program test;

{ test hommx combat }

uses CRT, Graph, Drivers, LowGr, Monsters, Combat;

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
    side1 = 2 * 6 + 1;
    side2 = 0 * 6 + 1;
    monster1 = moSlaver;
    monster2 = moNinja;
    rand = false;
    rand1 = false;
    advantage = 0;
    slowem = false;
  var
    i, m, rm, sid, q, st: integer;
  begin
    InitEvents;
    InitGraph(GrDriver, GrMode, '');
    SetPalette;

    if rand or rand1 then randomize;
    if rand1 then rm := random(36) + 1;

    ACombat := New(PCombat, Init(true, 0, 0, 1, colGreen));

    with ACombat^ do begin
      for i := 1 to 12 do begin
        if i >= 7 then begin
          sid := 2;
          if monster2 = 0 then m := side2 + i - 7 else m := monster2
        end else begin
          sid := 1;
          if monster1 = 0 then m := side1 + i - 1 else m := monster1;
        end;
        if rand then m := random(36) + 1;
        if rand1 and (sid = 2) then m := rm;
        q := 6000 div MonsterData[m].cost;
        if advantage = sid then q := q * 4;
        st := AddStack(locs[i, 1], locs[i, 2], sid, m, q, 0, 0);
        if slowem and (sid = 2) then
          Stacks[st].speed := Stacks[st].speed div 2;
      end;

      HandleCombat;
    end;

    Dispose(ACombat, Done);

    CloseGraph;
    DoneEvents;
  end;

begin
  run;
end.
