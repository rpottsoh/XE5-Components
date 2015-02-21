{----------------------------------------------------------------------------}
{-                                                                          -}
{-     Turbo Pascal Numerical Methods Toolbox                               -}
{-     Copyright (c) 1986, 87 by Borland International, Inc.                -}
{-                                                                          -}
{----------------------------------------------------------------------------}

procedure RealFFT{(NumPoints : integer;
                   Inverse   : boolean;
               var XReal     : TNvectorPtr;
               var XImag     : TNvectorPtr;
               var Error     : byte)};
var
  SinTable, CosTable : TNvectorPtr;   { Tables of sine and cosine values  }
  NumberOfBits : byte;                { Number of bits necessary to     }
                                      { represent the number of points  }

procedure MakeRealDataComplex(NumPoints : integer;
                          var XReal     : TNvectorPtr;
                          var XImag     : TNvectorPtr);

{-----------------------------------------------------------}
{- Input: NumPoints, XReal                                 -}
{- Output: XReal, XImag                                    -}
{-                                                         -}
{- This procedure shuffles the real data.  There are       -}
{- 2*NumPoints real data points in the vector XReal.  The  -}
{- data is shuffled so that there are NumPoints complex    -}
{- data points.  The real part of the complex data is      -}
{- made up of those points whose original array Index was  -}
{- even; the imaginary part of the complex data is made    -}
{- up of those points whose original array Index was odd.  -}
{-----------------------------------------------------------}

var
  Index, NewIndex : integer;
  DummyReal, DummyImag : TNvectorPtr;

begin
  New(DummyReal);
  New(DummyImag);
  for Index := 0 to NumPoints - 1 do
  begin
    NewIndex := Index shl 1;
    DummyReal^[Index] := XReal^[NewIndex];
    DummyImag^[Index] := XReal^[NewIndex + 1];
  end;
  XReal^ := DummyReal^;
  XImag^ := DummyImag^;
  Dispose(DummyReal);
  Dispose(DummyImag);
end; { procedure MakeRealDataComplex }

procedure UnscrambleComplexOutput(NumPoints : integer;
                              var SinTable  : TNvectorPtr;
                              var CosTable  : TNvectorPtr;
                              var XReal     : TNvectorPtr;
                              var XImag     : TNvectorPtr);

{----------------------------------------------------------}
{- Input: NumPoints, SinTable, CosTable, XReal, XImag     -}
{- Output: XReal, XImag                                   -}
{-                                                        -}
{- This procedure unshuffles the complex transform.       -}
{- The transform has NumPoints elements.  This procedure  -}
{- unshuffles the transform so that it is 2*NumPoints     -}
{- elements long.  The resulting vector is symmetric      -}
{- about the element NumPoints.                           -}
{- Both the forward and inverse transforms are defined    -}
{- with a 1/Sqrt(NumPoints) factor.  Since the real FFT   -}
{- algorithm operates on vectors of length NumPoints/2,   -}
{- the unscrambled vectors must be divided by Sqrt(2).    -}
{----------------------------------------------------------}

var
  PiOverNumPoints : Float;
  Index : integer;
  indexSHR1 : integer;
  NumPointsMinusIndex : integer;
  SymmetricIndex : integer;
  Multiplier : Float;
  Factor : Float;
  CosFactor, SinFactor : Float;
  RealSum, ImagSum, RealDif, ImagDif : Float;
  RealDummy, ImagDummy : TNvectorPtr;
  NumPointsSHL1 : integer;

begin
  New(RealDummy);
  New(ImagDummy);
  RealDummy^ := XReal^;
  ImagDummy^ := XImag^;
  PiOverNumPoints := Pi / NumPoints;
  NumPointsSHL1 := NumPoints shl 1;
  RealDummy^[0] := (XReal^[0] + XImag^[0]) / Sqrt(2);
  ImagDummy^[0] := 0;
  RealDummy^[NumPoints] := (XReal^[0] - XImag^[0]) / Sqrt(2);
  ImagDummy^[NumPoints] := 0;
  for Index := 1 to NumPoints - 1 do
  begin
    Multiplier := 0.5 / Sqrt(2);
    Factor := PiOverNumPoints * Index;
    NumPointsMinusIndex := NumPoints - Index;
    SymmetricIndex := NumPointsSHL1 - Index;
    if Odd(Index) then
      begin
        CosFactor :=  Cos(Factor);
        SinFactor := -Sin(Factor);
      end
    else
      begin
        indexSHR1 := Index shr 1;
        CosFactor := CosTable^[indexSHR1];
        SinFactor := SinTable^[indexSHR1];
      end;

    RealSum := XReal^[Index] + XReal^[NumPointsMinusIndex];
    ImagSum := XImag^[Index] + XImag^[NumPointsMinusIndex];
    RealDif := XReal^[Index] - XReal^[NumPointsMinusIndex];
    ImagDif := XImag^[Index] - XImag^[NumPointsMinusIndex];

    RealDummy^[Index] := Multiplier * (RealSum + CosFactor * ImagSum
                         + SinFactor * RealDif);
    ImagDummy^[Index] := Multiplier * (ImagDif + SinFactor * ImagSum
                         - CosFactor * RealDif);
    RealDummy^[SymmetricIndex] :=  RealDummy^[Index];
    ImagDummy^[SymmetricIndex] := -ImagDummy^[Index];
  end;  { for }

  XReal^ := RealDummy^;
  XImag^ := ImagDummy^;
  Dispose(RealDummy);
  Dispose(ImagDummy);
end; { procedure UnscrambleComplexOutput }

begin { procedure RealFFT }

  { The number of complex data points will  }
  { be half the number of real data points  }
  NumPoints := NumPoints shr 1;

  TestInput(NumPoints, NumberOfBits, Error);

  if Error = 0 then
  begin
    New(SinTable);
    New(CosTable);
    MakeRealDataComplex(NumPoints, XReal, XImag);
    MakeSinCosTable(NumPoints, SinTable, CosTable);
    FFT(NumberOfBits, NumPoints, Inverse, XReal, XImag, SinTable, CosTable);
    UnscrambleComplexOutput(NumPoints, SinTable, CosTable, XReal, XImag);
    NumPoints := NumPoints shl 1;    { The number of complex points  }
                                     { in the transform will be the  }
                                     { same as the number of real    }
                                     { points in input data.         }
    Dispose(SinTable);
    Dispose(CosTable);
  end;
end; { procedure RealFFT }

procedure RealConvolution{(NumPoints : integer;
                       var XReal     : TNvectorPtr;
                       var XImag     : TNvectorPtr;
                       var HReal     : TNvectorPtr;
                       var Error     : byte)};

var
  SinTable, CosTable : TNvectorPtr;    { Tables of sine and cos values  }
  Inverse : boolean;                   { Indicates inverse transform  }
  NumberOfBits : byte;                 { Number of bits required to  }
                                       { represent NumPoints    }
  HImag : TNvectorPtr;                 { Imaginary part of the   }
                                       { FFT transform of HReal  }

procedure Multiply(NumPoints : integer;
               var XReal     : TNvectorPtr;
               var XImag     : TNvectorPtr;
               var HReal     : TNvectorPtr;
               var HImag     : TNvectorPtr);

{----------------------------------------------}
{- Input: NumPoints, XReal, XImag, HReal,     -}
{-        HImag                               -}
{- Output: XReal, XImag                       -}
{-                                            -}
{- This procedure multiplies each element in  -}
{- X by the corresponding element in H.  The  -}
{- product is returned in X.                  -}
{----------------------------------------------}

var
  Term : integer;
  Dummy : Float;

begin
  for Term := 0 to NumPoints - 1 do
  begin
    Dummy := XReal^[Term] * HReal^[Term] - XImag^[Term] * HImag^[Term];
    XImag^[Term] := XReal^[Term] * HImag^[Term] +
                    XImag^[Term] * HReal^[Term];
    XReal^[Term] := Dummy;
  end;
end; { procedure Multiply }

procedure SeparateTransforms(NumPoints : integer;
                         var XReal     : TNvectorPtr;
                         var XImag     : TNvectorPtr;
                         var HReal     : TNvectorPtr;
                         var HImag     : TNvectorPtr);

{-------------------------------------------------------}
{- Input: NumPoints, XReal, XImag                      -}
{- Output: HReal, HImag                                -}
{-                                                     -}
{- The transforms of the real data XReal and HReal are -}
{- stored in the vector XReal, XImag.  By using the    -}
{- symmetries of the transforms of real data, this     -}
{- procedure extracts the complex transforms.  The     -}
{- transform of XReal is returned in XReal, XImag. The -}
{- transform of HReal is returned in HReal, HImag.     -}
{-------------------------------------------------------}

var
  Term : integer;
  EndTerm : integer;
  DummyReal : Float;
  DummyImag : Float;
  NumPointsSHR1 : integer;
  NumPointsMinusTerm : integer;

begin
  HReal^[0] := XImag^[0];
  HImag^[0] := 0;
  XImag^[0] := 0;
  NumPointsSHR1 := NumPoints SHR 1;
  HReal^[NumPointsSHR1] := XImag^[NumPointsSHR1];
  HImag^[NumPointsSHR1] := 0;
  XImag^[NumPointsSHR1] := 0;
  EndTerm := NumPointsSHR1 - 1;
  for Term := 1 to EndTerm do
  begin
    NumPointsMinusTerm := NumPoints - Term;
    HReal^[Term] := 0.5 * (XImag^[Term] + XImag^[NumPointsMinusTerm]);
    HImag^[Term] := 0.5 * (XReal^[NumPointsMinusTerm] - XReal^[Term]);
    DummyReal := 0.5 * (XReal^[Term] + XReal^[NumPointsMinusTerm]);
    DummyImag := 0.5 * (XImag^[Term] - XImag^[NumPointsMinusTerm]);
    XReal^[Term] := DummyReal;
    XImag^[Term] := DummyImag;
  end;

  for Term := 1 to EndTerm do
  begin  { Make use of symmetries to calculate  }
         { the rest of the transform            }
    NumPointsMinusTerm := NumPoints - Term;
    XReal^[NumPointsMinusTerm] :=  XReal^[Term];
    XImag^[NumPointsMinusTerm] := -XImag^[Term];
    HReal^[NumPointsMinusTerm] :=  HReal^[Term];
    HImag^[NumPointsMinusTerm] := -HImag^[Term];
  end;
end; { procedure SeparateTransforms }

begin { procedure RealConvolution }
  TestInput(NumPoints, NumberOfBits, Error);
  if Error = 0 then
  begin
    New(HImag);
    New(SinTable);
    New(CosTable);

    { Combine the two real transforms  }
    { into one complex transform       }
    XImag^ := HReal^;

    MakeSinCosTable(NumPoints, SinTable, CosTable);

    { Take the transform of XReal, XImag  }
    Inverse := false;

    FFT(NumberOfBits, NumPoints, Inverse, XReal, XImag, SinTable, CosTable);

    { Separate out the X transform and H transform  }
    SeparateTransforms(NumPoints, XReal, XImag, HReal, HImag);

    { Multiply the two transforms  }
    Multiply(NumPoints, XReal, XImag, HReal, HImag);

    { Take the inverse transform of the product  }
    Inverse := true;
    FFT(NumberOfBits, NumPoints, Inverse, XReal, XImag, SinTable, CosTable);
    Dispose(SinTable);
    Dispose(CosTable);
    Dispose(HImag);
  end;
end; { procedure RealConvolution }

procedure RealCorrelation{(NumPoints : integer;
                      var Auto       : boolean;
                      var XReal      : TNvectorPtr;
                      var XImag      : TNvectorPtr;
                      var HReal      : TNvectorPtr;
                      var Error      : byte)};

var
  SinTable, CosTable : TNvectorPtr;  { Tables of sine and cosine values  }
  Inverse : boolean;                 { Indicates inverse transform  }
  NumberOfBits : byte;               { Number of bits necessary to     }
                                     { represent the number of points  }
  HImag : TNvectorPtr;               { Imaginary part of the   }
                                     { FFT transform of HReal  }

procedure SeparateTransforms(NumPoints : integer;
                         var XReal     : TNvectorPtr;
                         var XImag     : TNvectorPtr;
                         var HReal     : TNvectorPtr;
                         var HImag     : TNvectorPtr);

{-------------------------------------------------------}
{- Input: NumPoints, XReal, XImag                      -}
{- Output: HReal, HImag                                -}
{-                                                     -}
{- The transforms of the real data XReal and HReal are -}
{- stored in the vector XReal, XImag.  By using the    -}
{- symmetries of the transforms of real data, this     -}
{- procedure extracts the complex transforms.  The     -}
{- transform of XReal is returned in XReal, XImag. The -}
{- transform of HReal is returned in HReal, HImag.     -}
{-------------------------------------------------------}

var
  Term : integer;
  EndTerm : integer;
  DummyReal : Float;
  DummyImag : Float;
  NumPointsSHR1 : integer;
  NumPointsMinusTerm : integer;

begin
  HReal^[0] := XImag^[0];
  HImag^[0] := 0;
  XImag^[0] := 0;
  NumPointsSHR1 := NumPoints SHR 1;
  HReal^[NumPointsSHR1] := XImag^[NumPointsSHR1];
  HImag^[NumPointsSHR1] := 0;
  XImag^[NumPointsSHR1] := 0;
  EndTerm := NumPointsSHR1 - 1;
  for Term := 1 to EndTerm do
  begin
    NumPointsMinusTerm := NumPoints - Term;
    HReal^[Term] := 0.5 * (XImag^[Term] + XImag^[NumPointsMinusTerm]);
    HImag^[Term] := 0.5 * (XReal^[NumPointsMinusTerm] - XReal^[Term]);
    DummyReal := 0.5 * (XReal^[Term] + XReal^[NumPointsMinusTerm]);
    DummyImag := 0.5 * (XImag^[Term] - XImag^[NumPointsMinusTerm]);
    XReal^[Term] := DummyReal;
    XImag^[Term] := DummyImag;
  end;

  for Term := 1 to EndTerm do
  begin  { Make use of symmetries to calculate  }
         { the rest of the transform            }
    NumPointsMinusTerm := NumPoints - Term;
    XReal^[NumPointsMinusTerm] :=  XReal^[Term];
    XImag^[NumPointsMinusTerm] := -XImag^[Term];
    HReal^[NumPointsMinusTerm] :=  HReal^[Term];
    HImag^[NumPointsMinusTerm] := -HImag^[Term];
  end;
end; { procedure SeparateTransforms }

procedure Multiply(NumPoints : integer;
               var XReal     : TNvectorPtr;
               var XImag     : TNvectorPtr;
               var HReal     : TNvectorPtr;
               var HImag     : TNvectorPtr);

{----------------------------------------------------}
{- Input: NumPoints, XReal, XImag, HReal, HImag     -}
{- Output: XReal, XImag                             -}
{-                                                  -}
{- This procedure performs the following operation: -}
{-                                                  -}
{-     Dummy[f] := X[f] * H[-f]                     -}
{-                                                  -}
{- where -f is represented by NumPoints - f         -}
{- (circular correlation).  Because x and h were    -}
{- real functions, this operation is identical      -}
{- to:                                              -}
{-                           *                      -}
{-    Dummy[f] := X[f] - H[f]                       -}
{-                                                  -}
{- The product is returned in X.                    -}
{----------------------------------------------------}

var
  Term : integer;
  NumPointsMinusTerm : integer;
  DummyReal : TNvectorPtr;
  DummyImag : TNvectorPtr;

begin
  New(DummyReal);
  New(DummyImag);
  DummyReal^[0] := XReal^[0] * HReal^[0] - XImag^[0] * HImag^[0];
  DummyImag^[0] := XReal^[0] * HImag^[0] + XImag^[0] * HReal^[0];
  for Term := 1 to NumPoints - 1 do
  begin
    NumPointsMinusTerm := NumPoints - Term;
    DummyReal^[Term] := XReal^[Term] * HReal^[NumPointsMinusTerm] -
                        XImag^[Term] * HImag^[NumPointsMinusTerm];
    DummyImag^[Term] := XImag^[Term] * HReal^[NumPointsMinusTerm] +
                        XReal^[Term] * HImag^[NumPointsMinusTerm];
  end;
  XReal^ := DummyReal^;
  XImag^ := DummyImag^;
  Dispose(DummyReal);
  Dispose(DummyImag);
end; { procedure Multiply }

begin { procedure RealCorrelation }
  TestInput(NumPoints, NumberOfBits, Error);
  if Error = 0 then
  begin
    if Auto then
      FillChar(XImag^, SizeOf(XImag^), 0)
    else    { Combine the two real transforms  }
            { into one complex transform       }
      XImag^ := HReal^;
    New(HImag);
    New(SinTable);
    New(CosTable);

    MakeSinCosTable(NumPoints, SinTable, CosTable);

    { Take the transform of XReal, XImag  }
    Inverse := false;

    FFT(NumberOfBits, NumPoints, Inverse, XReal, XImag, SinTable, CosTable);

    if Auto then
      begin
        HReal^ := XReal^;
        HImag^ := XImag^;
      end
    else
      SeparateTransforms(NumPoints, XReal, XImag, HReal, HImag);

    { Multiply the two transforms together  }
    Multiply(NumPoints, XReal, XImag, HReal, HImag);

    { Take the inverse transform of the product  }
    Inverse := true;

    FFT(NumberOfBits, NumPoints, Inverse, XReal, XImag, SinTable, CosTable);

    Dispose(SinTable);
    Dispose(CosTable);
    Dispose(HImag);
  end;
end; { procedure RealCorrelation }

procedure ComplexFFT{(NumPoints : integer;
                      Inverse   : boolean;
                  var XReal     : TNvectorPtr;
                  var XImag     : TNvectorPtr;
                  var Error     : byte)};

var
  SinTable, CosTable : TNvectorPtr;      { Tables of sin and cosine values  }
  NumberOfBits : byte;                   { Number of bits to represent the  }
                                         { number of data points.           }

begin { procedure ComplexFFT }

  TestInput(NumPoints, NumberOfBits, Error);

  if Error = 0 then
  begin
    New(SinTable);
    New(CosTable);

    MakeSinCosTable(NumPoints, SinTable, CosTable);
    FFT(NumberOfBits, NumPoints, Inverse, XReal, XImag, SinTable, CosTable);

    Dispose(SinTable);
    Dispose(CosTable);
  end;
end; { procedure ComplexFFT }

procedure ComplexConvolution{(NumPoints : integer;
                          var XReal     : TNvectorPtr;
                          var XImag     : TNvectorPtr;
                          var HReal     : TNvectorPtr;
                          var HImag     : TNvectorPtr;
                          var Error     : byte)};

var
  SinTable, CosTable : TNvectorPtr;    { Tables of sine and cosine values  }
  Inverse : boolean;                   { Indicates inverse transform  }
  NumberOfBits : byte;                 { # of bits required to  }
                                       { represent NumPoints    }

procedure Multiply(NumPoints : integer;
               var XReal     : TNvectorPtr;
               var XImag     : TNvectorPtr;
               var HReal     : TNvectorPtr;
               var HImag     : TNvectorPtr);

{----------------------------------------------}
{- Input: NumPoints, XReal, XImag, HReal,     -}
{-        HImag                               -}
{- Output: XReal, XImag                       -}
{-                                            -}
{- This procedure multiplies each element in  -}
{- X by the corresponding element in H.  The  -}
{- product is returned in X.                  -}
{----------------------------------------------}

var
  Term : integer;
  Dummy : Float;

begin
  for Term := 0 to NumPoints - 1 do
  begin
    Dummy := XReal^[Term] * HReal^[Term] - XImag^[Term] * HImag^[Term];
    XImag^[Term] := XReal^[Term] * HImag^[Term] +
                    XImag^[Term] * HReal^[Term];
    XReal^[Term] := Dummy;
  end;
end; { procedure Multiply }

begin { procedure ComplexConvolution }

  TestInput(NumPoints, NumberOfBits, Error);

  if Error = 0 then
  begin
    New(SinTable);
    New(CosTable);

    MakeSinCosTable(NumPoints, SinTable, CosTable);

    { Take the transform of XReal, XImag  }
    Inverse := false;

    FFT(NumberOfBits, NumPoints, Inverse, XReal, XImag, SinTable, CosTable);

    { Take the transform of HReal, HImag  }

    FFT(NumberOfBits, NumPoints, Inverse, HReal, HImag, SinTable, CosTable);

    { Multiply the two transforms  }
    Multiply(NumPoints, XReal, XImag, HReal, HImag);

    { Take the inverse transform of the product  }
    Inverse := true;

    FFT(NumberOfBits, NumPoints, Inverse, XReal, XImag, SinTable, CosTable);

    Dispose(SinTable);
    Dispose(CosTable);
  end;
end; { procedure ComplexConvolution }

procedure ComplexCorrelation{(NumPoints : integer;
                          var Auto      : boolean;
                          var XReal     : TNvectorPtr;
                          var XImag     : TNvectorPtr;
                          var HReal     : TNvectorPtr;
                          var HImag     : TNvectorPtr;
                          var Error     : byte)};

var
  SinTable, CosTable : TNvectorPtr;  { Tables of sine and cosine values  }
  Inverse : boolean;                 { Indicates inverse transform  }
  NumberOfBits : byte;               { Number of bits necessary to     }
                                     { represent the number of points  }

procedure Multiply(NumPoints : integer;
               var XReal     : TNvectorPtr;
               var XImag     : TNvectorPtr;
               var HReal     : TNvectorPtr;
               var HImag     : TNvectorPtr);

{----------------------------------------------------}
{- Input: NumPoints, XReal, XImag, HReal, HImag     -}
{- Output: XReal, XImag                             -}
{-                                                  -}
{- This procedure performs the following operation: -}
{-                                                  -}
{-     Dummy[f] := X[f] * H[-f]                     -}
{-                                                  -}
{- where -f is represented by NumPoints - f         -}
{- (circular correlation).                          -}
{-                                                  -}
{- The product is returned in X.                    -}
{----------------------------------------------------}

var
  Term : integer;
  NumPointsMinusTerm : integer;
  DummyReal : TNvectorPtr;
  DummyImag : TNvectorPtr;

begin
  New(DummyReal);
  New(DummyImag);
  DummyReal^[0] := XReal^[0] * HReal^[0] - XImag^[0] * HImag^[0];
  DummyImag^[0] := XReal^[0] * HImag^[0] + XImag^[0] * HReal^[0];
  for Term := 1 to NumPoints - 1 do
  begin
    NumPointsMinusTerm := NumPoints - Term;
    DummyReal^[Term] := XReal^[Term] * HReal^[NumPointsMinusTerm] -
                        XImag^[Term] * HImag^[NumPointsMinusTerm];
    DummyImag^[Term] := XImag^[Term] * HReal^[NumPointsMinusTerm] +
                        XReal^[Term] * HImag^[NumPointsMinusTerm];
  end;
  XReal^ := DummyReal^;
  XImag^ := DummyImag^;
  Dispose(DummyReal);
  Dispose(DummyImag);
end; { procedure Multiply }

begin { procedure ComplexCorrelation }

  TestInput(NumPoints, NumberOfBits, Error);

  if Error = 0 then
  begin
    New(SinTable);
    New(CosTable);

    MakeSinCosTable(NumPoints, SinTable, CosTable);

    { Take the transform of XReal, XImag  }
    Inverse := false;

    FFT(NumberOfBits, NumPoints, Inverse, XReal, XImag, SinTable, CosTable);

    if not Auto then
      { Take the transform of HReal, HImag  }
      begin
        FFT(NumberOfBits, NumPoints, Inverse, HReal, HImag, SinTable, CosTable);
      end
    else
      { Autocorrelation; set H equal to X  }
      begin
        HReal := XReal;
        HImag := XImag;
      end;

    { Multiply the two transforms together  }
    Multiply(NumPoints, XReal, XImag, HReal, HImag);

    { Take the inverse transform of the product  }
    Inverse := true;

    FFT(NumberOfBits, NumPoints, Inverse, XReal, XImag, SinTable, CosTable);

    Dispose(SinTable);
    Dispose(CosTable);
  end;
end; { procedure ComplexCorrelation }
