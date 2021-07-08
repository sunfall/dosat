program testc;

{ test hommx castles }

uses CRT, Graph, Drivers, Players, LowGr, Castles;

const
  CT = ctCityOfShadows;

procedure run;
  const
    GrDriver: integer = VGA;
    GrMode: integer = VGAHi;
  var
    C: TCastle;
    CS: PCastleScr;
  begin
    InitEvents;
    InitGraph(GrDriver, GrMode, '');
    SetPalette;
    Randomize;

    InitPlayers;
    NumPlayers := 8;

    NewCastle(@C, 1, 1, CT, false, 0);

    CS := New(PCastleScr, Init);

    with CS^ do begin
      C.Garrison[1].monster := ord(CT) * 6 + 1;
      C.Garrison[1].qty := 64;
      C.Garrison[2].monster := ord(CT) * 6 + 2;
      C.Garrison[2].qty := 12;
      Player[1].Towns[1] := 1;
      Handle(@C, 1);
    end;

    Dispose(CS, Done);

    CloseGraph;
    DoneEvents;
  end;

begin
  run;
end.
