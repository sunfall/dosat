unit trap;

{ trap run-time errors }

interface

procedure InitTrap;

implementation

uses XStrings;

var
  OldExitProc: pointer;
  f: text;

procedure MyTrap; far;
  begin
    ExitProc := OldExitProc;

    assign(f, 'errors.txt');
    rewrite(f);

    writeln(f, 'ExitCode = ', ExitCode);
    writeln(f, 'ExitAddr = ', longint(ErrorAddr));
{
    writeln(f, 'ExitCode = ' + IStr(ExitCode, 0));
    writeln(f, 'ExitAddr = ' + HexStr(longint(ErrorAddr) div 65536, 4)
               + ':' + HexStr(longint(ErrorAddr) and $FFFF, 4));
}
    close(f);
  end;

procedure InitTrap;
  begin
    OldExitProc := ExitProc;
    ExitProc := @MyTrap;
  end;

{ unit initialization }

end.
