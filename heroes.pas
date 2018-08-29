unit heroes;

{ heroes for hommx }

interface

uses Objects, XStrings, LowGr, Spells, Monsters, Castles, Artifact, Map;

const
  skPower = 1;
  skHealing = 2;
  skSpellcraft = 3;
  skOffense = 4;
  skDefense = 5;
  skArchery = 6;
  skPathfinding = 7;
  skPersuasion = 8;
  skSummoning = 9;
  skDarkArts = 10;
  skWarcraft = 11;
  skConjuring = 12;

  skSorcery = 13;
  skWitchcraft = 14;
  skTactics = 15;
  skCunning = 16;
  skLore = 17;
  skWizardry = 18;
  skAlchemy = 19;
  skGating = 20;
  skLeadership = 21;
  skSpecialty = 22;
  skExpertise = 23;
  skInsight = 24;

  NumNSkills = 12;
  NumSkills = 24;

  SkillNames: array [1..NumSkills] of string[12] =
  (
    'Power',
    'Healing',
    'Spellcraft',
    'Offense',
    'Defense',
    'Archery',
    'Pathfinding',
    'Persuasion',
    'Summoning',
    'Dark Arts',
    'Warcraft',
    'Conjuring',
    'Sorcery',
    'Witchcraft',
    'Tactics',
    'Cunning',
    'Lore',
    'Wizardry',
    'Alchemy',
    'Gating',
    'Leadership',
    'Specialty',
    'Expertise',
    'Insight'
  );

  NumHeroes = (ord(high(TCastleType)) + 1) * 14;

  EquipSlot: array [1..19] of byte =
  (
    slRing, slRing,
    slWeapon, slWeapon,
    slArmor, slArmor,
    slBoots,
    slNecklace, slNecklace,
    slTool, slTool,
    slGear, slGear, slGear, slGear,
    slGear, slGear, slGear, slGear
  );

  BackpackSize = 30;

  hvMonument = $01;
  hvSchool   = $02;
  hvSageHut  = $04;

  PersuasionAmt = 600;
  HealingAmt = 400;
  GatingGP = 300;
  ConjuringGP = 700;
  SummoningGP = 200;
  WarcraftGP = 66;

  Nth: array [1..6] of string[3] = ('1st', '2nd', '3rd', '4th', '5th', '6th');

  SpecialtyBoost: array [1..4] of integer = (1, 2, 2, 2);

type
  THermitBonus = (hbNone, hbEye, hbWrecker, hbKiller, hbMystic);

  PHero = ^THero;
  THero = record
    Name: string[21];
    ct: TCastleType;
    player: integer;
    level: integer;
    XP: longint; { experience points }
    SP: integer; { spell points }
    MP: integer; { movement points }
    Skill: array [1..10] of byte;
    SkillLevel: array [1..10] of byte;
    army: TArmySet;
    MapX, MapY: integer;
    DestX, DestY: integer;
    SS: TSpellSet;
    FacingLeft: boolean;
    Equipped: array [1..19] of byte;
    Backpack: array [1..BackpackSize] of byte;
    Visited: array [1..MapGeoSize, 1..MapGeoSize] of byte;
    MiningRez: integer;
    SummoningAmt, GatingAmt: longint;
    RingWitches, RingDjinns: integer;
    LastAlchemy: byte;
    AlchemyDay: byte;
    AltarBonus: byte;
    AltarDays: byte;
    ShrineBonus: byte;
    ShrineDays: byte;
    LoreArtFraction, AlchemyArtFraction, TransformArtFraction: byte;
    MassSummonArtFraction, EvocationLevel: byte;
    Dead: boolean;
    DeathMana: integer;
    HermitBonus: THermitBonus;
    Specialty: byte;
    SummonedCr: byte;
    Expertise: byte;
    ExpertiseArtDay: byte;
  end;

  PHeroScr = ^THeroScr;
  THeroScr = object(TObject)
    HeroNum: integer;
    NextHero, PrevHero: integer;
    Bar: PArmyBar;
    ArtNum: integer;
    ArtEq: boolean;
    ArtOfs: integer;
    JustThisHero: boolean;
    constructor Init(iHeroNum: integer; iJustThisHero: boolean);
    destructor Done; virtual;
    procedure SetHero(h: integer);
    procedure GetArtXY(num: integer; eq: boolean; var x, y: integer);
    function ArtPtr(num: integer; eq: boolean): PByte;
    procedure DrawArts;
    procedure Draw;
    procedure HandleUsedArt(a: integer);
    procedure Handle;
  end;

  THeroTalkRec = record
    HeroNum: integer;
    Bar: PArmyBar;
    ArtOfs: integer;
  end;

  PHeroTalkScr = ^THeroTalkScr;
  THeroTalkScr = object(TObject)
    HTR: array [1..2] of THeroTalkRec;
    ArtNum, ArtSide: integer;
    constructor Init(iHero1, iHero2: integer);
    destructor Done; virtual;
    procedure DrawArts;
    procedure Draw;
    procedure Handle;
  end;

  THeroes = array [1..NumHeroes] of THero;
  PHeroes = ^THeroes;

  TSkillChoices = array [1..5] of integer;

var
  Hero: PHeroes;

procedure DrawHero(x, y, c, n: integer);
function HeroFirstSpell(h: integer): integer;
procedure DrawHeroInfo(x, y, h: integer);
function HeroMonsterHasFlag(h, m, fbyte, fbit: word): boolean;
procedure GetHeroMonsterStats(h, mons: integer; var ms: TMonster;
                              incombat: boolean);
procedure SpreadOut(h: integer; wayout: boolean);
function HeroMaxSP(h: integer): integer;
function NumTroopsWithFlag(h: integer; fb: byte; fbit: word): longint;
function HeroMaxMP(h: integer): integer;
procedure LimitMana(h: integer);
procedure GiveMana(h, amt: integer);
procedure GiveDeathMana(h: integer; amt: longint);
function EquipArt(h, art: integer): boolean;
function PackArt(h, art: integer): boolean;
function GainArt(h, art: integer): boolean;
function HasArt(h, art: integer; eq: boolean): boolean;
function CountArt(h, art: integer; eq: boolean): integer;
procedure LoseArt(h, art: integer);
procedure SortBackpack(h: integer);
function CountAllArts(h: integer): integer;
function GetVisited(h, x, y, hv: integer): boolean;
procedure SetVisited(h, x, y, hv: integer);
procedure PickSpecialty(h: integer);
procedure PickExpertise(h: integer);
function GetSkillLevel(h, sk: integer): integer;
function SkillHasInsight(h, sk: integer): boolean;
function GetEffSkillLevel(h, sk: integer): integer;
function HeroHasExpertiseBonus(h, sk: integer): boolean;
function CanGainSkillLevel(h, sk: integer): boolean;
function GainSkillLevel(h, sk: integer): boolean;
function XPForLevel(lev: integer): longint;
function XPAfterCunning(h: integer; x: longint): longint;
function NeededXPStr(h: integer): string;
function HeroSlots(h: integer): integer;
function EquipSlots(h: integer): integer;
function HeroSpellValue(h, sp: integer): integer;
function HeroSpellDur(h, sp: integer): integer;
function EffSpellCost(h, sp: integer): integer;
function HeroDailySP(h: integer): integer;
function HeroSPPerRound(h: integer): integer;
procedure HeroDailyUpgrading(h, lev, qty: integer);
function HeroAtSpot(x, y: integer): integer;
function ExpertiseBonusStr(h, sk: integer): string;
function SkillHint(h, sk, lev: integer): string;
function SkillStr(h, sk, plus: integer): string;
procedure KillHero(h: integer);
procedure TakeArts(h1, h2: integer);
procedure WearBestArts(h: integer);
function HeroQuickMagic(h: integer): integer;
function HeroArmyValue(h: integer): longint;
function WorthTalking(h1, h2, d: integer): integer;
procedure GetSkillChoices(h: integer; var skc: TSkillChoices);
function AIPickSkill(h: integer; skc: TSkillChoices): integer;
function AIPickSpell(h, sp1, sp2: integer): integer;
procedure AIHeroTalk(h1, h2: integer);
function SkillGraphic(sk: integer): PGraphic;
function HeroPersuasionGP(h: integer): longint;
function HeroNumShots(h: integer): integer;
procedure GiveSummoning(h: integer; gp: longint);
procedure GiveWarcraft(h, lev: integer);
procedure GiveHeroDailyMPSP(h: integer);
function HeroDailyAlchemy(h: integer): string;
procedure HeroDailySummoning(h: integer);
procedure HeroDailyGating(h: integer);
function HeroDailyInsight(h: integer): string;

procedure InitHeroes;
procedure DoHeroScreen(h: integer; JustThisHero: boolean);

implementation

uses Drivers, XMouse, XFace, Players, Combat, CombSub, Options, Rez;

const
  NumFeatures = 60;

  SkillArt: array [1..NumNSkills] of integer =
  (
    anRingOfPower1,
    anTalismanOfHealing1,
    anNecklaceOfSpellcraft,
    anSwordOfOffense1,
    anShieldOfDefense1,
    anBowOfArchery1,
    anBootsOfPathfinding1,
    anEyeOfPersuasion1,
    anNecklaceOfSummoning,
    anSkullOfDarkArts1,
    anAxeOfWarcraft1,
    anBellOfConjuring1
  );


type
  TFeature = array [1..32, 1..32] of byte;
  TFT = (fHead, fHair, fEyes, fMouth, fNose, fEyebrows, fMisc);

  TFeatureRec = record
    pix: TFeature;
    ft: TFT;
  end;

  TFace = array [1..8] of byte;

  TFeatures = array [1..NumFeatures] of TFeatureRec;
  PFeatures = ^TFeatures;

var
  Features: PFeatures;
  Faces: array [1..10 * 14] of TFace;

procedure LoadFaces;
  var f: file;
  begin
    New(Features);
    assign(f, 'faces.pic');
    reset(f, 1);
    blockread(f, Features^, sizeof(Features^));
    blockread(f, Faces, sizeof(Faces));
    close(f);
  end;

{
  jungle fort       swarm       / *conjure
  city of shadows   bad luck    / *weakness
  cloud castle      zap         / good luck
  thieves' guild    deserter    / *traitor
  factory           blow        / fury
  laboratory        grow        / *shrink
  pyramid           heal        / *fatigue
  ruins             fly         / *mudball

  circus            good luck / zap   / grow / fly
  evil temple       bad luck  / swarm / fury / blow
}

procedure InitHeroes;
  type
    TStartData = array [1..NumHeroes] of record
      n: string[21];
      sk1, sk2: byte;
      sum: byte;
      sp: byte;
    end;
    PStartData = ^TStartData;
  var
    i: integer;
    PSD: PStartData;
    f: file;
  begin
    New(PSD);
    assign(f, 'heroes.dat');
    reset(f, 1);
    blockread(f, PSD^, sizeof(PSD^));
    close(f);

    New(Hero);
    FillChar(Hero^, sizeof(Hero^), #0);

    for i := 1 to NumHeroes do
      with Hero^[i] do begin
        Name := PSD^[i].n;
        ct := TCastleType((i - 1) div 14);
        player := 0;
        level := 1;
        XP := 25;
        if PSD^[i].sk1 <= NumNSkills then begin
          Skill[1] := PSD^[i].sk1;
          SkillLevel[1] := 1;
          if PSD^[i].sk2 <= NumNSkills then begin
            Skill[2] := PSD^[i].sk2;
            SkillLevel[2] := 1;
          end else begin
            Skill[6] := PSD^[i].sk2;
            SkillLevel[6] := 1;
          end;
        end else begin
          Skill[6] := PSD^[i].sk1;
          SkillLevel[6] := 1;
          Skill[7] := PSD^[i].sk2;
          SkillLevel[7] := 1;
        end;
        MapX := 0;
        MapY := 0;
        DestX := 0;
        AddSpell(SS, PSD^[i].sp);
        FacingLeft := false;
        AltarBonus := 0;
        AltarDays := 0;
        ShrineBonus := 0;
        ShrineDays := 0;
        MiningRez := 0;
        SummoningAmt := 0;
        GatingAmt := 0;
        RingWitches := 0;
        RingDjinns := 0;
        LastAlchemy := 0;
        AlchemyDay := 0;
        LoreArtFraction := 0;
        AlchemyArtFraction := 0;
        TransformArtFraction := 0;
        MassSummonArtFraction := 0;
        EvocationLevel := 0;
        Dead := false;
        SP := HeroMaxSP(i);
        MP := HeroMaxMP(i);
        DeathMana := 0;
        HermitBonus := hbNone;
        Specialty := 0;
        SummonedCr := PSD^[i].sum;
        Expertise := 0;
        ExpertiseArtDay := 0;
      end;

    Dispose(PSD);
  end;

procedure DrawHero(x, y, c, n: integer);
  var
    f: TFace;
    fp: TFeature;
    px: array [1..32, 1..32] of byte;
    section, pc, i, j, redc, brownc: integer;
  begin
    XRectangle(x, y, x + 35, y + 35, c);

    if n <= 0 then begin
      XFillArea(x + 1, y + 1, x + 34, y + 34, colDarkBlue);
      DrawGraphic2c(x + 1, y + 3, PlColor[-n], colDarkBlue,
                    MapGraphics^[mgCamp], false);
    end else begin
      fillchar(px, sizeof(px), chr(colDarkBlue));
      redc := colRed;
      brownc := colBrown;

      f := faces[n];

      case f[1] of
        2: begin redc := colDarkGray;  brownc := colBlack; end;
        3: begin redc := colDarkGreen; brownc := colBlack; end;
        4: begin redc := colBlue;      brownc := colBlack; end;
        5: begin redc := colLightGray; brownc := colBlack; end;
        6: begin redc := colBlack;     brownc := colBlack; end;
      end;

      for section := 1 to 8 do
        if f[section] <> 0 then begin
          fp := Features^[f[section]].pix;
          for i := 1 to 32 do
            for j := 1 to 32 do begin
              pc := fp[i, j];
              if section <> 1 then begin
                if pc = colRed then
                  pc := redc
                else if pc = colBrown then
                  pc := brownc;
              end;
              if pc <> 255 then px[i, j] := pc;
            end;
        end;

      for i := 1 to 32 do
        for j := 1 to 32 do
          XPutPixel(x + i - 1 + 2, y + j - 1 + 2, px[i, j]);
    end;
  end;

function HeroFirstSpell(h: integer): integer;
  var sp, j: integer;
  begin
    sp := 0;

    for j := 1 to NumSpells do
      if CheckForSpell(Hero^[h].SS, j) then
        sp := j;

    HeroFirstSpell := sp;
  end;

procedure DrawHeroInfo(x, y, h: integer);
  const
    skorder: array [1..10] of byte = (1, 6, 2, 7, 3, 8, 4, 9, 5, 10);
  var
    sp, i, sk, sky, c: integer;
  begin
    DrawText(x, y - 13, colBlack, colWhite, Hero^[h].Name);
    DrawHero(x, y, colLightGray, h);
    if not Hero^[h].Dead then begin
      sky := y;
      for i := 1 to 10 do begin
        sk := Hero^[h].Skill[skorder[i]];
        if (sk <> 0) and (sky < y + 14 * 2) then begin
          if sk <= NumNSkills then c := colLightBlue else c := colYellow;
          DrawText(x + 45, sky, colBlack, c, SkillNames[sk]);
          inc(sky, 14);
        end;
      end;
      DrawSmallGraphic2c(x + 45, y + 28 - 2, colGrayYellows, colBlack,
                         MonsterGraphic(Hero^[h].SummonedCr)^);
      sp := HeroFirstSpell(h);
      if sp <> 0 then
        DrawText(x + 45 + 10 + 8, y + 28, colBlack,
                 SpellSlantColor[SpellData[sp].slant], SpellData[sp].name);
    end else begin
      DrawText(x + 45, y, colBlack, colWhite,
               'Level ' + IStr(Hero^[h].Level, 0));
      DrawText(x + 45, y + 14, colBlack, colLightBlue,
               IStr(CountAllArts(h), 0) + ' Artifacts');
      DrawText(x + 45, y + 28, colBlack, colLightGreen,
               IStr(CountSpells(Hero^[h].SS), 0) + ' Spells');
    end;
  end;

function HeroMonsterHasFlag(h, m, fbyte, fbit: word): boolean;
  var hmhf: boolean;
  begin
    if ((MonsterData[m].sflags[fbyte] and fbit) <> 0)
       and (((m = Hero^[h].Specialty)
             and (GetEffSkillLevel(h, skSpecialty) >= 3))
            or ((MonsterLevel(m) = 1)
                and (CountArt(h, anRingoftheSpecialist, true) > 0))) then
      hmhf := true
    else
      hmhf := MonsterHasFlag(m, fbyte, fbit);
    HeroMonsterHasFlag := hmhf;
  end;

procedure GetHeroMonsterStats(h, mons: integer; var ms: TMonster;
                              incombat: boolean);
  var i, lev, ca, hh, ab, specl, specm: integer;
  begin
    ms := MonsterData[mons];

    if h <> 0 then begin
      specm := Hero^[h].Specialty;
      specl := GetEffSkillLevel(h, skSpecialty);

      if ((mons = specm) and (specl >= 3))
          or ((MonsterLevel(mons) = 1)
              and (CountArt(h, anRingoftheSpecialist, true) > 0)) then
        for i := 1 to NumFlagWords do
          ms.flags[i] := MonsterData[mons].sflags[i];

      lev := GetEffSkillLevel(h, skOffense);
      if (mons = specm) then inc(lev, SpecialtyBoost[specl]);
      if lev <> 0 then
        inc(ms.dmg, (ms.dmg * lev + 9) div 10);

      lev := GetEffSkillLevel(h, skDefense);
      if (mons = specm) then inc(lev, SpecialtyBoost[specl]);
      if lev <> 0 then
        inc(ms.hp, (ms.hp * lev + 9) div 10);

      lev := GetEffSkillLevel(h, skTactics);
      if (mons = specm) then inc(lev, SpecialtyBoost[specl]);
      if lev <> 0 then
        inc(ms.speed, lev * 5);

      ab := Hero^[h].AltarBonus;
      if ab = altCheetah then begin
        if ms.speed <> 0 then
          inc(ms.speed, 10);
      end else if ab <> 0 then
        ms.flags[Altars[ab].flagb] := ms.flags[Altars[ab].flagb]
                                      or Altars[ab].flag;

      inc(ms.hp, 2 * CountArt(h, anShieldOfTheSmall, true));
      inc(ms.dmg, CountArt(h, anSwordOfTheWeak, true));

      ca := CountArt(h, anGlovesOftheSpeedyHordes, true);
      if (ca > 0) and (MonsterLevel(mons) = 1) then
        inc(ms.speed, 10 * ca);

      inc(ms.speed, CountArt(h, anTacticiansGloves, true) * 5);

      if HasArt(h, anShieldOfFriendship, true) then
        ms.flags[4] := ms.flags[4] or f4Friendship;

      if Hero^[h].HermitBonus = hbKiller then
        ms.flags[4] := ms.flags[4] or f4Maiming;

      ca := CountArt(h, anSpikedShield, true);
      if ca = 1 then
        ms.flags[4] := ms.flags[4] or f4Spikes
      else if ca = 2 then
        ms.flags[5] := ms.flags[5] or f5Spikes2;

      if HasArt(h, anTerrainShield, true) then
        ms.flags[4] := ms.flags[4] or f4WaterImmune or f4FireImmune;

      if mons = moShadow then begin
         if (CountArt(h, anTalismanoftheNecromancer, true) > 0) then
           ms.flags[2] := ms.flags[2] or f2RemoveFlags or f2Stun;
         if HeroHasExpertiseBonus(h, skDarkArts) then
           ms.flags[2] := ms.flags[2] or f2RemoveFlags;
      end;

      if HeroHasExpertiseBonus(h, skOffense) then
        ms.flags[6] := ms.flags[6] or f6AttImmune;
      if HeroHasExpertiseBonus(h, skDefense) then begin
        ms.flags[6] := ms.flags[6] or f6DefImmune;
        ms.flags[4] := ms.flags[4] or f4FireImmune;
      end;
    end;

    if Twists[twMonstersHaveAbility] then
      ms.flags[FlagByte(AllMonstersAbility)]
      := ms.flags[FlagByte(AllMonstersAbility)]
         or FlagBit(AllMonstersAbility);

    if h <> 0 then begin
      if not incombat then begin
        hh := CountArt(h, anHeartsHelm, true);
        if hh > 0 then begin
          if (ms.flags[1] and (f1Fly or f1AnyRange)) = 0 then
            inc(ms.speed, 15);
          if (ms.flags[1] and f1AnyRange) <> 0 then
            inc(ms.dmg, (MonsterData[mons].dmg * hh * 3 + 9) div 10);
        end;

        ca := CountArt(h, anFlyersHelm, true);
        if ((ca > 0) or (hh > 0)) and ((ms.flags[1] and f1Fly) <> 0) then
          inc(ms.hp, (MonsterData[mons].hp * (hh * 3 + ca) + 9) div 10);

        ca := CountArt(h, anArchersHelm, true);
        if (ca > 0) and ((ms.flags[1] and f1AnyRange) <> 0) then begin
          inc(ms.hp, (MonsterData[mons].hp * ca + 9) div 10);
          ms.flags[1] := ms.flags[1] or f1Hiding;
        end;

        ca := CountArt(h, anWalkersHelm, true);
        if (ca > 0)
           and ((ms.flags[1] and (f1Fly or f1AnyRange or f1Transform) = 0)) then
          inc(ms.hp, (MonsterData[mons].hp * ca * 2 + 9) div 10);

        { gloves of courage - not possible }
      end;
    end;
  end;

procedure SpreadOut(h: integer; wayout: boolean);
  const
    ranktbl: array [1..17] of record
      fbyte, fbit: word;
    end =
    (
      (fbyte: 4; fbit: f4Explode),
      (fbyte: 2; fbit: f2Stun),
      (fbyte: 5; fbit: f5SwitchMove),
      (fbyte: 5; fbit: f5Friendport),
      (fbyte: 1; fbit: f1Plantport),
      (fbyte: 4; fbit: f4FeedOnDead),
      (fbyte: 2; fbit: f2RemoveFlags),
      (fbyte: 2; fbit: f2CopyFlags),
      (fbyte: 3; fbit: f3Illusionist),
      (fbyte: 4; fbit: f4Maiming),
      (fbyte: 4; fbit: f4Curse),
      (fbyte: 3; fbit: f3Bless),
      (fbyte: 5; fbit: f5Disease),
      (fbyte: 2; fbit: f2Hex),
      (fbyte: 2; fbit: f2Flame),
      (fbyte: 5; fbit: f5SuperBless),
      (fbyte: 2; fbit: f2Devolve)
    );
  var
    i, es, rank, brank, bi, sl, j: integer;
    ms: TMonster;
  begin
    sl := HeroSlots(h);
    with Hero^[h] do begin
      repeat
        es := 0;
        for i := 1 to sl do
          if army[i].qty = 0 then es := i;
        if es <> 0 then begin
          bi := 0;
          for i := 1 to sl do
            if army[i].qty > 1 then begin
              GetHeroMonsterStats(h, army[i].monster, ms, false);
              rank := 0;
              for j := 1 to high(ranktbl) do
                if ((ms.flags[ranktbl[j].fbyte] and ranktbl[j].fbit) <> 0) then
                  rank := (j + 1) * 2;
              if wayout and (rank = 0) and (army[i].qty >= 20)
                 and ((ms.flags[4] and f4Poison) = 0)
                 and ((ms.flags[3] and (f3Vampire or f3Morale
                                        or f3LikesDamage)) = 0)
                 and ((ms.flags[1] and f1Retaliate) = 0)
                 and ((ms.flags[5] and f5Werewolf) = 0) then
                rank := 1;
              if army[i].qty >= 200 then rank := 25;
              if army[i].qty >= 1000 then rank := 100;
              if (rank > 0) and ((bi = 0) or (rank > brank)) then begin
                bi := i;
                brank := rank;
              end;
            end;
          if bi <> 0 then begin
            army[es].monster := army[bi].monster;
            army[es].qty := army[bi].qty div 2;
            army[bi].qty := (army[bi].qty + 1) div 2;
          end;
        end;
      until (es = 0) or (bi = 0);
    end;
  end;

function HeroMaxSP(h: integer): integer;
  begin
    HeroMaxSP := 40 + 20 * GetEffSkillLevel(h, skSpellcraft);
  end;

function NumTroopsWithFlag(h: integer; fb: byte; fbit: word): longint;
  var
    d: longint;
    i: integer;
  begin
    d := 0;

    for i := 1 to HeroSlots(h) do
      if (Hero^[h].army[i].qty > 0)
         and HeroMonsterHasFlag(h, Hero^[h].army[i].monster, fb, fbit) then
        inc(d, Hero^[h].army[i].qty);

    NumTroopsWithFlag := d;
  end;

function HeroMaxMP(h: integer): integer;
  var
    n, i, t, pl: integer;
    mind, d: longint;
  begin
    n := 0;

    if HasArt(h, anSevenLeagueBoots, true) then begin
      mind := MaxLongInt;
      for i := 1 to MaxTowns do begin
        pl := Hero^[h].Player;
        if pl <> 0 then begin
          t := Player[pl].Towns[i];
          if t <> 0 then begin
            d := round(Sqrt(Sqr(Hero^[h].MapX - Castle[t].MapX)
                            + Sqr(Hero^[h].MapY - Castle[t].MapY)));
            if d < mind then mind := d;
          end;
        end;
      end;
      if mind <> MaxLongInt then begin
        n := mind div {8}12;
        if n < 1 then n := 1;
      end;
    end;

    if Twists[twDoubleMovement] then inc(n, 14);

    inc(n, CountArt(h, anToyPickaxe, true));

    HeroMaxMP := 14 + GetEffSkillLevel(h, skPathfinding) + n
                 + NumTroopsWithFlag(h, 4, f4Pathfinding) div 30;
  end;

procedure LimitMana(h: integer);
  var maxsp: integer;
  begin
    maxsp := HeroMaxSP(h);
    if Hero^[h].SP > maxsp then Hero^[h].SP := maxsp;
  end;

procedure GiveMana(h, amt: integer);
  begin
    inc(Hero^[h].SP, amt);
    LimitMana(h);
  end;

procedure GiveDeathMana(h: integer; amt: longint);
  begin
    inc(amt, Hero^[h].DeathMana);
    GiveMana(h, amt div 100);
    Hero^[h].DeathMana := amt mod 100;
  end;

function EquipArt(h, art: integer): boolean;
  var
    did: boolean;
    i: integer;
  begin
    did := false;
    for i := 1 to EquipSlots(h) do
      if (ArtData[art].slot = EquipSlot[i]) and (Hero^[h].Equipped[i] = 0)
         and not did then begin
        did := true;
        Hero^[h].Equipped[i] := art;
      end;
    EquipArt := did;
  end;

function PackArt(h, art: integer): boolean;
  var
    did: boolean;
    i: integer;
  begin
    did := false;
    for i := 1 to BackpackSize do
      if (Hero^[h].Backpack[i] = 0) and not did then begin
        did := true;
        Hero^[h].Backpack[i] := art;
      end;
    PackArt := did;
  end;

function GainArt(h, art: integer): boolean;
  var ga: boolean;
  begin
    ga := EquipArt(h, art) or PackArt(h, art);
    if ga and Player[Hero^[h].player].AI then WearBestArts(h);
    GainArt := ga;
  end;

function HasArt(h, art: integer; eq: boolean): boolean;
  begin
    HasArt := CountArt(h, art, eq) > 0;
  end;

function CountArt(h, art: integer; eq: boolean): integer;
  var i, ca: integer;
  begin
    ca := 0;

    if eq then begin
      for i := 1 to EquipSlots(h) do
        if Hero^[h].Equipped[i] = art then
          inc(ca);
    end else begin
      for i := 1 to BackpackSize do
        if Hero^[h].Backpack[i] = art then
          inc(ca);
    end;

    CountArt := ca;
  end;

procedure LoseArt(h, art: integer);
  var
    lost: boolean;
    i: integer;
  begin
    lost := false;
    for i := 1 to EquipSlots(h) do
      if not lost and (Hero^[h].Equipped[i] = art) then begin
        lost := true;
        Hero^[h].Equipped[i] := 0;
      end;
    for i := 1 to BackpackSize do
      if not lost and (Hero^[h].Backpack[i] = art) then begin
        lost := true;
        Hero^[h].Backpack[i] := 0;
      end;
  end;

procedure SortBackpack(h: integer);
  var i, j, mini, minart, art: integer;
  begin
    for j := 1 to BackpackSize - 1 do begin
      minart := 0;
      for i := j to BackpackSize do
        if (Hero^[h].Backpack[i] <> 0)
           and ((minart = 0) or (Hero^[h].Backpack[i] < minart)) then begin
          minart := Hero^[h].Backpack[i];
          mini := i;
        end;
      if minart <> 0 then begin
        art := Hero^[h].Backpack[j];
        Hero^[h].Backpack[j] := minart;
        Hero^[h].Backpack[mini] := art;
      end;
    end;
  end;

function CountAllArts(h: integer): integer;
  var i, caa: integer;
  begin
    caa := 0;

    for i := 1 to EquipSlots(h) do
      if Hero^[h].Equipped[i] <> 0 then inc(caa);
    for i := 1 to BackpackSize do
      if Hero^[h].Backpack[i] <> 0 then inc(caa);

    CountAllArts := caa;
  end;

function GetVisited(h, x, y, hv: integer): boolean;
  begin
    GetVisited := (Hero^[h].Visited[x, y] and hv) <> 0;
  end;

procedure SetVisited(h, x, y, hv: integer);
  begin
    Hero^[h].Visited[x, y] := Hero^[h].Visited[x, y] or hv;
  end;

function SpecialtyHint(m: integer): string;
  var
    s: string;
    i: integer;
    gotone: boolean;
  begin
    s := '';
    gotone := false;
    for i := 1 to FlagMax do
      if ((MonsterData[m].sflags[FlagByte(i)]
           and FlagBit(i)) <> 0)
          and ((MonsterData[m].flags[FlagByte(i)]
               and FlagBit(i)) = 0) then begin
        if gotone then s := s + ', ';
        s := s + FlagNames^[i];
        gotone := true;
      end;
    SpecialtyHint := s;
  end;

function HasSummonCreatureSkill(h: integer; eff: boolean): boolean;
  begin
    if eff then
      HasSummonCreatureSkill := (GetEffSkillLevel(h, skSummoning) > 0)
                                or (GetEffSkillLevel(h, skConjuring) > 0)
                                or (GetEffSkillLevel(h, skWarcraft) > 0)
    else
      HasSummonCreatureSkill := (GetSkillLevel(h, skSummoning) > 0)
                                or (GetSkillLevel(h, skConjuring) > 0)
                                or (GetSkillLevel(h, skWarcraft) > 0);
  end;

procedure PickSpecialty(h: integer);
  var
    DA: TDialogArr;
    i, m, bestm, slots: integer;
    gp, bestgp: longint;
  begin
    if (GetSkillLevel(h, skSpecialty) > 0)
       and (Hero^[h].Specialty = 0) then begin
      if (Hero^[h].player = 0) or Player[Hero^[h].player].AI then begin
        bestm := Hero^[h].SummonedCr;
        if not HasSummonCreatureSkill(h, true) then begin
          slots := HeroSlots(h);
          bestgp := 0;
          for i := 1 to 6 do begin
            m := MonsterForLevel(Hero^[h].ct, i);
            gp := CountMonsters(@Hero^[h].army, slots, m)
                  * longint(MonsterData[m].cost);
            if gp > bestgp then begin
              bestm := m;
              bestgp := gp;
            end;
          end;
        end;
        Hero^[h].Specialty := bestm;
      end else begin
        for i := 1 to 6 do begin
          m := MonsterForLevel(Hero^[h].ct, i);
          DA[i].pic := dgMonster + m;
          DA[i].s := MonsterData[m].pname + chr(colLightGray)
                     + ' - ' + SpecialtyHint(m);
        end;

        repeat
          i := BaseDialogN(dgcFace + chr(h)
                           + 'Choose a creature type to specialize in '
                           + '(it gets the listed bonus at Specialty 3).',
                           @DA, 6, 2);
          if i = -1 then DoHeroScreen(h, true);
        until i <> -1;

        Hero^[h].Specialty := DA[i].pic - dgMonster;
      end;
    end;
  end;

procedure PickExpertise(h: integer);
  var
    i, bestsk, bestlev, sk, lastsk: integer;
    DA: TDialogArr;
  begin
    with Hero^[h] do begin
      if (Expertise = 0)
         and (Skill[1] <> 0)
         and (GetEffSkillLevel(h, skExpertise) > 0) then begin
        if (player = 0) or Players.Player[player].AI then begin
          bestsk := Skill[1];
          bestlev := SkillLevel[1];

          for i := 2 to 5 do
            if (Skill[i] <> 0)
               and (SkillLevel[i] > bestlev) then begin
              bestsk := Skill[i];
              bestlev := SkillLevel[i];
            end;

          Expertise := bestsk;
        end else begin
          for i := 1 to 5 do begin
            sk := Skill[i];
            if sk <> 0 then begin
              DA[i].pic := dgSkill + sk;
              DA[i].s := SkillNames[sk] + chr(colLightGray)
                         + ' - ' + ExpertiseBonusStr(h, sk);
              lastsk := i;
            end;
          end;

          repeat
            i := BaseDialogN(dgcFace + chr(h)
                             + 'Choose a blue skill as your field of '
                             + 'expertise' + chr(colLightGray)
                             + ' (you get the listed bonus at Expertise 2).',
                             @DA, lastsk, 1);
            if i = -1 then DoHeroScreen(h, true);
          until i <> -1;

          Hero^[h].Expertise := DA[i].pic - dgSkill;
        end;
      end;
    end;
  end;

function GetSkillLevel(h, sk: integer): integer;
  var i, lev: integer;
  begin
    lev := 0;
    for i := 1 to 10 do
      if Hero^[h].Skill[i] = sk then
        lev := Hero^[h].SkillLevel[i];
    GetSkillLevel := lev;
  end;

function SkillHasInsight(h, sk: integer): boolean;
  var
    shi: boolean;
    ins, m, i: integer;
  begin
    shi := false;

    if (sk > NumNSkills) and (sk <> skInsight) then begin
      ins := GetSkillLevel(h, skInsight);
      if ins > 0 then begin
        if ins = 3 then ins := 4;
        m := 6;
        for i := 1 to ins do begin
          if (m <= 10) and (Hero^[h].Skill[m] = skInsight) then
            inc(m);
          if (m <= 10) and (Hero^[h].Skill[m] = sk) then
            shi := true;
          inc(m);
        end;
      end;
    end;

    SkillHasInsight := shi;
  end;

function GetEffSkillLevel(h, sk: integer): integer;
  var i, lev, c, x, y, b, pl, h2, ins, m: integer;
  begin
    lev := GetSkillLevel(h, sk);
    pl := Hero^[h].player;

    if sk <= NumNSkills then begin
      if pl <> 0 then
        inc(lev, Player[pl].SkillMines[sk]);
      for i := 1 to 3 do
        inc(lev, CountArt(h, SkillArt[sk] + i - 1, true) * i);
    end;

    if SkillHasInsight(h, sk) then inc(lev);

    if sk = skDefense then
      inc(lev, CountArt(h, anShieldOfFriendship, true)
               + CountArt(h, anSpikedShield, true)
               + CountArt(h, anTerrainShield, true));

    if sk = skArchery then
      inc(lev, CountArt(h, anBowOfEvil, true)
               + CountArt(h, anBowOfForce, true)
               + CountArt(h, anBowOfSpeed, true)
               + CountArt(h, anFlamingBow, true)
               + 2 * CountArt(h, anBowoftheRanger, true)
               + 2 * CountArt(h, anBowofPoison, true));

    if sk = skPathfinding then
      inc(lev, CountArt(h, anBootsoftheScout, true)
               + CountArt(h, anBootsofEndurance, true)
               + CountArt(h, anBootsofJourneying, true)
               + 2 * CountArt(h, anBootsofGating, true));

    if sk = skSummoning then
      inc(lev, CountArt(h, anBootsoftheScout, true));

    if sk = skSorcery then
      inc(lev, CountArt(h, anRingOfSorcery, true));

    if (sk = skOffense) or (sk = skDefense) then
      inc(lev, CountArt(h, anSwordoftheWarrior, true));

    if (sk = skPower) or (sk = skWizardry) then
      inc(lev, CountArt(h, anRingoftheWarlock, true));

    if (sk = skPersuasion) or (sk = skDarkArts) then
      inc(lev, CountArt(h, anTalismanoftheNecromancer, true));

    if sk = skHealing then
      inc(lev, CountArt(h, anBowoftheRanger, true));

    if sk = skGating then
      inc(lev, CountArt(h, anBootsofGating, true));

    if Hero^[h].ShrineBonus = sk then inc(lev, 2);

    if ((sk = skOffense) or (sk = skDefense) or (sk = skTactics))
       and (pl <> 0) then begin
      for i := 1 to MaxTowns do begin
        c := Player[pl].Towns[i];
        if c <> 0 then
          for x := 1 to 8 do
            for y := 1 to 8 do begin
              b := Castle[c].Grid[x, y];
              if ((sk = skOffense) and (b = bCrownOfOffense))
                 or ((sk = skDefense) and (b = bCrownOfDefense))
                 or ((sk = skTactics) and (b = bCrownOfTactics)) then
                inc(lev);
            end;
      end;
    end;

    if (sk <= NumNSkills) then begin
      if Twists[tw10Towers] then inc(lev);

      if pl <> 0 then
        for i := 1 to MaxDudes do begin
          h2 :=  Player[pl].Dudes[i];
          if (h2 <> 0) and (Hero^[h2].Expertise = sk)
             and (GetEffSkillLevel(h2, skExpertise) >= 3) then
            inc(lev);
        end;
    end;

    GetEffSkillLevel := lev;
  end;

function HeroHasExpertiseBonus(h, sk: integer): boolean;
  begin
    HeroHasExpertiseBonus := (Hero^[h].Expertise = sk)
                             and (GetEffSkillLevel(h, skExpertise) >= 2);
  end;

function MaxSkillsPerSide: integer;
  var msps: integer;
  begin
    if Twists[twMax4Skills] then msps := 2 else msps := 4;
    MaxSkillsPerSide := msps;
  end;

function CanGainSkillLevel(h, sk: integer): boolean;
  var
    i, msps: integer;
    can, found: boolean;
  begin
    can := false;
    found := false;
    msps := MaxSkillsPerSide;

    for i := 1 to 10 do
      if (Hero^[h].Skill[i] = sk) then begin
        found := true;
        if (i <= 5) or ((i > 5) and (Hero^[h].SkillLevel[i] < 3)) then
          can := true;
      end;

    if not can and not found then
      for i := 1 to 10 do
        if not can and (Hero^[h].SkillLevel[i] = 0) then begin
          if sk <= NumNSkills then
            can := ((i >= 1) and (i <= msps))
                   or ((i = msps + 1)
                       and (GetEffSkillLevel(h, skCunning) >= 2))
          else
            can := ((i >= 6) and (i <= 5 + msps))
                   or ((i = 6 + msps)
                       and (GetEffSkillLevel(h, skCunning) >= 3));
        end;

    CanGainSkillLevel := can;
  end;

function GainSkillLevel(h, sk: integer): boolean;
  var
    i, n, msps: integer;
    did, can: boolean;
  begin
    did := false;
    msps := MaxSkillsPerSide;

    if CanGainSkillLevel(h, sk) then begin
      if sk <= NumNSkills then n := 1 else n := 6;
      for i := n to n + msps do
        if not did and ((Hero^[h].Skill[i] = sk)
                        or (Hero^[h].SkillLevel[i] = 0)) then begin
          Hero^[h].Skill[i] := sk;
          inc(Hero^[h].SkillLevel[i]);
          did := true;
        end;
    end;

    if did then begin
      if sk = skSpecialty then
        PickSpecialty(h);
      PickExpertise(h);
    end;

    GainSkillLevel := did;
  end;

function XPForLevel(lev: integer): longint;
  var r: real;
  begin
    r := exp(lev * ln(10) / 12) * 1000 + lev * 800.0 - 1000;
      { [12th root of 10] to the power of lev, plus extra }
    XPForLevel := round(r);
  end;

function XPAfterCunning(h: integer; x: longint): longint;
  var l: integer;
  begin
    l := GetEffSkillLevel(h, skCunning);
    if l > 0 then x := trunc(x * (1 + l / 20) + 0.99);
    if Twists[twDoubleXP] then x := x * 2;
    XPAfterCunning := x;
  end;

function NeededXPStr(h: integer): string;
  begin
    NeededXPStr := LStr(XPForLevel(Hero^[h].level) - Hero^[h].XP + 1, 0);
  end;

function HeroSlots(h: integer): integer;
  begin
    HeroSlots := 6 + GetEffSkillLevel(h, skLeadership);
  end;

function EquipSlots(h: integer): integer;
  begin
    EquipSlots := 15 + GetEffSkillLevel(h, skAlchemy);
  end;

function HeroSpellValue(h, sp: integer): integer;
  var hsv, pl: integer;
  begin
    hsv := SpellPowerValue(sp, GetEffSkillLevel(h, skPower) + 1,
                           GetEffSkillLevel(h, skWitchcraft) + 1);
    pl := Hero^[h].player;
    if (pl <> 0) then
      inc(hsv, (hsv * Player[pl].SpellMines[smMagician]) div 5);
    HeroSpellValue := hsv;
  end;

function HeroSpellDur(h, sp: integer): integer;
  var hsd, pl: integer;
  begin
    hsd := 1 + GetEffSkillLevel(h, skWitchcraft)
           + 2 * CountArt(h, anRingOfTheWitch, true);
    if not (sp in [spSwarm, spIceBolt, spFury, spGrow, spAgility, spShrink,
                   spWeakness, spFatigue, spJoy, spWoe, spMultiply]) then begin
      pl := Hero^[h].player;
      if (pl <> 0) then
        inc(hsd, Player[pl].SpellMines[smMagician]);
    end;
    HeroSpellDur := hsd;
  end;

function EffSpellCost(h, sp: integer): integer;
  var esc, pl, lore: integer;
  begin
    lore := GetEffSkillLevel(h, skLore);
    if lore > 3 then lore := 3;
    esc := SpellData[sp].cost
           - (lore + CountArt(h, anRingOfTheLoremaster, true))
             * SpellData[sp].level;
    if sp in [spBlow, spDeserter, spTraitor, spHeal, spSicken,
              spFireShield, spRenew] then begin
      pl := Hero^[h].player;
      if pl <> 0 then
        dec(esc, Player[pl].SpellMines[smMagician] * SpellData[sp].level);
    end;
    if esc < 1 then esc := 1;
    EffSpellCost := esc;
  end;

function HeroDailySP(h: integer): integer;
  begin
    HeroDailySP := 3 + 3 * GetEffSkillLevel(h, skSpellcraft)
                   + 2 * CountArt(h, anToyPickaxe, true);
  end;

function HeroSPPerRound(h: integer): integer;
  var hsppr, pl: integer;
  begin
    hsppr := 15 + 10 * GetEffSkillLevel(h, skWizardry)
             + 5 * CountArt(h, anRingoftheWizard, true);
    pl := Hero^[h].player;
    if pl <> 0 then
      inc(hsppr, 5 * Player[pl].SpellMines[smWizard]);
    HeroSPPerRound := hsppr;
  end;

procedure HeroDailyUpgrading(h, lev, qty: integer);
  var
    j, k, m, a: integer;
  begin
    with Hero^[h] do begin
      for j := 1 to HeroSlots(h) do
        if (qty > 0) and (army[j].qty > 0)
           and ((army[j].monster mod 6) = lev) then begin
          m := army[j].monster + 1;
          a := FindEmptyOrMonster(@army, HeroSlots(h), m);
          if a > 0 then begin
            k := army[j].qty;
            if k > qty then k := qty;
            dec(army[j].qty, k);
            if army[a].qty = 0 then begin
              army[a].monster := m;
              army[a].qty := k;
            end else
              inc(army[a].qty, k);
            dec(qty, k);
          end;
        end;
    end;
  end;

function HeroAtSpot(x, y: integer): integer;
  var h, n: integer;
  begin
    h := 0;

    for n := 1 to NumHeroes do
      if (Hero^[n].MapX = x) and (Hero^[n].MapY = y) then
        h := n;

    HeroAtSpot := h;
  end;

function HeroSummonedQtyStr(h: integer; gp: longint): string;
  var m: integer;
  begin
    m := Hero^[h].SummonedCr;
    HeroSummonedQtyStr := RStr(trunc(10.0 * gp / MonsterData[m].cost)
                               / 10, 0, 0)
                          + ' ' + MonsterData[m].pname;
  end;

function ExpertiseBonusStr(h, sk: integer): string;
  var ebs: string;
  begin
    case sk of
      skPower:       ebs := 'Your spells that target enemies also hex them.';
      skHealing:     ebs := 'You can heal troops from 2 stacks.';
      skSpellcraft:  ebs := 'You share spells with other heroes and '
                            + 'castles.';
      skOffense:     ebs := 'Your attacking monsters are immune to some '
                            + 'defensive abilities.';
      skDefense:     ebs := 'Your attacked monsters are immune to some '
                            + 'offensive abilities.';
      skArchery:     ebs := 'You get an extra Archery shot.';
      skPathfinding: ebs := 'You can see exactly how many monsters are in '
                            + 'a stack.';
      skPersuasion:  ebs := 'You persuade ' + IStr(PersuasionAmt, 0) + '_'
                            + crGold + ' of creatures that don''t match '
                            + 'your army.';
      skSummoning:   ebs := 'Your ' + CastlePNames[Hero^[h].ct] + ' produce '
                            + HeroSummonedQtyStr(h, SummoningGP)
                            + ' each day for free.';
      skDarkArts:    ebs := 'Your Shadows gain the "Removes Abilities" '
                            + 'ability.';
      skWarcraft:    ebs := 'Each time you pick up a treasure chest, you get '
                            + '+1 movement.';
      skConjuring:   ebs := 'You Conjure an additional stack of '
                            + HeroSummonedQtyStr(h, ConjuringGP) + '.';
    end;

    ExpertiseBonusStr := ebs;
  end;

function SkillHint(h, sk, lev: integer): string;
  const
    NthRange: array [1..3] of string[7] = ('1st', '1st-2nd', '1st-3rd');
    InsightBonus: array [skSorcery..skExpertise] of string[55] =
    (
      'Good/Evil spells w/o damage/%''s hit all targets',
      'Cast a free blessing in 1st round',
      '+0.5 speed',
      '+5% experience and +1 choice',
      'Gain 1 spell point when casting a spell',
      '+10 spell points usable per round',
      '+1 gear slot',
      '+300_' + crGold + ' of Gating each turn',
      '+1 army slot',
      'Convert 10 same level monsters to Specialty each turn',
      'Produce Expertise skill artifact every 4 days'
    );
  var
    s, s2: string;
    m, i, j: integer;

  function plural: string;
    begin
      if lev = 1 then plural := '' else plural := 's';
    end;

  begin
    case sk of
      skPower:       s := 'Increases the strength of your damage and '
                          + 'conjuring spells.';
      skHealing:     s := 'Your creatures heal ' + IStr(cHealDamage * lev, 0)
                          + ' damage each round. At the end of combat, you '
                          + 'revive ' + IStr(HealingAmt * lev, 0) + ' '
                          + crGold + ' of dead troops from a surviving stack.';
      skSpellcraft:  s := 'You have +' + IStr(20 * lev, 0) + ' maximum spell '
                          + 'points, and produce +' + IStr(3 * lev, 0)
                          + ' spell points per day.';
      skOffense:     s := 'Your troops deal +' + IStr(10 * lev, 0) + '% damage.';
      skDefense:     s := 'Your troops have +' + IStr(10 * lev, 0) + '% hit '
                          + 'points.';
      skArchery:     s := 'Your hero shoots in combat, dealing '
                          + IStr(cArcheryDamage * lev, 0) + ' damage.';
      skPathfinding: s := 'You have +' + ERStr(lev)
                          + ' movement per day, and see ' + IStr(lev, 0)
                          + ' square' + plural + ' farther.';
      skPersuasion:  s := 'When attacking, you gain control of '
                          + IStr(lev * PersuasionAmt, 0) + ' ' + crGold
                          + ' of enemies that match your army.';
      skSummoning:   begin
                       m := Hero^[h].SummonedCr;
                       s := 'You produce '
                            + HeroSummonedQtyStr(h, SummoningGP * lev)
                            + ' in your army each day.';
                     end;
      skDarkArts:    s := 'You produce ' + IStr(lev, 0) + ' Shadow'
                          + plural + ' per ' + IStr(cDarkArtsKills, 0)
                          + ' kills in combat.';
      skWarcraft:    s := 'Each time you fight a battle, you gain '
                          + HeroSummonedQtyStr(h, WarcraftGP * lev) + ', '
                          + IStr(lev, 0) + ' spell points, and '
                          + RStr(trunc(10.0 * lev / 4) / 10, 0, 0)
                          + ' movement.';
      skConjuring:   begin
                       m := Hero^[h].SummonedCr;
                       s := 'Each battle you have a stack of '
                            + HeroSummonedQtyStr(h, ConjuringGP * lev)
                            + ' fighting on your side.';
                     end;
      skSorcery:     s := 'Your spells can have up to ' + IStr(lev + 1, 0)
                          + ' targets. Damage and %''s are divided by the '
                          + 'number of targets.';
      skWitchcraft:  s := 'Your spells with a duration last ' + IStr(lev + 1, 0)
                          + ' rounds. Your spells with a % have a better %.';
      skTactics:     s := 'Your troops have +' + RStr(0.5 * lev, 3, 1)
                          + ' speed.';
      skCunning:     begin
                       s := 'You get 3 choices when going up a level. You '
                            + 'get +' + IStr(5 * lev, 0) + '% experience.';
                       if lev = 2 then
                         s := s + ' You can have an extra blue skill.'
                       else if lev = 3 then
                         s := s + ' You can have an extra blue skill and an '
                              + 'extra yellow skill.';
                     end;
      skLore:        s := 'You learn a ' + Nth[lev] + '-' + Nth[lev + 1]
                          + ' level spell when going up a level. Your '
                          + 'spells cost ' + IStr(lev, 0) + ' per level '
                          + 'less to cast.';
      skWizardry:    s := 'You have +' + IStr(10 * lev, 0) + ' spell points '
                          + 'usable per combat round. You cast spells earlier '
                          + 'in each round.';
      skAlchemy:     s := 'You produce a ' + NthRange[lev] + ' level artifact '
                          + 'every 7 days, and have ' + IStr(lev, 0)
                          + ' extra slot' + plural + ' for gear artifacts.';
      skGating:      s := 'You transport ' + IStr(GatingGP * lev, 0)
                          + ' ' + crGold + ' of troops total from your '
                          + CastlePNames[Hero^[h].ct]
                          + ' to your army each day.';
      skLeadership:  s := 'You can have ' + IStr(lev, 0) + ' extra stack'
                          + plural + ' of troops in your army.';
      skSpecialty:   begin
                       m := Hero^[h].Specialty;
                       if m = 0 then
                         s := 'A troop type of your choice for your '
                              + 'castle type has +10% hit points and damage, '
                              + 'and +0.5 speed.'
                       else begin
                         s := 'Your ' + MonsterData[m].pname
                              + ' have +' + IStr(SpecialtyBoost[lev] * 10, 0)
                              + '% hit points and damage, and +'
                              + RStr(SpecialtyBoost[lev] * 0.5, 3, 1)
                              + ' speed';
                         if lev >= 3 then
                           s := s + ', and gain an ability ('
                                + SpecialtyHint(m) + ')';
                         s := s + '.';
                       end;
                     end;
      skExpertise:   begin
                       m := Hero^[h].Expertise;
                       if m = 0 then begin
                         s := 'You choose a blue skill. You can take it '
                              + 'when gaining a level, and get +1 level '
                              + 'from schools for it.';
                         if Hero^[h].Skill[1] = 0 then
                           s := s + ' (This will be the first blue skill '
                                + 'you get, since you don''t have any.)'
                         else if Hero^[h].Skill[2] = 0 then
                           s := s + ' (This will be '
                                + SkillNames[Hero^[h].Skill[1]]
                                + ', since that''s your only blue skill.)';
                       end else begin
                         s := 'You can take ' + SkillNames[m]
                              + ' when gaining a level. +1 '
                              + SkillNames[m] + ' from schools.';
                         if lev >= 2 then begin
                           s := s + ' ' + ExpertiseBonusStr(h, m);
                           if lev >= 3 then
                             s := s + ' All of your heroes have +1 '
                                  + SkillNames[m] + '.';
                         end;
                       end;
                     end;
      skInsight:     begin
                       case lev of
                         1: s := 'You have +1 level of your first other '
                                 + 'yellow skill.';
                         2: s := 'You have +1 level of your first two '
                                 + 'other yellow skills.';
                         3: s := 'You have +1 level of your other yellow '
                                 + 'skills.';
                       end;
                       with Hero^[h] do
                         if Skill[6] <> 0 then begin
                           s2 := '';
                           m := 6;
                           if lev = 3 then j := 4 else j := lev;
                           for i := 1 to j do begin
                             if (m <= 10) and (Skill[m] = skInsight) then
                               inc(m);
                             if (m <= 10) and (Skill[m] <> 0)
                                and (SkillLevel[m] = 3) then begin
                               if s2 <> '' then s2 := s2 + '; ';
                               s2 := s2 + InsightBonus[Skill[m]];
                             end;
                             inc(m);
                           end;
                           if s2 <> '' then
                             s := s + ' (' + s2 + '.)';
                         end;
                     end;
    end;

    SkillHint := s;
  end;

function SkillStr(h, sk, plus: integer): string;
  var lev, skcol: integer;
  begin
    lev := GetSkillLevel(h, sk) + plus;
    if sk <= NumNSkills then skcol := colLightBlue else skcol := colYellow;
    SkillStr := chr(skcol) + SkillNames[sk] + ' ' + IStr(lev, 0)
                + chr(colLightGray) + ' - ' + SkillHint(h, sk, lev);
  end;

procedure KillHero(h: integer);
  var i: integer;
  begin
    with Hero^[h] do begin
      Dead := true;
      if (MapX <> 0) and (TheMap^[MapX, MapY] = mHero) then
        TheMap^[MapX, MapY] := mGrass;
      MapX := 0;
      DestX := 0;
      if MP > 1 then MP := 1;
      SP := 0;
      AltarBonus := 0;
      AltarDays := 0;
      ShrineBonus := 0;
      ShrineDays := 0;
      for i := 1 to HeroSlots(h) do
        army[i] := NilArmy;

      if player <> 0 then
        with players.player[player] do begin
          for i := 1 to MaxDudes do begin
            if Dudes[i] = h then
              Dudes[i] := 0;
            if (Dudes[i] = 0) and (i < MaxDudes) then begin
              Dudes[i] := Dudes[i + 1];
              Dudes[i + 1] := 0;
            end;
          end;
          SortHeroes(player);
        end;
    end;
  end;

procedure TakeArts(h1, h2: integer);
  var i, aiv: integer;

  procedure TakeArt(p: PByte);
    var a: integer;
    begin
      a := p^;
      if (a <> 0) and (ArtData[a].AIval = aiv) then begin
        GainArt(h1, a);
        p^ := 0;
      end;
    end;

  begin
    for aiv := MaxArtAIVal downto 0 do begin
      for i := 1 to EquipSlots(h2) do TakeArt(@Hero^[h2].Equipped[i]);
      for i := 1 to BackpackSize do TakeArt(@Hero^[h2].Backpack[i]);
    end;
  end;

procedure WearBestArts(h: integer);
  const
    InWearBestArts: boolean = false;
  var
    arts: array [1..19 + BackpackSize] of byte;
    i, aiv, esl: integer;
  begin
    if not InWearBestArts then begin
      InWearBestArts := true;
      fillchar(arts, sizeof(arts), #0);
      esl := EquipSlots(h);

      for i := 1 to esl do
        arts[i] := Hero^[h].Equipped[i];
      for i := 1 to BackpackSize do
        arts[esl + i] := Hero^[h].Backpack[i];

      fillchar(Hero^[h].Equipped, sizeof(Hero^[h].Equipped), #0);
      fillchar(Hero^[h].Backpack, sizeof(Hero^[h].Backpack), #0);

      for aiv := MaxArtAIVal downto 0 do
        for i := 1 to high(arts) do
          if (arts[i] <> 0) and (ArtData[arts[i]].AIval = aiv) then
            GainArt(h, arts[i]);

      InWearBestArts := false;
    end;
  end;

function HeroQuickMagic(h: integer): integer;
  var magicsum, magicskills: integer;

  procedure AddSkill(sk: integer);
    var n: integer;
    begin
      n := GetEffSkillLevel(h, sk);
      if n > 0 then begin
        if sk = skPower then n := n * 2;
        inc(magicsum, n);
        inc(magicskills);
      end;
    end;

  begin
    magicsum := 0;

    if Hero^[h].SP >= EffSpellCost(h, spZap) then begin
      magicsum := 1;
      magicskills := 0;
      AddSkill(skPower);
      if Hero^[h].SP >= EffSpellCost(h, spIceBolt) then AddSkill(skWizardry);
      AddSkill(skSorcery);
      AddSkill(skWitchcraft);
      AddSkill(skLore);
      inc(magicsum, CountArt(h, anRingOfTheWitch, true)
                    + CountArt(h, anRingOfTheWizard, true));
      if magicskills >= 3 then magicsum := magicsum * 2;
      magicsum := magicsum * 50;
    end;

    HeroQuickMagic := magicsum;
  end;

function HeroArmyValue(h: integer): longint;
  var
    m: integer;
    hav: longint;
  begin
    hav := ArmySetGP(@Hero^[h].army);
    if hav > 0 then begin
      inc(hav, GetEffSkillLevel(h, skConjuring) * ConjuringGP);
      inc(hav, GetEffSkillLevel(h, skWarcraft) * WarcraftGP);
      inc(hav, hav * (GetEffSkillLevel(h, skOffense)
                      + GetEffSkillLevel(h, skDefense)
                      + GetEffSkillLevel(h, skTactics)) div 20);
      m := Hero^[h].Specialty;
      if m <> 0 then
        inc(hav, (SpecialtyBoost[GetEffSkillLevel(h, skSpecialty)]
                  * CountMonsters(@Hero^[h].army, HeroSlots(h), m)
                  * longint(MonsterData[m].cost)) div 20);

      inc(hav, cArcheryDamage * 10 * GetEffSkillLevel(h, skArchery));
      inc(hav, cFireDamage * 10 * CountArt(h, anFlamingBow, true));
      inc(hav, HeroQuickMagic(h) * 6);
    end;
    HeroArmyValue := hav;
  end;

function WorthTalking(h1, h2, d: integer): integer;
  var
    wt: integer;
    xp1, xp2: longint;
  begin
    wt := MaxInt;

    if ArmySharingValue(@Hero^[h2].army, @Hero^[h1].army,
                        HeroSlots(h2), HeroSlots(h1)) >= 1200 then begin
      xp1 := Hero^[h1].XP;
      xp2 := Hero^[h2].XP;
      if xp2 > xp1 then begin
        if xp2 > 2 * xp1 then
          wt := d div 4
        else if xp2 * 3 < xp1 * 4 then
          wt := d * 2
        else
          wt := d;
      end;
    end;

    WorthTalking := wt;
  end;

procedure GetSkillChoices(h: integer; var skc: TSkillChoices);
  var
    Cunning, msps, numchoices, maxchoices: integer;
    canN, can3: boolean;

  function IsPicked(sk: integer): boolean;
    var
      i: integer;
      ip: boolean;
    begin
      ip := false;
      for i := 1 to 5 do
        if skc[i] = sk then
          ip := true;
      IsPicked := ip;
    end;

  function New3Skill: integer;
    var
      n, sk, i: integer;
      found: boolean;
    begin
      n := 10;
      while (Hero^[h].SkillLevel[n] = 0) and (n > 5) do dec(n);
      repeat
        sk := random(NumSkills - NumNSkills) + NumNSkills + 1;
        if IsPicked(sk) then found := true
        else begin
          found := false;
          if n > 5 then
            for i := 6 to n do
              if Hero^[h].Skill[i] = sk then found := true;
        end;
      until not found;
      New3Skill := sk;
    end;

  function Random3Skill: integer;
    var
      n, i, sk: integer;
      can: boolean;
    begin
      n := 10;
      while (Hero^[h].SkillLevel[n] = 0) and (n > 5) do dec(n);
      if n = 5 then
        sk := New3Skill
      else begin
        can := false;
        for i := 6 to n do
          if (Hero^[h].SkillLevel[i] <> 3)
             and not IsPicked(Hero^[h].Skill[i]) then
            can := true;
        if can then begin
          repeat
            i := random(n - 5) + 6;
          until (Hero^[h].SkillLevel[i] <> 3)
                and not IsPicked(Hero^[h].Skill[i]);
          sk := Hero^[h].Skill[i];
        end else
          sk := 0;
      end;
      Random3Skill := sk;
    end;

  function NewNSkill: integer;
    var
      n, sk, i: integer;
      found: boolean;
    begin
      n := 5;
      while (Hero^[h].SkillLevel[n] = 0) and (n > 0) do dec(n);
      repeat
        sk := random(NumNSkills) + 1;
        if IsPicked(sk) then found := true
        else begin
          found := false;
          if n > 0 then
            for i := 1 to n do
              if Hero^[h].Skill[i] = sk then found := true;
        end;
      until not found;
      NewNSkill := sk;
    end;

  function RandomNSkill: integer;
    var
      n, sk, i: integer;
      can: boolean;
    begin
      repeat
        n := 5;
        while (Hero^[h].SkillLevel[n] = 0) and (n > 0) do dec(n);
        if n = 0 then
          sk := NewNSkill
        else begin
          can := false;
          for i := 1 to n do
            if not IsPicked(Hero^[h].Skill[i]) then
              can := true;
          if can then begin
            n := random(n) + 1;
            sk := Hero^[h].Skill[n];
          end else
            sk := 0;
        end;
      until (sk = 0) or not IsPicked(sk);
      RandomNSkill := sk;
    end;

  procedure AddSkillChoice(sk: integer);
    var
      i: integer;
      got: boolean;
    begin
      if sk <> 0 then begin
        got := false;
        for i := 1 to 5 do
          if not got and (skc[i] = 0) then begin
            skc[i] := sk;
            got := true;
            inc(numchoices);
          end;
      end;
    end;

  procedure AddNewOrRandomN;
    begin
      if canN then
        AddSkillChoice(NewNSkill)
      else
        AddSkillChoice(RandomNSkill);
    end;

  var
    i: integer;
  begin
    msps := MaxSkillsPerSide;
    maxchoices := 2;
    Cunning := GetEffSkillLevel(h, skCunning);
    if Cunning > 0 then inc(maxchoices);
    if Cunning > 3 then inc(maxchoices);

    canN := (Hero^[h].SkillLevel[msps] = 0)
            or ((Hero^[h].SkillLevel[msps + 1] = 0) and (Cunning >= 2));
    can3 := (Hero^[h].SkillLevel[5 + msps] = 0)
            or ((Hero^[h].SkillLevel[6 + msps] = 0) and (Cunning >= 3));

    for i := 1 to 5 do skc[i] := 0;
    numchoices := 0;

    if Hero^[h].Expertise <> 0 then begin
      AddSkillChoice(Hero^[h].Expertise);
      inc(maxchoices);
    end;

    if Hero^[h].level mod 2 = 0 then begin
      {
        new N - old N
        old 3 - new 3 - old N
        new 3 - old 3 - newN - old N
      }
      AddNewOrRandomN;
      i := Random3Skill;
      if i <> 0 then
        AddSkillChoice(i)
      else
        if can3 then
          AddSkillChoice(New3Skill)
        else
          AddSkillChoice(RandomNSkill);
      if Cunning > 0 then begin
        if can3 then
          AddSkillChoice(New3Skill)
        else begin
          i := Random3Skill;
          if i <> 0 then
            AddSkillChoice(i)
          else
            AddNewOrRandomN;
        end;
      end;
    end else begin
      {
        old N
        new 3 - new N - old 3 - old N
        new N - old N
      }
      AddSkillChoice(RandomNSkill);
      if can3 then
        AddSkillChoice(New3Skill)
      else if canN then
        AddSkillChoice(NewNSkill)
      else begin
        i := Random3Skill;
        if i <> 0 then
          AddSkillChoice(i)
        else
          AddSkillChoice(RandomNSkill);
      end;
      if Cunning > 0 then
        AddNewOrRandomN;
    end;

    if numchoices < maxchoices then
      AddNewOrRandomN;
    if numchoices < maxchoices then
      AddSkillChoice(Random3Skill);
    if numchoices < maxchoices then
      if can3 then
        AddSkillChoice(New3Skill);
    if numchoices < maxchoices then
      AddNewOrRandomN;
  end;

function AIPickSkill(h: integer; skc: TSkillChoices): integer;
  const
    MonsterAbilitySkill: array [1..FlagMax] of byte =
    (
      0, 0, 0, 0,
      skTactics, skTactics, skTactics, skTactics,
      skTactics, 0, 0, 0,
      0, skTactics, skTactics, skTactics,
      0, skLeadership, 0, 0,
      skTactics, skLeadership, 0, 0,
      skArchery, skLeadership, 0, skLeadership,
      255, skArchery, skHealing, 0,
      skLeadership, 0, 0, 0,
      skPower, skTactics, skHealing, skSummoning,
      0, skArchery, skTactics, skOffense,
      254, skLeadership, skTactics, 0,
      255, skHealing, skTactics, skSummoning,
      skSummoning, 0, 0, 254,
      0, 0, 0, 0,
      0, 0, 0, skLeadership,
      skSummoning, 0, 0, 0,
      skLeadership, skLeadership, 0, 0,
      skTactics, 0, 0, 0,
      0, skLeadership, 0, 0,
      0, skLeadership, skLeadership, 0,
      0, 0
    );
  var
    score: array [1..5] of integer;

  procedure NukeSkill(s, v: integer);
    var i: integer;
    begin
      for i := 1 to 5 do
        if skc[i] = s then score[i] := v;
    end;

  procedure BoostSkill(s, v: integer);
    var i: integer;
    begin
      for i := 1 to 5 do
        if skc[i] = s then inc(score[i], v);
    end;

  procedure HurtSkill(s, v: integer);
    begin
      if GetSkillLevel(h, s) = 0 then BoostSkill(s, v);
    end;

  var
    i, besti, bestscore: integer;
  begin
    for i := 1 to 5 do
      if skc[i] = 0 then
        score[i] := 0
      else
        score[i] := 64 - GetEffSkillLevel(h, skc[i]);

    if GetSkillLevel(h, skDarkArts) > 0 then NukeSkill(skSpellcraft, 3);
    if GetSkillLevel(h, skSpellcraft) > 0 then NukeSkill(skDarkArts, 5);

    if h <> Player[Hero^[h].player].Dudes[1] then begin
      BoostSkill(skSummoning, 126);
      BoostSkill(skAlchemy, 124);
      BoostSkill(skPathfinding, 122);
      BoostSkill(skCunning, 120);
      BoostSkill(skGating, 118);
      BoostSkill(skLore, 116);
      BoostSkill(skLeadership, 114);
    end;

    if GetSkillLevel(h, skArchery) > 2 then
      NukeSkill(skArchery, 7);

    if GetSkillLevel(h, skPersuasion) > 0 then
      BoostSkill(skLeadership, 4);

    if GetSkillLevel(h, skPower) > 0 then begin
      BoostSkill(skSpellcraft, 4);
      BoostSkill(skDarkArts, 4);
      BoostSkill(skWarcraft, 2);
    end;

    if Twists[twDoubleXP] then BoostSkill(skLore, 2);
    if Twists[twAllGainXP] then BoostSkill(skLore, 2);
    if Twists[twOneUseBuildings] then BoostSkill(skLore, 2);

    if Twists[tw10Towers] then begin
      HurtSkill(skArchery, -6);
      HurtSkill(skPower, -2);
      BoostSkill(skSummoning, 4);
      BoostSkill(skDarkArts, 4);
      BoostSkill(skLeadership, 2);
    end;

    if Twists[twMax4Skills] then begin
      BoostSkill(skPathfinding, 8);
      BoostSkill(skSummoning, 8);
      BoostSkill(skDarkArts, 8);
      BoostSkill(skOffense, 8);
      BoostSkill(skDefense, 8);
      BoostSkill(skCunning, 8);
      BoostSkill(skWarcraft, 8);
      HurtSkill(skSpellcraft, -4);
      if (GetSkillLevel(h, skSpellcraft) = 0)
         and (GetSkillLevel(h, skDarkArts) = 0) then begin
        HurtSkill(skPower, -8);
        HurtSkill(skSorcery, -8);
        HurtSkill(skWitchcraft, -8);
        HurtSkill(skWizardry, -8);
        HurtSkill(skLore, -8);
      end;
    end;

    if Twists[twTerrainsAffectCombat] then begin
      BoostSkill(skArchery, 2);
      BoostSkill(skPower, 2);
    end;

    if Twists[twOnly2Heroes] then begin
      BoostSkill(skPathfinding, 8);
      BoostSkill(skGating, 8);
      BoostSkill(skSummoning, 8);
      BoostSkill(skDarkArts, 8);
      BoostSkill(skLeadership, 8);
      BoostSkill(skWarcraft, 8);
      BoostSkill(skPersuasion, 4);
    end;

    if Twists[twSkipWeekend] then begin
      BoostSkill(skSummoning, 4);
      BoostSkill(skAlchemy, 4);
      BoostSkill(skGating, 4);
      BoostSkill(skSpellcraft, 4);
    end;

    if Twists[twDwellingsAppear] then begin
      BoostSkill(skWarcraft, 24);
      BoostSkill(skLeadership, 4);
      BoostSkill(skPersuasion, 4);
    end;

    if Hero^[h].Equipped[13] <> 0 then BoostSkill(skAlchemy, 4);

    if Twists[twMonstersHaveAbility] then begin
      i := MonsterAbilitySkill[AllMonstersAbility];
      if i = 255 then begin
        HurtSkill(skOffense, -4);
        HurtSkill(skDefense, -4);
      end else if i = 254 then begin
        HurtSkill(skHealing, -4);
      end else if i > 0 then begin
        BoostSkill(i, 4);
        if i = skPower then begin
          BoostSkill(skSpellcraft, 4);
          BoostSkill(skDarkArts, 4);
          BoostSkill(skLore, 4);
          BoostSkill(skWizardry, 4);
        end else if i = skSummoning then begin
          BoostSkill(skDarkArts, 4);
          BoostSkill(skGating, 4);
          BoostSkill(skPersuasion, 4);
          BoostSkill(skWarcraft, 4);
          BoostSkill(skConjuring, 4);
        end;
      end;
    end;

    bestscore := score[1];
    besti := 1;

    for i := 2 to 5 do
      if score[i] > bestscore then begin
        bestscore := score[i];
        besti := i;
      end;

    AIPickSkill := besti;
  end;

function AIPickSpell(h, sp1, sp2: integer): integer;
  var sp: integer;
  begin
    if CheckForSpell(Hero^[h].SS, sp1) then
      sp := 2
    else if CheckForSpell(Hero^[h].SS, sp2) then
      sp := 1
    else if GetEffSkillLevel(h, skWizardry) > 0 then
      sp := 2
    else
      sp := 1;

    AIPickSpell := sp;
  end;

procedure AIHeroTalk(h1, h2: integer);

  procedure TryToGive(pb: PByte);
    var j, t, sl: integer;
    begin
      if pb^ <> 0 then
        with Hero^[h1] do begin
          sl := ArtData[pb^].slot;
          for j := 1 to EquipSlots(h1) do
            if (EquipSlot[j] = sl)
               and ((Equipped[j] = 0)
                    or (ArtData[Equipped[j]].AIval
                        < ArtData[pb^].AIval)) then begin
              t := Equipped[j];
              Equipped[j] := pb^;
              pb^ := t;
            end;
        end;
    end;

  var i: integer;
  begin
    if Hero^[h2].XP > Hero^[h1].XP then begin
      i := h1;
      h1 := h2;
      h2 := i;
    end;

    ShareTroops(@Hero^[h1].army, @Hero^[h2].army,
                HeroSlots(h1), HeroSlots(h2));

    for i := 1 to EquipSlots(h2) do TryToGive(@Hero^[h2].Equipped[i]);
    for i := 1 to BackpackSize do TryToGive(@Hero^[h2].Backpack[i]);

    with Hero^[h1] do
      for i := 1 to BackpackSize do
        if Backpack[i] <> 0 then
          if GainArt(h2, Backpack[i]) then
            Backpack[i] := 0;

    WearBestArts(h2);
  end;

function SkillGraphic(sk: integer): PGraphic;
  const
    WitchcraftGr: TGraphic =
    ('******....', { witchcraft }
     '********..',
     '**********',
     '******....',
     '***  ****.',
     '*******.**',
     '*******...',
     '*****.....',
     '*****.*...',
     '*******...');
    GatingGr: TGraphic =
    ('.********.', { gating }
     '.*      *.',
     '.*      *.',
     '.*      *.',
     '.* **   *.',
     '.* **   *.',
     '.*      *.',
     '.*      *.',
     '.*      *.',
     '.********.');
    SummoningGr: TGraphic =
    ('...***....', { summoning }
     '...***....',
     '..*.*.....',
     '...****...',
     '....*.....',
     '....*. *..',
     '.* * *  *.',
     '*  * *   *',
     '*        *',
     '.********.');
    ExpertiseGr: TGraphic =
    ('...*******', { expertise }
     '..*     *.',
     '..*    *..',
     '.*    * *.',
     '.*   *   *',
     '*   *  **.',
     '*  ** *...',
     '***.**....',
     '*.........',
     '*.........');
    InsightGr: TGraphic =
    ('.....***..', { insight }
     '....*...*.',
     '...*..*..*',
     '...*.*...*',
     '...*.....*',
     '...**...*.',
     '..******..',
     '.***......',
     '***.......',
     '.*........');
  var
    g: PGraphic;
  begin
    case sk of
      skPower:       g := @CombatIcons[fxBolt];
      skHealing:     g := @CombatIcons[fxHeal];
      skSpellcraft:  g := @ArtGraphics[agWand];
      skOffense:     g := @ArtGraphics[agSword];
      skDefense:     g := @ArtGraphics[agShield];
      skArchery:     g := @ArtGraphics[agBow];
      skPathfinding: g := @ArtGraphics[agBoots];
      skPersuasion:  g := @ArtGraphics[agEye];
      skSummoning:   g := @SummoningGr;
      skDarkArts:    g := @ArtGraphics[agSkull];
      skWarcraft:    g := @ArtGraphics[agAxe];
      skConjuring:   g := @ArtGraphics[agBell];
      skSorcery:     g := @ArtGraphics[agRing];
      skWitchcraft:  g := @WitchcraftGr;
      skTactics:     g := @ArtGraphics[agGlove];
      skCunning:     g := @CastleIcons[ciPlan];
      skLore:        g := @ArtGraphics[agScroll];
      skWizardry:    g := @CastleIcons[ciSpells2];
      skAlchemy:     g := @MapGraphics^[mgPotion];
      skGating:      g := @GatingGr;
      skLeadership:  g := @CastleIcons[ciBuyCreatures];
      skSpecialty:   g := @MapGraphics^[mgCamp];
      skExpertise:   g := @ExpertiseGr;
      skInsight:     g := @InsightGr;
    end;
    SkillGraphic := g;
  end;

function HeroPersuasionGP(h: integer): longint;
  begin
    HeroPersuasionGP := GetEffSkillLevel(h, skPersuasion)
                        * longint(PersuasionAmt)
                        + NumTroopsWithFlag(h, 6, f6Persuasion) * 50;
  end;

function HeroNumShots(h: integer): integer;
  var hns: integer;
  begin
    if GetEffSkillLevel(h, skArchery) = 0 then
      hns := 0
    else begin
      hns := 1 + CountArt(h, anBowOfSpeed, true);
      if HeroHasExpertiseBonus(h, skArchery) then inc(hns);
    end;
    HeroNumShots := hns;
  end;

procedure GiveSummoning(h: integer; gp: longint);
  var a, j: integer;
  begin
    with Hero^[h] do begin
      inc(SummoningAmt, gp);
      a := FindEmptyOrMonster(@army, HeroSlots(h), SummonedCr);
      if a > 0 then begin
        j := SummoningAmt div MonsterData[SummonedCr].cost;
        army[a].monster := SummonedCr;
        inc(army[a].qty, j);
        dec(SummoningAmt, j * MonsterData[SummonedCr].cost);
      end;
    end;
  end;

procedure GiveWarcraft(h, lev: integer);
  begin
    inc(Hero^[h].MP, lev div 4);
    GiveMana(h, lev);
    GiveSummoning(h, WarCraftGP * lev);
  end;

procedure GiveHeroDailyMPSP(h: integer);
  var n: integer;
  begin
    with Hero^[h] do begin
      n := HeroMaxMP(h);
      if HasArt(h, anBootsOfEndurance, true) then begin
        inc(MP, n);
        if MP > n * 2 then MP := n * 2;
      end else
        MP := n;

      GiveMana(h, HeroDailySP(h));
    end;
  end;

function HeroDailyAlchemy(h: integer): string;
  var
    n, a: integer;
    s: string;
  begin
    s := '';
    with Hero^[h] do begin
      n := GetEffSkillLevel(h, skAlchemy);
      if n > 3 then n := 3;
      if n > 0 then begin
        inc(AlchemyDay);
        if AlchemyDay >= 7 then begin
          AlchemyDay := 0;
          if LastAlchemy < n then
            inc(LastAlchemy)
          else
            LastAlchemy := 1;
          a := RandomArtifact(LastAlchemy);
          if GainArt(h, a) then
            s := dgcFace + chr(h) + Name
                 + ' finishes work on ' + AnArtName(a) + '!'
          else begin
            AlchemyDay := 6;
            LastAlchemy := n - 1;
            s := dgcFace + chr(h) + Name
                 + ' would have finished work on an artifact '
                 + 'today, but had nowhere to put it.';
          end;
        end;
      end;
    end;
    HeroDailyAlchemy := s;
  end;

procedure HeroDailySummoning(h: integer);
  var n, g, t, m: integer;
  begin
    n := GetEffSkillLevel(h, skSummoning);
    if n > 0 then
      GiveSummoning(h, n * SummoningGP);

    if HeroHasExpertiseBonus(h, skSummoning) then begin
      m := Hero^[h].SummonedCr;
      for g := 1 to MaxTowns do begin
        t := Player[Hero^[h].player].Towns[g];
        if (t <> 0) and (Castle[t].CT = Hero^[h].ct) then
          GiveCastleSummoning(t, m);
      end;
    end;

  end;

procedure HeroDailyGating(h: integer);
  var n, j, g, t, m, m2, q, q2: integer;
  begin
    with Player[Hero^[h].player], Hero^[h] do begin
      n := GetEffSkillLevel(h, skGating);
      if n > 0 then begin
        inc(GatingAmt, n * GatingGP);
        for j := 6 downto 1 do
          for g := 1 to MaxTowns do begin
            t := Towns[g];
            if (t <> 0) and (Castle[t].CT = CT) then
              for m := 1 to 6 do begin
                m2 := Castle[t].Garrison[m].monster;
                q := Castle[t].Garrison[m].qty;
                if (q > 0) and (MonsterLevel(m2) = j) then begin
                  q2 := GatingAmt div MonsterData[m2].cost;
                  if q2 > q then q2 := q;
                  if q2 > 0 then begin
                    if GainMonster(@Hero^[h].army, HeroSlots(h), m2,
                                   q2) then begin
                      dec(Castle[t].Garrison[m].qty, q2);
                      dec(GatingAmt, MonsterData[m2].cost * q2);
                    end;
                  end;
                end;
              end;
          end;
      end;
    end;
  end;

function HeroDailyInsight(h: integer): string;
  var
    i, q, q2, ml, sl: integer;
    s: string;
  begin
    s := '';
    with Hero^[h] do begin
      if GetEffSkillLevel(h, skSpecialty) >= 4 then begin
        q := 10;
        ml := MonsterLevel(Specialty);
        sl := HeroSlots(h);
        for i := 1 to sl do
          if (q > 0) and (army[i].qty > 0)
             and (army[i].monster <> Specialty)
             and (MonsterLevel(army[i].monster) = ml) then begin
            q2 := army[i].qty;
            if q2 > q then q2 := q;
            if GainMonster(@army, sl, Specialty, q2) then begin
              dec(q, q2);
              dec(army[i].qty, q2);
            end;
          end;
      end;

      if GetEffSkillLevel(h, skExpertise) >= 4 then begin
        inc(ExpertiseArtDay);
        if ExpertiseArtDay >= 4 then begin
          ExpertiseArtDay := 0;
          if GainArt(h, SkillArt[Expertise]) then
            s := dgcFace + chr(h) + Name
                 + ' finishes work on ' + AnArtName(SkillArt[Expertise]) + '!'
          else begin
            ExpertiseArtDay := 3;
            s := dgcFace + chr(h) + Name
                 + ' would have finished work on an artifact '
                 + 'today, but had nowhere to put it.';
          end;
        end;

      end;
    end;
    HeroDailyInsight := s;
  end;

{ THeroScr methods }

constructor THeroScr.Init(iHeroNum: integer; iJustThisHero: boolean);
  begin
    TObject.Init;
    Bar := nil;
    JustThisHero := iJustThisHero;
    SetHero(iHeroNum);
  end;

destructor THeroScr.Done;
  begin
    TObject.Done;
  end;

procedure THeroScr.SetHero(h: integer);
  var i, pl, HeroIdx: integer;
  begin
    HeroNum := h;
    ArtNum := 0;
    ArtOfs := 0;

    if Bar <> nil then Dispose(Bar, Done);
    Bar := New(PArmyBar, Init(56, 390 + 45, @Hero^[HeroNum].army,
                              HeroSlots(HeroNum), 56, 380, h, false));

    HeroIdx := 0;
    pl := Hero^[HeroNum].player;
    for i := 1 to MaxDudes do
      if Player[pl].Dudes[i] = HeroNum then
        HeroIdx := i;

    if (HeroIdx <> 0) and not JustThisHero then begin
      i := HeroIdx - 1;
      if i < 1 then begin
        i := MaxDudes;
        while Player[pl].Dudes[i] = 0 do dec(i);
      end;
      if i = HeroIdx then
        PrevHero := 0
      else
        PrevHero := Player[pl].Dudes[i];

      i := HeroIdx + 1;
      if (i > MaxDudes) or (Player[pl].Dudes[i] = 0) then i := 1;
      if i = HeroIdx then
        NextHero := 0
      else
        NextHero := Player[pl].Dudes[i];

      if PrevHero = NextHero then PrevHero := 0;
    end else begin
      PrevHero := 0;
      NextHero := 0;
    end;
  end;

procedure THeroScr.GetArtXY(num: integer; eq: boolean; var x, y: integer);
  const
    EqXY: array [1..18] of record
      x, y: integer;
    end =
    (
      (x: 16; y: 108 + 60),
      (x: 16 + 40; y: 108 + 60),
      (x: 16; y: 108),
      (x: 16 + 40; y: 108),
      (x: 16 + 120; y: 108),
      (x: 16 + 120 + 40; y: 108),
      (x: 16 + 240; y: 108),
      (x: 16 + 120; y: 108 + 60),
      (x: 16 + 120 + 40; y: 108 + 60),
      (x: 16 + 240; y: 108 + 60),
      (x: 16 + 240 + 40; y: 108 + 60),
      (x: 16; y: 108 + 120),
      (x: 16 + 40; y: 108 + 120),
      (x: 16 + 80; y: 108 + 120),
      (x: 16 + 120; y: 108 + 120),
      (x: 16 + 160; y: 108 + 120),
      (x: 16 + 200; y: 108 + 120),
      (x: 16 + 240; y: 108 + 120)
    );
  begin
    if eq then begin
      x := EqXY[num].x;
      y := EqXY[num].y;
    end else begin
      x := 16 + 40 * ((num - 1) mod 8);
      y := 108 + 180 + 40 * ((num - 1) div 8);
    end;
  end;

function THeroScr.ArtPtr(num: integer; eq: boolean): PByte;
  begin
    if eq then
      ArtPtr := @Hero^[HeroNum].Equipped[num]
    else
      ArtPtr := @Hero^[HeroNum].Backpack[num];
  end;

procedure DrawBackpackArrow(a, b, h, aofs: integer);
  begin
    if Hero^[h].Backpack[16] <> 0 then begin
      if aofs = 0 then
        DrawIcon(a, b, @RightArrow)
      else
        DrawIcon(a, b, @LeftArrow);
    end else
      DrawArt(a, b, 0);
  end;

procedure THeroScr.DrawArts;
  var i, a, b: integer;
  begin
    SortBackpack(HeroNum);
    if Hero^[HeroNum].Backpack[16] = 0 then ArtOfs := 0;

    for i := 1 to EquipSlots(HeroNum) do begin
      GetArtXY(i, true, a, b);
      DrawArt(a, b, Hero^[HeroNum].Equipped[i]);
    end;

    for i := 1 to 15 do begin
      GetArtXY(i, false, a, b);
      DrawArt(a, b, Hero^[HeroNum].Backpack[ArtOfs + i]);
    end;

    GetArtXY(16, false, a, b);
    DrawBackpackArrow(a, b, HeroNum, ArtOfs);

    if ArtNum <> 0 then begin
      if ArtEq then
        i := ArtNum
      else
        i := ArtNum - ArtOfs;
      GetArtXY(i, ArtEq, a, b);
      XRectangle(a, b, a + 39, b + 39, colWhite);
    end;
  end;

procedure THeroScr.Draw;
  var
    i, j, d: integer;
    s: string;

  procedure SkillLine(x, sk, c: integer);
    var sky, skl, sksk, spec: integer;
    begin
      skl := Hero^[HeroNum].SkillLevel[sk];
      if skl > 0 then begin
        sksk := Hero^[HeroNum].Skill[sk];
        sky := (i - 1) * 12 + 36;
        DrawText(x, sky, colBlack, c, SkillNames[sksk] + ' ' + IStr(skl, 0));
        if (sksk = skSummoning) or (sksk = skConjuring)
           or (sksk = skWarcraft) then
          DrawSmallGraphic2c(x - 12, sky - 2, colLightBlue, colBlack,
                             MonsterGraphic(Hero^[HeroNum].SummonedCr)^)
        else if sksk = skSpecialty then begin
          spec := Hero^[HeroNum].Specialty;
          if spec > 0 then
            DrawSmallGraphic2c(x - 12, sky - 2, colYellow, colBlack,
                               MonsterGraphic(spec)^);
        end else if sksk = skExpertise then begin
          spec := Hero^[HeroNum].Expertise;
          if spec > 0 then
            DrawSmallGraphic2c(x - 12, sky - 2, colYellow, colDarkGray,
                               SkillGraphic(spec)^);
        end;
      end;
    end;

  function plurald: string;
    begin
      if d > 1 then
        plurald := 's'
      else
        plurald := '';
    end;

  begin
    Bar^.Draw;
    DrawHero(16, 437, colLightGray, HeroNum);

    s := Hero^[HeroNum].name;
    case Hero^[HeroNum].HermitBonus of
      hbEye:     s := s + ' aka "The Eye"';
      hbWrecker: s := s + ' aka "The Wrecker"';
      hbKiller:  s := s + ' aka "The Killer"';
      hbMystic:  s := s + ' aka "The Mystic"';
    end;
    DrawText(16, 12, colBlack, colWhite, s);

    i := 16;
    d := Hero^[HeroNum].ShrineDays;
    if d > 0 then begin
      DrawText(i, 24, colBlack, colLightGray, '+2 ');
      DrawSmallGraphic2c(i + 24 - 1, 24 - 1, colLightGray, colDarkGray,
                         SkillGraphic(Hero^[HeroNum].ShrineBonus)^);
      inc(i, 34);
      if Hero^[HeroNum].HermitBonus <> hbMystic then begin
        s := ' (' + IStr(d, 0) + ' day' + plurald + ')';
        DrawText(i, 24, colBlack, colLightGray, s);
        inc(i, 8 * length(s));
      end;
    end;
    d := Hero^[HeroNum].AltarDays;
    if d > 0 then begin
      if i <> 16 then begin
        DrawText(i, 24, colBlack, colLightGray, ', ');
        inc(i, 16);
      end;
      s := Altars[Hero^[HeroNum].AltarBonus].Name;
      if Hero^[HeroNum].HermitBonus <> hbMystic then
        s := s + ' (' + IStr(d, 0) + ' day' + plurald + ')';
      DrawText(i, 24, colBlack, colLightGray, s);
    end;

    DrawText(16, 36, colBlack, colWhite,
             'Level: ' + IStr(Hero^[HeroNum].level, 0));
    DrawSmallGraphic2c(16 + 2, 48 - 1, colWhite, colBlack,
                       CastleIcons[ciPlan]);
    DrawText(16 + 16, 48, colBlack, colWhite,
             'XP:  ' + LStr(Hero^[HeroNum].XP, 0) + ' / '
             + LStr(XPForLevel(Hero^[HeroNum].level), 0));
    DrawSmallGraphic2c(16 + 1, 60 - 1, colGreen, colBlack, Horsie);
    DrawText(16 + 16, 60, colBlack, colGreen,
             'MP:  ' + LSet(IStr(Hero^[HeroNum].MP, 0) + ' / '
                            + IStr(HeroMaxMP(HeroNum), 0), 10));
    DrawSmallGraphic2c(16 + 1, 72 - 1, colBlue, colBlue, ArtGraphics[agWand]);
    DrawText(16 + 16, 72, colBlack, colBlue,
             'SP:  ' + LSet(IStr(Hero^[HeroNum].SP, 0) + ' / '
                            + IStr(HeroMaxSP(HeroNum), 0) + ' ('
                            + IStr(HeroDailySP(HeroNum), 0) + '/day, '
                            + IStr(HeroSPPerRound(HeroNum), 0) + '/round)',
                            30));

    DrawText(368, 12, colBlack, colWhite, 'Skills:');
    DrawText(368, 116, colBlack, colWhite, 'Spells:');

    DrawText(16, 96, colBlack, colWhite, 'Weapons:');
    DrawText(16 + 120, 96, colBlack, colWhite, 'Armor:');
    DrawText(16 + 240, 96, colBlack, colWhite, 'Boots:');
    DrawText(16, 96 + 60, colBlack, colWhite, 'Rings:');
    DrawText(16 + 120, 96 + 60, colBlack, colWhite, 'Necklaces:');
    DrawText(16 + 240, 96 + 60, colBlack, colWhite, 'Tools:');
    DrawText(16, 96 + 120, colBlack, colWhite, 'Gear:');
    DrawText(16, 96 + 180, colBlack, colWhite, 'Backpack:');

    DrawSpellSet(368, 140, Hero^[HeroNum].SS);

    for i := 1 to 5 do begin
      SkillLine(368, i, colLightBlue);
      SkillLine(368 + 136, i + 5, colYellow);
    end;

    if not HasSummonCreatureSkill(HeroNum, false) then begin
      i := 5;
      while (Hero^[HeroNum].Skill[i] = 0) and (i > 0) do dec(i);
      inc(i);
      j := (i - 1) * 12 + 36;
      DrawText(368, j, colBlack, colDarkGray, 'Friend to');
      DrawSmallGraphic2c(368 + 8 * 10, j - 2, colDarkGray, colBlack,
                         MonsterGraphic(Hero^[HeroNum].SummonedCr)^)
    end;

    DrawArts;

    if PrevHero <> 0 then DrawHero(600 - 120, 440, colLightGray, PrevHero);
    if NextHero <> 0 then DrawHero(600 - 60, 440, colLightGray, NextHero);

    DrawIcon(600, 440, @ExitIcon);
  end;

procedure THeroScr.HandleUsedArt(a: integer);
  var
    s: string;
    pl, t, h, h2, nx, ny, nx2, ny2: integer;
    gotone: boolean;
  begin
    case a of
      anPortableHole:    s := 'You may drop the Portable Hole to swallow '
                              + 'up all nearby neutral monsters.';
      anPortableGateway: s := 'You may step through the Portable Gateway '
                              + 'to return to your oldest castle.';
      anCrownOfBreeding: s := 'You may leave the Crown Of Breeding in a '
                              + 'castle to increase creature production '
                              + 'there.';
      anMercenarysCrown: s := 'You may leave the Mercenary''s Crown in a '
                              + 'castle to make creatures cheaper there.';
      anCrownOfOffense:  s := 'You may leave the Crown of Offense in a '
                              + 'castle to give all allied troops +10% '
                              + 'damage.';
      anCrownOfDefense:  s := 'You may leave the Crown of Defense in a '
                              + 'castle to give all allied troops +10% '
                              + 'hit points.';
      anCrownOfTactics:  s := 'You may leave the Crown of Tactics in a '
                              + 'castle to give all allied troops +0.5 '
                              + 'speed.';
    end;

    if BaseDialog(s + ' Do you?', dgArtifact + a, dgCancel, 0, 0,
                  'Do it', 'Cancel', '', '') = 1 then begin
      case a of
        anPortableHole:
          begin
            gotone := false;
            for h := 1 to 6 do
              if FindAdjMapHex(h, Hero^[HeroNum].MapX, Hero^[HeroNum].MapY,
                               nx, ny) then
                for h2 := 1 to 6 do
                  if FindAdjMapHex(h2, nx, ny, nx2, ny2) then
                    if TheMap^[nx2, ny2] in [mMonster, mHardMonster] then begin
                      gotone := true;
                      TheMap^[nx2, ny2] := mGrass;
                      MapInfo^[nx2, ny2] := 0;
                      MapNum^[nx2, ny2] := 0;
                    end;
            if gotone then
              LoseArt(HeroNum, a)
            else
              BaseMessage('There are no neutral monsters close enough.');
          end;
        anPortableGateway:
          begin
            pl := Hero^[HeroNum].player;
            t := Player[pl].Towns[1];
            if t = 0 then
              BaseMessage('You have no castles.')
            else if HeroAtSpot(Castle[t].MapX, Castle[t].MapY) <> 0 then
              BaseMessage('The way is blocked.')
            else begin
              if TheMap^[Hero^[HeroNum].MapX, Hero^[HeroNum].MapY] = mHero then
                TheMap^[Hero^[HeroNum].MapX, Hero^[HeroNum].MapY] := mGrass;
              Hero^[HeroNum].MapX := Castle[t].MapX;
              Hero^[HeroNum].MapY := Castle[t].MapY;
              LoseArt(HeroNum, a);
            end;
          end;
        anCrownOfBreeding..anCrownOfTactics:
          begin
            if TheMap^[Hero^[HeroNum].MapX, Hero^[HeroNum].MapY]
               in [mJungleFort..mLastCastle] then begin
              pl := Hero^[HeroNum].player;
              t := MapInfo^[Hero^[HeroNum].MapX, Hero^[HeroNum].MapY];
              if PlaceCrown(t, a) then
                LoseArt(HeroNum, a)
              else
                BaseMessage('You must build a treasure chamber in the '
                            + 'castle first.');
            end else
              BaseMessage('Hero must be visiting a castle.');
          end;
      end;
    end;

    ClearScr;
    Draw;
  end;

procedure THeroScr.Handle;
  var
    over, goteq, did: boolean;
    E: TEvent;
    x, y, i, goti, gotart, sp, ax, ay: integer;
    p: PByte;

  procedure FindArtClick;
    var n: integer;

    procedure CheckArtClick(apos, an: integer; eq: boolean);
      var a, b, art: integer;
      begin
        GetArtXY(apos, eq, a, b);
        if eq then
          art := Hero^[HeroNum].Equipped[an]
        else
          art := Hero^[HeroNum].Backpack[an];
        if (x >= a) and (y >= b) and (x < a + 40) and (y < b + 40)
           and (art <> 0) then begin
          goti := an;
          goteq := eq;
          gotart := art;
        end;
      end;

    begin
      goti := 0;
      gotart := 0;
      for n := 1 to EquipSlots(HeroNum) do CheckArtClick(n, n, true);
      for n := 1 to 15 do CheckArtClick(n, ArtOfs + n, false);
    end;

  procedure TryToMoveArt;
    begin
      if goteq then begin
        if PackArt(HeroNum, gotart) then begin
          Hero^[HeroNum].Equipped[goti] := 0;
          ArtNum := 0;
        end else begin
          ArtNum := goti;
          ArtEq := goteq;
        end;
      end else begin
        if EquipArt(HeroNum, gotart) then begin
          Hero^[HeroNum].Backpack[goti] := 0;
          ArtNum := 0;
        end else begin
          ArtNum := goti;
          ArtEq := goteq;
        end;
      end;
    end;

  procedure HeroScrMessage(s: string);
    begin
      BaseMessage(s);
      ClearScr;
      Draw;
    end;

  begin
    over := false;
    ArtNum := 0;

    DrawBackground := false;
    ClearScr;
    Draw;

    repeat
      WaitForEvent(E);
      if E.What = evMouseDown then begin
        if E.Buttons = mbLeftButton then begin
          x := E.Where.X;
          y := E.Where.Y;

          if not JustThisHero and Bar^.HandleClick(E) then begin
            { handled by HandleClick }
          end else if (x >= 600) and (y >= 440) then begin
            over := true;
          end else if (x >= 600 - 60) and (y >= 440) then begin
            if NextHero > 0 then begin
              SetHero(NextHero);
              ClearScr;
              Draw;
            end;
          end else if (x >= 600 - 120) and (y >= 440) then begin
            if PrevHero > 0 then begin
              SetHero(PrevHero);
              ClearScr;
              Draw;
            end;
          end else begin
            FindArtClick;
            if (goti <> 0) and not JustThisHero then begin
              if ArtNum <> 0 then begin
                p := ArtPtr(ArtNum, ArtEq);
                if ArtData[p^].slot = ArtData[gotart].slot then begin
                  ArtPtr(goti, goteq)^ := p^;
                  p^ := gotart;
                  ArtNum := 0;
                end else begin
                  ArtNum := 0;
                  TryToMoveArt;
                end;
              end else begin
                TryToMoveArt;
                if (ArtNum <> 0)
                   and (Hero^[HeroNum].Backpack[ArtNum]
                        in [anPortableHole, anPortableGateway,
                            anCrownOfBreeding..anCrownOfTactics]) then begin
                  HandleUsedArt(Hero^[HeroNum].Backpack[ArtNum]);
                  ArtNum := 0;
                end;
              end;
              Draw;
            end;
            GetArtXY(16, false, ax, ay);
            if (x >= ax) and (y >= ay) and (x < ax + 40) and (y < ay + 40)
               and (Hero^[heroNum].Backpack[16] <> 0) then begin
              ArtOfs := 15 - ArtOfs;
              if not ArtEq then ArtNum := 0;
              Draw;
            end;
          end;
        end else if E.Buttons = mbRightButton then begin
          x := E.Where.X;
          y := E.Where.Y;

          if Bar^.HandleRightClick(E) then begin
            Draw;
          end else if (x >= 368) and (y >= 36) and (y < 36 + 6 * 12) then begin
            i := (y - 36) div 12 + 1;
            if x >= 368 + 136 then inc(i, 5);
            if ((i < 6) or (x >= 368 + 136)) and (i < 11)
               and (Hero^[HeroNum].SkillLevel[i] > 0) then
              HeroScrMessage(SkillStr(HeroNum, Hero^[HeroNum].Skill[i], 0))
            else if (i >= 1) and (i <= 6) and (x < 368 + 136)
                    and ((i = 1) or (Hero^[HeroNum].SkillLevel[i - 1] > 0))
                    and not HasSummonCreatureSkill(HeroNum, false) then
              HeroScrMessage(chr(colLightGray) + 'This hero would summon '
                             + MonsterData[Hero^[HeroNum].SummonedCr].pname
                             + ' with Summoning, Conjuring, or Warcraft.');
          end else begin
            sp := SpellSetClick(Hero^[HeroNum].SS, 368, 140, x, y);
            if sp <> 0 then
              HeroScrMessage(SpellHintStr(sp, HeroNum, 0))
            else begin
              FindArtClick;
              if gotart <> 0 then
                HeroScrMessage(ArtData[gotart].name + chr(colLightGray)
                               + ' - ' + ArtHelp^[gotart]);
            end;
          end;
        end;
      end;
    until over;

    LimitMana(HeroNum);
  end;

procedure DoHeroScreen(h: integer; JustThisHero: boolean);
  var
    HS: PHeroScr;
    DB: boolean;
  begin
    DB := DrawBackground;
    New(HS, Init(h, JustThisHero));
    HS^.Handle;
    Dispose(HS, Done);
    DrawBackground := DB;
    ClearScr;
  end;

{ THeroTalkScr methods }

constructor THeroTalkScr.Init(iHero1, iHero2: integer);
  var i: integer;
  begin
    TObject.Init;

    HTR[1].HeroNum := iHero1;
    HTR[2].HeroNum := iHero2;

    for i := 1 to 2 do begin
      New(HTR[i].Bar, Init(56, 91 + (i - 1) * 240, @Hero^[HTR[i].HeroNum].army,
                           HeroSlots(HTR[i].HeroNum), 56, (i - 1) * 240 + 36,
                           HTR[i].HeroNum, false));
      HTR[i].ArtOfs := 0;
    end;

    ArtNum := 0;
    ArtSide := 0;
  end;

destructor THeroTalkScr.Done;
  begin
    TObject.Done;
  end;

procedure THeroTalkScr.DrawArts;
  var h, i, x, y: integer;

  procedure GetArtXY(side, num: integer);
    begin
      x := 16 + 40 * ((num - 1) mod 8);
      y := 240 * (side - 1) + 140 + 40 * ((num - 1) div 8);
    end;

  begin
    for h := 1 to 2 do begin
      SortBackpack(HTR[h].HeroNum);
      if Hero^[HTR[h].HeroNum].Backpack[16] = 0 then HTR[h].ArtOfs := 0;
      for i := 1 to 15 do begin
        GetArtXY(h, i);
        DrawArt(x, y, Hero^[HTR[h].HeroNum].Backpack[i + HTR[h].ArtOfs]);
      end;
      GetArtXY(h, 16);
      DrawBackpackArrow(x, y, HTR[h].HeroNum, HTR[h].ArtOfs);
    end;

    if ArtNum <> 0 then begin
      GetArtXY(ArtSide, ArtNum - HTR[ArtSide].ArtOfs);
      XRectangle(x, y, x + 39, y + 39, colWhite);
    end;
  end;

procedure THeroTalkScr.Draw;
  var h, i, y: integer;
  begin
    for h := 1 to 2 do
      with HTR[h] do begin
        y := (h - 1) * 240;
        DrawText(16, y + 5, colBlack, colWhite, Hero^[HeroNum].name);
        DrawText(16, y + 18, colBlack, colWhite,
                 'Level: ' + IStr(Hero^[HeroNum].level, 0));

        Bar^.Draw;
        DrawHero(16, y + 93, colLightGray, HeroNum);
      end;

    DrawIcon(56 + 4 * 60, 36, @DownArrow);
    DrawIcon(56 + 4 * 60, 240 + 36, @UpArrow);

    DrawArts;
    DrawIcon(600, 440, @ExitIcon);
  end;

procedure THeroTalkScr.Handle;
  var
    over: boolean;
    E: TEvent;
    x, y, h, a, ca, i: integer;

  function ClickOnArt: boolean;
    var coa: boolean;
    begin
      coa := (x >= 16) and (x < 16 + 40 * 8)
             and (((y >= 140) and (y < 140 + 40 * 2))
                  or ((y >= 240 + 140) and (y < 240 + 140 + 40 * 2)));
      if coa then begin
        h := 1 + (y div 240);
        a := 1 + (x - 16) div 40 + (((y mod 240) - 140) div 40) * 8;
        if a = 16 then
          ca := -1
        else begin
          inc(a, HTR[h].ArtOfs);
          ca := Hero^[HTR[h].HeroNum].Backpack[a];
        end;
      end;
      ClickOnArt := coa;
    end;

  function ClickedOnArrow: boolean;
    begin
      ClickedOnArrow := (x >= 56 + 4 * 60) and (x < 56 + 4 * 60 + 40)
                        and (((y >= 36) and (y < 36 + 40))
                             or ((y >= 240 + 36)
                                 and (y < 240 + 36 + 40)));
    end;

  begin
    over := false;

    DrawBackground := false;
    ClearScr;
    Draw;

    repeat
      WaitForEvent(E);
      if E.What = evMouseDown then begin
        x := E.Where.X;
        y := E.Where.Y;
        if E.Buttons = mbLeftButton then begin
          if (x >= 600) and (y >= 440) then begin
            over := true;
          end else if HandleTwoBars(HTR[1].Bar, HTR[2].Bar, E) then begin
            { handled }
          end else if ClickOnArt then begin
            if ca = -1 then begin
              if Hero^[HTR[h].HeroNum].Backpack[16] <> 0 then begin
                HTR[h].ArtOfs := 15 - HTR[h].ArtOfs;
                if h = ArtSide then ArtNum := 0;
              end;
            end else if ArtNum <> 0 then begin
              if (a = ArtNum) and (h = ArtSide) then begin
                { just clear highlight }
              end else begin
                Hero^[HTR[h].HeroNum].Backpack[a]
                  := Hero^[HTR[ArtSide].HeroNum].Backpack[ArtNum];
                Hero^[HTR[ArtSide].HeroNum].Backpack[ArtNum] := ca;
              end;
              ArtNum := 0;
            end else if Hero^[HTR[h].HeroNum].Backpack[a] <> 0 then begin
              if PackArt(HTR[3 - h].HeroNum, ca) then begin
                Hero^[HTR[h].HeroNum].Backpack[a] := 0;
              end else begin
                ArtNum := a;
                ArtSide := h;
              end;
            end;
            DrawArts;
          end else if (x >= 16) and (x < 16 + 36)
                      and (((y >= 93) and (y < 93 + 36))
                           or ((y >= 93 + 240)
                               and (y < 93 + 240 + 36))) then begin
            if y >= 93 + 240 then h := 2 else h := 1;
            DoHeroScreen(HTR[h].HeroNum, false);
            Draw;
          end else if ClickedOnArrow then begin
            if y >= 240 + 36 then
              ShareTroops(@Hero^[HTR[1].HeroNum].army,
                          @Hero^[HTR[2].HeroNum].army,
                          HeroSlots(HTR[1].HeroNum),
                          HeroSlots(HTR[2].HeroNum))
            else
              ShareTroops(@Hero^[HTR[2].HeroNum].army,
                          @Hero^[HTR[1].HeroNum].army,
                          HeroSlots(HTR[2].HeroNum),
                          HeroSlots(HTR[1].HeroNum));
            for i := 1 to 2 do
              with HTR[i].Bar^ do begin
                CanDismiss := false;
                highlight := 0;
              end;
            Draw;
          end;
        end else if E.Buttons = mbRightButton then begin
          if HTR[1].Bar^.HandleRightClick(E)
             or HTR[2].Bar^.HandleRightClick(E) then begin
            Draw;
          end else if ClickOnArt and (ca > 0) then begin
            BaseMessage(ArtData[ca].name + chr(colLightGray) + ' - '
                        + ArtHelp^[ca]);
            ClearScr;
            Draw;
          end else if ClickedOnArrow then begin
            BaseMessage('Give the other hero the best troops that the '
                        + 'two of you have combined.');
            ClearScr;
            Draw;
          end;
        end;
      end;
    until over;
  end;

{ unit initialization }

begin
  LoadFaces;
end.
