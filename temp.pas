program temp;

procedure run;
  var
    c, r: real;
    i: integer;
  begin
    for i := 1 to 32 do begin
      r := 100 / exp(i / 10 * ln(2));
      writeln(i, ' -> ', r:10:5);
    end;
  end;

begin
  run;
end.
