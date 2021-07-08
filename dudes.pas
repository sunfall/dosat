program dudes;

{ Dudes of Stuff and Things }

{ compile in protected mode! }

uses CRT, Drivers,
     XSVGA, XStrings, Trap, LowGr, XMouse, Hexes, Rez, XFace,
     Players, Map, MapScr, MapGen, Heroes, Monsters,
     Spells, Artifact, Options, Castles, CombSub, Combat;

procedure run;
  var
    i, pl, h: integer;
  begin
    InitEvents;
    InitSVGA;
    SetSVGAMode;
    SetPalette;
    InitTrap;

{}  Randomize; {}

    MapOptions;

    CloseGraphics;
    DoneSVGA;
    DoneEvents;
  end;

begin
  run;
end.
