program paltest;

uses Graph, CRT, Drivers, LowGr;

procedure Run;
  const
    GrDriver: integer = VGA;
    GrMode: integer = VGAHi;
  var
    i, j, c, ci, cj: integer;
  begin
    InitEvents;
    InitGraph(GrDriver, GrMode, '');
    SetPalette;
    StdControl;

    for i := 0 to 639 do begin
      ci := i div 40;
      for j := 0 to 479 do begin
        cj := j div 30;

        if (i + j) mod 2 = 0 then
          c := ci
        else
          c := cj;

        if (i mod 40 < 5) or (i mod 40 >= 35)
           or (j mod 30 < 5) or (j mod 30 >= 25) then
          c := colGreen;

        XPutPixel(i, j, c);
      end;
    end;

    repeat until keypressed;

    CloseGraph;
    DoneEvents;
  end;

begin
  Run;
end.
