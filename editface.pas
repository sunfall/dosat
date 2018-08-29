program editface;

{ face editor for hommx }

uses Drivers, XMouse, XSVGA, LowGr, XStrings;

const
  NumFeatures = 60;
  NumHeroes = 10 * 14;

type
  TFeature = array [1..32, 1..32] of byte;
  TFT = (fHead, fHair, fEyes, fMouth, fNose, fEyebrows, fMisc);

  TFeatureRec = record
    pix: TFeature;
    ft: TFT;
  end;

  TFace = array [1..8] of byte;

  TFeatures = array [1..NumFeatures] of TFeatureRec;
  PFeatures = ^TFeatures;

var
  Features: PFeatures;
  Faces: array [1..NumHeroes] of TFace;

const
  FeatureNames: array [TFT] of string =
  (
    'Head', 'Hair', 'Eyes', 'Mouth', 'Nose', 'Eyebrows', 'Misc'
  );

  HeroNames: array [1..NumHeroes] of string[21] =
  (
    'Snidd', 'Gnarr', 'Darba',
    'Baloth', 'Lorian', 'Brackus',
    'Undorak', 'Gourna', 'Kavu',
    'Vorine', 'Vorrac', 'Bulvox',
    'Garh', 'Murlodont',
    'Raphael', 'Gabriel', 'Alexandre',
    'Olivier', 'Antoine', 'Nicolas',
    'Florent', 'Pierre', 'Aurelien',
    'Gilles', 'Sylvain', 'Romain',
    'Christophe', 'Sebastien',
    'Skuld', 'Bragi', 'Idun',
    'Urd', 'Aurvandil', 'Tyr',
    'Heimdallr', 'Verdandi', 'Aegir',
    'Baldur', 'Gefjun', 'Ullr',
    'Skadi', 'Hel',
    '"Biscuits" O''Malley', '"Thunder" Hopkins', '"Farmstead" Johnson',
    'Benny "The Biter"', 'Kevin "The Carver"', '"Brains" Ratcliffe',
    '"Savoir" O''Farrell', '"Corduroy" Brown', '"Hotfoot" Donovan',
    'Shandy "The Shuttler"', 'Mickey Istari', '"Cheesecloth" McGinty',
    'Joey "Nickels"', '"Spats" Martin',
    'Deep Thought', 'HAL', 'Data',
    'Tobor', 'Robby', 'TX-1000',
    'R2-D2', 'ED209', 'Roy Batty',
    'Pris', 'C3-P0', 'Marvin',
    'Gort', 'Agent Smith',
    'Dr. Doolittle', 'Dr. Brain', 'Dr. Doom',
    'Dr. Kildare', 'Dr. No', 'Dr. Strange',
    'Dr. Moreau', 'Dr. T', 'Dr. Strangelove',
    'Dr. Evil', 'Dr. Robert', 'Dr. Octopus',
    'Dr. Jekyll', 'Dr. Death',
    'Osiris', 'Anubis', 'Set',
    'Ma''at', 'Khnum', 'Horus',
    'Isis', 'Amun', 'Ptah',
    'Thoth', 'Ra', 'Nekhbet',
    'Nephthys', 'Sobek',
    'Hector', 'Theseus', 'Hercules',
    'Achilles', 'Perseus', 'Bellerophon',
    'Autolycus', 'Odysseus', 'Orion',
    'Jason', 'Aeneas', 'Meleager',
    'Nestor', 'Orpheus',
    'Bozo', 'Krusty', 'Pierrot',
    'Harlequin', 'Yorick', 'Joker',
    'Chuckles', 'Buttons', 'Clarabell',
    'Pennywise', 'Shakes', 'Arlecchino',
    'Calvero', 'Koko',
    'Father O''Flynn', 'Father O''Blivion', 'Father O''Calcutta',
    'Father O''Rly', 'Father William', 'Sister Disco',
    'Sister Suzy', 'Sister Ray', 'Sister Midnight',
    'Sister O''Mercy', 'Brother Maynard', 'Uncle Ernie',
    'Friar Tuck', 'Joey the Altar Boy'
  );

{
  circus -

    bozo                       leadership / alchemy
    krusty                     specialty  / tactics
    pierrot (b&w french)       wizardry   / sorcery
    harlequin                  cunning    / lore
    yorick                     lore       / wizardry
    joker                      tactics    / cunning
    chuckles (killed on mtm)   lore       / sorcery
    buttons                    leadership / tactics
    clarabell                  gating     / leadership
    pennywise (horror)         witchcraft / specialty
    shakes (alcoholic)         alchemy    / gating
    arlecchino (opera)         sorcery    / witchcraft
    calvero (chaplin)          specialty  / gating
    koko                       wizardry   / witchcraft

  evil temple -

    father o'flynn             summoning   / pathfinding
    father o'blivion           summoning   / dark arts
    father o'calcutta          defense     / power
    father o'rly               spellcraft  / healing
    father william             summoning   / offense
    sister disco               pathfinding / spellcraft
    sister suzy                dark arts   / persuasion
    sister ray                 power       / spellcraft
    sister midnight            dark arts   / power
    sister o'mercy             healing     / defense
    brother maynard            archery     / healing
    uncle ernie                persuasion  / offense
    friar tuck                 offense     / defense
    joey the altar boy         pathfinding / archery
}

procedure DrawBigPixel(x, y, c: integer);
  var i, j, c1, c2: integer;
  begin
    if c = 255 then begin
      c1 := colBlack;
      c2 := colDarkGray;
    end else begin
      c1 := c;
      c2 := c;
    end;

    for i := 0 to 7 do
      for j := 0 to 7 do
        if (i = 0) or (j = 0) then
          XPutPixel(x + i, y + j, colBlack)
        else if (i + j) mod 2 = 0 then
          XPutPixel(x + i, y + j, c1)
        else
          XPutPixel(x + i, y + j, c2);
  end;

procedure Print(x, y: integer; s: string; len: integer);
  const blank: string = 'лллллллллллллллллллллллллллллллллллллллл';
  begin
    DrawText(x, y, colBlack, colWhite, LSet(s, len));
  end;

procedure DrawFeatureName(f: integer);
  begin
    Print(0, 280, FeatureNames[Features^[f].ft], 10);
  end;

procedure DrawBigFeature(f: integer);
  var x, y: integer;
  begin
    for x := 1 to 32 do
      for y := 1 to 32 do
        DrawBigPixel((x - 1) * 8, (y - 1) * 8, Features^[f].pix[x, y]);
  end;

procedure DrawPalette(c: integer);
  var
    i, ic: integer;
    ch: char;
  begin
    for i := 0 to 16 do begin
      if i = 16 then ic := 255 else ic := i;
      DrawBigPixel(i * 8, 264, ic);
      if ic = c then ch := '^' else ch := ' ';
      Print(i * 8, 264 + 8, ch, 1);
    end;
  end;

procedure DrawFace(x, y: integer; f: TFace);
  var
    px: array [1..32, 1..32] of byte;
    n, c, i, j, redc, brownc: integer;
  begin
    fillchar(px, sizeof(px), chr(colDarkBlue));
    redc := colRed;
    brownc := colBrown;

    case f[1] of
      2: begin redc := colDarkGray;  brownc := colBlack; end;
      3: begin redc := colDarkGreen; brownc := colBlack; end;
      4: begin redc := colBlue;      brownc := colBlack; end;
      5: begin redc := colLightGray; brownc := colBlack; end;
      6: begin redc := colBlack;     brownc := colBlack; end;
    end;

    for n := 1 to 8 do
      if f[n] <> 0 then
        for i := 1 to 32 do
          for j := 1 to 32 do begin
            c := Features^[f[n]].pix[i, j];
            if n <> 1 then begin
              if c = colRed then
                c := redc
              else if c = colBrown then
                c := brownc;
            end;
            if c <> 255 then px[i, j] := c;
          end;

    for i := 1 to 32 do
      for j := 1 to 32 do
        XPutPixel(x + i - 1, y + j - 1, px[i, j]);
  end;

procedure DrawPossibilities(h, idx: integer);
  var
    i: integer;
    f: TFace;
  begin
    for i := 1 to NumFeatures do begin
      f := Faces[h];
      f[idx] := i;
      DrawFace(320 + ((i - 1) mod 8) * 40, ((i - 1) div 8) * 40, f);
    end;
  end;

procedure DrawHeroFeatures(h, idx: integer);
  var
    i: integer;
    f: TFace;
    ch: char;
  begin
    fillchar(f, sizeof(f), #0);
    for i := 1 to 8 do begin
      f[1] := Faces[h, i];
      DrawFace(320 + (i - 1) * 40, 320 + 16, f);
      if i = idx then ch := '^' else ch := ' ';
      Print(320 + (i - 1) * 40 + 12, 320 + 16 + 32, ch, 1);
    end;

    Print(320, 320 + 64, HeroNames[h], 21);

    DrawFace(320, 320 + 64 + 12, Faces[h]);
  end;

procedure ClearData;
  var i: integer;
  begin
    for i := 1 to NumFeatures do begin
      FillChar(Features^[i].pix, sizeof(Features^[i].pix), #255);
      Features^[i].FT := fMisc;
    end;
    FillChar(Faces, sizeof(Faces), #0);
  end;

procedure LoadData;
  var f: file;
  begin
    assign(f, 'faces.pic');
    reset(f, 1);
    blockread(f, Features^, sizeof(Features^));
    blockread(f, Faces, sizeof(Faces));
    close(f);
  end;

procedure SaveData;
  var f: file;
  begin
    assign(f, 'faces.pic');
    rewrite(f, 1);
    blockwrite(f, Features^, sizeof(Features^));
    blockwrite(f, Faces, sizeof(Faces));
    close(f);
  end;

procedure run;
  var
    over: boolean;
    E: TEvent;
    FeatureNum: integer;
    HeroNum: integer;
    ColorNum: integer;
    Section: integer;
    x, y, n: integer;
    p: TFeature;

  procedure Draw;
    begin
      DrawPalette(ColorNum);
      DrawBigFeature(FeatureNum);
      DrawFeatureName(FeatureNum);
      DrawPossibilities(HeroNum, Section);
      DrawHeroFeatures(HeroNum, Section);
    end;

  procedure DrawFamily;
    var h, i: integer;
    begin
      h := HeroNum - 1;
      h := h - (h mod 14);
      inc(h);
      for i := 0 to 13 do
        DrawFace((i mod 7) * 40, 320 + 64 + 12 + (i div 7) * 40, Faces[h + i]);
    end;

  procedure MakeCircle;
    var i, j: integer;
    begin
      for i := 1 to 32 do
        for j := 1 to 32 do
          if sqr(i - 16.5) + sqr(j - 16.5 - 2) <= sqr(12) then
            Features^[FeatureNum].pix[i, j] := ColorNum;
    end;

  begin
    InitEvents;
    InitSVGA;
    SetSVGAMode;
    SetPalette;
    ClearScr;

    New(Features);
    ClearData;

    FeatureNum := 1;
    HeroNum := 1;
    ColorNum := 1;
    Section := 1;
    fillchar(p, sizeof(p), #255);
    over := false;

    LoadData;
    Draw;

    repeat
      WaitForEvent(E);
      if E.What = evKeyDown then begin
        case E.charcode of
          #27: over := true;
        end;
        case E.keycode of
          kbLeft:  FeatureNum := ((FeatureNum - 1 + NumFeatures - 1) mod NumFeatures) + 1;
          kbRight: FeatureNum := (((FeatureNum - 1) + 1) mod NumFeatures) + 1;
          kbPgUp:  FeatureNum := ((FeatureNum - 1 + NumFeatures - 8) mod NumFeatures) + 1;
          kbPgDn:  FeatureNum := (((FeatureNum - 1) + 8) mod NumFeatures) + 1;
          kbUp:    HeroNum := ((HeroNum - 1 + NumHeroes - 1) mod NumHeroes) + 1;
          kbDown:  HeroNum := (((HeroNum - 1) + 1) mod NumHeroes) + 1;
          kbHome:  HeroNum := ((HeroNum - 1 + NumHeroes - 14) mod NumHeroes) + 1;
          kbEnd:   HeroNum := (((HeroNum - 1) + 14) mod NumHeroes) + 1;
          kbAltL:  LoadData;
          kbAltS:  SaveData;
          kbAltC:  MakeCircle;
          kbAltG:  p := Features^[FeatureNum].pix;
          kbAltU:  Features^[FeatureNum].pix := p;
          kbAltF:  DrawFamily;
{
  face randomizer
}
        end;
        if not over then Draw;
      end;
      if E.What = evMouseDown then begin
        if E.Buttons = mbLeftButton then begin
          x := E.Where.X;
          y := E.Where.Y;

          if (x < 256) and (y < 256) then begin
            x := x div 8;
            y := y div 8;
            Features^[FeatureNum].pix[x + 1, y + 1] := ColorNum;
            DrawBigPixel(x * 8, y * 8, Features^[FeatureNum].pix[x + 1, y + 1]);
          end else if (y >= 280) and (y < 280 + 8) and (x < 10 * 8) then begin
            if Features^[FeatureNum].ft = high(TFT) then
              Features^[FeatureNum].ft := low(TFT)
            else
              inc(Features^[FeatureNum].ft);
            DrawFeatureName(FeatureNum);
          end else if (y >= 264) and (y < 264 + 8) and (x < 17 * 8) then begin
            x := x div 8;
            if x < 16 then ColorNum := x else ColorNum := 255;
            DrawPalette(ColorNum);
          end else if (x >= 320) and (y < 320) then begin
            x := (x - 320) div 40;
            y := y div 40;
            n := x + y * 8 + 1;
            if n <= NumFeatures then begin
              Faces[HeroNum][Section] := n;
              if Section < 8 then inc(Section);
              DrawPossibilities(HeroNum, Section);
              DrawHeroFeatures(HeroNum, Section);
            end;
          end else if (x >= 320) and (y >= 320 + 16)
                      and (y < 320 + 16 + 32) then begin
            x := (x - 320) div 40 + 1;
            if x <= 8 then begin
              Section := x;
              DrawPossibilities(HeroNum, Section);
              DrawHeroFeatures(HeroNum, Section);
            end;
          end;
        end else if E.Buttons = mbRightButton then begin
          x := E.Where.X;
          y := E.Where.Y;

          if (x < 256) and (y < 256) then begin
            x := x div 8;
            y := y div 8;
            Features^[FeatureNum].pix[x + 1, y + 1] := 255;
            DrawBigPixel(x * 8, y * 8, Features^[FeatureNum].pix[x + 1, y + 1]);
          end else if (x >= 320) and (y >= 320 + 16)
                      and (y < 320 + 16 + 32) then begin
            x := (x - 320) div 40 + 1;
            if x <= 8 then begin
              Faces[HeroNum][x] := 0;
              DrawPossibilities(HeroNum, Section);
              DrawHeroFeatures(HeroNum, Section);
            end;
          end else if (x >= 320) and (y < 320) then begin
            x := (x - 320) div 40;
            y := y div 40;
            n := x + y * 8 + 1;
            if n <= NumFeatures then begin
              FeatureNum := n;
              DrawBigFeature(FeatureNum);
              DrawFeatureName(FeatureNum);
            end;
          end;
        end;
      end;
    until over;

    Dispose(Features);
    CloseGraphics;
    DoneSVGA;
    DoneEvents;
  end;

begin
  run;
end.
