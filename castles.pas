unit castles;

interface

uses Objects, Monsters, Rez, Spells, Players, LowGr;

const
  bEmpty = 0;
  bCreature1 = 1;
  bCreature2 = 2;
  bCreature3 = 3;
  bCreature4 = 4;
  bCreature5 = 5;
  bCreature6 = 6;
  bSpells1 = 7;
  bSpells2 = 8;
  bLittleMoney = 9;
  bBigMoney = 10;
  bSilo = 11;
  bBarbican = 12;
  bTreasure = 13;
  bObstacle = 14;
  bCrownOfBreeding = 15;
  bMercenarysCrown = 16;
  bCrownOfOffense = 17;
  bCrownOfDefense = 18;
  bCrownOfTactics = 19;

  bMask = $3F;
  bPlanned = $40;

  bDecays = [bCreature1..bBarbican];

  ciBuyCreatures = 1;
  ciBuild = 2;
  ciSpells1 = 3;
  ciBuyHero = 4;
  ciMarket = 5;
  ciPrevCastle = 6;
  ciNextCastle = 7;
  ciExit = 8;
  ciRotate = 9;
  ciFlip = 10;
  ciSpells2 = 11;
  ciMint = 12;
  ciBarbican = 13;
  ciTreasure = 14;
  ciUnused = 15;
  ciBuy1 = 16;
  ciBuyAll = 17;
  ciTakeAll = 18;
  ciBuy5 = 19;
  ciBuy10 = 20;
  ciPlan = 21;

  CastleIcons: array [1..21] of TGraphic =
  (
    ('..........', { buy creatures }
     '..........',
     '.***..***.',
     '.***..***.',
     '..*....*..',
     '.***..***.',
     '..*....*..',
     '.*.*..*.*.',
     '..........',
     '..........'),
    ('......*...', { build }
     '.....***..',
     '....*****.',
     '.....*****',
     '....*****.',
     '...***.*..',
     '..***.....',
     '.***......',
     '***.......',
     '.*........'),
    ('......*...', { see spells / spells 1 }
     '.....**...',
     '....**....',
     '...***....',
     '..******..',
     '..******..',
     '....***...',
     '....**....',
     '...**.....',
     '...*......'),
    ('..........', { buy hero }
     '...***....',
     '...***....',
     '....*.....',
     '....**.***',
     '.*..*..***',
     '..******..',
     '..******..',
     '.*.*...*..',
     '.*..*...*.'),
    ('....**....', { marketplace }
     '..*******.',
     '.********.',
     '.**.......',
     '.*******..',
     '..*******.',
     '.......**.',
     '.********.',
     '.*******..',
     '....**....'),
    ('**..**..**', { prev castle }
     '**..**..**',
     '**********',
     '**********',
     '**********',
     '**********',
     '..........',
     '..*.......',
     '.********.',
     '..*.......'),
    ('**..**..**', { next castle }
     '**..**..**',
     '**********',
     '**********',
     '**********',
     '**********',
     '..........',
     '.......*..',
     '.********.',
     '.......*..'),
    ('...****...', { exit }
     '..*    *..',
     '.*    ***.',
     '*    *** *',
     '*   ***  *',
     '*  ***   *',
     '* ***    *',
     '.***    *.',
     '..*    *..',
     '...****...'),
    ('..........', { rotate }
     '.......*..',
     '.......**.',
     '....******',
     '..**...**.',
     '.*.....*..',
     '*.........',
     '*.........',
     '.*........',
     '..**......'),
    ('..........', { flip }
     '..........',
     '..*....*..',
     '.**....**.',
     '**********',
     '.**....**.',
     '..*....*..',
     '..........',
     '..........',
     '..........'),
    ('....****..', { spells 2 }
     '..**...**.',
     '.*......**',
     '........**',
     '........**',
     '.**.....**',
     '****...**.',
     '****..***.',
     '.*******..',
     '...****...'),
    ('....*.*...', { mint }
     '.....*....',
     '...*****..',
     '..*******.',
     '..***..**.',
     '.***..****',
     '.****..***',
     '.***..****',
     '.*********',
     '..*******.'),
    ('..........', { barbican }
     '..*.*.*...',
     '..*****...',
     '..*****...',
     '..*****...',
     '..*****...',
     '..*****...',
     '..*****...',
     '..*****...',
     '..........'),
    ('..........', { treasury }
     '..........',
     '*...*...*.',
     '**.***.**.',
     '*********.',
     '*********.',
     '*********.',
     '*********.',
     '*********.',
     '..........'),
    ('....*.....', { unused }
     '.*..*..*..',
     '..*****...',
     '..*****...',
     '*********.',
     '..*****...',
     '..*****...',
     '.*..*..*..',
     '....*.....',
     '..........'),
    ('..........', { buy/trade 1 }
     '.....*....',
     '....**....',
     '...***....',
     '...***....',
     '....**....',
     '....**....',
     '....**....',
     '..******..',
     '..******..'),
    ('..........', { buy/trade all }
     '..........',
     '....**....',
     '....**....',
     '..******..',
     '..******..',
     '....**....',
     '....**....',
     '..........',
     '..........'),
    ('....***...', { take all garrison troops }
     '....***...',
     '....***...',
     '....***...',
     '....***...',
     '....***...',
     '..*******.',
     '...*****..',
     '....***...',
     '.....*....'),
    ('..........', { buy/trade 5 }
     '..******..',
     '..******..',
     '..**......',
     '..*****...',
     '...*****..',
     '......**..',
     '..**..**..',
     '..******..',
     '...****...'),
    ('..........', { buy/trade 10 }
     '..*..****.',
     '.**.******',
     '***.**..**',
     '***.**..**',
     '.**.**..**',
     '.**.**..**',
     '.**.**..**',
     '.**.******',
     '.**..****.'),
    ('..........', { plan }
     '..*****...',
     '.*.....*..',
     '*.......*.',
     '*.**.**.*.',
     '*.......*.',
     '.*..*..*..',
     '..*.*.*...',
     '..*...*...',
     '...***....')
  );

type
  TCastleType = (ctJungleFort, ctCityOfShadows, ctCloudCastle, ctThievesGuild,
                 ctFactory, ctLaboratory, ctPyramid, ctRuins,
                 ctCircus, ctEvilTemple);

const
  CastleNames: array [TCastleType] of string[15] =
  (
    'Jungle Fort', 'City of Shadows', 'Cloud Castle', 'Thieves'' Guild',
    'Factory', 'Laboratory', 'Pyramid', 'Ruins', 'Circus', 'Evil Temple'
  );
  CastlePNames: array [TCastleType] of string[17] =
  (
    'Jungle Forts', 'Cities of Shadows', 'Cloud Castles', 'Thieves'' Guilds',
    'Factories', 'Laboratories', 'Pyramids', 'Ruins',
    'Circuses', 'Evil Temples'
  );

type
  PFootprint = ^TFootprint;
  TFootprint = array [1..4] of string[4];

  TCastleAction = (caNone, caBuy, caBuild, caSpells, caTavern, caMarket);

  TGrid = array [1..8, 1..8] of byte;

  PCastle = ^TCastle;
  TCastle = record
    CT: TCastleType;
    Outpost: boolean;
    MapX, MapY: integer;
    Grid, Center, Decay: TGrid;
    Garrison: TArmySet;
    AvailableTroops: array [1..6] of integer;
    FractionalTroops: array [1..6] of integer;
    AvailableSpells: TSpellSet;
    Player: byte;
    Income: TResourceSet;
    FreeSquares: integer;
    Summoning: array [1..6] of integer;
  end;

  PCastleScr = ^TCastleScr;
  TCastleScr = object(TObject)
    PC: PCastle;
    Action: TCastleAction;
    BuildChoice: integer;
    BuildFP: TFootprint;
    BuildX, BuildY: integer;
    MarketLeft, MarketRight: TResource;
    ghosts: array [1..8, 1..8] of boolean;
    GarrisonBar, HeroBar: PArmyBar;
    VisitingHero, HeroX, HeroY: integer;
    DeadGuys: array [1..2] of integer;
    cnum: integer;
    constructor Init;
    destructor Done; virtual;
    procedure SetCastle(P: PCastle);
    function FootprintOverSquare(x, y: integer): boolean;
    procedure DrawCastleSquare(x, y: integer);
    procedure DrawCastle;
    procedure DrawIcons;
    procedure DrawFootprint(x, y, siz, fc, rc: integer; fp: TFootprint);
    procedure DrawAreaBuild;
    function BuildingName(b: integer): string;
    function BuildingHint(b: integer): string;
    procedure DrawBuildChoice;
    procedure DrawAreaBuy;
    procedure DrawAreaSpells;
    function FindTavernHero(i: integer): integer;
    procedure DrawAreaTavern;
    procedure FindMarketRate(var left, right: integer);
    procedure DrawAreaMarket;
    procedure DrawActionArea;
    procedure DrawResources;
    procedure DrawGarrison;
    procedure Draw;
    procedure Build;
    procedure FindDeadGuys;
    procedure SetHero(h: integer);
    procedure Handle(C: PCastle; icnum: integer);
  end;

var
  NumCastles: integer;
  Castle: array [1..MaxTowns] of TCastle;
  Taverns: array [TCastleType, 1..2] of integer;
  MonsterRanks: array [TCastleType, 1..6] of integer;

procedure NewCastle(p: PCastle; iMapX, iMapY: integer; iCT: TCastleType;
                    iOutpost: boolean; iPlayer: byte);
function MonsterForLevel(ct: TCastleType; lev: integer): integer;
procedure CastleProduction(c: integer);
function CastleProdValue(c: integer): longint;
function CastleTroopsGP(c: integer; limit: boolean): longint;
function FindUnusedHero(ct: TCastleType; newguy: integer): integer;
function CanBuildSomewhere(c: integer; fp: TFootprint): boolean;
function CanBuildKind(c: integer): integer;
procedure FindBuildCost(c, b: integer; var rs: TResourceSet);
function BuildingFootprint(c, b: integer): PFootprint;
function TryToBuild(c, bc: integer; trading, free: boolean): boolean;
procedure AIVisitCastle(c, h: integer);
function BuyCastleTroops(c, troops, amt: integer; trade: boolean): integer;
procedure SetTaverns;
procedure BuyHeroAtCastle(c, h: integer);
procedure GarrisonToHero(pc: PCastle; h: integer);
function PlaceCrown(c, a: integer): boolean;
function RemoveObstacle(c: integer): boolean;
procedure RemoveAllPlans(c: integer);
procedure HandleDecay(c: integer);
procedure GiveCastleSummoning(c, m: integer);

implementation

uses Drivers, XMouse, XStrings, Heroes, Artifact, XFace, Options;

const
  BaseFeet: array [bSpells1..bTreasure] of TFootprint =
  (
    ('@...', { spells 1 }
     '....',
     '....',
     '....'),
    ('@*..', { spells 2 }
     '....',
     '....',
     '....'),
    ('@...', { little money }
     '....',
     '....',
     '....'),
    ('@*..', { big money }
     '**..',
     '....',
     '....'),
    ('@*..', { silo }
     '....',
     '....',
     '....'),
    ('@...', { barbican }
     '....',
     '....',
     '....'),
    ('@...', { treasury }
     '....',
     '....',
     '....')
  );

  CrFeet: array [TCastleType, 1..6] of TFootprint =
  (
    (('@*..',  { 1 bunny }
      '....',
      '....',
      '....'),
     ('*@*.',  { 2 giant frog }
      '....',
      '....',
      '....'),
     ('*@*.',  { 3 mad turtle }
      '*.*.',
      '....',
      '....'),
     ('****',  { 4 fungus }
      '*@.*',
      '....',
      '....'),
     ('****',  { 5 carnivorous plant }
      '.@..',
      '****',
      '....'),
     ('***.',  { 6 kong }
      '*@*.',
      '.***',
      '.***')),
    (('@*..',  { 1 shadow }
      '....',
      '....',
      '....'),
     ('@*..',  { 2 soul thief }
      '*...',
      '....',
      '....'),
     ('@**.',  { 3 horror }
      '*...',
      '*...',
      '....'),
     ('*@*.',  { 4 necromancer }
      '*.**',
      '*...',
      '....'),
     ('.***',  { 5 evil fog }
      '*@*.',
      '.***',
      '....'),
     ('****',  { 6 death puppet }
      '*@**',
      '**..',
      '**..')),
    (('@*..',  { 1 shrinking man }
      '....',
      '....',
      '....'),
     ('@*..',  { 2 witch }
      '*...',
      '....',
      '....'),
     ('@***',  { 3 will-o-wisp }
      '*...',
      '....',
      '....'),
     ('****',  { 4 dancing sword }
      '.@*.',
      '.*..',
      '....'),
     ('*.**',  { 5 illusionist }
      '**@.',
      '*.**',
      '....'),
     ('.**.',  { 6 cloud giant }
      '*@**',
      '****',
      '.**.')),
    (('@*..',  { 1 urchin }
      '....',
      '....',
      '....'),
     ('*@*.',  { 2 lookout }
      '....',
      '....',
      '....'),
     ('**..',  { 3 sneak }
      '.@**',
      '....',
      '....'),
     ('@***',  { 4 ninja }
      '*...',
      '*...',
      '*...'),
     ('**..',  { 5 assassin }
      '**.*',
      '*@**',
      '....'),
     ('****',  { 6 mastermind }
      '*.@*',
      '*...',
      '****')),
    (('@*..',  { 1 robot }
      '....',
      '....',
      '....'),
     ('@*..',  { 2 wobbler }
      '*...',
      '....',
      '....'),
     ('*@*.',  { 3 whirly }
      '.*..',
      '.*..',
      '....'),
     ('.*..',  { 4 transformer }
      '*@**',
      '.*.*',
      '....'),
     ('***.',  { 5 steamroller }
      '*@*.',
      '***.',
      '....'),
     ('****',  { 6 laser }
      '**@*',
      '*.*.',
      '*.*.')),
    (('@*..',  { 1 lab assistant }
      '....',
      '....',
      '....'),
     ('*@*.',  { 2 pygmy dragon }
      '....',
      '....',
      '....'),
     ('.**.',  { 3 mimic }
      '*@..',
      '*...',
      '....'),
     ('***.',  { 4 blob }
      '*@*.',
      '.*..',
      '....'),
     ('***.',  { 5 headless }
      '.*@*',
      '..**',
      '...*'),
     ('**.*',  { 6 mad scientist }
      '.***',
      '**@*',
      '*.*.')),
    (('@*..',  { 1 scorpion }
      '....',
      '....',
      '....'),
     ('*@*.',  { 2 mummy }
      '....',
      '....',
      '....'),
     ('*@*.',  { 3 vulture }
      '**..',
      '....',
      '....'),
     ('@**.',  { 4 djinn }
      '*.*.',
      '*...',
      '*...'),
     ('..**',  { 5 guardian }
      '**@*',
      '***.',
      '....'),
     ('****',  { 6 slaver }
      '*@**',
      '****',
      '....')),
    (('@*..',  { 1 giant rat }
      '....',
      '....',
      '....'),
     ('@*..',  { 2 mosquito cloud }
      '*...',
      '....',
      '....'),
     ('.*..',  { 3 electric eel }
      '*@*.',
      '.*..',
      '....'),
     ('**..',  { 4 flying slug }
      '*@**',
      '.*..',
      '....'),
     ('*..*',  { 5 two-headed giant }
      '*@**',
      '***.',
      '....'),
     ('****',  { 6 fire duiker }
      '..**',
      '.*@*',
      '***.')),
    (('@*..',  { 1 magician }
      '....',
      '....',
      '....'),
     ('@*..',  { 2 ringmaster }
      '*...',
      '....',
      '....'),
     ('*...',  { 3 clown car }
      '*@*.',
      '..*.',
      '....'),
     ('...*',  { 4 lion }
      '**@*',
      '*..*',
      '....'),
     ('.***',  { 5 elephant }
      '**@*',
      '*.*.',
      '....'),
     ('.***',  { 6 fire-eater }
      '*@.*',
      '*..*',
      '****')),
    (('@*..',  { 1 angry villager }
      '....',
      '....',
      '....'),
     ('*@*.',  { 2 skulk }
      '....',
      '....',
      '....'),
     ('*@**',  { 3 priest }
      '.*..',
      '....',
      '....'),
     ('.**.',  { 4 vile duck }
      '*@*.',
      '**..',
      '....'),
     ('*.*.',  { 5 werewolf }
      '**@*',
      '*.**',
      '....'),
     ('****',  { 6 serpent angel }
      '*@**',
      '*..*',
      '*..*'))
  );

  FeetSize: array [1..13] of byte =
  (
    2, 3, 5, 7, 9, 12, 1, 3, 1, 4, 2, 1, 1
  );

  BackColor: array [0..19] of byte =
  (
    colBlack, colDarkBlue, colDarkBlue, colDarkBlue,
    colDarkBlue, colDarkBlue, colDarkBlue, colDarkGreen,
    colDarkGreen, colBrown, colBrown, colBrown,
    colDarkGray, colDarkRed, colDarkGray,
    colDarkGray, colDarkGray, colDarkGray, colDarkGray,
    colDarkGray
  );

  ForeColor: array [0..19] of byte =
  (
    colLightGray, colLightBlue, colBlue, colWhite,
    colLightGreen, colLightRed, colLightRed, colLightGreen,
    colLightRed, colYellow, colYellow, colLightGray,
    colWhite, colBlack, colLightGray,
    colLightBlue, colYellow, colLightRed, colLightGreen,
    colWhite
  );

  Obstacles: array [TCastleType] of TGraphic =
  (
    ('..******..', { jungle fort }
     '.*.*.*.**.',
     '*.*.*.**.*',
     '*.*.**.*.*',
     '.*.*.**.*.',
     '..******..',
     '....**....',
     '....**....',
     '....**....',
     '...****...'),
    ('...***....', { city of shadows }
     '..*   *...',
     '.*     *..',
     '.*     *..',
     '.* *** *..',
     '.*     *..',
     '.* *** *..',
     '.*     *..',
     '.*     *..',
     '.*******..'),
    ('....*.....', { cloud castle }
     '....**....',
     '...***....',
     '...****...',
     '..******..',
     '..****.*..',
     '.**.*.*.*.',
     '.*.*.*.**.',
     '*.*.*.*.**',
     '**.*.*.*.*'),
    ('.........*', { thieves' guild }
     '........*.',
     '.......*.*',
     '......*...',
     '.....*.*..',
     '....*...*.',
     '.***......',
     '*..*......',
     '*..*......',
     '.**.......'),
    ('.********.', { factory }
     '.*......*.',
     '.*.****.*.',
     '.*.*..*.*.',
     '.*.*..*.*.',
     '.*.****.*.',
     '.*......*.',
     '.*..***.*.',
     '.*......*.',
     '.********.'),
    ('.......**.', { laboratory }
     '......**..',
     '......****',
     '.....****.',
     '....***...',
     '...***....',
     '.****.....',
     '****......',
     '..**......',
     '.**.......'),
    ('..........', { pyramids }
     '..*.**....',
     '.**.*.*...',
     '.**.*..*..',
     '.**.*...*.',
     '..*.*....*',
     '..*.******',
     '..*..*.*..',
     '..*..*.*..',
     '..........'),
    ('..........', { ruins }
     '..........',
     '.....*....',
     '.*...*...*',
     '..*..*..*.',
     '...*.*.*..',
     '...*.*.*..',
     '..*******.',
     '.*.......*',
     '..........'),
    ('..........', { circus }
     '.**...**..',
     '.**...**..',
     '....*.....',
     '*...*...*.',
     '**.....**.',
     '*.*****.*.',
     '*.*.*.*.*.',
     '.**.*.**..',
     '..*****...'),
    ('....**....', { evil temple }
     '....**....',
     '.********.',
     '.********.',
     '....**....',
     '....**....',
     '....**....',
     '....**....',
     '....**....',
     '....**....')
  );

  SiloResource: array [TCastleType] of TResource =
  (
    rApples, rClay, rRocks, rEmeralds, rQuartz, rBeakers, rQuartz, rClay,
    rBeakers, rEmeralds
  );

  cwid = 40 * 8 - 1 + 8; { the bar down the middle }


function InCastle(x, y: integer): boolean;
  begin
    InCastle := (x >= 1) and (x <= 8) and (y >= 1) and (y <= 8);
  end;

procedure UpLeftFootprint(var f: TFootprint);
  var
    x, y: integer;
    did: boolean;
  begin
    repeat
      did := false;
      if (f[1, 1] = '.') and (f[2, 1] = '.')
         and (f[3, 1] = '.') and (f[4, 1] = '.') then begin
        for y := 1 to 4 do
          f[y] := copy(f[y], 2, 3) + '.';
        did := true;
      end;
      if f[1] = '....' then begin
        for y := 1 to 3 do
          f[y] := f[y + 1];
        f[4] := '....';
        did := true;
      end;
    until not did;
  end;

procedure FlipFootprint(var f: TFootprint);
  var
    x, y: integer;
    f2: TFootprint;
  begin
    f2 := f;
    for x := 1 to 4 do
      for y := 1 to 4 do
        f2[y, x] := f[y, 5 - x];
    UpLeftFootprint(f2);
    f := f2;
  end;

procedure RotateFootprint(var f: TFootprint);
  var
    x, y: integer;
    f2: TFootprint;
  begin
    f2 := f;
    for x := 1 to 4 do
      for y := 1 to 4 do
        f2[y, x] := f[5 - x, y];
    UpLeftFootprint(f2);
    f := f2;
  end;

procedure NewCastle(p: PCastle; iMapX, iMapY: integer; iCT: TCastleType;
                    iOutpost: boolean; iPlayer: byte);
  var i, nob, x, y: integer;
  begin
    with p^ do begin
      CT := iCT;
      Outpost := iOutpost;
      MapX := iMapX;
      MapY := iMapY;
      Player := iPlayer;
      for i := 1 to 6 do Garrison[i] := NilArmy;
      FillChar(Grid, sizeof(Grid), chr(bEmpty));
      FillChar(Center, sizeof(Center), #255);
      FillChar(AvailableTroops, sizeof(AvailableTroops), #0);
      FillChar(FractionalTroops, sizeof(FractionalTroops), #0);
      FillChar(Decay, sizeof(Decay), #0);

      if Outpost then nob := 20 else nob := 4;

      for i := 1 to nob do begin
        x := random(8) + 1;
        y := random(8) + 1;
        Grid[x, y] := bObstacle;
        Center[x, y] := (x - 1) + (y - 1) * 8;
      end;

      FreeSquares := 0;
      for x := 1 to 8 do
        for y := 1 to 8 do
          if Grid[x, y] = bEmpty then
            inc(FreeSquares);

      AvailableSpells := NoSpells;

      FillChar(Income, sizeof(Income), #0);
      Income[rGold] := 500;

      FillChar(Summoning, sizeof(Summoning), #0);
    end;
  end;

function CastleGPProdPerSquare(c: integer): integer;
  var i, j, h, prod, pt: integer;
  begin
    pt := PlayerTowns(Castle[c].Player);
    prod := 300;

    for i := 1 to MaxDudes do begin
      h := Player[Castle[c].Player].Dudes[i];
      if h <> 0 then
        inc(prod, (50 * CountArt(h, anWrenchOfHusbandry, true)) div pt);
    end;

    for i := 1 to 8 do
      for j := 1 to 8 do
        if Castle[c].Grid[i, j] = bCrownOfBreeding then
          inc(prod, 100);

    prod := (prod + 6) div 7;
    if Twists[twDoubleCostProd] then prod := prod * 2;

    CastleGPProdPerSquare := prod;
  end;

function CastleSquaresOfType(c, b: integer): integer;
  var x, y, csot: integer;
  begin
    csot := 0;

    for x := 1 to 8 do
      for y := 1 to 8 do
        if Castle[c].Grid[x, y] = b then
          inc(csot);

    CastleSquaresOfType := csot;
  end;

function MonsterForLevel(ct: TCastleType; lev: integer): integer;
  var mfl: integer;
  begin
    if Twists[twCastleCreaturesMixed] and (lev > 1) then
      mfl := ((ord(ct) + MixedCreaturesOfs[lev]) mod NumCastleTypes) * 6 + lev
    else
      mfl := ord(ct) * 6 + lev;

    MonsterForLevel := mfl;
  end;

function HusbandryByLevel(c, lev: integer): integer;
  var prod: integer;
  begin
    prod := Player[Castle[c].Player].HusbandryMines[lev] * 5;
    if Twists[twDoubleCostProd] then prod := prod * 2;
    HusbandryByLevel := prod;
  end;

procedure CastleProduction(c: integer);
  var
    x, y, g, cr, m, i, h, pps, prod: integer;
    pr: PResourceSet;
    r: TResource;
  begin
    pr := @Player[Castle[c].Player].Resources;
    for r := low(TResource) to high(TResource) do begin
      inc(pr^[r], Castle[c].Income[r]);
      inc(RezProd[r], Castle[c].Income[r]);
    end;

    pps := CastleGPProdPerSquare(c);

    for x := 1 to 8 do
      for y := 1 to 8 do begin
        g := Castle[c].Grid[x, y];
        if (g >= bCreature1) and (g <= bCreature6) then begin
          prod := pps + HusbandryByLevel(c, g);
          cr := g - bCreature1 + 1;
          m := MonsterForLevel(Castle[c].CT, cr);
          if Twists[twOneSquareDwelling] and (g = OneSquareDwelling) then
            inc(Castle[c].FractionalTroops[cr], prod * FeetSize[g])
          else
            inc(Castle[c].FractionalTroops[cr], prod);
          if Castle[c].FractionalTroops[cr] >= MonsterData[m].cost then begin
            i := Castle[c].FractionalTroops[cr] div MonsterData[m].cost;
            inc(Castle[c].AvailableTroops[cr], i);
            dec(Castle[c].FractionalTroops[cr], i * MonsterData[m].cost);
          end;
        end;
      end;
  end;

function CastleProdValue(c: integer): longint;
  var
    x, y, g: integer;
    prod, cpv, pps: longint;
  begin
    pps := CastleGPProdPerSquare(c);
    cpv := 0;

    for x := 1 to 8 do
      for y := 1 to 8 do begin
        g := Castle[c].Grid[x, y];
        if (g >= bCreature1) and (g <= bCreature6) then begin
          prod := pps + HusbandryByLevel(c, g);
          if Twists[twOneSquareDwelling] and (g = OneSquareDwelling) then
            inc(cpv, prod * FeetSize[g])
          else
            inc(cpv, prod);
        end;
      end;

    CastleProdValue := cpv;
  end;

function MonsterCost(c, lev: integer): longint;
  var m, cost, i, j: integer;
  begin
    m := MonsterForLevel(Castle[c].CT, lev);
    cost := MonsterData[m].cost;

    for i := 1 to 8 do
      for j := 1 to 8 do
        if Castle[c].Grid[i, j] = bMercenarysCrown then
          cost := cost div 2;

    if cost < 1 then cost := 1;

    MonsterCost := cost;
  end;

function CastleTroopsGP(c: integer; limit: boolean): longint;
  var
    gp: longint;
    i: integer;
  begin
    gp := 0;

    with Castle[c] do
      for i := 1 to 6 do
        if AvailableTroops[i] > 0 then
          inc(gp, AvailableTroops[i] * MonsterCost(c, i));

    if limit and (gp > Player[Castle[c].player].Resources[rGold]) then

    CastleTroopsGP := gp;
  end;

function BuyCastleTroops(c, troops, amt: integer; trade: boolean): integer;
  var
    canb, m, slot, h, bought, left, right: integer;
    gp, mc, wantgp, tradeamt: longint;
    r: TResource;
  begin
    with Player[Turn], Castle[c] do begin
      m := MonsterForLevel(CT, troops);
      mc := MonsterCost(c, troops);

      if trade then begin
        wantgp := AvailableTroops[troops] * mc - Resources[rGold];
        if wantgp > 0 then begin
          CalcSpareRez(Turn, ExcessRez);
          for r := rRocks to high(TResource) do
            if (ExcessRez[r] > 0) and (wantgp > 0) then begin
              FindExchangeRate(r, rGold, left, right);
              gp := ExcessRez[r] * right;
              if gp > wantgp + right - 1 then gp := wantgp + right - 1;
              tradeamt := gp div right;
              dec(ExcessRez[r], tradeamt);
              dec(Resources[r], tradeamt);
              inc(Resources[rGold], tradeamt * right);
              dec(wantgp, tradeamt * right);
            end;
        end;
      end;

      canb := Resources[rGold] div mc;
      bought := 0;

      if (AvailableTroops[troops] > 0) and (canb > 0) then begin
        if amt > canb then
          amt := canb;
        if amt > AvailableTroops[troops] then
          amt := AvailableTroops[troops];
        gp := mc * longint(amt);
        h := HeroAtSpot(Castle[c].MapX, Castle[c].MapY);
        if ((h <> 0) and (GainMonster(@Hero^[h].army, HeroSlots(h), m, amt)))
           or GainMonster(@Garrison, 6, m, amt) then begin
          dec(Resources[rGold], gp);
          dec(AvailableTroops[troops], amt);
          bought := amt;
        end;
      end;
    end;

    BuyCastleTroops := bought;
  end;

function FindUnusedHero(ct: TCastleType; newguy: integer): integer;
  var avail, n, ffh: integer;

  function HeroUnused(h: integer): boolean;
    var
      ict: TCastleType;
      hu: boolean;
    begin
      hu := true;
      for ict := low(TCastleType) to high(TCastleType) do
        if (Taverns[ict, 1] = h) or (Taverns[ict, 2] = h) then
          hu := false;

      HeroUnused := hu and (Hero^[h].player = 0) and not Hero^[h].Dead
                    and (h <> newguy);
    end;

  procedure GetHeroInRange(r1, r2: integer);
    var i: integer;
    begin
      for i := r1 to r2 do
        if HeroUnused(i) then
          inc(avail);

      if avail > 0 then begin
        repeat
         ffh := random(r2 - r1 + 1) + r1;
        until HeroUnused(ffh);
      end;
    end;

  begin
    ffh := 0;
    n := ord(ct) * 14;
    avail := 0;

    GetHeroInRange(n + 1, n + 14);
    if avail = 0 then GetHeroInRange(1, NumHeroes);

    FindUnusedHero := ffh;
  end;

procedure SetTaverns;
  var ct: TCastleType;
  begin
    for ct := low(TCastleType) to high(TCastleType) do begin
      Taverns[ct, 1] := 0;
      Taverns[ct, 2] := 0;
      Taverns[ct, 1] := FindUnusedHero(ct, 0);
      Taverns[ct, 2] := FindUnusedHero(ct, 0);
    end;
  end;

procedure BuyHeroAtCastle(c, h: integer);
  var n: integer;
  begin
    dec(Player[Turn].Resources[rGold], 2500);
    GainHero(Turn, h, Castle[c].MapX, Castle[c].MapY);
    if Hero^[h].Dead then
      Hero^[h].Dead := false
    else begin
      if Taverns[Castle[c].CT, 2] = h then
        n := 2
      else
        n := 1;
      Taverns[Castle[c].CT, n] := 0;
      Taverns[Castle[c].CT, n] := FindUnusedHero(Castle[c].CT, h);
    end;
    PickSpecialty(h);
    PickExpertise(h);
  end;

procedure GarrisonToHero(pc: PCastle; h: integer);
  var lev, n: integer;
  begin
    for lev := 6 downto 1 do
      for n := 1 to 6 do begin
        if (pc^.Garrison[n].qty > 0)
           and (MonsterLevel(pc^.Garrison[n].monster) = lev)
           and GainMonster(@Hero^[h].army, HeroSlots(h),
                           pc^.Garrison[n].monster,
                           pc^.Garrison[n].qty) then
          pc^.Garrison[n] := NilArmy;
      end;
  end;

function PlaceCrown(c, a: integer): boolean;
  var
    i, j: integer;
    did: boolean;
  begin
    did := false;

    for i := 1 to 8 do
      for j := 1 to 8 do
        if not did and (Castle[c].Grid[i, j] = bTreasure) then begin
          Castle[c].Grid[i, j] := bCrownOfBreeding + a - anCrownOfBreeding;
          did := true;
        end;

    PlaceCrown := did;
  end;

function RemoveObstacle(c: integer): boolean;
  var
    i, j: integer;
    did: boolean;
  begin
    did := false;

    for i := 1 to 8 do
      for j := 1 to 8 do
        if not did and (Castle[c].Grid[i, j] = bObstacle) then begin
          Castle[c].Grid[i, j] := bEmpty;
          inc(Castle[c].FreeSquares);
          did := true;
        end;

    RemoveObstacle := did;
  end;

procedure FindFootprintSize(f: TFootprint; var xwid, ywid: integer);
  var x, y: integer;
  begin
    xwid := 1;
    ywid := 1;
    for x := 1 to 4 do
      for y := 1 to 4 do
        if (f[y, x] <> '.') then begin
          if x > xwid then xwid := x;
          if y > ywid then ywid := y;
        end;
  end;

function GridEmpty(c, x, y: integer): boolean;
  var g: integer;
  begin
    g := Castle[c].Grid[x, y];
    GridEmpty := (g = bEmpty) or ((g and bPlanned) <> 0);
  end;

function CanBuildThere(c, x, y: integer; fp: TFootprint): boolean;
  var
    cbt: boolean;
    i, j: integer;
  begin
    cbt := true;

    for i := 1 to 4 do
      for j := 1 to 4 do
        if (fp[j, i] <> '.')
           and (not InCastle(x + i - 1, y + j - 1)
                or not GridEmpty(c, x + i - 1, y + j - 1)) then
          cbt := false;

    CanBuildThere := cbt;
  end;

function PlanOverlap(c, x, y: integer; fp: TFootprint): boolean;
  var
    po: boolean;
    i, j: integer;
  begin
    po := false;

    for i := 1 to 4 do
      for j := 1 to 4 do
        if (fp[j, i] <> '.') and InCastle(x + i - 1, y + j - 1)
           and ((Castle[c].Grid[x + i - 1, y + j - 1] and bPlanned) <> 0) then
          po := true;

    PlanOverlap := po;
  end;

function MatchesPlan(c, bc, x, y: integer; fp: TFootprint): boolean;
  var
    mp: boolean;
    i, j, cent, cij: integer;
  begin
    mp := true;
    cent := 255;
    bc := bc or bPlanned;

    for i := 1 to 4 do
      for j := 1 to 4 do
        if fp[j, i] <> '.' then begin
          if not InCastle(x + i - 1, y + j - 1)
             or (Castle[c].Grid[x + i - 1, y + j - 1] <> bc) then
            mp := false
          else begin
            cij := Castle[c].Center[x + i - 1, y + j - 1];
            if cent = 255 then begin
              if cij = 255 then
                mp := false
              else
                cent := cij;
            end else begin
              if cent <> cij then
                mp := false;
            end;
          end;
        end;

    MatchesPlan := mp;
  end;

function GridScore(g: TGrid; planempty: boolean): integer;
  var score, i, j: integer;

  function EmptySpot(x, y: integer): boolean;
    begin
      if planempty then
        EmptySpot := (g[x, y] = bEmpty) or ((g[x, y] and bPlanned) <> 0)
      else
        EmptySpot := g[x, y] = bEmpty;
    end;

  begin
    score := 0;

    for i := 1 to 8 do
      for j := 1 to 8 do
        if EmptySpot(i, j) then begin
          if (i = 1) or not EmptySpot(i - 1, j) then inc(score);
          if (i = 8) or not EmptySpot(i + 1, j) then inc(score);
          if (j = 1) or not EmptySpot(i, j - 1) then inc(score);
          if (j = 8) or not EmptySpot(i, j + 1) then inc(score);
        end;

    GridScore := score;
  end;

procedure FindBuildSpot(c, bc: integer; fp: TFootprint; best: boolean;
                        var x, y, bflip, brot: integer; prevplan: boolean);
  var
    i, j, flip, rot, fi, fj, score, bestscore: integer;
    xwid, ywid: integer;
    f: TFootprint;
    g: TGrid;
    test: boolean;
  begin
    bestscore := MaxInt;
    x := 1;
    y := 1;
    bflip := 0;
    brot := 0;

    for flip := 0 to 1 do begin
      f := fp;
      if flip = 1 then FlipFootprint(f);
      for rot := 0 to 3 do begin
        if rot <> 0 then RotateFootprint(f);
        FindFootprintSize(f, xwid, ywid);
        for i := 1 to 8 - xwid + 1 do
          for j := 1 to 8 - ywid + 1 do begin
            if prevplan then
              test := MatchesPlan(c, bc, i, j, f)
            else
              test := CanBuildThere(c, i, j, f)
                      and not (best and PlanOverlap(c, i, j, f));
            if test then begin
              if best then begin
                g := Castle[c].Grid;
                for fi := 1 to 4 do
                  for fj := 1 to 4 do
                    if f[fj, fi] <> '.' then
                      g[i + fi - 1, j + fj - 1] := 1;
                score := GridScore(g, prevplan);
              end else score := 0;
              if score < bestscore then begin
                bestscore := score;
                x := i;
                y := j;
                bflip := flip;
                brot := rot;
              end;
            end;
          end;
      end;
    end;
  end;

function CanBuildSomewhere(c: integer; fp: TFootprint): boolean;
  var i, x, y, bflip, brot: integer;
  begin
    FindBuildSpot(c, 0, fp, false, x, y, bflip, brot, false);
    if bflip > 0 then FlipFootprint(fp);
    if brot > 0 then for i := 1 to brot do RotateFootprint(fp);
    CanBuildSomewhere := CanBuildThere(c, x, y, fp);
  end;

procedure FindBuildCost(c, b: integer; var rs: TResourceSet);
  const
    BaseCosts: array [7..13] of TResourceSet =
    ( { gold  ro  ap em qu be cl }
      ( 1000,  0,  1, 1, 1, 1, 1), { spells 1 }
      ( 1000,  0,  5, 5, 5, 5, 5), { spells 2 }
      ( 3000,  6,  0, 0, 0, 0, 0), { little money }
      (10000, 15,  0, 0, 0, 0, 0), { big money }
      ( 5000,  5,  0, 0, 0, 0, 0), { silo }
      ( 2000,  3,  0, 0, 0, 0, 0), { barbican }
      ( 1000,  0,  0, 0, 0, 0, 0)  { treasury }
    );

    CrCosts: array [TCastleType, 1..6] of TResourceSet =
    ( {  gold  ro  ap  em  qu  be  cl }
      (( 1000,  2,  0,  0,  0,  0,  0), { jungle fort }
       ( 2000,  5,  0,  0,  0,  0,  0),
       ( 3000,  3,  0,  0,  0,  2,  0),
       ( 4500,  5,  5,  0,  0,  0,  0),
       ( 7000,  5,  0,  0,  0,  0,  5),
       (10000, 10, 15,  0,  0,  0,  0)),
      (( 1000,  3,  0,  0,  0,  0,  0), { city of shadows }
       ( 2000,  2,  0,  1,  0,  1,  0),
       ( 3000,  5,  0,  0,  0,  0,  0),
       ( 4500,  5,  0,  0,  5,  0,  5),
       ( 7000,  0,  0,  2,  0,  2,  0),
       (10000, 10,  0,  0,  0,  0, 15)),
      (( 1000,  3,  0,  0,  0,  0,  0), { cloud castle }
       ( 2000,  5,  2,  0,  0,  1,  1),
       ( 3000,  0,  0,  1,  1,  0,  0),
       ( 4500,  5,  0,  0,  0,  0,  0),
       ( 7000,  3,  0,  5,  5,  0,  0),
       (10000, 15,  2,  2,  2,  2,  2)),
      (( 1000,  3,  0,  0,  0,  0,  0), { thieves' guild }
       ( 2000,  5,  2,  0,  0,  0,  0),
       ( 3000,  5,  0,  0,  0,  0,  5),
       ( 4500,  0,  5,  0,  0,  0,  0),
       ( 7000,  5,  0,  5,  0,  0,  0),
       (10000, 10,  0, 15,  0,  0,  0)),
      (( 1000,  2,  0,  0,  0,  0,  0), { factory }
       ( 2000,  5,  0,  0,  0,  0,  0),
       ( 3000,  3,  0,  0,  0,  5,  0),
       ( 4500,  5,  0,  5,  0,  0,  0),
       ( 7000,  5,  0,  0,  5,  0,  0),
       (10000, 10,  0,  0, 15,  0,  0)),
      (( 1000,  2,  0,  0,  0,  0,  0), { laboratory }
       ( 2000,  5,  0,  0,  0,  0,  2),
       ( 3000,  0,  1,  1,  1,  1,  1),
       ( 4500,  0,  2,  0,  0,  2,  2),
       ( 7000,  7,  5,  0,  0,  0,  0),
       (10000, 10,  0,  0,  0, 15,  0)),
      (( 1000,  3,  0,  0,  0,  0,  0), { pyramid }
       ( 2000,  5,  0,  0,  0,  0,  0),
       ( 3000,  2,  0,  5,  0,  0,  0),
       ( 4500,  3,  5,  0,  5,  0,  0),
       ( 7000, 10,  0,  0,  0,  0,  0),
       (10000,  5,  0,  0, 15,  0,  0)),
      (( 1000,  2,  0,  0,  0,  0,  0), { ruins }
       ( 2000,  5,  3,  0,  0,  0,  0),
       ( 3000,  0,  2,  0,  0,  5,  2),
       ( 4500,  3,  0,  0,  0,  0,  0),
       ( 7000,  5,  0,  5,  5,  0,  0),
       (10000, 10,  0,  0,  0,  0, 15)),
      {  gold  ro  ap  em  qu  be  cl }
      (( 1000,  2,  0,  0,  0,  0,  0), { circus }
       ( 2000,  5,  0,  0,  1,  0,  0),
       ( 3000,  0,  0,  4,  4,  0,  0),
       ( 4500,  6,  0,  0,  0,  0,  0),
       ( 7000,  6,  2,  0,  0,  0,  2),
       (10000, 10,  0,  0,  0, 15,  0)),
      (( 1000,  2,  0,  0,  0,  0,  0), { evil temple }
       ( 2000,  5,  0,  0,  0,  2,  0),
       ( 3000,  5,  3,  1,  0,  0,  0),
       ( 4500,  1,  1,  1,  1,  0,  1),
       ( 7000,  5,  0,  0,  0,  2,  2),
       (10000, 10,  0, 15,  0,  0,  0))
    );
  var
    rez: TResource;
    m: integer;
  begin
    if b <= 6 then begin
      m := MonsterForLevel(Castle[c].CT, b) - 1;
      rs := CrCosts[TCastleType(m div 6), (m mod 6) + 1]
    end else
      rs := BaseCosts[b];

    if Twists[twDoubleCostProd] and (b >= bCreature1)
       and (b <= bCreature6) then
      for rez := low(TResource) to high(TResource) do
        rs[rez] := rs[rez] * 2;
  end;

function CanBuildKind(c: integer): integer;
  var
    j, cbk: integer;
    rs: TResourceSet;
  begin
    cbk := 0;

    for j := 13 downto 1 do begin
      FindBuildCost(c, j, rs);
      if CanPay(Player[Turn].Resources, rs)
         and CanBuildSomewhere(c, BuildingFootprint(c, j)^) then begin
        if j <= 6 then
          cbk := 2
        else
          cbk := 1;
      end;
    end;

    CanBuildKind := cbk;
  end;

function BuildingFootprint(c, b: integer): PFootprint;
  var
    fp: PFootprint;
    m: integer;
  begin
    if b <= 6 then begin
      if Twists[twOneSquareDwelling] and (b = OneSquareDwelling) then
        fp := @BaseFeet[bTreasure]
      else begin
        m := MonsterForLevel(Castle[c].CT, b) - 1;
        fp := @CrFeet[TCastleType(m div 6), (m mod 6) + 1];
      end;
    end else
      fp := @BaseFeet[b];
    BuildingFootprint := fp;
  end;

procedure AddRandomSpell(c, lev: integer);
  var sp: integer;
  begin
    sp := RandomNewSpell(Castle[c].AvailableSpells, lev, 0, false);
    if sp <> 0 then
      AddSpell(Castle[c].AvailableSpells, sp);
  end;

procedure RemovePlan(c, x, y: integer);
  var i, j, cent: integer;
  begin
    with Castle[c] do begin
      cent := Center[x, y];
      for i := 1 to 8 do
        for j := 1 to 8 do
          if Center[i, j] = cent then begin
            Center[i, j] := 255;
            Grid[i, j] := bEmpty;
          end;
    end;
  end;

procedure RemoveAllPlans(c: integer);
  var i, j: integer;
  begin
    with Castle[c] do
      for i := 1 to 8 do
        for j := 1 to 8 do
          if (Grid[i, j] and bPlanned) <> 0 then begin
            Grid[i, j] := bEmpty;
            Center[i, j] := 255;
          end;
  end;

function BuildInCastle(c, BuildChoice, BuildX, BuildY: integer;
                       BuildFP: TFootprint; trading, free: boolean): boolean;
  var
    i, j, bc, h: integer;
    bic, plan: boolean;
    rs: TResourceSet;
  begin
    bic := false;

    if CanBuildThere(c, BuildX, BuildY, BuildFP) then begin
      plan := (BuildChoice and bPlanned) <> 0;

      if plan or free then
        bic := true
      else begin
        FindBuildCost(c, BuildChoice, rs);
        if PayEither(Player[Turn].Resources, rs, ExcessRez, trading) then
          bic := true;
      end;

      if bic then begin
        for i := 1 to 4 do
          for j := 1 to 4 do
            if BuildFP[j, i] = '@' then
              bc := BuildX + i - 2 + (BuildY + j - 2) * 8;

        for i := 1 to 4 do
          for j := 1 to 4 do
            if BuildFP[j, i] in ['*', '@'] then
              if (Castle[c].Grid[BuildX + i - 1, BuildY + j - 1]
                  and bPlanned) <> 0 then
                RemovePlan(c, BuildX + i - 1, BuildY + j - 1);

        for i := 1 to 4 do
          for j := 1 to 4 do
            if BuildFP[j, i] in ['*', '@'] then begin
              Castle[c].Grid[BuildX + i - 1, BuildY + j - 1] := BuildChoice;
              Castle[c].Center[BuildX + i - 1, BuildY + j - 1] := bc;
              if not plan then dec(Castle[c].FreeSquares);
            end;

        if not plan then begin
          case BuildChoice of
            bCreature1
            ..bCreature6: begin
                            i := 1200;
                            if Twists[twDoubleCostProd] then i := i * 2;
                            i := i div MonsterData
                                       [MonsterForLevel(Castle[c].CT,
                                                        BuildChoice)].cost;
                            if i < 1 then i := 1;
                            inc(Castle[c].AvailableTroops[BuildChoice], i);
                          end;
            bSpells1,
            bSpells2:    begin
                           if BuildChoice = bSpells1 then
                             for i := 0 to 3 do
                               AddRandomSpell(c, (i div 2) + 1)
                           else
                             for i := 0 to 3 do
                               AddRandomSpell(c, (i div 2) + 3);
                           h := HeroAtSpot(Castle[c].MapX, Castle[c].MapY);
                           if h <> 0 then
                             AddSpellSet(Hero^[h].SS, Castle[c].AvailableSpells);
                         end;
            bLittleMoney: inc(Castle[c].Income[rGold], 500);
            bBigMoney:    inc(Castle[c].Income[rGold], 2500);
            bSilo:        inc(Castle[c].Income[SiloResource[Castle[c].CT]]);
          end;
        end;
      end;
    end;

    BuildInCastle := bic;
  end;

function TryToBuild(c, bc: integer; trading, free: boolean): boolean;
  var
    ttb: boolean;
    rs: TResourceSet;
    fp: TFootprint;
    x, y, bflip, brot, j: integer;
  begin
    ttb := false;
    if trading and not free then CalcSpareRez(Turn, ExcessRez);

    FindBuildCost(c, bc, rs);
    if free or CanPayEither(Player[Turn].Resources, rs, ExcessRez,
                            trading) then begin
      fp := BuildingFootprint(c, bc)^;
      FindBuildSpot(c, 0, fp, true, x, y, bflip, brot, false);
      if bflip > 0 then FlipFootprint(fp);
      if brot > 0 then for j := 1 to brot do RotateFootprint(fp);
      if CanBuildThere(c, x, y, fp)
         and BuildInCastle(c, bc, x, y, fp, trading, free) then
        ttb := true;
    end;

    TryToBuild := ttb;
  end;

procedure AIVisitCastle(c, h: integer);
  var
    i, j, x, y, bflip, brot, crown, crownidx, idx: integer;
    rs: TResourceSet;
    fp: TFootprint;
    did: boolean;
  begin
    { day 1 special }

    if (Date = 0)
       and (Player[Hero^[h].player].Resources[rGold] >= 5500)
       and not Twists[twStartWithStack] then begin
      TryToBuild(c, 1, false, false);
      TryToBuild(c, 1, false, false);
    end;

    { build treasuries for crowns }

    repeat
      crownidx := 0;
      did := false;

      for i := 1 to BackpackSize do begin
        j := Hero^[h].Backpack[i];
        if (j >= anCrownOfBreeding) and (j <= anCrownOfTactics) then begin
          if (crownidx = 0) or (j < crown) then begin
            crownidx := i;
            crown := j;
          end;
        end;
      end;

      FindBuildCost(c, bTreasure, rs);
      if (crownidx <> 0) then begin
        if PlaceCrown(c, crown) then begin
          LoseArt(h, crown);
          did := true;
        end else if CanPay(Player[Turn].Resources, rs)
                and TryToBuild(c, bTreasure, false, false) then begin
          Pay(Player[Turn].Resources, rs);
          PlaceCrown(c, crown);
          LoseArt(h, crown);
          did := true;
        end;
      end;
    until not did;

    { buy available troops }

    for i := 6 downto 1 do
      BuyCastleTroops(c, i, Castle[c].AvailableTroops[i], true);

    { build mage guilds }

    if GetEffSkillLevel(h, skLore) = 0 then begin
      if (Hero^[h].level >= 8) and (CountSpells(Hero^[h].SS) < 10)
         and (GetEffSkillLevel(h, skWizardry) >= 3) then
        TryToBuild(c, bSpells2, false, false);

      if (Hero^[h].level >= 3) and (CountSpells(Hero^[h].SS) < 5)
         and (GetEffSkillLevel(h, skPower)
              + GetEffSkillLevel(h, skWizardry)
              + GetEffSkillLevel(h, skSpellcraft)
              + GetEffSkillLevel(h, skSorcery)
              + GetEffSkillLevel(h, skWitchcraft) >= 2) then
        TryToBuild(c, bSpells1, false, false);
    end;

    { build creature dwelling and buy troops }

    for idx := 1 to 6 do begin
      i := MonsterRanks[Castle[c].CT, idx];
      if FindEmptyOrMonster(@Hero^[h].army, HeroSlots(h),
                            MonsterForLevel(Castle[c].CT, i)) <> 0 then begin
        repeat
          CalcSpareRez(Turn, ExcessRez);
          did := false;
          FindBuildCost(c, i, rs);
          inc(rs[rGold], 1200);
          if CanPayWithTrading(Player[Turn].Resources, rs, ExcessRez)
             and TryToBuild(c, i, true, false) then begin
            BuyCastleTroops(c, i, Castle[c].AvailableTroops[i], true);
            did := true;
          end;
        until not did;
      end;
    end;

    { take garrison'd troops }

    ShareTroops(@Hero^[h].army, @Castle[c].Garrison, HeroSlots(h), 6);
  end;

procedure RemoveBuilding(c, x, y: integer);
  var cent, i, j: integer;
  begin
    with Castle[c] do begin
      cent := Center[x, y];
      for i := 1 to 8 do
        for j := 1 to 8 do
          if Center[i, j] = cent then begin
            if cent = (i - 1) + (j - 1) * 8 then begin
              case Grid[i, j] of
                bLittleMoney: dec(Income[rGold], 500);
                bBigMoney:    dec(Income[rGold], 2500);
                bSilo:        dec(Castle[c].Income[SiloResource[Castle[c].CT]]);
              end;
            end;
            Grid[i, j] := bEmpty;
            Center[i, j] := 255;
            Decay[i, j] := 0;
          end;
    end;
  end;

function DecayTime(g: integer): integer;
  begin
    DecayTime := 10 + FeetSize[g] * 4;
  end;

procedure HandleDecay(c: integer);
  var i, j, g: integer;
  begin
    with Castle[c] do
      for i := 1 to 8 do
        for j := 1 to 8 do begin
          g := Grid[i, j];
          if g in bDecays then begin
            inc(Decay[i, j]);
            if Decay[i, j] >= DecayTime(g) then
              RemoveBuilding(c, i, j);
          end;
        end;
  end;

procedure GiveCastleSummoning(c, m: integer);
  var m2, q: integer;
  begin
    with Castle[c] do begin
      m2 := ((m - 1) mod 6) + 1;
      if Summoning[m2] < 32000 then inc(Summoning[m2], SummoningGP);
      q := Summoning[m2] div MonsterData[m].cost;
      if q > 0 then
        if GainMonster(@Garrison, 6, m, q) then
          dec(Summoning[m2], q * MonsterData[m].cost);
    end;
  end;


{ TCastleScr methods }

constructor TCastleScr.Init;
  begin
    TObject.Init;
    PC := nil;
    GarrisonBar := New(PArmyBar, Init(56, 390, nil, 6, 56, cwid+8, 0, false));
    HeroBar := nil;
    VisitingHero := 0;
  end;

destructor TCastleScr.Done;
  begin
    TObject.Done;
  end;

procedure TCastleScr.SetCastle(P: PCastle);
  begin
    PC := P;
    GarrisonBar^.AS := @(PC^.Garrison);
    GarrisonBar^.highlight := 0;
    Action := caNone;
    BuildChoice := 0;
    SetHero(HeroAtSpot(PC^.MapX, PC^.MapY));
  end;

function TCastleScr.FootprintOverSquare(x, y: integer): boolean;
  var fos: boolean;
  begin
    fos := (BuildChoice <> 0)
           and (x >= BuildX) and (y >= BuildY)
           and (x <= BuildX + 3) and (y <= BuildY + 3)
           and (BuildFP[y - BuildY + 1, x - BuildX + 1] in ['*', '@']);

    FootprintOverSquare := fos;
  end;

procedure TCastleScr.DrawCastleSquare(x, y: integer);
  var
    i, j, n, x1, y1, g, c, fc, sc: integer;
    p: PGraphic;
    ghostok, fos: boolean;

  procedure DrawSide(ox, oy, a1, b1, a2, b2: integer);
    begin
      if not InCastle(x + ox, y + oy)
         or (PC^.Center[x + ox, y + oy] <> c) then
        CheckerArea(x1 + a1, y1 + b1, x1 + a2, y1 + b2, fc);
    end;

  procedure DrawCorner(ox, oy, a1, b1, a2, b2: integer);
    begin
      if InCastle(x + ox, y + oy)
         and (PC^.Center[x + ox, y + oy] <> c) then
        CheckerArea(x1 + a1, y1 + b1, x1 + a2, y1 + b2, fc);
    end;

  begin
    x1 := (x - 1) * 40 + 4;
    y1 := (y - 1) * 40 + 4;
    g := PC^.Grid[x, y];
    c := PC^.Center[x, y];
    fos := FootprintOverSquare(x, y);
    if fos then begin
      fc := colDarkGray;
      if GridEmpty(cnum, x, y) then begin
        if CanBuildThere(cnum, BuildX, BuildY, BuildFP) then
          sc := BackColor[BuildChoice]
        else
          sc := colDarkGray
      end else
        sc := colBlack;
    end else if (g and bPlanned) <> 0 then begin
      fc := colDarkDarkGray;
      sc := colBlack;
    end else begin
      fc := ForeColor[g];
      sc := BackColor[g];
    end;

    XFillArea(x1, y1, x1 + 39, y1 + 39, sc);

    if g = bEmpty then begin
      ghostok := true;
      if InCastle(x - 1, y - 1) and InCastle(x + 1, y + 1) then begin
        for i := -1 to 1 do
          for j := -1 to 1 do
            if (PC^.Grid[x + i, y + j] <> bEmpty) or ghosts[x + i, y + j] then
              ghostok := false;
        if ghostok then begin
          if not fos then
            DrawGraphic(x1 + 4 + 2 - 1, y1 + 4 + 2 - 1, colDarkGray,
                        MonsterGraphic(MonsterForLevel(PC^.CT, + 1))^, false);
          ghosts[x, y] := true;
        end;
      end;
    end else begin
      DrawSide(-1,  0,  0,  0,  2, 39);
      DrawSide( 1,  0, 37,  0, 39, 39);
      DrawSide( 0, -1,  0,  0, 39,  2);
      DrawSide( 0,  1,  0, 37, 39, 39);
      DrawCorner(-1, -1,  0,  0,  2,  2);
      DrawCorner(-1,  1,  0, 37,  2, 39);
      DrawCorner( 1, -1, 37,  0, 39,  2);
      DrawCorner( 1,  1, 37, 37, 39, 39);

      if c = (x - 1) + (y - 1) * 8 then begin
        p := nil;
        g := g and bMask;
        case g of
          bCreature1..bCreature6:
            p := MonsterGraphic(MonsterForLevel(PC^.CT, g - bCreature1 + 1));
          bSilo:        p := @ResourceGraphics[SiloResource[PC^.CT]];
          bObstacle:    p := @Obstacles[PC^.CT];
          bSpells1:     p := @CastleIcons[ciSpells1];
          bSpells2:     p := @CastleIcons[ciSpells2];
          bLittleMoney: p := @ResourceGraphics[rGold];
          bBigMoney:    p := @CastleIcons[ciMint];
          bBarbican:    p := @CastleIcons[ciBarbican];
          bTreasure,
          bCrownOfBreeding
          ..bCrownOfTactics: p := @CastleIcons[ciTreasure];
        end;
        if p <> nil then
          DrawGraphic(x1 + 4 + 2 - 1, y1 + 4 + 2 - 1, fc, p^, false);
      end;
    end;
  end;

procedure TCastleScr.DrawCastle;
  var x, y: integer;
  begin
{   ClearArea(4, 4, cwid - 4, cwid - 4); }
    Fillchar(ghosts, sizeof(ghosts), chr(ord(false)));

    for x := 1 to 8 do
      for y := 1 to 8 do
        DrawCastleSquare(x, y);
  end;

procedure TCastleScr.DrawIcons;
  var
    i, j, x, y, c: integer;
    active: boolean;
  begin
    for i := 0 to 7 do begin
      x := (i mod 4) * 60 + 338 + 36;
      y := (i div 4) * 50 + 10;

      case i + 1 of
        ciBuyCreatures: begin
                          active := false;
                          for j := 1 to 6 do begin
                            if (Player[Turn].Resources[rGold]
                                div MonsterCost(cnum, j) >= 1)
                               and (PC^.AvailableTroops[j] > 0) then
                              active := true;
                          end;
                        end;
        ciBuild:        active := CanBuildKind(cnum) > 0;
        ciSpells1:      begin
                          active := false;
                          for j := 1 to 4 do
                            if PC^.AvailableSpells[j] <> 0 then
                              active := true;
                        end;
        ciBuyHero:      active := (Player[PC^.Player].Resources[rGold] >= 2500)
                                  and (VisitingHero = 0)
                                  and (Player[PC^.Player].Dudes[MaxDudes] = 0)
                                  and ((Taverns[PC^.CT, 1] <> 0)
                                       or (Taverns[PC^.CT, 2] <> 0)
                                       or (DeadGuys[1] <> 0)
                                       or (DeadGuys[2] <> 0));
        ciMarket:       active := true;
        ciPrevCastle,
        ciNextCastle:   active := Player[PC^.Player].Towns[2] <> 0;
        ciExit:         active := true;
      end;

      if active then
        c := colWhite
      else
        c := colBlack;

      DrawIcon2c(x, y, c, colBlack, @CastleIcons[i + 1]);
    end;

    GarrisonBar^.DrawIcons;

    DrawIcon(56 + 6 * 36 + 5, 390, @CastleIcons[18]);
  end;

procedure DrawResourceSet(i, j: integer; rs, mainrs: TResourceSet);
  var
    r: TResource;
    c: integer;
  begin
    for r := low(TResource) to high(TResource) do begin
      if mainrs[r] < rs[r] then
        c := colRed
      else
        c := colBlack;
      DrawResource(i + (ord(r) mod 4) * 75, j + (ord(r) div 4) * 13,
                   c, r, rs[r]);
    end;
  end;

procedure TCastleScr.DrawResources;
  begin
    ClearArea(cwid + 1, 445, 636, 476);
    DrawResourceSet(cwid + 8, 450, Player[Turn].Resources,
                    Player[Turn].Resources);
  end;

function TCastleScr.BuildingName(b: integer): string;
  const
    BuildingNames: array [7..19] of string[18] =
    (
      'Spell Crypt',
      'Spell Tower',
      'Bazaar',
      'Mint',
      'Mine',
      'Barbican',
      'Treasury',
      'Obstacle',
      'Crown of Breeding',
      'Mercenary''s Crown',
      'Crown of Offense',
      'Crown of Defense',
      'Crown of Tactics'
    );
  var s: string;
  begin
    if b = 0 then
      s := 'Empty'
    else if b <= 6 then
      s := MonsterData[MonsterForLevel(PC^.CT, b)].pname
    else
      s := BuildingNames[b];
    if b = bSilo then s := MineNames[SiloResource[PC^.CT]];
    BuildingName := s;
  end;

function TCastleScr.BuildingHint(b: integer): string;
  var s: string;
  begin
    s := '';
    case b of
      bEmpty:       s := 'Space available for buildings.';
      bCreature1
      ..bCreature6: s := 'Produces '
                         + MonsterData[MonsterForLevel(PC^.CT, b)].pname + '.';
      bSpells1:     s := 'Teaches two 1st level and two 2nd level spells.';
      bSpells2:     s := 'Teaches two 3rd level and two 4th level spells,';
      bLittleMoney: s := 'Produces 500 ' + crGold + ' per day.';
      bBigMoney:    s := 'Produces 2500 ' + crGold + ' per day.';
      bSilo:        begin
                      s := 'Produces 1 ' + RezChr(SiloResource[PC^.CT])
                           + ' per day.';
                    end;
      bBarbican:    s := 'Defends castle.';
      bTreasure:    s := 'Holds a Crown artifact brought here.';
      bObstacle:    s := 'Unusable space.';
      bCrownOfBreeding: s := 'Increases creature production here by 100 '
                             + crGold + ' per square per day.';
      bMercenarysCrown: s := 'Creatures are half price here.';
      bCrownOfOffense:  s := 'All allied troops deal +10% damage.';
      bCrownOfDefense:  s := 'All allied troops get +10% hit points.';
      bCrownOfTactics:  s := 'All allied troops get +0.5 speed.';
    end;

    BuildingHint := s;
  end;

procedure TCastleScr.DrawFootprint(x, y, siz, fc, rc: integer; fp: TFootprint);
  var i, j, a, b, c: integer;
  begin
    for i := 0 to 3 do
      for j := 0 to 3 do begin
        if fp[j + 1, i + 1] in ['*', '@'] then
          c := fc
        else
          c := colBlack;
        for a := 0 to siz - 1 do
          for b := 0 to siz - 1 do
            XPutPixel(x + i * siz + a, y + j * siz + b, c);
      end;

    XRectangle(x - 1, y - 1, x + siz * 4, y + siz * 4, rc);
  end;

procedure TCastleScr.DrawAreaBuild;
  var
    i, x, fc, nc, rc: integer;
    r: TResource;
    rs: TResourceSet;
    s: string;
    fp: TFootprint;
    cbs: boolean;
  begin
    for i := 1 to 13 do begin
      FindBuildCost(cnum, i, rs);
      fp := BuildingFootprint(cnum, i)^;
      cbs := CanBuildSomewhere(cnum, fp);
      if cbs and CanPay(Player[Turn].Resources, rs) then begin
        fc := BackColor[i];
        nc := colWhite;
        rc := colLightGray;
      end else begin
        fc := colDarkGray;
        if cbs then nc := colLightGray else nc := colDarkGray;
        rc := colDarkGray;
      end;
      DrawFootprint(306 + 82, 117 + i * 20, 4, fc, rc, fp);
      s := BuildingName(i);
      DrawText(306 + 82 + 24, 117 + i * 20 + 4, colBlack, nc, s);
      if cbs then begin
        x := 306 + 82 + 24 + 8 * length(s) + 8;
        for r := low(TResource) to high(TResource) do
          if rs[r] > Player[Turn].Resources[r] then begin
            DrawResourceGraphic(x, 117 + i * 20 + 4 - 1, r);
            inc(x, 12);
          end;
      end;
    end;
  end;

procedure TCastleScr.DrawBuildChoice;
  const
    ButtonStr: array [0..3] of string[6] = ('Rotate', 'Flip', 'Build', 'Plan');
  var
    i, c, cp: integer;
    a: TArmy;
    rs: TResourceSet;
  begin
    FindBuildCost(cnum, BuildChoice, rs);

    if CanBuildThere(cnum, BuildX, BuildY, BuildFP) then begin
      cp := colWhite;
      if CanPay(Player[Turn].Resources, rs) then
        c := colWhite
      else
        c := colBlack;
    end else begin
      cp := colBlack;
      c := colBlack;
    end;

    DrawIcon(0 * 60 + 338 + 36, 137, @CastleIcons[ciRotate]);
    DrawIcon(1 * 60 + 338 + 36, 137, @CastleIcons[ciFlip]);
    DrawIcon2c(2 * 60 + 338 + 36, 137, c, colBlack, @CastleIcons[ciBuild]);
    DrawIcon2c(3 * 60 + 338 + 36, 137, cp, colBlack, @CastleIcons[ciPlan]);

    for i := 0 to 3 do
      DrawText(i * 60 + 338 + 36, 137 - 10, colBlack, colLightGray, ButtonStr[i]);

    DrawFootprint(338 + 40 + 36, 137 + 60, 8, BackColor[BuildChoice],
                  colLightGray, BuildFP);
    DrawText(338 + 40 + 36 + 48, 137 + 60 + 12, colBlack, colLightGray,
             BuildingName(BuildChoice));

    DrawResourceSet(cwid + 8, 137 + 60 + 32 + 12, rs, Player[Turn].Resources);

    if BuildChoice in [bCreature1..bCreature6] then begin
      a.monster := MonsterForLevel(PC^.CT, BuildChoice);
      a.qty := 0;
      DrawArmyStats(338 + 36, 137 + 60 + 32 + 12 + 40, a,
                    MonsterCost(cnum, BuildChoice),
                    (CastleGPProdPerSquare(cnum)
                     + HusbandryByLevel(cnum, BuildChoice))
                    * FeetSize[BuildChoice], true);
    end else begin
      DrawBoxText(338 + 36, 137 + 60 + 32 + 12 + 40, 639 - 47,
                  colBlack, colWhite, BuildingHint(BuildChoice));
    end;
  end;

procedure TCastleScr.DrawAreaBuy;
  var
    i, x, y, c, prod: integer;
    a: TArmy;
    canbuy: boolean;
  begin
    canbuy := false;
    for i := 1 to 6 do begin
      x := cwid + 6;
      y := 118 + 46 * i;
      a.monster := MonsterForLevel(PC^.CT, i);
      a.qty := PC^.AvailableTroops[i];

      if (Player[Turn].Resources[rGold] div MonsterCost(cnum, i) >= 1)
         and (a.qty > 0) then begin
        c := colWhite;
        canbuy := true;
      end else
        c := colBlack;

      prod := (CastleGPProdPerSquare(cnum) + HusbandryByLevel(cnum, i))
              * CastleSquaresOfType(cnum, i);
      if Twists[twOneSquareDwelling] and (i = OneSquareDwelling) then
        prod := prod * FeetSize[i];

      DrawArmyStats(x, y, a, MonsterCost(cnum, i), prod,
                    (prod > 0) or (a.qty > 0));

      DrawIcon2c(x + 36 + 6 + 21 * 8 + 5, y, c, colBlack, @CastleIcons[ciBuy1]);
      DrawIcon2c(x + 36 + 6 + 21 * 8 + 5 + 44, y, c, colBlack,
                 @CastleIcons[ciBuyAll]);
    end;

    if canbuy then
      c := colWhite
    else
      c := colBlack;

    DrawIcon2c(x + 36 + 6 + 21 * 8 + 5 + 44, 118, c, colBlack,
               @CastleIcons[ciBuyAll]);
  end;

procedure TCastleScr.DrawAreaSpells;
  begin
    DrawSpellSet(cwid + 40, 149 - 12, PC^.AvailableSpells);
  end;

function TCastleScr.FindTavernHero(i: integer): integer;
  begin
    if (i = 1) or (i = 2) then
      FindTavernHero := Taverns[PC^.CT, i]
    else if (i = 3) or (i = 4) then
      FindTavernHero := DeadGuys[i - 2]
    else
      FindTavernHero := 0;
  end;

procedure TCastleScr.DrawAreaTavern;
  var i, h: integer;
  begin
    if (Taverns[PC^.CT, 1] = 0) and (Taverns[PC^.CT, 2] = 0)
       and (DeadGuys[1] = 0) and (DeadGuys[2] = 0) then
      DrawText(cwid + 40, 137, colBlack, colRed, 'No heroes available!')
    else begin
      for i := 1 to 4 do begin
        h := FindTavernHero(i);
        if h <> 0 then
          DrawHeroInfo(cwid + 40, 137 + (i - 1) * 83, h);
      end;
    end;
  end;

procedure TCastleScr.FindMarketRate(var left, right: integer);
  begin
    FindExchangeRate(MarketLeft, MarketRight, left, right);
  end;

procedure TCastleScr.DrawAreaMarket;
  var
    left, right, t, i, j, b, c1, c2: integer;
    rs, sum: TResourceSet;
    r: TResource;
    gotplan: boolean;

  procedure IconForAmt(ci, x, amt: integer);
    var c: integer;
    begin
      if (t >= amt) and (MarketLeft <> MarketRight) then
        c := colWhite
      else
        c := colBlack;
      DrawIcon2c(x, 137 + 140, c, colBlack, @CastleIcons[ci]);
    end;

  procedure SetColors(match: boolean);
    begin
      if match then begin
        c1 := ResourceColors[r];
        c2 := ResourceBacks[r];
      end else begin
        c1 := colDarkDarkGray;
        c2 := colBlack;
      end;
    end;

  begin
    for r := low(TResource) to high(TResource) do begin
      SetColors(r = MarketLeft);
      DrawIcon2c(cwid + 6 + ord(r) * 43, 118, c1, c2, @ResourceGraphics[r]);
      SetColors(r = MarketRight);
      DrawIcon2c(cwid + 6 + ord(r) * 43, 118 + 45, c1, c2, @ResourceGraphics[r]);
    end;

    DrawIcon2c(cwid + 75, 137 + 80, ResourceColors[MarketLeft],
               ResourceBacks[MarketLeft], @ResourceGraphics[MarketLeft]);
    DrawGraphic(cwid + 75 + 60 + 5, 137 + 80 + 6, colWhite, RightArrow, false);
    DrawIcon2c(cwid + 75 + 120, 137 + 80, ResourceColors[MarketRight],
               ResourceBacks[MarketRight], @ResourceGraphics[MarketRight]);

    FindMarketRate(left, right);
    DrawText(cwid + 75 + 8, 137 + 80 + 45, colBlack, colWhite,
             CSet(IStr(left, 0), 4));
    DrawText(cwid + 75 + 120 + 8, 137 + 80 + 45, colBlack, colWhite,
             CSet(IStr(right, 0), 4));
    t := Player[Turn].Resources[MarketLeft] div left;

    IconForAmt(ciBuy1, cwid + 75, 1);
    IconForAmt(ciBuy5, cwid + 75 + 60, 5);
    IconForAmt(ciBuy10, cwid + 75 + 120, 10);

    DrawText(cwid + 40, 137 + 190, colBlack, colWhite,
             'Resources produced this turn:');
    DrawResourceSet(cwid + 8, 137 + 210, RezProd, RezProd);

    FillChar(sum, sizeof(sum), #0);
    gotplan := false;

    for i := 1 to 8 do
      for j := 1 to 8 do begin
        b := Castle[cnum].Grid[i, j];
        if ((b and bPlanned) <> 0)
           and (Castle[cnum].Center[i, j] = (i - 1) + (j - 1) * 8) then begin
          FindBuildCost(cnum, b and bMask, rs);
          for r := low(TResource) to high(TResource) do
            inc(sum[r], rs[r]);
          gotplan := true;
        end;
      end;

    if gotplan then begin
      DrawText(cwid + 40, 137 + 190 + 60, colBlack, colWhite,
               'Cost of planned buildings:');
      DrawResourceSet(cwid + 8, 137 + 210 + 60, sum, sum);
    end;
  end;

procedure TCastleScr.DrawActionArea;
  begin
    ClearArea(cwid + 1, 109, 636, 441);

    case Action of
      caNone:   ;
      caBuy:    DrawAreaBuy;
      caBuild:  if BuildChoice <> 0 then
                  DrawBuildChoice
                else
                  DrawAreaBuild;
      caSpells: DrawAreaSpells;
      caTavern: DrawAreaTavern;
      caMarket: DrawAreaMarket;
    end;
  end;

procedure TCastleScr.DrawGarrison;
  begin
    if HeroBar <> nil then begin
      HeroBar^.Draw;
      case HeroSlots(VisitingHero) of
          6: begin
               HeroX := 56 - 40;
               HeroY := 390 + 45 + 2;
             end;
       7..9: begin
               HeroX := 5;
               HeroY := 397;
             end;
         10: begin
               HeroX := 5;
               HeroY := 397 - 40;
             end;
      end;
      DrawHero(HeroX, HeroY, colLightGray, VisitingHero)
    end;
    if GarrisonBar <> nil then
      GarrisonBar^.Draw;
  end;

procedure TCastleScr.Draw;
  begin
    CheckerArea(0, 0, 639, 2, colDarkGray);
    CheckerArea(0, 477, 639, 479, colDarkGray);
    CheckerArea(0, 0, 2, 479, colDarkGray);
    CheckerArea(637, 0, 639, 479, colDarkGray);

    CheckerArea(0, cwid - 2, cwid, cwid, colDarkGray);
    CheckerArea(cwid - 2, 0, cwid, 479, colDarkGray);
    CheckerArea(cwid, 106, 639, 108, colDarkGray);
    CheckerArea(cwid, 442, 639, 444, colDarkGray);

    DrawCastle;
    DrawIcons;
    DrawActionArea;
    DrawResources;
    DrawGarrison;
  end;

procedure TCastleScr.Build;
  var i, j, c: integer;
  begin
    if BuildInCastle(cnum, BuildChoice, BuildX, BuildY, BuildFP,
                     false, false) then begin
      Action := caNone;
      if BuildChoice <= 6 then
        Action := caBuy
      else if (BuildChoice = bSpells1) or (BuildChoice = bSpells2) then
        Action := caSpells;
      BuildChoice := 0;
      DrawResources;
    end;
  end;

procedure TCastleScr.FindDeadGuys;
  var
    deadlev: array [1..2] of integer;
    i, h: integer;
    used: boolean;
  begin
    for i := 1 to 2 do begin
      deadlev[i] := 0;
      DeadGuys[i] := 0;
    end;

    for h := 1 to NumHeroes do
      if Hero^[h].Dead and (Hero^[h].player = Turn) then begin
        used := false;
        for i := 1 to 2 do
          if not used and (DeadGuys[i] = 0) then begin
            used := true;
            DeadGuys[i] := h;
            deadlev[i] := Hero^[h].level;
          end;
        for i := 1 to 2 do
          if not used and (Hero^[h].level > deadlev[i]) then begin
            used := true;
            DeadGuys[i] := h;
            deadlev[i] := Hero^[h].level;
          end;
      end;
  end;

procedure TCastleScr.SetHero(h: integer);
  var sl, j: integer;
  begin
    if HeroBar <> nil then begin
      Dispose(HeroBar, Done);
      HeroBar := nil;
    end;

    VisitingHero := h;
    if h <> 0 then begin
      sl := HeroSlots(VisitingHero);
      if sl > 9 then j := 9 else j := sl;
      HeroBar := New(PArmyBar, Init(56 - 18 * (j - 6),
                                    390 + 45, @Hero^[VisitingHero].army,
                                    sl, 56, cwid + 8, h, sl = 10));
      if VisitingHero <> 0 then begin
        AddSpellSet(Hero^[VisitingHero].SS, PC^.AvailableSpells);
        if HeroHasExpertiseBonus(VisitingHero, skSpellcraft) then
          AddSpellSet(PC^.AvailableSpells, Hero^[VisitingHero].SS);
      end;
    end;
  end;

procedure TCastleScr.Handle(C: PCastle; icnum: integer);
  const
    ButtonHint: array [0..7] of string[90] =
    (
      'Buy creatures produced here.',
      'Build or plan new buildings.',
      'See what spells are taught here.',
      'Buy a hero here ' + chr(colLightGray) + '(2500 ' + crGold
      + ', if no hero is here and you have less than 8 heroes).',
      'Trade resources.',
      'View previous castle.',
      'View next castle.',
      'Exit castle screen.'
    );
  var
    over, did: boolean;
    E: TEvent;
    x, y, ike, n, h, i, left, right, t, bflip, brot, sp: integer;
    ActiveBar: PArmyBar;
    a: TCastleAction;
    s: string;

  procedure ShowHeroScreen(hsh: integer; jth: boolean);
    begin
      if hsh <> 0 then begin
        DoHeroScreen(hsh, jth);
        Draw;
      end;
    end;

  procedure FindDefaultBuildSpot;
    var rt: integer;
    begin
      BuildFP := BuildingFootprint(cnum, BuildChoice)^;
      FindBuildSpot(cnum, 0, BuildFP, true, BuildX, BuildY, bflip, brot, false);
      if bflip > 0 then FlipFootprint(BuildFP);
      if brot > 0 then
        for rt := 1 to brot do RotateFootprint(BuildFP);
      if PlanOverlap(cnum, BuildX, BuildY, BuildFP)
         or not CanBuildThere(cnum, BuildX, BuildY, BuildFP) then begin
        FindBuildSpot(cnum, BuildChoice, BuildFP, true, BuildX, BuildY, bflip,
                      brot, true);
        if bflip > 0 then FlipFootprint(BuildFP);
        if brot > 0 then
          for rt := 1 to brot do RotateFootprint(BuildFP);
      end;
      DrawActionArea;
      DrawCastle;
    end;

  procedure CastleHint(ch: string);
    begin
      if ch <> '' then begin
        BaseMessage(ch);
        ClearScr;
        Draw;
      end;
    end;

  begin
    cnum := icnum;
    over := false;
    SetCastle(C);
    FindDeadGuys;
    MarketLeft := rRocks;
    MarketRight := rGold;

    DrawBackground := false;
    ClearScr;
    Draw;

    repeat
      WaitForEvent(E);
      if E.What = evMouseDown then begin
        if E.Buttons = mbLeftButton then begin
          x := E.Where.X;
          y := E.Where.Y;

          if (x >= 4) and (y >= 4)
             and (x <= cwid - 4) and (y <= cwid - 4) then begin
            x := (x - 4) div 40 + 1;
            y := (y - 4) div 40 + 1;
            if (Action = caBuild) and (BuildChoice <> 0) then begin
              BuildX := x;
              BuildY := y;
              DrawCastle;
              DrawActionArea;
            end;
          end else if (x > cwid) and (x < 637)
                      and (y >= 4) and (y < 106) then begin
            x := (x - 338 - 36) div 60;
            y := (y - 10) div 50;
            if (x >= 0) and (y >= 0) and (x <= 3) and (y <= 1) then begin
              ike := x + y * 4 + 1;
              if ike <= 5 then begin
                Action := TCastleAction(ike);
                BuildChoice := 0;
                DrawActionArea;
                DrawCastle;
              end else if (ike >= 6) and (ike <= 7) then begin
                if Player[PC^.Player].Towns[2] <> 0 then begin
                  for i := 1 to MaxTowns do
                    if Player[PC^.Player].Towns[i] = cnum then
                      n := i;
                  if ike = 6 then dec(n) else inc(n);
                  if n = 0 then
                    for i := 1 to MaxTowns do
                      if Player[PC^.Player].Towns[i] <> 0 then n := i;
                  if Player[PC^.Player].Towns[n] = 0 then n := 1;
                  cnum := Player[PC^.Player].Towns[n];
                  C := @Castle[Player[PC^.Player].Towns[n]];
                  a := Action;
                  SetCastle(C);
                  Action := a;
                  ClearScr;
                  Draw;
                end;
              end else if ike = 8 then begin
                over := true;
              end;
            end;
          end else if (x > cwid) and (x < 637)
                      and (y > 108) and (y < 442) then begin
            case Action of
              caBuy:    begin
                          n := cwid + 6 + 36 + 6 + 21 * 8 + 5;
                          if (x >= n) and (x < n + 44 + 40) and (y >= 118)
                             and (y < 118 + 46 * 6 + 40) then begin
                            y := (y - 118) div 46;
                            x := (x - n) div 44;
                            if y = 0 then begin
                              for n := 6 downto 1 do
                                BuyCastleTroops(cnum, n,
                                                Castle[cnum].AvailableTroops[n],
                                                false);
                              did := true;
                            end else begin
                              if x = 0 then
                                n := 1
                              else
                                n := PC^.AvailableTroops[y];
                              did := BuyCastleTroops(cnum, y, n, false) > 0;
                            end;
                            if did then begin
                              DrawResources;
                              DrawAreaBuy;
                              DrawGarrison;
                              DrawIcons;
                            end;
                          end;
                        end;
              caBuild:  if BuildChoice = 0 then begin
                          if (x >= 306 + 82) and (x < 306 + 82 + 16 + 8 * 19)
                             and (y >= 117 + 20)
                             and (y < 117 + 14 * 20 + 16) then begin
                            BuildChoice := (y - 117) div 20;
                            FindDefaultBuildSpot;
                          end;
                        end else begin
                          if (x >= 338 + 36) and (x < 338 + 36 + 3 * 60 + 40)
                             and (y >= 137) and (y < 137 + 40) then begin
                            x := (x - 338 - 36) div 60;
                            case x of
                              0: RotateFootprint(BuildFP);
                              1: FlipFootprint(BuildFP);
                              2: Build;
                              3: if BuildInCastle(cnum,
                                                  BuildChoice or bPlanned,
                                                  BuildX, BuildY, BuildFP,
                                                  false, false) then
                                   FindDefaultBuildSpot;
                            end;
                            DrawActionArea;
                            DrawCastle;
                            DrawIcons;
                          end;
                        end;
              caTavern: if (x >= cwid + 40) and (x < cwid + 40 + 36)
                           and (y >= 137) and (y < 137 + 83 * 3 + 36)
                           and (((y - 137) mod 83) < 36) then begin
                          n := (y - 137) div 83 + 1;
                          if PlayerDudes(Turn) >= MaxDudes then
                            CastleHint('You already have the maximum '
                                       + 'number of heroes.')
                          else if Player[Turn].Resources[rGold] < 2500 then
                            CastleHint('Heroes cost ' + GoldStr(2500)
                                       + '. You can''t afford one.')
                          else if VisitingHero <> 0 then
                            CastleHint('The visiting hero must leave '
                                       + 'before you can buy a new hero.')
                          else begin
                            h := FindTavernHero(n);
                            if h = 0 then
                              CastleHint('There are no heroes available.')
                            else begin
                              BuyHeroAtCastle(cnum, h);
                              SetHero(h);
                              FindDeadGuys;
                            end;
                            ClearScr;
                            Draw;
                          end;
                        end;
              caMarket: begin
                          FindMarketRate(left, right);
                          t := Player[Turn].Resources[MarketLeft] div left;
                          if InIcon(x, y, cwid + 75, 137 + 80) then begin
                            if MarketLeft = high(TResource) then
                              MarketLeft := low(TResource)
                            else
                              inc(MarketLeft);
                          end else if InIcon(x, y, cwid + 75 + 120,
                                             137 + 80) then begin
                            if MarketRight = high(TResource) then
                              MarketRight := low(TResource)
                            else
                              inc(MarketRight);
                          end else if (y >= 118) and (x >= cwid + 6)
                                      and (y < 118 + 45 + 40) then begin
                            x := (x - (cwid + 6)) div 43;
                            if x <= ord(high(TResource)) then begin
                              if y < 118 + 40 then
                                MarketLeft := TResource(x)
                              else if y >= 118 + 45 then
                                MarketRight := TResource(x);
                            end;
                          end else begin
                            n := 0;
                            if InIcon(x, y, cwid + 75, 137 + 140) then
                              n := 1
                            else if InIcon(x, y, cwid + 75 + 60,
                                           137 + 140) then
                              n := 5
                            else if InIcon(x, y, cwid + 75 + 120,
                                           137 + 140) then
                              n := 10;
                            if (n <> 0) and (n <= t) then begin
                              dec(Player[Turn].Resources[MarketLeft],
                                  n * left);
                              inc(Player[Turn].Resources[MarketRight],
                                  n * right);
                            end;
                          end;
                          DrawActionArea;
                          DrawResources;
                          DrawIcons;
                        end;
            end;
          end else if (x > 2) and (x < cwid)
                      and (y > cwid) and (y < 477) then begin
            if HandleTwoBars(GarrisonBar, HeroBar, E) then begin
              { handled }
            end else if (x >= 56 + 6 * 36 + 5) and (x < 56 + 6 * 36 + 5 + 36)
                        and (y >= 390) and (y < 390 + 40)
                        and (HeroBar <> nil) then begin
              ShareTroops(@Hero^[VisitingHero].army, @Castle[cnum].Garrison,
                          HeroSlots(VisitingHero), 6);
              GarrisonBar^.highlight := 0;
              HeroBar^.highlight := 0;
              DrawGarrison;
            end else if (VisitingHero <> 0) and (x >= HeroX) and (y >= HeroY)
                        and (x < HeroX + 36) and (y < HeroY + 36) then begin
              ShowHeroScreen(VisitingHero, false);
            end;
          end;
        end else if E.Buttons = mbRightButton then begin
          x := E.Where.X;
          y := E.Where.Y;

          if GarrisonBar^.HandleRightClick(E)
             or ((HeroBar <> nil)
                 and (HeroBar^.HandleRightClick(E))) then begin
            Draw;
          end else if (x >= 4) and (y >= 4)
                      and (x <= cwid - 4) and (y <= cwid - 4) then begin
              x := (x - 4) div 40 + 1;
              y := (y - 4) div 40 + 1;
              n := Castle[cnum].Grid[x, y] and bMask;
              if n in [bCreature1..bCreature6] then
                s := MonsterData[MonsterForLevel(PC^.CT, n)].name
                     + ' Dwelling - ' + BuildingHint(n)
              else
                s := BuildingName(n) + ' - ' + BuildingHint(n);
              if (Castle[cnum].Grid[x, y] and bPlanned) <> 0 then begin
                if BaseDialog('Plans for ' + s, dgOK, dgCancel, 0, 0,
                              'Remove it', 'Cancel', '', '') = 1 then
                  RemovePlan(cnum, x, y);
              end else begin
                if Twists[twCastleBuildingsDecay] and (n in bDecays) then begin
                  i := DecayTime(n) - Castle[cnum].Decay[x, y];
                  s := s + ' Decays in ' + IStr(i, 0) + ' turn';
                  if i <> 1 then s := s + 's';
                  s := s + '.';
                end;
                BaseMessage(s);
              end;
              ClearScr;
              Draw;
          end else if (x >= 338 + 36) and (x < 338 + 36 + 60 * 3 + 40)
                      and (y >= 10) and (y < 50 + 10 + 40) then begin
            x := x - 338 - 36;
            y := y - 10;
            if ((x mod 60) < 40) and ((y mod 50) < 40) then begin
              n := (x div 60) + (y div 50) * 4;
              CastleHint(ButtonHint[n]);
            end;
          end else if Action = caSpells then begin
            sp := SpellSetClick(PC^.AvailableSpells, cwid + 40, 149 - 12, x, y);
            if sp <> 0 then
              CastleHint(SpellHintStr(sp, 0, Castle[cnum].player));
          end else if Action = caTavern then begin
            y := (y - 137) div 83 + 1;
            if (y >= 1) and (y <= 4) and (x >= cwid + 40) then
              ShowHeroScreen(FindTavernHero(y), true);
          end else if Action = caBuy then begin
            i := (y - 118) div 46;
            if (x >= cwid + 6) and (x < cwid + 6 + 36 + 6 + 21 * 8)
               and (i >= 1) and (i <= 6) then
              CastleHint(ArmyStatsHint(MonsterForLevel(PC^.CT, i), cwid + 6,
                                       118 + i * 46, x, y, true));
          end else if (Action = caBuild) and (BuildChoice <> 0) then begin
            if (x >= 338 + 36) and (x < 338 + 36 + 36 + 6 + 21 * 8)
               and (y >= 137 + 60 + 32 + 12 + 40)
               and (y < 137 + 60 + 32 + 12 + 40 + 46) then
              CastleHint(ArmyStatsHint(MonsterForLevel(PC^.CT, BuildChoice),
                                       338 + 36, 137 + 60 + 32 + 12 + 40,
                                       x, y, true));
          end;
        end;
      end;
    until over;
  end;

{ unit initialization }

end.
