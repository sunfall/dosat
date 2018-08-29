program geoedit;

{ edit geomorphs for hommx }

uses CRT, Drivers, XSVGA, LowGr, XMouse, Map, XStrings;

var
  Geo: integer;
  Choice: byte;

procedure InitGeos;
  var g, i, j, top, right, bottom, left: integer;
  begin
    for g := 1 to NumGeos do begin
      for i := 1 to GeoSize do
        for j := 1 to GeoSize do
          Geos^[g][i, j] := mGrass;

      if g <= 81 then begin
        top := (g - 1) mod 3;
        right := ((g - 1) div 3) mod 3;
        bottom := ((g - 1) div 9) mod 3;
        left := ((g - 1) div 27) mod 3;
      end else begin
        top := ((g - 82) mod 2) * 2;
        right := (((g - 82) div 2) mod 2) * 2;
        bottom := (((g - 82) div 4) mod 2) * 2;
        left := (((g - 82) div 8) mod 2) * 2;
      end;

      for i := 1 to GeoSize do begin
        if top = 2 then Geos^[g][i, 1] := mObstacle;
        if bottom = 2 then Geos^[g][i, GeoSize] := mObstacle;
        if left = 2 then Geos^[g][1, i] := mObstacle;
        if right = 2 then Geos^[g][GeoSize, i] := mObstacle;
      end;

      for i := 1 to 3 do begin
        if top = 1 then begin
          Geos^[g][i, 1] := mObstacle;
          Geos^[g][GeoSize - i + 1, 1] := mObstacle;
        end;
        if bottom = 1 then begin
          Geos^[g][i, GeoSize] := mObstacle;
          Geos^[g][GeoSize - i + 1, GeoSize] := mObstacle;
        end;
        if left = 1 then begin
          Geos^[g][1, i] := mObstacle;
          Geos^[g][1, GeoSize - i + 1] := mObstacle;
        end;
        if right = 1 then begin
          Geos^[g][GeoSize, i] := mObstacle;
          Geos^[g][GeoSize, GeoSize - i + 1] := mObstacle;
        end;
      end;
    end;
  end;

procedure SaveGeos;
  var
    f: file;
    result: word;
  begin
    assign(f, 'geos.dat');
    rewrite(f, 1);
    BlockWrite(f, Geos^, sizeof(Geos^), result);
    close(f);
  end;

procedure GetHexXY(i, j: integer; var x, y: integer);
  begin
    x := (i - 1) * 32;
    y := (j - 1) * 32;
    if (j mod 2) = 1 then inc(x, 16);
  end;

procedure PointToGeoGrid(var x, y: integer);
  begin
    y := (y div 32) + 1;
    if y mod 2 = 1 then dec(x, 16);
    if x < 0 then
      x := 0
    else
      x := (x div 32) + 1;
  end;

procedure BlackRect(x, y: integer);
  begin
    HLine32(x, y, colBlack);
    HLine32(x, y + 31, colBlack);
    VLine32(x, y, colBlack);
    VLine32(x + 31, y, colBlack);
  end;

procedure DrawGeo;
  var
    i, j, x, y, m, p, n, m2: integer;

  procedure FindCastle(f: integer);
    begin
      if Geos^[Geo][i + 1, j] = f then
        p := 1
      else if Geos^[Geo][i + n, j + 1] = f then
        p := 2
      else if Geos^[Geo][i + n - 1, j + 1] = f then
        p := 3
      else if Geos^[Geo][i - 1, j] = f then
        p := 4;
      if p <> 0 then m2 := f;
    end;

  procedure Blodget;
    begin
      DrawMapHexData(0, 0, x, y, mGrass, 0, 0);
      XRectangle(x + 2, y + 2, x + 29, y + 29, colWhite);
      XRectangle(x + 4, y + 4, x + 27, y + 27, colWhite);
    end;

  begin
    for i := 1 to GeoSize do
      for j := 1 to GeoSize do begin
        GetHexXY(i, j, x, y);
        m := Geos^[Geo][i, j];
        if m = mRightHalf then begin
          m2 := Geos^[Geo][i - 1, j];
          if (m2 >= mPreciousMine) and (m2 <= mFarmstead) then
            DrawMapHexData(0, 0, x, y, m2, 1, 0)
          else
            Blodget;
        end else if m = mCastlePart then begin
          if j mod 2 = 1 then n := 1 else n := 0;
          p := 0;
          FindCastle(mCastle);
          if p = 0 then FindCastle(mOutpost);
          if p <> 0 then DrawMapHexData(0, 0, x, y, m2, p, 0);
          if p = 0 then Blodget;
        end else if (m = mCastle) or (m = mOutpost) then begin
          DrawMapHexData(0, 0, x, y, mGrass, 0, 0);
          Blodget;
        end else
          DrawMapHexData(0, 0, x, y, m, 0, 0);
        BlackRect(x, y);
      end;

    DrawMapHexData(0, 0, 384, 32 + 64, Choice, 0, 0);
    DrawText(391, 8, colBlack, colWhite, LSet(IStr(Geo, 0), 3));

    BlackRect(384, 32);
    case GeoEdge(Geo, geBottom) of
      1: for i := 1 to 8 do begin
           XPutPixel(384 + i - 1, 32 + 31, colLightGray);
           XPutPixel(384 + 32 - i, 32 + 31, colLightGray);
         end;
      2: HLine32(384, 32 + 31, colLightGray);
    end;
    case GeoEdge(Geo, geLeft) of
      1: for i := 1 to 8 do begin
           XPutPixel(384, 32 + i - 1, colLightGray);
           XPutPixel(384, 32 + 32 - i, colLightGray);
         end;
      2: VLine32(384, 32, colLightGray);
    end;
    case GeoEdge(Geo, geTop) of
      1: for i := 1 to 8 do begin
           XPutPixel(384 + i - 1, 32, colLightGray);
           XPutPixel(384 + 32 - i, 32, colLightGray);
         end;
      2: HLine32(384, 32, colLightGray);
    end;
    case GeoEdge(Geo, geRight) of
      1: for i := 1 to 8 do begin
           XPutPixel(384 + 31, 32 + i - 1, colLightGray);
           XPutPixel(384 + 31, 32 + 32 - i, colLightGray);
         end;
      2: VLine32(384 + 31, 32, colLightGray);
    end;
  end;

const
  Ikes: array [1..47] of byte =
  (
    mGrass, mResource, mRezGold, mRezRocks,
    mRezApples, mEasyResource, mEasyTreasure, mBag,
    mChest, mBarrel, mArtifact, mCamp,
    mPotion, mMonster, mHardMonster, mObstacle,
    mOakTree, mPineTree, mJungleTree, mMountain,
    mWater, mHill, mPreciousMine, mGoldMine,
    mAppleMine, mRockMine, mSkillMine, mFarmstead,
    mDwelling, mSchool, mSpellPavilion, mMonument,
    mShrine, mAltar, mSageHut, mJunkMerchant,
    mLibrary, mWatchtower, mCastle, mOutpost,
    mCache, mTree, mHermitHut, mUpgradeFort,
    mSnowyPineTree, mGreenMountain, mTwisty2
  );

procedure DrawIcons;
  var
    i, x, y: integer;
  begin
    for i := 1 to high(Ikes) do begin
      x := ((i - 1) mod 5) * 32 + (640 - 5*32);
      y := ((i - 1) div 5) * 32;
      if ((Ikes[i] >= mGoldMine) and (Ikes[i] <= mFarmstead))
         or (Ikes[i] = mCastle) or (Ikes[i] = mOutpost) then
        DrawMapHexData(0, 0, x, y, Ikes[i], 1, 0)
      else
        DrawMapHexData(0, 0, x, y, Ikes[i], 0, 0);
      BlackRect(x, y);
    end;
  end;

procedure run;
  var
    over: boolean;
    E: TEvent;
    x, y, ike, i: integer;
  begin
    InitEvents;
    InitSVGA;
    SetSVGAMode;
    SetPalette;
    ClearScr;
    DrawBackground := true;
    BackgroundColor := colGreen;

    Geo := 1;
    over := false;
    Choice := mObstacle;

    DrawIcons;
    DrawGeo;

    repeat
      WaitForEvent(E);
      if E.What = evKeyDown then begin
        case E.charcode of
          #27: over := true;
           #9: Geo := (((Geo - 1) + NumGeos div 2) mod NumGeos) + 1;
        end;
        case E.keycode of
          kbLeft,
          kbUp:   Geo := (((Geo - 1) + NumGeos -  1) mod NumGeos) + 1;
          kbRight,
          kbDown: Geo := (((Geo - 1) + 1           ) mod NumGeos) + 1;
          kbPgUp: Geo := (((Geo - 1) + NumGeos - 10) mod NumGeos) + 1;
          kbPgDn: Geo := (((Geo - 1) + 10          ) mod NumGeos) + 1;
{         kbAltI: InitGeos; }
{         kbAltL: LoadGeos; }
          kbAltS: SaveGeos;
        end;
      end;
      if E.What = evMouseDown then begin
        if E.Buttons = mbLeftButton then begin
          x := E.Where.X;
          y := E.Where.Y;

          if x >= 640 - 5 * 32 then begin
            x := (x - (640 - 5 * 32)) div 32;
            y := y div 32;
            ike := x + y * 5 + 1;
            if ike <= high(Ikes) then Choice := Ikes[ike];
          end else begin
            PointToGeoGrid(x, y);
            if (x >= 1) and (y >= 1)
               and (x <= GeoSize) and (y <= GeoSize) then begin
              if ((Choice = mCastle) or (Choice = mOutpost)) then begin
                if (x > 2) and (x < GeoSize - 1)
                   and (y > 2) and (y < GeoSize - 1) then begin
                  Geos^[Geo][x, y] := Choice;
                  Geos^[Geo][x - 1, y] := mCastlePart;
                  Geos^[Geo][x + 1, y] := mCastlePart;
                  if y mod 2 = 0 then i := x - 1 else i := x;
                  Geos^[Geo][i, y - 1] := mCastlePart;
                  Geos^[Geo][i + 1, y - 1] := mCastlePart;
                end;
              end else begin
                Geos^[Geo][x, y] := Choice;
                if (Choice >= mPreciousMine) and (Choice <= mFarmstead) then
                  Geos^[Geo][x + 1, y] := mRightHalf;
              end;
            end;
          end;
        end else if E.Buttons = mbRightButton then begin
          x := E.Where.X;
          y := E.Where.Y;
          PointToGeoGrid(x, y);
          if (x >= 1) and (y >= 1)
             and (x <= GeoSize) and (y <= GeoSize) then
            Geos^[Geo][x, y] := mGrass;
        end;
      end;
      if not over then DrawGeo;
    until over;

    Dispose(Geos);

    CloseGraphics;
    DoneSVGA;
    DoneEvents;
  end;

begin
  run;
end.
