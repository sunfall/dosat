unit artifact;

{ artifacts for hommx }

interface

uses LowGr;

type
  TArtData = record
    name: string[30];
    gr: byte;
    fcol, bcol: byte;
    slot: byte;
    AIval: byte;
    level: byte;
  end;

const
  slNone = 0;
  slRing = 1;
  slWeapon = 2;
  slArmor = 3;
  slBoots = 4;
  slNecklace = 5;
  slTool = 6;
  slGear = 7;

  agRing = 1;
  agSword = 2;
  agBow = 3;
  agShield = 4;
  agBoots = 5;
  agNecklace = 6;
  agPickaxe = 7;
  agSkull = 8;
  agBell = 9;
  agWand = 10;
  agBox = 11;
  agGlove = 12;
  agBag = 13;
  agCrown = 14;
  agWrench = 15;
  agScroll = 16;
  agEye = 17;
  agTalisman = 18;
  agHelm = 19;
  agSpecial = 255;

  ArtGraphics: array [1..19] of TGraphic =
  (
    ('...   ....', { ring }
     '..     ...',
     '...   ....',
     '...***....',
     '..**.**...',
     '.**...**..',
     '.*.....*..',
     '.**...**..',
     '..**.**...',
     '...***....'),
    ('........**', { sword }
     '.......* *',
     '......* *.',
     '*....* *..',
     '**..* *...',
     '.*** *....',
     '..* *.....',
     '.****.....',
     '***.**....',
     '**...**...'),
    ('........*.', { bow }
     '.......**.',
     '......*.*.',
     '.....*.*..',
     '....*..*..',
     '...*..*...',
     '..*..*....',
     '.*.**.....',
     '***.......',
     '..........'),
    ('.***...***', { shield }
     '.* ***** *',
     '.*       *',
     '.*   *   *',
     '.*  ***  *',
     '.*   *   *',
     '..*  *  *.',
     '...*   *..',
     '....* *...',
     '.....*....'),
    ('.... .....', { boots }
     '..  *.....',
     '. ***.....',
     '.****.....',
     '.****.....',
     '.****.....',
     '.****.....',
     '.*******..',
     '.********.',
     '.   .    .'),
    ('..***.....', { necklace }
     '.*...*....',
     '*.....*...',
     '*......*..',
     '.*..**.*..',
     '..**..*...',
     '.....* *..',
     '....* * *.',
     '.....* *..',
     '......*...'),
    ('....****..', { pickaxe }
     '...******.',
     '......****',
     '.....**.**',
     '....**..**',
     '...**...*.',
     '..**......',
     '.**.......',
     '**........',
     '*.........'),
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
    ('..........', { bell }
     '....**....',
     '...****...',
     '...****...',
     '..******..',
     '..******..',
     '.********.',
     '..... ....',
     '....   ...',
     '..... ....'),
    ('.... .... ', { wand }
     '..... . ..',
     '... ..... ',
     '....... ..',
     '....**....',
     '....**.. .',
     '...*......',
     '..*.......',
     '.*........',
     '*.........'),
    ('..........', { box }
     '..........',
     '...*****..',
     '..*   **..',
     '.***** *..',
     '.*   * *..',
     '.*   * *..',
     '.*   **...',
     '.*****....',
     '..........'),
    ('....*.....', { glove }
     '..*.*.*...',
     '*.*.*.*...',
     '*.*.*.*...',
     '*.*.*.*.*.',
     '*******.*.',
     '.********.',
     '..******..',
     '..*****...',
     '..****....'),
    ('....*.*...', { Bag }
     '.....*....',
     '...*****..',
     '..*******.',
     '..***  **.',
     '.***  ****',
     '.****  ***',
     '.***  ****',
     '.*********',
     '..*******.'),
    ('..........', { crown }
     '..........',
     '*...*...*.',
     '**.***.**.',
     '*********.',
     '*********.',
     '*********.',
     '*********.',
     '*********.',
     '..........'),
    ('.......**.', { wrench }
     '......**..',
     '......****',
     '.....****.',
     '....***...',
     '...***....',
     '.****.....',
     '****......',
     '..**......',
     '.**.......'),
    ('..........', { scroll }
     '.********.',
     '.*      *.',
     '.* **** *.',
     '.*      *.',
     '.* ***  *.',
     '.*      *.',
     '.* ***  *.',
     '.*      *.',
     '.********.'),
    ('..........', { eye }
     '..........',
     '...****...',
     '.** ** **.',
     '*  ****  *',
     '*  ****  *',
     '.** ** **.',
     '...****...',
     '..........',
     '..........'),
    ('....**....', { talisman }
     '....**....',
     '.********.',
     '.********.',
     '....**....',
     '....**....',
     '....**....',
     '....**....',
     '....**....',
     '....**....'),
    ('. ...... .', { helm }
     '.  ....  .',
     '..  ..  ..',
     '...****...',
     '..******..',
     '.********.',
     '**********',
     '**********',
     '**......**',
     '..........')
  );

  NumMapArts = 108;
  NumArts = NumMapArts + 7;

  anRings = 1;

  anRingOfPower1 = anRings;
  anRingOfTheWizard = anRings + 3;
  anRingOfTheSage = anRings + 4;
  anRingOfTheSpecialist = anRings + 5;
  anRingOfTheLoremaster = anRings + 6;
  anRingOfTheWitch = anRings + 7;
  anRingOfSorcery = anRings + 8;
  anRingOfWitches = anRings + 9;
  anRingOfDjinns = anRings + 10;
  anRingOfTheWarlock = anRings + 11;

  anWeapons = anRings + 12;

  anSwordOfOffense1 = anWeapons;
  anSwordOfTheWeak = anWeapons + 3;
  anSwordoftheWarrior = anWeapons + 4;
  anBowOfArchery1 = anWeapons + 5;
  anBowOfEvil = anWeapons + 8;
  anBowOfForce = anWeapons + 9;
  anBowOfSpeed = anWeapons + 10;
  anFlamingBow = anWeapons + 11;
  anBowoftheRanger = anWeapons + 12;
  anBowOfPoison = anWeapons + 13;

  anShields = anWeapons + 14;

  anShieldOfDefense1 = anShields;
  anTerrainShield = anShields + 3;
  anShieldOfFriendship = anShields + 4;
  anShieldOfTheSmall = anShields + 5;
  anSpikedShield = anShields + 6;
  anArchersHelm = anShields + 7;
  anFlyersHelm = anShields + 8;
  anWalkersHelm = anShields + 9;
  anHeartsHelm = anShields + 10;

  anBoots = anShields + 11;

  anBootsOfPathfinding1 = anBoots;
  anBootsOfExperience = anBoots + 3;
  anSevenLeagueBoots = anBoots + 4;
  anBootsOfGating = anBoots + 5;
  anBootsOfTheScout = anBoots + 6;
  anBootsOfEndurance = anBoots + 7;
  anBootsOfJourneying = anBoots + 8;

  anNecklaces = anBoots + 9;

  anNecklaceOfSpellcraft = anNecklaces;
  anNecklaceOfSummoning = anNecklaces + 3;
  anNecklaceOfLore = anNecklaces + 6;
  anNecklaceOfUpgrading = anNecklaces + 7;
  anNecklaceOfUltraUpgrading = anNecklaces + 8;
  anNecklaceOfMassSummoning = anNecklaces + 9;
  anNecklaceOfTheHordes = anNecklaces + 10;
  anNecklaceOfEvocation = anNecklaces + 11;

  anTools = anNecklaces + 12;

  anPickaxeOfGoldMining = anTools;
  anPickaxeOfRockMining = anTools + 1;
  anPickaxeOfMining = anTools + 2;
  anAlchemistsPickaxe = anTools + 3;
  anLegionnairesPickaxe = anTools + 4;
  anDwarvenPickaxe = anTools + 5;
  anToyPickaxe = anTools + 6;
  anWrenchOfHusbandry = anTools + 7;
  anWrenchOfDeconstruction = anTools + 8;
  anAlchemistsWrench = anTools + 9;
  anWrenchOfRezoning = anTools + 10;
  anWrenchOfTheHordes = anTools + 11;

  anGear = anTools + 12;

  anSkullOfDarkArts1 = anGear;
  anBellOfBunnies = anGear + 3;
  anBellOfWobblers = anGear + 4;
  anBellOfMimics = anGear + 5;
  anTacticiansGloves = anGear + 6;
  anGlovesOfTheSpeedyHordes = anGear + 7;
  anGlovesOfTheFieryTitan = anGear + 8;
  anGlovesOfCourage = anGear + 9;
  anWandOfBlessings = anGear + 10;
  anWandOfCurses = anGear + 11;
  anWandOfPain = anGear + 12;
  anWandOfHealth = anGear + 13;
  anWandOfDesertion = anGear + 14;
  anWandOfEndlessCurses = anGear + 15;
  anScrollOfMagicBow = anGear + 16;
  anScrollOfFireBolt = anGear + 17;
  anScrollOfRenew = anGear + 18;
  anScrollOfZap = anGear + 19;
  anScrollOfTraitor = anGear + 20;
  anScrollOfVampire = anGear + 21;
  anScrollOfScrolls = anGear + 22;
  anEyeOfPersuasion1 = anGear + 23;
  anTalismanOfHealing1 = anGear + 26;
  anTalismanoftheNecromancer = anGear + 29;

  anNonEquipped = anGear + 30;

  anPortableHole = anNonEquipped;
  anBoxOfClay = anNonEquipped + 1;
  anPortableGateway = anNonEquipped + 2;
  anCrownOfBreeding = anNonEquipped + 3;
  anMercenarysCrown = anNonEquipped + 4;
  anCrownOfOffense = anNonEquipped + 5;
  anCrownOfDefense = anNonEquipped + 6;
  anCrownOfTactics = anNonEquipped + 7;

  anNonMapArts = anNonEquipped + 8;

  anBagOfJunk = anNonMapArts;
  anBagOfBaubles = anNonMapArts + 1;
  anBagOfJewelry = anNonMapArts + 2;
  anTreasureMap1 = anNonMapArts + 3;

  MaxArtAIVal = 12;

  ArtData: array [1..NumArts] of TArtData =
  (
    (name:  'Ring of +1 Power';
     gr:    agRing;
     fcol:  colYellow;
     bcol:  colLightGreen;
     slot:  slRing;
     AIval: 3;
     level: 1),
    (name:  'Ring of +2 Power';
     gr:    agRing;
     fcol:  colYellow;
     bcol:  colRed;
     slot:  slRing;
     AIval: 6;
     level: 2),
    (name:  'Ring of +3 Power';
     gr:    agRing;
     fcol:  colYellow;
     bcol:  colBlue;
     slot:  slRing;
     AIval: 9;
     level: 3),
    (name:  'Ring of the Wizard';
     gr:    agRing;
     fcol:  colGrays + 2;
     bcol:  colLightGreen;
     slot:  slRing;
     AIval: 4;
     level: 1),
    (name:  'Ring of the Sage';
     gr:    agRing;
     fcol:  colGrays + 2;
     bcol:  colMagentas + 4;
     slot:  slRing;
     AIval: 7;
     level: 2),
    (name:  'Ring of the Specialist';
     gr:    agRing;
     fcol:  colYellows + 4;
     bcol:  colDarkRedOranges + 2;
     slot:  slRing;
     AIval: 6;
     level: 2),
    (name:  'Ring of the Loremaster';
     gr:    agRing;
     fcol:  colYellow;
     bcol:  colWhite;
     slot:  slRing;
     AIval: 5;
     level: 1),
    (name:  'Ring of the Witch';
     gr:    agRing;
     fcol:  colYellow;
     bcol:  colBlack;
     slot:  slRing;
     AIval: 4;
     level: 1),
    (name:  'Ring of the Sorcerer';
     gr:    agRing;
     fcol:  colWhite;
     bcol:  colPaleGreens + 4;
     slot:  slRing;
     AIval: 2;
     level: 1),
    (name:  'Ring of Witches';
     gr:    agRing;
     fcol:  colDarkDarkGray;
     bcol:  colBlack;
     slot:  slRing;
     AIval: 6;
     level: 2),
    (name:  'Ring of Djinns';
     gr:    agRing;
     fcol:  colGrayYellows + 5;
     bcol:  colPaleBlues + 4;
     slot:  slRing;
     AIval: 9;
     level: 3),
    (name:  'Ring of the Warlock';
     gr:    agRing;
     fcol:  colGrayYellows + 5;
     bcol:  colRedMagentas + 5;
     slot:  slRing;
     AIval: 9;
     level: 3),
    (name:  'Sword of +1 Offense';
     gr:    agSword;
     fcol:  colDarkGreen;
     bcol:  colLightGreen;
     slot:  slWeapon;
     AIval: 4;
     level: 1),
    (name:  'Sword of +2 Offense';
     gr:    agSword;
     fcol:  colDarkRed;
     bcol:  colLightRed;
     slot:  slWeapon;
     AIval: 7;
     level: 2),
    (name:  'Sword of +3 Offense';
     gr:    agSword;
     fcol:  colDarkBlue;
     bcol:  colLightBlue;
     slot:  slWeapon;
     AIval: 10;
     level: 3),
    (name:  'Sword of the Weak';
     gr:    agSword;
     fcol:  colDarkGreen;
     bcol:  colWhite;
     slot:  slWeapon;
     AIval: 3;
     level: 1),
    (name:  'Sword of the Warrior';
     gr:    agSword;
     fcol:  colRedMagentas + 1;
     bcol:  colRedMagentas + 5;
     slot:  slWeapon;
     AIval: 9;
     level: 3),
    (name:  'Bow of +1 Archery';
     gr:    agBow;
     fcol:  colLightGreen;
     bcol:  colBlack;
     slot:  slWeapon;
     AIval: 1;
     level: 1),
    (name:  'Bow of +2 Archery';
     gr:    agBow;
     fcol:  colRed;
     bcol:  colBlack;
     slot:  slWeapon;
     AIval: 3;
     level: 2),
    (name:  'Bow of +3 Archery';
     gr:    agBow;
     fcol:  colBlue;
     bcol:  colBlack;
     slot:  slWeapon;
     AIval: 4;
     level: 2),
    (name:  '+1 Bow of Evil';
     gr:    agBow;
     fcol:  colBlack;
     bcol:  colBlack;
     slot:  slWeapon;
     AIval: 4;
     level: 1),
    (name:  '+1 Bow of Force';
     gr:    agBow;
     fcol:  colLightRed;
     bcol:  colBlack;
     slot:  slWeapon;
     AIval: 2;
     level: 1),
    (name:  '+1 Bow of Speed';
     gr:    agBow;
     fcol:  colLightBlue;
     bcol:  colBlack;
     slot:  slWeapon;
     AIval: 6;
     level: 3),
    (name:  '+1 Flaming Bow';
     gr:    agBow;
     fcol:  colDeepOranges;
     bcol:  colBlack;
     slot:  slWeapon;
     AIval: 6;
     level: 3),
    (name:  'Bow of the Ranger';
     gr:    agBow;
     fcol:  colRedMagentas + 5;
     bcol:  colBlack;
     slot:  slWeapon;
     AIval: 7;
     level: 3),
    (name:  '+2 Bow of Poison';
     gr:    agBow;
     fcol:  colPaleYellows + 1;
     bcol:  colBlack;
     slot:  slWeapon;
     AIval: 5;
     level: 2),
    (name:  'Shield of +1 Defense';
     gr:    agShield;
     fcol:  colDarkGreen;
     bcol:  colLightGreen;
     slot:  slArmor;
     AIval: 3;
     level: 1),
    (name:  'Shield of +2 Defense';
     gr:    agShield;
     fcol:  colDarkRed;
     bcol:  colLightRed;
     slot:  slArmor;
     AIval: 6;
     level: 2),
    (name:  'Shield of +3 Defense';
     gr:    agShield;
     fcol:  colDarkBlue;
     bcol:  colLightBlue;
     slot:  slArmor;
     AIval: 9;
     level: 3),
    (name:  '+1 Terrain Shield';
     gr:    agShield;
     fcol:  colOranges + 1;
     bcol:  colTan;
     slot:  slArmor;
     AIval: 4;
     level: 2),
    (name:  '+1 Shield of Friendship';
     gr:    agShield;
     fcol:  colLightBlue;
     bcol:  colLightGreen;
     slot:  slArmor;
     AIval: 5;
     level: 2),
    (name:  'Shield of the Small';
     gr:    agShield;
     fcol:  colWhite;
     bcol:  colLightGreen;
     slot:  slArmor;
     AIval: 2;
     level: 1),
    (name:  '+1 Spiked Shield';
     gr:    agShield;
     fcol:  colBlack;
     bcol:  colLightGreen;
     slot:  slArmor;
     AIval: 5;
     level: 2),
    (name:  'Helm of the Archer';
     gr:    agHelm;
     fcol:  colGrays + 1;
     bcol:  colGrays + 4;
     slot:  slArmor;
     AIval: 2;
     level: 1),
    (name:  'Helm of the Flyer';
     gr:    agHelm;
     fcol:  colCyans + 1;
     bcol:  colPaleBlues + 5;
     slot:  slArmor;
     AIval: 2;
     level: 1),
    (name:  'Helm of the Walker';
     gr:    agHelm;
     fcol:  colGrayGreens + 1;
     bcol:  colPaleGreens + 5;
     slot:  slArmor;
     AIval: 2;
     level: 1),
    (name:  'Hearts'' Helm';
     gr:    agHelm;
     fcol:  colPinks + 1;
     bcol:  colPaleReds + 5;
     slot:  slArmor;
     AIval: 8;
     level: 3),
    (name:  'Boots of +1 Pathfinding';
     gr:    agBoots;
     fcol:  colLightGreen;
     bcol:  colDarkGreen;
     slot:  slBoots;
     AIval: 3;
     level: 1),
    (name:  'Boots of +2 Pathfinding';
     gr:    agBoots;
     fcol:  colRed;
     bcol:  colDarkRed;
     slot:  slBoots;
     AIval: 6;
     level: 2),
    (name:  'Boots of +3 Pathfinding';
     gr:    agBoots;
     fcol:  colBlue;
     bcol:  colDarkBlue;
     slot:  slBoots;
     AIval: 9;
     level: 3),
    (name:  'Boots of Experience';
     gr:    agBoots;
     fcol:  colLightBlue;
     bcol:  colBlue;
     slot:  slBoots;
     AIval: 2;
     level: 1),
    (name:  'Seven League Boots';
     gr:    agBoots;
     fcol:  colOranges + 1;
     bcol:  colBlack;
     slot:  slBoots;
     AIval: 3;
     level: 2),
    (name:  'Boots of Gating';
     gr:    agBoots;
     fcol:  colBurntOranges + 2;
     bcol:  colBurntOranges;
     slot:  slBoots;
     AIval: 1;
     level: 3),
    (name:  'Boots of the Scout';
     gr:    agBoots;
     fcol:  colPaleBurntOranges + 2;
     bcol:  colPaleBurntOranges;
     slot:  slBoots;
     AIval: 8;
     level: 3),
    (name:  '+1 Boots of Endurance';
     gr:    agBoots;
     fcol:  colPaleOranges + 5;
     bcol:  colPaleOranges;
     slot:  slBoots;
     AIval: 4;
     level: 2),
    (name:  '+1 Boots of Journeying';
     gr:    agBoots;
     fcol:  colGrayGreens + 5;
     bcol:  colGrayGreens;
     slot:  slBoots;
     AIval: 5;
     level: 2),
    (name:  'Necklace of +1 Spellcraft';
     gr:    agNecklace;
     fcol:  colYellow;
     bcol:  colLightGreen;
     slot:  slNecklace;
     AIval: 2;
     level: 1),
    (name:  'Necklace of +2 Spellcraft';
     gr:    agNecklace;
     fcol:  colYellow;
     bcol:  colRed;
     slot:  slNecklace;
     AIval: 4;
     level: 2),
    (name:  'Necklace of +3 Spellcraft';
     gr:    agNecklace;
     fcol:  colYellow;
     bcol:  colBlue;
     slot:  slNecklace;
     AIval: 7;
     level: 3),
    (name:  'Necklace of +1 Summoning';
     gr:    agNecklace;
     fcol:  colLightGray;
     bcol:  colLightGreen;
     slot:  slNecklace;
     AIval: 4;
     level: 1),
    (name:  'Necklace of +2 Summoning';
     gr:    agNecklace;
     fcol:  colLightGray;
     bcol:  colRed;
     slot:  slNecklace;
     AIval: 7;
     level: 2),
    (name:  'Necklace of +3 Summoning';
     gr:    agNecklace;
     fcol:  colLightGray;
     bcol:  colBlue;
     slot:  slNecklace;
     AIval: 10;
     level: 3),
    (name:  'Necklace of Lore';
     gr:    agNecklace;
     fcol:  colWhite;
     bcol:  colDarkGreen;
     slot:  slNecklace;
     AIval: 1;
     level: 1),
    (name:  'Necklace of Upgrading';
     gr:    agNecklace;
     fcol:  colBlack;
     bcol:  colLightGreen;
     slot:  slNecklace;
     AIval: 5;
     level: 2),
    (name:  'Necklace of Ultra Upgrading';
     gr:    agNecklace;
     fcol:  colBlack;
     bcol:  colLightBlue;
     slot:  slNecklace;
     AIval: 6;
     level: 3),
    (name:  'Necklace of Mass Summoning';
     gr:    agNecklace;
     fcol:  colPaleBlues + 5;
     bcol:  colMagentas + 1;
     slot:  slNecklace;
     AIval: 11;
     level: 3),
    (name:  'Necklace of the Hordes';
     gr:    agNecklace;
     fcol:  colRedMagentas + 5;
     bcol:  colWhite;
     slot:  slNecklace;
     AIval: 5;
     level: 1),
    (name:  'Necklace of Evocation';
     gr:    agNecklace;
     fcol:  colPaleBlues + 3;
     bcol:  colCyans + 4;
     slot:  slNecklace;
     AIval: 8;
     level: 2),
    (name:  'Pickaxe of Gold Mining';
     gr:    agPickaxe;
     fcol:  colGrayYellows + 5;
     bcol:  colBlack;
     slot:  slTool;
     AIval: 6;
     level: 2),
    (name:  'Pickaxe of Rock Mining';
     gr:    agPickaxe;
     fcol:  colGrays + 2;
     bcol:  colBlack;
     slot:  slTool;
     AIval: 3;
     level: 1),
    (name:  'Pickaxe of Mining';
     gr:    agPickaxe;
     fcol:  colGrayGreens + 5;
     bcol:  colBlack;
     slot:  slTool;
     AIval: 2;
     level: 1),
    (name:  'Alchemist''s Pickaxe';
     gr:    agPickaxe;
     fcol:  colLightBlue;
     bcol:  colBlack;
     slot:  slTool;
     AIval: 4;
     level: 2),
    (name:  'Legionnaire''s Pickaxe';
     gr:    agPickaxe;
     fcol:  colLightRed;
     bcol:  colBlack;
     slot:  slTool;
     AIval: 1;
     level: 2),
    (name:  'Dwarven Pickaxe';
     gr:    agPickaxe;
     fcol:  colYellow;
     bcol:  colBlack;
     slot:  slTool;
     AIval: 5;
     level: 2),
    (name:  'Toy Pickaxe';
     gr:    agPickaxe;
     fcol:  colOranges + 5;
     bcol:  colBlack;
     slot:  slTool;
     AIval: 3;
     level: 1),
    (name:  'Wrench of Husbandry';
     gr:    agWrench;
     fcol:  colLightBlue;
     bcol:  colBlack;
     slot:  slTool;
     AIval: 9;
     level: 3),
    (name:  'Wrench of Deconstruction';
     gr:    agWrench;
     fcol:  colBlack;
     bcol:  colBlack;
     slot:  slTool;
     AIval: 8;
     level: 3),
    (name:  'Alchemist''s Wrench';
     gr:    agWrench;
     fcol:  colRed;
     bcol:  colBlack;
     slot:  slTool;
     AIval: 4;
     level: 2),
    (name:  'Wrench of Rezoning';
     gr:    agWrench;
     fcol:  colOranges + 5;
     bcol:  colBlack;
     slot:  slTool;
     AIval: 8;
     level: 3),
    (name:  'Wrench of the Hordes';
     gr:    agWrench;
     fcol:  colWhite;
     bcol:  colBlack;
     slot:  slTool;
     AIval: 5;
     level: 2),
    (name:  'Skull of +1 Dark Arts';
     gr:    agSkull;
     fcol:  colLightGray;
     bcol:  colDarkGreen;
     slot:  slGear;
     AIval: 4;
     level: 1),
    (name:  'Skull of +2 Dark Arts';
     gr:    agSkull;
     fcol:  colLightGray;
     bcol:  colDarkRed;
     slot:  slGear;
     AIval: 7;
     level: 2),
    (name:  'Skull of +3 Dark Arts';
     gr:    agSkull;
     fcol:  colLightGray;
     bcol:  colDarkBlue;
     slot:  slGear;
     AIval: 10;
     level: 3),
    (name:  'Bell of Bunnies';
     gr:    agBell;
     fcol:  colLightGreen;
     bcol:  colBlack;
     slot:  slGear;
     AIval: 1;
     level: 1),
    (name:  'Bell of Wobblers';
     gr:    agBell;
     fcol:  colRed;
     bcol:  colBlack;
     slot:  slGear;
     AIval: 1;
     level: 2),
    (name:  'Bell of Mimics';
     gr:    agBell;
     fcol:  colBlue;
     bcol:  colBlack;
     slot:  slGear;
     AIval: 2;
     level: 2),
    (name:  'Tactician''s Gloves';
     gr:    agGlove;
     fcol:  colOranges + 1;
     bcol:  colBlack;
     slot:  slGear;
     AIval: 3;
     level: 1),
    (name:  'Gloves of the Speedy Hordes';
     gr:    agGlove;
     fcol:  colWhite;
     bcol:  colBlack;
     slot:  slGear;
     AIval: 3;
     level: 1),
    (name:  'Gloves of the Fiery Titan';
     gr:    agGlove;
     fcol:  colRed;
     bcol:  colBlack;
     slot:  slGear;
     AIval: 2;
     level: 2),
    (name:  'Gloves of Courage';
     gr:    agGlove;
     fcol:  colLightGreen;
     bcol:  colBlack;
     slot:  slGear;
     AIval: 1;
     level: 2),
    (name:  'Wand of Blessings';
     gr:    agWand;
     fcol:  colLightBlue;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 1;
     level: 1),
    (name:  'Wand of Curses';
     gr:    agWand;
     fcol:  colLightBlue;
     bcol:  colBlack;
     slot:  slGear;
     AIval: 1;
     level: 1),
    (name:  'Wand of Pain';
     gr:    agWand;
     fcol:  colRed;
     bcol:  colBlack;
     slot:  slGear;
     AIval: 7;
     level: 2),
    (name:  'Wand of Health';
     gr:    agWand;
     fcol:  colBlue;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 4;
     level: 1),
    (name:  'Wand of Desertion';
     gr:    agWand;
     fcol:  colGrays + 2;
     bcol:  colNewDarkRed;
     slot:  slGear;
     AIval: 9;
     level: 3),
    (name:  'Wand of Endless Curses';
     gr:    agWand;
     fcol:  colPaleBlues + 3;
     bcol:  colNewDarkBlue;
     slot:  slGear;
     AIval: 4;
     level: 2),
    (name:  'Scroll of Magic Bow';
     gr:    agScroll;
     fcol:  colDarkGreen;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 10;
     level: 3),
    (name:  'Scroll of Fire Bolt';
     gr:    agScroll;
     fcol:  colRed;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 8;
     level: 2),
    (name:  'Scroll of Renew';
     gr:    agScroll;
     fcol:  colBlue;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 11;
     level: 3),
    (name:  'Scroll of Zap';
     gr:    agScroll;
     fcol:  colPaleReds + 5;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 2;
     level: 1),
    (name:  'Scroll of Traitor';
     gr:    agScroll;
     fcol:  colGrays + 2;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 3;
     level: 1),
    (name:  'Scroll of Vampire';
     gr:    agScroll;
     fcol:  colBlack;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 10;
     level: 3),
    (name:  'Scroll of Scrolls';
     gr:    agScroll;
     fcol:  colWhite;
     bcol:  colMagentas + 5;
     slot:  slGear;
     AIval: 6;
     level: 3),
    (name:  'Eye of +1 Persuasion';
     gr:    agEye;
     fcol:  colLightGreen;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 3;
     level: 1),
    (name:  'Eye of +2 Persuasion';
     gr:    agEye;
     fcol:  colRed;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 6;
     level: 2),
    (name:  'Eye of +3 Persuasion';
     gr:    agEye;
     fcol:  colBlue;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 9;
     level: 3),
    (name:  'Talisman of +1 Healing';
     gr:    agTalisman;
     fcol:  colLightGreen;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 3;
     level: 1),
    (name:  'Talisman of +2 Healing';
     gr:    agTalisman;
     fcol:  colRed;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 6;
     level: 2),
    (name:  'Talisman of +3 Healing';
     gr:    agTalisman;
     fcol:  colBlue;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 9;
     level: 3),
    (name:  'Talisman of The Necromancer';
     gr:    agTalisman;
     fcol:  colBlack;
     bcol:  colWhite;
     slot:  slGear;
     AIval: 7;
     level: 3),
    (name:  'Portable Hole';
     gr:    agBox;
     fcol:  colOranges + 1;
     bcol:  colBlack;
     slot:  slNone;
     AIval: 0;
     level: 1),
    (name:  'Box of Clay';
     gr:    agBox;
     fcol:  colOranges + 1;
     bcol:  colLightGray;
     slot:  slNone;
     AIval: 0;
     level: 2),
    (name:  'Portable Gateway';
     gr:    agBox;
     fcol:  colOranges + 1;
     bcol:  colLightBlue;
     slot:  slNone;
     AIval: 0;
     level: 2),
    (name:  'Crown of Breeding';
     gr:    agCrown;
     fcol:  colLightBlue;
     bcol:  colBlack;
     slot:  slNone;
     AIval: 0;
     level: 3),
    (name:  'Mercenary''s Crown';
     gr:    agCrown;
     fcol:  colYellow;
     bcol:  colBlack;
     slot:  slNone;
     AIval: 0;
     level: 2),
    (name:  'Crown of Offense';
     gr:    agCrown;
     fcol:  colLightRed;
     bcol:  colBlack;
     slot:  slNone;
     AIval: 0;
     level: 1),
    (name:  'Crown of Defense';
     gr:    agCrown;
     fcol:  colLightGreen;
     bcol:  colBlack;
     slot:  slNone;
     AIval: 0;
     level: 1),
    (name:  'Crown of Tactics';
     gr:    agCrown;
     fcol:  colWhite;
     bcol:  colBlack;
     slot:  slNone;
     AIval: 0;
     level: 2),
    (name:  'Bag of Junk';
     gr:    agBag;
     fcol:  colLightGray;
     bcol:  colDarkGray;
     slot:  slNone;
     AIval: 0;
     level: 0),
    (name:  'Bag of Baubles';
     gr:    agBag;
     fcol:  colLightRed;
     bcol:  colYellow;
     slot:  slNone;
     AIval: 0;
     level: 0),
    (name:  'Bag of Jewelry';
     gr:    agBag;
     fcol:  colYellow;
     bcol:  colOranges + 1;
     slot:  slNone;
     AIval: 0;
     level: 0),
    (name:  'Treasure Map';
     gr:    agSpecial;
     fcol:  colBlack;
     bcol:  colBlack;
     slot:  slNone;
     AIval: 0;
     level: 0),
    (name:  'Treasure Map';
     gr:    agSpecial;
     fcol:  colBlack;
     bcol:  colBlack;
     slot:  slNone;
     AIval: 0;
     level: 0),
    (name:  'Treasure Map';
     gr:    agSpecial;
     fcol:  colBlack;
     bcol:  colBlack;
     slot:  slNone;
     AIval: 0;
     level: 0),
    (name:  'Treasure Map';
     gr:    agSpecial;
     fcol:  colBlack;
     bcol:  colBlack;
     slot:  slNone;
     AIval: 0;
     level: 0)
  );

  NumTreasureMaps = 4;

type
  TArtHelp = array [1..NumArts] of string[160];
  PArtHelp = ^TArtHelp;

var
  ArtHelp: PArtHelp;
  FoundMaps: integer;

  TreasureMap: array [1..NumTreasureMaps] of record
    x, y: integer;
  end;

function RandomArtifact(lev: integer): integer;
function AnArtName(a: integer): string;
procedure DrawArt(x, y, art: integer);

implementation

uses Map;

function RandomArtifact(lev: integer): integer;
  var i: integer;
  begin
    repeat
      i:= random(NumMapArts) + 1;
    until ArtData[i].level = lev;

    RandomArtifact := i;
  end;

function AnArtName(a: integer): string;
  var s: string;
  begin
    if ArtData[a].name[1] in ['A', 'E', 'I', 'O', 'U'] then
      s := 'an'
    else
      s := 'a';

    AnArtName := s + ' ' + ArtData[a].name;
  end;

procedure DrawArt(x, y, art: integer);
  var ax, ay, tx, ty, c, tax, tay: integer;

  procedure XPut2x2Pixels(px, py, pc: integer);
    begin
      XPutPixel(px, py, pc);
      XPutPixel(px + 1, py, pc);
      XPutPixel(px, py + 1, pc);
      XPutPixel(px + 1, py + 1, pc);
    end;

  begin
    if art = 0 then
      DrawIcon(x, y, @BlankIcon)
    else if (art >= anTreasureMap1)
            and (art <= anTreasureMap1 + NumTreasureMaps - 1) then begin
      DrawIcon2c(x, y, colBlack, colBlack, @BlankIcon);
      tx := TreasureMap[art - anTreasureMap1 + 1].x;
      ty := TreasureMap[art - anTreasureMap1 + 1].y;
      for ax := 0 to 14 do
        for ay := 0 to 14 do begin
          tax := tx - 7 + ax;
          tay := ty - 7 + ay;
          if not OnMap(tax, tay) then
            c := colBlack
          else if (ax = 7) and (ay = 7) then
            c := colBlack
          else begin
            c := ObstacleColor(tax, tay);
            if c = colGreen then
              c := ClimateColor[Climate^[tax, tay] and $07];
          end;
          XPut2x2Pixels(x + ax * 2 + 5, y + ay * 2 + 5, c);
        end;
    end else
      DrawIcon2c(x, y, ArtData[art].fcol, ArtData[art].bcol,
                 @ArtGraphics[ArtData[art].gr]);
    end;

{ unit initialization }

end.
