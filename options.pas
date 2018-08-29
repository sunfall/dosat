unit options;

{ options screens for hommx }

interface

uses Map;

const
  twDoubleMovement = 1;
  twDoubleXP = 2;
  tw10Towers = 3;
  twMax4Skills = 4;
  twStartWithArt = 5;
  twStartWithSkill = 6;
  twStartWithStack = 7;
  twAllGainXP = 8;
  twMoreCastleObstacles = 9;
  twDoubleCostProd = 10;
  twStartWithBuilding = 11;
  twCastleBuildingsDecay = 12;
  twOneSquareDwelling = 13;
  twCastleCreaturesMixed = 14;
  twMonstersHaveAbility = 15;
  twTerrainsAffectCombat = 16;
  twStartWithHero = 17;
  twOnly2Heroes = 18;
  twSkipWeekend = 19;
  twAllSameResource = 20;
  twOneUseBuildings = 21;
  twForestsDie = 22;
  twDwellingsAppear = 23;
  twFlooding = 24;

  twMax = 24;

var
  LoadSavedGame, QuitToMenu: boolean;
  Twists: array [1..twMax] of boolean;
  OneSquareDwelling: integer;
  MixedCreaturesOfs: array [2..6] of integer;
  AllMonstersAbility: integer;

procedure MapOptions;
procedure ShowTwists;

implementation

uses Dos, Objects, Drivers, XStrings,
     LowGr, XSVGA, XMouse, Players, Castles, Heroes, Monsters, MapGen, XFace,
     Spells, MapScr, Rez, Artifact;

type
  PPlayerOpts = ^TPlayerOpts;
  TPlayerOpts = object(TObject)
    Options: array [1..8] of record
      AI: boolean;
      CT: TCastleType;
      Dude: integer;
      Easy: boolean;
    end;
    constructor Init;
    destructor Done; virtual;
    procedure NextDude(pl: integer);
    procedure DrawPlayer(pl: integer);
    procedure Draw;
    procedure Handle;
    procedure Apply;
  end;

  TTwistChoice = (tcOff, tcOn, tcRandom);

  PMapOpts = ^TMapOpts;
  TMapOpts = object(TObject)
    MapType: integer;
    NPlayers: integer;
    Loopiness: integer;
    fnames: PStringCollection;
    FileNum: integer;
    NumTwists: integer;
    TwistOpts: array [1..twMax] of TTwistChoice;
    constructor Init;
    destructor Done; virtual;
    procedure GetRMTStats(var players, space: integer);
    procedure Draw;
    procedure DrawTwists;
    procedure GetTwists;
    procedure PickTwists;
    procedure Handle;
    procedure Load;
    procedure Save;
  end;

  TTwistNames = array [1..twMax] of string[60];
  PTwistNames = ^TTwistNames;

var
  TwistNames: PTwistNames;

constructor TPlayerOpts.Init;
  var i: integer;
  begin
    TObject.Init;

    for i := 1 to NumPlayers do
      with Options[i] do begin
        AI := true;
        CT := TCastleType(random(ord(high(TCastleType)) + 1));
        Dude := 0;
        Easy := false;
      end;

    Options[1].AI := false;
  end;

destructor TPlayerOpts.Done;
  begin
    TObject.Done;
  end;

procedure TPlayerOpts.NextDude(pl: integer);
  var
    i: integer;
    good: boolean;
  begin
    with Options[pl] do
      repeat
        if Dude = 0 then
          Dude := Ord(CT) * 14 + 1
        else if Dude = Ord(CT) * 14 + 14 then
          Dude := 0
        else
          Options[pl].Dude := ((((Dude - 1) mod 14) + 1) mod 14)
                              + 14 * ord(CT) + 1;
        good := true;
        if Dude <> 0 then
          for i := 1 to NumPlayers do
            if (i <> pl) and (Options[i].Dude = Options[pl].Dude) then
              good := false;
      until good;
  end;

procedure TPlayerOpts.DrawPlayer(pl: integer);
  const
    AIGraphic: array [boolean] of TGraphic =
    (
      ('..........',
       '...***....',
       '...***....',
       '....*.....',
       '...***....',
       '..*.*.*...',
       '....*.....',
       '...*.*....',
       '...*.*....',
       '..........'),
      ('.********.',
       '.*......*.',
       '.*.****.*.',
       '.*.*..*.*.',
       '.*.*..*.*.',
       '.*.****.*.',
       '.*......*.',
       '.*..***.*.',
       '.*......*.',
       '.********.')
    );
    QMark: TGraphic =
    ('...****...',
     '..******..',
     '..**..**..',
     '......**..',
     '.....**...',
     '....**....',
     '....**....',
     '..........',
     '....**....',
     '....**....');
  var y, i: integer;
  begin
    y := (pl - 1) * 60 + 15;
    ClearArea(0, y - 13, 639 - 40, y + 39);

    DrawIcon2c(0, y, PLColor[pl], colBlack, @MapGraphics^[mgCamp]);
    DrawIcon(60, y, @AIGraphic[Options[pl].AI]);
    DrawText(120, y + 7, colDarkGray, colWhite,
             LSet(CastleNames[Options[pl].CT], 15));

    for i := 1 to 6 do
      DrawSmallGraphic2c(120 + (i - 1) * 20 + 5, y + 7 + 8 + 7,
                         colLightBlue, colBlack,
                         MonsterGraphic(MonsterForLevel(Options[pl].CT, i))^);

    if Options[pl].Dude = 0 then begin
      XRectangle(260, y, 260 + 35, y + 35, colLightGray);
      DrawText(260, y - 13, colBlack, colWhite, 'Random Hero');
      XDrawIcon2c(260 + 2, y + 2, colWhite, colBlack, @QMark);
    end else
      DrawHeroInfo(260, y, Options[pl].Dude);

    if Options[pl].Easy then begin
      DrawIcon2c(410, y, colYellow, colBlack, @ResourceGraphics[rGold]);
      DrawText(460, y + 13, colBlack, colWhite, 'Easy  ');
    end else begin
      DrawIcon(410, y, @BlankIcon);
      DrawText(460, y + 13, colBlack, colWhite, 'Normal');
    end;
  end;

procedure TPlayerOpts.Draw;
  var i: integer;
  begin
    for i := 1 to NumPlayers do
      DrawPlayer(i);

    DrawIcon(600, 440, @RightArrow);
  end;

procedure TPlayerOpts.Handle;
  var
    over: boolean;
    E: TEvent;
    x, y, pl, sp, sk: integer;

  procedure OptMsg(s: string);
    begin
      BaseMessage(s);
      ClearScr;
      Draw;
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
          end else begin
            y := ((y - 15) div 60) + 1;
            if (y >= 1) and (y <= NumPlayers) then begin
              if (x >= 60) and (x < 60 + 40) then begin
                Options[y].AI := not Options[y].AI;
              end else if (x >= 120) and (x < 120 + 15 * 8) then begin
                if Options[y].CT = high(TCastleType) then
                  Options[y].CT := low(TCastleType)
                else
                  inc(Options[y].CT);
                Options[y].Dude := 0;
              end else if (x >= 260) and (x < 260 + 36) then begin
                NextDude(y);
              end else if (x >= 410) and (x < 410 + 40) then begin
                Options[y].Easy := not Options[y].Easy;
              end;
              DrawPlayer(y);
            end;
          end;
        end else if E.Buttons = mbRightButton then begin
          pl := (y - 15) div 60 + 1;
          if (pl >= 1) and (pl <= 8) then begin
            y := (y - 15) mod 60;
            if (x >= 260 + 45) and (x < 260 + 45 + 12 * 8)
               and (Options[pl].Dude <> 0) then begin
              if y < 10 then begin
                sk := Hero^[Options[pl].Dude].Skill[1];
                if sk = 0 then sk := Hero^[Options[pl].Dude].Skill[6];
                OptMsg(SkillStr(Options[pl].Dude, sk, 0));
              end else if (y >= 14) and (y < 14 + 10) then begin
                sk := Hero^[Options[pl].Dude].Skill[7];
                if sk = 0 then sk := Hero^[Options[pl].Dude].Skill[6];
                if sk = 0 then sk := Hero^[Options[pl].Dude].Skill[2];
                OptMsg(SkillStr(Options[pl].Dude, sk, 0));
              end else if (y >= 28) and (y < 28 + 10) then begin
                sp := HeroFirstSpell(Options[pl].Dude);
                if sp <> 0 then
                  OptMsg(SpellHintStr(sp, Options[pl].Dude, 0));
              end;
            end else if (x >= 410) and (x < 410 + 40) then begin
              if Options[pl].Easy then
                OptMsg('Easy - this player has an advantage over other '
                       + 'players.')
              else
                OptMsg('Normal - this player has no advantage over other '
                       + 'players.');
            end else if (x >= 60) and (x < 60 + 40) then begin
              if Options[pl].AI then
                OptMsg('Computer player.')
              else
                OptMsg('Human player.');
            end else if (x >= 120) and (x < 120 + 15 * 8) then begin
              OptMsg('This player''s starting castle type.');
            end else if (x >= 260) and (x < 260 + 36) then begin
              OptMsg('This player''s starting hero.');
            end else if (x < 40) then begin
              OptMsg('This player''s color.');
            end;
          end;
        end;
      end;
    until over;
  end;

procedure TPlayerOpts.Apply;
  var pl, c, h, fx, fy, i: integer;
  begin
    for pl := 1 to NumPlayers do
      with Options[pl] do begin
        Player[pl].AI := AI;
        if Dude = 0 then begin
          Dude := Ord(CT) * 14 + 1 + random(14);
          NextDude(pl);
          if Dude = 0 then NextDude(pl);
        end;
        Player[pl].Dudes[1] := Dude;
        c := Player[pl].Towns[1];
        Castle[c].CT := CT;
        TheMap^[Castle[c].MapX, Castle[c].MapY] := mJungleFort + ord(CT);
        for h := 1 to 6 do
          if FindAdjMapHex(h, Castle[c].MapX, Castle[c].MapY, fx, fy) then
            if TheMap^[fx, fy] = mCastlePart then
              MapInfo^[fx, fy] := (MapInfo^[fx, fy] and $F0) + ord(CT) + 2;
        Hero^[Dude].MapX := Castle[c].MapX;
        Hero^[Dude].MapY := Castle[c].MapY;
        Hero^[Dude].Player := pl;
        if Options[pl].Easy then begin
          if not TryToBuild(c, bBigMoney, false, true) then begin
            for i := 1 to 5 do
              TryToBuild(c, bLittleMoney, false, true);
          end;
        end;
      end;
  end;

procedure PlayerOptions;
  var PO: PPlayerOpts;
  begin
    PO := New(PPlayerOpts, Init);
    PO^.Handle;
    PO^.Apply;
    Dispose(PO, Done);
  end;

constructor TMapOpts.Init;
  var
    DirInfo: SearchRec;
    i: integer;
  begin
    TObject.Init;

    MapType := 1;
    NPlayers := 6;
    Loopiness := 3;
    NumTwists := 0;
    for i := 1 to twMax do
      TwistOpts[i] := tcRandom;

    fnames := New(PStringCollection, Init(24, 8));

    FindFirst('*.RMT', AnyFile, DirInfo);
    while DosError = 0 do begin
      fnames^.Insert(NewStr(DirInfo.Name));
      FindNext(DirInfo);
    end;

    FileNum := 0;
  end;

destructor TMapOpts.Done;
  begin
    Dispose(fnames, Done);

    TObject.Done;
  end;

procedure TMapOpts.GetRMTStats(var players, space: integer);
  var
    f: text;
    s: string;
    i, j: integer;
    ch: char;
  begin
    players := 0;
    space := 0;

    assign(f, PString(fnames^.At(FileNum))^);
    reset(f);

    for i := 1 to 25 do begin
      readln(f, s);
      if (i mod 2) = 0 then
        for j := 1 to 12 do begin
          ch := s[j * 2];
          if ch <> '*' then
            inc(space);
          if (ch in ['1'..'8']) and (players < ord(ch) - ord('0')) then
            players := ord(ch) - ord('0');
        end;
    end;

    close(f);
  end;

procedure TMapOpts.Draw;
  const
    FTCol: array [boolean] of byte = (colBlack, colWhite);
  var
    players, space: integer;
  begin
    DrawText(20, 15, colBlack, colLightBlue, 'Dudes of Stuff and Things');
    DrawText(20, 25, colBlack, colLightGray, 'by Donald X.');


    DrawIcon2c(20, 15 + 60, FTCol[MapType = 1], colBlack, @RightArrow);
    DrawText(80, 15 + 60 + 10, colBlack, colWhite, 'Random Map');
    DrawIcon2c(240, 15 + 60, FTCol[MapType = 1], colBlack,
               @Numerals[NPlayers]);
    DrawText(300, 15 + 60 + 10, colBlack, colWhite, '# of Players');
    DrawIcon2c(240, 15 + 60 * 2, FTCol[MapType = 1], colBlack,
               @Numerals[Loopiness]);
    DrawText(300, 15 + 60 * 2 + 10, colBlack, colWhite, 'Loopiness');

    DrawIcon2c(460, 15 + 60, FTCol[MapType in [1, 2]], colBlack,
               @Numerals[NumTwists]);
    DrawText(520, 15 + 60 + 10, colBlack, colWhite, 'Random Twists');
    DrawIcon2c(460, 15 + 60 * 2, FTCol[MapType in [1, 2]], colBlack, @RightArrow);
    DrawText(520, 15 + 60 * 2 + 10, colBlack, colWhite, 'Edit Twists');

    DrawIcon2c(20, 15 + 60 * 3, FTCol[MapType = 2], colBlack, @RightArrow);
    DrawText(80, 15 + 60 * 3 + 10, colBlack, colWhite, 'Randomized');
    DrawText(80, 15 + 60 * 3 + 20, colBlack, colWhite, 'Scenario');
    DrawIcon2c(240, 15 + 60 * 3, FTCol[MapType = 2], colBlack, @Computer);
    if fnames^.Count > 0 then begin
      DrawText(300, 15 + 60 * 3 + 10, colBlack, colWhite,
               LSet(PString(fnames^.At(FileNum))^, 20));
      GetRMTStats(players, space);
      DrawText(300, 15 + 60 * 3 + 20, colBlack, colLightGray,
               LSet(IStr(players, 0) + ' players, size '
                    + IStr((space * 100) div 144, 0) + '%.', 24));
    end;

    DrawIcon2c(20, 15 + 60 * 5, FTCol[MapType = 3], colBlack, @RightArrow);
    DrawText(80, 15 + 60 * 5 + 10, colBlack, colWhite, 'Load Saved Game');

    DrawIcon2c(20, 15 + 60 * 7, FTCol[MapType = 4], colBlack, @RightArrow);
    DrawText(80, 15 + 60 * 7 + 10, colBlack, colWhite, 'Quit');

    DrawIcon(600, 440, @RightArrow);
  end;

procedure DrawTwist(i, c: integer; s: string);
  var y: integer;
  begin
    y := i * 16;
    XRectangle(40, y, 72, y + 12, c);
    DrawText(44, y + 3, colBlack, c, s);
    DrawText(80, y + 3, colBlack, c, TwistNames^[i] + '.');
  end;

procedure ShowTwists;
  const
    OnOffText: array [boolean] of string[3] = ('Off', 'On ');
    OnOffColor: array [boolean] of integer = (colDarkGray, colWhite);
  var
    i, x, y: integer;
    E: TEvent;
    db, over: boolean;
  begin
    db := DrawBackground;
    DrawBackground := false;
    ClearScr;

    for i := 1 to twMax do
      DrawTwist(i, OnOffColor[Twists[i]], OnOffText[Twists[i]]);

    if Twists[twMonstersHaveAbility] then
      DrawText(80 + 8 * length(TwistNames^[twMonstersHaveAbility]) + 16,
               twMonstersHaveAbility * 16 + 3, colBlack, OnOffColor[true],
               '(' + FlagNames^[AllMonstersAbility] + ')');

    DrawIcon(600, 440, @RightArrow);
    over := false;

    repeat
      WaitForEvent(E);
      if E.What = evMouseDown then begin
        x := E.Where.X;
        y := E.Where.Y;
        if (E.Buttons = mbLeftButton) and (x >= 600) and (y >= 440) then
          over := true;
      end;
    until over;

    DrawBackground := db;
    ClearScr;
  end;

procedure TMapOpts.DrawTwists;
  const
    TwistText: array [TTwistChoice] of string[3] =
    (
      'Off', 'On ', ' ? '
    );
    TwistColor: array [TTwistChoice] of integer =
    (
      colDarkGray, colWhite, colLightGray
    );
  var
    i: integer;
  begin
    for i := 1 to twMax do
      DrawTwist(i, TwistColor[TwistOpts[i]], TwistText[TwistOpts[i]]);

    DrawIcon(600, 440, @RightArrow);
  end;

procedure TMapOpts.GetTwists;
  var
    over: boolean;
    E: TEvent;
    x, y: integer;
  begin
    over := false;

    ClearScr;
    DrawTwists;

    repeat
      WaitForEvent(E);
      if (E.What = evMouseDown) and (E.Buttons = mbLeftButton) then begin
        x := E.Where.X;
        y := E.Where.Y;
        if (x >= 600) and (y >= 440) then
          over := true
        else if (x >= 40) and (x <= 72) then begin
          y := y div 16;
          if (y >= 1) and (y <= twMax) then begin
            if TwistOpts[y] = high(TTwistChoice) then
              TwistOpts[y] := low(TTwistChoice)
            else
              inc(TwistOpts[y]);
            DrawTwists;
          end;
        end;
      end;
    until over;
  end;

procedure TMapOpts.PickTwists;
  var
    i, j, r, n: integer;
    s: string;
  begin
    r := 0;

    for i := 1 to twMax do begin
      Twists[i] := TwistOpts[i] = tcOn;
      if TwistOpts[i] = tcRandom then inc(r);
    end;

    if r <= NumTwists then begin
      for i := 1 to twMax do
        if TwistOpts[i] = tcRandom then
          Twists[i] := true;
    end else begin
      for i := 1 to NumTwists do begin
        n := random(r);
        j := 1;
        while (TwistOpts[j] <> tcRandom) or Twists[j] do inc(j);
        while n > 0 do begin
          inc(j);
          while (TwistOpts[j] <> tcRandom) or Twists[j] do inc(j);
          dec(n);
        end;
        Twists[j] := true;
        dec(r);
      end;
    end;

    if Twists[twOneSquareDwelling] then
      OneSquareDwelling := random(6) + bCreature1;
    if Twists[twCastleCreaturesMixed] then
      for i := 2 to 6 do
        MixedCreaturesOfs[i] := random(8);
    if Twists[twMonstersHaveAbility] then
      repeat
        AllMonstersAbility := random(FlagMax) + 1;
{       AllMonstersAbility := 82;  }
      until (AllMonstersAbility <> 17)      { can't be smash obstacles }
            and (AllMonstersAbility <> 24)  { or stun }
            and (AllMonstersAbility <> 62)  { or fire trail }
            and (AllMonstersAbility <> 71); { or makes creatures }
    if Twists[twDoubleMovement] then
      for i := 1 to NumHeroes do
        Hero^[i].MP := HeroMaxMP(i);

    n := 0;

    for i := 1 to twMax do
      if Twists[i] then inc(n);

    if n > 0 then ShowTwists;
  end;

procedure TMapOpts.Handle;
  var
    over: boolean;
    E: TEvent;
    x, y: integer;

  function InIcon(ix, iy: integer): boolean;
    begin
      InIcon := (x >= ix) and (x < ix + 40)
                and (y >= iy) and (y < iy + 40);
    end;

  begin
    over := false;
    Load;

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
          end else if InIcon(20, 15 + 60) then begin
            MapType := 1;
          end else if InIcon(20, 15 + 60 * 3) then begin
            if fnames^.Count > 0 then
              MapType := 2;
          end else if InIcon(20, 15 + 60 * 5) then begin
            MapType := 3;
          end else if InIcon(20, 15 + 60 * 7) then begin
            MapType := 4;
          end else if InIcon(240, 15 + 60) then begin
            case NPlayers of
              2: NPlayers := 3;
              3: NPlayers := 4;
              4: NPlayers := 6;
              6: NPlayers := 8;
              8: NPlayers := 2;
            end;
          end else if InIcon(240, 15 + 60 * 2) then begin
            if Loopiness = 5 then
              Loopiness := 1
            else
              inc(Loopiness);
          end else if InIcon(460, 15 + 60) then begin
            if NumTwists < 8 then
              inc(NumTwists)
            else
              NumTwists := 0;
          end else if InIcon(460, 15 + 60 * 2) then begin
            GetTwists;
            ClearScr;
            Draw;
          end else if InIcon(240, 15 + 60 * 3) then begin
            if FileNum < fnames^.Count - 1 then
              inc(FileNum)
            else
              FileNum := 0;
          end;
          Draw;
        end;
      end;
    until over;

    Save;
  end;

procedure TMapOpts.Load;
  var f: file;
  begin
    assign(f, 'options.dat');
    reset(f, 1);
    blockread(f, MapType, sizeof(MapType));
    blockread(f, NPlayers, sizeof(NPlayers));
    blockread(f, Loopiness, sizeof(Loopiness));
    blockread(f, NumTwists, sizeof(NumTwists));
    blockread(f, TwistOpts, sizeof(TwistOpts));
    close(f);
  end;

procedure TMapOpts.Save;
  var f: file;
  begin
    assign(f, 'options.dat');
    rewrite(f, 1);
    blockwrite(f, MapType, sizeof(MapType));
    blockwrite(f, NPlayers, sizeof(NPlayers));
    blockwrite(f, Loopiness, sizeof(Loopiness));
    blockwrite(f, NumTwists, sizeof(NumTwists));
    blockwrite(f, TwistOpts, sizeof(TwistOpts));
    close(f);
  end;

procedure MapOptions;
  var
    MO: PMapOpts;
    MS: PMapScr;
    MG: PMapGeos;
    mt: integer;
  begin
    InitPlayers;
    InitHeroes;

    LoadSavedGame := false;
    QuitToMenu := false;

    repeat
      New(MG);
      New(MS, Init);
      MS^.MapGeos := MG;

      if LoadSavedGame then begin
        LoadSavedGame := false;
        MS^.LoadGame;
        mt := 3;
      end else begin
        if QuitToMenu then begin
          QuitToMenu := false;
          Dispose(MS, Done);
          New(MS, Init);
          MS^.MapGeos := MG;
          InitPlayers;
          InitHeroes;
        end;

        MO := New(PMapOpts, Init);
        MO^.Handle;
        mt := MO^.MapType;

        if mt = 1 then begin
          NumPlayers := MO^.NPlayers;
          DrawText(80, 15 + 60 + 10 + 10, colRed, colWhite, 'Generating...');
          RefreshScreen;
          MakeRandomMap(MG, MO^.NPlayers, 20 * (6 - MO^.Loopiness));
        end else if mt = 2 then begin
          LoadRandomMap(MG, PString(MO^.fnames^.At(MO^.FileNum))^);
        end;

        if mt in [1, 2] then begin
          MapGeosToMap(MG);
          MO^.PickTwists;
          PlayerOptions;
          ClearScr;
          DrawBackground := true;
          BackgroundColor := colGreen;
          MS^.Setup;
        end else if mt = 3 then begin
          MS^.LoadGame;
        end;

        Dispose(MO, Done);
      end;

      if (mt <> 4) and not MS^.GameOver then MS^.Handle;

      Dispose(MS, Done);
      Dispose(MG);
    until not LoadSavedGame and not QuitToMenu;
  end;

procedure LoadHints;
  var f: file;
  begin
    New(ArtHelp);
    New(FlagHelp);
    New(TwistNames);
    New(FlagNames);
    assign(f, 'strings.dat');
    reset(f, 1);
    blockread(f, ArtHelp^, sizeof(ArtHelp^));
    blockread(f, FlagHelp^, sizeof(FlagHelp^));
    blockread(f, TwistNames^, sizeof(TwistNames^));
    blockread(f, FlagNames^, sizeof(FlagNames^));
    close(f);
  end;

{ unit initialization }

begin
  LoadHints;
end.
