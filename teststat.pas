program test;

{ test out hommx stuff - calc stats }

uses CRT, Graph, Drivers, LowGr, Monsters, Combat, XStrings, Castles;

procedure colortest;
  var i, j: integer;
  begin
    for i := 480 to 639 do
      for j := 320 to 479 do
        PutPixel(i, j, ((i - 480) div 40) * 4 + ((j - 320) div 40));
  end;

procedure run;
  const
    GrDriver: integer = VGA;
    GrMode: integer = VGAHi;
    locs: array [1..12, 1..2] of byte =
    (
      (1, 2), (1, 4), (1, 6), (1, 8), (1, 10), (1, 12),
      (12, 1), (12, 3), (12, 5), (12, 7), (12, 9), (12, 11)
    );
  var
    i, m, sid, q: integer;
    monster1, monster2, level, m1, m2: integer;
    f: text;
    gpa, rgpa: longint;
  begin
    InitEvents;
    InitGraph(GrDriver, GrMode, '');
    SetPalette;
    randomize;

    assign(f, 'temp.dat');
    rewrite(f);
    writeln(f, 'attacking  defending  attack gp adv');
    writeln(f, '---------  ---------  -------------');
{   for level := 1 to 8 do begin }
    level := 2;
      for monster2 := 1 to 8 do
        for monster1 := 1 to 8 do begin
          m1 := monster1 * 6 - 5 + 1 - 1;
          m2 := monster2 * 6 - 5 + level - 1;

          ACombat := New(PCombat, Init(true, 0, 0, 1));

          with ACombat^ do begin
            ClearStacks;
            for i := 1 to 12 do begin
              if i >= 7 then begin
                sid := 2;
                m := m2;
              end else begin
                sid := 1;
                m := m1 + i - 1;
              end;
              q := 6000 div MonsterData[m].cost;
              if m = moBunny then q := (q * 11) div 10;
              AddStack(locs[i, 1], locs[i, 2], sid, m, q, 0, 0);
            end;

{           ACombat^.actual := false; }
            HandleCombat;
          end;

          for i := 1 to StackMax do begin
            if ACombat^.Stacks[i].illusion <> 0 then
              ACombat^.Stacks[i].qty := 0;
            ACombat^.Stacks[i].done := true; { for gpa calc }
          end;

          ACombat^.GoldPieceAdvantage(1, gpa, rgpa);
          writeln(f, LSet(CastleNames[TCastleType(monster1-1)], 9) + '  '
                     + LSet(MonsterData[m2].name, 9) + '  '
                     + LStr(gpa, 13));

          Dispose(ACombat, Done);
         end;
      writeln(f, '---------  ---------  -------------');
{   end; }
    close(f);

    CloseGraph;
    DoneEvents;
  end;

begin
  run;
end.
