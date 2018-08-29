unit mapgen;

{ generate random map of geos for hommx }

{
  start by distributing R's and C's
    sometimes S near center
    R's on circle around center
      S and R's must be all-even or all-odd
    C's in neighborhood of R's
      all-even or all-odd

  count longest R-R distance - LRR and longest C-R - LCR (and LSR)
    that will be target for that kind of line
    sometimes add 2 to total

  basic algorithm:
    for each path between points that matter, if it's too short
      see which wall we can add to get best score
        score is sum of squares of line diff's from target lengths
      if anything at least ties current score, make that change

    repeat process until don't make a change

    R wants to be at least LRR from each other R
    C wants to be at least LCR from each R
    R wants to be at least LSR from S
    C wants to be at least 2*LCR from each neighborhood C
    C wants to be at least 2*LCR+LRR from each distant C
      or 2*LCR+2*LSR

  reassess longest distances and redo?

  then also check castle treat neighborhoods
    count reachable area as sum of 20-distance to squares
    wall of areas to try to make each castle have same sum as minimum
}

interface

uses Objects, Map;

const
  MapWallsSize = MapGeoSize * 2 + 1;

type
  PMapWalls = ^TMapWalls;
  TMapWalls = array [1..MapWallsSize, 1..MapWallsSize] of boolean;

  TCrossroad = record
    x, y: integer;
  end;

  TDistGrid = array [1..MapGeoSize, 1..MapGeoSize] of integer;

  PMapGenObj = ^TMapGenObj;
  TMapGenObj = object(TObject)
    NumCastles: integer;
    NumCrossroads: integer;
    MW: TMapWalls;
    MG: TMapGeos;
    Crossroads: array [1..8] of TCrossroad;
    Center: TCrossroad;
    Castles: array [1..8] of TCrossroad;
    grid: array [1..MapGeoSize, 1..MapGeoSize] of byte;
    LSR, LRR, LCR, LCN, LCC: integer;
    radius: real;
    dist: TDistGrid;
    SpaceToRemove: integer;
    constructor Init(iNumCastles, iSpaceToRemove: integer);
    destructor Done; virtual;
    function Castleroad(i: integer): integer;
    procedure RandomCastle(bx, by, r: integer; var x, y: integer);
    procedure InitMapWalls;
    procedure PickPoints;
    function AddDistanceLayer(n: integer): boolean;
    procedure MakeDistanceGrid(cr: TCrossroad);
    function CrossroadDist(cr1, cr2: TCrossroad): integer;
    procedure FindLongestDistances;
    function Score: longint;
    function MakePaths: boolean;
    procedure RemoveDistance;
    procedure RemoveMaxDiff;
    function ExtraSpace: longint;
    procedure RemoveSpace;
    procedure CloseOffUnreachable;
    procedure AddForts;
    procedure MakeGeos(coutposts, scastle: boolean);
    procedure MakeGeoDiffs;
    procedure MakeMap(part1, part2: boolean);
    function NormalizedScore: real;
  end;

procedure LoadMG(MG: PMapGeos; fname: string);
procedure SaveMG(MG: PMapGeos; fname: string);
procedure MakeRandomMap(MG: PMapGeos; NumCastles, SpaceToRemove: integer);
procedure LoadRandomMap(MG: PMapGeos; fname: string);

implementation

uses Players;

const
  dirx: array [0..3] of integer = (-1, 0, 1, 0);
  diry: array [0..3] of integer = (0, -1, 0, 1);

constructor TMapGenObj.Init(iNumCastles, iSpaceToRemove: integer);
  begin
    TObject.Init;
    NumCastles := iNumCastles;
    SpaceToRemove := iSpaceToRemove;
    FillChar(grid, sizeof(grid), #0);
    FillChar(MG, sizeof(MG), #0);
  end;

destructor TMapGenObj.Done;
  begin
    TObject.Done;
  end;

procedure TMapGenObj.InitMapWalls;
  var i, j: integer;
  begin
    FillChar(MW, sizeof(MW), chr(ord(false)));

    for i := 1 to MapWallsSize do
      for j := 1 to MapWallsSize do
        if (((i mod 2) = 1) and ((j mod 2) = 1)) or (i = 1) or (j = 1)
           or (i = MapWallsSize) or (j = MapWallsSize) then
          MW[i, j] := true;
  end;

function TMapGenObj.Castleroad(i: integer): integer;
  begin
    Castleroad := ((i - 1) div (NumCastles div NumCrossroads)) + 1;
  end;

procedure TMapGenObj.RandomCastle(bx, by, r: integer; var x, y: integer);
  var r1, r2: integer;
  begin
    repeat
      r1 := random(r) - (r div 2);
      r2 := random(r) - (r div 2);
      x := bx + r1;
      y := by + r2;
    until (x >= 1) and (x <= MapGeoSize) and (y >= 1) and (y <= MapGeoSize)
          and (grid[x, y] = 0)
          and ((x + y) mod 2 = 0)
          and ((x - 6) * (x - 6) + (y - 6) * (y - 6) > radius);
  end;

procedure TMapGenObj.PickPoints;
  var
    th, a: real;
    i, j, w, xr: integer;
  begin
    case NumCastles of
      2,
      3: NumCrossroads := NumCastles;
      4: if random(2) = 0 then NumCrossroads := 2
         else NumCrossroads := 4;
      6: case random(3) of
           0: NumCrossroads := 2;
           1: NumCrossroads := 3;
           2: NumCrossroads := 6;
         end;
      8: case random(3) of
           0: NumCrossroads := 2;
           1: NumCrossroads := 4;
           2: NumCrossroads := 8;
         end;
    end;

    if (NumCastles <> 2) and (random(2) = 0) then begin
      Center.X := 6;
      Center.Y := 6;
      grid[Center.X, Center.Y] := mgcCenter;
    end else begin
      Center.X := 0;
    end;

    radius := 2 + random(3);
    if NumCrossroads > 4 then radius := radius + 1;
    th := random(360) * 2 * pi / 360;

    for i := 1 to NumCrossroads do
      with Crossroads[i] do begin
        a := (2 * pi / NumCrossroads) * (i - 1) + th;
        X := trunc(6.5 + radius * sin(a));
        Y := trunc(6.5 + radius * cos(a));
        if (X + Y) mod 2 <> 0 then begin
          if X > 6 then dec(X) else inc(X);
        end;
        if X < 1 then X := 1;
        if X > MapGeoSize then X := MapGeoSize;
        if Y < 1 then Y := 1;
        if Y > MapGeoSize then Y := MapGeoSize;
        grid[X, Y] := mgcCrossroad + 16 * i;
      end;

    for i := 1 to NumCastles do
      with Castles[i] do begin
        xr := CastleRoad(i);
        RandomCastle(Crossroads[xr].X, Crossroads[xr].Y, 5, X, Y);
        grid[X, Y] := mgcCastle + 16 * i;
      end;
  end;

function TMapGenObj.AddDistanceLayer(n: integer): boolean;
  var
    change: boolean;
    i, j: integer;

  procedure Check(oi, oj: integer);
    begin
      if not MW[i * 2 + oi, j * 2 + oj]
         and (dist[i + oi, j + oj] = 0) then begin
        dist[i + oi, j + oj] := n;
        change := true;
      end;
    end;

  begin
    change := false;

    for i := 1 to MapGeoSize do
      for j := 1 to MapGeoSize do
        if dist[i, j] = n - 1 then begin
          Check(0, -1);
          Check(0, 1);
          Check(-1, 0);
          Check(1, 0);
        end;

    AddDistanceLayer := change;
  end;

procedure TMapGenObj.MakeDistanceGrid(cr: TCrossroad);
  var
    change: boolean;
    n: integer;
  begin
    fillchar(dist, sizeof(dist), #0);
    dist[cr.X, cr.Y] := 1;
    n := 2;

    repeat
      change := AddDistanceLayer(n);
      inc(n);
    until not change;
  end;

function TMapGenObj.CrossroadDist(cr1, cr2: TCrossroad): integer;
  var d, d1, d2: integer;
  begin
    d1 := dist[cr1.X, cr1.Y];
    d2 := dist[cr2.X, cr2.Y];
    if (d1 = 0) or (d2 = 0) then
      d := 255
    else
      d := abs(d1 - d2);
    CrossroadDist := d;
  end;

procedure TMapGenObj.FindLongestDistances;
  var i, j, d: integer;
  begin
    LSR := 0;
    if Center.X <> 0 then begin
      MakeDistanceGrid(Center);
      for i := 1 to NumCrossroads do begin
        d := CrossroadDist(Crossroads[i], Center);
        if d > LSR then LSR := d;
      end;
      LSR := LSR + 2 * random(2);
    end;

    LRR := 0;
    for i := 1 to NumCrossroads do begin
      MakeDistanceGrid(Crossroads[i]);
      j := (i mod NumCrossroads) + 1;
      d := CrossroadDist(Crossroads[i], Crossroads[j]);
      if d > LRR then LRR := d;
    end;
    LRR := LRR + 2 * random(2);

    LCR := 0;
    for i := 1 to NumCastles do begin
      j := CastleRoad(i);
      MakeDistanceGrid(Crossroads[j]);
      d := CrossroadDist(Castles[i], Crossroads[j]);
      if d > LCR then LCR := d;
    end;
    LCR := LCR + 2 * random(2);

    LCN := 2 * LCR;

    if (Center.X <> 0) and (LSR * 2 < LRR) then
      LCC := LCN + LSR * 2
    else
      LCC := LCN + LRR;
  end;

function TMapGenObj.Score: longint;
  var
    t: longint;
    i, j, d, r: integer;
  begin
    t := 0;

    for i := 1 to NumCrossroads do begin
      MakeDistanceGrid(Crossroads[i]);

      if Center.X <> 0 then begin
        d := CrossroadDist(Crossroads[i], Center);
        t := t + longint(d - LSR) * (d - LSR);
      end;

      if not ((i = 2) and (NumCrossroads = 2)) then begin
        j := (i mod NumCrossroads) + 1;
        d := CrossroadDist(Crossroads[i], Crossroads[j]);
        t := t + longint(d - LRR) * (d - LRR);
      end;

      for j := 1 to NumCastles do
        if CastleRoad(j) = i then begin
          d := CrossroadDist(Crossroads[i], Castles[j]);
          t := t + longint(d - LCR) * (d - LCR);
        end;
    end;

    for i := 1 to NumCastles - 1 do begin
      r := CastleRoad(i);
      MakeDistanceGrid(Castles[i]);
      for j := i + 1 to NumCastles do begin
        d := CrossroadDist(Castles[i], Castles[j]);
        if Castleroad(j) = r then
          t := t + longint(d - LCN) * (d - LCN)
        else
          t := t + longint(d - LCC) * (d - LCC);
      end;
    end;

    Score := t;
  end;

function TMapGenObj.MakePaths: boolean;
  var
    i, j, r, d: integer;
    s: longint;
    oldwall: TMapWalls;
    change: boolean;
    dg: TDistGrid;
    cr: TCrossroad;

  procedure FixPath(cr1, cr2: TCrossroad);
    var
      bests, test: longint;
      px, py, pn, h, goth, bestwx, bestwy, hr, hi: integer;
    begin
      bests := MaxLongInt;
      px := cr2.X;
      py := cr2.Y;
      pn := dg[px, py];

      repeat
        goth := -1;
        hr := random(4);
        for hi := 0 to 3 do begin
          h := (hi + hr) mod 4;
          if (not MW[px * 2 + dirx[h], py * 2 + diry[h]])
             and (dg[px + dirx[h], py + diry[h]] = pn - 1) then
            goth := h;
        end;
        if goth <> -1 then begin
          MW[px * 2 + dirx[goth], py * 2 + diry[goth]] := true;
          test := Score;
          if test < bests then begin
            bests := test;
            bestwx := px * 2 + dirx[goth];
            bestwy := py * 2 + diry[goth];
          end;
          MW := oldwall;
          dist := dg;
          inc(px, dirx[goth]);
          inc(py, diry[goth]);
          pn := dg[px, py];
        end;
      until (goth = -1) or (pn = 1);

      if bests <= s then begin
        MW[bestwx, bestwy] := true;
        oldwall := MW;
        change := true;
        MakeDistanceGrid(cr);
        dg := dist;
      end;
    end;

  begin
    s := Score;
    oldwall := MW;
    change := false;

    for i := 1 to NumCrossroads do begin
      cr := Crossroads[i];
      MakeDistanceGrid(cr);
      dg := dist;

      if Center.X <> 0 then
        if CrossroadDist(Crossroads[i], Center) < LSR then
          FixPath(Crossroads[i], Center);

      j := (i mod NumCrossroads) + 1;
      if CrossroadDist(Crossroads[i], Crossroads[j]) < LRR then
        FixPath(Crossroads[i], Crossroads[j]);

      for j := 1 to NumCastles do
        if Castleroad(j) = i then
          if CrossroadDist(Crossroads[i], Castles[j]) < LCR then
            FixPath(Crossroads[i], Castles[j]);
    end;

    for i := 1 to NumCastles - 1 do begin
      r := CastleRoad(i);
      cr := Castles[i];
      MakeDistanceGrid(cr);
      for j := i + 1 to NumCastles do begin
        d := CrossroadDist(Castles[i], Castles[j]);
        if Castleroad(j) = r then begin
          if d < LCN then FixPath(Castles[i], Castles[j]);
        end else begin
          if d < LCC then FixPath(Castles[i], Castles[j]);
        end;
      end;
    end;

    MakePaths := change;
  end;

procedure TMapGenObj.RemoveDistance;
  var
    maxd: array [1..8] of integer;
    i, x, y, minmaxd: integer;
    sqmaxd: array [1..MapGeoSize, 1..MapGeoSize] of integer;
    s: longint;
    oldwall: TMapWalls;
  begin
    minmaxd := MaxInt;
    fillchar(sqmaxd, sizeof(sqmaxd), #0);
    s := Score;
    oldwall := MW;

    for i := 1 to NumCastles do begin
      MakeDistanceGrid(Castles[i]);
      maxd[i] := 0;
      for x := 1 to MapGeoSize do
        for y := 1 to MapGeoSize do
          if MG[x, y].diff <> 0 then begin
            if dist[x, y] > maxd[i] then
              maxd[i] := dist[x, y];
            if dist[x, y] > sqmaxd[x, y] then
              sqmaxd[x, y] := dist[x, y];
          end;
      if maxd[i] < minmaxd then minmaxd := maxd[i];
    end;

    for x := 1 to MapGeoSize do
      for y := 1 to MapGeoSize do
        if sqmaxd[x, y] > minmaxd then begin
          MW[x * 2 - 1, y * 2] := true;
          MW[x * 2 + 1, y * 2] := true;
          MW[x * 2, y * 2 - 1] := true;
          MW[x * 2, y * 2 + 1] := true;
          if Score <= s then
            oldwall := MW
          else
            MW := oldwall;
        end;
  end;

procedure TMapGenObj.RemoveMaxDiff;
  var
    x, y, maxdiff: integer;
    oldwall: TMapWalls;
    s: longint;
    doit: boolean;
  begin
    s := Score;
    oldwall := MW;
    repeat
      maxdiff := 0;
      MakeDistanceGrid(Castles[1]);

      for x := 1 to MapGeoSize do
        for y := 1 to MapGeoSize do
          if (dist[x, y] <> 0) and (MG[x, y].diff > maxdiff) then
            maxdiff := MG[x, y].diff;

      for x := 1 to MapGeoSize do
        for y := 1 to MapGeoSize do
          if MG[x, y].diff = maxdiff then begin
            MW[x * 2 - 1, y * 2] := true;
            MW[x * 2 + 1, y * 2] := true;
            MW[x * 2, y * 2 - 1] := true;
            MW[x * 2, y * 2 + 1] := true;
          end;

      doit := Score <= s;

      if doit then
        oldWall := MW
      else
        MW := oldWall;
    until not doit;
  end;

function TMapGenObj.ExtraSpace: longint;
  var
    space: array [1..8] of longint;
    sp, leastspace: longint;
    i, x, y, d: integer;
  begin
    leastspace := MaxLongInt;

    for i := 1 to NumCastles do begin
      MakeDistanceGrid(Castles[i]);
      sp := 0;
      for x := 1 to MapGeoSize do
        for y := 1 to MapGeoSize do
          if (dist[x, y] <> 0) and (MG[x, y].diff <> 0) then begin
            d := ((20 - dist[x, y]) * 12) div MG[x, y].diff;
            if d < 0 then d := 0;
            inc(sp, d);
          end;
      space[i] := sp;
      if sp < leastspace then leastspace := sp;
    end;

    sp := 0;
    for i := 1 to NumCastles do
      inc(sp, space[i] - leastspace);

    ExtraSpace := sp;
  end;

procedure TMapGenObj.RemoveSpace;
  var
    i, j, t, wi, wj, changes: integer;
    s, sp, test: longint;
    oldwall: TMapWalls;
    change: boolean;
    order: array [1..MapWallsSize * MapWallsSize] of integer;
  begin
    s := Score;
    oldwall := MW;
    sp := ExtraSpace;
    changes := 0;

    repeat
      change := false;

      for i := 1 to MapWallsSize * MapWallsSize do
        order[i] := i;

      for i := 1 to MapWallsSize * MapWallsSize do begin
        if i < MapWallsSize * MapWallsSize then begin
          j := i + random(MapWallsSize * MapWallsSize - i) + 1;
          t := order[i];
          order[i] := order[j];
          order[j] := t;
        end;

        wi := ((order[i] - 1) div MapWallsSize) + 1;
        wj := ((order[i] - 1) mod MapWallsSize) + 1;

        if (wi mod 2) + (wj mod 2) = 1 then
          if not MW[wi, wj] then begin
            MW[wi, wj] := true;
            test := ExtraSpace;
            if (Score <= s) and (test <= sp)
               and (changes < SpaceToRemove) then begin
              sp := test;
              oldwall := MW;
              change := true;
              inc(changes);
            end else begin
              MW := oldwall;
            end;
          end;
      end;
    until not change;
  end;

procedure TMapGenObj.CloseOffUnreachable;
  var i, j, h: integer;
  begin
    MakeDistanceGrid(Crossroads[1]);
    for i := 1 to MapGeoSize do
      for j := 1 to MapGeoSize do
        if dist[i, j] = 0 then
          for h := 0 to 3 do
            MW[i * 2 + dirx[h], j * 2 + diry[h]] := true;
  end;

procedure TMapGenObj.AddForts;
  var
    cancel: boolean;
    i, j, a1, b1, a2, b2, r: integer;

  procedure PlaceFortBetweenPoints(x1, y1, x2, y2: integer);
    var
      cr: TCrossroad;
      x, y, p, h, hi, hr, goth, hx, hy, midp: integer;
      found: boolean;
    begin
      cr.x := x1;
      cr.y := y1;
      MakeDistanceGrid(cr);
      midp := (dist[x2, y2] + 1) div 2;
      found := false;
      x := x2;
      y := y2;
      p := dist[x2, y2] - 1;

      repeat
        goth := -1;
        hr := random(4);
        for hi := 0 to 3 do begin
          h := (hi + hr) mod 4;
          hx := x + dirx[h];
          hy := y + diry[h];
          if (hx >= 1) and (hx <= MapGeoSize)
             and (hy >= 1) and (hy <= MapGeoSize)
             and (dist[hx, hy] = p) then
            goth := h;
        end;
        if goth <> -1 then begin
          inc(x, dirx[goth]);
          inc(y, diry[goth]);
          if (p = midp) and (grid[x, y] in [mgcNormal, mgcSmallFort,
                                            mgcBigFort]) then begin
            if grid[x, y] = mgcNormal then
              grid[x, y] := mgcSmallFort
            else
              grid[x, y] := mgcBigFort;
            found := true;
          end;
          dec(p);
        end;
      until found or (goth = -1) or (p = midp - 1);

      if not found then cancel := true;
    end;

  begin
    if random(3) = 0 then begin
      cancel := false;

      r := random(4);
      if ((r = 3) and (Center.X = 0))
         or ((NumCrossroads = 2) and ((r = 1) or (r = 3))) then
        r := 0;

      case r of
        0: for i := 1 to NumCastles do begin  { between castles }
             j := (i mod NumCastles) + 1;
             PlaceFortBetweenPoints(Castles[i].x, Castles[i].y,
                                    Castles[j].x, Castles[j].y);
           end;
        1: for i := 1 to NumCrossroads do begin { between crossroads }
             j := (i mod NumCrossroads) + 1;
             PlaceFortBetweenPoints(Crossroads[i].x, Crossroads[i].y,
                                    Crossroads[j].x, Crossroads[j].y);
           end;
        2: for i := 1 to NumCastles do begin { between castles / crossroads }
             j := CastleRoad(i);
             PlaceFortBetweenPoints(Castles[i].x, Castles[i].y,
                                    Crossroads[j].x, Crossroads[j].y);
           end;
        3: for i := 1 to NumCrossroads do { between crossroads and center }
             PlaceFortBetweenPoints(Center.x, Center.y,
                                    Crossroads[i].x, Crossroads[i].y);
      end;

      if cancel then
        for i := 1 to MapGeoSize do
          for j := 1 to MapGeoSize do
            if (grid[i, j] = mgcSmallFort) or (grid[i, j] = mgcBigFort) then
              grid[i, j] := mgcNormal;
    end;
  end;

procedure TMapGenObj.MakeGeos(coutposts, scastle: boolean);
  var i, j, g, c: integer;
  begin
    for i := 1 to MapGeoSize do
      for j := 1 to MapGeoSize do begin
        MG[i, j].rand := random(256);
        c := grid[i, j];
        MG[i, j].cat := c;
        if ((c and $0F) = mgcCastle)
           or (coutposts and ((c and $0F) = mgcCrossroad))
           or (scastle and (c = mgcCenter))
           or (c = mgcBigFort) or (c = mgcSmallFort) then begin
          g := 82;
          if MW[i * 2, j * 2 - 1] then g := g + 1;
          if MW[i * 2 + 1, j * 2] then g := g + 2;
          if MW[i * 2, j * 2 + 1] then g := g + 4;
          if MW[i * 2 - 1, j * 2] then g := g + 8;
          if random(2) = 0 then inc(g, NumGeos div 2);
          MG[i, j].geo := g;
        end;
      end;

    for i := 1 to MapGeoSize do
      for j := 1 to MapGeoSize do
        if MG[i, j].geo = 0 then begin
          g := 1;

          if MW[i * 2, j * 2 - 1] then
            g := g + 2
          else if MG[i, j - 1].geo <> 0 then
            g := g + GeoEdge(MG[i, j - 1].geo, geBottom)
          else if random(2) = 0 then
            g := g + 1;

          if MW[i * 2 + 1, j * 2] then
            g := g + 2 * 3
          else if MG[i + 1, j].geo <> 0 then
            g := g + 3 * GeoEdge(MG[i + 1, j].geo, geLeft)
          else if random(2) = 0 then
            g := g + 3;

          if MW[i * 2, j * 2 + 1] then
            g := g + 2 * 9
          else if MG[i, j + 1].geo <> 0 then
            g := g + 9 * GeoEdge(MG[i, j + 1].geo, geTop)
          else if random(2) = 0 then
            g := g + 9;

          if MW[i * 2 - 1, j * 2] then
            g := g + 2 * 27
          else if MG[i - 1, j].geo <> 0 then
            g := g + 27 * GeoEdge(MG[i - 1, j].geo, geRight)
          else if random(2) = 0 then
            g := g + 27;

          if random(2) = 0 then inc(g, NumGeos div 2);
          MG[i, j].geo := g;
        end;
  end;

procedure TMapGenObj.MakeGeoDiffs;
  var
    i, j, n: integer;
    change: boolean;

  procedure CheckDiff(io, jo: integer);
    begin
      if not MW[i * 2 + io, j * 2 + jo]
         and (MG[i + io, j + jo].diff = 0) then begin
        MG[i + io, j + jo].diff := n + 1;
        change := true;
      end;
    end;

  begin
    for i := 1 to MapGeoSize do
      for j := 1 to MapGeoSize do
        if (grid[i, j] and $0F) = mgcCastle then
          MG[i, j].diff := 1
        else
          MG[i, j].diff := 0;

    n := 1;
    repeat
      change := false;
      for i := 1 to MapGeoSize do
        for j := 1 to MapGeoSize do
          if MG[i, j].diff = n then begin
            CheckDiff(-1, 0);
            CheckDiff(1, 0);
            CheckDiff(0, -1);
            CheckDiff(0, 1);
          end;
      inc(n);
    until not change;
  end;

procedure TMapGenObj.MakeMap(part1, part2: boolean);
  begin
    if part1 then begin
      InitMapWalls;
      PickPoints;
      FindLongestDistances;
      repeat until not MakePaths;
    end;
    if part2 then begin
      MakeGeoDiffs;
      RemoveDistance;
      RemoveMaxDiff;
      RemoveSpace;
      CloseOffUnreachable;
      MakeGeoDiffs;
      AddForts;
      MakeGeos(random(6) <> 0, (Center.X <> 0) and (random(4) <> 0));
    end;
  end;

function TMapGenObj.NormalizedScore: real;
  var n: integer;
  begin
    n := (NumCastles * (NumCastles - 1) div 2)
         + NumCastles + NumCrossroads;
    if Center.X <> 0 then inc(n, NumCrossroads);
    if NumCrossroads = 2 then dec(n);

    NormalizedScore := Score / n;
  end;

procedure LoadMG(MG: PMapGeos; fname: string);
  var
    f: file;
    result: word;
  begin
    assign(f, fname);
    reset(f, 1);
    BlockRead(f, MG^, sizeof(MG^), result);
    close(f);
  end;

procedure SaveMG(MG: PMapGeos; fname: string);
  var
    f: file;
    result: word;
  begin
    assign(f, fname);
    rewrite(f, 1);
    BlockWrite(f, MG^, sizeof(MG^), result);
    close(f);
  end;

procedure MakeRandomMap(MG: PMapGeos; NumCastles, SpaceToRemove: integer);
  const
    DesiredScore = 5;
  var
    MGO: PMapGenObj;
    s: real;
  begin
    repeat
      New(MGO, Init(NumCastles, SpaceToRemove));
      MGO^.MakeMap(true, false);
      s := MGO^.NormalizedScore;
      if s < DesiredScore then begin
        MGO^.MakeMap(false, true);
        MG^ := MGO^.MG;
      end;
      Dispose(MGO, Done);
    until s < DesiredScore;
  end;

procedure LoadRandomMap(MG: PMapGeos; fname: string);
  var
    MGO: PMapGenObj;
    f: text;
    lines: array [1..25] of string[30];
    x, y, gx, gy, n, NumCastles, NumCrossroads: integer;
    ch: char;
  begin
    NumCastles := 0;
    NumCrossroads := 0;

    assign(f, fname);
    reset(f);
    for y := 1 to 25 do begin
      readln(f, lines[y]);
      for x := 1 to 25 do begin
        ch := lines[y][x];
        case ch of
          '1'..'8': if ord(ch) - ord('0') > NumCastles then
                      NumCastles := ord(ch) - ord('0');
          'a'..'h': if ord(ch) - ord('a') + 1 > NumCrossroads then
                      NumCrossroads := ord(ch) - ord('a') + 1;
        end;
      end;
    end;
    close(f);

    NumPlayers := NumCastles;

    New(MGO, Init(NumCastles, 0));
    MGO^.NumCrossroads := NumCrossroads;
    MGO^.Center.X := 0;

    for y := 1 to 25 do
      for x := 1 to 25 do
        MGO^.MW[x, y] := lines[y][x] = '*';

    for y := 1 to 25 do begin
      gy := (y + 1) div 2;
      for x := 1 to 25 do begin
        gx := (x + 1) div 2;
        ch := lines[y][x];
        case ch of
          '1'..'8': begin
                      n := ord(ch) - ord('0');
                      MGO^.grid[gx, gy] := mgcCastle + 16 * n;
                      MGO^.Castles[n].x := gx;
                      MGO^.Castles[n].y := gy;
                    end;
          'a'..'h': begin
                      n := ord(ch) - ord('a') + 1;
                      MGO^.grid[gx, gy] := mgcCrossroad + 16 * n;
                    end;
          '@':      begin
                      MGO^.Center.X := gx;
                      MGO^.Center.Y := gy;
                      MGO^.grid[gx, gy] := mgcCenter;
                    end;
          '$':      MGO^.grid[gx, gy] := mgcBigFort;
          '%':      MGO^.grid[gx, gy] := mgcSmallFort;
        end;
      end;
    end;

    MGO^.MakeGeoDiffs;
    MGO^.MakeGeos(NumCrossroads > 0, MGO^.Center.X <> 0);
    MG^ := MGO^.MG;
    Dispose(MGO, Done);
  end;

{ unit initialization }

end.
