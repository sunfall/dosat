unit XStrings;

{ LIBDESC XStrings  - low-level string manipulation routines }
{ LIBINFO XStrings  - CMD none   REG none   }

{$R-}
{$V-}

interface

const
  Blank: string[160] = '                                        ' +
                       '                                        ' +
                       '                                        ' +
                       '                                        ';
  Dash: string[160] =  '----------------------------------------' +
                       '----------------------------------------' +
                       '----------------------------------------' +
                       '----------------------------------------';
  Zeros: string[40]  = '0000000000000000000000000000000000000000';
  Hidden: string[160] = #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255
                        + #255+#255+#255+#255+#255+#255+#255+#255+#255+#255;

  { character constants }

  CrLf = #13 + #10;

  { constants for adjusting strings }

  ajLeft    = 0;
  ajRight   = 1;
  ajCenter  = 2;
  ajEmbed   = 3;
  ajSLeft   = 4;
  ajSRight  = 5;
  ajSCenter = 6;
  ajSEmbed  = 7;

  { constants for undefined variables }

  udInteger = -32768;
  udReal    = -1.7e38;
  udString  = '';

  mnInteger = -32767;
  mxInteger = 32767;
  mnReal    = -1.7e37;
  mxReal    = 1.7e38;

type
  PCharSet = ^CharSet;
  CharSet = set of char;

  PByte    = ^byte;
  PWord    = ^word;
  PInteger = ^integer;
  PLongint = ^longint;
  PPointer = ^pointer;
  PReal    = ^real;

function StripSpaces(mystr: string): string;
function StripLeft(s: string): string;
function StripRight(s: string): string;
function StripSides(mystr: string): string;
function EmptyStr(mystr: string): boolean;
function Spaces(len: byte): string;
function Dashes(len: byte): string;
function StripTabs(s: string; tabsize: integer): string;

function SLSet(mystr: string; len: integer): string;
function SRSet(mystr: string; len: integer): string;
function SCSet(mystr: string; len: integer): string;
function SESet(mystr: string; len: integer): string;
function LSet(mystr: string; len: integer): string;
function RSet(mystr: string; len: integer): string;
function CSet(mystr: string; len: integer): string;
function ESet(mystr: string; len: integer): string;
function ASet(Adjust: byte; mystr: string; len: integer): string;
function SHRSet(mystr: string; len: integer): string;
function HRSet(mystr: string; len: integer): string;

function UpCaseStr(mystr: string): string;
function PadZeros(mystr: string; len: integer): string;
function LimitChars(mystr: string; chars: charset): string;
procedure SubStr(var mystr: string; s: string; i: integer);
procedure SubAdjStr(var s1: string; s2: string; a, l, i: integer);

function IStr(n, a: integer): string;
function LStr(n: longint; a: integer): string;
function RemoveTrailingZeros(s: string): string;
function ERStr(r: real): string;
function RStr(n: real; a, b: integer): string;
function ValPrep(mystr: string): string;
function IVal(mystr: string): integer;
function RVal(mystr: string): real;
function DelimPos(mystr: string): integer;
procedure DelimStrToReals(mystr: string; var r1, r2: real);
procedure DelimStrTo3Reals(mystr: string; var r1, r2, r3: real);
function HexStr(i: longint; d: integer): string;
function HexToDec(s: string): longint;
function RToI(r: real): integer;
function LimitI(i, min, max: integer): integer;
function LimitIorUndef(i, min, max: integer): integer;

procedure RemoveAndCharsBefore(var mystr: string; pstr: string);
procedure RemoveAndCharBefore(var mystr: string; pstr: string);
procedure RemoveAndCharsAfter(var mystr: string; pstr: string);
procedure RemoveCharsBefore(var mystr: string; pstr: string);

function PtrToStr(p: pointer): string;
function StrToPtr(s: string): pointer;

function CharToText(ch: char): string;
function CharToASCII(ch: char): string;

implementation

function StripSpaces(mystr: string): string;
  begin
    while pos(' ', mystr) > 0 do delete(mystr, pos(' ', mystr), 1);
    StripSpaces := mystr;
  end;

function StripLeft(s: string): string;
  var i: integer;
  begin
    i := 1;
    while (i <= length(s)) and (s[i] = ' ') do inc(i);
    StripLeft := Copy(s, i, 255);
  end;

function StripRight(s: string): string;
  begin
    while s[length(s)] = ' ' do dec(s[0]);
    StripRight := s;
  end;

function StripSides(mystr: string): string;
  begin
    StripSides := StripLeft(StripRight(mystr));
  end;

function EmptyStr(mystr: string): boolean;
  begin
    EmptyStr := StripSides(mystr) = '';
  end;

function Spaces(len: byte): string;
  begin
    Spaces := Copy(Blank, 1, len);
  end;

function Dashes(len: byte): string;
  begin
    Dashes := Copy(Dash, 1, len);
  end;

function StripTabs(s: string; tabsize: integer): string;
  var i, j: integer;
  begin
    repeat
      i := pos(^I, s);
      if i > 0 then begin
        System.Delete(s, i, 1);
        j := tabsize - ((i - 1) mod tabsize);
        if j = 0 then j := tabsize;
        System.Insert(Spaces(j), s, i);
      end;
    until i = 0;
    StripTabs := s;
  end;

function SLSet(mystr: string; len: integer): string;
  begin
    mystr := mystr + Copy(Blank, 1, len - length(mystr));
    SLSet := Copy(mystr, 1, len);
  end;

function SRSet(mystr: string; len: integer): string;
  begin
    mystr := Copy(Blank, 1, len - length(mystr)) + mystr;
    SRSet := Copy(mystr, 1, len);
  end;

function SCSet(mystr: string; len: integer): string;
  begin
    mystr := Copy(Blank, 1, (len - length(mystr)) div 2) + mystr +
             Copy(Blank, 1, (len - length(mystr) + 1) div 2);
    SCSet := Copy(mystr, 1, len);
  end;

function SESet(mystr: string; len: integer): string;
  begin
    if length(mystr) > len then SESet := Copy(mystr, 1, len)
    else SESet := mystr;
  end;

function LSet(mystr: string; len: integer): string;
  begin
    LSet := SLSet(StripSides(mystr), len);
  end;

function RSet(mystr: string; len: integer): string;
  begin
    RSet := SRSet(StripSides(mystr), len);
  end;

function CSet(mystr: string; len: integer): string;
  begin
    CSet := SCSet(StripSides(mystr), len);
  end;

function ESet(mystr: string; len: integer): string;
  begin
    ESet := SESet(StripSides(mystr), len);
  end;

function ASet(Adjust: byte; mystr: string; len: integer): string;
  begin
    case Adjust of
      ajLeft:    ASet :=  LSet(mystr, len);
      ajRight:   ASet :=  RSet(mystr, len);
      ajCenter:  ASet :=  CSet(mystr, len);
      ajEmbed:   ASet :=  ESet(mystr, len);
      ajSLeft:   ASet := SLSet(mystr, len);
      ajSRight:  ASet := SRSet(mystr, len);
      ajSCenter: ASet := SCSet(mystr, len);
      ajSEmbed:  ASet := SESet(mystr, len);
    end;
  end;

function SHRSet(mystr: string; len: integer): string;
  begin
    mystr := Copy(Hidden, 1, len - length(mystr)) + mystr;
    SHRSet := Copy(mystr, 1, len);
  end;

function HRSet(mystr: string; len: integer): string;
  begin
    HRSet := SHRSet(StripSides(mystr), len);
  end;

function UpCaseStr(mystr: string): string;
  var i: integer;
  begin
    for i := 1 to length(mystr) do mystr[i] := UpCase(mystr[i]);
    UpCaseStr := mystr;
  end;

function PadZeros(mystr: string; len: integer): string;
  begin
    if (length(mystr) > 0) and (mystr[1] = '-') then
      mystr := '-' + Copy(Zeros, 1, len - length(mystr))
                   + Copy(mystr, 2, length(mystr) - 1)
    else
      mystr := Copy(Zeros, 1, len - length(mystr)) + mystr;
    PadZeros := Copy(mystr, 1, len);
  end;

function LimitChars(mystr: string; chars: charset): string;
  var i: integer;
  begin
    if length(mystr) > 0 then begin
      i := 1;
      repeat
        if not (mystr[i] in chars) then delete(mystr, i, 1)
        else inc(i);
      until i > length(mystr);
    end;
    LimitChars := mystr;
  end;

procedure SubStr(var mystr: string; s: string; i: integer);
  begin
    System.Delete(mystr, i, length(s));
    System.Insert(s, mystr, i);
  end;

procedure SubAdjStr(var s1: string; s2: string; a, l, i: integer);
  begin
    if (a = ajRight) or (a = ajSRight) then
      SubStr(s1, ASet(a, s2, l), i - l + 4)
    else
      SubStr(s1, ASet(a, s2, l), i);
  end;

function IStr(n, a: integer): string;
  var mystr: string[80];
  begin
    if a = 0 then Str(n, mystr) else Str(n:a, mystr);
    IStr := mystr;
  end;

function LStr(n: longint; a: integer): string;
  var mystr: string[80];
  begin
    if a = 0 then Str(n, mystr) else Str(n:a, mystr);
    LStr := mystr;
  end;

function RemoveTrailingZeros(s: string): string;
  begin
    while (length(s) > 0) and (s[length(s)] = '0') do
      delete(s, length(s), 1);
    if (length(s) > 0) and (s[length(s)] = '.') then delete(s, length(s), 1);
    RemoveTrailingZeros := s;
  end;

function ERStr(r: real): string;
  var s: string[50];
  begin
    Str(r:30:11, s);
    s := StripSides(s);
    if pos('.', s) > 0 then s := RemoveTrailingZeros(s);
    ERStr := s;
  end;

function RStr(n: real; a, b: integer): string;
  var mystr: string[80];
  begin
    if a = 0 then mystr := ERStr(n) else Str(n:a:b, mystr);
    RStr := mystr;
  end;

function ValPrep(mystr: string): string;
  begin
    mystr := StripSides(mystr);
    if (length(mystr) > 0) and (mystr[1] = '+') then delete(mystr, 1, 1);
    ValPrep := mystr;
  end;

function IVal(mystr: string): integer;
  var
    i: longint;
    err: integer;
  begin
    Val(ValPrep(mystr), i, err);
    if err <> 0 then i := udInteger
    else begin
      if i < mnInteger then i := mnInteger;
      if i > mxInteger then i := mxInteger;
    end;
    IVal := i;
  end;

function RVal(mystr: string): real;
  var
    r: real;
    err: integer;
  begin
    Val(ValPrep(mystr), r, err);
    if err <> 0 then r := udReal
    else begin
      if r < mnReal then r := mnReal;
      if r > mxReal then r := mxReal;
    end;
    RVal := r;
  end;

function DelimPos(mystr: string): integer;
  var i: integer;
  begin
    i := 0;
    if i = 0 then i := pos(',', mystr);
    if i = 0 then i := pos(':', mystr);
    if i = 0 then i := pos('/', mystr);
    if i = 0 then i := pos('\', mystr);
    if i = 0 then i := pos(';', mystr);
    DelimPos := i;
  end;

procedure DelimStrToReals(mystr: string; var r1, r2: real);
  var i: integer;
  begin
    i := DelimPos(mystr);
    if i = 0 then begin
      r1 := udReal;
      r2 := udReal;
    end else begin
      if i < 2 then r1 := 0.0
      else r1 := RVal(Copy(mystr, 1, i - 1));
      if length(mystr) - i < 1 then r2 := 0.0
      else r2 := RVal(Copy(mystr, i + 1, length(mystr) - i));
    end;
  end;

procedure DelimStrTo3Reals(mystr: string; var r1, r2, r3: real);
  var i: integer;
  begin
    i := DelimPos(mystr);
    if i = 0 then begin
      r1 := udReal;
      r2 := udReal;
      r3 := udReal;
    end else begin
      if i < 2 then r1 := 0.0
      else r1 := RVal(Copy(mystr, 1, i - 1));
      DelimStrToReals(Copy(mystr, i + 1, length(mystr) - i), r2, r3);
      if (r2 = udReal) or (r3 = udReal) then r1 := udReal;
    end;
  end;

const Hexes: string[16] = '0123456789ABCDEF';

function HexStr(i: longint; d: integer): string;
  var mystr: string[80];
  begin
    mystr := '';
    while i > 0 do begin
      mystr := Hexes[(i and 15) + 1] + mystr;
      i := i shr 4;
    end;
    if d <> 0 then mystr := PadZeros(mystr, d)
    else if mystr = '' then mystr := '0';
    HexStr := mystr;
  end;

function HexToDec(s: string): longint;
  var
    i: longint;
    j, k: integer;
  begin
    i := 0;
    for k := 1 to length(s) do begin
      j := pos(UpCase(s[k]), Hexes);
      if j > 0 then i := 16 * i + j - 1;
    end;
    HexToDec := i;
  end;

function RToI(r: real): integer;
  begin
    if (r < mnInteger) then RToI := mnInteger
    else if (r > mxInteger) then RToI := mxInteger
    else RToI := trunc(r);
  end;

function LimitI(i, min, max: integer): integer;
  begin
    if i < min then      LimitI := min
    else if i > max then LimitI := max
    else                 LimitI := i;
  end;

function LimitIorUndef(i, min, max: integer): integer;
  begin
    if i < min then      LimitIorUndef := udInteger
    else if i > max then LimitIorUndef := udInteger
    else                 LimitIorUndef := i;
  end;

procedure RemoveAndCharsBefore(var mystr: string; pstr: string);
  var i: integer;
  begin
    Repeat
      i := pos(pstr, mystr);
      if i > 0 then mystr := Copy(mystr, i + 1, length(mystr) - i);
    until i <= 0;
  end;

procedure RemoveAndCharBefore(var mystr: string; pstr: string);
  var i: integer;
  begin
    Repeat
      i := pos(pstr, mystr);
      if i > 1 then Delete(mystr, i - 1, 2)
      else if i > 0 then Delete(mystr, i, 1);
    until i <= 0;
  end;

procedure RemoveAndCharsAfter(var mystr: string; pstr: string);
  var i: integer;
  begin
    Repeat
      i := pos(pstr, mystr);
      if i > 0 then mystr := Copy(mystr, 1, i - 1);
    until i <= 0;
  end;

procedure RemoveCharsBefore(var mystr: string; pstr: string);
  begin
    if pos(pstr, mystr) > 0 then begin
      RemoveAndCharsBefore(mystr, pstr);
      mystr := pstr + mystr;
    end;
  end;

function PtrToStr(p: pointer): string;
  var s: string[sizeof(p)];
  begin
    s[0] := Chr(sizeof(p));
    Move(p, s[1], sizeof(p));
    PtrToStr := s;
  end;

function StrToPtr(s: string): pointer;
  begin
    StrToPtr := PPointer (@s[1])^;
  end;

function CharToText (ch: char): string;
  begin
    case ch of
      #0:         CharToText := '<NUL>';
      ^A..^Z:     CharToText := '<^' + Chr(Ord(ch) + Ord('A') - 1) + '>';
      #27:        CharToText := '<ESC>';
      #28..#31,
      #127..#255: CharToText := '<#' + IStr(Ord(ch), 0) + '>';
      else        CharToText := ch;
    end;
  end;

function CharToASCII(ch: char): string;
  const AsciiTable: array [#0..#32] of string[16] =
   ('^@ = NUL',
    '^A = SOH',
    '^B = STX',
    '^C = ETX',
    '^D = EOT',
    '^E = ENQ',
    '^F = ACK',
    '^G = BEL',
    '^H = BS',
    '^I = HT',
    '^J = LF',
    '^K = VT',
    '^L = FF',
    '^M = CR',
    '^N = SO',
    '^O = SI',
    '^P = DLE',
    '^Q = DC1 = XON',
    '^R = DC2',
    '^S = DC3 = XOFF',
    '^T = DC4',
    '^U = NAK',
    '^V = SYN',
    '^W = ETB',
    '^X = CAN',
    '^Y = EM',
    '^Z = SUB',
    '^[ = ESC',
    '^\ = FS',
    '^] = GS',
    '^^ = RS',
    '^_ = US',
    ' ');
  begin
    case ch of
      #0..#32:    CharToASCII := '<' + AsciiTable[ch] + '>';
      #127:       CharToASCII := '<DEL>';
      else        CharToASCII := CharToText(ch);
    end;
  end;


end.
