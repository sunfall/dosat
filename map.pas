unit map;

{ adventure map for homms }

interface

uses LowGr, Monsters;

const
  mGrass = $00;

  mResource = $10;
  mRezGold = $11;
  mRezRocks = $12;
  mRezApples = $13;
  mRezEmeralds = $14;
  mRezQuartz = $15;
  mRezBeakers = $16;
  mRezClay = $17;
  mEasyResource = $18;

  mEasyTreasure = $20;
  mBag = $21;
  mChest = $22;
  mBarrel = $23;
  mArtifact = $24;
  mCamp = $25;   { one-time free creatures }
  mPotion = $26; { one-time move/spell pt bonus to all of your heroes }

  mMonster = $30;
  mHardMonster = $31;
  mHero = $32;

  mFirstObstacle = $34;
  mChasm = $34;
  mFlower1 = $35;
  mFlower2 = $36;
  mFlower3 = $37;
  mBigMountain = $38;
  mRocky = $39;
  mBranchTree = $3A;
  mBush = $3B;
  mBirchTree = $3C;
  mSnowTreeMountain = $3D;
  mTwisty2 = $3E;
  mGreenMountain = $3F;
  mObstacle = $40;
  mOakTree = $41;
  mPineTree = $42;
  mJungleTree = $43;
  mMountain = $44;
  mWater = $45;
  mHill = $46;
  mTree = $47;
  mSnowyMountain = $48;
  mTwistyTree = $49;
  mWillowTree = $4A;
  mElmTree = $4B;
  mSnowyPineTree = $4C;
  mDoodad = $4D;
  mCastlePart = $4E; { graphic part of adj castle hex }
  mRightHalf = $4F; { right half of a 2-hex building }

  mPreciousMine = $50;
  mGoldMine = $51;
  mRockMine = $52;
  mAppleMine = $53;
  mEmeraldMine = $54;
  mQuartzMine = $55;
  mBeakerMine = $56;
  mClayMine = $57;
  mSkillMine = $58;
  mFarmstead = $59;

  mDwelling = $60;
  mHordeDwelling = $61;

  mSchool = $70;           { gain skill }
  mSpellPavilion = $71;    { learn spell }
  mMonument = $72;         { gain experience }
  mShrine = $73;           { temporary skill boost }
  mAltar = $74;            { temporary creature stat bonus }
  mSageHut = $75;          { gain a level }
  mJunkMerchant = $76;     { artifact market }
  mLibrary = $77;          { spell market }
  mHermitHut = $78;        { exotic skill-like bonus }
  mUpgradeFort = $79;      { upgrade creatures }
  mMiningVillage = $7A;    { resources/week }
  mShamanHut = $7B;        { +spell speed }
  mMagicianHome = $7C;     { improved spells }
  mWizardHouse = $7D;      { +0.5 wizardry }
  mHouseofHusbandry = $7E; { +creatures in castles}

  mWatchtower = $80;

  mCastle = $90;
  mOutpost = $91;
  mJungleFort = $92;
  mCityOfShadows = $93;
  mCloudCastle = $94;
  mThievesGuild = $95;
  mFactory = $96;
  mLaboratory = $97;
  mPyramid = $98;
  mRuins = $99;
  mCircus = $9A;
  mEvilTemple = $9B;

  mLastCastle = mEvilTemple;

  mCache = $A0; { 12 }

  mTarget = $FE; { code for hero path algorithm }
  mFill = $FF;   { code for non-stack flood-fill }

  AIVisitable = [mResource..mHero, mPreciousMine..mCache];

  { high byte will handle roads/darkness }

  GeoSize = 10;
  NumGeos = (81 + 16) * 2;
  MapSize = 120;
  MapGeoSize = MapSize div GeoSize;

  geBottom = 1;    { geo edges }
  geLeft = 2;
  geTop = 3;
  geRight = 4;

  mgcNormal = 0;
  mgcCenter = 1;
  mgcCrossroad = 2;
  mgcCastle = 3;
  mgcSmallFort = 4;
  mgcBigFort = 5;

  mmdWalk = 1;
  mmdRoad = 2;

  NumCaches = 12;

  ClimateColor: array [0..4] of byte =
  (
    colSnow, colDesolate, colGreen, colTemperate2, colJungle
  );

type
  TGeomorph = array [1..GeoSize, 1..GeoSize] of byte;

  PGeoSet = ^TGeoSet;
  TGeoSet = array [1..NumGeos] of TGeomorph;

  PMap = ^TMap;
  TMap = array [1..MapSize, 1..MapSize] of byte;

  PWordMap = ^TWordMap;
  TWordMap = array [1..MapSize, 1..MapSize] of word;

  TMapGeo = record
    geo: byte;
    diff: byte;
    rand: byte;
    cat: byte;
  end;

  PMapGeos = ^TMapGeos;
  TMapGeos = array [1..MapGeoSize, 1..MapGeoSize] of TMapGeo;

  TMapGraphics = array [1..71] of TGraphic;
  PMapGraphics = ^TMapGraphics;

var
  Geos: PGeoSet;
  TheMap, MapInfo, Dist, Roads, Climate: PMap;
  MapNum: PWordMap;
  ToughFight: longint;
  MapGraphics: PMapGraphics;

const
  mgResource = 1;
  mgEasyResource = 2;
  mgEasyTreasure = 3;
  mgBag = 4;
  mgChest = 5;
  mgBarrel = 6;
  mgArtifact = 7;
  mgCamp = 8;
  mgPotion = 9;
  mgMonster = 10;
  mgHardMonster = 11;
  mgOakTree = 12;
  mgPineTree = 13;
  mgJungleTree = 14;
  mgMountain = 15;
  mgHill = 16;
  mgMineEntrance = 17;
  mgMineCart = 18;
  mgMineHouse = 19;
  mgMineHouseRight = 20;
  mgManaBolt = 21;
  mgDwelling = 22;
  mgSchool = 23;
  mgSpellPavilion = 24;
  mgMonument = 25;
  mgShrine = 26;
  mgAltar = 27;
  mgSageHut = 28;
  mgJunkMerchant = 29;
  mgLibrary = 30;
  mgWatchtower = 31;
  mgEye = 32;
  mgCastleLeft = 33;
  mgCastleUpLeft = 34;
  mgCache = 35;
  mgHero = 36;
  mgSnowyMountain = 37;
  mgTwistyTree = 38;
  mgWillowTree = 39;
  mgElmTree = 40;
  mgTowerRight = 41;
  mgTowerLeft = 42;
  mgHermitHut = 43;
  mgUpgradeFort = 44;
  mgSnowyPineTree = 45;
  mgGreenMountain = 46;
  mgTwisty2 = 47;
  mgShip = 48;
  mgBanana = 49;
  mgTombstone = 50;
  mgWindmill = 51;
  mgVolcano = 52;
  mgBranchTree = 53;
  mgBush = 54;
  mgBirchTree = 55;
  mgSnowTreeMountain = 56;
  mgRocky = 57;
  mgFlower1 = 58;
  mgFlower2 = 59;
  mgFlower3 = 60;
  mgBigMountain1 = 61;
  mgBigMountain2 = 62;
  mgBigMountain3 = 63;
  mgRockDecor1 = 64;
  mgRockDecor2 = 65;
  mgRockDecor3 = 66;
  mgMiningVillage = 67;
  mgShamanHut = 68;
  mgMagicianHome = 69;
  mgWizardHouse = 70;
  mgHouseofHusbandry = 71;

  MapForeColor: array [1..71] of integer =
  (
    colYellow, colWhite, colWhite, colYellow,
    colRed, colBlack, colDarkGray, colLightBlue,
    colBlue, colDarkGray, colDarkGray, colLightGreen,
    colDarkGreen, colPaleGreens + 4, colLightGray, colBrown,
    colLightGray, colLightGray, colLightGray, colLightRed,
    colWhite, colBrown, colDarkRed, colLightBlue,
    colLightBlue, colBlue, colRed, colBrown,
    colRed, colLightGray, colLightGray, colBlue,
    colLightGray, colLightGray, colDarkGray, colBrown,
    colWhite, colBrown, colPaleOranges, colBrown,
    colDarkGray, colDarkGray, colMagentas, colBrown,
    colWhite, colLightGray, colPaleOranges + 1, colTan,
    colYellow, colLightGray, colLightGray, colLightGray,
    colLightGreen, colGreens + 3, colBlack, colBlack,
    colDarkGray, colBlack, colBlack, colBlack,
    colBlack, colBlack, colBlack, colBlack,
    colBlack, colBlack, colGrays, colOranges,
    colGrays + 2, colOranges + 1, colOranges
  );

  MapBackColor: array [1..71] of integer =
  (
    colBlack, colBlack, colBlack, colBrown,
    colOrange, colBrown, colLightGray, colBlack,
    colBlack, colBlack, colBlack, colBrown,
    colBrown, colBrown, colDarkGray, colLightGray,
    colBlack, colDarkGray, colBrown, colBrown,
    colBlack, colLightRed, colRed, colBlue,
    colWhite, colDarkBlue, colBrown, colLightGreen,
    colLightRed, colDarkGray, colDarkGray, colWhite,
    colDarkGray, colDarkGray, colBlack, colBlack,
    colLightGray, colLightGreen, colPaleGreens + 3, colLightGreen,
    colLightGray, colLightGray, colBlack, colBlack,
    colDarkGreen, colDarkGreen, colBlack, colLightBlue,
    colBlack, colDarkGray, colBrown, colRed,
    colBrown, colPaleOranges, colBlack, colBlack,
    colLightGray, colBlack, colBlack, colBlack,
    colBlack, colBlack, colBlack, colBlack,
    colBlack, colBlack, colOranges, colPaleBurntOranges + 1,
    colPaleBlues + 3, colPaleBurntOranges + 2, colPaleOranges + 1
  );

  clSnowy = 0;
  clDesolate = 1;
  clTemperate = 2;
  clTemperate2 = 3;
  clJungle = 4;
  clSwapTrees = 8;
  clBorder = 16;

  CacheMonsters: array [1..NumCaches, 1..3, 1..3] of byte =
  (
    ((moCarnivorousPlant, 3, 8),
     (moFungus, 5, 12),
     (0, 0, 0)),
    ((moLaser, 4, 4),
     (moRobot, 2, 40),
     (moWobbler, 3, 25)),
    ((moAssassin, 4, 6),
     (moSoulThief, 4, 40),
     (0, 0, 0)),
    ((moBlob, 2, 48),
     (moLabAssistant, 4, 50),
     (0, 0, 0)),
    ((moIllusionist, 2, 12),
     (moWilloWisp, 3, 18),
     (moShadow, 3, 36)),
    ((moMadTurtle, 2, 15),
     (moGiantFrog, 3, 18),
     (moBunny, 6, 27)),
    ((moMadScientist, 2, 6),
     (moMimic, 4, 50),
     (0, 0, 0)),
    ((moEvilFog, 4, 12),
     (moUrchin, 4, 120),
     (0, 0, 0)),
    ((moRubberRat, 4, 40),
     (0, 0, 0),
     (0, 0, 0)),
    ((moDancingSword, 4, 8),
     (moDjinn, 3, 8),
     (0, 0, 0)),
    ((moTwoHeadedGiant, 4, 12),
     (moVulture, 1, 48),
     (0, 0, 0)),
    ((moWhirly, 6, 24),
     (0, 0, 0),
     (0, 0, 0))
  );

  CacheLevel: array [1..NumCaches] of byte =
  (
    3, 2, 3, 2, 3, 1, 3, 3, 1, 2, 3, 2
  );

function OnMap(i, j: integer): boolean;
function GeoX(x: integer): integer;
function GeoY(y: integer): integer;
function FindAdjMapHex(n, x, y: integer; var i, j: integer): boolean;
function AdjToMonster(M: PMap; i, j: integer): boolean;
function GeoEdge(m, e: byte): byte;
function ObstacleColor(x, y: integer): integer;
function FindNeutralMine(var x, y: integer): boolean;
function MineName(x, y: integer): string;

procedure MakeMapDist(M, D: PMap; a, b, x2, y2, t: integer);
procedure DrawMapGraphic(x, y, gr: integer);
procedure DrawMapHexData(mi, mj, x, y, md, part, road: integer);
procedure DrawRoad(mi, mj, x, y, road: integer);
procedure LoadGeos;
procedure MapGeosToMap(MG: PMapGeos);

function AdjToTerrain(i, j, t: integer): boolean;
procedure GrowWater;
procedure ShrinkWater;

function CombatDefFor(MG: PMapGeos; x, y: integer): integer;
procedure XlatMapXY(var x, y: integer);
function CacheStrength(n: integer): longint;
function DwellingGuardsQty(m: integer): integer;
function MapHintText(mh, x, y: integer): string;

implementation

uses Hexes, Rez, Castles, Players, Heroes, Artifact, Spells, XFace, XStrings;

procedure LoadMapGraphics;
  var f: file;
  begin
    assign(f, 'map.pic');
    reset(f, 1);
    blockread(f, MapGraphics^, sizeof(MapGraphics^));
    close(f);
  end;

function OnMap(i, j: integer): boolean;
  begin
    OnMap := (i >= 1) and (i <= MapSize) and (j >= 1) and (j <= MapSize);
  end;

function GeoX(x: integer): integer;
  begin
    GeoX := ((x - 1) div GeoSize) + 1;
  end;

function GeoY(y: integer): integer;
  begin
    GeoY := ((y - 1) div GeoSize) + 1;
  end;

function FindAdjMapHex(n, x, y: integer; var i, j: integer): boolean;
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

    FindAdjMapHex := OnMap(i, j);
  end;

function AdjToMonster(M: PMap; i, j: integer): boolean;
  var
    atm: boolean;
    h, ni, nj, md: integer;
  begin
    atm := false;

    for h := 1 to 6 do
      if FindAdjMapHex(h, i, j, ni, nj) then begin
        md := M^[ni, nj];
        if (md = mMonster) or (md = mHardMonster) then
          atm := true;
      end;

    AdjToMonster := atm;
  end;

function GeoEdge(m, e: byte): byte;
  const
    Twos: array [1..4] of byte = (4, 8, 1, 2);
    Threes: array [1..4] of byte = (9, 27, 1, 3);
  var ge: byte;
  begin
    if m > NumGeos div 2 then
      dec(m, NumGeos div 2);
    if m >= 82 then begin
      ge := ((m - 82) div Twos[e]) mod 2;
      if ge = 1 then ge := 2;
    end else begin
      ge := ((m - 1) div Threes[e]) mod 3;
    end;
    GeoEdge := ge;
  end;

function ObstacleColor(x, y: integer): integer;
  var oc: integer;
  begin
    oc := colGreen;

    case TheMap^[x, y] of
      mOakTree:       oc := colGreens + 3;
      mPineTree:      oc := colDarkGreen;
      mJungleTree:    oc := colPaleGreens + 4;
      mMountain:      oc := colLightGray;
      mWater:         oc := colDarkBlue;
      mHill:          oc := colBrown;
      mSnowyMountain: oc := colGrayCyans + 3;
      mTwistyTree:    oc := colBrown;
      mWillowTree:    oc := colPaleGreens + 3;
      mElmTree:       oc := colLightGreen;
      mSnowyPineTree: oc := colNewDarkGreen;
      mGreenMountain: oc := colGrayGreens;
      mTwisty2:       oc := colPaleOranges + 1;
      mBranchTree:    oc := colLightGreen;
      mBirchTree:     oc := colGreens + 5;
      mBush:          oc := colGreens + 3;
      mSnowTreeMountain: oc := colLightGray;
      mDoodad:        oc := ObstacleColor(x + 1, y);
      mRocky:         oc := colGrays + 1;
      mChasm:         oc := colDesolateShadow3;
      mBigMountain:   oc := colPaleBlues + 3;
      mFlower1:       oc := colRed;
      mFlower2:       oc := colLightBlue;
      mFlower3:       oc := colYellow;
    end;

    ObstacleColor := oc;
  end;

function FindNeutralMine(var x, y: integer): boolean;
  var
    found: boolean;
    i, j, oi, oj: integer;
  begin
    found := false;
    oi := random(MapSize);
    oj := random(MapSize);

    for i := 1 to MapSize do
      for j := 1 to MapSize do
        if not found then begin
          x := (i + oi) mod MapSize + 1;
          y := (j + oj) mod MapSize + 1;
          if (TheMap^[x, y] > mGoldMine) and (TheMap^[x, y] <= mSkillMine)
             and (MapNum^[x, y] = 0) then
            found := true;
        end;

    FindNeutralMine := found;
  end;

function MineName(x, y: integer): string;
  var s: string;
  begin
    if TheMap^[x, y] = mSkillMine then
      s := 'Tower of ' + SkillNames[MapInfo^[x, y]]
    else
      s := MineNames[TResource(TheMap^[x, y] - mGoldMine)];

    MineName := s;
  end;

procedure MakeMapDist(M, D: PMap; a, b, x2, y2, t: integer);
  var
    mdchange, pass, atm, visit: boolean;
    n, md, max: integer;

  function AddDistLayer: boolean;
    var
      change: boolean;
      h, i, j, ni, nj: integer;
    begin
      change := false;

      for i := 1 to MapSize do
        for j := 1 to MapSize do
          if D^[i, j] = n - 1 then
            for h := 1 to 6 do
              if FindAdjMapHex(h, i, j, ni, nj) then
                if D^[ni, nj] = 0 then begin
                  md := M^[ni, nj];
                  case t of
                    mmdWalk: begin
                               atm := AdjToMonster(M, ni, nj);
                               pass := (((md = mGrass)
                                         or (((md >= mResource)
                                              and (md <= mBarrel))
                                             or (md = mPotion))
                                         or ((md >= mCastle)
                                             and (md <= mLastCastle)))
                                        and not atm)
                                       or (md = mTarget);
                             end;
                    mmdRoad: pass := (md < mFirstObstacle)
                                     or ((md >= mCastle) and (md <= mLastCastle));
                  end;
                  if pass then begin
                    D^[ni, nj] := n;
                    change := true;
                  end;
                  if visit and (atm or (md in AIVisitable)) then
                    D^[ni, nj] := 128 + n;
                end;

      AddDistLayer := change;
    end;

  begin
    FillChar(D^, sizeof(D^), #0);
    atm := false;
    visit := (x2 = -1) and (t <> mmdRoad);

    D^[a, b] := 1;
    n := 2;
    if t = mmdRoad then max := 240 else max := 120;

    repeat
      mdchange := AddDistLayer;
      inc(n);
    until not mdchange or (n > max)
          or ((x2 = -1) and (n >= y2 + 2))
          or ((x2 <> -1) and (D^[x2, y2] <> 0));
  end;

procedure DrawMapGraphic(x, y, gr: integer);
  begin
    if gr in [mgSnowyPineTree, mgBirchTree, mgSnowTreeMountain, mgOakTree,
              mgFlower1, mgFlower2, mgFlower3,
              mgBigMountain1, mgBigMountain2, mgBigMountain3,
              mgShip, mgRocky, mgSageHut, mgMiningVillage] then
      DrawGraphic256c(x, y, MapGraphics^[gr])
    else
      DrawGraphic2c(x, y, MapForeColor[gr], MapBackColor[gr], MapGraphics^[gr],
                    false);
  end;

function MapHexMonster(x, y, md: integer; mg: TMapGeo; nudge: boolean): byte;
  var
    mhm, l: integer;
  begin
    if mg.diff = 0 then
      l := 5
    else begin
      l := (mg.diff - 1) div 2;
      if md = mHardMonster then inc(l);
      if (mg.diff > 1) and nudge then
        case (mg.rand + y) mod 5 of
          0: inc(l);
          3: if l > 0 then dec(l);
        end;
      if l > 5 then l := 5;
    end;
    mhm := ((mg.rand + x + y * 10) mod (ord(high(TCastleType)) + 1))
           * 6 + l + 1;

    MapHexMonster := mhm;
  end;

function RoadCalc(ri, rj, mask: integer): integer;
  var rn, rp: integer;

  function FindRoad(wx, wy: integer): boolean;
    begin
      FindRoad := OnMap(wx, wy) and ((Roads^[wx, wy] and mask) <> 0);
    end;

  begin
    if rj mod 2 = 1 then rn := 0 else rn := -1;
    rp := 0;
    if FindRoad(ri - 1,      rj)     then inc(rp, 1);
    if FindRoad(ri + rn,     rj - 1) then inc(rp, 2);
    if FindRoad(ri + rn + 1, rj - 1) then inc(rp, 4);
    if FindRoad(ri + 1,      rj)     then inc(rp, 8);
    if FindRoad(ri + rn + 1, rj + 1) then inc(rp, 16);
    if FindRoad(ri + rn,     rj + 1) then inc(rp, 32);
    RoadCalc := rp;
  end;

function HexCode(pm: PMap; i, j, m: integer): integer;
  var p, n: integer;

  function FindHex(cm, cx, cy: integer): boolean;
    var
      a: integer;
      fh: boolean;
    begin
      if OnMap(cx, cy) then begin
        a := pm^[cx, cy];
        if pm = Climate then a := a and $07;
        fh := a = cm;
      end else
        fh := true;
      FindHex := fh;
    end;

  begin
    p := 0;
    if j mod 2 = 1 then n := 0 else n := -1;

    if FindHex(m, i - 1,     j)     then inc(p, 1);
    if FindHex(m, i + n,     j - 1) then inc(p, 2);
    if FindHex(m, i + n + 1, j - 1) then inc(p, 4);
    if FindHex(m, i + 1,     j)     then inc(p, 8);
    if FindHex(m, i + n + 1, j + 1) then inc(p, 16);
    if FindHex(m, i + n,     j + 1) then inc(p, 32);

    HexCode := p;
  end;

function FindTerrain(wm, wx, wy: integer): boolean;
  begin
    FindTerrain := not OnMap(wx, wy) or (TheMap^[wx, wy] = wm);
  end;

function WaterCode(i, j, m: integer): integer;
  begin
    WaterCode := HexCode(TheMap, i, j, m);
  end;

function ClimateCode(i, j, m: integer): integer;
  begin
    ClimateCode := HexCode(Climate, i, j, m);
  end;

function SafeTerrain(x, y: integer): integer;
  begin
    if OnMap(x, y) then
      SafeTerrain := TheMap^[x, y]
    else
      SafeTerrain := -1;
  end;

type
  TWaterGrid = array [1..8, 1..8] of integer;
  PWaterGrid = ^TWaterGrid;

var
  watergrid: TWaterGrid;

const
  wgBorder = -2;
  wgChasm = -1;
  wgWater = 0;

  dwgFlower1 = -4;    { through -1 }
  dwgFaintRoad = -5;
  dwgRoad = -6;
  { -7 unused }

  dwgCorner = -11;       { shadowed }
  dwgRightEdge = -10;
  dwgBottomEdge = -9;
  dwgDot = -8;

  dwgCornerG = -15;      { background }
  dwgRightEdgeG = -14;
  dwgBottomEdgeG = -13;
  dwgDotG = -12;

  dwgCornerT = -19;      { fixed color (green) }
  dwgRightEdgeT = -18;
  dwgBottomEdgeT = -17;
  dwgDotT = -16;

  dwgSquareG = -20;

  WaterGridDef: TWaterGrid =
  (
    ($02, $02, $02, $02, $06, $04, $04, $04),
    ($00, $02, $02, $06, $0E, $0C, $0C, $0C),
    ($01, $03, $03, $47, $4E, $0E, $0C, $08),
    ($01, $01, $47, $47, $4E, $4E, $0C, $08),
    ($01, $21, $71, $71, $78, $78, $08, $08),
    ($01, $21, $31, $71, $78, $18, $18, $08),
    ($21, $21, $21, $31, $30, $10, $10, $00),
    ($20, $20, $20, $30, $10, $10, $10, $10)
  );

  WaterUpGridDef: TWaterGrid =
  (
    ($03, $03, $03, $03, $06, $04, $04, $04),
    ($01, $03, $03, $07, $0E, $0C, $0C, $0C),
    ($01, $03, $03, $47, $4E, $0E, $0C, $08),
    ($01, $01, $47, $47, $4E, $4E, $0C, $08),
    ($01, $21, $71, $71, $78, $78, $08, $08),
    ($20, $20, $30, $70, $78, $18, $18, $08),
    ($20, $20, $20, $30, $30, $10, $10, $10),
    ($20, $20, $20, $30, $10, $10, $10, $10)
  );

  WaterDownGridDef: TWaterGrid =
  (
    ($02, $02, $02, $02, $06, $04, $04, $04),
    ($02, $02, $02, $06, $06, $04, $04, $04),
    ($01, $03, $03, $47, $46, $06, $04, $04),
    ($01, $01, $47, $47, $4E, $4E, $0C, $08),
    ($01, $21, $71, $71, $78, $78, $08, $08),
    ($01, $21, $31, $71, $78, $18, $18, $08),
    ($21, $21, $21, $31, $38, $18, $18, $08),
    ($20, $20, $20, $30, $18, $18, $18, $18)
  );

  EdgeGridDef: TWaterGrid =
  (
    ($02, $00, $00, $00, $06, $00, $00, $04),
    ($00, $02, $00, $04, $0A, $08, $08, $0C),
    ($01, $03, $01, $45, $40, $02, $04, $00),
    ($00, $00, $46, $00, $00, $42, $04, $00),
    ($00, $20, $50, $00, $00, $70, $00, $00),
    ($00, $20, $10, $40, $68, $08, $18, $08),
    ($21, $01, $01, $11, $20, $00, $10, $00),
    ($20, $00, $00, $30, $00, $00, $00, $10)
  );

  MiddleGridDef: TWaterGrid =
  (
    ($00, $02, $02, $02, $00, $04, $04, $00),
    ($00, $00, $02, $02, $04, $04, $04, $00),
    ($00, $00, $02, $02, $0E, $0C, $08, $08),
    ($01, $01, $01, $47, $4E, $0C, $08, $08),
    ($01, $01, $21, $71, $78, $08, $08, $08),
    ($01, $01, $21, $31, $10, $10, $00, $00),
    ($00, $20, $20, $20, $10, $10, $00, $00),
    ($00, $20, $20, $00, $10, $10, $10, $00)
  );

  StonesGridDef: TWaterGrid =
  (
    ($02, $02, $02, $00, $04, $04, $04, $00),
    ($02, $02, $02, $02, $04, $04, $04, $04),
    ($00, $02, $02, $02, $00, $0C, $0C, $04),
    ($01, $01, $00, $00, $08, $08, $08, $00),
    ($01, $01, $01, $30, $38, $38, $08, $00),
    ($01, $01, $31, $30, $38, $38, $00, $00),
    ($00, $01, $31, $30, $30, $00, $00, $00),
    ($00, $00, $00, $00, $00, $00, $00, $00)
  );

  ManyStonesGridDef: TWaterGrid =
  (
    ($02, $02, $04, $04, $00, $00, $00, $00),
    ($02, $02, $04, $06, $02, $0C, $0C, $00),
    ($01, $01, $00, $02, $02, $0C, $0C, $00),
    ($01, $01, $00, $00, $00, $00, $00, $00),
    ($00, $00, $00, $20, $28, $18, $10, $00),
    ($20, $21, $11, $30, $28, $18, $10, $00),
    ($20, $21, $11, $10, $00, $00, $00, $00),
    ($00, $00, $00, $00, $00, $00, $00, $00)
  );

procedure MakeWaterGrid(mi, mj, wn, wg: integer);

  procedure ApplyGrid(wgg: PWaterGrid; pn, c: integer; bend: boolean);
    var
      x, y: integer;
      leftup, rightdown: boolean;
    begin
      leftup := false;
      rightdown := false;
      if bend and (wn = $49) then
        case mi mod 3 of
          0: leftup := true;
          1: rightdown := true;
        end;

      for x := 1 to 8 do
        for y := 1 to 8 do
          if (wgg^[y, x] and pn) <> 0 then begin
            if leftup and (x <= 4) and (y > 2) then
              watergrid[x, y - 2] := c
            else if rightdown and (x >= 5) and (y < 7) then
              watergrid[x, y + 2] := c
            else
              watergrid[x, y] := c;
          end;

      if (pn and $03) = $03 then watergrid[1, 2] := c;
      if (pn and $18) = $18 then watergrid[8, 7] := c;
    end;

  procedure RandomStar;
    var rx, ry, i, j, ct: integer;
    begin
      rx := random(4) + 3;
      ry := random(4) + 3;
      ct := 0;
      for i := -2 to 2 do
        for j := -2 to 2 do
          if watergrid[rx + i, ry + j] <> colBlack then inc(ct);
      if ct = 0 then begin
        if random(12) = 0 then begin
          watergrid[rx, ry] := colLightGray;
          watergrid[rx - 1, ry] := colDarkGray;
          watergrid[rx + 1, ry] := colDarkGray;
          watergrid[rx, ry - 1] := colDarkGray;
          watergrid[rx, ry + 1] := colDarkGray;
        end else begin
          watergrid[rx, ry] := colDarkGray;
        end;
      end;
    end;

  procedure ReplaceColor(c1, c2: integer);
    var x, y: integer;
    begin
      for x := 1 to 8 do
        for y := 1 to 8 do
          if watergrid[x, y] = c1 then
            watergrid[x, y] := c2;
    end;

  procedure ReplaceHatch(c1, c2, c3: integer);
    var x, y: integer;
    begin
      for x := 1 to 8 do
        for y := 1 to 8 do
          if watergrid[x, y] = c1 then
            if (x + y) mod 2 = 0 then
              watergrid[x, y] := c2
            else
              watergrid[x, y] := c3;
    end;

  procedure AddCliffs;

    procedure CliffLine(cx, cy: integer);
      begin
        watergrid[cx, cy] := colDesolateShadow;
        if (cx < 8) and (cy < 8)
           and (watergrid[cx + 1, cy + 1] = colBlack) then begin
          watergrid[cx + 1, cy + 1] := colDesolateShadow2;
          if (cx < 7) and (cy < 7)
             and (watergrid[cx + 2, cy + 2] = colBlack) then
            watergrid[cx + 2, cy + 2] := colDesolateShadow3;
        end;
      end;

    var x, y: integer;
    begin
      for x := 1 to 7 do
        for y := 1 to 7 do
          if (watergrid[x, y] = colGreen)
             and (watergrid[x + 1, y + 1] = colBlack) then
            CliffLine(x + 1, y + 1);
      if (wn and $01) = 0 then
        for y := 1 to 8 do
          if watergrid[1, y] = colBlack then
            CliffLine(1, y);
      if (wn and $06) = 0 then
        for x := 1 to 8 do
          if watergrid[x, 1] = colBlack then
            CliffLine(x, 1);

      if ((wn and $04) <> 0) and ((wn and $02) = 0) then begin
        x := 1;
        while watergrid[x, 1] = colGreen do inc(x);
        watergrid[x, 1] := colDesolateShadow;
        watergrid[x + 1, 1] := colDesolateShadow2;
        watergrid[x + 1, 2] := colDesolateShadow2;
        watergrid[x + 2, 1] := colDesolateShadow3;
        watergrid[x + 2, 2] := colDesolateShadow3;
        watergrid[x + 2, 3] := colDesolateShadow3;
        watergrid[x + 3, 1] := colDesolateShadow3;
      end;

      if ((wn and $01) <> 0) and ((wn and $02) = 0) then begin
        y := 1;
        while watergrid[1, y] = colGreen do inc(y);
        if ((mi > 1) and (MapInfo^[mi - 1, mj] in [$09, $39, $0F])
            and ((mi - 1 = 1) or (TheMap^[mi - 2, mj] = mChasm))
            and ((mi - 1) mod 3 = 1))
           or ((wn in [$49, $79, $4F])
               and ((mi = 1) or (TheMap^[mi - 1, mj] = mChasm))
               and (mi mod 3 = 0)) then begin
          watergrid[1, y] := colDesolateShadow;
          watergrid[1, y + 1] := colDesolateShadow;
          watergrid[2, y + 1] := colDesolateShadow2;
          watergrid[1, y + 2] := colDesolateShadow2;
          watergrid[2, y + 2] := colDesolateShadow2;
          watergrid[3, y + 2] := colDesolateShadow3;
          watergrid[1, y + 3] := colDesolateShadow3;
          watergrid[2, y + 3] := colDesolateShadow3;
          watergrid[3, y + 3] := colDesolateShadow3;
        end else begin
          watergrid[1, y] := colDesolateShadow2;
          watergrid[1, y + 1] := colDesolateShadow3;
          watergrid[2, y + 1] := colDesolateShadow3;
        end;
      end;
    end;

  procedure WaterBase(wc: integer);
    begin
      if wn in [$49, $79, $4F] then begin
        case mi mod 3 of
          0:   ApplyGrid(@WaterUpGridDef, wn, wc, false);
          1:   ApplyGrid(@WaterDownGridDef, wn, wc, false);
          else ApplyGrid(@WaterGridDef, wn, wc, false);
        end;
      end else begin
        ApplyGrid(@WaterGridDef, wn, wc, false);
      end;
    end;

  procedure BasicRoad(mask: integer);
    var wn2: integer;
    begin
      wn2 := RoadCalc(mi, mj, mask) or $40;
      ApplyGrid(@WaterGridDef, wn2, dwgRoad, true);
    end;

  procedure RandomDecorations(num, c: integer);
    var i, rx, ry, ax, ay, ct: integer;
    begin
      for i := 1 to num do begin
        rx := random(7) + 1;
        ry := random(7) + 1;
        ct := 0;
        for ax := rx - 1 to rx + 1 do
          for ay := ry - 1 to ry + 1 do
            if (ax >= 1) and (ay >= 1) and (ax <= 8) and (ay <= 8)
               and (watergrid[ax, ay] = c) then
              inc(ct);
        if ct = 9 then begin
          for ax := rx - 1 to rx + 1 do
            for ay := ry - 1 to ry + 1 do
              watergrid[ax, ay] := colInvisible;
          watergrid[rx, ry] := dwgFlower1 + random(4);
        end;
      end;
    end;

  procedure FixHalfBricks(wnv: integer);
    var i, j: integer;
    begin
      for i := 1 to 8 do
        for j := 1 to 7 do
          if (watergrid[i, j] = dwgRightEdgeG)
             and not ((watergrid[i, j + 1] = dwgRightEdgeG)
                      or (watergrid[i, j + 1] = dwgCornerG)) then
            watergrid[i, j] := dwgCornerG;

      if wnv = $49 then
        for i := 1 to 8 do
          if watergrid[i, 8] = dwgRightEdgeG then
            watergrid[i, 8] := dwgCornerG;
    end;

  procedure AddStoneEdges;
    var
      i, j, n: integer;
      right, bottom, corner, straight: boolean;
    begin
      straight := (RoadCalc(mi, mj, $04) or $40 = $49)
                  or (RoadCalc(mi, mj, $08) or $40 = $49);
      for i := 1 to 8 do
        for j := 1 to 8 do
          if watergrid[i, j] = colLightGray then begin
            if i < 8 then
              right := watergrid[i + 1, j] = colLightGray
            else
              right := false;
            if j < 8 then begin
              bottom := watergrid[i, j + 1] = colLightGray;
              if i < 8 then
                corner := watergrid[i + 1, j + 1] = colLightGray
              else
                corner := false;
            end else begin
              bottom := not straight;
              corner := not straight;
            end;

            if not right and not bottom then
              watergrid[i, j] := dwgCorner
            else if not right then
              watergrid[i, j] := dwgRightEdge
            else if not bottom then
              watergrid[i, j] := dwgBottomEdge
            else if not corner then
              watergrid[i, j] := dwgDot;
          end;
    end;

  procedure MakeHoles;

    procedure Deepen(di, dj: integer);
      begin
        if (di >= 1) and (dj >= 1) and (di <= 8) and (dj <= 8) then begin
          case watergrid[di, dj] of
            dwgRoad:      watergrid[di, dj] := dwgFaintRoad;
            dwgFaintRoad: watergrid[di, dj] := colGreen;
          end;
        end;
      end;

    var t, i, j: integer;
    begin
      for t := 1 to 16 do begin
        i := random(8) + 1;
        j := random(8) + 1;
        Deepen(i, j);
        Deepen(i - 1, j);
        Deepen(i + 1, j);
        Deepen(i, j - 1);
        Deepen(i, j + 1);
      end;
    end;

  procedure UnifyStones(dwg: integer);
    var i, j: integer;
    begin
      for i := 1 to 8 do
        for j := 1 to 8 do
          if (watergrid[i, j] >= dwgCorner)
             and (watergrid[i, j] <= dwgDot) then
            inc(watergrid[i, j], dwg - dwgCorner);
    end;

  procedure AddClimate(cl: integer);
    var c, n, p, fx, fy: integer;

    procedure CheckClimate(oi, oj, bm: integer);
      begin
        inc(oi, mi);
        inc(oj, mj);
        if OnMap(oi, oj) and ((Climate^[oi, oj] and $07) = cl) then
          p := p or bm;
      end;

    begin
      c := Climate^[mi, mj] and $07;
      if c = cl then begin
        for fx := 1 to 8 do
          for fy := 1 to 8 do
            watergrid[fx, fy] := ClimateColor[c];
      end else begin
        if mj mod 2 = 1 then n := 0 else n := -1;
        p := $40;

        CheckClimate(n,     -1, $07);
        CheckClimate(n + 1, -1, $0E);
        CheckClimate(-1,     0, $23);
        CheckClimate(1,      0, $1C);
        CheckClimate(n,      1, $31);
        CheckClimate(n + 1,  1, $38);

        if p <> $40 then begin
          wn := p;
          WaterBase(ClimateColor[cl]);
        end;
      end;
    end;

  var
    wn2, wn3, n, cc, fx, fy: integer;
    rs: longint;
  begin
    rs := randseed;
    randseed := (mi * longint(256) * 13 + mj * 17) div 2;
    wn := (wn and $7F) or $40;

    for fx := 1 to 8 do
      for fy := 1 to 8 do
        watergrid[fx, fy] := colGreen;

    if wg = wgBorder then begin
      AddClimate(clTemperate2);
      AddClimate(clDesolate);
      AddClimate(clJungle);
      AddClimate(clSnowy);
    end else if wg = wgWater then begin
      WaterBase(colDarkBlue);
{
      if not (wn in [$7F, $49, $4F, $79, $52, $73, $5E, $64, $67, $7C])
         and (random(2) = 0) then
        RandomDecorations(1, colDarkBlue); }
    end else if wg = wgChasm then begin
      WaterBase(colBlack);
      AddCliffs;
      RandomStar;
    end else begin
      if (wg and $10) <> 0 then begin
{       wn2 := RoadCalc(mi, mj, $10) or $40;
        ApplyGrid(@MiddleGridDef, wn2, dwgRoad, true); }
      end;
      if (wg and $20) <> 0 then begin
        BasicRoad($20);
        MakeHoles;
      end;
      if (wg and $01) <> 0 then begin
        BasicRoad($01);
      end;
      if (wg and $40) <> 0 then begin
        wn2 := RoadCalc(mi, mj, $40) or $40;
        ApplyGrid(@EdgeGridDef, wn2, colLightGray, true);
        ApplyGrid(@MiddleGridDef, wn2, dwgRoad, true);
        if (wg and $02) = 0 then
          ReplaceColor(colLightGray, dwgCornerT)
        else
          ReplaceColor(colLightGray, dwgCornerG);
      end;
      if (wg and $02) <> 0 then begin
        wn3 := RoadCalc(mi, mj, $02) or $40;
        ApplyGrid(@WaterGridDef, wn3, colLightBlue, true);
        ReplaceHatch(colLightBlue, dwgCornerG, dwgRightEdgeG);
      end;

      if (wg and $04) <> 0 then begin
        wn2 := RoadCalc(mi, mj, $04) or $40;
        ApplyGrid(@StonesGridDef, wn2, colLightGray, true);
      end;
      if (wg and $08) <> 0 then begin
        wn2 := RoadCalc(mi, mj, $08) or $40;
        ApplyGrid(@ManyStonesGridDef, wn2, colLightGray, true);
      end;

      if (wg and $0C) <> 0 then AddStoneEdges;
      if (wg and $02) <> 0 then FixHalfBricks(wn3);
      if ((wg and $0C) <> 0) and ((wg and $42) <> 0) then begin
        if (wg and $02) <> 0 then
          UnifyStones(dwgCornerG)
        else
          UnifyStones(dwgCornerT);
      end;
      if (wg and $10) <> 0 then RandomDecorations(24, colGreen);
    end;

    if not DrawBackground then
      ReplaceColor(colGreen, colInvisible)
    else if mi <> 0 then begin
      cc := ClimateColor[Climate^[mi, mj] and $07];
      if cc <> colGreen then
        ReplaceColor(colGreen, cc);
    end;

    randseed := rs;
  end;

procedure DrawWaterGrid(mi, mj, x, y: integer);
  const
    decorations: array [1..2, 0..3] of integer =
    (
      (mgFlower1, mgFlower2, mgFlower3, mgRocky),
      (mgRockDecor1, mgRockDecor2, mgRockDecor3, mgRocky)
    );
    shadows: array [0..4] of byte =
    (
{     colSnowShadow, colDesolateShadow, colDarkGreen, colDarkGreen, colJungleShadow }
      colDarkGray, colDarkGray, colDarkGreen, colDarkGreen, colJungleShadow
    );

  var
    dwi, dwj, gx, gy, w, c, bc, d: integer;

  procedure ApplyPattern(p, c1, c2: integer);
    const
      patterns: array [0..4] of string[16] =
      (
        '0001000100011111',
        '0001000100010001',
        '0000000000001111',
        '0000000000000001',
        '1111100110011111'
      );
    var
      i, j, cn: integer;
    begin
      for i := 0 to 3 do
        for j := 0 to 3 do begin
          if patterns[p][i + j * 4 + 1] = '0' then
            cn := c1
          else
            cn := c2;
          if cn <> colInvisible then
            XPutPixel(gx + i, gy + j, cn);
        end;
    end;

  procedure GetClimateColor;
    begin
      if DrawBackground then
        c := BackgroundColor
      else
        c := XGetPixel(gx, gy);
    end;

  begin
    if DrawBackground then bc := BackgroundColor else bc := colInvisible;

    for dwi := 1 to 8 do
      for dwj := 1 to 8 do begin
        gx := x + (dwi - 1) * 4;
        gy := y + (dwj - 1) * 4;
        w := watergrid[dwi, dwj];
        if w = colInvisible then begin
        end else if w >= 0 then begin
          XPut4x4Pixels(gx, gy, w);
        end else begin
          case w of
            dwgFlower1..dwgFlower1 + 3:
              begin
                GetClimateColor;
                if c in [colSnow, colDesolate] then
                  d := 2
                else
                  d := 1;
                DrawSmallGraphic256c(gx - 3, gy - 3,
                                     MapGraphics^[decorations[d, w - dwgFlower1]]);
                if DrawBackground then
                  XRectangle(gx - 4, gy - 4, gx + 7, gy + 7, BackgroundColor);
              end;
            dwgFaintRoad: begin
                            GetClimateColor;
                            case c of
                              colSnow:       c := colSnowRoad2;
                              colDesolate:   c := colDesolateRoad;
                              colGreen:      c := colGreenRoad;
                              colTemperate2: c := colTemperate2Road;
                              colJungle:     c := colJungleRoad;
                            end;
                            XPut4x4Pixels(gx, gy, c);
                          end;
            dwgRoad: begin
                       GetClimateColor;
                       if c = colSnow then
                         c := colSnowRoad
                       else
                         c := colTan;
                       XPut4x4Pixels(gx, gy, c);
                     end;
            dwgCorner
            ..dwgDot:   begin
                          if mi = 0 then
                            c := colDarkGreen
                          else
                            c := shadows[Climate^[mi, mj] and $07];
                          ApplyPattern(w - dwgCorner, colLightGray, c);
                        end;
            dwgCornerG
            ..dwgDotG:  ApplyPattern(w - dwgCornerG, colLightGray, bc);
            dwgCornerT
            ..dwgDotT:  ApplyPattern(w - dwgCornerT, colLightGray, colGreen);
            dwgSquareG: ApplyPattern(4, colLightGray, bc);
          end;
        end;
      end;
  end;

procedure DrawMapHexData(mi, mj, x, y, md, part, road: integer);
  const
    xlat: array [1..42, 1..2] of integer =
    (
      (mResource, mgResource),
      (mEasyResource, mgEasyResource),
      (mEasyTreasure, mgEasyTreasure),
      (mBag, mgBag),
      (mChest, mgChest),
      (mBarrel, mgBarrel),
      (mPotion, mgPotion),
      (mOakTree, mgOakTree),
      (mPineTree, mgPineTree),
      (mJungleTree, mgJungleTree),
      (mMountain, mgMountain),
      (mHill, mgHill),
      (mDwelling, mgDwelling),
      (mSchool, mgSchool),
      (mSpellPavilion, mgSpellPavilion),
      (mMonument, mgMonument),
      (mShrine, mgShrine),
      (mAltar, mgAltar),
      (mSageHut, mgSageHut),
      (mJunkMerchant, mgJunkMerchant),
      (mLibrary, mgLibrary),
      (mWatchtower, mgWatchtower),
      (mCache, mgCache),
      (mSnowyMountain, mgSnowyMountain),
      (mTwistyTree, mgTwistyTree),
      (mWillowTree, mgWillowTree),
      (mElmTree, mgElmTree),
      (mHermitHut, mgHermitHut),
      (mUpgradeFort, mgUpgradeFort),
      (mGreenMountain, mgGreenMountain),
      (mTwisty2, mgTwisty2),
      (mSnowyPineTree, mgSnowyPineTree),
      (mBranchTree, mgBranchTree),
      (mBirchTree, mgBirchTree),
      (mBush, mgBush),
      (mSnowTreeMountain, mgSnowTreeMountain),
      (mRocky, mgRocky),
      (mFlower1, mgFlower1),
      (mFlower2, mgFlower2),
      (mFlower3, mgFlower3),
      (mMiningVillage, mgMiningVillage),
      (mHordeDwelling, mgDwelling)
    );
  var
    i, j, nudge, c, oldbc: integer;
    r: TResource;
    inv, outp, olddb: boolean;
    gr: TGraphic;

  procedure AnyHLine32(x, y, c: integer);
    begin
      if DrawBackground then HLine32(x, y, c);
    end;

  procedure AnyVLine32(x, y, c: integer);
    begin
      if DrawBackground then VLine32(x, y, c);
    end;

  procedure BorderBox(bbc: integer);
    begin
      AnyHLine32(x, y, bbc);
      AnyHLine32(x, y + 31, bbc);
      AnyVLine32(x, y, bbc);
      AnyVLine32(x + 31, y, bbc);
    end;

  begin
    olddb := DrawBackground;
    oldbc := BackgroundColor;

    if mi = 0 then
      BackgroundColor := colGreen
    else if (md = mWater) and (part = $3F) then
      BackgroundColor := colDarkBlue
    else begin
      BackgroundColor := ClimateColor[Climate^[mi, mj] and $07];
      if (Climate^[mi, mj] and clBorder) <> 0 then begin
        MakeWaterGrid(mi, mj, 0, wgBorder);
        DrawWaterGrid(mi, mj, x, y);
        DrawBackground := false;
      end;
    end;

    if (md = mObstacle) or (md = mGrass) then begin
      if md = mObstacle then
        c := colLightGray
      else
        c := BackgroundColor;
      if road <> 0 then
        DrawRoad(mi, mj, x, y, road)
      else if DrawBackground then begin
        for j := 0 to 31 do
          HLine32(x, y + j, c);
      end;
    end else if md = mWater then begin
      MakeWaterGrid(mi, mj, part, wgWater);
      DrawWaterGrid(mi, mj, x, y);
    end else if md = mChasm then begin
      MakeWaterGrid(mi, mj, part, wgChasm);
      DrawWaterGrid(mi, mj, x, y);
    end else if md = mDooDad then begin
      if TheMap^[mi + 1, mj] = mWater then begin
        DrawBackground := true;
        BorderBox(colDarkBlue);
        DrawMapGraphic(x + 1, y + 1, mgShip);
      end else begin
        BorderBox(BackgroundColor);
        c := 0;
        case TheMap^[mi + 1, mj] of
          mJungleTree: c := mgBanana;
          mTwisty2:    c := mgTombstone;
          mHill:       c := mgWindmill;
          mMountain:   c := mgVolcano;
        end;
        if c <> 0 then
          DrawMapGraphic(x + 1, y + 1 , c);
      end;
    end else begin
      if road <> 0 then begin
        DrawRoad(mi, mj, x, y, road);
        DrawBackground := false;
      end else begin
        BorderBox(BackgroundColor);
      end;

      for j := 1 to high(xlat) do
        if md = xlat[j, 1] then
          DrawMapGraphic(x + 1, y + 1, xlat[j, 2]);

      if md = mBigMountain then begin
        case part of
          0: DrawMapGraphic(x + 1, y + 1, mgMountain);
          1: begin
               DrawMapGraphic(x + 1, y + 2, mgBigMountain1);
               if DrawBackground then AnyHLine32(x, y + 1, BackgroundColor);
             end;
          2: begin
               DrawMapGraphic(x + 2, y + 0, mgBigMountain2);
               if DrawBackground then begin
                 AnyHLine32(x, y + 30, BackgroundColor);
                 AnyVLine32(x + 1, y, BackgroundColor);
               end;
             end;
          3: begin
               DrawMapGraphic(x + 0, y + 0, mgBigMountain3);
               if DrawBackground then begin
                 AnyHLine32(x, y + 30, BackgroundColor);
                 AnyVLine32(x + 30, y, BackgroundColor);
               end;
             end;
        end;
      end;

      if (md >= mRezGold) and (md <= mRezClay) then begin
        r := TResource(md - mRezGold);
        DrawGraphic2c(x + 1, y + 1, ResourceColors[r], ResourceBacks[r],
                      ResourceGraphics[r], false);
      end;

      if md = mTree then
        DrawGraphic2c(x + 1, y + 1, colLightGray, colDarkGray,
                      MapGraphics^[mgPineTree], false);

      if ((md >= mPreciousMine) and (md <= mClayMine))
         or (md = mFarmstead) then begin
        if (part and 1) = 0 then begin
          if (md = mAppleMine) or (md = mBeakerMine) or (md = mFarmstead) then
            DrawGraphic2c(x + 1, y + 1, PlColor[part div 16],
                          MapBackColor[mgMineHouse],
                          MapGraphics^[mgMineHouse], false)
          else
            DrawMapGraphic(x + 1, y + 1, mgMineEntrance)
        end else begin
          if (md = mAppleMine) or (md = mBeakerMine)
             or (md = mFarmstead) then begin
            DrawMapGraphic(x + 1, y + 1, mgMineHouseRight);
            i := 21;
            j := 6;
          end else begin
            DrawGraphic2c(x + 1, y + 1, PlColor[part div 16],
                          MapBackColor[mgMineCart],
                          MapGraphics^[mgMineCart], false);
            i := 21;
            j := 0;
          end;
          if md = mFarmstead then begin
            if part div 16 = 1 then
              DrawSmallGraphic2c(x + 1 + 5, y + 1 + 16, ResourceColors[rGold],
                                 ResourceBacks[rGold], ResourceGraphics[rGold])
            else
              DrawSmallGraphic2c(x + 1 + 5, y + 1 + 16, colBlack,
                                 colDarkGray, ResourceGraphics[rGold]);
          end else if (md >= mGoldMine) and (md <= mClayMine) then begin
            r := TResource(md - mGoldMine);
            if (r = rApples) or (r = rBeakers) then
              DrawSmallGraphic2c(x + 1 + 5, y + 1 + 16, ResourceColors[r],
                                 ResourceBacks[r], ResourceGraphics[r])
            else
              DrawSmallGraphic2c(x + 1 + 10, y + 1 + 13, ResourceColors[r],
                                 ResourceBacks[r], ResourceGraphics[r]);
          end;

          if md <> mFarmstead then
            DrawSmallGraphic2c(x + i, y + j, PlColor[part div 16], colBlack,
                               MapGraphics^[mgCamp]);
        end;
      end;

      if md = mSkillMine then begin
        if (part and 1) = 0 then begin
          DrawGraphic2c(x + 1, y + 1, MapForeColor[mgTowerLeft],
                        PlColor[part div 16], MapGraphics^[mgTowerLeft],
                        false);
          DrawSmallGraphic2c(x + 22, y + 0, PlColor[part div 16], colBlack,
                             MapGraphics^[mgCamp]);
        end else begin
          DrawMapGraphic(x + 1, y + 1, mgTowerRight);
          DrawSmallGraphic2c(x + 1 + 7, y + 1 + 10, colWhite, colBlack,
                             SkillGraphic(part div 16)^);
        end;
      end;

      if (md = mShamanHut) or (md = mMagicianHome)
         or (md = mWizardHouse) or (md = mHouseofHusbandry) then begin
        case md of
          mShamanHut:        i := mgShamanHut;
          mMagicianHome:     i := mgMagicianHome;
          mWizardHouse:      i := mgWizardHouse;
          mHouseofHusbandry: i := mgHouseofHusbandry;
        end;
        if part div 16 = 0 then
          c := MapForecolor[i]
        else
          c := PlColor[part div 16];
        DrawGraphic2c(x + 1, y + 1, c, MapBackColor[i], MapGraphics^[i],
                      false);
      end;

      if md = mMiningVillage then begin
        if part div 16 = 1 then
          DrawSmallGraphic2c(x + 1 + 16, y + 1 + 16, colYellow,
                             colBlack, ArtGraphics[agPickAxe])
        else
          DrawSmallGraphic2c(x + 1 + 16, y + 1 + 16, colBlack,
                             colBlack, ArtGraphics[agPickAxe]);
      end;

      if (md = mMonster) or (md = mHardMonster) or (md = mCamp) then begin
        if part = 0 then begin
          if md = mMonster then
            DrawMapGraphic(x + 1, y + 1, mgMonster)
          else if (md = mHardMonster) then
            DrawMapGraphic(x + 1, y + 1, mgHardMonster)
          else
            DrawMapGraphic(x + 1, y + 1, mgCamp);
        end else begin
          if md = mCamp then c := colFriend
          else c := colEnemy;
          DrawGraphic2c(x + 1, y + 1, c, colBlack, MonsterGraphic(part)^,
                        false);
        end;
      end;

      if (md = mDwelling) or (md = mHordeDwelling) then begin
        if part = 0 then
          DrawSmallGraphic2c(x + 1 + 11, y + 1 + 16, colBlue, colBlack,
                             MapGraphics^[mgMonster])
        else begin
          if md = mDwelling then
            gr := MonsterGraphic(part and $7F)^
          else
            gr := CastleIcons[ciBuyCreatures];
          if (part and $80) <> 0 then
            c := colRed
          else if (part and $100) <> 0 then
            c := colBlue
          else
            c := colDarkGray;
          DrawSmallGraphic2c(x + 1 + 11, y + 1 + 16, c, colBlack, gr);
        end;
      end;

      if md = mShrine then begin
        DrawSmallGraphic2c(x + 13, y + 17, colLightBlue, colBlue,
                           SkillGraphic(part)^);
      end;

      if md = mArtifact then begin
        if part = 0 then
          DrawMapGraphic(x + 1, y + 1, mgArtifact)
        else
          DrawGraphic2c(x + 1,  y + 1, ArtData[part].fcol,
                        ArtData[part].bcol, ArtGraphics[ArtData[part].gr],
                        false);
      end;

      if md = mLibrary then
        DrawSmallGraphic2c(x + 1 + 10, y + 1 + 10, MapForeColor[mgManaBolt],
                           MapBackColor[mgManaBolt], MapGraphics^[mgManaBolt]);

      if md = mJunkMerchant then
        DrawSmallGraphic2c(x + 1 + 15, y + 1 + 16, MapForeColor[mgArtifact],
                           MapBackColor[mgArtifact], MapGraphics^[mgArtifact]);

      if md = mWatchtower then
        DrawSmallGraphic2c(x + 1 + 10, y + 1 + 8, MapForeColor[mgEye],
                           MapBackColor[mgEye], MapGraphics^[mgEye]);

      if md = mCache then begin
        if part <> 0 then
          DrawSmallGraphic2c(x + 1 + 10, y + 1 + 15, colLightRed, colBlack,
                             MonsterGraphic(part)^);
      end;

      if md = mAltar then begin
        if part = altCheetah then
          gr := MapGraphics^[mgMonster]
        else
          gr := MonsterGraphic(Altars[part].mo)^;
        DrawSmallGraphic2c(x + 1 + 10, y + 1 + 8, colOranges + 5, colBlack,
                           gr);
      end;

      if (md >= mCastle) and (md <= mLastCastle) then begin
        c := PlColor[part div 16];
        part := part and $0F;
        if part >= 8 then begin
          dec(part, 8);
          outp := true;
        end else
          outp := false;
        case part of
          1: begin
               j := mgCastleLeft;
               inv := false;
               nudge := 0;
             end;
          2: begin
               j := mgCastleUpLeft;
               inv := false;
               nudge := 1;
               if DrawBackground then AnyVLine32(x + 1, y, BackgroundColor);
             end;
          3: begin
               j := mgCastleUpLeft;
               inv := true;
               nudge := -1;
               if DrawBackground then AnyVLine32(x + 30, y, BackgroundColor);
             end;
          4: begin
               j := mgCastleLeft;
               inv := true;
               nudge := 0;
             end;
        end;
        if (part >= 1) and (part <= 4) then begin
          DrawGraphic2c(x + 1 + nudge, y + 1, MapForeColor[j], MapBackColor[j],
                        MapGraphics^[j], inv);
          if md = mCastle then
            gr := MapGraphics^[mgHardMonster]
          else if md = mOutpost then
            gr := MapGraphics^[mgMonster]
          else if outp then
            gr := MonsterGraphic(MonsterForLevel(TCastleType(md - mJungleFort), 1))^
          else
            gr := MonsterGraphic(MonsterForLevel(TCastleType(md - mJungleFort), 6))^;

          if part = 2 then
            DrawHalfMedGraphic2c(x + 22, y + 1 + 6, c, colBlack, 1, gr)
          else if part = 3 then
            DrawHalfMedGraphic2c(x, y + 1 + 6, c, colBlack, 6, gr);
        end;
      end;
    end;

    DrawBackground := olddb;
    BackgroundColor := oldbc;
  end;

procedure DrawRoad(mi, mj, x, y, road: integer);
  begin
    MakeWaterGrid(mi, mj, RoadCalc(mi, mj, $FF), road);
    DrawWaterGrid(mi, mj, x, y);
  end;

procedure LoadGeos;
  var
    f: file;
    result: word;
  begin
    assign(f, 'geos.dat');
    reset(f, 1);
    BlockRead(f, Geos^, sizeof(Geos^), result);
    close(f);
  end;

var
  FloodM: PMap;
  Floodc, Floodrep: integer;

procedure FloodSub(i, j: integer);
  begin
    FloodM^[i, j] := Floodc;

    if (i > 1) and (FloodM^[i - 1, j] = Floodrep) then
      FloodSub(i - 1, j);
    if (i < MapSize) and (FloodM^[i + 1, j] = Floodrep) then
      FloodSub(i + 1, j);

    if j mod 2 = 0 then dec(i);

    if (j > 1) then begin
      if (i >= 1) and (FloodM^[i, j - 1] = Floodrep) then
        FloodSub(i, j - 1);
      if (i < MapSize) and (FloodM^[i + 1, j - 1] = Floodrep) then
        FloodSub(i + 1, j - 1);
    end;
    if (j < MapSize) then begin
      if (i >= 1) and (FloodM^[i, j + 1] = Floodrep) then
        FloodSub(i, j + 1);
      if (i < MapSize) and (FloodM^[i + 1, j + 1] = Floodrep) then
        FloodSub(i + 1, j + 1);
    end;
  end;

procedure Flood(M: PMap; i, j, rep, c: integer);
  begin
    FloodM := M;
    Floodrep := rep;
    Floodc := c;
    FloodSub(i, j);
  end;

procedure BigFlood(M: PMap; i, j, rep, c: integer);
  var
    change: boolean;
    x, y: integer;

  procedure SetSpot(a, b: integer);
    begin
      if M^[a, b] <> mFill then begin
        M^[a, b] := mFill;
        change := true;
      end;
    end;

  procedure CheckSpot(cx, cy: integer);
    begin
      if M^[cx, cy] = mFill then begin
        if (cx > 1) and (M^[cx - 1, cy] = rep) then
          SetSpot(cx - 1, cy);
        if (cx < MapSize) and (M^[cx + 1, cy] = rep) then
          SetSpot(cx + 1, cy);

        if cy mod 2 = 0 then dec(cx);

        if (cy > 1) then begin
          if (cx >= 1) and (M^[cx, cy - 1] = rep) then
            SetSpot(cx, cy - 1);
          if (cx < MapSize) and (M^[cx + 1, cy - 1] = rep) then
            SetSpot(cx + 1, cy - 1);
        end;
        if (cy < MapSize) then begin
          if (cx >= 1) and (M^[cx, cy + 1] = rep) then
            SetSpot(cx, cy + 1);
          if (cx < MapSize) and (M^[cx + 1, cy + 1] = rep) then
            SetSpot(cx + 1, cy + 1);
        end;
      end;
    end;

  begin
    M^[i, j] := mFill;

    repeat
      change := false;
      for x := 1 to MapSize do
        for y := 1 to MapSize do
          CheckSpot(x, y);
    until not change;

    for x := 1 to MapSize do
      for y := 1 to MapSize do
        if M^[x, y] = mFill then M^[x, y] := c;
  end;

procedure MakeRoad(x1, y1, x2, y2: integer; monspath: boolean; num: integer);
  var
    n, h, ni, nj, newi, newj: integer;

  procedure SetX2Y2;
    var
      md, mh, x3, y3: integer;
      av: longint;

    procedure NoteMonster(x, y: integer);
      begin
        md := TheMap^[x, y];
        if (md = mMonster) or (md = mHardMonster) then begin
          MapInfo^[x, y] := MapInfo^[x, y] or $80;
          av := MonsterData[MapInfo^[x, y] and $7F].cost
                * longint(MapNum^[x, y]);
          if av > ToughFight then ToughFight := av;
        end;
      end;

    begin
      if monspath then begin
        NoteMonster(x2, y2);
        for mh := 1 to 6 do
          if FindAdjMapHex(mh, x2, y2, x3, y3) then
            NoteMonster(x3, y3);
      end else
        Roads^[x2, y2] := Roads^[x2, y2] or num;
    end;

  begin
    if num = 1 then
      num := 1 shl random(7);

    MakeMapDist(TheMap, Dist, x1, y1, x2, y2, mmdRoad);

    if dist^[x2, y2] <> 0 then begin
      n := dist^[x2, y2];
      SetX2Y2;
      repeat
        newi := 0;
        for h := 1 to 6 do
          if FindAdjMapHex(h, x2, y2, ni, nj) then
            if Dist^[ni, nj] = n - 1 then begin
              if (newi = 0) or (ni > newi)
                 or ((ni = newi) and (nj > newj)) then begin
                newi := ni;
                newj := nj;
              end;
            end;
        if newi <> 0 then begin
          x2 := newi;
          y2 := newj;
          SetX2Y2;
        end;
        dec(n);
      until (newi = 0) or (n = 1);
    end;
  end;

procedure FindMGC(MG: PMapGeos; M: PMap; mgc: integer; var x, y: integer);
  var i, j, gi, gj, mi, mj: integer;
  begin
    x := 0;
    for i := 1 to MapGeoSize do
      for j := 1 to MapGeoSize do
        if MG^[i, j].cat = mgc then begin
          for gi := 1 to GeoSize do
            for gj := 1 to GeoSize do begin
              mi := (i - 1) * GeoSize + gi;
              mj := (j - 1) * GeoSize + gj;
              if (M^[mi, mj] >= mJungleFort)
                 and (M^[mi, mj] <= mLastCastle) then begin
                x := mi;
                y := mj;
              end;
            end;
        end;
  end;

function GeoHasCastle(MG: PMapGeos; M: PMap; gi, gj: integer): boolean;
  var
    x, y, mi, mj: integer;
    ghc: boolean;
  begin
    ghc := false;

    for x := 1 to GeoSize do
      for y := 1 to GeoSize do begin
        mi := (gi - 1) * GeoSize + x;
        mj := (gj - 1) * GeoSize + y;
        if (M^[mi, mj] >= mJungleFort) and (M^[mi, mj] <= mLastCastle) then
          ghc := true;
      end;

    GeoHasCastle := ghc;
  end;

procedure RegionizeTerrain;
  type
    TArrHalf = array [0..129, 0..64] of real;
    PArrHalf = ^TArrHalf;
  var
    arr: array [0..1] of PArrHalf;

  procedure AddArr(ax, ay: integer; var avg: real; var avgct: integer);
    begin
      if (ax >= 0) and (ax <= 128) and (ay >= 0) and (ay <= 128) then begin
        avg := avg + arr[ay div 65]^[ax, ay mod 65];
        inc(avgct);
      end;
    end;

  procedure SetArr(ax, ay: integer; r: real);
    begin
      arr[ay div 65]^[ax, ay mod 65] := r;
    end;

  procedure MakePlasmaCloud(grit: real);
    var
      avg, gp: real;
      wid, n, avgct, x, y: integer;
    begin
      SetArr(  0,   0, random(6) + 6);
      SetArr(128,   0, random(6) + 6);
      SetArr(  0, 128, random(6) + 6);
      SetArr(128, 128, random(6) + 6);

      wid := 128;
      n := 1;

      repeat
        { do square midpoints }

        for x := 0 to n - 1 do
          for y := 0 to n - 1 do begin
            avg := 0;
            avgct := 0;
            AddArr(x * wid, y * wid, avg, avgct);
            AddArr((x + 1) * wid, y * wid, avg, avgct);
            AddArr(x * wid, (y + 1) * wid, avg, avgct);
            AddArr((x + 1) * wid, (y + 1) * wid, avg, avgct);
            avg := avg / avgct;
            gp := random(8) / grit;
            if random(2) = 0 then avg := avg + gp else avg := avg - gp;
            SetArr(x * wid + wid div 2, y * wid + wid div 2, avg);
          end;

        { do diamond midpoints }

        n := n * 2;
        wid := wid div 2;

        for x := 0 to n do
          for y := 0 to n do
            if (x + y) mod 2 = 1 then begin
              avg := 0;
              avgct := 0;
              AddArr(x * wid, (y - 1) * wid, avg, avgct);
              AddArr((x + 1) * wid, y * wid, avg, avgct);
              AddArr(x * wid, (y + 1) * wid, avg, avgct);
              AddArr((x - 1) * wid, y * wid, avg, avgct);
              avg := avg / avgct;
              gp := random(8) / grit;
              if random(2) = 0 then avg := avg + gp else avg := avg - gp;
              SetArr(x * wid, y * wid, avg);
            end;

        grit := grit * 2;
      until wid = 1;
    end;

  function ArrInt(x, y: integer): integer;
    var
      r: real;
      n: integer;
    begin
      r := arr[y div 65]^[x, y mod 65];
      if r < 0 then n := round(-r / 2) else n := round(r / 2);
      n := n mod 16;

      ArrInt := n;
    end;

  const
    TreeTbl: array [boolean, 0..4] of integer =
    (
      (mPineTree, mTwistyTree, mOakTree, mBirchTree, mJungleTree),
      (mSnowyPineTree, mTwisty2, mElmTree, mBranchTree, mWillowTree)
    );
    MtnTbl: array [0..4] of integer =
    (
      mSnowyMountain, mBigMountain, mMountain, mSnowTreeMountain, mGreenMountain
    );
    HillTbl: array [0..4] of integer =
    (
      mRocky, mChasm, mHill, mBush, mFlower1
    );
  var
    i, x, y, md, n: integer;
    bands: array [0..15] of integer;
  begin
    for i := 0 to 1 do New(arr[i]);

    MakePlasmaCloud({0.75} 1.0); { for climate type }

    bands[0] := random(5);

    for i := 1 to 15 do
      case bands[i - 1] of
        0, 4: bands[i] := random(3) + 1;
        1..3: begin
                bands[i] := random(4);
                if bands[i] = bands[i - 1] then
                  bands[i] := 4;
              end;
      end;

    for x := 1 to MapSize do
      for y := 1 to MapSize do begin
        n := ArrInt(x, y);
        Climate^[x, y] := bands[n];
        if n mod 2 = 1 then inc(Climate^[x, y], clSwapTrees);
      end;

    MakePlasmaCloud(0.75); { for terrain type }

    bands[0] := random(5);

    for i := 1 to 15 do begin
      bands[i] := random(4);
      if bands[i] = bands[i - 1] then bands[i] := 4;
    end;

    for x := 1 to MapSize do
      for y := 1 to MapSize do begin
        md := TheMap^[x, y];
        if md in [mObstacle, mMountain, mTree] then begin
          n := Climate^[x, y];
          if md in [mObstacle, mMountain] then begin
            case bands[ArrInt(x, y)] of
              0: md := MtnTbl[n and $07];
              1: md := TreeTbl[(n and clSwapTrees) = 0, n and $07];
              2: md := TreeTbl[(n and clSwapTrees) <> 0, n and $07];
              3: md := HillTbl[n and $07];
              4: md := mWater;
            end;
          end else if md = mTree then begin
            md := TreeTbl[ArrInt(x, y) mod 2 = 0, n and $07];
          end;
          TheMap^[x, y] := md;
        end;
      end;

    for i := 0 to 1 do Dispose(arr[i]);
  end;

procedure MapGeosToMap(MG: PMapGeos);
  var
    i, j, x, y, g, n, n2, tree, xo, yo, cnum, pnum, mons, m: integer;
    gp: longint;
    gx, gy, mgi, mgj, p: integer;
    cx, cy, rx, ry, cenx, ceny, NumCrossroads: integer;
    ct: TCastleType;
    rcr, rrr, rrs: boolean;
    m2, mostdiff: integer;
    change: boolean;
  const
    obs: array [1..5] of byte =
    (
      mOakTree, mElmTree, mMountain, mHill, mWater
    );
    trees: array [1..2] of byte =
    (
      mOakTree, mElmTree
    );
    ReplacePavilion: array [0..15] of byte =
    (
      mMiningVillage, mMiningVillage, mHordeDwelling, mHordeDwelling,
      mShamanHut, mMagicianHome, mWizardHouse, mHouseofHusbandry,
      mSpellPavilion, mSpellPavilion, mSpellPavilion, mSpellPavilion,
      mSpellPavilion, mSpellPavilion, mSpellPavilion, mSpellPavilion
    );

  procedure FindCastle;
    var icm: integer;

    function IsCastle(icx, icy: integer): boolean;
      begin
        icm := TheMap^[icx, icy];
        cnum := MapInfo^[icx, icy];
        IsCastle := (icm >= mCastle) and (icm <= mLastCastle);
      end;

    begin
      if IsCastle(i + 1, j) then
        p := 1
      else if IsCastle(i + n, j + 1) then
        p := 2
      else if IsCastle(i + n - 1, j + 1) then
        p := 3
      else if IsCastle(i - 1, j) then
        p := 4;
      if p <> 0 then m2 := icm;
    end;

  procedure OrAdjRoads(ri, rj, orv: integer);
    var rn: integer;

    function OrRoad(wx, wy: integer): boolean;
      begin
        if OnMap(wx, wy) and (Roads^[wx, wy] <> 0) then
          Roads^[wx, wy] := Roads^[wx, wy] or orv;
      end;

    begin
      if rj mod 2 = 1 then rn := 0 else rn := -1;
      OrRoad(ri - 1,      rj);
      OrRoad(ri + rn,     rj - 1);
      OrRoad(ri + rn + 1, rj - 1);
      OrRoad(ri + 1,      rj);
      OrRoad(ri + rn + 1, rj + 1);
      OrRoad(ri + rn,     rj + 1);
    end;

  function DoodadSpot(ri, rj: integer): boolean;
    var rn, rm: integer;
    begin
      if rj mod 2 = 1 then rn := 0 else rn := -1;
      rm := TheMap^[ri, rj];

      DoodadSpot := (rm in [mTwisty2, mWater, mJungleTree, mHill, mMountain])
                    and (TheMap^[ri - 1, rj] = rm)
                    and (TheMap^[ri + rn, rj - 1] = rm)
                    and (TheMap^[ri + rn + 1, rj - 1] = rm)
                    and (TheMap^[ri + 1, rj] = rm)
                    and (TheMap^[ri + rn + 1, rj + 1] = rm)
                    and (TheMap^[ri + rn, rj + 1] = rm);
    end;

  function DiffClimate(cl, cx, cy: integer): boolean;
    var
      nc: integer;
      dc: boolean;
    begin
      dc := false;
      if OnMap(cx, cy) then begin
        nc := (Climate^[cx, cy] and $07);
        if nc <> cl then begin
          if not (cl = clSnowy)
             and not ((cl = clJungle) and (nc <> clSnowy))
             and not ((cl = clDesolate) and (nc <> clSnowy)
                      and (nc <> clJungle))
             and not ((cl = clTemperate2) and (nc <> clSnowy)
                      and (nc <> clJungle) and (nc <> clDesolate)) then
            dc := true;
        end;
      end;
      DiffClimate := dc;
    end;

  begin
    FillChar(TheMap^, sizeof(TheMap^), #0);
    FillChar(MapInfo^, sizeof(MapInfo^), #0);
    FillChar(MapNum^, sizeof(MapNum^), #0);

    { copy geos to map }
    { find greatest difficulty }

    mostdiff := 0;

    for i := 1 to MapGeoSize do
      for j := 1 to MapGeoSize do begin
        xo := (i - 1) * GeoSize;
        yo := (j - 1) * GeoSize;
        g := MG^[i, j].geo;
        for x := 1 to GeoSize do
          for y := 1 to GeoSize do
            TheMap^[xo + x, yo + y] := Geos^[g][x, y];
        if MG^[i, j].diff > mostdiff then
          mostdiff := MG^[i, j].diff;
      end;

    { replace spell pavilions with other structures }

    p := 0;

    for i := 1 to MapSize do
      for j := 1 to MapSize do
        if TheMap^[i, j] = mSpellPavilion then begin
          mgi := GeoX(i);
          mgj := GeoY(j);

          if (MG^[mgi, mgj].cat and $0F) <> mgcCastle then begin
            n := ReplacePavilion[(MG^[mgi, mgj].rand + j) mod 16];
            if (n = mWizardHouse) and ((i mod 2) = 0) then n := mMiningVillage;
            if (n = mMagicianHome) and (p = 4) then n := mShamanHut;
            TheMap^[i, j] := n;
            if n = mMagicianHome then inc(p);
          end;

{         TheMap^[i, j] := mHordeDwelling;  }
        end;

    { replace random resources, obstacles, mines, castles }
    { pick dwellings, monsters, camps, artifacts, guild spells }
    { note other parts of castle, mine }

    cnum := 1;
    NumCastles := 0;

    for i := 1 to MapSize do
      for j := 1 to MapSize do begin
        mgi := GeoX(i);
        mgj := GeoY(j);
        gx := ((i - 1) mod GeoSize) + 1;
        gy := ((j - 1) mod GeoSize) + 1;
        case TheMap^[i, j] of
          mResource: TheMap^[i, j] := mRezGold + random(7);
          mPreciousMine: TheMap^[i, j] := mAppleMine + random(5);
          mSkillMine: MapInfo^[i, j] := random(NumNSkills) + 1;
          mCastle:   begin
                       ct := TCastleType(random(ord(high(TCastleType)) + 1));
                       TheMap^[i, j] := mJungleFort + ord(ct);
                       MapInfo^[i, j] := cnum;
                       m := MG^[mgi, mgj].cat;
                       if (m and $0F) = mgcCastle then
                         pnum := m div 16
                       else
                         pnum := 0;
                       NewCastle(@Castle[cnum], i, j, ct,
                                 ((m and $0F) = mgcCrossroad)
                                 or (m = mgcSmallFort),
                                 pnum);
                       if pnum <> 0 then
                         Player[pnum].Towns[1] := cnum;
                       inc(cnum);
                       inc(NumCastles);
                     end;
          mDwelling,
          mMonster,
          mHardMonster,
          mCamp:     begin
                       mons := MapHexMonster(gx, gy, TheMap^[i, j],
                                             MG^[mgi, mgj],
                                             TheMap^[i, j] <> mDwelling);
                       gp := 1200 - 240 + random(480);
                       n := MG^[mgi, mgj].diff;
                       gp := gp * n + (gp * n * n) div 8;
                       MapInfo^[i, j] := mons;
                       case TheMap^[i, j] of
                         { FIXME: 1200 isn't enough to handle Serpent Angels. }
                         mDwelling:    n := 1200 div MonsterData[mons].cost;
                         mMonster,
                         mHardMonster: n := gp div MonsterData[mons].cost;
                         mCamp:        if mons mod 6 = 1 then
                                         n := 25 + 5 * random(3)
                                       else
                                         n := 15 + 5 * random(3);
                       end;
                       if n < 1 then n := 1;
                       MapNum^[i, j] := n;
                       if (TheMap^[i, j] = mDwelling)
                          and (MonsterLevel(mons) >= 3) then
                         MapInfo^[i, j] := MapInfo^[i, j] or $80;
                     end;
          mHordeDwelling: begin
                            MapNum^[i, j] := 40;
                            MapInfo^[i, j] := $80;
                          end;
          mArtifact: if MG^[mgi, mgj].diff <= 4 then
                       MapInfo^[i, j] := RandomArtifact(1)
                     else if MG^[mgi, mgj].diff <= 8 then
                       MapInfo^[i, j] := RandomArtifact(2)
                     else
                       MapInfo^[i, j] := RandomArtifact(3);
          mSpellPavilion: begin
                            n := ((MG^[mgi, mgj].diff - 1) div 3) + 1;
                            if n < 1 then n := 1;
                            if n > 4 then n := 4;
                            MapInfo^[i, j] := RandomSpell(n);
                            MapNum^[i, j] := 0;
                          end;
          mFarmstead:    MapNum^[i, j] := 1;
          mMiningVillage: begin
                            MapNum^[i, j] := 1;
                            MapInfo^[i, j] := random(6) + 1;
                          end;
          mJunkMerchant: begin
                           MapNum^[i, j] := 2;
                           MapInfo^[i, j] := RandomArtifact(2);
                         end;
          mLibrary:      begin
                           MapNum^[i, j] := 2;
                           MapInfo^[i, j] := random(6) + 1;
                         end;
          mCache:        MapInfo^[i, j] := random(NumCaches) + 1;
          mSchool:       MapInfo^[i, j] := (MG^[mgi, mgj].rand
                                            mod NumSkills) + 1;
          mShrine:       MapInfo^[i, j] := ((MG^[mgi, mgj].rand + j)
                                            mod NumNSkills) + 1;
          mAltar:        begin
                           n := MG^[mgi, mgj].diff
                                + (MG^[mgi, mgj].rand mod 3) - 1;
                           if n < 1 then n := 1;
                           if n > 12 then n := 12;
                           MapInfo^[i, j] := n;
                         end;
          mUpgradeFort:  MapInfo^[i, j] := random(5) + 1;
          mHouseofHusbandry: MapInfo^[i, j] := random(6) + 1;
        end;
      end;

    { note other parts of castle, mine }

    for i := 1 to MapSize do
      for j := 1 to MapSize do begin
        case TheMap^[i, j] of
          mRightHalf:  if i > 1 then MapInfo^[i, j] := TheMap^[i - 1, j];
          mCastlePart: begin
                         if j mod 2 = 1 then n := 1 else n := 0;
                         p := 0;
                         FindCastle;
                         if p <> 0 then begin
                           m := MG^[GeoX(i), GeoY(j)].cat;
                           if ((m and $0F) = mgcCrossroad)
                              or (m = mgcSmallFort) then
                             inc(p, 8);
                           MapInfo^[i, j] := (m2 - mCastle) + 16 * p;
                           MapNum^[i, j] := cnum;
                         end;
                       end;
        end;
      end;

    { add roads }

    FillChar(Roads^, sizeof(Roads^), #0);
    FindMGC(MG, TheMap, mgcCenter, cenx, ceny);
    rcr := random(4) <> 0;                    { castle to crossroad }
    rrr := random(4) <> 0;                    { crossroad to crossroad }
    rrs := (cenx <> 0) and (random(4) <> 0);  { crossroad to center }
    NumCrossroads := 0;
    if not rcr and not rrr and not rrs then rrr := true;

    for i := 1 to MapGeoSize do
      for j := 1 to MapGeoSize do
        if ((MG^[i, j].cat and $0F) = mgcCrossroad)
           and GeoHasCastle(MG, TheMap, i, j) then
          inc(NumCrossroads);

    if (NumCrossroads > 0) and (NumCrossroads <= NumPlayers) then begin
      for i := 1 to NumCrossroads do begin
        FindMGC(MG, TheMap, mgcCrossroad + 16 * i, rx, ry);
        if rx <> 0 then begin
          if rcr then begin
            for j := 1 to NumPlayers do
              if i = ((j - 1) div (NumPlayers div NumCrossroads)) + 1 then begin
                FindMGC(MG, TheMap, mgcCastle + 16 * j, cx, cy);
                if cx <> 0 then MakeRoad(rx, ry, cx, cy + 1, false, 1);
              end;
          end;
          if rrr then begin
            j := (i mod NumCrossroads) + 1;
            FindMGC(MG, TheMap, mgcCrossroad + 16 * j, cx, cy);
            if cx <> 0 then MakeRoad(rx, ry, cx, cy + 1, false, 1);
          end;
          if rrs then MakeRoad(rx, ry, cenx, ceny + 1, false, 1);
        end;
      end;
    end else begin
      n := random(NumPlayers - 1) + 1;
      if NumPlayers = 2 * n then
        n2 := NumPlayers div 2
      else
        n2 := NumPlayers;
      for i := 1 to n2 do begin
        FindMGC(MG, TheMap, mgcCastle + 16 * i, cx, cy);
        j := ((i - 1 + n) mod NumPlayers) + 1;
        FindMGC(MG, TheMap, mgcCastle + 16 * j, rx, ry);
        MakeRoad(cx, cy, rx, ry + 1, false, 1);
      end;
    end;

    repeat
      change := false;
      for i := 1 to MapSize do
        for j := 1 to MapSize do
          if Roads^[i, j] <> 0 then
            if RoadCalc(i, j, $FF)
               in [1 + 2 + 4, 2 + 4 + 8, 4 + 8 + 16, 8 + 16 + 32,
                   16 + 32 + 1, 32 + 1 + 2, 1 + 2 + 4 + 8, 2 + 4 + 8 + 16,
                   4 + 8 + 16 + 32, 8 + 16 + 32 + 1,
                   16 + 32 + 1 + 2, 32 + 1 + 2 + 4,
                   1 + 2, 2 + 4, 4 + 8, 8 + 16, 16 + 32, 32 + 1] then begin
              OrAdjRoads(i, j, Roads^[i, j]);
              Roads^[i, j] := 0;
              change := true;
            end;
    until not change;

    { use plasma clouds to determine climates / terrains }

    RegionizeTerrain;

    { no chasm by water }

    for j := 1 to MapSize do begin
      if j mod 2 = 1 then n := 0 else n := -1;
      for i := 1 to MapSize do
        if TheMap^[i, j] = mChasm then
          if (SafeTerrain(i - 1, j) = mWater)
             or (SafeTerrain(i + 1, j) = mWater)
             or (SafeTerrain(i + n, j - 1) = mWater)
             or (SafeTerrain(i + n + 1, j - 1) = mWater)
             or (SafeTerrain(i + n, j + 1) = mWater)
             or (SafeTerrain(i + n + 1, j + 1) = mWater) then
            BigFlood(TheMap, i, j, mChasm, mWater);
    end;

    { get rid of single-hex water/chasm }

    for i := 1 to MapSize do
      for j := 1 to MapSize do begin
        m := TheMap^[i, j];
        if (m = mChasm) and (WaterCode(i, j, mChasm) = 0) then
          TheMap^[i, j] := mRocky
        else if (m = mWater) and (WaterCode(i, j, mWater) = 0) then
          TheMap^[i, j] := mFlower1 + random(3);
      end;

    { note water/chasm pattern, flower/mountain type, climates w/ border }

    for j := 1 to MapSize do begin
      if j mod 2 = 1 then n := 0 else n := -1;
      for i := 1 to MapSize do begin
        m := TheMap^[i, j];
        if m in [mWater, mChasm] then begin
          p := WaterCode(i, j, m);
          MapInfo^[i, j] := p;
        end else if m = mFlower1 then
          TheMap^[i, j] := mFlower1 + random(3)
        else if m = mBigMountain then begin
          p := (i - 1 + (j mod 2) * 2) mod 3 + 1;
          case p of
            1: if not FindTerrain(m, i + n, j + 1)
                  or not FindTerrain(m, i + n + 1, j + 1) then
                 p := 0;
            2: if not FindTerrain(m, i + n + 1, j - 1)
                  or not FindTerrain(m, i + 1, j) then
                 p := 0;
            3: if not FindTerrain(m, i + n, j - 1)
                  or not FindTerrain(m, i - 1, j) then
                 p := 0;
          end;
          MapNum^[i, j] := p;
        end;

        m := Climate^[i, j] and $07;
        if (DiffClimate(m, i + n, j - 1)
            or DiffClimate(m, i + n + 1, j - 1)
            or DiffClimate(m, i - 1, j)
            or DiffClimate(m, i + 1, j)
            or DiffClimate(m, i + n, j + 1)
            or DiffClimate(m, i + n + 1, j + 1)) then
          Climate^[i, j] := Climate^[i, j] or clBorder;
      end;
    end;

    { place doodads }

    for n := 1 to 64 do begin
      i := random(MapSize - 2) + 2;
      j := random(MapSize - 2) + 2;
      if DoodadSpot(i, j) then
        TheMap^[i, j] := mDooDad;
    end;

    { place treasure map treasures }

    dec(mostdiff, 2);
    if mostdiff < 1 then mostdiff := 1;

    for n := 1 to NumTreasureMaps do begin
      repeat
        i := random(MapSize) + 1;
        j := random(MapSize) + 1;
      until (MG^[GeoX(i), GeoY(j)].diff >= mostdiff)
            and (TheMap^[i, j] < mFirstObstacle);
      TreasureMap[n].x := i;
      TreasureMap[n].y := j;
    end;

    FoundMaps := 0;

    { determine castle-path monsters and hardest one }

    ToughFight := 0;

    for cnum := 1 to NumCastles - 1 do begin
      MakeMapDist(TheMap, Dist, Castle[cnum].MapX, Castle[cnum].MapY,
                  -1, 240, mmdRoad);
      for n := cnum + 1 to NumCastles do
        if Dist^[Castle[n].MapX, Castle[n].MapY] <> 0 then
          MakeRoad(Castle[cnum].MapX, Castle[cnum].MapY,
                   Castle[n].MapX, Castle[n].MapY, true, 0);
    end;

    inc(ToughFight, ToughFight div 5);

  end;

function AdjToTerrain(i, j, t: integer): boolean;
  var
    att: boolean;
    h, ni, nj, md: integer;
  begin
    att := false;

    for h := 1 to 6 do
      if FindAdjMapHex(h, i, j, ni, nj) then
        if TheMap^[ni, nj] = t then
          att := true;

    AdjToTerrain := att;
  end;

procedure GrowWater;
  var i, j, m: integer;
  begin
    for i := 1 to MapSize do
      for j := 1 to MapSize do
        if TheMap^[i, j] = mGrass then
          if AdjToTerrain(i, j, mWater) then
            TheMap^[i, j] := mFill;

    for i := 1 to MapSize do
      for j := 1 to MapSize do
        if TheMap^[i, j] = mFill then begin
          TheMap^[i, j] := mWater;
          MapInfo^[i, j] := $80;
        end;

    for i := 1 to MapSize do
      for j := 1 to MapSize do
        if TheMap^[i, j] = mWater then
          MapInfo^[i, j] := WaterCode(i, j, mWater)
                            or (MapInfo^[i, j] and $80);
  end;

procedure ShrinkWater;
  var i, j: integer;
  begin
    for i := 1 to MapSize do
      for j := 1 to MapSize do
        if TheMap^[i, j] = mWater then
          if (MapInfo^[i, j] and $80) <> 0 then begin
            TheMap^[i, j] := mGrass;
            MapInfo^[i, j] := 0;
          end;

    for i := 1 to MapSize do
      for j := 1 to MapSize do
        if TheMap^[i, j] = mWater then
          MapInfo^[i, j] := WaterCode(i, j, mWater);
  end;

function CombatDefFor(MG: PMapGeos; x, y: integer): integer;
  const
    def: array [mFirstObstacle..mRightHalf] of byte =
    (
      27, 75, 0, 0, 78, 72,
      60, 63, 66, 69, 57, 54,
      0, 1, 3, 5, 7, 19, 9,
      0, 11, 13, 15, 17, 51,
      0, 0, 0
    );
    def2: array [mFirstObstacle..mRightHalf] of byte =
    (
      22, 77, 0, 0, 80, 74,
      62, 65, 68, 71, 59, 56,
      0, 41, 42, 43, 44, 50, 45,
      0, 46, 47, 48, 49, 53,
      0, 0, 0
    );
  var
    cdf, h, h2, nx, ny, fx, fy, i, most, mosti, rand, md: integer;
    count: array [mFirstObstacle..mRightHalf] of integer;
  begin
    if (x = 1) and (y = 1) then
      cdf := 1
    else begin
      fillchar(count, sizeof(count), #0);

      for h := 1 to 6 do
        if FindAdjMapHex(h, x, y, nx, ny) then
          for h2 := 1 to 6 do
            if FindAdjMapHex(h2, nx, ny, fx, fy) then begin
              md := TheMap^[fx, fy];
              if md in [mFirstObstacle..mRightHalf] then begin
                if md in [mFlower2, mFlower3] then
                  md := mFlower1;
                inc(count[md]);
              end;
            end;

      most := 0;
      for i := low(count) to high(count) do
        if count[i] > most then begin
          most := count[i];
          mosti := i;
        end;

      rand := MG^[GeoX(x), GeoY(y)].rand;

      if (most = 0) or (def[mosti] = 0) then
        cdf := 1
      else if (rand + x + y * 3) mod 8 = 0 then
        cdf := def[mosti] + 1
      else if (rand + x + y) mod 2 = 0 then
        cdf := def2[mosti]
      else
        cdf := def[mosti];
    end;

    CombatDefFor := cdf;
  end;

procedure XlatMapXY(var x, y: integer);
  var i: integer;
  begin
    if TheMap^[x, y] = mRightHalf then
      dec(x);
    if TheMap^[x, y] = mCastlePart then begin
      i := MapNum^[x, y];
      x := Castle[i].MapX;
      y := Castle[i].MapY;
    end;
  end;

function CacheStrength(n: integer): longint;
  var
    i: integer;
    av: longint;
  begin
    av := 0;
    for i := 1 to 3 do
      if CacheMonsters[n, i, 1] <> 0 then
        inc(av, longint(MonsterData[CacheMonsters[n, i, 1]].cost)
                * CacheMonsters[n, i, 2] * CacheMonsters[n, i, 3]);
    CacheStrength := av;
  end;

function DwellingGuardsQty(m: integer): integer;
  begin
    DwellingGuardsQty := 1800 * (MonsterLevel(m) - 2) div MonsterData[m].cost;
  end;

function MapHintText(mh, x, y: integer): string;
  const
    SpellMineHint: array [1..3] of string[50] =
    (
      'allied heroes have +1 spellcasting speed',
      'allied heroes have improved spells',
      'allied heroes can use +5 spell points per round'
    );
  var
    i, info, h: integer;
    s, adj: string;
    visited, eye: boolean;
    AS: TArmySet;
    r: TResource;

  procedure VisitString(hv: integer);
    begin
      if mh <> 0 then begin
        if GetVisited(mh, GeoX(x), GeoY(y), hv) then
          s := s + ' (visited)'
        else
          s := s + ' (not visited)';
      end;
    end;

  procedure OwnerString;
    begin
      s := s + chr(colLightGray) + '(';
      if MapNum^[x, y] = Turn then
        s := s + 'yours'
      else if MapNum^[x, y] = 0 then
        s := s + 'unowned'
      else
        s := s + 'enemy''s';
      s := s + ')';
    end;

  function PaidStr: string;
    begin
      if MapNum^[x, y] = 1 then
        PaidStr := chr(colLightGray) + '(unpaid)'
      else
        PaidStr := chr(colLightGray) + '(paid)';
    end;

  begin
    s := '';

    XlatMapXY(x, y);

    visited := (MapNum^[x, y] and BitTable[Turn]) <> 0;
    info := MapInfo^[x, y];
    eye := (mh <> 0) and (Hero^[mh].HermitBonus = hbEye)
           and (sqr(Hero^[mh].MapX - x) + sqr(Hero^[mh].MapY - y) < 200);

    case TheMap^[x, y] of
      mMonster,
      mHardMonster,
      mCamp:        begin
                      if TheMap^[x, y] = mCamp then
                        adj := 'friendly'
                      else
                        adj := '';
                      s := MonsterDescription(info and $7F, MapNum^[x, y],
                                              adj, eye);
                    end;
      mSchool:      begin
                      s := 'School of ' + SkillNames[info];
                      if mh <> 0 then begin
                        s := s + chr(colLightGray);
                        if GetVisited(mh, GeoX(x), GeoY(y), hvSchool) then
                          s := s + ' (visited)'
                        else if not CanGainSkillLevel(mh, info) then
                          s := s + ' (can''t learn)'
                        else if GetSkillLevel(mh, info) = 0 then
                          s := s + ' (can learn as new skill)'
                        else
                          s := s + ' (can learn more of)';
                      end;
                    end;
      mSpellPavilion: begin
                        if visited then begin
                          s := 'Spell Pavilion teaching '
                               + SpellData[info].name;
                          if mh <> 0 then begin
                            s := s + chr(colLightGray);
                            if CheckForSpell(Hero^[mh].SS, info) then
                              s := s + ' (known)'
                            else
                              s := s + ' (not known)';
                          end;
                        end else
                          s := 'Spell Pavilion';
                      end;
      mAltar:       begin
                      s := 'Altar of the ' + Altars[info].name
                           + chr(colLightGray) + ' (gives your troops '
                           + AltarAbilityStr(info) + ' for 3 days)';
                      if mh <> 0 then begin
                        if Hero^[mh].AltarBonus = 0 then
                          s := s + ' (you have no bonus)'
                        else
                          s := s + ' (you have '
                               + AltarAbilityStr(Hero^[mh].AltarBonus) + ')';
                      end;
                    end;
      mShrine:      begin
                      s := 'Shrine of ' + SkillNames[info];
                      if mh <> 0 then begin
                        s := s + chr(colLightGray);
                        if Hero^[mh].ShrineBonus = 0 then
                          s := s + ' (you have no bonus)'
                        else
                          s := s + ' (you have +2 '
                               + SkillNames[Hero^[mh].ShrineBonus]
                               + ')';
                      end;
                    end;
      mCache:       if MapNum^[x, y] = 0 then begin
                      s := 'SPECIAL';
                      for i := 1 to 3 do
                        if CacheMonsters[info, i, 1] <> 0 then begin
                          AS[i].monster := CacheMonsters[info, i, 1];
                          AS[i].qty := CacheMonsters[info, i, 2]
                                       * CacheMonsters[info, i, 3];
                        end else
                          AS[i] := NilArmy;
                      ArmyMessage(0, 3, @AS, 'Fort', eye);
                    end else
                      s := 'Empty Fort';
      mDwelling:    begin
                      s := MonsterData[info and $7F].name + ' dwelling';
                      if (info and $80) <> 0 then
                        s := s + ', guarded by '
                             + MonsterAmtString(DwellingGuardsQty(info and $7F),
                                                eye)
                             + ' ' + MonsterData[info and $7F].pname
                      else if MapNum^[x, y] = 0 then
                        s := s + chr(colLightGray) + ' (no-one home)'
                      else
                        s := s + chr(colLightGray) + ' ('
                             + MonsterAmtString(MapNum^[x, y], eye)
                             + ' ' + MonsterData[info and $7F].pname + ')';
                    end;
      mHordeDwelling: begin
                        s := 'Horde dwelling';
                        if (info and $80) <> 0 then
                          s := s + ', guarded by '
                               + MonsterAmtString(80, eye)
                               + ' 1st level creatures'
                        else if MapNum^[x, y] = 0 then
                          s := s + chr(colLightGray) + ' (no-one home)'
                        else
                          s := s + chr(colLightGray) + ' ('
                               + MonsterAmtString(MapNum^[x, y], eye)
                               + ' 1st level creatures)';
                      end;
      mFarmstead:   s := 'Farmstead ' + PaidStr;
      mMiningVillage: s := 'Miner ' + PaidStr;
      mMonument:    begin
                      s := 'Monument';
                      VisitString(hvMonument);
                    end;
      mRezGold
      ..mRezClay:   s := 'Pile of '
                         + PResourceNames[TResource(TheMap^[x, y] - mRezGold)];
      mArtifact:    s := 'Artifact';
      mBag:         s := 'Bag of treasure';
      mChest:       s := 'Treasure chest';
      mBarrel:      s := 'Barrel';
      mPotion:      s := 'Potion';
      mSageHut:     begin
                      s := 'Sage Hut';
                      VisitString(hvSageHut);
                    end;
      mJunkMerchant: s := 'Junk Merchant';
      mLibrary:     s := 'Library';
      mWatchtower:  s := 'Watchtower';
      mGoldMine
      ..mSkillMine: begin
                      s := MineName(x, y) + ' ';
                      OwnerString;
                      s := s + ' (';
                      if TheMap^[x, y] = mSkillMine then
                        s := s + 'allied heroes gain +1 '
                             + SkillNames[MapInfo^[x, y]]
                      else begin
                        r := TResource(TheMap^[x, y] - mGoldMine);
                        s := s + 'produces ' + IStr(ResourceInc[r], 0)
                             + '_' + RezChr(r) + ' per day';
                      end;
                      s := s + ')';
                    end;
      mShamanHut,
      mMagicianHome,
      mWizardHouse: begin
                      case TheMap^[x, y] of
                        mShamanHut:        i := smShaman;
                        mMagicianHome:     i := smMagician;
                        mWizardHouse:      i := smWizard;
                      end;
                      s := SpellMineNames[i] + ' ';
                      OwnerString;
                      s := s + ' (' + SpellMineHint[i] + ')';
                    end;
      mHouseofHusbandry: begin
                           s := 'House of Husbandry'
                                + ', level ' + IStr(MapInfo^[x, y], 0) + ' ';
                           OwnerString;
                           s := s + ' (allied castles produce +5 ' + crGold
                                + ' of ' + Nth[MapInfo^[x, y]]
                                + ' level troops per square per day)';
                         end;
      mHero,
      mJungleFort
      ..mLastCastle: begin
                       s := 'SPECIAL';
                       h := HeroAtSpot(x, y);
                       if h <> 0 then
                         ArmyMessage(h, HeroSlots(h), @Hero^[h].army,
                                     Hero^[h].Name, eye)
                       else
                         ArmyMessage(-Castle[MapInfo^[x, y]].player, 6,
                                     @Castle[MapInfo^[x, y]].Garrison,
                                     'Castle', eye);
                     end;
      mHermitHut:   s := 'Hermit Cave';
      mUpgradeFort: s := 'Academy, level ' + IStr(MapInfo^[x, y], 0);
    end;

    if (s <> 'SPECIAL') and (s <> '') then s := s + '.';

    MapHintText := s;
  end;

{ unit initialization }

begin
  New(TheMap);
  New(MapInfo);
  New(MapNum);
  New(Dist);
  New(Roads);
  New(Climate);
  New(Geos);
  LoadGeos;
  New(MapGraphics);
  LoadMapGraphics;
end.
