unit hexes;

{ utility routines for dealing with hex grids }

interface

const
  BitTable: array [1..16] of word =
  (
    $0001, $0002, $0004, $0008, $0010, $0020, $0040, $0080,
    $0100, $0200, $0400, $0800, $1000, $2000, $4000, $8000
  );

  CombatXMax = 12;
  CombatYMax = 12;

var
  XYInDir: array [1..(CombatXMax * CombatYMax), 1..6] of byte;

procedure UpLeft(var x, y: integer);
procedure DownLeft(var x, y: integer);
function HexIsAdjacent(x1, y1, x2, y2: integer): boolean;
function HexIsInLine(x1, y1, x2, y2: integer): boolean;
function HexWithinDist(x1, y1, x2, y2, dist: integer): boolean;
procedure HexAwayFrom(fromx, fromy, isx, isy: integer; var tox, toy: integer);

function OnGrid(x, y: integer): boolean;
function FindAdjHex(n, x, y: integer; var i, j: integer): boolean;
function FindCenterAdjHex(n, x, y: integer; var i, j: integer): boolean;
function FindWideAdjHex(n, x, y: integer; var i, j: integer): boolean;
procedure PointToGrid(var x, y: integer);
procedure PointToGridOfs(var x, y: integer);
procedure GetCombatHexXY(x, y: integer; var nx, ny: integer);

implementation

procedure UpLeft(var x, y: integer);
  begin
    if y mod 2 = 0 then dec(x);
    dec(y);
  end;

procedure DownLeft(var x, y: integer);
  begin
    if y mod 2 = 0 then dec(x);
    inc(y);
  end;

function HexIsAdjacent(x1, y1, x2, y2: integer): boolean;
  var hia: boolean;
  begin
    hia := false;
    if y1 = y2 then begin
      hia := abs(x1 - x2) = 1;
    end else if abs(y1 - y2) = 1 then begin
      if y1 mod 2 = 1 then
        hia := (x2 >= x1) and (x2 <= x1 + 1)
      else
        hia := (x2 >= x1 - 1) and (x2 <= x1);
    end;
    HexIsAdjacent := hia;
  end;

function HexIsInLine(x1, y1, x2, y2: integer): boolean;
  var
    hiil: boolean;
    xd, yd: integer;
  begin
    hiil := false;
    xd := abs(x1 - x2);
    yd := abs(y1 - y2);
    if y1 = y2 then
      hiil := true
    else if yd mod 2 = 0 then
      hiil := xd = yd div 2
    else begin
      if xd = 0 then
        hiil := yd = 1
      else if y1 mod 2 = 1 then begin
        if x1 < x2 then
          hiil := (yd = 2 * xd) or (yd = 2 * xd - 1)
        else
          hiil := (yd = 2 * xd) or (yd = 2 * xd + 1);
      end else begin
        if x1 < x2 then
          hiil := (yd = 2 * xd) or (yd = 2 * xd + 1)
        else
          hiil := (yd = 2 * xd) or (yd = 2 * xd - 1);
      end;
    end;
    HexIsInLine := hiil;
  end;

function HexWithinDist(x1, y1, x2, y2, dist: integer): boolean;
  var
    hisr: boolean;
    d: integer;
  begin
    if (x2 < (x1 - dist)) or (x2 > (x1 + dist))
       or (y2 < (y1 - dist)) or (y2 > (y1 + dist)) then
      hisr := false
    else begin
      d := 0;
      while y2 > y1 do begin
        UpLeft(x2, y2);
        if x2 < x1 then inc(x2);
        inc(d);
      end;
      while y2 < y1 do begin
        DownLeft(x2, y2);
        if x2 < x1 then inc(x2);
        inc(d);
      end;
      inc(d, abs(x2 - x1));
      hisr := d <= dist;
    end;

    HexWithinDist := hisr;
  end;

procedure HexAwayFrom(fromx, fromy, isx, isy: integer; var tox, toy: integer);
  var m, n: integer;
  begin
    tox := isx;
    toy := isy;
    m := fromx;
    n := fromy;

    if isy = fromy then begin
      if isx < fromx then
        dec(tox)
      else
        inc(tox);
    end else if isy < fromy then begin
      UpLeft(m, n);
      if m <> tox then inc(tox);
      UpLeft(tox, toy);
    end else begin
      DownLeft(m, n);
      if m <> tox then inc(tox);
      DownLeft(tox, toy);
    end;
  end;

function OnGrid(x, y: integer): boolean;
  begin
    OnGrid := (x >= 1) and (x <= CombatXMax)
              and (y >= 1) and (y <= CombatYMax);
  end;

function FindAdjHex(n, x, y: integer; var i, j: integer): boolean;
  begin
    i := x;
    j := y;

    case n of
      1: dec(i);
      2: UpLeft(i, j);
      3: begin
           UpLeft(i, j);
           inc(i);
         end;
      4: inc(i);
      5: begin
           DownLeft(i, j);
           inc(i);
         end;
      6: DownLeft(i, j);
    end;

    FindAdjHex := OnGrid(i, j);
  end;

function FindCenterAdjHex(n, x, y: integer; var i, j: integer): boolean;
  const
    ConvTbl: array [1..4, 1..6] of byte =
    (
      (4, 5, 3, 6, 2, 1),
      (1, 6, 2, 5, 3, 4),
      (4, 3, 5, 2, 6, 1),
      (1, 2, 6, 3, 5, 4)
    );
  var
    idx: integer;
  begin
    if x <= CombatXMax div 2 then idx := 1 else idx := 2;
    if y > CombatYMax div 2 then inc(idx, 2);
    FindCenterAdjHex := FindAdjHex(ConvTbl[idx, n], x, y, i, j);
  end;

function FindWideAdjHex(n, x, y: integer; var i, j: integer): boolean;
  var
    fah: boolean;
    n1: integer;
  begin
    n1 := ((n - 1) mod 6) + 1;
    fah := FindAdjHex(n1, x, y, i, j);

    if n > 6 then
      fah := FindAdjHex(n1, i, j, i, j);

    FindWideAdjHex := fah;
  end;

procedure PointToGrid(var x, y: integer);
  begin
    y := (y div 40) + 1;
    if y mod 2 = 1 then dec(x, 18);
    if x < 0 then
      x := 0
    else
      x := (x div 36) + 1;
  end;

procedure PointToGridOfs(var x, y: integer);
  begin
    if (((y div 40) + 1) mod 2) = 1 then dec(x, 18);
    x := x mod 36;
    y := y mod 40;
  end;

procedure GetCombatHexXY(x, y: integer; var nx, ny: integer);
  begin
    nx := (x - 1) * 36;
    if (y mod 2) = 1 then inc(nx, 18);
    ny := (y - 1) * 40;
  end;

procedure InitHexTables;
  var idx, x, y, tx, ty, h: integer;
  begin
    for x := 1 to CombatXMax do
      for y := 1 to CombatYMax do begin
        idx := (x - 1) * CombatYMax + y;
        for h := 1 to 6 do begin
          if FindAdjHex(h, x, y, tx, ty) then
            XYInDir[idx, h] := (ty - 1) + (tx - 1) * CombatXMax
          else
            XYInDir[idx, h] := 255;
        end;
      end;
  end;

{ unit initialization }

begin
  InitHexTables;
end.
