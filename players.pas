unit players;

{ players for hommx }

interface

uses Rez, LowGr;

const
  MaxMaxDudes = 8;
  MaxTowns = 8 + 8 + 1 + 8; { 8 starting, 8 outposts, 1 center, 8 scenario }

  PlColor: array [0..8] of integer =
  (
    colLightGray,
    colBlack, colYellow, colRed, colBlue,
    colRedOranges + 5, colMagentas + 5, colDarkBlue, colLightRed
  );

  PlName: array [0..8] of string[12] =
  (
    'Neutral',
    'Black', 'Yellow',  'Red', 'Blue',
    'Orange', 'Magenta', 'Dark Blue', 'Light Red'
  );

  SpyMode: boolean = false;

  smShaman = 1;
  smMagician = 2;
  smWizard = 3;

  SpellMineNames: array [1..3] of string[20] =
  (
    'Shaman''s Hut',
    'Magician''s Home',
    'Wizard''s House'
  );

type
  TPlayer = record
    AI: boolean;
    Resources: TResourceSet;
    Dudes: array [1..MaxMaxDudes] of byte;
    Towns: array [1..MaxTowns] of byte;
    DeathNoted: boolean;
    SkillMines: array [1..10] of byte;
    SpellMines: array [1..3] of byte;
    HusbandryMines: array [1..6] of byte;
  end;

var
  Player: array [1..8] of TPlayer;
  NumPlayers: integer;
  Turn, Date: integer;

function MaxDudes: integer;
procedure GainHero(pl, h, x, y: integer);
procedure GainCastle(pl, c: integer);
procedure LoseCastle(pl, c: integer);
function PlayerDudes(pl: integer): integer;
function PlayerTowns(pl: integer): integer;
function VisibleTurn: boolean;
procedure SortHeroes(pl: integer);
procedure CalcSpareRez(pl: integer; var rez: TResourceSet);
procedure InitPlayers;

implementation

uses Heroes, Castles, Spells, Options;

function MaxDudes: integer;
  var md: integer;
  begin
    if Twists[twOnly2Heroes] then
      md := 2
    else
      md := MaxMaxDudes;
    MaxDudes := md;
  end;

procedure GainHero(pl, h, x, y: integer);
  var i, j: integer;
  begin
    j := 0;
    for i := MaxDudes downto 1 do
      if Player[pl].Dudes[i] = 0 then
        j := i;
    if j <> 0 then begin
      Player[pl].Dudes[j] := h;
      Hero^[h].player := pl;
      Hero^[h].MapX := x;
      Hero^[h].MapY := y;
      Hero^[h].DestX := 0;
      SortHeroes(pl);
    end;
  end;

procedure GainCastle(pl, c: integer);
  var i, j, cpl: integer;
  begin
    cpl := Castle[c].player;
    if cpl <> 0 then
      LoseCastle(cpl, c);

    for i := MaxTowns downto 1 do
      if Player[pl].Towns[i] = 0 then
        j := i;
    if j <> 0 then begin
      Player[pl].Towns[j] := c;
      Castle[c].Player := pl;
    end;

    RemoveAllPlans(c);
  end;

procedure LoseCastle(pl, c: integer);
  var i, j: integer;
  begin
    for i := 1 to MaxTowns do
      if Player[pl].Towns[i] = c then
        j := i;
    if j <> 0 then begin
      Player[pl].Towns[j] := 0;
      if j < MaxTowns then
        for i := j to MaxTowns - 1 do
          Player[pl].Towns[i] := Player[pl].Towns[i + 1];
      Castle[c].Player := 0;
    end;
  end;

function PlayerDudes(pl: integer): integer;
  var i: integer;
  begin
    i := MaxDudes;
    while (i > 0) and (Player[pl].Dudes[i] = 0) do dec(i);
    PlayerDudes := i;
  end;

function PlayerTowns(pl: integer): integer;
  var i: integer;
  begin
    i := MaxTowns;
    while (i > 0) and (Player[pl].Towns[i] = 0) do dec(i);
    PlayerTowns := i;
  end;

function VisibleTurn: boolean;
  begin
    VisibleTurn := SpyMode or not Player[Turn].AI;
  end;

procedure SortHeroes(pl: integer);
  var i, j, t: integer;
  begin
    with Player[pl] do begin
      for i := 1 to MaxDudes - 1 do
        if Dudes[i] <> 0 then begin
          for j := i + 1 to MaxDudes do
            if (Dudes[j] <> 0)
               and (Hero^[Dudes[i]].XP < Hero^[Dudes[j]].XP) then begin
              t := Dudes[i];
              Dudes[i] := Dudes[j];
              Dudes[j] := t;
            end;
        end;
    end;
  end;

procedure CalcSpareRez(pl: integer; var rez: TResourceSet);
  var
    need, rs: TResourceSet;
    r: TResource;
    i, j: integer;
  begin
    with Player[pl] do begin
      need[rGold] := 20000;
      for r := rRocks to high(TResource) do
        need[r] := 5;
      for i := 1 to MaxTowns do
        if Towns[i] <> 0 then begin
          for j := 1 to 6 do
            if CanBuildSomewhere(Towns[i],
                                 BuildingFootprint(Towns[i], j)^) then begin
              FindBuildCost(Towns[i], j, rs);
              for r := rRocks to high(TResource) do
                if rs[r] > need[r] then
                  need[r] := rs[r];
            end;
        end;

      for r := low(TResource) to high(TResource) do
        if need[r] >= Resources[r] then
          rez[r] := 0
        else
          rez[r] := Resources[r] - need[r];
    end;
  end;

procedure InitPlayers;
  var i: integer;
  begin
    FillChar(Player, sizeof(Player), #0);

    for i := 1 to high(Player) do
      with Player[i] do begin
        Resources[rGold] := 5000;
        Resources[rRocks] := 10;
        Resources[rApples] := 5;
        Resources[rEmeralds] := 5;
        Resources[rQuartz] := 5;
        Resources[rBeakers] := 5;
        Resources[rClay] := 5;
        AI := true;
        DeathNoted := false;
      end;

    Date := 0;
  end;

{ unit initialization }

end.
