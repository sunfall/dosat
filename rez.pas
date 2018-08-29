unit rez;

{ resources for hommx }

interface

uses LowGr;

type
  TResource = (rGold, rRocks, rApples, rEmeralds, rQuartz, rBeakers, rClay);

  PResourceSet = ^TResourceSet;
  TResourceSet = array [TResource] of longint;

const
  crGold = chr(ord(rGold) + 16);

  ResourceColors: array [TResource] of byte =
  (
    colYellow, colGrays + 2{colLightGray}, colRed, colDarkGreen,
    colBlue, colBlue, colLightRed
  );

  ResourceBacks: array [TResource] of byte =
  (
    colOrange, colDarkGray, colDarkRed, colLightGreen,
    colLightBlue, colLightGray, colBrown
  );

  ResourceNames: array [TResource] of string[8] =
  (
    'Gold', 'Rock', 'Apple', 'Emerald', 'Quartz', 'Beaker', 'Clay'
  );

  PResourceNames: array [TResource] of string[8] =
  (
    'Gold', 'Rocks', 'Apples', 'Emeralds', 'Quartz', 'Beakers', 'Clay'
  );

  MineNames: array [TResource] of string[14] =
  (
    'Gold Mine', 'Rock Quarry', 'Apple Orchard', 'Emerald Mine',
    'Quartz Mine', 'Beaker Factory', 'Clay Pit'
  );

  ResourceInc: array [TResource] of integer =
  (
    1000, 1, 1, 1, 1, 1, 1
  );

  ResourceGraphics: array [TResource] of TGraphic =
  (
    ('.....*....', { gold }
     '.*...*...*',
     '..*.....*.',
     '..........',
     '..********',
     '.*      **',
     '******** *',
     '*      * *',
     '*      **.',
     '********..'),
    ('..........', { rocks }
     '....****..',
     '..***   *.',
     '.* * *  *.',
     '.**** *  *',
     '**** * * *',
     '****** * *',
     '.****** *.',
     '..******..',
     '..........'),
    ('..........', { apples }
     '..... ....',
     '.... .....',
     '..** **...',
     '.*******..',
     '.*******..',
     '.*******..',
     '..*****...',
     '...***....',
     '..........'),
    ('..........', { emeralds }
     '..........',
     '..*****...',
     '.*  *  *..',
     '*********.',
     '.*  *  *..',
     '..* * *...',
     '...***....',
     '....*.....',
     '..........'),
    ('..........', { quartz }
     '....*.....',
     '...***....',
     '...** *...',
     '..*  * *..',
     '.*   *  *.',
     '.*    *  *',
     '*      **.',
     '********..',
     '..........'),
    ('..**..**..', { beakers }
     '...*..*...',
     '...*..*...',
     '...*  *...',
     '...*  *...',
     '..*    *..',
     '.*      *.',
     '*        *',
     '*        *',
     '.********.'),
    ('..........', { clay }
     '..........',
     '.********.',
     '**      **',
     '* ****** *',
     '*        *',
     '.*      *.',
     '..*    *..',
     '...****...',
     '..........')
  );

var
  RezProd, ExcessRez: TResourceSet;

procedure FindExchangeRate(r1, r2: TResource; var left, right: integer);
function CanPay(RS, cost: TResourceSet): boolean;
function Pay(var RS: TResourceSet; cost: TResourceSet): boolean;
function CanPayWithTrading(RS, cost, excess: TResourceSet): boolean;
function PayWithTrading(var RS: TResourceSet;
                        cost, excess: TResourceSet): boolean;
function CanPayEither(RS, cost, excess: TResourceSet;
                      trading: boolean): boolean;
function PayEither(var RS: TResourceSet; cost, excess: TResourceSet;
                   trading: boolean): boolean;
procedure DrawResourceGraphic(i, j: integer; r: TResource);
procedure DrawResource(i, j, bc: integer; r: TResource; amt: longint);
function RezAmt(r: TResource; rand: integer): integer;
function RezChr(r: TResource): char;
function GoldStr(gp: longint): string;

implementation

uses XStrings;

procedure FindExchangeRate(r1, r2: TResource; var left, right: integer);

  function ResourceCat(r: TResource): integer;
    begin
      case r of
        rGold:              ResourceCat := 1;
        rRocks:             ResourceCat := 2;
        rEmeralds, rQuartz,
        rBeakers, rClay,
        rApples:            ResourceCat := 3;
      end;
    end;

  const
    XchgTable: array [1..3, 1..3, 1..2] of integer =
    (
      ((1, 1),
       (1000, 1),
       (2500, 1)),
      ((1, 50),
       (6, 1),
       (12, 1)),
      ((1, 100),
       (3, 1),
       (6, 1))
    );
  var
    cl, cr: integer;
  begin
    if r1 = r2 then begin
      left := 1;
      right := 1;
    end else begin
      cl := ResourceCat(r1);
      cr := ResourceCat(r2);
      left := XchgTable[cl, cr, 1];
      right := XchgTable[cl, cr, 2];
    end;
  end;

function CanPay(RS, cost: TResourceSet): boolean;
  begin
    CanPay := Pay(RS, cost);
  end;

function Pay(var RS: TResourceSet; cost: TResourceSet): boolean;
  var
    r: TResource;
    can: boolean;
  begin
    can := true;

    for r := low(TResourceSet) to high(TResourceSet) do
      if RS[r] >= cost[r] then
        dec(RS[r], cost[r])
      else
        can := false;

    Pay := can;
  end;

function CanPayWithTrading(RS, cost, excess: TResourceSet): boolean;
  begin
    CanPayWithTrading := PayWithTrading(RS, cost, excess);
  end;

function PayWithTrading(var RS: TResourceSet;
                        cost, excess: TResourceSet): boolean;
  var
    PRS: TResourceSet;
    r, er: TResource;
    can: boolean;
    left, right: integer;
  begin
    can := true;
    PRS := RS;

    for r := low(TResource) to high(TResource) do
      if excess[r] > PRS[r] - cost[r] then
        excess[r] := PRS[r] - cost[r];

    for r := low(TResource) to high(TResource) do begin
      if can and (PRS[r] < cost[r]) then begin
        for er := high(TResource) downto low(TResource) do
          if excess[er] > 0 then begin
            FindExchangeRate(er, r, left, right);
            while (excess[er] >= left) and (PRS[r] < cost[r]) do begin
              dec(excess[er], left);
              dec(PRS[er], left);
              inc(PRS[r], right);
            end;
          end;
        if PRS[r] < cost[r] then can := false;
      end;
    end;

    if can then begin
      for r := low(TResource) to high(TResource) do
        dec(PRS[r], cost[r]);
      RS := PRS;
    end;

    PayWithTrading := can;
  end;

function CanPayEither(RS, cost, excess: TResourceSet;
                      trading: boolean): boolean;
  begin
    if trading then
      CanPayEither := CanPayWithTrading(RS, cost, excess)
    else
      CanPayEither := CanPay(RS, cost);
  end;

function PayEither(var RS: TResourceSet; cost, excess: TResourceSet;
                   trading: boolean): boolean;
  begin
    if trading then
      PayEither := PayWithTrading(RS, cost, excess)
    else
      PayEither := Pay(RS, cost);
  end;

procedure DrawResourceGraphic(i, j: integer; r: TResource);
  var x, y: integer;
  begin
    DrawSmallGraphic2c(i, j, ResourceColors[r], ResourceBacks[r],
                       ResourceGraphics[r]);
  end;

procedure DrawResource(i, j, bc: integer; r: TResource; amt: longint);
  var
    x2: integer;
    s: string;
  begin
    x2 := i + 8 * 9 - 1;
    if x2 > 639 then x2 := 639;
    XRectangle(i - 1, j - 1, x2, j + 10, bc);
    if bc = colRed then bc := colDarkGray;
    XFillArea(i, j, x2 - 1, j + 10 - 1, bc);
    if amt < 1000000 then
      s := LStr(amt, 0)
    else
      s := LStr(amt div 1000, 0) + 'k';
    DrawText(i + 22, j + 2, bc, ResourceColors[r], LSet(s, 6));
    DrawResourceGraphic(i, j, r);
  end;

function RezAmt(r: TResource; rand: integer): integer;
  var n: integer;
  begin
    case r of
      rRocks: n := (rand mod 2) + 2;
      rGold:  n := ((rand mod 4) + 5) * 100;
      else    n := (rand mod 4) + 3;
    end;

    RezAmt := n;
  end;

function RezChr(r: TResource): char;
  begin
    RezChr := chr(ord(r) + 16);
  end;

function GoldStr(gp: longint): string;
  begin
    GoldStr := LStr(gp, 0) + '_' + crGold;
  end;

{ unit initialization }

end.
