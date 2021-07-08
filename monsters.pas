unit monsters;

{ monster and army stuff for hommx }

interface

uses Objects, Drivers, LowGr;

const
  MaxSlots = 10;
  NumFlagWords = 6;

type
  TMonster = record
    name: string[18];
    pname: string[18];
    flags, sflags: array [1..NumFlagWords] of word;
    hp: integer;
    dmg: byte;
    speed: byte;
    cost: integer;
  end;

  TArmy = record
    monster: integer;
    qty: integer;
  end;

  PArmySet = ^TArmySet;
  TArmySet = array [1..MaxSlots] of TArmy;

  PArmyBar = ^TArmyBar;
  TArmyBar = object(TObject)
    AS: PArmySet;
    ABX, ABY: integer;
    highlight: integer;
    slots: integer;
    IkesX, IkesY: integer;
    CanDismiss: boolean;
    Dude: integer;
    bend: boolean;
    constructor Init(iABX, iABY: integer; iAS: PArmySet;
                     islots, iIkesX, iIkesY, idude: integer; ibend: boolean);
    destructor Done; virtual;
    procedure Draw;
    procedure DrawIcons;
    function ClickBox(E: TEvent): integer;
    procedure XferFrom(bar: PArmyBar; i1, i2: integer);
    function HandleClick(E: TEvent): boolean;
    function HandleRightClick(E: TEvent): boolean;
    function HandleXferClick(bar: PArmyBar; E: TEvent): boolean;
    procedure Split(how: integer);
  end;

const
  NilArmy: TArmy = (monster: 0; qty: 0);

  moChangedWerewolf = -1;

  moBunny = 1;
  moGiantFrog = 2;
  moMadTurtle = 3;
  moFungus = 4;
  moCarnivorousPlant = 5;
  moKong = 6;
  moShadow = 7;
  moSoulThief = 8;
  moHorror = 9;
  moNecromancer = 10;
  moEvilFog = 11;
  moDeathPuppet = 12;
  moShrinkingMan = 13;
  moWitch = 14;
  moWillOWisp = 15;
  moDancingSword = 16;
  moIllusionist = 17;
  moCloudGiant = 18;
  moUrchin = 19;
  moLookout = 20;
  moSneak = 21;
  moNinja = 22;
  moAssassin = 23;
  moMastermind = 24;
  moRobot = 25;
  moWobbler = 26;
  moWhirly = 27;
  moTransformer = 28;
  moSteamroller = 29;
  moLaser = 30;
  moLabAssistant = 31;
  moPygmyDragon = 32;
  moMimic = 33;
  moBlob = 34;
  moHeadless = 35;
  moMadScientist = 36;
  moScorpion = 37;
  moMummy = 38;
  moVulture = 39;
  moDjinn = 40;
  moGuardian = 41;
  moSlaver = 42;
  moRubberRat = 43;
  moMosquitoCloud = 44;
  moElectricEel = 45;
  moFlyingSlug = 46;
  moTwoHeadedGiant = 47;
  moFireDuiker = 48;
  moMagician = 49;
  moRingmaster = 50;
  moClownCar = 51;
  moLion = 52;
  moElephant = 53;
  moFireEater = 54;
  moAngryVillager = 55;
  moSkulk = 56;
  moPriest = 57;
  moVileDuck = 58;
  moWerewolf = 59;
  moSerpentAngel = 60;

  NumMonsters = 60;
  NumCastleTypes = NumMonsters div 6;

  f1Fly         = $0001;
  f1Jump        = $0002;
  f1Steamroll   = $0004;
  f1Plantport   = $0008;
  f1Range       = $0010;
  f1HighRange   = $0020;
  f1Range1      = $0040;
  f1RangeAll    = $0080;
  f1RangeLine   = $0100;
  f1AoE         = $0200;
  f1Breath1     = $0400;
  f1Breath2     = $0800;
  f1Retaliate   = $1000;
  f1ShortRange  = $2000;
  f1Transform   = $4000;
  f1Hiding      = $8000;

  f1AnyRange    = f1Range or f1HighRange or f1Range1 or f1RangeAll
                  or f1RangeLine or f1ShortRange;
  f1RealRange   = f1Range or f1Range1 or f1RangeAll;

  f2Smash       = $0001;
  f2Flame       = $0002;
  f2AttMoveAtt  = $0004;
  f2Hydra       = $0008;
  f2Throw       = $0010;
  f2RemoveFlags = $0020;
  f2CopyFlags   = $0040;
  f2Push        = $0080;
  f2Stun        = $0100;
  f2Hex         = $0200;
  f2Circle      = $0400;
  f2Devolve     = $0800;
  f2Assassin    = $1000;
  f2Water       = $2000;
  f2SplitYou    = $4000;
  f2TwoHead     = $8000;

  f3RaiseDead   = $0001;
  f3Morale      = $0002;
  f3LikesDamage = $0004;
  f3Spinning    = $0008;
  f3LikesSpells = $0010;
  f3Blink       = $0020;
  f3Split       = $0040;
  f3DeathMana   = $0080;
  f3Enemyport   = $0100;
  f3SlimeTrail  = $0200;
  f3Illusionist = $0400;
  f3Vampire     = $0800;
  f3Regenerate  = $1000;
  f3Bless       = $2000;
  f3Bounce      = $4000;
  f3Lightning   = $8000;

  f4Traitor     = $0001;
  f4Poison      = $0002;
  f4FeedOnDead  = $0004;
  f4Pathfinding = $0008;
  f4Multiplies  = $0010;
  f4Explode     = $0020;
  f4Friendship  = $0040;
  f4Maiming     = $0080;
  f4Spikes      = $0100;
  f4WaterImmune = $0200;
  f4FireImmune  = $0400;
  f4Waterwalking= $0800;
  f4Firewalking = $1000;
  f4FireTrail   = $2000;
  f4FireShield  = $4000;
  f4Curse       = $8000;

  f5DeathMana2  = $0001;
  f5Bewildering = $0002;
  f5OneRetaliate= $0004;
  f5Spikes2     = $0008;
  f5Disease     = $0010;
  f5CopiesSpells= $0020;
  f5MakesGuys   = $0040;
  f5Pull        = $0080;
  f5ThreeAttacks= $0100;
  f5MoveFar     = $0200;
  f5Trample     = $0400;
  f5FireCircle  = $0800;
  f5Friendport  = $1000;
  f5SuperBless  = $2000;
  f5SwitchMove  = $4000;
  f5Werewolf    = $8000;

  f6Healing     = $0001;
  f6Persuasion  = $0002;
  f6RaiseSkulk  = $0004;
  f6Recruit     = $0008;
  f6AttImmune   = $0010;
  f6DefImmune   = $0020;

  FlagMax = 86;

type
  TFlagHelp = array [1..FlagMax] of string[160];
  PFlagHelp = ^TFlagHelp;

  TFlagNames = array [1..FlagMax] of string[21];
  PFlagNames = ^TFlagNames;

const
  MonsterData: array [1..NumMonsters] of TMonster =
  (
    (name:  'Bunny';
     pname: 'Bunnies';
     flags: (f1Jump, 0, 0, f4Multiplies, 0, 0);
     sflags: (f1Jump + f1Breath1, 0, 0, f4Multiplies, 0, 0);
     hp:    9;
     dmg:   4;
     speed: 60;
     cost:  52),
    (name:  'Giant Frog';
     pname: 'Giant Frogs';
     flags: (f1Jump + f1HighRange, 0, 0, 0, 0, 0);
     sflags: (f1Jump + f1HighRange, 0, 0, f4Poison, 0, 0);
     hp:    22;
     dmg:   6;
     speed: 60;
     cost:  110),
    (name:  'Mad Turtle';
     pname: 'Mad Turtles';
     flags: (0, 0, f3Spinning, 0, 0, 0);
     sflags: (f1Hiding, 0, f3Spinning, 0, 0, 0);
     hp:    41;
     dmg:   10;
     speed: 60;
     cost:  200),
    (name:  'Fungus';
     pname: 'Fungi';
     flags: (f1Plantport, 0, 0, 0, 0, 0);
     sflags: (f1Plantport, 0, f3Illusionist, 0, 0, 0);
     hp:    93;
     dmg:   26;
     speed: 50;
     cost:  360),
    (name:  'Carnivorous Plant';
     pname: 'Carnivorous Plants';
     flags: (f1Range, 0, 0, 0, 0, 0);
     sflags: (f1Range, f2Throw, 0, 0, 0, 0);
     hp:    156;
     dmg:   27;
     speed: 0;
     cost:  660),
    (name:  'Kong';
     pname: 'Kongs';
     flags: (0, f2Throw, 0, 0, 0, 0);
     sflags: (f1Fly, f2Throw + f2SplitYou, 0, 0, 0, 0);
     hp:    230;
     dmg:   50;
     speed: 100;
     cost:  1000),
    (name:  'Shadow';
     pname: 'Shadows';
     flags: (f1Fly, 0, f3DeathMana, 0, 0, 0);
     sflags: (f1Fly, 0, 0, 0, f5DeathMana2, 0);
     hp:    10;
     dmg:   5;
     speed: 50;
     cost:  52),
    (name:  'Soul Thief';
     pname: 'Soul Thieves';
     flags: (0, f2RemoveFlags, 0, 0, 0, 0);
     sflags: (0, f2RemoveFlags, 0, f4Multiplies, 0, 0);
     hp:    32;
     dmg:   7;
     speed: 50;
     cost:  100),
    (name:  'Horror';
     pname: 'Horrors';
     flags: (0, 0, f3LikesDamage, 0, 0, 0);
     sflags: (0, 0, f3LikesDamage + f3SlimeTrail, f4WaterImmune + f4Waterwalking, 0, 0);
     hp:    49;
     dmg:   12;
     speed: 60;
     cost:  195),
    (name:  'Necromancer';
     pname: 'Necromancers';
     flags: (f1Range, 0, f3RaiseDead, 0, 0, 0);
     sflags: (f1Range, 0, f3RaiseDead + f3LikesSpells, 0, 0, 0);
     hp:    58;
     dmg:   14;
     speed: 70;
     cost:  370),
    (name:  'Evil Fog';
     pname: 'Evil Fogs';
     flags: (f1Fly, f2Stun, 0, 0, 0, 0);
     sflags: (f1Fly, f2Stun, f3Vampire, 0, 0, 0);
     hp:    140;
     dmg:   34;
     speed: 90;
     cost:  650),
    (name:  'Death Puppet';
     pname: 'Death Puppets';
     flags: (0, 0, f3Morale, 0, 0, 0);
     sflags: (f1Range, 0, f3Morale, 0, 0, 0);
     hp:    216;
     dmg:   71;
     speed: 100;
     cost:  1200),
    (name:  'Shrinking Man';
     pname: 'Shrinking Men';
     flags: (f1Hiding, 0, 0, 0, 0, 0);
     sflags: (f1Hiding, 0, 0, 0, f5OneRetaliate, 0);
     hp:    9;
     dmg:   4;
     speed: 70;
     cost:  62),
    (name:  'Witch';
     pname: 'Witches';
     flags: (f1Range1, f2Hex, 0, 0, 0, 0);
     sflags: (f1Range1, f2Hex, 0, f4Curse, 0, 0);
     hp:    21;
     dmg:   3;
     speed: 60;
     cost:  100),
    (name:  'Will-o-wisp';
     pname: 'Will-o-wisps';
     flags: (f1Fly, 0, f3Blink, 0, 0, 0);
     sflags: (f1Fly, 0, f3Blink + f3Lightning, 0, 0, 0);
     hp:    30;
     dmg:   12;
     speed: 90;
     cost:  210),
    (name:  'Dancing Sword';
     pname: 'Dancing Swords';
     flags: (f1Fly, 0, f3LikesSpells, 0, 0, 0);
     sflags: (f1Fly, 0, f3LikesSpells, f4Maiming, 0, 0);
     hp:    42;
     dmg:   30;
     speed: 80;
     cost:  385),
    (name:  'Illusionist';
     pname: 'Illusionists';
     flags: (f1Range, 0, f3Illusionist, 0, 0, 0);
     sflags: (f1Range, f2RemoveFlags, f3Illusionist, 0, 0, 0);
     hp:    88;
     dmg:   21;
     speed: 80;
     cost:  690),
    (name:  'Cloud Giant';
     pname: 'Cloud Giants';
     flags: (0, f2Smash + f2Hydra, 0, 0, 0, 0);
     sflags: (f1Steamroll, f2Smash + f2Hydra, 0, 0, 0, 0);
     hp:    256;
     dmg:   50;
     speed: 75;
     cost:  1000),
    (name:  'Urchin';
     pname: 'Urchins';
     flags: (0, f2Push, 0, 0, 0, 0);
     sflags: (0, f2Push, 0, f4WaterImmune + f4Waterwalking, 0, 0);
     hp:    8;
     dmg:   5;
     speed: 70;
     cost:  57),
    (name:  'Lookout';
     pname: 'Lookouts';
     flags: (f1Range, 0, 0, f4Pathfinding, 0, 0);
     sflags: (f1Range, f2AttMoveAtt, 0, f4Pathfinding, 0, 0);
     hp:    20;
     dmg:   3;
     speed: 60;
     cost:  104),
    (name:  'Sneak';
     pname: 'Sneaks';
     flags: (0, 0, f3Enemyport, 0, 0, 0);
     sflags: (0, f2Stun, f3Enemyport, 0, 0, 0);
     hp:    32;
     dmg:   12;
     speed: 80;
     cost:  230),
    (name:  'Ninja';
     pname: 'Ninjas';
     flags: (f1Fly, f2Circle, 0, 0, 0, 0);
     sflags: (f1Fly, f2Circle, f3Spinning, 0, 0, 0);
     hp:    60;
     dmg:   23;
     speed: 90;
     cost:  380),
    (name:  'Assassin';
     pname: 'Assassins';
     flags: (0, f2Assassin, 0, 0, 0, 0);
     sflags: (f1RangeLine, f2Assassin, 0, 0, 0, 0);
     hp:    126;
     dmg:   20;
     speed: 75;
     cost:  600),
    (name:  'Mastermind';
     pname: 'Masterminds';
     flags: (f1RangeAll, 0, 0, 0, 0, 0);
     sflags: (f1RangeAll, 0, f3RaiseDead, 0, 0, 0);
     hp:    181;
     dmg:   16;
     speed: 70;
     cost:  1200),
    (name:  'Robot';
     pname: 'Robots';
     flags: (f1RangeLine, 0, 0, 0, 0, 0);
     sflags: (f1RangeLine + f1Range1, 0, 0, 0, 0, 0);
     hp:    13;
     dmg:   4;
     speed: 50;
     cost:  50),
    (name:  'Wobbler';
     pname: 'Wobblers';
     flags: (f1Retaliate, 0, 0, 0, 0, 0);
     sflags: (f1Retaliate, f2Hydra, 0, 0, 0, 0);
     hp:    30;
     dmg:   8;
     speed: 40;
     cost:  103),
    (name:  'Whirly';
     pname: 'Whirlies';
     flags: (f1Fly, f2AttMoveAtt, 0, 0, 0, 0);
     sflags: (f1Fly + f1Retaliate, f2AttMoveAtt, 0, 0, 0, 0);
     hp:    35;
     dmg:   9;
     speed: 80;
     cost:  200),
    (name:  'Transformer';
     pname: 'Transformers';
     flags: (f1Transform, 0, 0, 0, 0, 0);
     sflags: (f1Fly + f1Range, 0, 0, 0, 0, 0);
     hp:    77;
     dmg:   18;
     speed: 80;
     cost:  375),
    (name:  'Steamroller';
     pname: 'Steamrollers';
     flags: (f1Steamroll, 0, 0, 0, 0, 0);
     sflags: (f1Steamroll, f2SplitYou, 0, 0, 0, 0);
     hp:    167;
     dmg:   16;
     speed: 90;
     cost:  665),
    (name:  'Laser';
     pname: 'Lasers';
     flags: (f1Range, f2Flame, 0, 0, 0, 0);
     sflags: (f1Range + f1AoE, f2Flame, 0, 0, 0, 0);
     hp:    200;
     dmg:   43;
     speed: 60;
     cost:  1200),
    (name:  'Lab Assistant';
     pname: 'Lab Assistants';
     flags: (f1Range + f1AoE, 0, 0, 0, 0, 0);
     sflags: (f1Range + f1AoE, f2Water, 0, 0, 0, 0);
     hp:    10;
     dmg:   2;
     speed: 30;
     cost:  80),
    (name:  'Pygmy Dragon';
     pname: 'Pygmy Dragons';
     flags: (f1Fly + f1Breath1, 0, 0, 0, 0, 0);
     sflags: (f1Fly + f1Breath2, 0, 0, 0, 0, 0);
     hp:    20;
     dmg:   5;
     speed: 70;
     cost:  110),
    (name:  'Mimic';
     pname: 'Mimics';
     flags: (0, f2CopyFlags, 0, 0, 0, 0);
     sflags: (0, f2CopyFlags, f3Regenerate, 0, 0, 0);
     hp:    42;
     dmg:   12;
     speed: 70;
     cost:  200),
    (name:  'Blob';
     pname: 'Blobs';
     flags: (0, 0, f3Split, 0, 0, 0);
     sflags: (0, f2CopyFlags, f3Split, 0, 0, 0);
     hp:    100;
     dmg:   32;
     speed: 60;
     cost:  330),
    (name:  'Headless';
     pname: 'Headlesses';
     flags: (0, f2Hydra, 0, 0, 0, 0);
     sflags: (0, f2Hydra, f3Morale, 0, 0, 0);
     hp:    163;
     dmg:   27;
     speed: 80;
     cost:  660),
    (name:  'Mad Scientist';
     pname: 'Mad Scientists';
     flags: (0, f2Devolve, 0, 0, 0, 0);
     sflags: (0, f2Devolve, f3Split, 0, 0, 0);
     hp:    214;
     dmg:   40;
     speed: 100;
     cost:  1000),
    (name:  'Scorpion';
     pname: 'Scorpions';
     flags: (0, 0, 0, f4Poison, 0, 0);
     sflags: (0, 0, 0, f4Poison + f4FireImmune + f4Firewalking + f4Firetrail, 0, 0);
     hp:    9;
     dmg:   4;
     speed: 60;
     cost:  52),
    (name:  'Mummy';
     pname: 'Mummies';
     flags: (0, 0, f3Regenerate, 0, 0, 0);
     sflags: (0, 0, f3Regenerate, f4Curse, 0, 0);
     hp:    25;
     dmg:   10;
     speed: 50;
     cost:  93),
    (name:  'Vulture';
     pname: 'Vultures';
     flags: (f1Fly, 0, 0, f4FeedOnDead, 0, 0);
     sflags: (f1Fly, 0, f3Regenerate, f4FeedOnDead, 0, 0);
     hp:    60;
     dmg:   13;
     speed: 50;
     cost:  200),
    (name:  'Djinn';
     pname: 'Djinns';
     flags: (f1Range, 0, f3Bless, 0, 0, 0);
     sflags: (f1Range, 0, f3Bless, f4FireShield + f4FireImmune, 0, 0);
     hp:    52;
     dmg:   14;
     speed: 80;
     cost:  405),
    (name:  'Guardian';
     pname: 'Guardians';
     flags: (0, 0, 0, 0, f5Friendport, 0);
     sflags: (0, 0, 0, 0, f5Friendport + f5Bewildering, 0);
     hp:    172;
     dmg:   38;
     speed: 70;
     cost:  660),
    (name:  'Slaver';
     pname: 'Slavers';
     flags: (0, 0, 0, f4Traitor, 0, 0);
     sflags: (0, 0, f3LikesDamage, f4Traitor, 0, 0);
     hp:    205;
     dmg:   28;
     speed: 60;
     cost:  1000),
    (name:  'Rubber Rat';
     pname: 'Rubber Rats';
     flags: (0, 0, f3Bounce, 0, 0, 0);
     sflags: (0, 0, f3Bounce, 0, f5Disease, 0);
     hp:    11;
     dmg:   5;
     speed: 60;
     cost:  56),
    (name:  'Mosquito Cloud';
     pname: 'Mosquito Clouds';
     flags: (f1Fly, 0, f3Vampire, 0, 0, 0);
     sflags: (f1Fly, 0, f3Vampire + f3DeathMana, 0, 0, 0);
     hp:    19;
     dmg:   5;
     speed: 70;
     cost:  125),
    (name:  'Electric Eel';
     pname: 'Electric Eels';
     flags: (f1Range, 0, f3Lightning, 0, 0, 0);
     sflags: (f1Range, 0, f3Lightning, f4Friendship, 0, 0);
     hp:    33;
     dmg:   8;
     speed: 70;
     cost:  225),
    (name:  'Flying Slug';
     pname: 'Flying Slugs';
     flags: (f1Fly, f2Water, f3SlimeTrail, 0, 0, 0);
     sflags: (f1Fly + f1HighRange, f2Water, f3SlimeTrail, 0, 0, 0);
     hp:    69;
     dmg:   20;
     speed: 70;
     cost:  360),
    (name:  'Two-headed Giant';
     pname: 'Two-headed Giants';
     flags: (0, f2SplitYou + f2TwoHead, 0, 0, 0, 0);
     sflags: (0, f2SplitYou + f2TwoHead + f2Throw, 0, 0, 0, 0);
     hp:    172;
     dmg:   26;
     speed: 80;
     cost:  600),
    (name:  'Fire Duiker';
     pname: 'Fire Duikers';
     flags: (f1Breath2, 0, 0, f4Explode, 0, 0);
     sflags: (f1Breath2, f2Flame, 0, f4Explode, 0, 0);
     hp:    231;
     dmg:   60;
     speed: 80;
     cost:  1100),
    (name:  'Magician';
     pname: 'Magicians';
     flags: (f1Fly, 0, 0, 0, f5CopiesSpells, 0);
     sflags: (f1Fly, 0, f3Bless, 0, f5CopiesSpells, 0);
     hp:    10;
     dmg:   5;
     speed: 60;
     cost:  65),
    (name:  'Ringmaster';
     pname: 'Ringmasters';
     flags: (f1Range, 0, 0, 0, f5Pull, 0);
     sflags: (f1Range, 0, f3LikesDamage, 0, f5Pull, 0);
     hp:    17;
     dmg:   4;
     speed: 70;
     cost:  117),
    (name:  'Clown Car';
     pname: 'Clown Cars';
     flags: (0, 0, 0, 0, f5MakesGuys, 0);
     sflags: (0, 0, 0, f4Pathfinding, f5MakesGuys, 0);
     hp:    50;
     dmg:   10;
     speed: 70;
     cost:  200),
    (name:  'Lion';
     pname: 'Lions';
     flags: (0, 0, 0, 0, f5ThreeAttacks, 0);
     sflags: (0, f2Circle, 0, 0, f5ThreeAttacks, 0);
     hp:    66;
     dmg:   10;
     speed: 80;
     cost:  360),
    (name:  'Elephant';
     pname: 'Elephants';
     flags: (0, 0, 0, 0, f5Trample + f5MoveFar, 0);
     sflags: (0, f2Stun, 0, 0, f5Trample + f5MoveFar, 0);
     hp:    181;
     dmg:   27;
     speed: 40;
     cost:  660),
    (name:  'Fire-Eater';
     pname: 'Fire-Eaters';
     flags: (0, 0, 0, f4Friendship, f5FireCircle, 0);
     sflags: (f1Hiding, 0, 0, f4Friendship, f5FireCircle, 0);
     hp:    228;
     dmg:   56;
     speed: 70;
     cost:  900),
    (name:  'Angry Villager';
     pname: 'Angry Villagers';
     flags: (f1ShortRange, 0, 0, 0, 0, 0);
     sflags: (f1ShortRange, 0, 0, 0, 0, f6Recruit);
     hp:    10;
     dmg:   3;
     speed: 60;
     cost:  48),
    (name:  'Skulk';
     pname: 'Skulks';
     flags: (0, 0, 0, 0, f5SwitchMove, 0);
     sflags: (0, 0, 0, 0, f5SwitchMove + f5Disease, 0);
     hp:    24;
     dmg:   6;
     speed: 60;
     cost:  107),
    (name:  'Priest';
     pname: 'Priests';
     flags: (0, 0, 0, 0, 0, f6Healing + f6Persuasion);
     sflags: (0, f2RemoveFlags, 0, 0, 0, f6Healing + f6Persuasion);
     hp:    31;
     dmg:   15;
     speed: 80;
     cost:  210),
    (name:  'Vile Duck';
     pname: 'Vile Ducks';
     flags: (f1Fly, 0, 0, f4Curse, 0, 0);
     sflags: (f1Fly, 0, 0, f4Curse, 0, f6RaiseSkulk);
     hp:    53;
     dmg:   35;
     speed: 70;
     cost:  350),
    (name:  'Werewolf';
     pname: 'Werewolves';
     flags: (0, 0, 0, f4Maiming, f5Werewolf, 0);
     sflags: (0, 0, f3Morale, f4Maiming, f5Werewolf, 0);
     hp:    164;
     dmg:   37;
     speed: 80;
     cost:  660),
    (name:  'Serpent Angel';
     pname: 'Serpent Angels';
     flags: (f1Fly, 0, 0, 0, f5SuperBless, 0);
     sflags: (f1Fly, 0, f3Regenerate, 0, f5SuperBless, 0);
     hp:    175;
     dmg:   64;
     speed: 100;
     cost:  1500)
  );

type
  TAltar = record
    name: string[13];
    mo: byte;
    flag: word;
    flagb: byte;
  end;

const
  altCheetah = 6;

  Altars: array [1..12] of TAltar =
  (
    (name:  'Bunny';
     mo:    moBunny;
     flag:  f1Jump;
     flagb: 1),
    (name:  'Shrinking Man';
     mo:    moShrinkingMan;
     flag:  f1Hiding;
     flagb: 1),
    (name:  'Vulture';
     mo:    moVulture;
     flag:  f1Fly;
     flagb: 1),
    (name:  'Pygmy Dragon';
     mo:    moPygmyDragon;
     flag:  f1Breath1;
     flagb: 1),
    (name:  'Robot';
     mo:    moRobot;
     flag:  f1RangeLine;
     flagb: 1),
    (name:  'Cheetah';
     mo:    0;
     flag:  0;
     flagb: 0),
    (name:  'Guardian';
     mo:    moGuardian;
     flag:  f5Friendport;
     flagb: 5),
    (name:  'Fungus';
     mo:    moFungus;
     flag:  f1Plantport;
     flagb: 1),
    (name:  'Wobbler';
     mo:    moWobbler;
     flag:  f1Retaliate;
     flagb: 1),
    (name:  'Headless';
     mo:    moHeadless;
     flag:  f2Hydra;
     flagb: 2),
    (name:  'Laser';
     mo:    moLaser;
     flag:  f2Flame;
     flagb: 2),
    (name:  'Flying Slug';
     mo:    moFlyingSlug;
     flag:  f2Water;
     flagb: 2)
  );

var
  FlagHelp: PFlagHelp;
  FlagNames: PFlagNames;

function MonsterGraphic(m: integer): PGraphic;
function FlagByte(fl: byte): byte;
function FlagBit(fl: byte): word;
function MonsterHasFlag(m, fbyte, fbit: word): boolean;
function DamageVariance(m: integer): integer;
procedure DamageMinMax(m, avg: integer; var min, max: integer;
                       goodluck, badluck: boolean);
function AltarAbilityStr(a: integer): string;
function FindEmptySlot(AS: PArmySet; slots: integer): integer;
function FindMonsterSlot(AS: PArmySet; slots, m: integer): integer;
function FindEmptyOrMonster(AS: PArmySet; slots, m: integer): integer;
function GainMonster(AS: PArmySet; slots, m, q: integer): boolean;
procedure DrawArmy(x, y, c, cd, cdb: integer; a: TArmy; inv: boolean);
procedure DrawArmyBox(x, y, sc, ac, bc: integer; a: TArmy; showzero: boolean);
procedure GetMonsterAbilityStr(m: integer; var s1, s2: string);
procedure DrawArmyStats(x, y: integer; a: TArmy; cost, gpday: longint;
                        bright: boolean);
function ArmyStatsHint(m, x, y, hx, hy: integer; perday: boolean): string;
function MonsterLevel(m: integer): integer;
function MonsterSpellValue(m, qty, sp: integer): integer;
function FlagBitToNum(flagb: byte; flag: word): integer;
function CountMonsters(AS: PArmySet; slots, m: integer): integer;
function MonsterAmtString(qty: integer; eye: boolean): string;
function MonsterAmtHintStr(qty: integer): string;
function MonsterDescription(m, q: integer; adj: string; eye: boolean): string;
function ArmyGP(a: TArmy): longint;
function ArmySetGP(AS: PArmySet): longint;
function BestStack(AS: PArmySet; sl: integer): integer;
function WorstStack(AS: PArmySet; sl: integer): integer;
procedure ConserveSlots(AS: PArmySet; sl: integer);
procedure ShareTroops(AS1, AS2: PArmySet; sl1, sl2: integer);
function ArmySharingValue(AS1, AS2: PArmySet; sl1, sl2: integer): longint;

function HandleTwoBars(bar1, bar2: PArmyBar; E: TEvent): boolean;

implementation

uses XStrings, Spells, XFace, Options, Heroes, Rez;

type
  TMonsterGraphics = array [1..NumMonsters] of TGraphic;
  PMonsterGraphics = ^TMonsterGraphics;

var
  MonsterGraphics: PMonsterGraphics;

procedure LoadMonsterGraphics;
  var f: file;
  begin
    assign(f, 'monster.pic');
    reset(f, 1);
    blockread(f, MonsterGraphics^, sizeof(MonsterGraphics^));
    close(f);
  end;

function MonsterGraphic(m: integer): PGraphic;
  const
    ChangedWerewolf: TGraphic =
    ('......***.', { werewolf #2 }
     '.....*** *',
     '.....*****',
     '....****  ',
     '*..*******',
     '*.*****...',
     '.******...',
     '.***..*...',
     '*.*....*..',
     '*..*......');
  begin
    if m = moChangedWerewolf then
      MonsterGraphic := @ChangedWerewolf
    else
      MonsterGraphic := @MonsterGraphics^[m];
  end;

function FlagByte(fl: byte): byte;
  begin
    FlagByte := ((fl - 1) div 16) + 1;
  end;

function FlagBit(fl: byte): word;
  begin
    FlagBit := 1 shl ((fl - 1) mod 16);
  end;

function MonsterHasFlag(m, fbyte, fbit: word): boolean;
  var mhf: boolean;
  begin
    if Twists[twMonstersHaveAbility]
       and (FlagByte(AllMonstersAbility) = fbyte)
       and (FlagBit(AllMonstersAbility) = fbit) then
      mhf := true
    else
      mhf := (MonsterData[m].Flags[fbyte] and fbit) <> 0;

    MonsterHasFlag := mhf;
  end;

function DamageVariance(m: integer): integer;
  const
    variance: array [1..6] of byte =
    (
      1, 2, 3, 4, 6, 8
    );
  begin
    DamageVariance := variance[((m - 1) mod 6) + 1];
  end;

procedure DamageMinMax(m, avg: integer; var min, max: integer;
                       goodluck, badluck: boolean);
  var dv: integer;
  begin
    dv := DamageVariance(m);
    min := avg - dv;
    max := avg + dv;

    if goodluck then min := max;
    if badluck then max := min;

    if min < 1 then min := 1;
    if max < min then max := min;
  end;

function AltarAbilityStr(a: integer): string;
  var s: string;
  begin
    if Altars[a].flag = 0 then
      s := '+1 speed'
    else
      s := FlagNames^[FlagBitToNum(Altars[a].flagb, Altars[a].flag)];
    AltarAbilityStr := s;
  end;

procedure DrawArmy(x, y, c, cd, cdb: integer; a: TArmy; inv: boolean);
  var s: string;
  begin
    DrawGraphic(x + 3, y + 2, c, MonsterGraphic(a.monster)^, inv);
    if cdb <> colInvisible then
      DrawSmallNumberBox(x + 17, y + 34 - 1, cdb, a.qty);
    if cd = colInvisible then
      DrawSmallNumberStr(x + 17, y + 34 - 1, colWhite,
                         MonsterAmtHintStr(a.qty))
    else
      DrawSmallNumber(x + 17, y + 34 - 1, cd, a.qty);
  end;

procedure DrawArmyBox(x, y, sc, ac, bc: integer; a: TArmy; showzero: boolean);
  begin
    XRectangle(x, y, x + 35, y + 39, sc);
    XFillArea(x + 1, y + 1, x + 34, y + 38, colDarkGray);
    if showzero or (a.qty > 0) then
      DrawArmy(x, y, ac, bc, colInvisible, a, false);
  end;

procedure GetMonsterAbilityNums(m: integer; var a1, a2: integer);
  var k: integer;

  procedure AddNum(n: integer);
    begin
      if a1 = 0 then a1 := n else a2 := n;
    end;

  begin
    a1 := 0;
    a2 := 0;

    for k := 1 to FlagMax do
      if (MonsterData[m].Flags[FlagByte(k)] and FlagBit(k)) <> 0 then
        AddNum(k);
  end;

procedure GetMonsterAbilityStr(m: integer; var s1, s2: string);
  var a1, a2: integer;
  begin
    GetMonsterAbilityNums(m, a1, a2);
    if a1 <> 0 then s1 := FlagNames^[a1] else s1 := '';
    if a2 <> 0 then s2 := FlagNames^[a2] else s2 := '';
  end;

procedure DrawArmyStats(x, y: integer; a: TArmy; cost, gpday: longint;
                        bright: boolean);
  const
    colors: array [boolean, 1..4] of byte =
    (
      (colBlack, colDarkGray, colBrown, colBlack),
      (colFriend, colLightGray, colYellow, colWhite)
    );
  var
    s1, s2, space: string;
    r: real;
  begin
    DrawArmyBox(x, y, colLightGray, colors[bright, 1], colors[bright, 4], a,
                true);

    GetMonsterAbilityStr(a.monster, s1, s2);
    DrawText(x + 36 + 6, y +  1, colBlack, colors[bright, 2], s1);
    DrawText(x + 36 + 6, y + 11, colBlack, colors[bright, 2], s2);
    if MonsterData[a.monster].hp >= 100 then
      space := ' '
    else
      space := '  ';
    DrawText(x + 36 + 6, y + 21, colBlack, colors[bright, 2],
              IStr(MonsterData[a.monster].hp, 0) + ' hp' + space
              + IStr(MonsterData[a.monster].dmg, 0) + ' dmg' + space
              + IStr(MonsterData[a.monster].speed div 10, 0)
              + '.' + IStr(MonsterData[a.monster].speed mod 10, 0) + ' sp');
    s1 := IStr(cost, 0) + ' gp';
    if gpday <> 0 then begin
      r := ((gpday * 10) div MonsterData[a.monster].cost) / 10;
      s1 := s1 + '  ' + RStr(r, 0, 0) + '/day';
    end;
    DrawText(x + 36 + 6, y + 31, colBlack, colors[bright, 3], s1);
  end;

function ArmyStatsHint(m, x, y, hx, hy: integer; perday: boolean): string;
  var
    ash: string;
    a1, a2: integer;
  begin
    ash := '';
    GetMonsterAbilityNums(m, a1, a2);

    if (hx >= x + 36 + 6) and (hx < x + 36 + 6 + 21 * 8) then begin
      if (a1 <> 0) and (hy >= y + 1) and (hy < y + 1 + 8) then
        ash := FlagHelp^[a1]
      else if (a2 <> 0) and (hy >= y + 11) and (hy < y + 11 + 8) then
        ash := FlagHelp^[a2]
      else if (hy >= y + 21) and (hy < y + 21 + 8) then
        ash := 'hp = hit points per monster (the damage it can take before '
               + 'dying). dmg = damage dealt per monster. sp = speed and '
               + 'how many hexes this monster moves.'
      else if (hy >= y + 31) and (hy < y + 31 + 8) then begin
        ash := 'gp = gold piece cost per monster ( ' + crGold + ').';
        if perday then
          ash := ash + ' x_/_day_=_how many monsters the castle produces '
                 + 'each day.';
      end;
    end;

    ArmyStatsHint := ash;
  end;

function FindEmptySlot(AS: PArmySet; slots: integer): integer;
  var i, slot: integer;
  begin
    slot := 0;
    for i := slots downto 1 do
      if AS^[i].qty = 0 then
        slot := i;
    FindEmptySlot := slot;
  end;

function FindMonsterSlot(AS: PArmySet; slots, m: integer): integer;
  var i, slot: integer;
  begin
    slot := 0;
    for i := slots downto 1 do
      if (AS^[i].qty > 0) and (AS^[i].monster = m) then
        slot := i;
    FindMonsterSlot := slot;
  end;

function FindEmptyOrMonster(AS: PArmySet; slots, m: integer): integer;
  var slot: integer;
  begin
    slot := FindMonsterSlot(AS, slots, m);
    if slot = 0 then
      slot := FindEmptySlot(AS, slots);
    FindEmptyOrMonster := slot;
  end;

function GainMonster(AS: PArmySet; slots, m, q: integer): boolean;
  var slot: integer;
  begin
    slot := FindEmptyOrMonster(AS, slots, m);

    if slot > 0 then begin
      if AS^[slot].qty > 0 then
        inc(AS^[slot].qty, q)
      else begin
        AS^[slot].qty := q;
        AS^[slot].monster := m;
      end;
    end;

    GainMonster := slot > 0;
  end;

function MonsterLevel(m: integer): integer;
  begin
    MonsterLevel := ((m - 1) mod 6) + 1;
  end;

function MonsterSpellValue(m, qty, sp: integer): integer;
  var power, witch: integer;
  begin
    power := 1 + qty * longint(MonsterData[m].cost) div 1800;
    witch := power;
    if witch > 4 then witch := 4;
    MonsterSpellValue := SpellPowerValue(sp, power, witch);
  end;

function FlagBitToNum(flagb: byte; flag: word): integer;
  var k, fb: integer;
  begin
    fb := 0;

    for k := 1 to FlagMax do
      if (FlagByte(k) = flagb) and (FlagBit(k) = flag) then
        fb := k;

    FlagBitToNum := fb;
  end;

function CountMonsters(AS: PArmySet; slots, m: integer): integer;
  var i, cm: integer;
  begin
    cm := 0;

    for i := 1 to slots do
      if AS^[i].monster = m then
        inc(cm, AS^[i].qty);

    CountMonsters := cm;
  end;

const
  MonsterAmt: array [1..10] of integer =
  (
    6, 11, 21, 41, 71, 101, 201, 401, 701, 1001
  );

{
  group mess company number mass myriad sundry heaps-of

  band party gang crew troop crowd squad
  multitude host army panoply mob
  flock cluster colony herd drove bevy
  clump collection body assortment gathering plague
  abundance plentiful innumerable handful
  slew scads gobs
}

function MonsterAmtString(qty: integer; eye: boolean): string;
  const
    MonsterAmtNames: array [1..11] of string[12] =
    (
      'a couple of',  { 1-5 }
      'hardly any',   { 6-10 }
      'some',         { 11-20 }
      'a bunch of',   { 21-40 }
      'quite a few',  { 41-70 }
      'many',         { 71-100 }
      'plenty of',    { 101-200 }
      'scores of',    { 201-400 }
      'oodles of',    { 401-700 }
      'a sea of',     { 701-1000 }
      'countless'     { 1000+ }
    );
  var
    i: integer;
    s: string;
  begin
    if eye then
      s := IStr(qty, 0)
    else begin
      s := MonsterAmtNames[1];
      for i := 1 to high(MonsterAmt) do
        if qty >= MonsterAmt[i] then
          s := MonsterAmtNames[i + 1];
    end;

    MonsterAmtString := s;
  end;

function MonsterAmtHintStr(qty: integer): string;
  var
    i: integer;
    s: string;
  begin
    if qty > MonsterAmt[8] then
      s := IStr(MonsterAmt[8], 0) + '+'
    else
      s := '1-' + IStr(MonsterAmt[1] - 1, 0);
    for i := 1 to high(MonsterAmt) - 1 do
      if qty >= MonsterAmt[i] then
        s := IStr(MonsterAmt[i], 0) + '-' + IStr(MonsterAmt[i + 1] - 1, 0);
    MonsterAmtHintStr := s;
  end;

function MonsterDescription(m, q: integer; adj: string; eye: boolean): string;
  var
    s: string;
    k: integer;
  begin
    s := MonsterAmtString(q, eye);
    if adj <> '' then s := s + ' ' + adj;
    s := s + ' ' + MonsterData[m].pname + chr(colLightGray) + ' (';
    if not eye then
      s := s + MonsterAmtHintStr(q) + ', ';
    s := s + 'level_' + IStr((((m) - 1) mod 6) + 1, 0) + ', '
         + IStr(MonsterData[m].hp, 0) + '_hp, '
         + IStr(MonsterData[m].dmg, 0) + '_dmg, '
         + IStr(MonsterData[m].speed div 10, 0) + '.'
         + IStr(MonsterData[m].speed mod 10, 0) + '_sp';

    for k := 1 to FlagMax do
      if MonsterHasFlag(m, FlagByte(k), FlagBit(k)) then
        s := s + ', ' + FlagNames^[k];

    s := s + ')';
    s[1] := UpCase(s[1]);

    MonsterDescription := s;
  end;

function ArmyGP(a: TArmy): longint;
  begin
    if a.qty = 0 then
      ArmyGP := 0
    else
      ArmyGP := longint(a.qty) * MonsterData[a.monster].cost;
  end;

function ArmySetGP(AS: PArmySet): longint;
  var
    i: integer;
    av: longint;
  begin
    av := 0;

    for i := 1 to MaxSlots do inc(av, ArmyGP(AS^[i]));

    ArmySetGP := av;
  end;

function BestStack(AS: PArmySet; sl: integer): integer;
  var
    i, besti: integer;
    bestscore, score: longint;
  begin
    besti := 0;
    bestscore := 0;

    for i := 1 to sl do begin
      score := ArmyGP(AS^[i]);
      if score > bestscore then begin
        besti := i;
        bestscore := score;
      end;
    end;

    BestStack := besti;
  end;

function WorstStack(AS: PArmySet; sl: integer): integer;
  var
    i, besti: integer;
    bestscore, score: longint;
  begin
    besti := 0;
    bestscore := MaxLongInt;

    for i := 1 to sl do begin
      score := ArmyGP(AS^[i]);
      if score < bestscore then begin
        besti := i;
        bestscore := score;
      end;
    end;

    WorstStack := besti;
  end;

procedure ConserveSlots(AS: PArmySet; sl: integer);
  var i, j, m: integer;
  begin
    for i := 1 to sl - 1 do
      if AS^[i].qty > 0 then begin
        m := AS^[i].monster;
        for j := i + 1 to sl do
          if (AS^[j].qty > 0) and (AS^[j].monster = m) then begin
            inc(AS^[i].qty, AS^[j].qty);
            AS^[j].qty := 0;
          end;
      end;
  end;

procedure ShareTroops(AS1, AS2: PArmySet; sl1, sl2: integer);
  var
    i, j, m, worst, best: integer;
    switch: boolean;
    a: TArmy;
  begin
    ConserveSlots(AS1, sl1);
    ConserveSlots(AS2, sl2);

    for i := 1 to sl1 do
      if AS1^[i].qty > 0 then begin
        m := AS1^[i].monster;
        for j := 1 to sl2 do
          if (AS2^[j].qty > 0) and (AS2^[j].monster = m) then begin
            inc(AS1^[i].qty, AS2^[j].qty);
            AS2^[j].qty := 0;
          end;
      end;

    repeat
      worst := WorstStack(AS1, sl1);
      best := BestStack(AS2, sl2);
      switch := (worst > 0) and (best > 0)
                and (ArmyGP(AS1^[worst]) < ArmyGP(AS2^[best]));
      if switch then begin
        a := AS1^[worst];
        AS1^[worst] := AS2^[best];
        AS2^[best] := a;
      end;
    until not switch;
  end;

function ArmySharingValue(AS1, AS2: PArmySet; sl1, sl2: integer): longint;
  var
    av: longint;
    A1, A2: TArmySet;
  begin
    av := ArmySetGP(AS1);
    A1 := AS1^;
    A2 := AS2^;
    ShareTroops(@A1, @A2, sl1, sl2);
    ArmySharingValue := ArmySetGP(@A1) - av;
  end;

{ TArmyBar methods }

const
  abSplit1 = 1;
  abSplitHalf = 2;
  abSplitAll = 3;
  abSplitGone = 4;

constructor TArmyBar.Init(iABX, iABY: integer; iAS: PArmySet;
                          islots, iIkesX, iIkesY, iDude: integer;
                          ibend: boolean);
  begin
    TObject.Init;

    ABX := iABX;
    ABY := iABY;
    AS := iAS;
    highlight := 0;
    slots := islots;
    IkesX := iIkesX;
    IkesY := iIkesY;
    CanDismiss := false;
    Dude := iDude;
    bend := ibend;
  end;

destructor TArmyBar.Done;
  begin
    TObject.Done;
  end;

procedure TArmyBar.Draw;
  var i, x, y, sc: integer;
  begin
    for i := 1 to slots do begin
      if highlight = i then
        sc := colWhite
      else
        sc := colLightGray;
      if (i = 10) and bend then begin
        x := ABX;
        y := ABY - 40;
      end else begin
        x := ABX + (i - 1) * 36;
        y := ABY;
      end;
      DrawArmyBox(x, y, sc, colFriend, colWhite, AS^[i], false);
    end;

    DrawIcons;
  end;

procedure TArmyBar.DrawIcons;
  const
    ArmyBarGraphics: array [1..4] of TGraphic =
    (
      ('....*.....', { split 1 }
       '....*.....',
       '***.*.....',
       '***.*..*..',
       '.*..*.**..',
       '***.*..*..',
       '.*..*..*..',
       '*.*.*.***.',
       '....*.....',
       '....*.....'),
      ('....*.....', { split half }
       '....*.....',
       '***.*.***.',
       '***.*.***.',
       '.*..*..*..',
       '***.*.***.',
       '.*..*..*..',
       '*.*.*.*.*.',
       '....*.....',
       '....*.....'),
      ('....*.....', { split all }
       '....*.....',
       '***.*.....',
       '***.*.*..*',
       '.*..*.**.*',
       '***.*.*.**',
       '.*..*.*..*',
       '*.*.*.*..*',
       '....*.....',
       '....*.....'),
      ('...***....', { dismiss }
       '..*   *...',
       '.*     *..',
       '.*     *..',
       '.* *** *..',
       '.*     *..',
       '.* *** *..',
       '.*     *..',
       '.*     *..',
       '.*******..')
    );
  var i: integer;
  begin
    for i := 0 to 3 do
      if (i = 3) and CanDismiss then
        DrawIcon2c(IkesX + i * 60, IkesY, colRed, colBlack,
                   @ArmyBarGraphics[i + 1])
      else
        DrawIcon(IkesX + i * 60, IkesY, @ArmyBarGraphics[i + 1]);
  end;

function TArmyBar.ClickBox(E: TEvent): integer;
  var i: integer;
  begin
    if bend and (E.Where.X >= ABX) and (E.Where.X < ABX + 36)
       and (E.Where.Y >= ABY - 40) and (E.Where.Y < ABY) then
      i := 10
    else if (E.Where.X >= ABX) and (E.Where.X < ABX + 36 * slots)
            and (E.Where.Y >= ABY) and (E.Where.Y < ABY + 40) then
      i := ((E.Where.X - ABX) div 36) + 1
    else
      i := -1;

    ClickBox := i;
  end;

procedure TArmyBar.XferFrom(bar: PArmyBar; i1, i2: integer);
  var a: TArmy;
  begin
    if AS^[i2].qty = 0 then begin
      AS^[i2] := bar^.AS^[i1];
      bar^.AS^[i1] := NilArmy;
    end else if AS^[i2].monster = bar^.AS^[i1].monster then begin
      inc(AS^[i2].qty, bar^.AS^[i1].qty);
      bar^.AS^[i1] := NilArmy;
    end else begin
      a := AS^[i2];
      AS^[i2] := bar^.AS^[i1];
      bar^.AS^[i1] := a;
    end;
    bar^.highlight := 0;
  end;

function TArmyBar.HandleClick(E: TEvent): boolean;
  var
    i: integer;
    did: boolean;
  begin
    did := false;

    i := ClickBox(E);
    if i <> -1 then begin
      if highlight = 0 then begin
        if AS^[i].qty > 0 then
          highlight := i;
      end else begin
        if i = highlight then
          highlight := 0
        else
          XferFrom(@self, highlight, i);
      end;
      CanDismiss := false;
      Draw;
      did := true;
    end else if (E.Where.x >= IkesX) and (E.Where.x < IkesX + 3 * 60 + 40)
                and (E.Where.y >= IkesY) and (E.Where.y < IkesY + 40)
                and (highlight <> 0) then begin
      Split((E.Where.x - IkesX) div 60 + 1);
      did := true;
    end;

    HandleClick := did;
  end;

function TArmyBar.HandleRightClick(E: TEvent): boolean;
  var
    i, m, k: integer;
    did: boolean;
    s: string;
    ms: TMonster;
  begin
    did := false;

    i := ClickBox(E);
    if i <> -1 then begin
      if AS^[i].qty > 0 then begin
        m := AS^[i].monster;
        GetHeroMonsterStats(Dude, m, ms, false);
        s := IStr(AS^[i].qty, 0) + ' ';
        if AS^[i].qty = 1 then
          s := s + ms.name
        else
          s := s + ms.pname;
        s := s + chr(colLightGray) + ' (level ' + IStr(((m - 1) mod 6) + 1, 0);

        for k := 1 to FlagMax do
          if (ms.Flags[FlagByte(k)] and FlagBit(k)) <> 0 then
            s := s + ', ' + FlagNames^[k];

        s := s + '; ' + IStr(ms.hp, 0) + '_hit_points, '
             + IStr(ms.dmg, 0) + '_damage, '
             + IStr(ms.speed div 10, 0)
             + '.' + IStr(ms.speed mod 10, 0) + '_speed)';
        BaseMessage(s);
        did := true;
      end;
    end else if (E.Where.x >= IkesX) and (E.Where.x < IkesX + 3 * 60 + 40)
                and (E.Where.y >= IkesY)
                and (E.Where.y < IkesY + 40) then begin
      case (E.Where.x - IkesX) div 60 + 1 of
        abSplit1:    BaseMessage('Split off one troop from a stack.');
        abSplitHalf: BaseMessage('Split a stack into two stacks.');
        abSplitAll:  BaseMessage('Divide a stack among all available slots.');
        abSplitGone: BaseMessage('Dismiss a stack (click twice).');
      end;
      did := true;
    end;

    if did then ClearScr;

    HandleRightClick := did;
  end;

function TArmyBar.HandleXferClick(bar: PArmyBar; E: TEvent): boolean;
  var
    i: integer;
    a: TArmy;
  begin
    i := ClickBox(E);
    if i <> -1 then begin
      XferFrom(bar, bar^.highlight, i);
      CanDismiss := false;
      bar^.CanDismiss := false;
      Draw;
      bar^.Draw;
    end;
    HandleXferClick := i <> -1;
  end;

procedure TArmyBar.Split(how: integer);
  var slot, i, num, q, n, aq: integer;
  begin
    slot := FindEmptySlot(AS, slots);

    if (highlight <> 0) and (((AS^[highlight].qty > 1) and (slot <> 0))
                            or (how = abSplitGone)
                            or (how = abSplitAll)) then begin
      case how of
        abSplit1:    begin
                       AS^[slot].monster := AS^[highlight].monster;
                       AS^[slot].qty := 1;
                       dec(AS^[highlight].qty);
                       if FindEmptySlot(AS, slots) = 0 then
                         highlight := 0;
                     end;
        abSplitHalf: begin
                       AS^[slot].monster := AS^[highlight].monster;
                       AS^[slot].qty := AS^[highlight].qty div 2;
                       AS^[highlight].qty := (AS^[highlight].qty + 1) div 2;
                       highlight := 0;
                     end;
        abSplitAll:  begin
                       for i := 1 to slots do
                         if (AS^[i].qty > 0)
                            and (AS^[i].monster = AS^[highlight].monster)
                            and (i <> highlight) then begin
                           inc(AS^[highlight].qty, AS^[i].qty);
                           AS^[i].qty := 0;
                         end;
                       num := 1;
                       for i := 1 to slots do
                         if AS^[i].qty = 0 then inc(num);
                       n := 0;
                       aq := AS^[highlight].qty;
                       for i := 1 to slots do
                         if AS^[i].qty = 0 then begin
                           AS^[i].monster := AS^[highlight].monster;
                           q := (aq + n) div num;
                           AS^[i].qty := q;
                           dec(AS^[highlight].qty, q);
                           inc(n);
                         end;
                       highlight := 0;
                     end;
        abSplitGone: begin
                       if CanDismiss then begin
                         AS^[highlight] := NilArmy;
                         highlight := 0;
                         CanDismiss := false;
                       end else begin
                         CanDismiss := true;
                       end;
                     end;
      end;

      if how <> abSplitGone then
        CanDismiss := false;

      Draw;
    end;
  end;

function HandleTwoBars(bar1, bar2: PArmyBar; E: TEvent): boolean;
  var
    ActiveBar: PArmyBar;
    did: boolean;
  begin
    if bar1^.highlight <> 0 then
      ActiveBar := bar1
    else if (bar2 <> nil) and (bar2^.highlight <> 0) then
      ActiveBar := bar2
    else
      ActiveBar := nil;

    if ActiveBar = nil then begin
      did := bar1^.HandleClick(E);
      if not did and (bar2 <> nil) then
        did := bar2^.HandleClick(E);
    end else begin
      did := ActiveBar^.HandleClick(E);
      if not did and (bar2 <> nil) then begin
        if bar1^.highlight <> 0 then
          did := bar2^.HandleXferClick(bar1, E)
        else if bar2^.highlight <> 0 then
          did := bar1^.HandleXferClick(bar2, E);
      end;
    end;

    HandleTwoBars := did;
  end;

{ unit initialization }

begin
  New(MonsterGraphics);
  LoadMonsterGraphics;
end.
