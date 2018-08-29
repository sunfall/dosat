program testmg;

{ test hommx map generation }

uses CRT, Graph, MapGen, XStrings, Map;

procedure OutStr(x, y, c: integer; s: string);
  const blank: string = 'ллллллллллллллллллллллллллллллллллллллллллллл';
  begin
    SetColor(black);
    OutTextXY(x, y, copy(blank, 1, length(s)));
    SetColor(c);
    OutTextXY(x, y, s);
  end;

procedure ShowMGO(MGO: PMapGenObj);
  var
    i, j, x, y, c: integer;
  begin
    with MGO^ do begin

      CloseOffUnreachable;

      for i := 1 to MapWallsSize do
        for j := 1 to MapWallsSize do
          if MW[i, j] or ((i mod 2 = 0) and (j mod 2 = 0)
                          and MW[i - 1, j] and MW[i + 1, j]
                          and MW[i, j - 1] and MW[i, j + 1]) then begin
            for x := 8 * (i - 1) to 8 * (i - 1) + 7 do
              for y := 8 * (j - 1) to 8 * (j - 1) + 7 do
                PutPixel(x, y, lightgray);
          end;

      for i := 1 to NumCastles do
        OutStr(Castles[i].X * 16 - 8, Castles[i].Y * 16 - 8, white,
               chr(ord('0') + i));

      for i := 1 to NumCrossroads do
          OutStr(Crossroads[i].X * 16 - 8, Crossroads[i].Y * 16 - 8, white,
                 chr(ord('A') + i - 1));

      if Center.X <> 0 then
        OutStr(Center.X * 16 - 8, Center.Y * 16 - 8, white, 'S');

      OutStr(240, 16, white, 'LCR = ' + IStr(LCR, 0));
      OutStr(360, 16, white, 'LRR = ' + IStr(LRR, 0));
      OutStr(480, 16, white, 'LSR = ' + IStr(LSR, 0));

      for i := 1 to NumCastles do begin
        j := Castleroad(i);
        MakeDistanceGrid(Crossroads[j]);
        OutStr(240, 32 + i * 16, white,
               chr(ord('0') + i) + ' to ' + chr(ord('A') + j - 1) +' = '
               + IStr(CrossroadDist(Castles[i], Crossroads[j]), 0) + ' ');
      end;

      for i := 1 to NumCrossroads do begin
        j := (i mod NumCrossroads) + 1;
        MakeDistanceGrid(Crossroads[i]);
        OutStr(360, 32 + i * 16, white,
               chr(ord('A') + i - 1) + ' to ' + chr(ord('A') + j - 1) +' = '
               + IStr(CrossroadDist(Crossroads[i], Crossroads[j]), 0) + ' ');
        if Center.X <> 0 then
          OutStr(480, 32 + i * 16, white,
                 chr(ord('A') + i - 1) + ' to S = '
                 + IStr(CrossroadDist(Crossroads[i], Center), 0) + ' ');
      end;

      for i := 1 to NumCastles do begin
        OutStr(240, 200 + (i - 1) * 16, white, IStr(i, 0));
        OutStr(256 + (i - 1) * 32, 200 - 16, white, IStr(i, 0));
        MakeDistanceGrid(Castles[i]);
        for j := 1 to NumCastles do
          if i <> j then begin
            if CastleRoad(i) = CastleRoad(j) then
              c := yellow
            else
              c := white;
            OutStr(256 + (j - 1) * 32, 200 + (i - 1) * 16, c,
                   LSet(IStr(CrossroadDist(Castles[i], Castles[j]), 0), 4));
          end;
      end;

      OutStr(0, 216, white, LStr(Score, 4) + ' -> '
                                 + RStr(NormalizedScore, 7, 3));
    end;
  end;

procedure run;
  const
    GrDriver: integer = VGA;
    GrMode: integer = VGAHi;
  var
    MGO: PMapGenObj;
  begin
    InitGraph(GrDriver, GrMode, '');

    Randomize;
    New(MGO, Init(6));

    with MGO^ do begin
      InitMapWalls;
      PickPoints;
      FindLongestDistances;
      OutStr(0, 232, white, 'Paths');
      repeat
        ShowMGO(MGO);
      until not MakePaths;

      MakeGeoDiffs;

      OutStr(0, 232, white, 'Space');
      repeat
        ShowMGO(MGO);
      until not RemoveSpace;

      ShowMGO(MGO);
      OutStr(0, 232, white, 'Done ');
      repeat until keypressed;
    end;

    Dispose(MGO, Done);

    CloseGraph;
  end;

begin
  run;
end.
