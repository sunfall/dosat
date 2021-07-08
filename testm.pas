program testm;

{ Dudes of Stuff and Things }

{ compile in protected mode! }

uses CRT, Graph, Drivers,
     XStrings, Trap, LowGr, Misc, Hexes, Rez, XFace,
     Players, Map, MapScr, MapGen, Heroes, Monsters,
     Spells, Artifact, Options, Castles, Combat;

procedure run;
  const
    GrDriver: integer = VGA;
    GrMode: integer = VGAHi;
  var
    i, pl, h: integer;
  begin
    InitEvents;
    InitGraph(GrDriver, GrMode, '');
    SetPalette;
    InitTrap;

    Randomize;

    InitPlayers;
    InitHeroes;

    MapOptions;

    CloseGraph;
    DoneEvents;
  end;

begin
  run;
end.
