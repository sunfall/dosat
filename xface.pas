unit xface;

{ misc user interace stuff }

interface

uses Monsters;

const
  dgMonster = 0;
  dgOK = 64;
  dgXP = 65;
  dgGold = 66;
  dgSpell = 67;
  dgCancel = 68;
  dgBuy1 = 69;
  dgBuyAll = 70;
  dgComputer = 71;
  dgArtifact = 128;

  dgcFace = #16;

type
  TDialogRec = record
    pic: integer;
    s: string;
  end;

  TDialogArr = array [1..8] of TDialogRec;
  PDialogArr = ^TDialogArr;

function BaseDialog(s: string; pic1, pic2, pic3, pic4: integer;
                    s1, s2, s3, s4: string): integer;
function BaseDialogN(s: string; PDA: PDialogArr; choices: integer): integer;
procedure BaseMessage(s: string);
function VictoryMessage(s: string; AS1, AS2: PArmySet; slots: integer): integer;
procedure ArmyMessage(h, slots: integer; AS: PArmySet; s: string; eye: boolean);

implementation

uses Drivers, LowGr, XMouse, Artifact, Castles, Heroes, MapScr;

const
  DialogGr: array [64..71] of TGraphic =
  (
    ('..........', { ok }
     '..........',
     '........**',
     '.......**.',
     '......**..',
     '.....**...',
     '.**.**....',
     '..***.....',
     '...*......',
     '..........'),
    ('..........', { xp }
     '..*****...',
     '.*.....*..',
     '*.......*.',
     '*.**.**.*.',
     '*.......*.',
     '.*..*..*..',
     '..*.*.*...',
     '..*...*...',
     '...***....'),
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
    ('......*...', { spell }
     '.....**...',
     '....**....',
     '...***....',
     '..******..',
     '..******..',
     '....***...',
     '....**....',
     '...**.....',
     '...*......'),
    ('...****...', { cancel }
     '..*    *..',
     '.*    ***.',
     '*    *** *',
     '*   ***  *',
     '*  ***   *',
     '* ***    *',
     '.***    *.',
     '..*    *..',
     '...****...'),
    ('..........', { buy 1 }
     '.....*....',
     '....**....',
     '...***....',
     '...***....',
     '....**....',
     '....**....',
     '....**....',
     '..******..',
     '..******..'),
    ('..........', { buy all }
     '..........',
     '....**....',
     '....**....',
     '..******..',
     '..******..',
     '....**....',
     '....**....',
     '..........',
     '..........'),
    ('.********.', { computer }
     '.*......*.',
     '.*.****.*.',
     '.*.*..*.*.',
     '.*.*..*.*.',
     '.*.****.*.',
     '.*......*.',
     '.*..***.*.',
     '.*......*.',
     '.********.')
  );

procedure DrawDialogBox(x1, y1, x2, y2: integer);
  var i, j: integer;
  begin
    ClearArea(x1, y1, x2, y2);

    XRectangle(x1 + 1, y1 + 1, x2 - 2, y2 - 2, colLightGray);
    XRectangle(x1 + 3, y1 + 3, x2 - 4, y2 - 4, colYellow);
    XRectangle(x1 + 5, y1 + 5, x2 - 6, y2 - 6, colLightGray);
  end;

procedure DrawDialogButton(x1, y, x2, fc, bc: integer; s: string; pic: PGraphic);
  var
    db: boolean;
    tx1, tx2: integer;
  begin
    db := DrawBackground;
    DrawBackground := true;
    BackgroundColor := colDarkGray;

    DrawGraphic2c(x1, y, fc, bc, pic^, false);
    XRectangle(x1 - 1, y - 1, x1 + 30, y + 30, colDarkGray);
    XRectangle(x1 - 2, y - 2, x1 + 31, y + 31, colLightGray);
    tx1 := x1 + 32 + 8;
    tx2 := x2 - 8;
    DrawBoxText(tx1, y + 14 - BoxTextLines(tx1, tx2, s) * 5, tx2,
                colBlack, colWhite, s);

    BackgroundColor := colGreen;
    DrawBackground := db;
  end;

function GetDialogChoice(bx, bx2, by, byht, numpics, fx, fy: integer): integer;
  var
    E: TEvent;
    over: boolean;
    x, y, choice: integer;
  begin
    over := false;

    repeat
      WaitForEvent(E);
      if E.What = evMouseDown then begin
        x := E.Where.X;
        y := E.Where.Y;
        choice := 0;
        if E.Buttons = mbLeftButton then begin
          if (y >= by - 2) and ((y - (by - 2)) mod byht < 33) then begin
            if (x >= bx - 2) and (x <= bx + 31) then
              choice := (y - (by - 2)) div byht + 1
            else if (bx2 <> 0) and (x >= bx2 - 2) and (x <= bx2 + 31) then
              choice := (y - (by - 2)) div byht + 1 + (numpics + 1) div 2;
          end;
        end else if E.Buttons = mbRightButton then begin
          if (fx <> 0) and (x >= fx) and (x < fx + 36)
             and (y >= fy) and (y < fy + 36) then
            choice := -1;
        end;
        if (choice = -1) or ((choice >= 1) and (choice <= numpics)) then
          over := true;
      end;
    until over;

    GetDialogChoice := choice;
  end;

procedure DrawPicButton(x1, y, x2: integer; s: string; pic: integer);
  var
    pgr: PGraphic;
    fc, bc: integer;
  begin
    if (pic >= low(DialogGr)) and (pic <= high(DialogGr)) then begin
      pgr := @DialogGr[pic];
      if pic = dgGold then
        fc := colYellow
      else
        fc := colLightGray;
      bc := colBlack;
    end else if (pic <= 6 * (ord(high(TCastleType)) + 1))
                and (pic >= 1) then begin
      pgr := MonsterGraphic(pic);
      fc := colLightBlue;
      bc := colBlack;
    end else if (pic >= dgArtifact) then begin
      pgr := @ArtGraphics[ArtData[pic - dgArtifact].gr];
      fc := ArtData[pic - dgArtifact].fcol;
      bc := ArtData[pic - dgArtifact].bcol;
    end else
      pgr := nil;

    if pgr <> nil then
      DrawDialogButton(x1, y, x2, fc, bc, s, pgr);
  end;

function BaseDialog(s: string; pic1, pic2, pic3, pic4: integer;
                    s1, s2, s3, s4: string): integer;
  const
    dx1 = 48;
    dx2 = 432 + 32;
    midy = 240;
  var
    i, j, numpics, ywid, y1, y2, x, y, pic, tx1, tx2: integer;
    yofs, ypic, faceofs, fx, fy, bd, h: integer;
  begin
    if pic4 <> 0 then numpics := 4
    else if pic3 <> 0 then numpics := 3
    else if pic2 <> 0 then numpics := 2
    else if pic1 <> 0 then numpics := 1
    else begin
      numpics := 1;
      pic1 := dgOK;
      s1 := 'OK';
    end;

    if s[1] = dgcFace then
      faceofs := 40
    else
      faceofs := 0;

    ywid := 64 * numpics + 64 + 32 + faceofs;
    y1 := midy - ywid div 2;
    y2 := midy + ywid div 2;

    if s[1] = dgcFace then begin
      fx := dx1 + 32;
      fy := y1 + 16;
      h := ord(s[2]);
      s := copy(s, 3, 255);
    end else begin
      fx := 0;
    end;

    if length(s) > 150 then
      yofs := 16
    else
      yofs := 0;

    DrawDialogBox(dx1, y1, dx2, y2);

    if faceofs <> 0 then
      DrawHero(fx, fy, colLightGray, h);

    DrawBoxText(dx1 + 32, y1 + 32 - yofs + faceofs, dx2 - 24, colBlack,
                colWhite, s);

    for j := 1 to 4 do
      if numpics >= j then begin
        ypic := y1 + 96 + yofs + 64 * (j - 1) + faceofs;

        case j of
          1: begin  pic := pic1; s := s1;  end;
          2: begin  pic := pic2; s := s2;  end;
          3: begin  pic := pic3; s := s3;  end;
          4: begin  pic := pic4; s := s4;  end;
        end;

        DrawPicButton(dx1 + 64, ypic, dx2, s, pic);
      end;

    BaseDialog := GetDialogChoice(dx1 + 64, 0, y1 + 96 + yofs + faceofs, 64,
                                  numpics, fx, fy);
  end;

procedure BaseMessage(s: string);
  begin
    BaseDialog(s, 0, 0, 0, 0, '', '', '', '');
  end;

function BaseDialogN(s: string; PDA: PDialogArr; choices: integer): integer;
  const
    dx1 = 48;
    dx2 = 432 + 32;
    midy = 240;
  var
    i, j, ywid, y1, y2, x, y, tx1, tx2: integer;
    xpic, xpic2, ypic, faceofs, fx, fy: integer;
  begin
    if s[1] = dgcFace then
      faceofs := 40
    else
      faceofs := 0;

    ywid := 64 * ((choices + 1) div 2) + 64 + 32 + faceofs;
    y1 := midy - ywid div 2;
    y2 := midy + ywid div 2;

    DrawDialogBox(dx1, y1, dx2, y2);

    if faceofs <> 0 then begin
      fx := dx1 + 32;
      fy := y1 + 16;
      DrawHero(fx, fy, colLightGray, ord(s[2]));
      s := copy(s, 3, 255);
    end else
     fx := 0;

    DrawBoxText(dx1 + 32, y1 + 32 + faceofs, dx2 - 24, colBlack, colWhite, s);

    for j := 1 to 8 do
      if j <= choices then begin
        if j <= (choices + 1) div 2 then begin
          xpic := dx1 + 64;
          xpic2 := (dx1 + dx2) div 2;
          ypic := y1 + 96 + faceofs + 64 * (j - 1);
        end else begin
          xpic := (dx1 + dx2) div 2;
          xpic2 := dx2;
          ypic := y1 + 96 + faceofs + 64 * (j - 1 - (choices + 1) div 2);
        end;

        DrawPicButton(xpic, ypic, xpic2, PDA^[j].s, PDA^[j].pic);
      end;

    BaseDialogN := GetDialogChoice(dx1 + 64, (dx1 + dx2) div 2,
                                   y1 + 96 + faceofs, 64, choices, fx, fy);
  end;

function VictoryMessage(s: string; AS1, AS2: PArmySet; slots: integer): integer;
  const
    vx1 = 48;
    vx2 = 464;
    vy1 = 240 - 128;
    vy2 = 240 + 128;
  var
    i, x, y, faceofs, fx, fy, vm: integer;
    db: boolean;
  begin
    db := DrawBackground;
    DrawBackground := false;

    if s[1] = dgcFace then
      faceofs := 40
    else
      faceofs := 0;

    DrawDialogBox(vx1, vy1 - faceofs div 2, vx2, vy2 + faceofs div 2);

    y := vy1 + faceofs div 2;

    if faceofs <> 0 then begin
      fx := vx1 + 32;
      fy := vy1 - faceofs div 2 + 16;
      DrawHero(fx, fy, colLightGray, ord(s[2]));
      s := copy(s, 3, 255);
    end else
      fx := 0;

    DrawBoxText(vx1 + 32, y + 32, vx2 - 24, colBlack, colWhite, s);
    DrawBoxText(vx1 + 32 + 8, y + 80 - 12, vx2 - 24, colBlack, colLightGray,
                'Losses');
    DrawBoxText(vx1 + 32 + 8, y + 144 - 12, vx2 - 24, colBlack, colLightGray,
                'Gains');

    for i := 1 to slots do begin
      x := vx1 + i * 40;
      DrawArmyBox(x, y + 80, colLightGray, colRed, colWhite,
                  AS1^[i], false);
      DrawArmyBox(x, y + 144, colLightGray, colLightBlue, colWhite,
                  AS2^[i], false);
    end;

    DrawDialogButton(vx1 + 64, y + 208, vx2, colLightGray, colBlack, 'OK',
                     @DialogGr[dgOK]);

    vm := GetDialogChoice(vx1 + 64, 0, y + 208, 64, 1, fx, fy);

    DrawBackground := db;

    VictoryMessage := vm;
  end;

procedure ArmyMessage(h, slots: integer; AS: PArmySet; s: string; eye: boolean);
  const
    vx1 = 48;
    vx2 = 464;
    vy1 = 240 - 96;
    vy2 = 240 + 96;
  var
    i, c, x, y: integer;
    db, over: boolean;
    E: TEvent;
  begin
    db := DrawBackground;
    DrawBackground := false;

    DrawDialogBox(vx1, vy1, vx2, vy2);
    DrawHero(vx1 + 40, vy1 + 16 + 14, colLightGray, h);
    if s <> '' then
      DrawText(vx1 + 40 + 36 + 8, vy1 + 16 + 14 + 14, colBlack, colLightGray,
               s);
    if eye then c := colWhite else c := colInvisible;
    for i := 1 to slots do
      DrawArmyBox(vx1 + i * 40, vy1 + 80, colLightGray, colLightBlue, c,
                  AS^[i], false);

    DrawDialogButton(vx1 + 64, vy1 + 144, vx2, colLightGray, colBlack, 'OK',
                     @DialogGr[dgOK]);

    over := false;

    repeat
      WaitForEvent(E);
      if E.What = evMouseDown then begin
        x := E.Where.X;
        y := E.Where.Y;
        if E.Buttons = mbLeftButton then begin
          if (x >= vx1 + 64 - 2) and (x <= vx1 + 64 + 31)
             and (y >= vy1 + 144 - 2) and (y <= vy1 + 144 - 2 + 31) then
            over := true;
        end else if E.Buttons = mbRightButton then begin
          if (y >= vy1 + 80) and (y < vy1 + 80 + 40) then begin
            i := (x - vx1) div 40;
            if (i >= 1) and (i <= slots) and (AS^[i].qty > 0) then begin
              ClearArea(WindowX, WindowY, 639, 479);
              XRectangle(WindowX - 3, WindowY - 3, 639, 479, colDarkGray);
              DrawBoxText(WindowX, WindowY, WindowX2, colBlack, colWhite,
                          MonsterDescription(AS^[i].monster, AS^[i].qty,
                                              '', eye));
            end;
          end;
        end;
      end;
    until over;

    DrawBackground := true;
  end;

{ unit initialization }

end.
