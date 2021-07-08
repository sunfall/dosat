unit Combat;

{ combat routines for hommx }

interface

uses Objects, Hexes, Spells, Monsters, CombSub;

const
  StackMax = 40;

  MaxSFX = 6;

  hptAny = 0;
  hptEmpty = 1;
  hptFriend = 2;
  hptEnemy = 3;
  hptStack = 4;

  MonsterSpell: array [1..6] of byte =
  (
    spFury, spGrow, spWeakness, spAgility, spFatigue, spShrink
  );

  cdBase = 1;
  cdCastle = 21;
  cdDwelling = 23;
  cdCache = 29;
  cdBase2 = 41;

  avgLevel1MonsterCost = 57;

type
  TStack = record
    side: byte;           { must be first field for AddShadowLayers! }
    monster: byte;
    realmonster: byte;
    qty: integer;
    x, y: integer;
    speed: integer;
    moved, done: boolean;
    hp: integer;
    tophp: integer;
    dmg: integer;
    flags: array [1..NumFlagWords] of word;
    illusion: byte;
    morale: byte;
    whirly: byte;
    NumAttacks: byte;
    stunned: byte;
    hexed, diseased: boolean;
    canshoot: boolean;
    armyslot: integer;
    spin, wolfct: integer;
    renew: byte;
    maxqty: integer;
    sfx: array [1..MaxSFX] of TSFX;
    numsfx: integer;
    cast: integer;
    poison: integer;
    marked: boolean;
  end;

  TShadow = array [1..CombatXMax, 1..CombatYMax] of byte;

const
  sizTStack = sizeof(TStack);
  sizTShadow = sizeof(TShadow);

type
  TStatLines = array [0..4] of string;

  PCombat = ^TCombat;
  TCombat = object(TObject)
    Stacks: array [1..StackMax] of TStack;
    Shadow: TShadow;
    MShadow: TShadow;
    HoverShadow: TShadow;
    StacksGrid: array [1..CombatXMax, 1..CombatYMax] of byte;
    CombatMap: TCombatMap;
    actual: boolean;
    over: boolean;
    TrackedStack: integer;
    TrackedShadow: TShadow;
    edge, turnedge, roundnum: integer;
    LastStack: integer;
    AttackMoves, Targets: TShadow;
    MoveStackTargetX, MoveStackTargetY: integer;
    SV: array [1..2] of TSideVars;
    SpellList: TSpellList;
    SpellTargets: array [1..StackMax] of record
      x, y: integer;
    end;
    CDef: integer;
    backcol: integer;
    AttMoveChoiceX, AttMoveChoiceY: integer;

    constructor Init(iactual: boolean; ih1, ih2, iCDef, ibackcol: integer);
    destructor Done; virtual;
    function Spawn: PCombat;

    function HexEmpty(x, y: integer): boolean;
    function FindAdjEmpty(x, y: integer; var fx, fy: integer): boolean;
    function FindEmptyOrAdjEmpty(x, y: integer; var fx, fy: integer): boolean;
    function StacksOfMonster(side, monster: integer): integer;
    function TroopsWithFlag(side, fbyte, fbit: word): longint;

    function EffSpeed(st: integer; future, movement: boolean): integer;
    function EffAvgDmg(st: integer): integer;
    procedure EffDmg(st: integer; var min, max: integer);
    function EffHp(st: integer): integer;
    function EffFlagWord(st, fb: integer): word;
    function EffFlag(st, fb: integer; f: word): boolean;

    procedure ClearStacks;
    function FindFreeStack: integer;
    procedure SetMonster(st, mons: integer);
    function AddStack(ix, iy, iside, imonster, iqty, islot,
                      iillusion: integer): integer;
    procedure AddIllusions;

    procedure MakeShadow(st: integer; forchoice, rep: boolean);
    function AddShadowLayers(sst, fspeed: integer; newnum: byte;
                             fly, steamroll, gatemap: boolean): boolean;
    procedure EraseShadow;
    procedure ShowShadow;
    procedure BacktrackShadow(var x, y: integer; sh: integer);
    procedure BacktrackFutureShadow(var x, y: integer; sh: integer);
    procedure MakeTrackedShadow;

    function HexHasTarget(st, x, y: integer): boolean;
    function CanReach(st, x, y: integer): boolean;
    function CanAttack(st, x, y: integer): boolean;
    function AttackPossible(st: integer): boolean;
    procedure KillIllusions(st: integer);
    procedure KillStack(st: integer);
    function SplitStack(st, side, amt: integer): byte;
    procedure AdjHp(st: integer; amt: longint);
    function DamageStack(st: integer; dmg: longint; melee: boolean;
                         var numkilled: integer): boolean;
    function LoggedDamageStack(st: integer; dmg: longint; melee: boolean;
                               cl: integer): boolean;
    procedure StackDone(st: integer);
    procedure MarkStacksOnSide(side: integer);
    procedure AttackHex(st, x, y: integer; melee: boolean; divide: integer);
    procedure Attack(st, x, y: integer);

    procedure DrawMovementGhost(st, x, y: integer);
    procedure MakeStacksGrid;
    procedure MoveStack(st, x, y: integer; teleport: boolean);
    procedure ExchangeStacks(st, st2: integer);
    procedure RemoveObstacle(x, y: integer);
    procedure MakeObstacle(x, y, ob: integer);
    procedure GetRandomEmptyHex(var m, n: integer);
    procedure ClearTrackedStack;
    procedure UpdateTrackedStack;
    procedure UpdateTrackedStackIf(st: integer);
    procedure AddLogLine(s: string);
    function MonsterChr(st: integer): char;
    procedure UpdateStack(st: integer);
    procedure PushBackFrom(st, x, y: integer);
    procedure HideIllusionist(st: integer);
    function HealStack(st, hdmg: integer): boolean;
    procedure VolveStack(st, n: integer);

    procedure SideHasFlier(var side1, side2: boolean);
    procedure GoldPieceAdvantage(gside: integer; var gpa, rgpa, sgpa: longint;
                                 madsci: boolean);
    procedure FastGPA(gside: integer; var gpa: longint);
    procedure CalcAttackMoves(st: integer);
    function DistanceToClosestEnemy(st: integer;
                                    range, conjuredok: boolean): integer;
    function FindBestAttackGold(st: integer): longint;
    function FindBestFutureAttackGold(st: integer): longint;
    function BoardValue(sid: integer): longint;
    procedure StackPassTurn(st: integer);
    procedure GetGoodAIMove(st: integer;
                            var bestmx, bestmy, bestax, bestay: integer);
    procedure GetAIBestShot(side, dmg: integer; var bestax, bestay: integer);

    procedure GetClick(hx, hy: integer; var cx, cy: integer;
                       side, attingst: integer);
    procedure StartRound;
    function FastestStack: integer;
    procedure ShowAttMoveChoice;
    procedure PlayerTurn(st: integer);
    procedure AITurn(st: integer);
    procedure TakeTurn(st: integer);
    procedure BarbicanTurn(x, y: integer);

    procedure HeroAttackHex(side, x, y, dmg, cl: integer);
    function TargetOK(side, kind, x, y: integer): boolean;
    procedure HeroPickTarget(side, kind: integer; var tx, ty: integer);
    procedure AIPickTarget(side, kind, sp, value, dur, maxt: integer;
                           var tx, ty: integer);
    procedure AIPickDest(side, sp, value: integer; var tx, ty: integer);
    function EstimatedCombatLength: integer;
    function AIPickSpell(side: integer): integer;
    function PickSpell(side: integer): integer;
    procedure AddSFX(st, sp, v, dur, iside: integer);
    procedure RemoveSFX(st, sp: integer);
    procedure Remove1SFX(st, fx: integer);
    procedure SpellWasCast(side, sp, cl: integer);
    procedure RemoveAllStatSpells(st: integer);
    procedure CastNoTarget(side, sp, value, dur: integer);
    procedure BlowStack(st, dir, num: integer);
    procedure Traitors(st, side, qty: integer);
    procedure HealSpell(st: integer);
    procedure CastSpellOn(side, sp, x, y, value, dur: integer);
    procedure CastSpell(side, sp: integer);
    procedure TakeHeroTurn(side: integer);

    procedure WandSpell(side, st: integer; sl: TSlant; cl: integer;
                        strong: boolean);
    procedure ScrollSpell(side, sp, value, dur: integer);
    procedure CastEquipSpells(side: integer);
    procedure StartCombat;
    procedure CheckIfOver;
    procedure HandleNextPlay;
    procedure HandleCombat;

    procedure DrawMonster(st, i, j, hs: integer);
    procedure DrawCombatHex(x, y: integer);
    procedure DrawCombatScreen;
    function GetStatLines(st, sltop: integer;
                          var stl, sth: TStatLines): integer;
    procedure ShowStackStats(st, slot, top: integer);
    procedure ShowHeroStats(side, splev: integer);
    procedure DrawFX(x, y, fx: integer; wait: boolean);
    procedure DrawCombatGridHex(i, j: integer);
    procedure DrawCombatGrid;
    procedure Unhighlight(x, y: integer);
    procedure Refresh;

    procedure QuickCombat;
  end;

var
  ACombat: PCombat;

implementation

uses CRT, Drivers, XSVGA, XStrings, XMouse, LowGr,
     Heroes, Artifact, Players, Rez, Map, XFace, Options;

{ TCombat methods }

function TCombat.HexEmpty(x, y: integer): boolean;
  begin
    HexEmpty := (StacksGrid[x, y] = 0)
                and (CombatMap[x, y] <= cmEmptyMax);
  end;

function TCombat.FindAdjEmpty(x, y: integer; var fx, fy: integer): boolean;
  var h, tx, ty: integer;
  begin
    fx := 0;

    for h := 1 to 6 do
      if (fx = 0) and FindCenterAdjHex(h, x, y, tx, ty) then
        if HexEmpty(tx, ty) and not ((MoveStackTargetX = tx)
                                     and (MoveStackTargetY = ty)) then begin
          fx := tx;
          fy := ty;
        end;

    FindAdjEmpty := fx <> 0;
  end;

function TCombat.FindEmptyOrAdjEmpty(x, y: integer; var fx, fy: integer): boolean;
  var feoae: boolean;
  begin
    if HexEmpty(x, y) and not ((MoveStackTargetX = x)
                               and (MoveStackTargetY = y)) then begin
      fx := x;
      fy := y;
      feoae := true;
    end else
      feoae := FindAdjEmpty(x, y, fx, fy);

    FindEmptyOrAdjEmpty := feoae;
  end;

function TCombat.StacksOfMonster(side, monster: integer): integer;
  var i, som: integer;
  begin
    som := 0;

    for i := 1 to LastStack do
      if (Stacks[i].qty > 0) and (Stacks[i].side = side)
         and (Stacks[i].monster = monster) then
        inc(som);

    StacksOfMonster := som;
  end;

function TCombat.TroopsWithFlag(side, fbyte, fbit: word): longint;
  var
    i: integer;
    twf: longint;
  begin
    twf := 0;

    for i := 1 to LastStack do
      if (Stacks[i].qty > 0) and (Stacks[i].side = side)
         and EffFlag(i, fbyte, fbit) then
        inc(twf, Stacks[i].qty);

    TroopsWithFlag := twf;
  end;

function TCombat.EffSpeed(st: integer; future, movement: boolean): integer;
  var n, fx: integer;
  begin
    with Stacks[st] do begin
      if speed <= 0 then
        n := 0
      else begin
        n := speed + spin * 10;
        if hexed then dec(n, 10);
        if diseased then dec(n, 10);

        if (SV[side].HeartsHelm > 0)
           and not EffFlag(st, 1, f1Fly or f1AnyRange) then
          inc(n, 15);

        if Twists[twTerrainsAffectCombat] and (backcol = colDesolate)
           and not EffFlag(st, 1, f1Fly) then
          dec(n, 10);

        if numsfx > 0 then
          for fx := 1 to MaxSFX do
            with SFX[fx] do
              if sp <> 0 then begin
                if (sp = spAgility) or (sp = spJoy) then
                  n := n + (speed * v + 99) div 100
                else if (sp = spFatigue) or (sp = spWoe) then
                  n := n - (speed * v + 99) div 100
                else if sp = spIceBolt then
                  n := n - 20;
              end;

        if (CombatMap[x, y] = cmWater) and not future
           and not EffFlag(st, 1, f1Fly)
           and not EffFlag(st, 4, f4WaterImmune) then
          n := n div 2;

        if n < 10 then n := 10;
      end;

      if movement and EffFlag(st, 5, f5MoveFar) then inc(n, 40);
    end;

    EffSpeed := n;
  end;

function TCombat.EffAvgDmg(st: integer): integer;
  var fx, dv, avg: integer;
  begin
    with Stacks[st] do begin
      avg := dmg + spin * 2;
      if hexed then dec(avg, 2);
      if diseased then dec(avg, 2);

      if SV[side].Courage > 0 then
        inc(avg, (StacksOfMonster(side, monster) - 1) * SV[side].Courage);

      if (SV[side].HeartsHelm > 0)
         and EffFlag(st, 1, f1AnyRange) then
        inc(avg, (MonsterData[monster].dmg * SV[side].HeartsHelm * 3 + 9)
                 div 10);

      if numsfx > 0 then begin
        for fx := 1 to MaxSFX do
          with SFX[fx] do
            if sp <> 0 then begin
              if (sp = spFury) or (sp = spJoy) then
                avg := avg + (dmg * v + 99) div 100
              else if (sp = spWeakness) or (sp = spWoe) then
                avg := avg - (dmg * v + 99) div 100;
            end;
      end;

      if avg < 1 then avg := 1;
    end;

    EffAvgDmg := avg;
  end;

procedure TCombat.EffDmg(st: integer; var min, max: integer);
  var
    fx, dv, avg: integer;
    goodluck, badluck: boolean;
  begin
    with Stacks[st] do begin
      avg := EffAvgDmg(st);

      goodluck := false;
      badluck := false;
      if numsfx > 0 then begin
        for fx := 1 to MaxSFX do
          with SFX[fx] do
            if sp <> 0 then begin
              if (sp = spGoodLuck) then
                goodluck := true
              else if (sp = spBadLuck) then
                badluck := true;
            end;
      end;

      DamageMinMax(monster, avg, min, max, goodluck, badluck);
    end;
  end;

function TCombat.EffHp(st: integer): integer;
  var n, fx: integer;
  begin
    with Stacks[st] do begin
      n := hp + spin * 2;
      if hexed then dec(n, 2);
      if diseased then dec(n, 2);

      if ((SV[side].HeartsHelm > 0) or (SV[side].FlyersHelm > 0))
         and EffFlag(st, 1, f1Fly) then
        inc(n, (MonsterData[monster].hp
               * (SV[side].HeartsHelm * 3 + SV[side].FlyersHelm) + 9)
               div 10);

      if (SV[side].ArchersHelm > 0)
         and EffFlag(st, 1, f1AnyRange) then
        inc(n, (MonsterData[monster].hp * SV[side].ArchersHelm + 9) div 10);

      if (SV[side].WalkersHelm > 0)
         and not EffFlag(st, 1, f1Fly or f1AnyRange) then
        inc(n, (MonsterData[monster].hp * SV[side].WalkersHelm * 2 + 9)
               div 10);

      if numsfx > 0 then
        for fx := 1 to MaxSFX do
          with SFX[fx] do
            if sp <> 0 then begin
              if (sp = spGrow) or (sp = spJoy) then
                n := n + (hp * v + 99) div 100
              else if (sp = spShrink) or (sp = spWoe) then
                n := n - (hp * v + 99) div 100;
            end;

      if n < 1 then n := 1;
    end;

    EffHp := n;
  end;

function TCombat.EffFlagWord(st, fb: integer): word;
  var n, fx, h: word;
  begin
    with Stacks[st] do begin
      n := Flags[fb];

      if (fb = 1) and ((n and f1Transform) <> 0) then
        case roundnum mod 2 of
          1: n := n or f1Fly;
          0: n := n or f1Range;
        end;

      if numsfx > 0 then
        for fx := 1 to MaxSFX do
          with SFX[fx] do
            if sp <> 0 then begin
              if (sp = spFly) and (fb = 1) then
                n := n or f1Fly
              else if (sp = spMindBlank) then
                n := 0
              else if (sp = spMagicBow) and (fb = 1) then
                n := n or f1Range
              else if (sp = spVengeance) and (fb = 1) then
                n := n or f1Retaliate
              else if (sp = spVampire) and (fb = 3) then
                n := n or f3Vampire;
            end;

      if Twists[twTerrainsAffectCombat] and (fb = 1) then begin
        if backcol = colJungle then
          n := n and not f1AnyRange
        else if backcol = colCombatSnow then
          n := n and not f1Fly;
      end;

      if (fb = 1) and (SV[side].ArchersHelm > 0)
         and ((n and f1AnyRange) <> 0) then
        n := n or f1Hiding;
    end;

    EffFlagWord := n;
  end;

function TCombat.EffFlag(st, fb: integer; f: word): boolean;
  begin
    EffFlag := (EffFlagWord(st, fb) and f) <> 0;
  end;

procedure TCombat.PushBackFrom(st, x, y: integer);
  var i, j, w: integer;
  begin
    if HexAwayFrom(x, y, Stacks[st].x, Stacks[st].y, i, j)
       and HexEmpty(i, j)
       and not ((MoveStackTargetX = i) and (MoveStackTargetY = j)) then begin
      MoveStack(st, i, j, true);
      if actual then begin
        DrawCombatHex(Stacks[st].x, Stacks[st].y);
        for w := 1 to BlowDelay do Refresh;
      end;
    end;
  end;

procedure TCombat.ClearStacks;
  begin
    FillChar(Stacks, sizeof(Stacks), #0);
    FillChar(StacksGrid, sizeof(StacksGrid), #0);
  end;

function TCombat.FindFreeStack: integer;
  var i, st: integer;
  begin
    st := 0;
    i := 1;
    repeat
      if Stacks[i].qty = 0 then st := i;
      inc(i);
    until (st <> 0) or (i > StackMax);
    FindFreeStack := st;
  end;

procedure TCombat.SetMonster(st, mons: integer);
  var
    i: integer;
    ms: TMonster;
  begin
    with Stacks[st] do begin
      monster := mons;

      GetHeroMonsterStats(SV[side].Dude, mons, ms, true);

      speed := ms.speed;
      hp := ms.hp;
      dmg := ms.dmg;
      for i := 1 to NumFlagWords do
        flags[i] := ms.flags[i];
    end;
  end;

function TCombat.AddStack(ix, iy, iside, imonster, iqty, islot,
                          iillusion: integer): integer;
  var st: integer;
  begin
    st := FindFreeStack;
    if st <> 0 then
      with Stacks[st] do begin
        FillChar(sfx, sizeof(sfx), #0);
        numsfx := 0;
        x := ix;
        y := iy;
        side := iside;
        realmonster := imonster;
        qty := iqty;
        maxqty := iqty;
        SetMonster(st, imonster);
        moved := false;
        done := false;
        stunned := 0;
        morale := 0;
        whirly := 0;
        spin := 0;
        wolfct := 0;
        hexed := false;
        diseased := false;
        canshoot := true;
        illusion := iillusion;
        armyslot := islot;
        cast := 0;
        poison := 0;
        NumAttacks := 0;
        tophp := EffHp(st);
        StacksGrid[ix, iy] := st;
        if st > LastStack then LastStack := st;
      end;
    AddStack := st;
  end;

procedure TCombat.AddIllusions;
  var st, i, fx, fy: integer;
  begin
    for st := 1 to LastStack do
      if ((Stacks[st].flags[3] and f3Illusionist) <> 0)
         and (Stacks[st].illusion = 0) then begin
        for i := 1 to 2 do
          if FindAdjEmpty(Stacks[st].x, Stacks[st].y, fx, fy) then
            AddStack(fx, fy, Stacks[st].side, Stacks[st].monster,
                     Stacks[st].qty, 0, st);
      end;
  end;

(*
function TCombat.AddShadowLayers(st, fspeed, newnum: integer;
                                 fly, steamroll, gatemap: boolean): boolean;
  var
    idx, h, tx, ty, i: integer;
    Change, LoopChange: boolean;
    p, ptx, pty: PChar;
    pShadow: PByte;
  begin
    Change := false;
    i := fspeed;

    repeat
      LoopChange := false;
      inc(newnum);
      p := @Shadow;
      ptx := @XInDir;
      pty := @YInDir;
      for idx := 1 to (CombatXMax * CombatYMax) do begin
        if byte(p^) = newnum - 1 then begin  { fast way to check Shadow[i, j] }
          for h := 1 to 6 do begin
            tx := byte(ptx^);                { these replace FindAdjHex }
            if tx <> 0 then begin
              ty := byte(pty^);              { " }
              pShadow := @Shadow[tx, ty];
              if pShadow^ = 0 then begin
                if fly
{                  or HexEmpty(tx, ty) --- below is mildly faster equivalent }
                   or ((CombatMap[tx, ty] <= cmEmptyMax)
                       and (StacksGrid[tx, ty] = 0))
                   or (gatemap and (CombatMap[tx, ty] >= cmGate1)
                       and (CombatMap[tx, ty] <= cmGate8))
                   or (steamroll
                       and (CombatMap[tx, ty] <= cmEmptyMax)
                       and ((StacksGrid[tx, ty] = 0)
                            or ((StacksGrid[tx, ty] <> 0)
                                and (Stacks[StacksGrid[tx, ty]].side
                                     <> Stacks[st].side)))) then begin
                  pShadow^ := newnum;
                  Change := true;
                  LoopChange := true;
                end;
              end;
            end;
            inc(ptx);
            inc(pty);
          end;
        end else begin
          inc(ptx, 6);
          inc(pty, 6);
        end;
        inc(p);
      end;
      dec(i);
    until (i = 0) or not LoopChange;

    AddShadowLayers := Change;
  end;
*)

function TCombat.AddShadowLayers(sst, fspeed: integer; newnum: byte;
                                 fly, steamroll, gatemap: boolean): boolean;
{
  in assembly because it's the time bottleneck for combat AI

  es:di is a pointer to the Shadow array
  ds:si is a pointer to XYInDir
  cx is [tx, ty] offset to add to array starts (in inner loop)
}
  var
    Change, LoopChange: boolean;
    ShadowSeg, ShadowOfs: word;
    XYInDirOfs, CombatMapOfs, StacksGridOfs, StacksOfs: word;
  begin
    ShadowSeg := seg(Shadow);
    ShadowOfs := ofs(Shadow);
    XYInDirOfs := ofs(XYInDir);
    CombatMapOfs := ofs(CombatMap);
    StacksGridOfs := ofs(StacksGrid);
    StacksOfs := ofs(Stacks);

    asm
      mov  Change, 0
      mov  ax, ShadowSeg
      mov  es, ax
      mov  cx, fspeed
@ASLSpeedLoop:
      push cx
      mov  LoopChange, 0
      inc  newnum
      mov  di, ShadowOfs
      mov  si, XYInDirOfs
      mov  cx, sizTShadow
@ASLHexLoop:
      push cx
      mov  al, es:[di]      { Shadow }
      inc  al
      cmp  al, newnum
      jnz  @ASLNotThisHex
      mov  cx, 6
@ASLAdjLoop:
      push cx
      mov  cl, ds:[si]      { (ty - 1) + 12 * (tx - 1) }
      cmp  cl, 255
      jz   @ASLNextAdj      { no hex there }
      mov  ch, 0            { cx is [tx, ty] offset }

      mov  bx, cx
      add  bx, ShadowOfs
      mov  al, es:[bx]      { shadow[tx, ty] }
      cmp  al, 0
      jnz  @ASLNextAdj

@ASLCheck1:
      mov  al, fly          { flying? }
      cmp  al, 1
      jz   @ASLMakeChange

      mov  bx, cx
      add  bx, CombatMapOfs
      mov  dl, es:[bx]      { dl = CombatMap[tx, ty] }
      mov  bx, cx
      add  bx, StacksGridOfs
      mov  dh, es:[bx]      { dh = StacksGrid[tx, ty] }

@ASLCheck2:
      cmp  dl, cmEmptyMax   { empty hex? }
      jg   @ASLCheck3
      cmp  dh, 0
      jz   @ASLMakeChange

@ASLCheck3:
      mov  al, gatemap      { gate hex? }
      cmp  al, 1
      jnz  @ASLCheck4
      cmp  dl, cmGate1
      jl   @ASLCheck4
      cmp  dl, cmGate8
      jle  @ASLMakeChange

@ASLCheck4:
      mov  al, steamroll    { steamrolling? }
      cmp  al, 1
      jnz  @ASLNextAdj
      cmp  dl, cmEmptyMax
      jg   @ASLNextAdj
      cmp  dh, 0
      jz   @ASLMakeChange

      mov  al, dh
      dec  al
      mov  ah, sizTStack
      mul  ah
      mov  bx, ax
      add  bx, StacksOfs
      mov  dl, es:[bx]      { dl = Stacks[dh].side }
      mov  ax, sst
      dec  al
      mov  ah, sizTStack
      mul  ah
      mov  bx, ax
      add  bx, StacksOfs    { es:[bx] = Stacks[st].side }
      cmp  dl, es:[bx]
      jz   @ASLNextAdj

@ASLMakeChange:
      mov  al, newnum
      mov  bx, cx
      add  bx, ShadowOfs
      mov  es:[bx], al      { shadow[tx, ty] := newnum }
      mov  Change, 1
      mov  LoopChange, 1

@ASLNextAdj:
      inc  si
      pop  cx
      loop @JASLAdjLoop

      jmp  @ASLNextHex

@ASLNotThisHex:
      add  si, 6
@ASLNextHex:
      inc  di
      pop  cx
      loop @JASLHexLoop

      pop  cx
      cmp  LoopChange, 0
      jz   @ASLExit
      loop @JASLSpeedLoop
      jmp  @ASLExit
@JASLAdjLoop:
      jmp  @ASLAdjLoop
@JASLHexLoop:
      jmp  @ASLHexLoop
@JASLSpeedLoop:
      jmp  @ASLSpeedLoop
@ASLExit:
    end;

    AddShadowLayers := Change;
  end;

procedure TCombat.MakeShadow(st: integer; forchoice, rep: boolean);
  var
    TeleportSh: integer;
    fly, steamroll, gatemap, NoChange: boolean;

  procedure SetShadow(x, y: integer);
    begin
      if (shadow[x, y] = 0) and HexEmpty(x, y) then begin
        shadow[x, y] := TeleportSh;
        NoChange := false;
      end;
    end;

  procedure CanGoBySide(side: integer);
    var i, h, tx, ty: integer;
    begin
      for i := 1 to LastStack do
        if (Stacks[i].qty > 0) and (Stacks[i].side = side) and (i <> st) then
          for h := 1 to 6 do
            if FindAdjHex(h, Stacks[i].x, Stacks[i].y, tx, ty) then
              SetShadow(tx, ty);
    end;

  procedure CanGoTo(cm: integer);
   var i, j: integer;
    begin
      for i := 1 to CombatXMax do
        for j := 1 to CombatYMax do
          if CombatMap[i, j] = cm then
            SetShadow(i, j);
    end;

  var
    i, j, BaseShadow, h, tx, ty, h2, tx2, ty2, fspeed: integer;
  begin
    FillChar(Shadow, sizeof(Shadow), #0);
    MShadow := Shadow;
    fspeed := EffSpeed(st, false, true) div 10;
    fly := EffFlag(st, 1, f1Fly);
    steamroll := EffFlag(st, 1, f1Steamroll);
    gatemap := (CDef >= 21) and (CDef <= 40) and (Stacks[st].side = 2);

    if Stacks[st].stunned = 0 then begin
      Shadow[Stacks[st].x, Stacks[st].y] := 1;
      TeleportSh := fspeed + 1;
      BaseShadow := 1;

      repeat
        if fspeed <> 0 then
          NoChange := not AddShadowLayers(st, fspeed, BaseShadow, fly,
                                          steamroll, gatemap)
        else
          NoChange := true;

        if EffFlag(st, 1, f1Jump) and (fspeed <> 0) then
          for i := 1 to CombatXMax do
            for j := 1 to CombatYMax do
              if Shadow[i, j] = BaseShadow then
                for h := 1 to 6 do
                  if FindAdjHex(h, i, j, tx, ty) then begin
                    if shadow[tx, ty] = 0 then begin
                      shadow[tx, ty] := TeleportSh - 1;
                      NoChange := false;
                    end;
                    for h2 := 1 to 6 do
                      if FindAdjHex(h2, tx, ty, tx2, ty2) then
                        SetShadow(tx2, ty2);
                  end;

        if EffFlag(st, 1, f1Plantport) then begin
          for i := 1 to LastStack do
            if (Stacks[i].qty > 0)
               and ((Stacks[i].monster = moFungus)
                    or (Stacks[i].monster = moCarnivorousPlant)) then
              for h := 1 to 6 do
                if FindAdjHex(h, Stacks[i].x, Stacks[i].y, tx, ty) then
                  SetShadow(tx, ty);
          for i := 1 to CombatXMax do
            for j := 1 to CombatYMax do
              if CombatMap[i, j] in cmTrees then
                for h := 1 to 6 do
                  if FindAdjHex(h, i, j, tx, ty) then
                    SetShadow(tx, ty);
        end;

        if EffFlag(st, 5, f5Friendport) then
          CanGoBySide(Stacks[st].side);

        if EffFlag(st, 3, f3Enemyport) then
          CanGoBySide(3 - Stacks[st].side);

        if EffFlag(st, 4, f4Waterwalking) then
          CanGoTo(cmWater);

        if EffFlag(st, 4, f4Firewalking) then
          CanGoTo(cmFire);

        inc(BaseShadow, fspeed);
        inc(TeleportSh, fspeed);
      until not rep or NoChange;

      MShadow := Shadow;

      if forchoice then begin
        for i := 1 to CombatXMax do
          for j := 1 to CombatYMax do
            if not HexEmpty(i, j) then
              Shadow[i, j] := 0;
      end;

      if EffFlag(st, 5, f5SwitchMove) then begin
        for i := 1 to LastStack do
          if (Stacks[i].qty > 0) and (i <> st) then
            shadow[Stacks[i].x, Stacks[i].y] := TeleportSh;
      end;
    end;
  end;

procedure TCombat.EraseShadow;
  var i, j: integer;
  begin
    if actual then begin
      for i := 1 to CombatXMax do
        for j := 1 to CombatYMax do
          if Shadow[i, j] <> 0 then begin
            Shadow[i, j] := 0;
            DrawCombatHex(i, j);
          end;
    end else
      FillChar(Shadow, sizeof(Shadow), #0);
  end;

procedure TCombat.MakeTrackedShadow;
  var
    p: PCombat;
    st, i, j: integer;
  begin
    if (TrackedStack > 0) and (Stacks[TrackedStack].qty <> 0) then begin
      p := Spawn;
      p^.MakeShadow(TrackedStack, true, false);
      Move(p^.Shadow, TrackedShadow, sizeof(Shadow));
      Dispose(p, Done);
    end else if TrackedStack < 0 then begin
      FillChar(TrackedShadow, sizeof(TrackedShadow), #0);
      p := Spawn;
      for st := 1 to LastStack do
        if (Stacks[st].qty > 0)
           and (Stacks[st].side = -TrackedStack) then begin
          p^.MakeShadow(st, true, false);
          for i := 1 to CombatXMax do
            for j := 1 to CombatYMax do
              if p^.Shadow[i, j] <> 0 then
                TrackedShadow[i, j] := 1;
        end;
      Dispose(p, Done);
    end;
  end;

procedure TCombat.ShowShadow;
  var i, j: integer;
  begin
    if actual then
      for i := 1 to CombatXMax do
        for j := 1 to CombatYMax do
          if Shadow[i, j] > 0 then
            DrawCombatHex(i, j);
  end;

procedure TCombat.BacktrackShadow(var x, y: integer; sh: integer);
  var
    h, tx, ty: integer;
    BSN: byte;
    BSX, BSY: integer;
  begin
    if shadow[x, y] <> sh then begin
      repeat
        BSN := shadow[x, y] - 1;
        BSX := 0;
        for h := 1 to 6 do
          if FindAdjHex(h, x, y, tx, ty) then
            if (shadow[tx, ty] <> 0) and (shadow[tx, ty] <= BSN) then begin
              BSX := tx;
              BSY := ty;
            end;
        x := BSX;
        y := BSY;
      until (x = 0) or (shadow[x, y] = sh);
    end;
  end;

procedure TCombat.BacktrackFutureShadow(var x, y: integer; sh: integer);
  var
    failures, maxf: integer;
    h, tx, ty: integer;
    BSN: byte;
    BSX, BSY: integer;
  begin
    if not ((shadow[x, y] = sh) and (HexEmpty(x, y))) then begin
      maxf := shadow[x, y] - 2;
      failures := 0;
      repeat
        BSN := shadow[x, y] - 1 - failures;
        BSX := 0;
        for h := 1 to 6 do
          if FindAdjHex(h, x, y, tx, ty) then
            if (shadow[tx, ty] <> 0) and (shadow[tx, ty] <= BSN) then begin
              BSX := tx;
              BSY := ty;
            end;
        if BSX <> 0 then begin
          x := BSX;
          y := BSY;
          failures := 0;
        end else
          inc(failures);
      until ((BSX <> 0) and (shadow[x, y] <= sh) and HexEmpty(x, y))
            or (failures >= maxf)
            or (shadow[x, y] = 1);
      if failures >= maxf then x := 0;
    end;
  end;

procedure TCombat.StartRound;
  var
    i, j, n, t, fi, fj, h, ni, nj, fhp: integer;
    fmap: TCombatMap;
  begin
    for i := 1 to LastStack do
      with Stacks[i] do
        if qty > 0 then begin
          moved := false;
          done := false;
          canshoot := true;
          morale := 0;
          whirly := 0;
          renew := 0;
          NumAttacks := 0;
          if (roundnum > 1) and EffFlag(i, 3, f3Spinning) then inc(spin);
          fhp := EffHp(i);
          if tophp > fhp then tophp := fhp;
          UpdateTrackedStackIf(i);
        end;

    for i := 1 to 2 do
      with SV[i] do
        if Dude <> 0 then begin
          HWent := false;
          HRoundSP := HeroSPPerRound(Dude);
          n := CountArt(Dude, anWandOfEndlessCurses, true);
          if n <> 0 then
            for j := 1 to n do
              WandSpell(i, 0, slEvil, clWandofEndlessCurses, false);
          n := CountArt(Dude, anScrollOfScrolls, true);
          if (n <> 0) and (roundnum > 1) then
            for j := 1 to n do
              CastEquipSpells(i);
        end else
          HWent := true;

    turnedge := 3 - turnedge;
    edge := turnedge;

    for i := 1 to CombatXMax do
      for j := 1 to CombatYMax do
        case CombatMap[i, j] of
          cmBarbican:   BarbicanTurn(i, j);
          cmSpellTower: begin
                          HighlightAwhile(i, j, actual);
                          WandSpell(2, 0, slEvil, clSpellTower, false);
                          Unhighlight(i, j);
                          DrawCombatHex(i, j);
                        end;
          cmFlooder:    begin
                          AddLogLine(chr(clFlood) + ' floods!');
                          FillChar(fmap, sizeof(fmap), #0);
                          for fi := 1 to CombatXMax do
                            for fj := 1 to CombatYMax do
                              if (CombatMap[fi, fj] = cmWater)
                                 or (CombatMap[fi, fj] = cmFlooder) then
                                for h := 1 to 6 do
                                  if FindAdjHex(h, fi, fj, ni, nj) then
                                    if (CombatMap[ni, nj] = cmGrass)
                                       or (CombatMap[ni, nj] = cmFire) then
                                      fmap[ni, nj] := 1;
                          for fi := 1 to CombatXMax do
                            for fj := 1 to CombatYMax do
                              if fmap[fi, fj] = 1 then
                                MakeObstacle(fi, fj, cmWater);
                        end;
          cmFan:        begin
                          AddLogLine(chr(clFan) + ' blows!');
                          HighlightAwhile(i, j, actual);
                          for t := 1 to 2 do
                            for n := 1 to 12 do
                              if StacksGrid[n, j] <> 0 then
                                BlowStack(StacksGrid[n, j], -1, 1);
                          Unhighlight(i, j);
                          DrawCombatHex(i, j);
                        end;
          cmOpeningGate: if roundnum = 2 then begin
                           AddLogLine(chr(clOpenGate) + ' opens!');
                           DrawFX(i, j, fxBolt, true);
                           RemoveObstacle(i, j);
                           Refresh;
                         end;
        end;

    CheckIfOver;
  end;

function TCombat.FastestStack: integer;
  var i, st, stspeed, stside, sp: integer;
  begin
    st := 0;
    stspeed := -1;

    for i := 1 to LastStack do
      with Stacks[i] do
        if (qty > 0) and not Stacks[i].done then begin
          sp := EffSpeed(i, false, false);
          if ((sp = stspeed) and (side = edge) and (stside <> edge))
             or (sp > stspeed) then begin
            st := i;
            stspeed := sp;
            stside := side;
          end;
        end;

    for i := 1 to 2 do
      with SV[i] do
        if not HWent then
          if ((HSpeed = stspeed)
              and (((i = edge) and (stside <> edge)) or (st > 0)))
             or (HSpeed > stspeed) then begin
            st := -i;
            stspeed := HSpeed;
            stside := i;
          end;

    FastestStack := st;
  end;

procedure TCombat.DrawMovementGhost(st, x, y: integer);
  var
    sg, w: integer;
    sh: byte;
  begin
    if actual then begin
      sg := StacksGrid[x, y];
      sh := Shadow[x, y];
      StacksGrid[x, y] := st;
      Shadow[x, y] := 0;
      DrawCombatHex(x, y);

      for w := 1 to MoveGhostDelay do begin
        Highlight(x, y, false, actual);
        Refresh;
      end;

      StacksGrid[x, y] := sg;
      Unhighlight(x, y);
      DrawCombatHex(x, y);
      Shadow[x, y] := sh;
    end;
  end;

procedure TCombat.MakeStacksGrid;
  var i: integer;
  begin
    FillChar(StacksGrid, sizeof(StacksGrid), #0);
    for i := 1 to LastStack do
      if Stacks[i].qty > 0 then
        StacksGrid[Stacks[i].x, Stacks[i].y] := i;
  end;

procedure TCombat.MoveStack(st, x, y: integer; teleport: boolean);
  var
    i, j, n, a, b: integer;
    SaveShadow: TShadow;
    steamroll, slimetrail, firetrail: boolean;
  begin
    SaveShadow := Shadow;
    i := Stacks[st].x;
    j := Stacks[st].y;
    EraseShadow;
    StacksGrid[i, j] := 0;

    if StacksGrid[x, y] <> 0 then
      MoveStack(StacksGrid[x, y], i, j, true);

    steamroll := EffFlag(st, 1, f1Steamroll);
    slimetrail := EffFlag(st, 3, f3SlimeTrail);
    firetrail := not slimetrail and EffFlag(st, 4, f4FireTrail);

    if actual or steamroll or slimetrail or firetrail then begin
      DrawCombatHex(i, j);
      if teleport then begin
        if slimetrail then
          MakeObstacle(x, y, cmWater)
        else if firetrail then
          MakeObstacle(x, y, cmFire);
      end else begin
        MoveStackTargetX := x;
        MoveStackTargetY := y;
        Shadow := MShadow;
        for n := 2 to Shadow[x, y] do begin
          a := x;
          b := y;
          BacktrackShadow(a, b, n);
          if a > 0 then begin
            if steamroll and (StacksGrid[a, b] <> 0)
               and (Stacks[StacksGrid[a, b]].side <> Stacks[st].side) then begin
              FillChar(Shadow, sizeof(Shadow), #0);
              Stacks[st].x := a;
              Stacks[st].y := b;
              AttackHex(st, a, b, false, 1);
              if (Stacks[st].x = a) and (Stacks[st].y = b) then begin
                Stacks[st].x := i;
                Stacks[st].y := j;
              end;
              Shadow := MShadow;
              MakeStacksGrid; { hack fix of rare steamroller bug }
              if StacksGrid[i, j] = st then StacksGrid[i, j] := 0;
(*            StacksGrid[Stacks[st].x, Stacks[st].y] := 0;
                { handles steam-vulture getting ghost images } *)
            end;
            if (slimetrail or firetrail)
               and (CombatMap[a, b] <= cmEmptyMax) then begin
              FillChar(Shadow, sizeof(Shadow), #0);
              if slimetrail then
                MakeObstacle(a, b, cmWater)
              else
                MakeObstacle(a, b, cmFire);
              Shadow := MShadow;
            end;
            DrawMovementGhost(st, a, b);
          end;
        end;
        FillChar(Shadow, sizeof(Shadow), #0);
        MoveStackTargetX := 0;
      end;
    end;

    Stacks[st].x := x;
    Stacks[st].y := y;
    if not teleport then begin
      Stacks[st].moved := true;
      Stacks[st].canshoot := false;
    end;
    StacksGrid[x, y] := st;
    UpdateStack(st);
    if teleport then Shadow := SaveShadow;
  end;

procedure TCombat.ExchangeStacks(st, st2: integer);
  var x, y: integer;
  begin
    x := Stacks[st].x;
    y := Stacks[st].y;
    EraseShadow;
    StacksGrid[x, y] := st2;
    StacksGrid[Stacks[st2].x, Stacks[st2].y] := st;
    Stacks[st].x := Stacks[st2].x;
    Stacks[st].y := Stacks[st2].y;
    Stacks[st2].x := x;
    Stacks[st2].y := y;
    UpdateStack(st);
    UpdateStack(st2);
  end;

function TCombat.HexHasTarget(st, x, y: integer): boolean;
  var hht: boolean;
  begin
    hht := false;
    if (StacksGrid[x, y] > 0)
       and (Stacks[StacksGrid[x, y]].side <> Stacks[st].side) then
      hht := true
    else if EffFlag(st, 2, f2Smash)
            and not (CombatMap[x, y] in cmUnremovable) then
      hht := true
    else if (CombatMap[x, y] >= cmGate1) and (CombatMap[x, y] <= cmGate8)
            and (Stacks[st].side = 1) then
      hht := true;
    HexHasTarget := hht;
  end;

function TCombat.CanReach(st, x, y: integer): boolean;
  begin
    CanReach := HexIsAdjacent(Stacks[st].x, Stacks[st].y, x, y)
                or (Stacks[st].canshoot
                    and (EffFlag(st, 1, (f1Range or f1RangeAll or f1Range1))
                         or (EffFlag(st, 1, f1HighRange)
                             and (StacksGrid[x, y] <> 0)
                             and EffFlag(StacksGrid[x, y], 1, f1Fly))
                         or (EffFlag(st, 1, f1RangeLine)
                             and HexIsInLine(Stacks[st].x, Stacks[st].y, x, y))
                         or (EffFlag(st, 1, f1ShortRange)
                             and HexWithinDist(Stacks[st].x, Stacks[st].y,
                                               x, y, 6))));
  end;

function TCombat.CanAttack(st, x, y: integer): boolean;
  var
    ca: boolean;
    bx, by, cx, cy, h, tx, ty, dx, dy: integer;
  begin
    ca := false;
    if CanReach(st, x, y) then begin
      if HexHasTarget(st, x, y) then
        ca := true;
      if EffFlag(st, 1, f1AoE) then begin
        for h := 1 to 6 do
          if FindAdjHex(h, x, y, tx, ty) then
            if HexHasTarget(st, tx, ty) then
              ca := true;
      end;
      if EffFlag(st, 1, (f1Breath1 or f1Breath2))
         or EffFlag(st, 5, f5FireCircle) then begin
        if HexAwayFrom(Stacks[st].x, Stacks[st].y, x, y, bx, by) then begin
          if HexHasTarget(st, bx, by) then
            ca := true;
          if EffFlag(st, 1, f1Breath2) then begin
            if HexAwayFrom(x, y, bx, by, cx, cy) then begin
              if HexHasTarget(st, cx, cy) then
                ca := true
              else begin
                if HexAwayFrom(bx, by, cx, cy, dx, dy)
                   and HexHasTarget(st, dx, dy) then
                  ca := true;
              end;
            end;
          end;
        end;
      end;
    end;
    CanAttack := ca;
  end;

function TCombat.AttackPossible(st: integer): boolean;
  var
    i, j: integer;
    ap: boolean;
  begin
    ap := false;
    for i := 1 to CombatXMax do
      for j := 1 to CombatYMax do
        if CanAttack(st, i, j) then ap := true;
    AttackPossible := ap;
  end;

procedure TCombat.KillIllusions(st: integer);
  var i: integer;
  begin
    if actual then
      for i := 1 to LastStack do
        if (Stacks[i].qty > 0) and (Stacks[i].illusion = st) then begin
          KillStack(i);
          DrawCombatHex(Stacks[st].x, Stacks[st].y);
        end;
  end;

procedure TCombat.KillStack(st: integer);
  const HandlingIllusions: boolean = false;
  var i, x, y, tx, ty: integer;
  begin
    x := Stacks[st].x;
    y := Stacks[st].y;

    DrawFX(x, y, fxDeath, true);

    StacksGrid[x, y] := 0;
    Stacks[st].qty := 0;

    if EffFlag(st, 4, f4Explode) then begin
      MakeObstacle(Stacks[st].x, Stacks[st].y, cmFire);
      for i := 1 to 6 do
        if FindAdjHex(i, Stacks[st].x, Stacks[st].y, tx, ty) then
          MakeObstacle(tx, ty, cmFire);
    end;

    DrawCombatHex(x, y);
    if not HandlingIllusions then begin
      HandlingIllusions := true;
      KillIllusions(st);
      HandlingIllusions := false;
    end;

    UpdateTrackedStackIf(st);

    for i := 1 to LastStack do
      if (Stacks[i].qty > 0) and EffFlag(i, 4, f4FeedOnDead)
         and FindEmptyOrAdjEmpty(x, y, tx, ty) then begin
        inc(Stacks[i].spin);
        MoveStack(i, tx, ty, true);
      end;

    Refresh;
  end;

function TCombat.SplitStack(st, side, amt: integer): byte;
  var
    fx, fy, st2: integer;
    split: boolean;
  begin
    split := FindAdjEmpty(Stacks[st].x, Stacks[st].y, fx, fy);
    st2 := 0;

    if split then begin
      st2 := FindFreeStack;
      if st2 <> 0 then begin
        Stacks[st2] := Stacks[st];
        Stacks[st2].side := side;
        with Stacks[st2] do begin
          qty := amt;
          maxqty := amt;
          x := fx;
          y := fy;
          tophp := EffHp(st2);
          marked := false;
        end;
        StacksGrid[fx, fy] := st2;
        if st2 > LastStack then LastStack := st2;
        dec(Stacks[st].qty, amt);
        dec(Stacks[st].maxqty, amt);
        DrawCombatHex(Stacks[st].x, Stacks[st].y);
        DrawCombatHex(fx, fy);
      end;
    end;

    SplitStack := st2;
  end;

procedure TCombat.AdjHp(st: integer; amt: longint);
  var
    fhp, tothp: longint;
  begin
    with Stacks[st] do begin
      fhp := EffHp(st);
      tothp := fhp * (qty - 1) + tophp + amt;
      if tothp < 0 then tothp := 0;
      qty := (tothp div fhp) + 1;
      tophp := tothp mod fhp;
      if tophp = 0 then begin
        tophp := fhp;
        dec(qty);
      end;
      if qty > maxqty then begin
        qty := maxqty;
        tophp := fhp;
      end;
    end;
  end;

function TCombat.DamageStack(st: integer; dmg: longint; melee: boolean;
                             var numkilled: integer): boolean;
  var
    st2, fx, fy, oldq, h, hs, darkarts, darkq, i, sh: integer;
    killed: boolean;
  begin
    oldq := Stacks[st].qty;

    if not melee and EffFlag(st, 1, f1Hiding) then begin
      dmg := dmg div 10;
      if dmg < 1 then dmg := 1;
    end;

    AdjHp(st, -dmg);
    DrawFX(Stacks[st].x, Stacks[st].y, fxBolt, true);
    DrawCombatHex(Stacks[st].x, Stacks[st].y);
    numkilled := oldq - Stacks[st].qty;
    killed := (Stacks[st].qty = 0)
              or ((Stacks[st].illusion <> 0) and actual);
    if killed then
      KillStack(st);

    if numkilled > 0 then begin
      h := SV[Stacks[st].side].Dude;
      if actual and (h <> 0) then begin
        if EffFlag(st, 3, f3DeathMana) then
          GiveDeathMana(h, numkilled * longint(40));
        if EffFlag(st, 5, f5DeathMana2) then
          GiveDeathMana(h, numkilled * longint(50));
      end;

      hs := 3 - Stacks[st].side;
      h := SV[hs].Dude;
      if h <> 0 then begin
        darkarts := SV[hs].DarkArts;
        if darkarts > 0 then begin
          inc(SV[hs].HKills, numkilled);
          darkq := (SV[hs].HKills * longint(darkarts)) div cDarkArtsKills;
          if darkq > 0 then begin
            sh := 0;
            for i := LastStack downto 1 do
              if (Stacks[i].qty > 0)
                 and (Stacks[i].realmonster = moShadow)
                 and (Stacks[i].monster = moShadow)
                 and (Stacks[i].side = 3 - Stacks[st].side) then
                sh := i;
            if sh <> 0 then begin
              inc(Stacks[sh].qty, darkq);
              if Stacks[sh].qty > Stacks[sh].maxqty then
                Stacks[sh].maxqty := Stacks[sh].qty;
              DrawCombatHex(Stacks[sh].x, Stacks[sh].y);
              dec(SV[hs].HKills, (darkq * longint(cDarkArtsKills)) div darkarts);
            end else
              if FindEmptyOrAdjEmpty(Stacks[st].x, Stacks[st].y,
                                     fx, fy) then begin
                st2 := AddStack(fx, fy, hs, moShadow, darkq, -1, 0);
                if st2 <> 0 then begin
                  DrawCombatHex(fx, fy);
                  dec(SV[hs].HKills, (darkq * longint(cDarkArtsKills))
                                     div darkarts);
                end;
              end;
          end;
        end;
      end;
    end;

    if Stacks[st].qty > 0 then begin
      if EffFlag(st, 3, f3Blink) then begin
        GetRandomEmptyHex(fx, fy);
        MoveStack(st, fx, fy, true);
      end;

      if EffFlag(st, 3, f3Regenerate) then
        HealStack(st, -1);

      if EffFlag(st, 3, f3LikesDamage) then
        inc(Stacks[st].spin);

      if EffFlag(st, 3, f3Split) and (Stacks[st].qty > 1) then
        SplitStack(st, Stacks[st].side, Stacks[st].qty div 2);
    end;

    UpdateTrackedStackIf(st);
    Refresh;

    DamageStack := killed;
  end;

function TCombat.LoggedDamageStack(st: integer; dmg: longint; melee: boolean;
                                   cl: integer): boolean;
  var
    kills: integer;
    lds: boolean;
    ch: char;
  begin
    ch := MonsterChr(st);
    lds := DamageStack(st, dmg, melee, kills);
    if kills = 0 then
      AddLogLine(chr(cl) + ' hits ' + ch)
    else
      AddLogLine(chr(cl) + ' hits ' + ch + ', kills ' + IStr(kills, 0));
    LoggedDamageStack := lds;
  end;

procedure TCombat.GetRandomEmptyHex(var m, n: integer);
  begin
    repeat
      m := random(CombatXMax) + 1;
      n := random(CombatYMax) + 1;
    until HexEmpty(m, n)
          and not ((MoveStackTargetX = m) and (MoveStackTargetY = n));
  end;

procedure TCombat.RemoveObstacle(x, y: integer);
  begin
    if not (CombatMap[x, y] in cmUnremovable) then begin
      DrawFX(x, y, fxBolt, true);
      CombatMap[x, y] := cmGrass;
      if actual then begin
        DrawCombatGridHex(x, y);
        DrawCombatHex(x, y);
        UpdateTrackedStack;
        Refresh;
      end;
    end;
  end;

procedure TCombat.MakeObstacle(x, y, ob: integer);
  var h, ax, ay: integer;
  begin
    CombatMap[x, y] := ob;
    DrawCombatHex(x, y);
    for h := 1 to 6 do
      if FindAdjHex(h, x, y, ax, ay) then
        if CombatMap[ax, ay] in [cmFire, cmWater] then
          DrawCombatHex(ax, ay);
  end;

procedure TCombat.VolveStack(st, n: integer);
  var
    m, i: integer;
    r: real;
  begin
    with Stacks[st] do begin
      m := monster;
      if ((n = -1) and (MonsterLevel(m) <> 1))
         or ((n = 1) and (MonsterLevel(m) <> 6)) then begin
        r := tophp / EffHp(st);
        SetMonster(st, m + n);
        tophp := round(r * EffHp(st));
        if tophp > Stacks[st].hp then
          tophp := Stacks[st].hp;
        if tophp < 1 then
          tophp := 1;
        UpdateStack(st);
        KillIllusions(st);
      end;
    end;
  end;

procedure TCombat.AttackHex(st, x, y: integer; melee: boolean; divide: integer);
  var
    i, st2, st3, tothp, variance, m, n, h, tx, ty, nx, ny: integer;
    oldq, oldside, gp: integer;
    d, totd, fhp: longint;
    mind, maxd: integer;
    killed: boolean;

  procedure FixTopHP(tst: integer);
    var f: integer;
    begin
      f := EffHp(tst);
      if Stacks[tst].tophp > f then Stacks[tst].tophp := f;
    end;

  procedure MakeDeathStack(fbyte, fbit, mo: integer);
    begin
      if EffFlag(st, fbyte, fbit) and (Stacks[st2].monster <> mo) then begin
        if FindEmptyOrAdjEmpty(x, y, tx, ty) then begin
          st3 := AddStack(tx, ty, Stacks[st].side, mo, 1, -1, 0);
          DrawCombatHex(tx, ty);
        end;
      end;
    end;

  begin
    st2 := StacksGrid[x, y];

    if (st2 <> 0) and (Stacks[st2].qty > 0) and (Stacks[st].qty > 0)
       and (not EffFlag(st, 4, f4Friendship)
            or (Stacks[st2].side <> Stacks[st].side)) then begin
      if EffFlag(st, 2, f2CopyFlags) then
        for i := 1 to NumFlagWords do
          Stacks[st].flags[i] := Stacks[st].flags[i] or EffFlagWord(st2, i);

      if EffFlag(st, 2, f2Circle) then begin
        ExchangeStacks(st, st2);
        x := Stacks[st2].x;
        y := Stacks[st2].y;
      end;

      if EffFlag(st, 2, f2Throw) then begin
        GetRandomEmptyHex(m, n);
        MoveStack(st2, m, n, true);
        x := m;
        y := n;
      end;

      if EffFlag(st, 5, f5Pull) then begin
        if FindEmptyOrAdjEmpty(Stacks[st].x, Stacks[st].y, tx, ty) then begin
          MoveStack(st2, tx, ty, true);
          x := tx;
          y := ty;
        end;
      end;

      fhp := EffHp(st2);
      EffDmg(st, mind, maxd);
      d := (mind + random(maxd - mind + 1)) * longint(Stacks[st].qty);
      if divide <> 1 then
        d := (d + divide - 1) div divide;
      if EffFlag(st, 4, f4Maiming)
         and not EffFlag(st2, 6, f6DefImmune) then begin
        d := d + fhp;
        d := d - (d mod fhp);
      end;
      if EffFlag(st, 2, f2Assassin) then
        inc(d, fhp * longint(Stacks[st].qty));

      oldq := Stacks[st2].qty;
      oldside := Stacks[st2].side;
      totd := longint(oldq) * fhp;
      killed := false;

      if EffFlag(st, 4, f4Traitor)
         and not ((Stacks[st2].illusion <> 0) and actual) then begin
        i := Stacks[st].qty;
        if i > Stacks[st2].qty then i := Stacks[st2].qty;
        AddLogLine(MonsterChr(st) + ' enslaves ' + IStr(i, 0) + ' '
                   + MonsterChr(st2));
        Traitors(st2, Stacks[st].side, Stacks[st].qty);
        killed := (Stacks[st2].qty = 0) or (Stacks[st2].side = Stacks[st].side);
      end;

      if not killed then
        killed := LoggedDamageStack(st2, d,
                                    melee or EffFlag(st, 6, f6AttImmune),
                                    ord(MonsterChr(st)));

      if not killed then begin
        if not EffFlag(st2, 6, f6DefImmune) then begin
          if EffFlag(st, 2, f2RemoveFlags) then
            for i := 1 to NumFlagWords do
              Stacks[st2].Flags[i] := 0;
          if EffFlag(st, 2, f2Stun) then
            inc(Stacks[st2].stunned);
        end;
        if EffFlag(st2, 5, f5Bewildering) then
          for i := 1 to NumFlagWords do
            Stacks[st].Flags[i] := 0;
        if EffFlag(st, 2, f2Hex) then begin
          Stacks[st2].hexed := true;
          FixTopHP(st2);
        end;
        if EffFlag(st, 5, f5Disease) then begin
          Stacks[st2].diseased := true;
          FixTopHP(st2);
        end;
        if EffFlag(st, 4, f4Curse) then
          WandSpell(Stacks[st].side, st2, slEvil, ord(MonsterChr(st)), false);
        if EffFlag(st, 4, f4Poison)
           and not EffFlag(st2, 6, f6DefImmune) then
          if Stacks[st2].poison < cPoisonDamage * Stacks[st].qty then
            Stacks[st2].poison := cPoisonDamage * Stacks[st].qty;
        if melee and EffFlag(st2, 4, f4Poison)
           and not EffFlag(st, 6, f6AttImmune) then
          if Stacks[st].poison < cPoisonDamage * Stacks[st2].qty then begin
            Stacks[st].poison := cPoisonDamage * Stacks[st2].qty;
            DrawCombatHex(Stacks[st].x, Stacks[st].y);
          end;
        if EffFlag(st, 2, f2Devolve) then
          VolveStack(st2, -1);
        if EffFlag(st, 2, f2SplitYou) and (Stacks[st2].qty > 1) then
          SplitStack(st2, Stacks[st2].side, Stacks[st2].qty div 2);
        UpdateStack(st2);
      end;

      if EffFlag(st, 2, f2Flame) then
        MakeObstacle(x, y, cmFire);

      if EffFlag(st, 2, f2Water) then
        MakeObstacle(x, y, cmWater);

      DrawCombatHex(x, y);

      if killed then begin
        MakeDeathStack(3, f3RaiseDead, moSoulThief);
        MakeDeathStack(6, f6RaiseSkulk, moSkulk);
        if EffFlag(st, 3, f3Morale) then begin
          if Stacks[st].morale = 0 then Stacks[st].morale := 1;
        end;
        if EffFlag(st, 5, f5Werewolf) then
          with Stacks[st] do begin
            inc(spin);
            inc(wolfct);
            case wolfct of
              1: begin
                   Flags[1] := Flags[1] or f1Retaliate;
                   DrawCombatHex(x, y);
                 end;
              2: Flags[5] := Flags[5] or f5Disease;
              3: Flags[4] := Flags[4] or f4Poison;
              4: Flags[2] := Flags[2] or f2Stun;
            end;
          end;
      end;

      if EffFlag(st, 2, f2Push) then begin
        for h := 1 to 6 do
          if FindAdjHex(h, Stacks[st].x, Stacks[st].y, tx, ty) then
            if (StacksGrid[tx, ty] <> 0)
               and (Stacks[StacksGrid[tx, ty]].side <> Stacks[st].side) then
              PushBackFrom(StacksGrid[tx, ty], Stacks[st].x, Stacks[st].y);
      end;

      if EffFlag(st, 3, f3Vampire) then begin
        if d > totd then d := totd;
        AdjHp(st, d);
        DrawFX(Stacks[st].x, Stacks[st].y, fxHeal, true);
        DrawCombatHex(Stacks[st].x, Stacks[st].y);
      end;

      if (SV[Stacks[st].side].FlyersHelm > 0) and EffFlag(st, 1, f1Fly) then
        for i := 1 to SV[Stacks[st].side].FlyersHelm do
          HealSpell(st);

      if not killed and melee then begin
        if not EffFlag(st, 6, f6AttImmune) then begin
          if (EffFlag(st2, 1, f1Retaliate) or EffFlag(st2, 5, f5OneRetaliate))
             and CanAttack(st2, Stacks[st].x, Stacks[st].y) then begin
            AttackHex(st2, Stacks[st].x, Stacks[st].y, false, 1);
            Stacks[st2].flags[5] := Stacks[st2].flags[5] and not f5OneRetaliate;
          end;
          if EffFlag(st2, 4, f4Spikes) then
            LoggedDamageStack(st, cSpikeDamage, false, clSpikedShield);
          if EffFlag(st2, 5, f5Spikes2) then
            LoggedDamageStack(st, cSpikeDamage * 2, false, clSpikedShield);
        end;
        if EffFlag(st2, 3, f3Bounce) then begin
          tx := Stacks[st2].x;
          ty := Stacks[st2].y;
          for i := 1 to 12 do begin
            nx := Stacks[st].x;
            ny := Stacks[st].y;
            if (Stacks[st].x <> tx) or (Stacks[st].y <> ty) then
              PushBackFrom(st, tx, ty);
            tx := nx;
            ty := ny;
          end;
        end;
      end;
    end else begin
      if EffFlag(st, 2, f2Smash) then
        RemoveObstacle(x, y)
      else if (CombatMap[x, y] >= cmGate1)
              and (CombatMap[x, y] <= cmGate8) then begin
        EffDmg(st, mind, maxd);
        d := maxd * longint(Stacks[st].qty);
        n := CombatMap[x, y] - (d + cGateStrength - 1) div cGateStrength;
        if n < cmGate1 then n := cmGrass;
        DrawFX(x, y, fxBolt, true);
        CombatMap[x, y] := n;
        DrawCombatHex(x, y);
        UpdateTrackedStack;
        AddLogLine(MonsterChr(st) + ' hits ' + chr(clGate));
      end;

      if CombatMap[x, y] <= cmEmptyMax then begin
        if EffFlag(st, 2, f2Flame) then
          MakeObstacle(x, y, cmFire);
        if EffFlag(st, 2, f2Water) then
          MakeObstacle(x, y, cmWater);
      end;
    end;

    Refresh;
  end;

procedure TCombat.StackDone(st: integer);
  begin
    Stacks[st].moved := true;
    Stacks[st].done := true;
    Stacks[st].canshoot := false;
  end;

procedure TCombat.MarkStacksOnSide(side: integer);
  var i: integer;
  begin
    for i := 1 to StackMax do
      Stacks[i].marked := (Stacks[i].qty > 0) and (Stacks[i].side = side);
  end;

procedure TCombat.Attack(st, x, y: integer);
  var
    melee, gotl1, gotl2, trampledone, circleoffire: boolean;
    st2, stt, bx, by, cx, cy, dx, dy, fx, fy: integer;
    h, fh, h2, rh, rh2: integer;

  procedure AttackAdj(i, j, act: integer);
    var h, tx, ty: integer;
    begin
      for h := 1 to act do
        if FindWideAdjHex(h, i, j, tx, ty) then
          if (StacksGrid[tx, ty] <> st)
             and ((stt = 0) or (StacksGrid[tx, ty] <> stt))
             and not ((tx = x) and (ty = y)) then
            AttackHex(st, tx, ty, false, 1);
    end;

  procedure TrampleSub(really: boolean);
    begin
      if really and (fx <> 0) then DrawMovementGhost(st, x, y);
      bx := Stacks[st].x;
      by := Stacks[st].y;
      cx := x;
      cy := y;
      trampledone := false;
      repeat
        if HexAwayFrom(bx, by, cx, cy, dx, dy)
           and (StacksGrid[dx, dy] <> 0) then begin
          if really then begin
            AttackHex(st, dx, dy, false, 1);
            if fx <> 0 then DrawMovementGhost(st, dx, dy);
          end;
          bx := cx;
          by := cy;
          cx := dx;
          cy := dy;
        end else
          trampledone := true;
      until trampledone;

      if really and (fx <> 0) then StacksGrid[fx, fy] := 0;

      if OnGrid(dx, dy) and HexEmpty(dx, dy) then begin
        if really then
          MoveStack(st, dx, dy, true)
        else begin
          fx := dx;
          fy := dy;
        end;
      end else begin
        if really and (fx <> 0) then MakeStacksGrid;
        fx := 0;
      end;
    end;

  begin
    melee := HexIsAdjacent(x, y, Stacks[st].x, Stacks[st].y);
    stt := StacksGrid[x, y];
    Stacks[st].done := true; { needed here for blobs vs. weebles }
    circleoffire := melee and EffFlag(st, 5, f5FireCircle);

    MarkStacksOnSide(3 - Stacks[st].side);
    if stt <> 0 then Stacks[stt].marked := false;

    fx := Stacks[st].x;
    fy := Stacks[st].y;

    AttackHex(st, x, y, melee, 1);

    if melee and EffFlag(st, 5, f5Trample)
       and (fx = Stacks[st].x) and (fy = Stacks[st].y) then begin
      TrampleSub(false);
      if fx <> 0 then begin
        MoveStackTargetX := fx;
        MoveStackTargetY := fy;
        StacksGrid[Stacks[st].x, Stacks[st].y] := 0;
        DrawCombatHex(Stacks[st].x, Stacks[st].y);
      end;
      TrampleSub(true);
      MoveStackTargetX := 0;
    end;

    if circleoffire then
      AttackAdj(Stacks[st].x, Stacks[st].y, 12);

    if EffFlag(st, 2, f2Hydra) and not circleoffire then
      AttackAdj(Stacks[st].x, Stacks[st].y, 6);

    if EffFlag(st, 1, f1AoE) then
      AttackAdj(x, y, 6);

    if melee and EffFlag(st, 1, (f1Breath1 or f1Breath2)) then begin
      if HexAwayFrom(Stacks[st].x, Stacks[st].y, x, y, bx, by) then begin
        if not circleoffire then AttackHex(st, bx, by, false, 1);
        if EffFlag(st, 1, f1Breath2) then begin
          if HexAwayFrom(x, y, bx, by, cx, cy) then begin
            AttackHex(st, cx, cy, false, 1);
            if HexAwayFrom(bx, by, cx, cy, dx, dy) then
              AttackHex(st, dx, dy, false, 1);
          end;
        end;
      end;
    end;

    if EffFlag(st, 2, f2TwoHead) and melee then begin
      if HexAwayFrom(x, y, Stacks[st].x, Stacks[st].y, bx, by) then
        AttackHex(st, bx, by, false, 1);
    end;

    if EffFlag(st, 3, f3Lightning) then begin
      gotl1 := false;
      gotl2 := false;
      rh := random(6);
      rh2 := random(6);
      for h := 1 to 6 do
        if not gotl1 and FindAdjHex(((h + rh) mod 6) + 1, x, y, bx, by)
           and (StacksGrid[bx, by] <> 0)
           and (StacksGrid[bx, by] <> st) then begin
          gotl1 := true;
          AttackHex(st, bx, by, false, 2);
          for h2 := 1 to 6 do
            if not gotl2 and FindAdjHex(((h2 + rh2) mod 6) + 1, bx, by, cx, cy)
               and (StacksGrid[cx, cy] <> 0)
               and (StacksGrid[cx, cy] <> st)
               and (StacksGrid[cx, cy] <> stt) then begin
              gotl2 := true;
              AttackHex(st, cx, cy, false, 4);
            end;
        end;
    end;

    if EffFlag(st, 1, f1RangeAll) then begin
      for st2 := 1 to LastStack do
        if Stacks[st2].marked and (Stacks[st2].qty > 0)
           and (Stacks[st2].side <> Stacks[st].side) then
          AttackHex(st, Stacks[st2].x, Stacks[st2].y, false, 1);
    end;

    h := SV[Stacks[st].side].Dude;
    if (h <> 0) and (MonsterLevel(Stacks[st].monster) = 6)
       and SV[Stacks[st].side].FieryGloves then
      for fh := 1 to 6 do
        if FindAdjHex(fh, Stacks[st].x, Stacks[st].y, bx, by) then
          MakeObstacle(bx, by, cmFire);

    if not Stacks[st].moved then EraseShadow;

    if EffFlag(st, 2, f2AttMoveAtt) and not Stacks[st].moved
       and (Stacks[st].whirly = 0) then
      Stacks[st].whirly := 1;

    if not melee then
      Stacks[st].flags[1] := Stacks[st].flags[1] and not f1Range1;

    inc(Stacks[st].NumAttacks);

    if EffFlag(st, 5, f5ThreeAttacks)
       and (Stacks[st].NumAttacks < 3) then begin
      Stacks[st].done := false;
      Stacks[st].moved := true;
    end else
      StackDone(st);
  end;

procedure TCombat.ClearTrackedStack;
  begin
    TrackedStack := 0;
    EraseStats(2);
    DrawCombatLog;
    FillChar(TrackedShadow, sizeof(TrackedShadow), #0);
    DrawCombatGrid;
  end;

procedure TCombat.UpdateTrackedStack;
  begin
    if actual and (TrackedStack <> 0) then begin
      if (TrackedStack > 0) and (Stacks[TrackedStack].qty = 0) then begin
        ClearTrackedStack;
      end else begin
        if TrackedStack > 0 then
          ShowStackStats(TrackedStack, 2, -1)
        else begin
          EraseStats(2);
          DrawCombatLog;
        end;
        MakeTrackedShadow;
        DrawCombatGrid;
      end;
    end;
  end;

procedure TCombat.UpdateTrackedStackIf(st: integer);
  begin
    if (TrackedStack = st)
       or ((TrackedStack < 0) and (Stacks[st].side = -TrackedStack)) then
      UpdateTrackedStack;
  end;

procedure TCombat.AddLogLine(s: string);
  begin
    if actual then begin
      AddCombatLogLine(s);
      if TrackedStack <= 0 then DrawCombatLog;
    end;
  end;

function TCombat.MonsterChr(st: integer): char;
  var i: integer;
  begin
    if Stacks[st].side = 1 then
      i := clMonster1
    else
      i := clMonster2;
    MonsterChr := chr(i + Stacks[st].monster - 1);
  end;

procedure TCombat.UpdateStack(st: integer);
  begin
    DrawCombatHex(Stacks[st].x, Stacks[st].y);
    UpdateTrackedStackIf(st);
  end;

procedure TCombat.ShowAttMoveChoice;
  var x, y, i: integer;
  begin
    if AttMoveChoiceX <> 0 then begin
      GetCombatHexXY(AttMoveChoiceX, AttMoveChoiceY, x, y);
      inc(y, 2);
      DrawSmallGraphic2c(x + 6, y + 4, colWhite, colLightGray,
                         ArtGraphics[agBoots]);
      DrawSmallGraphic2c(x + 20, y + 22, colWhite, colLightGray,
                         ArtGraphics[agSword]);
      for i := 0 to 35 do
        XPutPixel(x + 35 - i, y + i, colLightGray);
    end;
  end;

procedure TCombat.PlayerTurn(st: integer);
  var
    x, y, amx, amy, gx, gy, i, j, shadowct: integer;
    canmove, canatt, attposs: boolean;
  begin
    MakeShadow(st, true, false);
    ShowShadow;

    shadowct := 0;
    for i := 1 to CombatXMax do
      for j := 1 to CombatYMax do
        if Shadow[i, j] > 0 then inc(shadowct);

    repeat
      ShowStackStats(st, 1, 0);
      UpdateTrackedStack;
      attposs := AttackPossible(st);
      if (shadowct = 0) and not attposs then begin
        HighlightAwhile(Stacks[st].x, Stacks[st].y, actual);
        Unhighlight(Stacks[st].x, Stacks[st].y);
        DrawCombatHex(Stacks[st].x, Stacks[st].y);
        Stacks[st].done := true;
      end else if not Stacks[st].moved or attposs then begin
        GetClick(Stacks[st].x, Stacks[st].y, x, y, Stacks[st].side, st);
        Unhighlight(Stacks[st].x, Stacks[st].y);
        DrawCombatHex(Stacks[st].x, Stacks[st].y);
        if x <> -1 then begin
          PointToGrid(x, y);
          if OnGrid(x, y) then begin
            canmove := (Shadow[x, y] > 0) and not Stacks[st].moved;
            canatt := CanAttack(st, x, y);
            if canatt and canmove then begin
              AttMoveChoiceX := x;
              AttMoveChoiceY := y;
              ShowAttMoveChoice;
              repeat
                GetClick(x, y, amx, amy, Stacks[st].side, st);
                if amx <> -1 then begin
                  gx := amx;
                  gy := amy;
                  PointToGrid(gx, gy);
                  if (gx = x) and (gy = y) then begin
                    PointToGridOfs(amx, amy);
                    if (amx + amy) < 36 then
                      canatt := false
                    else
                      canmove := false;
                  end;
                end;
              until (not canatt) or (not canmove) or over;
              AttMoveChoiceX := 0;
              DrawCombatHex(x, y);
            end;
            if canmove then
              MoveStack(st, x, y, false)
            else if canatt then
              Attack(st, x, y);
          end else if (x = 15) and (y = 2) then begin
            StackPassTurn(st);
{           Stacks[st].renew := 0; } { !X! }
            EraseShadow;
            DrawCombatHex(Stacks[st].x, Stacks[st].y);
            DrawFX(Stacks[st].x, Stacks[st].y, fxHourglass, true);
            DrawCombatHex(Stacks[st].x, Stacks[st].y);
            Refresh;
          end;
        end;
      end;
      if Stacks[st].moved and not Stacks[st].done
         and not AttackPossible(st) then
        StackDone(st);
    until Stacks[st].done or over;
    UpdateTrackedStack;
  end;

procedure TCombat.SideHasFlier(var side1, side2: boolean);
  var i: integer;
  begin
    side1 := false;
    side2 := false;

    for i := 1 to LastStack do
      with Stacks[i] do
        if (qty > 0) and EffFlag(i, 1, f1Fly) then begin
          if side = 1 then
            side1 := true
          else
            side2 := true;
        end;
  end;

procedure TCombat.GoldPieceAdvantage(gside: integer;
                                     var gpa, rgpa, sgpa: longint;
                                     madsci: boolean);
  var
    i, j: integer;
    h, c, tothp, fhp, n: longint;
    hasflier: array [1..2] of boolean;
    makesguys: boolean;
  begin
    gpa := 0;
    rgpa := 0;
    sgpa := 0;
    SideHasFlier(hasflier[1], hasflier[2]);

    for i := 1 to LastStack do
      with Stacks[i] do
        if qty > 0 then begin
          if madsci then
            c := MonsterData[monster].cost
          else
            c := MonsterData[realmonster].cost;
          makesguys := EffFlag(i, 5, f5MakesGuys);
          if makesguys then
            inc(c, avgLevel1MonsterCost);
          fhp := EffHp(i);
          tothp := fhp * (qty - 1) + tophp;
          tothp := tothp + (fhp - tophp) div 2;
           { part dead troop is worth more than its fraction of live troop }
          n := poison;
          if (CombatMap[x, y] = cmFire)
             and not EffFlag(i, 4, f4FireImmune) then
            inc(n, cFireDamage);
          if n > 0 then begin
            if EffFlag(i, 1, f1Hiding) then
              dec(tothp, n div 10)
            else
              dec(tothp, n);
          end;
          h := (tothp * c) div fhp;
          if h < 0 then h := 0;
          if not done then
            inc(h, h div 4); { prefer attacking units that haven't gone yet }
          if (armyslot = 0) and (not SV[side].AI) and (illusion = 0) then begin
(*          h := (h * 2) div 5; { devalue summoned stacks } *)
            if side = gside then inc(sgpa, h) else dec(sgpa, h);
            h := 0; { ignore human summoned stacks unless desperate !X! }
          end;
          if side = gside then inc(gpa, h) else dec(gpa, h);
          if EffFlag(i, 1, (f1Range or f1RangeAll))
             or (hasflier[3 - side] and EffFlag(i, 1, f1HighRange))
             or makesguys then begin
            if side = gside then inc(rgpa, h) else dec(rgpa, h);
          end;
        end;

    for i := 1 to 2 do
      with SV[i] do
        if Archery <> 0 then
          if i = gside then
            inc(rgpa, Archery * longint(40 * cArcheryDamage))
          else
            dec(rgpa, Archery * longint(40 * cArcheryDamage));

    n := 0;

    if CDef = 21 then
      for j := 1 to CombatYMax do
        if CombatMap[12, j] = cmBarbican then
          inc(n);

    if ((CDef = 25) and (CombatMap[7, 8] = cmBarbican))
       or ((CDef = 33) and (CombatMap[9, 4] = cmBarbican)) then
      inc(n);

    if n > 0 then begin
      n := n * cBarbicanDamage * 20;
      if gside = 1 then n := -n;
      inc(gpa, n);
      inc(rgpa, n);
    end;
  end;

procedure TCombat.FastGPA(gside: integer; var gpa: longint);
  var
    i: integer;
    h, tothp, fhp: longint;
  begin
    gpa := 0;

    for i := 1 to LastStack do
      with Stacks[i] do
        if qty > 0 then begin
          fhp := EffHp(i);
          tothp := fhp * (qty - 1) + tophp;
          tothp := tothp + (fhp - tophp) div 2;
           { part dead troop is worth more than its fraction of live troop }
{ ignore fire immunity, hiding vs. poison/fire }
{ - rarely relevant for future moves }
{ but have to handle fire for fire shield cases and poison for all-poison }

          if CombatMap[x, y] = cmFire then
            dec(tothp, cFireDamage);
          dec(tothp, poison);

          h := (tothp * MonsterData[realmonster].cost) div fhp;
{ not noting bonus for hitting clown cars }
          if h < 0 then h := 0;

          if not done then
            inc(h, h div 4); { prefer attacking units that haven't gone yet }
{ don't treat summoned stacks special - rarely relevant for future moves }
(*
          if (armyslot = 0) and (SV[side].Dude <> 0) then
            h := (h * 2) div 5;  { devalue summoned stacks }
*)
{ no let's try treating them as worthless for human !X! }
          if (armyslot = 0) and not SV[side].AI then
            h := 0;

          if side = gside then inc(gpa, h) else dec(gpa, h);
        end;

    { ignore barbicans - only effects Cloud Giants in rare battles }
  end;

procedure TCombat.CalcAttackMoves(st: integer);
  var
    i, j, h, h2, tx, ty, tx2, ty2, tx3, ty3, tx4, ty4: integer;
    breath, breath2, AoE: boolean;

  procedure SetAttackMove(x, y: integer);
    begin
      if (Shadow[x, y] > 0)
         or ((x = Stacks[st].x) and (y = Stacks[st].y)) then
        AttackMoves[x, y] := 1;
    end;

  begin
    FillChar(Targets, sizeof(Targets), #0);
    FillChar(AttackMoves, sizeof(AttackMoves), #0);

    breath2 := EffFlag(st, 1, f1Breath2);
    breath := EffFlag(st, 1, f1Breath1) or breath2
              or EffFlag(st, 5, f5FireCircle);
    AoE := EffFlag(st, 1, f1AoE);

    for i := 1 to CombatXMax do
      for j := 1 to CombatYMax do
        if HexHasTarget(st, i, j) then begin
          Targets[i, j] := 1;
          for h := 1 to 6 do begin
            if FindAdjHex(h, i, j, tx, ty) then begin
              SetAttackMove(tx, ty);
              if AoE then begin
                Targets[tx, ty] := 1;
                for h2 := 1 to 6 do
                  if FindAdjHex(h2, tx, ty, tx2, ty2) then
                    SetAttackMove(tx2, ty2);
              end;
              if breath then begin
                Targets[tx, ty] := 1;
                if FindAdjHex(h, tx, ty, tx2, ty2) then begin
                  SetAttackMove(tx2, ty2);
                  if breath2 then begin
                    Targets[tx2, ty2] := 1;
                    if FindAdjHex(h, tx2, ty2, tx3, ty3) then begin
                      SetAttackMove(tx3, ty3);
                      Targets[tx3, ty3] := 1;
                      if FindAdjHex(h, tx3, ty3, tx4, ty4) then
                        SetAttackMove(tx4, ty4);
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;

    if EffFlag(st, 1, f1AnyRange) then
      AttackMoves[Stacks[st].x, Stacks[st].y] := 1;
  end;

function TCombat.DistanceToClosestEnemy(st: integer;
                                        range, conjuredok: boolean): integer;
  var i, h, tx, ty, bestn: integer;
  begin
    MakeShadow(st, false, true);
    bestn := MaxInt;
    for i := 1 to LastStack do
      if (Stacks[i].qty > 0) and (Stacks[i].side <> Stacks[st].side)
         and not ((not conjuredok) and (Stacks[i].armyslot = 0)
                  and (SV[Stacks[i].side].Dude <> 0)
                  and not SV[Stacks[i].side].AI
                  and (Stacks[i].illusion = 0))  { !X! }
         and ((not range)
              or (EffFlag(i, 1, f1Range or f1HighRange or f1RangeAll)
                  or EffFlag(i, 5, f5MakesGuys))) then
        for h := 1 to 6 do
          if FindAdjHex(h, Stacks[i].x, Stacks[i].y, tx, ty) then begin
            if (tx = Stacks[st].x) and (ty = Stacks[st].y) then
              bestn := 1
            else if (shadow[tx, ty] > 0) and (shadow[tx, ty] < bestn) then
              bestn := shadow[tx, ty];
          end;

    dec(bestn, 2);

    if not conjuredok and (bestn = MaxInt - 2) then
      bestn := DistanceToClosestEnemy(st, range, true);

    DistanceToClosestEnemy := bestn;
  end;

function TCombat.FindBestAttackGold(st: integer): longint;
  var
    i, j, sid: integer;
    g, bestg, startg: longint;
    couldattack: boolean;

  procedure TryMove(m, n: integer);
    var
      p: PCombat;
      st2, h, a, b, tx, ty: integer;

    procedure TryAttack(x, y: integer);
      var q: PCombat;
      begin
        if p^.CanAttack(st, x, y) then begin
          couldattack := true;
          q := p^.Spawn;
          q^.Attack(st, x, y);
          q^.FastGPA(sid, g);
          if g >= bestg then bestg := g;
          Dispose(q, Done);
        end;
      end;

    begin
      p := Spawn;
      if (Shadow[m, n] > 0) then p^.MoveStack(st, m, n, false);

      if Stacks[st].canshoot and EffFlag(st, 1, f1AnyRange) then begin
        for a := 1 to CombatXMax do
          for b := 1 to CombatYMax do
            if Targets[a, b] > 0 then
              TryAttack(a, b);
      end else begin
        for h := 1 to 6 do
          if FindAdjHex(h, m, n, tx, ty) then
            if Targets[tx, ty] > 0 then
              TryAttack(tx, ty);
      end;

      Dispose(p, Done);
    end;

  begin
    sid := Stacks[st].side;
    FastGPA(sid, bestg);
    startg := bestg;
    couldattack := false;
    MakeShadow(st, true, false);
    CalcAttackMoves(st);

    for i := 1 to CombatXMax do
      for j := 1 to CombatYMax do
        if (AttackMoves[i, j] > 0) then
          TryMove(i, j);

    if couldattack then
      bestg := bestg - startg
    else
      bestg := 0;

    FindBestAttackGold := bestg;
  end;

function TCombat.BoardValue(sid: integer): longint;
  var
    st: integer;
    g, g2: longint;
    p: PCombat;
  begin
    g := 0;
    for st := 1 to LastStack do
      if Stacks[st].qty > 0 then begin
        p := Spawn;
        p^.Stacks[st].canshoot := true;
        g2 := p^.FindBestAttackGold(st);
        if Stacks[st].side = sid then inc(g, g2) else dec(g, g2);
        Dispose(p, Done);
      end;
    BoardValue := g;
  end;

function TCombat.FindBestFutureAttackGold(st: integer): longint;
  var
    p: PCombat;
    g: longint;
  begin
    p := Spawn;
    p^.Stacks[st].canshoot := true;
    p^.Stacks[st].speed := p^.Stacks[st].speed * 2;
    g := p^.FindBestAttackGold(st);
    Dispose(p, Done);
    FindBestFutureAttackGold := g;
  end;

procedure TCombat.StackPassTurn(st: integer);
  var tx, ty, m: integer;
  begin
    if Stacks[st].canshoot and EffFlag(st, 5, f5MakesGuys) then begin
      if FindEmptyOrAdjEmpty(Stacks[st].x, Stacks[st].y, tx, ty) then begin
        if actual then
          m := random(NumCastleTypes) * 6 + 1
        else
          m := moRubberRat;
        AddStack(tx, ty, Stacks[st].side, m, Stacks[st].qty, 0, 0);
        DrawCombatHex(tx, ty);
      end;
    end;

    StackDone(st);
  end;

procedure TCombat.GetGoodAIMove(st: integer;
                                var bestmx, bestmy, bestax, bestay: integer);
  var
    sid, bestdist, bestatt, bestwhirl, bestcenter: integer;
    g, bestgpa, bestattgp, bestsgpa, basegpa, basergpa, basesgpa: longint;
    freewhirly, desperate, mustcalcgpa, madsci: boolean;

  procedure AssessPlay(c: PCombat; movx, movy, attx, atty: integer);
    var
      gpa, rgpa, sgpa, attgp: longint;
      dist, att, whirl, center: integer;

    procedure FindGPA;
      begin
        if (attx <> -1) or mustcalcgpa or (CombatMap[movx, movy] = cmFire) then
          c^.GoldPieceAdvantage(c^.Stacks[st].side, gpa, rgpa, sgpa, madsci)
        else begin
          gpa := basegpa;
          rgpa := basergpa;
          sgpa := basesgpa;
        end;
      end;

    procedure FindDist;
      var
        fspeed: integer;
        divdown: integer;
      begin
        fspeed := c^.EffSpeed(st, true, true) div 10;
        if fspeed > 0 then begin
          if CombatMap[Stacks[st].x, Stacks[st].y] = cmWater then
            divdown := 1
          else
            divdown := fspeed;
          if rgpa < 0 then begin
            dist := c^.DistanceToClosestEnemy(st, true, false);
            if dist = MaxInt - 2 then begin
              dist := c^.DistanceToClosestEnemy(st, false, false);
              divdown := divdown div 2;
              if divdown < 1 then divdown := 1;
            end;
          end else begin
            dist := c^.DistanceToClosestEnemy(st, false, false);
          end;
          dist := dist div divdown;
        end else
          dist := MaxInt;
      end;

    procedure FindAttGP;
      begin
        attgp := c^.BoardValue(c^.Stacks[st].side);
      end;

    procedure FindCenter;
      var cen: integer;
      begin
        cen := -(Sqr(movx - CombatXMax div 2) + Sqr(movy - CombatYMax div 2));
        if CombatMap[movx, movy] = cmWater then
          dec(cen, 100);
        center := cen;
      end;

    procedure UsePlay;
      begin
        FindGPA;
        FindDist;
        FindAttGP;
        FindCenter;

        bestgpa := gpa;
        bestdist := dist;
        bestattgp := attgp;
        bestcenter := center;
        bestmx := movx;
        bestmy := movy;
        bestax := attx;
        bestay := atty;
        bestatt := att;
        bestwhirl := whirl;
        bestsgpa := sgpa;
      end;

    begin
      if (attx = -1) and desperate and not EffFlag(st, 5, f5Makesguys) then
        att := 0
      else
        att := 1;

      if freewhirly then FindGPA;

      if not freewhirly
         or ((movx = Stacks[st].x) and (movy = Stacks[st].y)
             and (attx <> -1) and (gpa >= basegpa)) then
        whirl := 1
      else
        whirl := 0;

      if whirl > bestwhirl then UsePlay
      else if whirl = bestwhirl then begin
        if att > bestatt then UsePlay
        else if att = bestatt then begin
          if not freewhirly then FindGPA;
          if gpa > bestgpa then UsePlay
          else if gpa = bestgpa then begin
            if EffFlag(st, 1, f1RealRange) or (rgpa > 0)
               or EffFlag(st, 5, f5MakesGuys)
               or ((bestgpa > {0}basegpa) and (bestax <> -1)) then begin
              if sgpa > bestsgpa then UsePlay { !X! }
              else begin
                FindAttGP;
                if attgp > bestattgp then UsePlay;
              end;
            end else begin
              FindDist;
              if dist < bestdist then UsePlay
              else if dist = bestdist then begin
                if sgpa > bestsgpa then UsePlay  { !X! }
                else begin
                  FindAttGP;
                  if attgp > bestattgp then UsePlay
                  else if attgp = bestattgp then begin
                    FindCenter;
                    if center > bestcenter then UsePlay;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

  procedure TryMove(m, n: integer);
    var
      p: PCombat;
      st2, a, b, h, tx, ty: integer;

    procedure TryAttack(x, y: integer);
      var q: PCombat;
      begin
        if p^.CanAttack(st, x, y) then begin
          q := p^.Spawn;
          q^.Attack(st, x, y);

          if (q^.Stacks[st].morale = 1)
             or (q^.Stacks[st].whirly = 1) then begin
            q^.Stacks[st].moved := false;
            q^.Stacks[st].done := false;
            q^.Stacks[st].canshoot := false;
          end;

          AssessPlay(q, m, n, x, y);
          Dispose(q, Done);
        end;
      end;

    begin
      p := Spawn;
      if (Shadow[m, n] > 0)
         and ((Stacks[st].x <> m) or (Stacks[st].y <> n)) then
        p^.MoveStack(st, m, n, false);

      if EffFlag(st, 1, f1AnyRange) and Stacks[st].canshoot then begin
        for a := 1 to CombatXMax do
          for b := 1 to CombatYMax do
            if Targets[a, b] > 0 then
              TryAttack(a, b);
      end else begin
        for h := 1 to 6 do
          if FindAdjHex(h, m, n, tx, ty) then
            if Targets[tx, ty] > 0 then
              TryAttack(tx, ty);
      end;

      p^.StackPassTurn(st);
      AssessPlay(p, m, n, -1, -1);

      Dispose(p, Done);
    end;

  var
    i, j: integer;
    tb: boolean;
  begin
    sid := Stacks[st].side;
    freewhirly := EffFlag(st, 2, f2AttMoveAtt) and not Stacks[st].moved
                  and (Stacks[st].whirly = 0);
    desperate := FindBestFutureAttackGold(st) = 0;
    madsci := EffFlag(st, 2, f2Devolve);
    bestmx := -1;
    bestax := -1;

    tb := Stacks[st].Done;
    Stacks[st].Done := true;
    GoldPieceAdvantage(sid, basegpa, basergpa, basesgpa, madsci);
    Stacks[st].Done := tb;

    CalcAttackMoves(st);
    bestgpa := -MaxLongInt;
    bestattgp := -MaxLongInt;
    bestdist := MaxInt;
    bestcenter := -MaxInt;
    bestsgpa := -MaxLongInt;
    if desperate then bestatt := 0 else bestatt := 1;
    if freewhirly then bestwhirl := 0 else bestwhirl := 1;

    mustcalcgpa := (CombatMap[Stacks[st].x, Stacks[st].y] = cmFire)
                   or EffFlag(st, 1, f1Steamroll)
                   or EffFlag(st, 3, f3SlimeTrail)
                   or EffFlag(st, 4, f4FireTrail)
                   or EffFlag(st, 5, f5MakesGuys);

    TryMove(Stacks[st].x, Stacks[st].y);

    if not Stacks[st].moved then begin
      { check real attacks first to seed bestgpa }
      { stops it from wasting calc time on moves that don't get +gpa }

      for i := 1 to CombatXMax do
        for j := 1 to CombatYMax do
          if AttackMoves[i, j] > 0 then
            TryMove(i, j);

      { now check non-attacks if necessary }

      if (bestgpa <= basegpa) or mustcalcgpa then
        for i := 1 to CombatXMax do
          for j := 1 to CombatYMax do
            if (Shadow[i, j] > 0) and (AttackMoves[i, j] = 0) then
              TryMove(i, j);
    end;
  end;

procedure TCombat.AITurn(st: integer);
  var mx, my, ax, ay: integer;
  begin
    repeat
      ShowStackStats(st, 1, 0);
      Highlight(Stacks[st].x, Stacks[st].y, false, actual);
      Refresh;
      MakeShadow(st, true, false);
      GetGoodAIMove(st, mx, my, ax, ay);
      Unhighlight(Stacks[st].x, Stacks[st].y);
      DrawCombatHex(Stacks[st].x, Stacks[st].y);
      if mx <> -1 then begin
        if (Shadow[mx, my] > 0)
           and ((mx <> Stacks[st].x) or (my <> Stacks[st].y)) then
          MoveStack(st, mx, my, false);
        if ax <> -1 then
          Attack(st, ax, ay)
        else
          StackPassTurn(st);
      end else
        StackDone(st);
    until Stacks[st].done;
  end;

procedure TCombat.GetAIBestShot(side, dmg: integer;
                                var bestax, bestay: integer);
  var
    i, j: integer;
    g, bestgpa, bestattgp: longint;

  procedure AssessPlay(c: PCombat; attx, atty: integer);
    var gpa, attgp: longint;

    procedure UsePlay;
      begin
        bestgpa := gpa;
        bestattgp := attgp;
        bestax := attx;
        bestay := atty;
      end;

    begin
      c^.FastGPA(side, gpa);
      attgp := c^.BoardValue(side);
      if gpa > bestgpa then UsePlay
      else if gpa = bestgpa then begin
        if attgp > bestattgp then UsePlay;
      end;
    end;

  procedure TryAttack(x, y: integer);
    var p: PCombat;
    begin
      p := Spawn;
      p^.HeroAttackHex(side, x, y, dmg, 0);
      AssessPlay(p, x, y);
      Dispose(p, Done);
    end;

  begin
    bestax := -1;
    bestgpa := -MaxLongInt;
    bestattgp := -MaxLongInt;

    for i := 1 to LastStack do
      if (Stacks[i].qty > 0) and (Stacks[i].side <> side) then
        TryAttack(Stacks[i].x, Stacks[i].y);
  end;

procedure TCombat.BarbicanTurn(x, y: integer);
  var ax, ay: integer;
  begin
    Highlight(x, y, false, actual);
    Refresh;
    GetAIBestShot(2, cBarbicanDamage, ax, ay);
    Unhighlight(x, y);
    DrawCombatHex(x, y);
    if ax <> -1 then HeroAttackHex(2, ax, ay, cBarbicanDamage, clArrowTower);
  end;

procedure TCombat.HideIllusionist(st: integer);
  var i, ist1, ist2, newst, x, y: integer;
  begin
    ist1 := 0;
    ist2 := 0;
    for i := 1 to LastStack do
      if (Stacks[i].qty > 0) and (Stacks[i].illusion = st) then begin
        if ist1 = 0 then
          ist1 := i
        else
         ist2 := i;
      end;
    newst := st;
    i := random(100);
    if (ist1 <> 0) and (ist2 = 0) and (i < 50) then
      newst := ist1
    else if ist2 <> 0 then begin
      if i < 33 then newst := ist1
      else if i > 67 then newst := ist2;
    end;
    if newst <> st then begin
      x := Stacks[newst].x;
      y := Stacks[newst].y;
      Stacks[newst].x := Stacks[st].x;
      Stacks[newst].y := Stacks[st].y;
      Stacks[st].x := x;
      Stacks[st].y := y;
      StacksGrid[Stacks[st].x, Stacks[st].y] := st;
      StacksGrid[Stacks[newst].x, Stacks[newst].y] := newst;
      if TrackedStack = st then TrackedStack := newst
      else if TrackedStack = newst then TrackedStack := st;
    end;
  end;

function TCombat.HealStack(st, hdmg: integer): boolean;
  var
    eh: integer;
    healed: boolean;
  begin
    with Stacks[st] do begin
      eh := EffHp(st);
      healed := tophp <> eh;

      if hdmg = -1 then
        tophp := eh
      else begin
        inc(tophp, hdmg);
        if tophp > eh then
          tophp := eh;
      end;

      if healed then begin
        DrawFX(x, y, fxHeal, true);
        UpdateStack(st);
        Refresh;
      end;

      HealStack := healed;
    end;
  end;

procedure TCombat.TakeTurn(st: integer);
  var
    killed: boolean;
    h, healing, tx, ty: integer;

  procedure RefreshStack;
    begin
      with Stacks[st] do begin
        moved := false;
        done := false;
        canshoot := true;
        NumAttacks := 0;
      end;
    end;

  begin
    if (Stacks[st].illusion <> 0) and actual then begin
      Stacks[st].moved := true;
      Stacks[st].done := true;
    end else begin
      h := SV[Stacks[st].side].Dude;

      if Stacks[st].tophp <> Effhp(st) then begin
        healing := TroopsWithFlag(Stacks[st].side, 6, f6Healing);
        if h <> 0 then
          inc(healing, GetEffSkillLevel(h, skHealing) * cHealDamage);
        if healing > 0 then
          HealStack(st, healing);
      end;

      killed := false;

      if (CombatMap[Stacks[st].x, Stacks[st].y] = cmFire)
         and not EffFlag(st, 4, f4FireImmune) then
        killed := LoggedDamageStack(st, cFireDamage, false, clFire);

      if not killed and (Stacks[st].poison > 0) then
        killed := LoggedDamageStack(st, Stacks[st].poison, false, clPoison);

      if killed or (Stacks[st].qty = 0) then begin
        StackDone(st);
      end else begin
        if Stacks[st].stunned > 0 then begin
          Stacks[st].moved := true;
          Stacks[st].stunned := 1;
        end;

        if EffFlag(st, 3, f3Bless) then
          WandSpell(Stacks[st].side, 0, slGood, ord(MonsterChr(st)), false);

        if EffFlag(st, 5, f5SuperBless) then
          WandSpell(Stacks[st].side, 0, slGood, ord(MonsterChr(st)), true);

        if not over then begin
          if not actual or SV[Stacks[st].side].AI then
            AITurn(st)
          else
            PlayerTurn(st);
        end;

        if Stacks[st].stunned > 0 then begin
          dec(Stacks[st].stunned);
          if Stacks[st].stunned = 0 then
            DrawCombatHex(Stacks[st].x, Stacks[st].y);
        end;

        if Stacks[st].done or (EffFlag(st, 5, f5ThreeAttacks)
                              and (Stacks[st].NumAttacks >= 3)) then begin
          if Stacks[st].morale = 1 then begin
            Stacks[st].morale := 2;
            RefreshStack;
          end else if Stacks[st].whirly = 1 then begin
            Stacks[st].whirly := 2;
            RefreshStack;
          end else if Stacks[st].renew > 0 then begin
            dec(Stacks[st].renew);
            RefreshStack;
            DrawCombatHex(Stacks[st].x, Stacks[st].y);
          end;
        end;

        if EffFlag(st, 3, f3Illusionist) then
          HideIllusionist(st);
      end;
    end;
  end;

procedure TCombat.HeroAttackHex(side, x, y, dmg, cl: integer);
  var st2: integer;
  begin
    st2 := StacksGrid[x, y];

    if st2 <> 0 then begin
      LoggedDamageStack(st2, dmg, false, cl);
      DrawCombatHex(x, y);
    end;
  end;

procedure TCombat.GetClick(hx, hy: integer; var cx, cy: integer;
                           side, attingst: integer);
  var
    x, y, i, slot, HoverX, HoverY: integer;
    E: TEvent;
    got: boolean;
    NewHoverShadow: TShadow;

  procedure ShowHint(s: string);
    begin
      BaseDialog(s, 0, 0, 0, 0, '', '', '', '');
      ClearScr;
      DrawCombatScreen;
      if TopStatsStack = 0 then
        ShowHeroStats(side, TopStatsSP)
      else
        ShowStackStats(TopStatsStack, 1, -1);
      if TrackedStack = 0 then
        DrawCombatLog
      else
        UpdateTrackedStack;
      ShowAttMoveChoice;
    end;

  procedure DoHoverHighlighting;
    var
      p: PCombat;
      i, j: integer;
      ok: boolean;

    procedure CheckForHitStacks;
      var i: integer;
      begin
        for i := 1 to LastStack do
          if Stacks[i].qty <> 0 then
            if (Stacks[i].qty > p^.Stacks[i].qty)
               or ((Stacks[i].qty = p^.Stacks[i].qty)
                   and (Stacks[i].tophp > p^.Stacks[i].tophp))
               or (Stacks[i].side <> p^.Stacks[i].side)
               or ((CombatMap[Stacks[i].x, Stacks[i].y]
                    in [cmFire, cmWater])
                   <> (p^.CombatMap[p^.Stacks[i].x, p^.Stacks[i].y]
                       in [cmFire, cmWater])) then
              NewHoverShadow[Stacks[i].x, Stacks[i].y] := 1
      end;

    begin
      XGetMouseEvent(E);
      x := E.Where.X;
      y := E.Where.Y;
      PointToGrid(x, y);
      FillChar(NewHoverShadow, sizeof(NewHoverShadow), #0);

      if OnGrid(x, y) then begin
        if CanAttack(attingst, x, y) then begin
          p := Spawn;
          p^.Attack(attingst, x, y);
          CheckForHitStacks;
          Dispose(p, Done);
        end;

        if (EffFlag(attingst, 1, f1SteamRoll)
            or (EffFlag(attingst, 1, f1Fly)
                and (EffFlag(attingst, 3, f3SlimeTrail)
                     or EffFlag(attingst, 4, f4FireTrail))))
           and (Shadow[x, y] > 0)
           and not Stacks[attingst].moved then begin
          p := Spawn;
          p^.MoveStack(attingst, x, y, false);
          CheckForHitStacks;
          Dispose(p, Done);
        end;
      end;

      ok := true;

      for i := 1 to CombatXMax do
        for j := 1 to CombatYMax do
          if HoverShadow[i, j] <> NewHoverShadow[i, j] then begin
            if (HoverX <> x) or (HoverY <> y) then begin
              HoverShadow[i, j] := NewHoverShadow[i, j];
              DrawCombatHex(i, j);
              ok := false;
            end else if HoverShadow[i, j] <> 2 then begin
              HoverShadow[i, j] := 2;
              DrawCombatHex(i, j);
              ok := false;
            end;
          end;

      if not ok then begin
        ShowAttMoveChoice;
        Refresh;
      end;

      HoverX := x;
      HoverY := y;
    end;

  procedure EraseHoverHighlighting;
    var i, j: integer;
    begin
      for i := 1 to CombatXMax do
        for j := 1 to CombatYMax do
          if HoverShadow[i, j] <> 0 then begin
            HoverShadow[i, j] := 0;
            DrawCombatHex(i, j);
          end;
    end;

  begin
    got := false;
    cx := -1;
    FillChar(HoverShadow, sizeof(HoverShadow), #0);
    HoverX := 0;

    repeat
      Refresh;
      repeat
        Highlight(hx, hy, true, actual);
        GetEvent(E);
        if (E.What = evNothing) and (attingst <> 0) then
          DoHoverHighlighting;
      until (E.What <> evNothing);
      EraseHoverHighlighting;
      Refresh;
      if (E.What = evKeyDown) and (E.CharCode = #27) then begin
        over := true;
        for i := 1 to StackMax do
          if (Stacks[i].qty > 0) and (Stacks[i].side = side) then
            Stacks[i].qty := 0;
      end;
      if E.What = evMouseDown then begin
        if E.Buttons = mbLeftButton then begin
          cx := E.Where.X;
          cy := E.Where.Y;
          got := true;
        end else if E.Buttons = mbRightButton then begin
          x := E.Where.X;
          y := E.Where.Y;
          PointToGrid(x, y);
          if OnGrid(x, y) then begin
            if StacksGrid[x, y] <> 0 then begin
              TrackedStack := StacksGrid[x, y];
              UpdateTrackedStack;
            end else
              ClearTrackedStack;
          end else if ((x = 14) or (x = 16)) and (y = 4) then begin
            if x = 14 then
              TrackedStack := -1
            else
              TrackedStack := -2;
            UpdateTrackedStack;
          end else begin
            x := E.Where.X;
            y := E.Where.Y;
            if (TopStatsStack = 0) and (TopStatsSP >= 128)
               and (x >= 468) and (x < 468 + 8 * 12)
               and (y >= 243) and (y < 243 + 8 * 13) then begin
              y := (y - 243) div 13;
              if (TopStatsSP - 128 + y <= NumSpells)
                 and (SpellList[TopStatsSP - 128 + y] <> 0) then
                ShowHint(SpellHintStr(SpellList[TopStatsSP - 128 + y],
                                      SV[side].Dude, 0));
            end else if x >= 468 then begin
              if y >= 9 * 40 + 43 then begin
                slot := 2;
                y := (y - (9 * 40 + 43)) div 13;
              end else if y >= 5 * 40 + 43 then begin
                slot := 1;
                y := (y - (5 * 40 + 43)) div 13;
              end else
                slot := 0;
              if (slot <> 0) and (y <= 5) and (StatHints^[slot, y] <> '') then
                if StatHints^[slot, y] = 'More' then begin
                  inc(SlotTop[slot], 5);
                  if slot = 1 then
                    ShowStackStats(TopStatsStack, 1, -1)
                  else
                    UpdateTrackedStack;
                end else
                  ShowHint(StatHints^[slot, y]);
            end;
          end;
        end;
      end;
    until got or over;

    FillChar(HoverShadow, sizeof(HoverShadow), #0);
  end;

function TCombat.TargetOK(side, kind, x, y: integer): boolean;
  var ok: boolean;
  begin
    ok := false;
    case kind of
      hptAny:    ok := true;
      hptEmpty:  ok := HexEmpty(x, y);
      hptFriend: ok := (StacksGrid[x, y] <> 0)
                       and (Stacks[StacksGrid[x, y]].side = side);
      hptEnemy:  ok := (StacksGrid[x, y] <> 0)
                       and (Stacks[StacksGrid[x, y]].side <> side);
      hptStack:  ok := StacksGrid[x, y] <> 0;
    end;
    TargetOK := ok;
  end;

procedure TCombat.HeroPickTarget(side, kind: integer; var tx, ty: integer);
  var
    x, y: integer;
    got: boolean;
  begin
    got := false;
    repeat
      GetClick(14, 6, x, y, side, 0);
      if x = -1 then
        tx := 0
      else begin
        PointToGrid(x, y);
        if OnGrid(x, y) then begin
          if TargetOK(side, kind, x, y) then begin
            tx := x;
            ty := y;
            got := true;
          end;
        end else if (x = 15) and (y = 2) then begin
          tx := 0;
          got := true;
        end;
      end;
    until got or over;
  end;

procedure TCombat.AIPickTarget(side, kind, sp, value, dur, maxt: integer;
                               var tx, ty: integer);
  var
    x, y, i, st, tries: integer;
    ok: boolean;
    p: PCombat;
    gpa, attgp, bestgpa, bestattgp: longint;
  begin
    if (sp = spMindBlank) or ((sp = spGrenade) and not actual) then
      kind := hptEnemy
    else if sp = spFly then
      kind := hptFriend;

    HighlightAwhile(14, 6, actual);

    tx := 0;
    bestgpa := -MaxLongInt;
    bestattgp := -MaxLongInt;
    value := (value + maxt - 1) div maxt;
    tries := 0;

    for x := 1 to CombatXMax do
      for y := 1 to CombatYMax do
        if TargetOK(side, kind, x, y) then begin
          ok := true;
          for i := 1 to high(SpellTargets) do
            if (SpellTargets[i].x = x) and (SpellTargets[i].y = y) then
              ok := false;
          st := StacksGrid[x, y];
          if (st <> 0) and (Stacks[st].numsfx > 0) then
            for i := 1 to MaxSFX do
              if Stacks[st].SFX[i].sp = sp then
                ok := false;
          if ok then begin
            inc(tries);
            if actual or (tries mod ((LastStack + 11) div 12) = 0) then begin
              p := Spawn;
              p^.CastSpellOn(side, sp, x, y, value, dur);
              p^.FastGPA(side, gpa);
              if gpa >= bestgpa then begin
                attgp := p^.BoardValue(side);
                if (gpa > bestgpa) or (attgp > bestattgp) then begin
                  bestgpa := gpa;
                  bestattgp := attgp;
                  tx := x;
                  ty := y;
                end;
              end;
              Dispose(p, Done);
            end;
          end;
        end;
  end;

procedure TCombat.AIPickDest(side, sp, value: integer; var tx, ty: integer);
  var
    x, y: integer;
    p: PCombat;
    gpa, attgp, bestgpa, bestattgp: longint;
  begin
    if not actual then begin
      GetRandomEmptyHex(tx, ty);
    end else begin
      HighlightAwhile(14, 6, actual);

      tx := 0;
      bestgpa := -MaxLongInt;
      bestattgp := -MaxLongInt;

      for x := 1 to CombatXMax do
        for y := 1 to CombatYMax do
          if ((tx = 0) or (random(4) = 0)) and HexEmpty(x, y) then begin
            p := Spawn;
            case sp of
              spConjure:  p^.AddStack(x, y, side, moBunny, value, 0, 0);
              spSummon:   p^.AddStack(x, y, side, moHorror, value, 0, 0);
            end;
            p^.FastGPA(side, gpa);
            if gpa >= bestgpa then begin
              attgp := p^.BoardValue(side);
              if (gpa > bestgpa) or (attgp > bestattgp) then begin
                bestgpa := gpa;
                bestattgp := attgp;
                tx := x;
                ty := y;
              end;
            end;
            Dispose(p, Done);
          end;
    end;
  end;

function TCombat.EstimatedCombatLength: integer;
  var
    i: integer;
    hp: array [1..2] of longint;
    len: real;
  begin
    hp[1] := 0;
    hp[2] := 0;
    for i := 1 to LastStack do
      if Stacks[i].qty > 0 then
        inc(hp[Stacks[i].side], longint(Stacks[i].qty) * EffHp(i));

    len := hp[1] / hp[2];
    if len < 1 then len := 1 / len;
    len := ln(len) / ln(2);                        { log2 len }
    if len = 0 then len := 16 else len := 4 / len;
    if len < 1 then len := 1;
    if len > 16 then len := 16;

    EstimatedCombatLength := round(len);
  end;

function TCombat.AIPickSpell(side: integer): integer;
  var
    i, ps, bestps, numAIstacks, numhumanstacks, dur: integer;
    len, spperround, sorc: integer;
    score, bestscore, basegpa, baseattgp: longint;
    p: PCombat;

  function CalcScore(c: PCombat; sp: integer): longint;
    var attgp, gpa, score: longint;
    begin
      c^.FastGPA(side, gpa);
      attgp := c^.BoardValue(side);
      score := (gpa - basegpa) + (attgp - baseattgp) div 2;
      if SpellData[sp].duration then
        score := score * dur;
      if SpellData[sp].targets then
        score := score * sorc;
      score := score * spperround div SpellData[sp].cost;
      if (sp = spConjure) or (sp = spSummon) then begin
        if numAIstacks >= 8 then
          score := score div numAIstacks
        else
          score := score div 2;
      end;
      CalcScore := score;
    end;

  begin
    ShowHeroStats(side, 126);
    HighlightAwhile(14, 6, actual);

    numAIstacks := 0;
    numhumanstacks := 0;
    for i := 1 to LastStack do
      if (Stacks[i].qty > 0) then
        if Stacks[i].side = side then
          inc(numAIstacks)
        else
          inc(numhumanstacks);
    len := EstimatedCombatLength;
    spperround := HeroSPPerRound(SV[side].Dude);

    FastGPA(side, basegpa);
    baseattgp := BoardValue(side);
    bestps := 0;
    bestscore := 0;

    for i := 1 to NumSpells do begin
      ps := SpellList[i];
      if ps <> 0 then begin
        dur := HeroSpellDur(SV[side].Dude, ps);
        if dur > len then dur := len;
        sorc := SpellMaxTargets(ps, SV[side].Dude);
        if sorc > numhumanstacks then sorc := numhumanstacks;
        DrawText(468 + 40, 200 + 18, colBlack, colLightGray,
                 LSet(SpellData[ps].name + '?', 13));
        Refresh;
        p := Spawn;
        p^.CastSpell(side, ps);
        score := CalcScore(p, ps);
        if score > bestscore then begin
          bestscore := score;
          bestps := ps;
        end;

        Dispose(p, Done);
      end;
    end;

    AIPickSpell := bestps;
  end;

function TCombat.PickSpell(side: integer): integer;
  var x, y, ax, ay, ps, topsp: integer;
  begin
    ps := -1;
    topsp := 1;

    repeat
      ShowHeroStats(side, 128 + topsp);
      GetClick(14, 6, ax, ay, side, 0);
      if ax <> -1 then begin
        x := ax;
        y := ay;
        PointToGrid(x, y);
        if (x = 15) and (y = 2) then begin
          ps := 0;
        end else begin
          if (ax >= 468 + 40) and (ax < 468 + 40 + 13 * 8)
             and (ay >= 200 + 8) and (ay < 200 + 8 + 8) then begin
            inc(topsp, 8);
            if (topsp > NumSpells) or (SpellList[topsp] = 0) then
              topsp := 1;
          end else if (ax >= 468) and (ax < 468 + 8 * 12)
                      and (ay >= 243) and (ay < 243 + 8 * 13) then begin
            ay := (ay - 243) div 13;
            if (topsp + ay <= NumSpells)
               and (SpellList[topsp + ay] <> 0) then begin
              ps := SpellList[topsp + ay];
            end;
          end;
        end;
      end;
    until (ps <> -1) or over;

    if over then ps := 0;

    PickSpell := ps;
  end;

procedure TCombat.AddSFX(st, sp, v, dur, iside: integer);
  var
    i, fhp1, fhp2: integer;
    got: boolean;
  begin
    with Stacks[st] do begin
      got := false;
      fhp1 := EffHp(st);

      for i := 1 to MaxSFX do
        if not got and (sfx[i].sp = 0) then begin
          sfx[i].sp := sp;
          sfx[i].v := v;
          sfx[i].dur := dur;
          sfx[i].side := iside;
          inc(numsfx);
          got := true;
        end;

      if got then begin
        fhp2 := EffHp(st);
        if fhp1 <> fhp2 then begin
          tophp := round(tophp / fhp1 * fhp2);
          if tophp < 1 then tophp := 1;
          if tophp > fhp2 then tophp := fhp2;
        end;
        UpdateStack(st);
      end;
    end;
  end;

procedure TCombat.RemoveSFX(st, sp: integer);
  var i: integer;
  begin
    if st <> 0 then
      for i := 1 to MaxSFX do
        if Stacks[st].sfx[i].sp = sp then
          Remove1SFX(st, i);
  end;

procedure TCombat.Remove1SFX(st, fx: integer);
  var r: real;
  begin
    with Stacks[st] do begin
      r := tophp / EffHp(st);
      case sfx[fx].sp of
        spPolymorph:  VolveStack(st, 1);
        spShapeshift: VolveStack(st, -1);
      end;
      sfx[fx].sp := 0;
      dec(numsfx);
      tophp := round(r * EffHp(st));
      if tophp > hp then
        tophp := hp;
      if tophp < 1 then
        tophp := 1;
      UpdateStack(st);
    end;
  end;

procedure TCombat.SpellWasCast(side, sp, cl: integer);
  var st, n, kills, k: integer;
  begin
    AddLogLine(chr(cl) + ' casts ' + SpellData[sp].name);

    for st := 1 to LastStack do
      if EffFlag(st, 3, f3LikesSpells) then begin
        inc(Stacks[st].spin);
        UpdateStack(st);
      end;

    if SV[side].Dude <> 0 then begin
      n := CountArt(SV[side].Dude, anWandOfDesertion, true);
      if n <> 0 then begin
        MarkStacksOnSide(3 - side);
        k := 0;
        for st := 1 to LastStack do
          if Stacks[st].marked and (Stacks[st].qty > 0)
             and (Stacks[st].side <> side) then
            inc(k);
        AddLogLine(chr(clWandofDesertion) + ' kills ' + IStr(k * n, 0)
                   + ' creatures');
        for st := 1 to LastStack do
          if Stacks[st].marked and (Stacks[st].qty > 0)
             and (Stacks[st].side <> side) then begin
            DrawFX(Stacks[st].x, Stacks[st].y, fxCast, true);
            Traitors(st, 0, n);
            DrawCombatHex(Stacks[st].x, Stacks[st].y);
          end;
        CheckIfOver;
      end;
      n := CountArt(SV[side].Dude, anWandOfPain, true);
      if n <> 0 then begin
        AddLogLine(chr(clWandofPain) + ' deals ' + IStr(n * 25, 0) + ' '
                   + chr(clDamage));
        MarkStacksOnSide(3 - side);
        for st := 1 to LastStack do
          if Stacks[st].marked and (Stacks[st].qty > 0)
             and (Stacks[st].side <> side) then
            DamageStack(st, n * 25, false, kills);
        CheckIfOver;
      end;
      n := CountArt(SV[side].Dude, anWandOfHealth, true);
      if n <> 0 then begin
        AddLogLine(chr(clWandofHealth) + ' heals ' + IStr(n * 25, 0));
        for st := 1 to LastStack do
          if (Stacks[st].qty > 0) and (Stacks[st].side = side) then
            HealStack(st, n * 25);
      end;
    end;

    Refresh;
  end;

procedure TCombat.RemoveAllStatSpells(st: integer);
  begin
    RemoveSFX(st, spJoy);
    RemoveSFX(st, spWoe);
    RemoveSFX(st, spGrow);
    RemoveSFX(st, spShrink);
    RemoveSFX(st, spAgility);
    RemoveSFX(st, spFatigue);
    RemoveSFX(st, spFury);
    RemoveSFX(st, spWeakness);
  end;

procedure TCombat.CastNoTarget(side, sp, value, dur: integer);
  var
    i, h, tx, ty, cl, kills: integer;
  begin
    case sp of
      spFireShield: for i := 1 to LastStack do
                      if (Stacks[i].qty > 0) and (Stacks[i].side = side) then
                        for h := 1 to 6 do
                          if FindAdjHex(h, Stacks[i].x, Stacks[i].y,
                                        tx, ty) then
                            if ((StacksGrid[tx, ty] = 0)
                                or (Stacks[StacksGrid[tx, ty]].side <> side))
                               and (CombatMap[tx, ty] <= cmEmptyMax) then
                              MakeObstacle(tx, ty, cmFire);
      spWoe, spJoy: for i := 1 to LastStack do
                      if (((sp = spWoe) and (Stacks[i].side <> side))
                          or ((sp = spJoy)
                              and ((Stacks[i].side = side)
                                   or EffFlag(i, 5, f5CopiesSpells))))
                         and (Stacks[i].qty > 0) then begin
                        RemoveAllStatSpells(i);
                        AddSFX(i, sp, value, dur, side);
                        DrawFX(Stacks[i].x, Stacks[i].y, fxCast, true);
                        DrawCombatHex(Stacks[i].x, Stacks[i].y);
                      end;
      spMentalBlast: begin
                       MarkStacksOnSide(3 - side);
                       for i := 1 to LastStack do
                         if Stacks[i].marked and (Stacks[i].qty > 0)
                            and (Stacks[i].side <> side) then
                           DamageStack(i, value, false, kills);
                     end;
      spInferno:    begin
                      MarkStacksOnSide(3 - side);
                      for i := 1 to LastStack do
                        if Stacks[i].marked and (Stacks[i].qty > 0)
                           and (Stacks[i].side <> side) then begin
                          DamageStack(i, value, false, kills);
                          MakeObstacle(Stacks[i].x, Stacks[i].y, cmFire);
                        end;
                    end;
      spConjure,
      spSummon:     begin
                      ShowHeroStats(side, 127);
                      if SV[side].AI then
                        AIPickDest(side, sp, value, tx, ty)
                      else
                        HeroPickTarget(side, hptEmpty, tx, ty);
                      if tx <> 0 then begin
                        if sp = spConjure then
                          AddStack(tx, ty, side, moBunny, value, 0, 0)
                        else
                          AddStack(tx, ty, side, random(8)*6+3, value, 0, 0);
                        DrawCombatHex(tx, ty);
                      end;
                    end;
    end;

    if side = 1 then cl := clHero1 else cl := clHero2;
    SpellWasCast(side, sp, cl);

    CheckIfOver;
  end;

procedure TCombat.BlowStack(st, dir, num: integer);
  var i, tx, ty, w: integer;
  begin
    for i := 1 to num do begin
      tx := Stacks[st].x + dir;
      ty := Stacks[st].y;
      if (tx >= 1) and (tx <= CombatXMax) and HexEmpty(tx, ty) then begin
        MoveStack(st, tx, ty, true);
        if actual then begin
          DrawCombatHex(Stacks[st].x, Stacks[st].y);
          for w := 1 to BlowDelay do Refresh;
        end;
      end;
    end;
  end;

procedure TCombat.Traitors(st, side, qty: integer);
  var st2: integer;
  begin
    if side = 0 then begin
      if Stacks[st].qty > qty then
        dec(Stacks[st].qty, qty)
      else
        KillStack(st);
    end else if Stacks[st].qty <= qty then begin
      Stacks[st].side := side;
      Stacks[st].armyslot := -1;
      for st2 := 1 to LastStack do
        if Stacks[st2].illusion = st then
          Stacks[st2].side := side;
    end else begin
      st2 := SplitStack(st, side, qty);
      if st2 <> 0 then begin
        Stacks[st2].tophp := Stacks[st].tophp;
        Stacks[st].tophp := EffHp(st);
        Stacks[st2].armyslot := -1;
      end else
        dec(Stacks[st].qty, qty);
    end;
  end;

procedure TCombat.HealSpell(st: integer);
  var
    fx: integer;
    healed: boolean;
  begin
    with Stacks[st] do begin
      for fx := 1 to MaxSFX do
        if (sfx[fx].sp > 0)
           and (sfx[fx].side <> side) then
          Remove1SFX(st, fx);
      hexed := false;
      diseased := false;
      stunned := 0;
      poison := 0;
      healed := false;
      if qty < maxqty then begin
        inc(qty);
        healed := true;
      end;
      if HealStack(st, -1) then healed := true;
      if healed then DrawFX(x, y, fxCast, true);
      DrawCombatHex(x, y);
    end;
  end;

procedure TCombat.CastSpellOn(side, sp, x, y, value, dur: integer);
  const
    CopyingSpells: boolean = false;
  var
    st, i, n, h, tx, ty, st2, kills, iside: integer;
    nofx: boolean;

  procedure RemoveSFXJW(sp: integer);
    begin
      RemoveSFX(st, sp);
      RemoveSFX(st, spJoy);
      RemoveSFX(st, spWoe);
    end;

  begin
    nofx := false;
    st := StacksGrid[x, y];

    if (st <> 0) and (Stacks[st].illusion <> 0) and actual
       and not (sp in [spZap, spSwarm, spFireBolt, spMudBall,
                       spIceBolt, spGrenade, spKill]) then begin
      { non-damage spell on illusion does nothing }
    end else if (st <> 0) or (sp = spGrenade) then begin
      iside := Stacks[st].side;

      if SpellData[sp].duration then
        RemoveSFX(st, sp);

      if (side <> iside) and (SV[side].Dude <> 0)
         and HeroHasExpertiseBonus(SV[side].Dude, skPower) then
        Stacks[st].hexed := true;

      case sp of
        spZap:          DamageStack(st, value, false, kills);
        spHeal:         HealSpell(st);
        spRenew:        begin
                          HealSpell(st);
                          if Stacks[st].done then begin
                            Stacks[st].done := false;
                            Stacks[st].moved := false;
                            Stacks[st].canshoot := true;
                          end else
                            inc(Stacks[st].renew);
                        end;
        spBadLuck:      RemoveSFX(st, spGoodLuck);
        spGoodLuck:     RemoveSFX(st, spBadLuck);
        spSwarm:        DamageStack(st, value, false, kills);
        spGrow:         RemoveSFXJW(spShrink);
        spBlow:         begin
                          if side = 1 then n := 1 else n := -1;
                          BlowStack(st, n, 3);
                        end;
        spTraitor:      Traitors(st, side, 1);
        spFury:         RemoveSFXJW(spWeakness);
        spFly:          ;
        spFireBolt:     begin
                          DamageStack(st, value, false, kills);
                          MakeObstacle(x, y, cmFire);
                        end;
        spDeserter:     Traitors(st, 0, 1);
        spMindBlank:    ;
        spMudBall:      begin
                          DamageStack(st, value, false, kills);
                          MakeObstacle(x, y, cmWater);
                        end;
        spShrink:       RemoveSFXJW(spGrow);
        spAgility:      RemoveSFXJW(spFatigue);
        spWeakness:     RemoveSFXJW(spFury);
        spIceBolt:      DamageStack(st, value, false, kills);
        spSicken:       begin
                          Stacks[st].stunned := 1;
                          Stacks[st].diseased := true;
                        end;
        spMagicBow:     ;
        spGrenade:      begin
                          if st <> 0 then DamageStack(st, value, false, kills);
                          RemoveObstacle(x, y);
                          for h := 1 to 6 do
                            if FindAdjHex(h, x, y, tx, ty) then begin
                              if (StacksGrid[tx, ty] <> 0) then
                                DamageStack(StacksGrid[tx, ty], value, false,
                                            kills);
                              RemoveObstacle(tx, ty);
                            end;
                        end;
        spVengeance:    ;
        spFatigue:      RemoveSFXJW(spAgility);
        spKill:         Traitors(st, 0, value);
        spVampire:      ;
        spMultiply:     begin
                          inc(Stacks[st].qty,
                              round(Stacks[st].qty * longint(value) div 100));
                          if Stacks[st].qty > stacks[st].maxqty then
                            Stacks[st].maxqty := Stacks[st].qty;
                        end;
        spPolymorph:    if MonsterLevel(Stacks[st].monster) = 1 then
                          nofx := true
                        else
                          VolveStack(st, -1);
        spShapeshift:   if MonsterLevel(Stacks[st].monster) = 6 then
                          nofx := true
                        else
                          VolveStack(st, 1);
      end;

      if SpellData[sp].duration and not nofx then
        AddSFX(st, sp, value, dur, side);

      if (SpellData[sp].duration or (sp in [spRenew, spHeal]))
          and (side = iside) and not CopyingSpells then begin
        CopyingSpells := true;
        for i := 1 to LastStack do
          if (i <> st) and (Stacks[i].qty > 0)
             and EffFlag(i, 5, f5CopiesSpells) then
            CastSpellOn(side, sp, Stacks[i].x, Stacks[i].y, value, dur);
        CopyingSpells := false;
      end;
    end;

    DrawCombatHex(x, y);
    if not (sp in [spZap, spHeal, spSwarm, spFireBolt, spMudBall,
                   spIceBolt, spGrenade, spRenew]) then begin
      DrawFX(x, y, fxCast, true);
      DrawCombatHex(x, y);
    end;

    CheckIfOver;
  end;

procedure TCombat.CastSpell(side, sp: integer);
  var
    numtargets, maxtargets, usabletargets: integer;
    tx, ty, i, x, y, dur, value, nt, hpt, cl, j: integer;
    used: boolean;
    sl: TSlant;

  function SlantMatch(st: integer): boolean;
    begin
      SlantMatch := ((sl = slEvil) and (Stacks[st].side <> side))
                    or ((sl = slGood) and (Stacks[st].side = side))
                    or (sl = slMixed);
    end;

  begin
    ShowHeroStats(side, sp);
    value := HeroSpellValue(SV[side].Dude, sp);
    dur := HeroSpellDur(SV[side].Dude, sp);

    if SpellData[sp].targets then begin
      if actual then
        numtargets := SpellMaxTargets(sp, SV[side].Dude)
      else
        numtargets := 1;
      sl := SpellData[sp].slant;
      usabletargets := 0;
      for i := 1 to LastStack do
        if (Stacks[i].qty > 0) and SlantMatch(i) then
          inc(usabletargets);
      maxtargets := usabletargets;
      if maxtargets > numtargets then maxtargets := numtargets;
      if sp = spGrenade then
        hpt := hptAny
      else case sl of
        slGood: hpt := hptFriend;
        slEvil: hpt := hptEnemy;
        slMixed: hpt := hptStack;
      end;

      if (sp in AllTargetSpells) and (numtargets >= usabletargets) then begin
        j := 1;
        for i := 1 to LastStack do
          if (Stacks[i].qty > 0) and SlantMatch(i) then begin
            SpellTargets[j].x := Stacks[i].x;
            SpellTargets[j].y := Stacks[i].y;
            inc(j);
            DrawCombatHex(Stacks[i].x, Stacks[i].y);
          end;
      end else begin
        repeat
          if SV[side].AI then
            AIPickTarget(side, hpt, sp, value, dur, maxtargets, tx, ty)
          else
            HeroPickTarget(side, hpt, tx, ty);
          if tx <> 0 then begin
            used := false;
            for i := 1 to high(SpellTargets) do
              if (SpellTargets[i].x = tx) and (SpellTargets[i].y = ty) then begin
                SpellTargets[i].x := 0;
                used := true;
              end;
            for i := 1 to high(SpellTargets) do
              if not used and (SpellTargets[i].x = 0) then begin
                SpellTargets[i].x := tx;
                SpellTargets[i].y := ty;
                used := true;
              end;
            if used then DrawCombatHex(tx, ty);
          end;
        until (tx = 0) or over or (SpellTargets[maxtargets].x <> 0)
              or (SV[side].AI
                  and (sp in [spGrow, spShrink, spAgility,
                              spFatigue, spFury, spWeakness, spMultiply])
                  and (SpellTargets[1].x <> 0));
      end;

      if not over then begin
        nt := 0;
        for i := 1 to numtargets do
          if SpellTargets[i].x <> 0 then inc(nt);
        if nt > 0 then begin
          value := (value + nt - 1) div nt;
          ShowHeroStats(side, 128);
          for i := 1 to numtargets do
            if not over and (SpellTargets[i].x <> 0) then begin
              x := SpellTargets[i].x;
              y := SpellTargets[i].y;
              SpellTargets[i].x := 0;
              DrawCombatHex(x, y);
              CastSpellOn(side, sp, x, y, value, dur);
            end;
          if side = 1 then cl := clHero1 else cl := clHero2;
          SpellWasCast(side, sp, cl);
        end;
      end;
    end else begin
      ShowHeroStats(side, 128);
      if SV[side].AI then HighlightAwhile(14, 6, actual);
      CastNoTarget(side, sp, value, dur);
    end;

    FillChar(SpellTargets, sizeof(SpellTargets), #0);
  end;

procedure TCombat.TakeHeroTurn(side: integer);
  var i, j, n, fx, x, y, sp, esc, st, shots, shot, cl: integer;
  begin
    for i := 1 to LastStack do
      if Stacks[i].qty > 0 then
        for fx := 1 to MaxSFX do
          if (Stacks[i].sfx[fx].sp > 0) and (Stacks[i].sfx[fx].dur > 0)
             and (Stacks[i].sfx[fx].side = side) then begin
            if Stacks[i].sfx[fx].sp = spSwarm then
              LoggedDamageStack(i, HeroSpellValue(SV[side].Dude, spSwarm),
                                false, clSwarm);
            dec(Stacks[i].sfx[fx].dur);
            if Stacks[i].sfx[fx].dur = 0 then
              Remove1SFX(i, fx);
            UpdateTrackedStackIf(i);
          end;

    CheckIfOver;

    shots := HeroNumShots(SV[side].Dude);

    for shot := 1 to shots do
      if not over then begin
        ShowHeroStats(side, -SV[side].Archery);
        UpdateTrackedStack;
        if SV[side].AI then begin
          Highlight(14, 6, false, actual);
          Refresh;
          GetAIBestShot(side, SV[side].Archery * cArcheryDamage, x, y);
        end else begin
          repeat
            HeroPickTarget(side, hptEnemy, x, y);
          until over or (x = 0) or (Stacks[StacksGrid[x, y]].side <> side);
        end;
        if not over and (x <> 0) then begin
          st := StacksGrid[x, y];
          if side = 1 then cl := clBow1 else cl := clBow2;
          HeroAttackHex(side, x, y, SV[side].Archery * cArcheryDamage, cl);
          if CountArt(SV[side].Dude, anFlamingBow, true) <> 0 then
            MakeObstacle(x, y, cmFire);
          if CountArt(SV[side].Dude, anBowOfPoison, true) > 0 then
            if (st <> 0) and (Stacks[st].qty > 0)
               and (Stacks[st].poison < 50) then begin
              Stacks[st].poison := 50;
              DrawCombatHex(Stacks[st].x, Stacks[st].y);
            end;
          n := CountArt(SV[side].Dude, anBowOfForce, true);
          if (n <> 0) and (st <> 0) and (Stacks[st].qty > 0) then begin
            if side = 1 then
              BlowStack(st, 1, n * 2)
            else
              BlowStack(st, -1, n * 2);
          end;
          for j := 1 to CountArt(SV[side].Dude, anBowOfEvil, true) do
            if (st <> 0) and (Stacks[st].qty > 0) then
              WandSpell(side, st, slEvil, clBowOfEvil, false);
        end;
        CheckIfOver;
      end;

    with SV[side] do begin
      if HRoundSP > Hero^[Dude].SP then
        HRoundSP := Hero^[Dude].SP;

      if not over and (HSpell > 0) then begin
        if HSpellCost >= HRoundSP then begin
          dec(HSpellCost, HRoundSP);
          dec(Hero^[Dude].SP, HRoundSP);
          HRoundSP := 0;
        end else begin
          dec(HRoundSP, HSpellCost);
          dec(Hero^[Dude].SP, HSpellCost);
          HSpellCost := 0;
        end;

        if HSpellCost = 0 then begin
          CastSpell(side, HSpell);
          HSpell := 0;
          if GetEffSkillLevel(Dude, skLore) = 4 then
            GiveMana(Dude, 1);
        end;
      end;

      while not over and (HRoundSP > 0) do begin
        MakeSpellList(SV[side], SpellList);
        if SpellList[1] = 0 then
          HRoundSP := 0
        else begin
          if SV[side].AI then
            sp := AIPickSpell(side)
          else
            sp := PickSpell(side);
          if sp = 0 then
            HRoundSP := 0
          else begin
            esc := EffSpellCost(Dude, sp);
            if HRoundSP >= esc then begin
              dec(HRoundSP, esc);
              dec(Hero^[Dude].SP, esc);
              CastSpell(side, sp);
              if GetEffSkillLevel(Dude, skLore) = 4 then
                GiveMana(Dude, 1);
            end else begin
              HSpell := sp;
              HSpellCost := esc - HRoundSP;
              dec(Hero^[Dude].SP, HRoundSP);
              HRoundSP := 0;
            end;
          end;
        end;
      end;

      HWent := true;
    end;
  end;

procedure TCombat.WandSpell(side, st: integer; sl: TSlant; cl: integer;
                            strong: boolean);
  const
    GoodSpells: array [boolean, 1..5] of byte =
    (
      (spGoodLuck, spGrow, spFury, spAgility, spFly),
      (spMagicBow, spVengeance, spVampire, spJoy, spRenew)
    );
    EvilSpells: array [1..6] of byte =
    (
      spBadLuck, spFatigue, spShrink, spWeakness, spSwarm, spMindBlank
    );
  var sp, value: integer;
  begin
    CheckIfOver;

    if not over then begin
      if sl = slGood then
        sp := GoodSpells[strong, random(5) + 1]
      else
        sp := EvilSpells[random(6) + 1];
      if st = 0 then begin
        repeat
          st := random(LastStack) + 1;
        until (Stacks[st].qty > 0)
              and (((sl = slGood) and (Stacks[st].side = side))
                   or ((sl = slEvil) and (Stacks[st].side <> side)));
      end;
      case sp of
        spGrow, spFury, spAgility,
        spFatigue, spShrink, spWeakness:  value := 20;
        spJoy:                            begin
                                            value := 40;
                                            RemoveAllStatSpells(st);
                                          end;
        spSwarm:                          value := 60;
        else                              value := 0;
      end;
      CastSpellOn(side, sp, Stacks[st].x, Stacks[st].y, value, 3);
      SpellWasCast(side, sp, cl);
    end;
  end;

procedure TCombat.ScrollSpell(side, sp, value, dur: integer);
  var
    gp, bestgp: longint;
    i, besti, tside, cl: integer;
  begin
    CheckIfOver;

    if not over then begin
      if (sp = spFireBolt) or (sp = spZap) or (sp = spTraitor) then
        tside := 3 - side
      else
        tside := side;
      bestgp := -MaxLongInt;
      besti := 0;
      for i := 1 to LastStack do
        if (Stacks[i].qty > 0) and (Stacks[i].side = tside) then begin
          gp := MonsterData[Stacks[i].realmonster].cost;
          if sp <> spTraitor then
            gp := gp * longint(Stacks[i].qty);
          if (sp = spFireBolt)
             and (CombatMap[Stacks[i].x, Stacks[i].y] = cmFire) then
            gp := gp div 2;
          if (gp > bestgp)
             and not ((sp = spMagicBow)
                      and EffFlag(i, 1, (f1Range or f1RangeAll)))
             and not ((sp = spVampire)
                      and EffFlag(i, 3, f3Vampire)) then begin
            bestgp := gp;
            besti := i;
          end;
        end;
      if besti <> 0 then begin
        CastSpellOn(side, sp, Stacks[besti].x, Stacks[besti].y, value, dur);
        case sp of
          spFireBolt: cl := clScrollofFireBolt;
          spMagicBow: cl := clScrollofMagicBow;
          spRenew:    cl := clScrollofRenew;
          spZap:      cl := clScrollofZap;
          spTraitor:  cl := clScrollofTraitor;
          spVampire:  cl := clScrollofVampire;
        end;
        SpellWasCast(side, sp, cl);
      end;
    end;
  end;

procedure TCombat.CastEquipSpells(side: integer);
  var j, h: integer;
  begin
    h := SV[side].Dude;
    for j := 1 to EquipSlots(h) do
      case Hero^[h].Equipped[j] of
        anWandOfBlessings:  WandSpell(side, 0, slGood, clWandofBless, false);
        anWandOfCurses:     WandSpell(side, 0, slEvil, clWandofCurse, false);
        anScrollOfMagicBow: ScrollSpell(side, spMagicBow, 0, 3);
        anScrollOfFireBolt: ScrollSpell(side, spFireBolt, 100, 0);
        anScrollOfRenew:    ScrollSpell(side, spRenew, 0, 0);
        anScrollofZap:      ScrollSpell(side, spZap, 50, 0);
        anScrollofTraitor:  ScrollSpell(side, spTraitor, 0, 0);
        anScrollofVampire:  ScrollSpell(side, spVampire, 0, 3);
      end;
  end;

procedure TCombat.StartCombat;
  const
    WitchInsight: array [0..2] of byte = (spGrow, spFury, spAgility);
  var
    i, j, nx, ny, h: integer;
  begin
    over := false;
    turnedge := 1;
    if SV[2].AI then
      TrackedStack := -2
    else
      TrackedStack := -1;
    MoveStackTargetX := 0;
    CombatMap := CombatDefs^[CDef].cmap;
    AddIllusions;
    DrawCombatScreen;

    for i := 1 to LastStack do
      with Stacks[i] do begin
        if EffFlag(i, 3, f3Illusionist) then
          HideIllusionist(i);
        if EffFlag(i, 4, f4FireShield) then begin
          for j := 1 to 6 do
            if FindAdjHex(j, Stacks[i].x, Stacks[i].y, nx, ny) then
              if HexEmpty(nx, ny) then
                MakeObstacle(nx, ny, cmFire);
        end;
        if EffFlag(i, 3, f3SlimeTrail) then
          MakeObstacle(Stacks[i].x, Stacks[i].y, cmWater)
        else if EffFlag(i, 4, f4FireTrail) then
          MakeObstacle(Stacks[i].x, Stacks[i].y, cmFire);
      end;

    if (SV[1].Dude <> 0)
       and (Hero^[SV[1].Dude].HermitBonus = hbWrecker) then begin
      for i := 1 to CombatXMax do
        for j := 1 to CombatYMax do
          if CombatMap[i, j] in [cmGate1..cmGate8, cmOpeningGate,
                                 cmBarbican, cmSpellTower] then begin
            DrawFX(i, j, fxBolt, true);
            RemoveObstacle(i, j);
            Refresh;
          end;
    end;

    StartRound;

    if not over then
      for i := 1 to 2 do begin
        h := SV[i].Dude;
        if h <> 0 then begin
          CastEquipSpells(i);
          if SkillHasInsight(h, skWitchcraft)
             and (GetSkillLevel(h, skWitchcraft) = 3) then
            CastSpell(i, WitchInsight[random(3)]);
        end;
      end;
  end;

procedure TCombat.CheckIfOver;
  var
    i: integer;
    sides: array [1..2] of integer;
  begin
    sides[1] := 0;
    sides[2] := 0;
    for i := 1 to LastStack do
      if Stacks[i].qty > 0 then inc(sides[Stacks[i].side]);
    if (sides[1] = 0) or (sides[2] = 0) then over := true;
  end;

procedure TCombat.HandleNextPlay;
  var st: integer;
  begin
    edge := 3 - edge;
    st := FastestStack;
    if st > 0 then TakeTurn(st);
    if st < 0 then TakeHeroTurn(-st);
    if st <> 0 then CheckIfOver;
    if (st = 0) and not over then begin
      inc(roundnum);
      StartRound;
    end;
  end;

procedure TCombat.HandleCombat;
  var st: integer;
  begin
    ClearScr;
    DrawBackground := false;
    AddLogLine('Combat Log');

    if Twists[twTerrainsAffectCombat] then
      case backcol of
        colJungle:     AddLogLine('No range attacks!');
        colCombatSnow: AddLogLine('No flying!');
        colDesolate:   AddLogLine('Slower ground troops!');
      end;

    StartCombat;
    if not over then
      repeat
        HandleNextPlay;
      until over;
  end;

procedure TCombat.DrawMonster(st, i, j, hs: integer);
  const
    HSColor: array [1..2, 1..2] of byte =
    (
      (colDarkDarkBlue, colBlues + 1),
      (colDarkDarkRed, colReds + 1)
    );
  var
    f, c, cd, cdb: integer;
    inv: boolean;
    a: TArmy;
    mine, yours: boolean;
  begin
    if Stacks[st].side = 1 then begin
      c := colFriend;
      inv := false;
    end else begin
      c := colEnemy;
      inv := true;
    end;

    if hs <> 0 then
      c := HSColor[Stacks[st].side, hs];

    a.monster := Stacks[st].monster;
    a.qty := Stacks[st].qty;

    if EffFlag(st, 5, f5Werewolf) and (Stacks[st].wolfct > 0) then
      a.monster := moChangedWerewolf;

    mine := Stacks[st].renew > 0;
    yours := Stacks[st].hexed or Stacks[st].diseased
             or (Stacks[st].stunned <> 0) or (Stacks[st].poison > 0);

    for f := 1 to MaxSFX do
      with Stacks[st].sfx[f] do
        if sp > 0 then
          case SpellData[sp].slant of
            slGood: mine := true;
            slEvil: yours := true;
            slMixed: if side = Stacks[st].side then
                       mine := true
                     else
                       yours := true;
          end;
    if mine and yours then begin
      cd := colYellows + 5;
      cdb := colYellows;
    end else if mine then begin
      cd := colGreens + 5;
      cdb := colGreens;
    end else if yours then begin
      cd := colLightReds + 2;
      cdb := colReds + 3;
    end else begin
      cd := colGrays + 5;
      cdb := colGrays;
    end;

    if (Stacks[st].armyslot = 0) and (SV[Stacks[st].side].Dude <> 0) then
      cd := colBlack;

    if a.qty > 0 then
      DrawArmy(i, j, c, cd, cdb, a, inv);
  end;

procedure TCombat.DrawCombatHex(x, y: integer);
  const
    HandlingIllusions: boolean = false;
  var
    i, j, st, n, sh, wn, hs: integer;

  function CombatWaterCode(m, cx, cy: integer): integer;
    var p, cn: integer;

    function CFindTerrain(wm, wx, wy: integer): boolean;
      begin
        CFindTerrain := (wx < 1) or (wy < 1)
                        or (wx > CombatXMax) or (wy > CombatYMax)
                        or (CombatMap[wx, wy] = wm);
      end;

    begin
      p := 0;
      if cy mod 2 = 1 then cn := 0 else cn := -1;

      if CFindTerrain(m, cx - 1,      cy)     then inc(p, 1);
      if CFindTerrain(m, cx + cn,     cy - 1) then inc(p, 2);
      if CFindTerrain(m, cx + cn + 1, cy - 1) then inc(p, 4);
      if CFindTerrain(m, cx + 1,      cy)     then inc(p, 8);
      if CFindTerrain(m, cx + cn + 1, cy + 1) then inc(p, 16);
      if CFindTerrain(m, cx + cn,     cy + 1) then inc(p, 32);

      CombatWaterCode := p;
    end;

  begin
    if actual then begin
      GetCombatHexXY(x, y, i, j);

      st := StacksGrid[x, y];

      sh := -1;
      for n := 1 to high(SpellTargets) do
        if (SpellTargets[n].x = x) and (SpellTargets[n].y = y) then
          sh := 0;
      if sh = -1 then
        if (Shadow[x, y] > 0) { and (st = 0)} then
          sh := 1
        else
          sh := 2;

      if CombatMap[x, y] in [cmWater, cmFire, cmChasm] then
        wn := CombatWaterCode(CombatMap[x, y], x, y)
      else
        wn := 0;

      DrawCombatTerrain(i, j, CombatMap[x, y], sh, wn, backcol);

      if st <> 0 then begin
        hs := HoverShadow[Stacks[st].x, Stacks[st].y];
        if Stacks[st].illusion <> 0 then
          DrawMonster(Stacks[st].illusion, i, j, hs)
        else
          DrawMonster(st, i, j, hs);
        if not HandlingIllusions and EffFlag(st, 3, f3Illusionist) then begin
          HandlingIllusions := true;
          for n := 1 to StackMax do
            if (Stacks[n].qty > 0)
               and (Stacks[n].illusion = st) then
              DrawCombatHex(Stacks[n].x, Stacks[n].y);
          HandlingIllusions := false;
        end;
      end;
    end;
  end;

procedure TCombat.DrawCombatScreen;
  var i, j, x, y: integer;
  begin
    DrawCombatGrid;

    for j := 1 to CombatYMax do
      for i := 1 to CombatXMax do
        DrawCombatHex(i, j);

    DrawCombatIcon(15, 2, fxHourglass, false);
    GetCombatHexXY(15, 2, x, y);
    DrawBoxText(x + 40, y + 15, 639, colBlack, colLightGray, 'Pass');

    for i := 1 to 2 do begin
      GetCombatHexXY(12 + 2 * i, 4, x, y);
      DrawHero(x, y, colLightGray, SV[i].Dude);
    end;
  end;

function TCombat.GetStatLines(st, sltop: integer;
                              var stl, sth: TStatLines): integer;
  var
    l, k, cc: integer;
    s, s2: string;

  procedure AddLine(s2: string; c: integer; s3: string);
    begin
      if (l >= sltop) and (l <= sltop + 4) then begin
        stl[l - sltop] := chr(c) + s2;
        sth[l - sltop] := s3;
      end;
      inc(l);
    end;

  begin
    l := 0;

    with Stacks[st] do begin
      if (armyslot = 0) and (SV[side].Dude <> 0) then
        AddLine('Conjured', colOranges + 5, 'This monster won''t be kept at '
                                            + 'the end of combat.');

      for k := 1 to FlagMax do
        if EffFlag(st, FlagByte(k), FlagBit(k)) then
          AddLine(FlagNames^[k], colLightGray, FlagHelp^[k]);

      if renew > 0 then
        AddLine('Renewed', colLightGreen, 'This monster will get another turn '
                                          + 'this round.');

      if stunned > 0 then
        AddLine('Stunned', colRed, 'This monster can''t move during its '
                                   + 'next turn.');
      if hexed then
        AddLine('Hexed', colRed, 'This monster has -2 hit points, deals -2 '
                                 + 'damage, and has -1 speed.');
      if diseased then
        AddLine('Diseased', colRed, 'This monster has -2 hit points, deals -2 '
                                    + 'damage, and has -1 speed.');
      if poison > 0 then
        AddLine('Poisoned (' + IStr(poison, 0) + ' dmg)', colRed,
                'This monster takes ' + IStr(poison, 0)
                + ' damage at the start of each of its turns.');

      for k := 1 to MaxSFX do
        with sfx[k] do
          if sp <> 0 then begin
            GetSpellStrings(sfx[k], s, s2, cc);
            AddLine(s, cc, s2);
          end;
    end;

    GetStatLines := l;
  end;

procedure TCombat.ShowStackStats(st, slot, top: integer);
  var
    x, y, l, k, d1, d2, m, fsp: integer;
    s, s2: string;
    stl, sth: TStatLines;
  begin
    if actual then begin
      if Stacks[st].illusion <> 0 then
        st := Stacks[st].illusion;

      GetSlotXY(slot, x, y);
      EraseStats(slot);
      if slot = 1 then begin
        TopStatsStack := st;
        TopStatsSP := 0;
      end;

      if top = -1 then
        top := SlotTop[slot]
      else
        SlotTop[slot] := top;

      DrawTallIconBox(x, y, colGreen);
      DrawMonster(st, x, y, 0);

      m := Stacks[st].monster;
      if Stacks[st].qty >= 2 then
        s := MonsterData[m].pname
      else
        s := MonsterData[m].name;
      DrawText(x, y - 10, colBlack, colLightGray, s);

      DrawText(x + 40, y + 3, colBlack, colLightGray,
               'Hits  = ' + IStr(Stacks[st].tophp, 0) + '/'
               + IStr(EffHp(st), 0));
      EffDmg(st, d1, d2);
      if d1 = d2 then
        s := IStr(d1, 0)
      else
        s := IStr(d1, 0) + '-' + IStr(d2, 0);
      DrawText(x + 40, y + 16, colBlack, colLightGray, 'Dmg   = ' + s);
      fsp := EffSpeed(st, false, false);
      DrawText(x + 40, y + 29, colBlack, colLightGray,
               'Speed = ' + IStr(fsp div 10, 0) + '.' + IStr(fsp mod 10, 0));

      for k := 0 to 5 do StatHints^[slot, k] := '';

      l := GetStatLines(st, top, stl, sth);
      if ((l < 6) and (top <> 0)) or (top >= l) then begin
        top := 0;
        SlotTop[slot] := 0;
        l := GetStatLines(st, top, stl, sth);
      end;

      for k := 0 to 4 do
        if l > top + k then begin
          DrawText(x, y + 43 + k * 13, colBlack, ord(stl[k][1]),
                   copy(stl[k], 2, 255));
          StatHints^[slot, k] := sth[k];
        end;

      if l > 5 then begin
        DrawText(x, y + 43 + 5 * 13, colLightGray, colWhite, 'More');
        StatHints^[slot, 5] := 'More';
      end;
    end;
  end;

procedure TCombat.ShowHeroStats(side, splev: integer);
  begin
    if actual then
      ActuallyShowHeroStats(SV[side], SpellList, splev);
  end;

procedure TCombat.DrawFX(x, y, fx: integer; wait: boolean);
  var i, j, w, k: integer;
  begin
    if actual then begin
      GetCombatHexXY(x, y, i, j);

      if wait then
        k := FXDelay
      else
        k := 1;

      DrawGraphic(i + 3, j - 1 + 3, colWhite, CombatIcons[fx], false);
      for w := 1 to k do Refresh;
    end;
  end;

procedure TCombat.DrawCombatGridHex(i, j: integer);
  var x, y, c: integer;
  begin
    if CombatMap[i, j] <= cmEmptyMax then begin
      GetCombatHexXY(i, j, x, y);
      if (TrackedStack <> 0) and (TrackedShadow[i, j] > 0) then begin
        if backcol = colCombatSnow then
          c := colGrayCyans
        else
          c := colDarkGray;
      end else
        c := colLightGray;
      XRectangle(x, y, x + 35, y + 39, c);
    end;
  end;

procedure TCombat.DrawCombatGrid;
  var i, j: integer;
  begin
    for i := 1 to CombatXMax do
      for j := 1 to CombatYMax do
        DrawCombatGridHex(i, j);
  end;

procedure TCombat.Unhighlight(x, y: integer);
  var i, j: integer;
  begin
    if actual then
      DrawCombatGridHex(x, y);
  end;

procedure TCombat.Refresh;
  begin
    if actual then RefreshScreen;
  end;

procedure TCombat.QuickCombat;
  var
    magicsum: integer;
    healamt, archeryamt, shots, badaim: array [1..2] of integer;
    healtroops: array [1..2] of boolean;
    illusionhits, BlessStack: array [1..StackMax] of byte;
    hasflier: array [1..2] of boolean;

  procedure SetBlessStack(st, val: integer);
    var i: integer;
    begin
      BlessStack[st] := val;
      if val = 1 then
        for i := 1 to LastStack do
          if (i <> st) and (Stacks[i].qty <> 0)
             and ((Stacks[i].Flags[5] and f5CopiesSpells) <> 0) then
            BlessStack[i] := 1;
    end;

  procedure SpinByFlag(fb, fbit: word);
    var n: integer;
    begin
      for n := 1 to LastStack do
        if (Stacks[n].qty > 0)
           and ((Stacks[n].Flags[fb] and fbit) <> 0) then
          inc(Stacks[n].spin);
    end;

  function QuickDamage(st: integer): integer;
    var d: integer;
    begin
      d := EffAvgDmg(st);
      if BlessStack[st] = 1 then
        inc(d, DamageVariance(Stacks[st].monster))
      else if BlessStack[st] = 2 then begin
        dec(d, DamageVariance(Stacks[st].monster));
        if d < 1 then d := 1;
      end;
      QuickDamage := d;
    end;

  procedure QuickHeal(st, d: integer);
    var eh: integer;
    begin
      eh := EffHp(st);
      inc(Stacks[st].tophp, d);
      if Stacks[st].tophp > eh then
        Stacks[st].tophp := eh;
    end;

  function QuickHiding(st: integer): boolean;
    begin
      with Stacks[st] do
        QuickHiding := ((SV[side].ArchersHelm > 0)
                        and ((Flags[1] and f1AnyRange) <> 0))
                       or ((Flags[1] and f1Hiding) <> 0);
    end;

  function SpeedBonus(stb: integer): integer;
    var sb: integer;
    begin
      with Stacks[stb] do begin
        if (Flags[3] and f3Enemyport) <> 0 then
          sb := 30
        else if (Flags[1] and f1Plantport) <> 0 then
          sb := 20
        else if ((Flags[1] and f1Fly) <> 0)
                or ((Flags[5] and (f5Friendport or f5SwitchMove)) <> 0) then
          sb := 10
        else if (Flags[1] and f1Transform) <> 0 then
          sb := 5
        else if (Flags[4] and (f4Waterwalking or f4Firewalking)) <> 0 then
          sb := 3
        else if (Flags[1] and f1Jump) <> 0 then
          sb := 2
        else
          sb := 0;
      end;
      SpeedBonus := sb;
    end;

  function PickStack(sid: integer; d: longint; stp: integer;
                     melee: boolean; var dmggp: longint): integer;
    var
      st, bestst, c: integer;
      gp, bestgp, h, fhp, fd: longint;
      kill, laser, maim, frog, stun: boolean;
    begin
      bestst := 0;
      bestgp := -MaxLongInt;
      if stp <> 0 then with Stacks[stp] do begin
        kill := ((flags[2] and f2Assassin) <> 0)
                or ((flags[4] and f4Traitor) <> 0);
        laser := (flags[2] and f2Flame) <> 0;
        maim := (flags[4] and f4Maiming) <> 0;
        frog := ((flags[1] and f1HighRange) <> 0)
                and ((flags[1] and f1RealRange) = 0)
                and (roundnum = 1);
        stun := stunned <> 0;
      end else begin
        kill := false;
        laser := false;
        maim := false;
        frog := false;
        stun := false;
      end;

      for st := 1 to LastStack do
        with Stacks[st] do
          if (qty > 0) and (side = sid)
             and ((not frog) or ((flags[1] and f1Fly) <> 0))
             and not (stun and ((flags[2] and f2Stun) = 0)) then begin
            fhp := EffHp(st);
            if kill then
              fd := d * fhp
            else begin
              fd := d;
              if maim
                 and ((Stacks[st].Flags[6] and f6DefImmune) = 0) then begin
                fd := fd + fhp;
                fd := fd - (fd mod fhp);
              end;
            end;
            if laser and ((Stacks[st].Flags[4] and f4FireImmune) = 0) then
              inc(fd, cFireDamage);
            if (not melee) and QuickHiding(st) then begin
              fd := fd div 10;
              if fd < 1 then fd := 1;
            end;
            h := fhp * (qty - 1) + tophp;
            if h > fd then h := fd;
            c := MonsterData[realmonster].cost;
            if (flags[5] and f5MakesGuys) <> 0 then
              inc(c, avgLevel1MonsterCost);
            gp := (h * c) div fhp;
            if (tophp <> fhp) and (d >= tophp) then inc(gp, c);
            if not done then begin
              if roundnum = 2 then
                dec(gp, gp div 4)
              else
                inc(gp, gp div 4);
            end;
            if gp > bestgp then begin
              bestst := st;
              bestgp := gp;
            end;
          end;

      dmggp := bestgp;
      PickStack := bestst;
    end;

  procedure HitStack(st2: integer; d: longint; melee: boolean);
    var oldq, hs, darkarts, darkq, sh, st3, n: integer;
    begin
      if (illusionhits[st2] = 1) or (illusionhits[st2] = 3) then begin
        dec(illusionhits[st2]);
        SpinByFlag(4, f4FeedOnDead);
      end else begin
        if illusionhits[st2] > 0 then dec(illusionhits[st2]);

        oldq := Stacks[st2].qty;
        if not melee and QuickHiding(st2) then begin
          d := d div 10;
          if d < 1 then d := 1;
        end;
        AdjHp(st2, -d);

        if oldq > Stacks[st2].qty then begin
          if Stacks[st2].qty = 0 then begin
            illusionhits[st2] := 0;
            SetBlessStack(st2, 0);
            SpinByFlag(4, f4FeedOnDead);
          end;

          with Stacks[st2] do
            if (SV[side].Dude <> 0) then begin
              if ((Flags[3] and f3DeathMana) <> 0) then
                GiveDeathMana(SV[side].Dude, (oldq - qty) * longint(40));
              if ((Flags[5] and f5DeathMana2) <> 0) then
                GiveDeathMana(SV[side].Dude, (oldq - qty) * longint(50));
            end;

          hs := 3 - Stacks[st2].side;
          darkarts := SV[hs].DarkArts;
          if darkarts > 0 then begin
            inc(SV[hs].HKills, oldq - Stacks[st2].qty);
            darkq := (SV[hs].HKills * longint(darkarts)) div cDarkArtsKills;
            if darkq > 0 then begin
              sh := 0;
              for n := LastStack downto 1 do
                with Stacks[n] do
                  if (qty > 0)
                     and (realmonster = moShadow)
                     and (monster = moShadow)
                     and (side = 3 - Stacks[st2].side) then
                    sh := n;
              if sh <> 0 then begin
                inc(Stacks[sh].qty, darkq);
                if Stacks[sh].qty > Stacks[sh].maxqty then
                  Stacks[sh].maxqty := Stacks[sh].qty;
                dec(SV[hs].HKills, (darkq * longint(cDarkArtsKills))
                                   div darkarts);
              end else
                st3 := AddStack(4, 4, hs, moShadow, darkq, -1, 0);
                if st3 <> 0 then
                  dec(SV[hs].HKills, (darkq * longint(cDarkArtsKills))
                                     div darkarts);
            end;
          end;
        end;

        with Stacks[st2] do
          if qty > 0 then begin
            if (Flags[3] and f3LikesDamage) <> 0 then
              inc(spin);
            if ((Flags[3] and f3Regenerate) <> 0)
               and (roundnum < 32) then
              tophp := EffHp(st2);
            if ((Flags[3] and f3Split) <> 0)
               and (qty > 1) then
              SplitStack(st2, side, qty div 2);
          end;
      end;
    end;

  procedure QuickSpellWasCast(side: integer);
    var st, n, kills, wod, wop, woh, h: integer;
    begin
      SpinByFlag(3, f3LikesSpells);

      h := SV[side].Dude;
      if h <> 0 then begin
        wod := CountArt(h, anWandOfDesertion, true);
        wop := CountArt(h, anWandOfPain, true);
        woh := CountArt(h, anWandOfHealth, true);

        if wod + wop + woh > 0 then
          for st := 1 to LastStack do
            if Stacks[st].qty > 0 then begin
              if Stacks[st].side = side then begin
                if woh > 0 then
                  QuickHeal(st, woh * 25);
              end else begin
                if wod > 0 then
                  dec(Stacks[st].qty, wod);
                if (wop > 0) and (Stacks[st].qty > 0) then
                  HitStack(st, wop * 25, false);
                if Stacks[st].qty = 0 then
                  SpinByFlag(4, f4FeedOnDead);
              end;
            end;
      end;
    end;

  procedure AttackStack(st2, st3: integer; edmg: longint; melee: boolean;
                        fraction: integer);
    var
      fl, i: integer;
      d, ehp3, totd: longint;
      killed: boolean;
    begin
      if (Stacks[st2].Flags[2] and f2CopyFlags) <> 0 then begin
        dec(Stacks[st2].speed, SpeedBonus(st2));
        for fl := 1 to NumFlagWords do
          Stacks[st2].Flags[fl] := Stacks[st2].Flags[fl]
                                   or Stacks[st3].Flags[fl];
        inc(Stacks[st2].speed, SpeedBonus(st2));
        edmg := QuickDamage(st2);
      end;

      ehp3 := EffHp(st3);

      d := edmg * Stacks[st2].qty;

      if ((Stacks[st2].Flags[4] and f4Maiming) <> 0)
         and ((Stacks[st3].Flags[6] and f6DefImmune) = 0) then begin
        d := d + ehp3;
        d := d - (d mod ehp3);
      end;

      if (((Stacks[st2].Flags[2] and f2Flame) <> 0)
         or (((Stacks[st2].Flags[1] and f1Fly) <> 0)
             and ((Stacks[st2].Flags[4] and f4FireTrail) <> 0)))
         and ((Stacks[st3].Flags[4] and f4FireImmune) = 0)
         and ((Stacks[st3].Flags[3] and f3Blink) = 0) then
        inc(d, cFireDamage);

      if fraction <> 100 then begin
        d := (d * fraction) div 100;
        if d < 1 then d := 1;
      end;

      if (Stacks[st2].Flags[2] and f2Assassin) <> 0 then
        inc(d, ehp3 * longint(Stacks[st2].qty));

      totd := ehp3 * Stacks[st3].qty;
      killed := false;

      if (Stacks[st2].Flags[4] and f4Traitor) <> 0 then begin
        Traitors(st3, Stacks[st2].side, Stacks[st2].qty);
        killed := (Stacks[st3].qty = 0)
                  or (Stacks[st3].side = Stacks[st2].side);
      end;

      if not killed then begin
        HitStack(st3, d,
                 melee or ((Stacks[st2].flags[6] and f6AttImmune) <> 0));
        killed := Stacks[st3].qty = 0;
      end;

      if not killed then begin
        if (Stacks[st3].Flags[6] and f6DefImmune) = 0 then begin
          if (Stacks[st2].Flags[2] and f2RemoveFlags) <> 0 then begin
            SetMonster(st3, Stacks[st3].monster);
            for fl := 1 to NumFlagWords do
              Stacks[st3].Flags[fl] := 0;
          end;
          if (Stacks[st2].Flags[2] and f2Stun) <> 0 then
            inc(Stacks[st3].stunned);
        end;
        if (Stacks[st3].Flags[5] and f5Bewildering) <> 0 then begin
          SetMonster(st2, Stacks[st2].monster);
          for fl := 1 to NumFlagWords do
            Stacks[st2].Flags[fl] := 0;
        end;
        if (Stacks[st2].Flags[2] and f2Hex) <> 0 then
          Stacks[st3].hexed := true;
        if (Stacks[st2].Flags[5] and f5Disease) <> 0 then
          Stacks[st3].diseased := true;
        if (Stacks[st2].Flags[4] and f4Curse) <> 0 then begin
          SetBlessStack(st3, 2);
          QuickSpellWasCast(Stacks[st2].side);
        end;
        if (Stacks[st2].Flags[2] and f2Devolve) <> 0 then begin
          dec(Stacks[st3].speed, SpeedBonus(st3));
          VolveStack(st3, -1);
          inc(Stacks[st3].speed, SpeedBonus(st3));
        end;
        if ((Stacks[st2].Flags[2] and f2SplitYou) <> 0)
           and (Stacks[st3].qty > 1) then
          SplitStack(st3, Stacks[st3].side, Stacks[st3].qty div 2);

        if ((Stacks[st2].Flags[4] and f4Poison) <> 0)
           and ((Stacks[st3].Flags[6] and f6DefImmune) = 0) then
          if Stacks[st3].poison < cPoisonDamage * Stacks[st2].qty then
            Stacks[st3].poison := cPoisonDamage * Stacks[st2].qty;
        if melee and ((Stacks[st3].Flags[4] and f4Poison) <> 0)
           and ((Stacks[st3].Flags[6] and f6AttImmune) = 0) then
          if Stacks[st2].poison < cPoisonDamage * Stacks[st3].qty then
            Stacks[st2].poison := cPoisonDamage * Stacks[st3].qty;

        if ((Stacks[st2].flags[2] and f2Water) <> 0) then
          CombatMap[Stacks[st3].x, Stacks[st3].y] := cmWater;
      end;

      if killed then with Stacks[st2] do begin
        if ((Flags[3] and f3RaiseDead) <> 0) and (monster <> moSoulThief) then
          AddStack(9, 9, side, moSoulThief, 1, -1, 0);
        if ((Flags[6] and f6RaiseSkulk) <> 0) and (monster <> moSkulk) then
          AddStack(9, 9, side, moSkulk, 1, -1, 0);
        if (Flags[3] and f3Morale) <> 0 then
          morale := 1;
        if (Flags[5] and f5Werewolf) <> 0 then begin
          inc(spin);
          inc(wolfct);
          case wolfct of
            1: Flags[1] := Flags[1] or f1Retaliate;
            2: Flags[5] := Flags[5] or f5Disease;
            3: Flags[4] := Flags[4] or f4Poison;
            4: Flags[2] := Flags[2] or f2Stun;
          end;
        end;
      end;

      if (Stacks[st2].Flags[3] and f3Vampire) <> 0 then begin
        if d > totd then d := totd;
        AdjHp(st2, d);
      end;

      with Stacks[st2] do
        if (SV[side].FlyersHelm > 0)
           and ((Flags[1] and f1Fly) <> 0) then begin
          hexed := false;
          diseased := false;
          stunned := 0;
          poison := 0;
          tophp := EffHp(st2);
          for i := 1 to SV[side].FlyersHelm do
            if qty < maxqty then
              inc(qty);
        end;

      if (not killed) and melee then begin
        if (Stacks[st2].Flags[6] and f6AttImmune) = 0 then begin
          if ((Stacks[st3].Flags[1] and f1Retaliate) <> 0)
             or ((Stacks[st3].Flags[5] and f5OneRetaliate) <> 0) then begin
            AttackStack(st3, st2, QuickDamage(st3), false, 100);
            Stacks[st3].flags[5] := Stacks[st3].flags[5] and not f5OneRetaliate;
          end;
          if (Stacks[st3].Flags[4] and f4Spikes) <> 0 then
            HitStack(st2, cSpikeDamage, false);
          if (Stacks[st3].Flags[5] and f5Spikes2) <> 0 then
            HitStack(st2, cSpikeDamage * 2, false);
        end;
        if (Stacks[st3].Flags[4] and f4FireShield) <> 0 then
          HitStack(st2, cFireDamage, false);
      end;

      if killed and melee and ((Stacks[st3].Flags[4] and f4Explode) <> 0) then
        HitStack(st2, cFireDamage, false);
    end;

  function PickAndHit(side: integer; d: longint): integer;
    var
      pst: integer;
      dmggp: longint;
    begin
      pst := PickStack(side, d, 0, false, dmggp);
      if pst <> 0 then HitStack(pst, d, false);
      PickAndHit := pst;
    end;

  function BestStackWithoutFlag(sid: integer; fb, fbit: word): integer;
    var
      i, bestst, fhp: integer;
      gp, bestgp: longint;
    begin
      bestst := 0;
      bestgp := -1;
      for i := 1 to LastStack do
        if (Stacks[i].qty > 0) and (Stacks[i].side = sid)
           and ((fb = 0) or ((Stacks[i].Flags[fb] and fbit) = 0)) then begin
          fhp := EffHp(i);
          gp := (fhp * (Stacks[i].qty - 1) + Stacks[i].tophp)
                * longint(MonsterData[Stacks[i].realmonster].cost) div fhp;
          if gp > bestgp then begin
            bestgp := gp;
            bestst := i;
          end;
        end;
      BestStackWithoutFlag := bestst;
    end;

  procedure QuickWandSpell(side: integer; good: boolean);
    var i: integer;
    begin
      i := BestStackWithoutFlag(side, 0, 0);
      if i <> 0 then
        case good of
          false: SetBlessStack(i, 2);
          true:  SetBlessStack(i, 1);
        end;
    end;

  procedure QuickAttack(st2: integer);
    const
      InSuperBless: boolean = false;
    var
      st3, i: integer;
      d, edmg, dmggp: longint;
      killed, melee, b, shooter: boolean;
      healtotal: integer;
      fspeed, dmgp: integer;

    function NextStack(sid, fromst: integer): integer;
      var j, n, got: integer;
      begin
        j := 1;
        got := 0;
        repeat
          n := (((fromst - 1) + j) mod LastStack) + 1;
          if (Stacks[n].qty > 0) and (Stacks[n].side = sid) then
            got := n;
          inc(j);
        until (got <> 0) or (j > LastStack);

        NextStack := got;
      end;

    procedure HitNextStack(fraction: integer);
      var got: integer;
      begin
        got := NextStack(3 - Stacks[st2].side, st3);

        if got <> 0 then
          AttackStack(st2, got, edmg, false, fraction);
      end;

    procedure MakeGuys;
      begin
        if (Stacks[st2].Flags[5] and f5MakesGuys) <> 0 then
          AddStack(2, 6, Stacks[st2].side, moRubberRat, Stacks[st2].qty, 0, 0);
      end;

    begin
     if roundnum < 32 then begin
       healtotal := healamt[Stacks[st2].side];
       if healtroops[Stacks[st2].side] then
         inc(healtotal, TroopsWithFlag(Stacks[st2].side, 6, f6Healing));
       QuickHeal(st2, healtotal);
     end;

     if Stacks[st2].poison > 0 then
       HitStack(st2, Stacks[st2].poison, false);

     if Stacks[st2].qty > 0 then begin

      if (Stacks[st2].Flags[3] and f3Bless) <> 0 then begin
        i := BestStackWithoutFlag(Stacks[st2].side, 0, 0);
        if i <> 0 then begin
          SetBlessStack(i, 1);
          QuickSpellWasCast(Stacks[st2].side);
        end;
      end;

      if ((Stacks[st2].Flags[5] and f5SuperBless) <> 0)
         and not InSuperBless then begin
        InSuperBless := true;
        i := BestStackWithoutFlag(Stacks[st2].side, 0, 0);
        if i <> 0 then begin
          b := Stacks[i].done;
          QuickAttack(i);
          Stacks[i].done := b;
        end;
        InSuperBless := false;
      end;

      shooter := ((Stacks[st2].Flags[1] and (f1Range or f1Range1
                                             or f1RangeAll)) <> 0)
                 or (((Stacks[st2].Flags[1] and f1HighRange) <> 0)
                     and (hasflier[3 - Stacks[st2].side]));

      if shooter or (roundnum <> 1) then begin
        edmg := QuickDamage(st2);

        if ((Stacks[st2].Flags[2] and f2Assassin) <> 0)
           or ((Stacks[st2].Flags[4] and f4Traitor) <> 0) then
          d := Stacks[st2].qty
        else
          d := edmg * Stacks[st2].qty;
        st3 := PickStack(3 - Stacks[st2].side, d, st2,
                         (roundnum <> 1)
                         or ((Stacks[st2].flags[6] and f6AttImmune) <> 0),
                         dmggp);

        if ((Stacks[st2].Flags[5] and f5MakesGuys) <> 0)
           and (dmggp < Stacks[st2].qty * longint(avgLevel1MonsterCost)) then
          st3 := 0;

        if st3 <> 0 then begin
          { slower monsters do less damage and don't hit what they want to }

          if shooter or ((Stacks[st2].flags[3] and f3Enemyport) <> 0) then
            dmgp := 100
          else begin
            fspeed := EffSpeed(st2, false, true);

            if (Stacks[st2].flags[1] and f1ShortRange) <> 0 then
              inc(fspeed, 8);
            if (Stacks[st2].flags[1] and f1RangeLine) <> 0 then
              inc(fspeed, 3);

            if fspeed >= 70 then
              dmgp := 100
            else if fspeed <= 30 then
              dmgp := 20
            else
              dmgp := fspeed * 2 - 40;

            i := Stacks[st2].side;

            if fspeed <= 40 then
              st3 := NextStack(3 - i, st3)
            else if fspeed < 80 then begin
              inc(badaim[i], 200 - fspeed * 2 - fspeed div 2);
              if badaim[i] >= 100 then begin
                dec(badaim[i], 100);
                st3 := NextStack(3 - i, st3);
              end;
            end;
          end;

          if roundnum = 1 then
            melee := false
          else if QuickHiding(st3) then
            melee := true
          else if ((Stacks[st2].flags[1] and f1AnyRange) <> 0)
                  or ((Stacks[st2].flags[2] and f2Push) <> 0)
                  or ((Stacks[st2].flags[2] and f2Throw) <> 0)
                  or ((Stacks[st3].flags[3] and f3Blink) <> 0)
                  or (((Stacks[st2].flags[1] and f1Transform) <> 0)
                      and ((roundnum mod 2) = 0)) then
            melee := false
          else
            melee := true;

          AttackStack(st2, st3, edmg, melee, dmgp);

          if (Stacks[st2].Flags[1] and f1RangeAll) <> 0 then
            for i := LastStack downto 1 do
              if (Stacks[i].qty > 0) and (Stacks[i].side <> Stacks[st2].side)
                 and (i <> st3) then
                AttackStack(st2, i, edmg, false, 100);

          if roundnum > 1 then with Stacks[st2] do begin
            if (Flags[3] and f3Lightning) <> 0 then HitNextStack(10);
            if (Flags[1] and f1Breath1)   <> 0 then HitNextStack(20);
            if (Flags[2] and f2TwoHead)   <> 0 then HitNextStack(25);
            if (Flags[5] and f5Trample)   <> 0 then HitNextStack(30);
            if (Flags[2] and f2Hydra)     <> 0 then HitNextStack(50);
            if (Flags[1] and f1Breath2)   <> 0 then HitNextStack(60);
            if (Flags[1] and f1Steamroll) <> 0 then HitNextStack(100);
            if (Flags[5] and f5FireCircle)<> 0 then HitNextStack(100);
          end;

          if (Stacks[st2].Flags[1] and f1AoE) <> 0 then HitNextStack(75);

          if (Stacks[st2].Flags[2] and f2AttMoveAtt) <> 0 then begin
            if (Stacks[st2].Flags[1] and (f1RealRange or f1HighRange)) <> 0 then
              HitNextStack(100)
            else if roundnum > 2 then
              HitNextStack(50);
          end;

          if (Stacks[st2].Flags[5] and f5ThreeAttacks) <> 0 then HitNextStack(200);

          if (Stacks[st2].morale = 1) then begin
            HitNextStack(100);
            Stacks[st2].morale := 0;
          end;

          if ((Stacks[st2].Flags[3] and f3SlimeTrail) <> 0)
             and ((Stacks[st2].Flags[1] and f1Fly) <> 0) then begin
            i := NextStack(3 - Stacks[st2].side, st3);
            if i <> 0 then
              CombatMap[Stacks[i].x, Stacks[i].y] := cmWater;
          end;
          Stacks[st2].Flags[1] := Stacks[st2].Flags[1] and not f1Range1;
        end else MakeGuys;
      end else MakeGuys;

      Stacks[st2].done := true;
      Stacks[st2].stunned := 0;
     end;
    end;

  procedure QuickEquipSpells(side: integer);

    procedure SpellBest(fb, fbitchk, fbitset: word);
      var i: integer;
      begin
        i := BestStackWithoutFlag(3 - side, fb, fbitchk);
        if i <> 0 then
          Stacks[i].Flags[fb] := Stacks[i].Flags[fb] or fbitset;
      end;

    var j, h, eq, i: integer;
    begin
      h := SV[side].Dude;
      for j := 1 to EquipSlots(h) do begin
        eq := Hero^[h].Equipped[j];
        if eq in [anWandOfBlessings, anWandOfCurses, anScrollOfMagicBow,
                  anScrollOfFireBolt, anScrollOfRenew, anScrollOfZap,
                  anScrollOfTraitor, anScrollOfVampire] then begin
          case eq of
            anWandOfBlessings:  QuickWandSpell(side, true);
            anWandOfCurses:     QuickWandSpell(3 - side, false);
            anScrollOfMagicBow: SpellBest(side, f1RealRange, f1Range);
            anScrollOfFireBolt: PickAndHit(3 - side, 300);
            anScrollOfRenew:    begin
                                  i := BestStackWithoutFlag(side, 0, 0);
                                  if i <> 0 then begin
                                    QuickAttack(i);
                                    Stacks[i].done := false;
                                  end;
                                end;
            anScrollofZap:      PickAndHit(3 - side, 50);
            anScrollofTraitor:  begin
                                  i := BestStackWithoutFlag(3 - side, 0, 0);
                                  if i <> 0 then
                                    Traitors(i, side, 1);
                                end;
            anScrollofVampire:  SpellBest(3, f3Vampire, f3Vampire);
          end;
          QuickSpellWasCast(side);
        end;
      end;
    end;

  procedure StartQuickRound;
    var i, fhp, n, j: integer;
    begin
      for i := 1 to LastStack do
        if Stacks[i].qty > 0 then begin
          Stacks[i].done := false;
          if roundnum <> 1 then begin
            if (Stacks[i].Flags[3] and f3Spinning) <> 0 then
              inc(Stacks[i].spin);
            if (roundnum = 2) and ((Stacks[i].Flags[5] and f5MoveFar) <> 0) then
              inc(Stacks[i].speed, 40);
          end;
        end;

      for i := 1 to 2 do
        if SV[i].Dude <> 0 then begin
          SV[i].HWent := false;
          n := CountArt(SV[i].Dude, anWandOfEndlessCurses, true);
          if n <> 0 then
            for j := 1 to n do
              QuickWandSpell(3 - i, false);
          n := CountArt(SV[i].Dude, anScrollOfScrolls, true);
          if roundnum = 1 then inc(n);
          if n <> 0 then
            for j := 1 to n do
              QuickEquipSpells(i);
        end else
          SV[i].HWent := true;

      turnedge := 3 - turnedge;
      edge := turnedge;

      for i := 1 to CombatYMax do
        if CombatDefs^[CDef].cmap[12, i] = cmBarbican then
          PickAndHit(1, cBarbicanDamage);

      CheckIfOver;
    end;
{
  procedure TestOutput;
    const
      sides: array [1..2] of string[4] = ('blue', 'red ');
    var
      i: integer;
      f: text;
    begin
      assign(f, 'temp2.dat');
      append(f);
      for i := 1 to LastStack do
        with Stacks[i] do
          if qty > 0 then
            writeln(f, sides[side] + ' '
                       + IStr(qty, 5) + ' '
                       + LSet(MonsterData[monster].name, 20));
      writeln(f);
      close(f);
    end;
}
  var
    st, i, mh, esc, archct, h: integer;
  begin
    actual := false;
    over := false;
    TrackedStack := 0;
    turnedge := 1;
    FillChar(illusionhits, sizeof(illusionhits), #0);
    FillChar(BlessStack, sizeof(BlessStack), #0);
    SideHasFlier(hasflier[1], hasflier[2]);

    for st := 1 to LastStack do
      if Stacks[st].qty > 0 then begin
        if (Stacks[st].Flags[3] and f3Illusionist) <> 0 then
          illusionhits[st] := 3;
        if Twists[twTerrainsAffectCombat] then begin
          if backcol = colJungle then
            Stacks[st].Flags[1] := Stacks[st].Flags[1] and not f1AnyRange
          else if backcol = colCombatSnow then
            Stacks[st].Flags[1] := Stacks[st].Flags[1] and not f1Fly;
        end;
        inc(Stacks[st].speed, SpeedBonus(st));
      end;

    for i := 1 to 2 do begin
      h := SV[i].Dude;
      if h <> 0 then begin
        healamt[i] := GetEffSkillLevel(h, skHealing) * cHealDamage;
        archeryamt[i] := SV[i].Archery * cArcheryDamage
                         + cFireDamage
                           * CountArt(h, anFlamingBow, true);
        shots[i] := HeroNumShots(h);
      end else begin
        healamt[i] := 0;
        archeryamt[i] := 0;
        shots[i] := 0;
      end;
      healtroops[i] := TroopsWithFlag(i, 6, f6Healing) > 0;
      badaim[i] := 0;
    end;

    CheckIfOver;

    if not over then begin
{     TestOutput; }
      StartQuickRound;

      if not over then repeat
        edge := 3 - edge;
        st := FastestStack;
        if st > 0 then
          QuickAttack(st);
        if st < 0 then begin
          for archct := 1 to shots[-st] do
            if not over then begin
              i := PickAndHit(3 - (-st), archeryamt[-st]);
              if (i <> 0) and (Stacks[i].qty > 0) then begin
                if CountArt(SV[-st].Dude, anBowOfEvil, true) <> 0 then begin
                  SetBlessStack(i, 2);
                  QuickSpellWasCast(-st);
                end;
                if (CountArt(SV[-st].Dude, anBowOfPoison, true) <> 0)
                   and (Stacks[i].poison < 50) then
                  Stacks[i].poison := 50;
              end;
            end;
          if not over and (roundnum < 3) then begin
            mh := SV[-st].Dude;
            if mh <> 0 then begin
              esc := EffSpellCost(mh, spZap);
              if (Hero^[mh].SP >= esc) then begin
                magicsum := HeroQuickMagic(mh);
                PickAndHit(3 - (-st), magicsum);
                dec(Hero^[mh].SP, esc);
                QuickSpellWasCast(-st);
              end;
            end;
            CheckIfOver;
          end;

          SV[-st].HWent := true;
        end;
        if st <> 0 then CheckIfOver;
        if (st = 0) and not over then begin
          inc(roundnum);
          if roundnum >= 32 then over := true
          else begin
{           TestOutput; }
            StartQuickRound;
          end;
        end;
      until over;
{     TestOutput; }
    end;
  end;

constructor TCombat.Init(iactual: boolean; ih1, ih2, iCDef, ibackcol: integer);
  var i: integer;
  begin
    TObject.Init;
    actual := iactual;
    SV[1].Dude := ih1;
    SV[2].Dude := ih2;
    CDef := iCDef;
    if ibackcol = colSnow then
      backcol := colCombatSnow
    else
      backcol := ibackcol;
    over := false;

    if actual then begin
      LastStack := 0;
      ClearStacks;
      FillChar(HoverShadow, sizeof(HoverShadow), #0);
      roundnum := 1;
      ResetCombatLog;
      AttMoveChoiceX := 0;

      for i := 1 to 2 do
        FillSideVars(SV[i]);

      FillChar(SpellTargets, sizeof(SpellTargets), #0);
    end;
  end;

destructor TCombat.Done;
  begin
    TObject.Done;
  end;

function TCombat.Spawn: PCombat;
  var p: PCombat;
  begin
    p := New(PCombat, Init(false, SV[1].Dude, SV[2].Dude, CDef, backcol));
    p^.Stacks := Stacks;
    p^.Shadow := Shadow;
    p^.MShadow := MShadow;
    p^.StacksGrid := StacksGrid;
    p^.CombatMap := CombatMap;
    p^.edge := edge;
    p^.turnedge := turnedge;
    p^.roundnum := roundnum;
    p^.LastStack := LastStack;
    p^.AttackMoves := AttackMoves;
    p^.Targets := Targets;
    p^.MoveStackTargetX := MoveStackTargetX;
    p^.MoveStackTargetY := MoveStackTargetY;
    p^.SV := SV;
    p^.SpellTargets := SpellTargets;
    Spawn := p;
  end;

{ unit initialization }

end.
