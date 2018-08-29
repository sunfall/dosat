unit spells;

{ spells for hommx }

interface

uses LowGr;

type
  TSpellSet = array [1..4] of word;

  TSlant = (slGood, slMixed, slEvil);

  TSpell = record
    name: string[12];
    level: byte;
    bit: word;
    targets: boolean;
    duration: boolean;
    secret: boolean;
    cost: byte;
    slant: TSlant;
  end;

const
  NumSpells = 36;

  FirstSpell: array [1..4] of integer = (1, 11, 21, 29);
  LastSpell: array [1..4] of integer = (10, 20, 28, 36);

  NoSpells: TSpellSet = (0, 0, 0, 0);

  spZap = 1;
  spMentalBlast = 2;
  spBadLuck = 3;
  spGoodLuck = 4;
  spSwarm = 5;
  spGrow = 6;
  spBlow = 7;
  spDeserter = 8;
  spFury = 9;
  spFly = 10;

  spFireBolt = 11;
  spTraitor = 12;
  spFatigue = 13;
  spConjure = 14;
  spMindBlank = 15;
  spMudBall = 16;
  spHeal = 17;
  spShrink = 18;
  spAgility = 19;
  spWeakness = 20;

  spIceBolt = 21;
  spSicken = 22;
  spMagicBow = 23;
  spKill = 24;
  spGrenade = 25;
  spVengeance = 26;
  spFireShield = 27;
  spVampire = 28;

  spWoe = 29;
  spJoy = 30;
  spMultiply = 31;
  spRenew = 32;
  spPolymorph = 33;
  spShapeshift = 34;
  spInferno = 35;
  spSummon = 36;

  SpellData: array [1..NumSpells] of TSpell =
  (
{ level 1 }
    (name: 'Zap';
     level: 1;
     bit: $0001;
     targets: true;
     duration: false;
     secret: false;
     cost: 10;
     slant: slEvil),
    (name: 'Mental Blast';
     level: 1;
     bit: $0002;
     targets: false;
     duration: false;
     secret: true;
     cost: 10;
     slant: slEvil),
    (name: 'Bad Luck';
     level: 1;
     bit: $0004;
     targets: true;
     duration: true;
     secret: false;
     cost: 10;
     slant: slEvil),
    (name: 'Good Luck';
     level: 1;
     bit: $0008;
     targets: true;
     duration: true;
     secret: false;
     cost: 10;
     slant: slGood),
    (name: 'Swarm';
     level: 1;
     bit: $0010;
     targets: true;
     duration: true;
     secret: false;
     cost: 10;
     slant: slEvil),
    (name: 'Grow';
     level: 1;
     bit: $0020;
     targets: true;
     duration: true;
     secret: false;
     cost: 10;
     slant: slGood),
    (name: 'Blow';
     level: 1;
     bit: $0040;
     targets: true;
     duration: false;
     secret: false;
     cost: 10;
     slant: slMixed),
    (name: 'Deserter';
     level: 1;
     bit: $0080;
     targets: true;
     duration: false;
     secret: false;
     cost: 10;
     slant: slEvil),
    (name: 'Fury';
     level: 1;
     bit: $0100;
     targets: true;
     duration: true;
     secret: false;
     cost: 10;
     slant: slGood),
    (name: 'Fly';
     level: 1;
     bit: $0200;
     targets: true;
     duration: true;
     secret: false;
     cost: 10;
     slant: slMixed),
{ level 2 }
    (name: 'Fire Bolt';
     level: 2;
     bit: $0001;
     targets: true;
     duration: false;
     secret: false;
     cost: 20;
     slant: slEvil),
    (name: 'Traitor';
     level: 2;
     bit: $0002;
     targets: true;
     duration: false;
     secret: false;
     cost: 20;
     slant: slEvil),
    (name: 'Fatigue';
     level: 2;
     bit: $0004;
     targets: true;
     duration: true;
     secret: false;
     cost: 20;
     slant: slEvil),
    (name: 'Conjure';
     level: 2;
     bit: $0008;
     targets: false;
     duration: true;
     secret: false;
     cost: 20;
     slant: slGood),
    (name: 'Mind Blank';
     level: 2;
     bit: $0010;
     targets: true;
     duration: true;
     secret: true;
     cost: 20;
     slant: slMixed),
    (name: 'Mud Ball';
     level: 2;
     bit: $0020;
     targets: true;
     duration: false;
     secret: false;
     cost: 20;
     slant: slEvil),
    (name: 'Heal';
     level: 2;
     bit: $0040;
     targets: true;
     duration: false;
     secret: false;
     cost: 20;
     slant: slGood),
    (name: 'Shrink';
     level: 2;
     bit: $0080;
     targets: true;
     duration: true;
     secret: false;
     cost: 20;
     slant: slEvil),
    (name: 'Agility';
     level: 2;
     bit: $0100;
     targets: true;
     duration: true;
     secret: false;
     cost: 20;
     slant: slGood),
    (name: 'Weakness';
     level: 2;
     bit: $0200;
     targets: true;
     duration: true;
     secret: false;
     cost: 20;
     slant: slEvil),
{ level 3 }
    (name: 'Ice Bolt';
     level: 3;
     bit: $0001;
     targets: true;
     duration: true;
     secret: false;
     cost: 30;
     slant: slEvil),
    (name: 'Sicken';
     level: 3;
     bit: $0002;
     targets: true;
     duration: false;
     secret: false;
     cost: 30;
     slant: slEvil),
    (name: 'Magic Bow';
     level: 3;
     bit: $0004;
     targets: true;
     duration: true;
     secret: false;
     cost: 30;
     slant: slGood),
    (name: 'Kill';
     level: 3;
     bit: $0008;
     targets: true;
     duration: false;
     secret: false;
     cost: 30;
     slant: slEvil),
    (name: 'Grenade';
     level: 3;
     bit: $0010;
     targets: true;
     duration: false;
     secret: true;
     cost: 30;
     slant: slEvil),
    (name: 'Vengeance';
     level: 3;
     bit: $0020;
     targets: true;
     duration: true;
     secret: false;
     cost: 30;
     slant: slGood),
    (name: 'Fire Shield';
     level: 3;
     bit: $0040;
     targets: false;
     duration: false;
     secret: false;
     cost: 30;
     slant: slGood),
    (name: 'Vampire';
     level: 3;
     bit: $0080;
     targets: true;
     duration: true;
     secret: false;
     cost: 30;
     slant: slGood),
{ level 4 }
    (name: 'Woe';
     level: 4;
     bit: $0001;
     targets: false;
     duration: true;
     secret: false;
     cost: 40;
     slant: slEvil),
    (name: 'Joy';
     level: 4;
     bit: $0002;
     targets: false;
     duration: true;
     secret: true;
     cost: 40;
     slant: slGood),
    (name: 'Multiply';
     level: 4;
     bit: $0004;
     targets: true;
     duration: false;
     secret: false;
     cost: 40;
     slant: slGood),
    (name: 'Renew';
     level: 4;
     bit: $0008;
     targets: true;
     duration: false;
     secret: false;
     cost: 40;
     slant: slGood),
    (name: 'Polymorph';
     level: 4;
     bit: $0010;
     targets: true;
     duration: true;
     secret: false;
     cost: 40;
     slant: slEvil),
    (name: 'Shapeshift';
     level: 4;
     bit: $0020;
     targets: true;
     duration: true;
     secret: false;
     cost: 40;
     slant: slGood),
    (name: 'Inferno';
     level: 4;
     bit: $0040;
     targets: false;
     duration: false;
     secret: false;
     cost: 40;
     slant: slEvil),
    (name: 'Summon';
     level: 4;
     bit: $0080;
     targets: false;
     duration: true;
     secret: false;
     cost: 40;
     slant: slGood)
  );

  SpellSlantColor: array [TSlant] of integer =
  (
    colLightGreen, colLightGray, colRed
  );

function CheckForSpell(SS: TSpellSet; sp: integer): boolean;
function CountSpells(SS: TSpellSet): integer;
procedure AddSpell(var SS: TSpellSet; sp: integer);
procedure AddSpellSet(var SS: TSpellSet; fSS: TSpellSet);
function RandomSpell(lev: integer): integer;
function PsuedorandomSpell(lev, r: integer): integer;
function RandomNewSpell(SS: TSpellSet; lev, notsp: integer;
                        secretok: boolean): integer;
procedure DrawSpellSet(x, y: integer; SS: TSpellSet);
function SpellSetClick(SS: TSpellSet; ssx, ssy, x, y: integer): integer;
function SpellPowerValue(sp, power, witch: integer): integer;
function SpellValueStr(sp, v: integer): string;
function SpellHint(sp, v, dur: integer): string;
function SpellHintStr(sp, h, pl: integer): string;

implementation

uses XStrings, Heroes, Players;

function CheckForSpell(SS: TSpellSet; sp: integer): boolean;
  begin
    CheckForSpell := (SS[SpellData[sp].level] and SpellData[sp].bit) <> 0;
  end;

function CountSpells(SS: TSpellSet): integer;
  var sp, cs: integer;
  begin
    cs := 0;

    for sp := 1 to NumSpells do
      if CheckForSpell(SS, sp) then inc(cs);

    CountSpells := cs;
  end;

procedure AddSpell(var SS: TSpellSet; sp: integer);
  begin
    SS[SpellData[sp].level] := SS[SpellData[sp].level] or SpellData[sp].bit;
  end;

procedure AddSpellSet(var SS: TSpellSet; fSS: TSpellSet);
  var i: integer;
  begin
    for i := 1 to 4 do
      SS[i] := SS[i] or fSS[i];
  end;

function RandomSpell(lev: integer): integer;
  var sp: integer;
  begin
    repeat
      sp := random(LastSpell[lev] - FirstSpell[lev] + 1) + FirstSpell[lev];
    until not SpellData[sp].secret;
    RandomSpell := sp;
  end;

function PsuedorandomSpell(lev, r: integer): integer;
  var sp: integer;
  begin
    repeat
      sp := (r mod (LastSpell[lev] - FirstSpell[lev] + 1)) + FirstSpell[lev];
      inc(r);
    until not SpellData[sp].secret;

    PsuedorandomSpell := sp;
  end;

function RandomNewSpell(SS: TSpellSet; lev, notsp: integer;
                        secretok: boolean): integer;
  var ns, r, i, n, f: integer;
  begin
    f := 0;

    repeat
      ns := LastSpell[lev] - FirstSpell[lev] + 1;
      r := random(ns);

      for i := 0 to ns - 1 do begin
        n := ((r + i) mod ns) + FirstSpell[lev];
        if (secretok or not SpellData[n].secret) and (n <> notsp)
           and not CheckForSpell(SS, n) then
          f := n;
      end;

      dec(lev);
    until (f <> 0) or (lev = 0);

    RandomNewSpell := f;
  end;

const
  cornerx: array [1..4] of integer =
  (
    0, 8 * 12 + 40, 0, 8 * 12 + 40
  );
  cornery: array [1..4] of integer =
  (
    0, 0, 12 * 13, 12 * 13
  );

procedure DrawSpellSet(x, y: integer; SS: TSpellSet);
  var
    l, i, lin: integer;
  begin
    for l := 1 to 4 do begin
      DrawText(x + cornerx[l], y + cornery[l], colBlack, colLightGray,
               'Level ' + IStr(l, 0));
      lin := 2;
      for i := FirstSpell[l] to LastSpell[l] do
        if CheckForSpell(SS, i) then begin
          DrawText(x + cornerx[l], y + cornery[l] + lin * 12, colBlack,
                   SpellSlantColor[SpellData[i].slant], SpellData[i].name);
          inc(lin);
        end;
    end;
  end;

function SpellSetClick(SS: TSpellSet; ssx, ssy, x, y: integer): integer;
  var sp, l, i, lin: integer;
  begin
    sp := 0;

    for l := 1 to 4 do begin
      lin := 2;
      for i := FirstSpell[l] to LastSpell[l] do
        if CheckForSpell(SS, i) then begin
          if (x >= ssx + cornerx[l]) and (x < ssx + cornerx[l] + 12 * 8)
             and (y >= ssy + cornery[l] + lin * 12)
             and (y < ssy + cornery[l] + lin * 12 + 8) then
            sp := i;
          inc(lin);
        end;
    end;

    SpellSetClick := sp;
  end;

function SpellPowerValue(sp, power, witch: integer): integer;
  const
{   perc: array [1..32] of byte =
    (
       7, 13, 19, 24, 29, 34, 38, 43, 46, 50,
      53, 56, 59, 62, 65, 67, 69, 71, 73, 75,
      77, 78, 80, 81, 82, 84, 85, 86, 87, 87,
      88, 89
    );             round(100 - 100 / exp(n / 10 * ln(2)))
}
    perc: array [1..4] of byte =
    (
      15, 25, 35, 50
    );
  var
    v, p: real;
  begin
    v := 0;

    p := (power - 1) * 1.5 + 1;

    case sp of
      spZap:         v := p * 50;
      spSwarm:       v := p * 30;
      spMentalBlast: v := p * 15;
      spBlow:        v := 3;
      spGrow:        v := witch * 20;
      spFury:        v := witch * 20;
      spFireBolt:    v := p * 100;
      spMudBall:     v := p * 100;
      spAgility:     v := witch * 20;
      spConjure:     v := p * 10;
      spShrink:      v := perc[witch];
      spWeakness:    v := perc[witch];
      spGrenade:     v := p * 50;
      spIceBolt:     v := p * 150;
      spFatigue:     v := perc[witch];
      spJoy:         v := witch * 20;
      spWoe:         v := perc[witch];
      spKill:        v := p;
      spInferno:     v := p * 100;
      spSummon:      v := p * 10;
      spMultiply:    v := witch * 2;
    end;

    SpellPowerValue := round(v);
  end;

function SpellValueStr(sp, v: integer): string;
  var s: string;
  begin
    if v = 0 then
      s := ''
    else begin
      case sp of
        spZap,
        spSwarm,
        spMentalBlast,
        spFireBolt,
        spMudBall,
        spGrenade,
        spIceBolt,
        spInferno:    s := 'd';
        spBlow:       s := 'h';
        spGrow,
        spFury,
        spAgility,
        spJoy,
        spConjure,
        spSummon,
        spMultiply:   s := '+';
        spShrink,
        spWeakness,
        spFatigue,
        spWoe:        s := '-';
        spKill:       s := 'k';
      end;
      s := s + IStr(v, 0);
      if sp in [spGrow, spFury, spAgility, spJoy, spMultiply,
                spShrink, spWeakness, spFatigue, spWoe] then
        s := s + '%';
    end;
    SpellValueStr := s;
  end;

function SpellHint(sp, v, dur: integer): string;
  var s, vs: string;

  function fordur: string;
    begin
      if dur = 1 then
        fordur := 'for one round.'
      else
        fordur := 'for ' + IStr(dur, 0) + ' rounds.';
    end;

  function plural: string;
    begin
      if v > 1 then
        plural := 's'
      else
        plural := '';
    end;

  begin
    vs := IStr(v, 0);

    case sp of
      spZap:          s := 'Deals ' + vs + ' damage to a stack.';
      spHeal:         s := 'Removes all enemy spells from a stack, as '
                           + 'well as conditions like being poisoned. '
                           + 'Heals the stack to full hit points and revives '
                           + 'up to 1 dead creature.';
      spBadLuck:      s := 'Stack deals minimum damage ' + fordur;
      spGoodLuck:     s := 'Stack deals maximum damage ' + fordur;
      spSwarm:        s := 'Deals ' + vs + ' damage to a stack now, '
                           + 'and each round ' + fordur;
      spGrow:         s := 'Stack has +' + vs + '% hit points ' + fordur;
      spBlow:         s := 'Pushes stack 3 hexes away from hero.';
      spDeserter:     s := 'Kills one creature in a stack.';
      spFury:         s := 'Stack deals +' + vs + '% damage ' + fordur;
      spFly:          s := 'Stack gains flying ' + fordur;
      spFireBolt:     s := 'Deals ' + vs + ' damage to a stack, and sets '
                           + 'that hex on fire (which will deal 200 damage '
                           + 'if the stack starts a turn there).';
      spTraitor:      s := 'Gain control of one creature in stack (you keep '
                           + 'it after combat if you have space).';
      spFatigue:      s := 'Stack has -' + vs + '% speed ' + fordur;
      spConjure:      s := 'Creates ' + vs + ' Bunnies, which you lose at '
                           + 'the end of combat.';
      spMindBlank:    s := 'Stack loses its abilities ' + fordur;
      spMudBall:      s := 'Deals ' + vs + ' damage to a stack, and douses '
                           + 'that hex with water (which will slow down '
                           + 'the stack if it starts a turn there and '
                           + 'doesn''t fly).';
      spMentalBlast:  s := 'Deals ' + vs + ' damage to each enemy stack.';
      spShrink:       s := 'Stack has -' + vs + '% hit points ' + fordur;
      spAgility:      s := 'Stack has +' + vs + '% speed ' + fordur;
      spWeakness:     s := 'Stack deals -' + vs + '% damage ' + fordur;
      spIceBolt:      s := 'Deals ' + vs + ' damage to a stack, and that '
                           + 'stack has -2 speed ' + fordur;
      spSicken:       s := 'Stack is stunned (it can''t move on its next '
                           + 'turn) and diseased (it has -2 hit points, '
                           + '-2 damage, and -1 speed).';
      spMagicBow:     s := 'Stack has a range attack ' + fordur;
      spWoe:          s := 'All enemy stacks have -' + vs + '% hit points, '
                           + 'damage, and speed, ' + fordur;
      spGrenade:      s := 'Deals ' + vs + ' damage to a hex and each '
                           + 'adjacent hex, destroying any obstacles.';
      spVengeance:    s := 'Stack retaliates against attacks ' + fordur;
      spFireShield:   s := 'Sets on fire each hex adjacent to a friendly '
                           + 'stack, but not those containing friendly '
                           + 'stacks.';
      spJoy:          s := 'All friendly stacks have +' + vs + '% hit points, '
                           + 'damage, and speed, ' + fordur;
      spKill:         s := 'Kills ' + vs + ' creature' + plural + ' in a '
                           + 'stack.';
      spVampire:      s := 'Stack has the drain life ability (as per '
                           + 'Mosquito Clouds), ' + fordur;
      spMultiply:     s := 'Stack gains +' + vs + '% creatures (you keep '
                           + 'them after combat).';
      spRenew:        s := 'Stack gets an extra turn this round.';
      spPolymorph:    s := 'Turns a stack into the next lowest level creature '
                           + 'for its castle type, ' + fordur + ' Does not '
                           + 'affect 1st level creatures.';
      spShapeshift:   s := 'Turns a stack into the next highest level '
                           + 'creature for its castle type, ' + fordur
                           + ' Does not affect 6th level creatures.';
      spInferno:      s := 'Deals ' + vs + ' damage to each enemy stack, and '
                           + 'sets all those hexes on fire (which will deal '
                           + '200 damage if a stack starts a turn there).';
      spSummon:       s := 'Creates ' + vs + ' random 3rd level creatures, '
                           + 'which you lose at end of combat.';
    end;

    SpellHint := s;
  end;

function SpellHintStr(sp, h, pl: integer): string;
  var
    s: string;
    v, dur, mag, t: integer;
  begin
    if h = 0 then begin
      v := SpellPowerValue(sp, 1, 1);
      dur := 1;
      if pl <> 0 then begin
        mag := Player[pl].SpellMines[smMagician];
        inc(v, (v * mag) div 5);
        if not (sp in [spSwarm, spIceBolt, spFury, spGrow, spAgility, spShrink,
                       spWeakness, spFatigue, spJoy, spWoe, spMultiply]) then
          inc(dur, mag);
      end;
    end else begin
      v := HeroSpellValue(h, sp);
      dur := HeroSpellDur(h, sp);
    end;
    s := chr(SpellSlantColor[SpellData[sp].slant]) + SpellData[sp].name
         + chr(colLightGray) + ' - ' + SpellHint(sp, v, dur);
    if (h <> 0) and SpellData[sp].targets then begin
      t := 1 + GetEffSkillLevel(h, skSorcery);
      s := s + ' ' + IStr(t, 0) + ' target';
      if t > 1 then s := s + 's';
      s := s + '.';
    end;
    SpellHintStr := s;
  end;

{ unit initialization }

end.
