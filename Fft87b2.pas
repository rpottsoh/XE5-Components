unit FFT87B2;

{----------------------------------------------------------------------------}
{-                                                                          -}
{-     Turbo Pascal Numerical Methods Toolbox                               -}
{-     Copyright (c) 1986, 87 by Borland International, Inc.                -}
{-                                                                          -}
{-  This unit provides procedures for performing real and complex fast      -}
{-  fourier transforms. Radix-2 8087 version                                -}
{-                                                                          -}
{----------------------------------------------------------------------------}

{$N+} { Requires the 8087 math co-processor }

interface

const
  TNArraySize = 8191;

type
  Float       = double;   { 16 byte representation, 15-16 significant digit real number }
  TNvector    = array[0..TNArraySize] of Float;
  TNvectorPtr = ^TNvector;

procedure TestInput(NumPoints    : integer;
                var NumberOfBits : byte;
                var Error        : byte);

{-------------------------------------------------------------}
{- Input: NumPoints                                          -}
{- Output: NumberOfBits, Error                               -}
{-                                                           -}
{- This procedure checks the input.  If the number of points -}
{- (NumPoints) is less than two or is not a multiple of two  -}
{- then an error is returned.  NumberOfBits is the number of -}
{- bits necessary to represent NumPoints in binary (e.g. if  -}
{- NumPoints = 16, NumberOfBits = 4).                        -}
{-------------------------------------------------------------}

procedure MakeSinCosTable(NumPoints : integer;
                      var SinTable  : TNvectorPtr;
                      var CosTable  : TNvectorPtr);

{--------------------------------------------------------}
{- Input: NumPoints                                     -}
{- Output: SinTable, CosTable                           -}
{-                                                      -}
{- This procedure fills in a table with sin and cosine  -}
{- values.  It is faster to pull data out of this       -}
{- table than it is to calculate the sines and cosines. -}
{--------------------------------------------------------}

procedure FFT(NumberOfBits : byte;
              NumPoints    : integer;
              Inverse      : boolean;
          var XReal        : TNvectorPtr;
          var XImag        : TNvectorPtr;
          var SinTable     : TNvectorPtr;
          var CosTable     : TNvectorPtr);

{-----------------------------------------------------}
{- Input: NumberOfBits, NumPoints, Inverse, XReal,   -}
{-        XImag, SinTable, CosTable                  -}
{- Output: XReal, XImag                              -}
{-                                                   -}
{- This procedure implements the actual fast Fourier -}
{- transform routine.  The vector X, which must be   -}
{- entered in bit-inverted order, is transformed in  -}
{- place.  The transformation uses the Cooley-Tukey  -}
{- algorithm.                                        -}
{-----------------------------------------------------}

procedure RealFFT(NumPoints : integer;
                  Inverse   : boolean;
              var XReal     : TNvectorPtr;
              var XImag     : TNvectorPtr;
              var Error     : byte);


{---------------------------------------------------------------------------}
{-                                                                         -}
{-    Input: NumPoints, Inverse, XReal, XImag,                             -}
{-    Output: XReal, XImag, Error                                          -}
{-                                                                         -}
{-    Purpose:  This procedure uses the complex Fourier transform          -}
{-              routine (FFT) to transform real data.  The real data       -}
{-              is in the vector XReal.  Appropriate shuffling of indices  -}
{-              changes the real vector into two vectors (representing     -}
{-              complex data) which are only half the size of the original -}
{-              vector.  Appropriate unshuffling at the end produces the   -}
{-              transform of the real data.                                -}
{-                                                                         -}
{-  User Defined Types:                                                    -}
{-         TNvector = array[0..TNArraySize] of real                        -}
{-      TNvectorPtr = ^TNvector                                            -}
{-                                                                         -}
{- Global Variables:  NumPoints   : integer     Number of data             -}
{-                                              points in X                -}
{-                    Inverse     : boolean     False => forward transform -}
{-                                              True ==> inverse transform -}
{-                    XReal,XImag : TNvectorPtr Data points                -}
{-                    Error       : byte        Indicates an error         -}
{-                                                                         -}
{-             Errors:  0: No Errors                                       -}
{-                      1: NumPoints < 2                                   -}
{-                      2: NumPoints not a power of two                    -}
{-                         (or 4 for radix-4 transforms)                   -}
{-                                                                         -}
{---------------------------------------------------------------------------}

procedure RealConvolution(NumPoints : integer;
                      var XReal     : TNvectorPtr;
                      var XImag     : TNvectorPtr;
                      var HReal     : TNvectorPtr;
                      var Error     : byte);

{-------------------------------------------------------------------}
{-                                                                 -}
{-   Input: NumPoints, XReal, XImag, HReal                         -}
{-   Output: XReal, XImag, Error                                   -}
{-                                                                 -}
{-   Purpose: This procedure performs a convolution of the         -}
{-            real data XReal and HReal.  The result is returned   -}
{-            in the complex vector XReal, XImag.                  -}
{-                                                                 -}
{- User Defined Types:                                             -}
{-         TNvector = array[0..TNArraySize] of real                -}
{-      TNvectorPtr = ^TNvector                                    -}
{-                                                                 -}
{- Global Variables:  NumPoints : integer     Number of data       -}
{-                                            points in X          -}
{-                    XReal     : TNvectorPtr Data points          -}
{-                    HReal     : TNvectorPtr Data points          -}
{-                    Error     : byte        Indicates an error   -}
{-                                                                 -}
{-             Errors:  0: No Errors                               -}
{-                      1: NumPoints < 2                           -}
{-                      2: NumPoints not a power of two            -}
{-                                                                 -}
{-------------------------------------------------------------------}

procedure RealCorrelation(NumPoints : integer;
                      var Auto      : boolean;
                      var XReal     : TNvectorPtr;
                      var XImag     : TNvectorPtr;
                      var HReal     : TNvectorPtr;
                      var Error     : byte);

{-------------------------------------------------------------------}
{-                                                                 -}
{-   Input: NumPoints, Auto, XReal, XImag, HReal                   -}
{-   Output: XReal, XImag, Error                                   -}
{-                                                                 -}
{-   Purpose: This procedure performs a correlation (auto or       -}
{-            cross) of the real data XReal and HReal. The         -}
{-            correlation is returned in the complex vector        -}
{-            XReal, XImag.                                        -}
{-                                                                 -}
{- User Defined Types:                                             -}
{-         TNvector = array[0..TNArraySize] OF real                -}
{-      TNvectorPtr = ^TNvector                                    -}
{-                                                                 -}
{- Global Variables:  NumPoints : integer     Number of data       -}
{-                                            points in X          -}
{-                    Auto      : boolean     True => auto-        -}
{-                                                    correlation  -}
{-                                            False=> cross-       -}
{-                                                    correlation  -}
{-                    XReal     : TNvectorPtr First sample         -}
{-                    HReal     : TNvectorPtr Second sample        -}
{-                    Error     : byte        Indicates an error   -}
{-                                                                 -}
{-             Errors:  0: No Errors                               -}
{-                      1: NumPoints < 2                           -}
{-                      2: NumPoints not a power of two            -}
{-                                                                 -}
{-------------------------------------------------------------------}

procedure ComplexFFT(NumPoints : integer;
                     Inverse   : boolean;
                 var XReal     : TNvectorPtr;
                 var XImag     : TNvectorPtr;
                 var Error     : byte);

{-------------------------------------------------------------------}
{-                                                                 -}
{-   Input: NumPoints, Inverse, XReal, XImag                       -}
{-   Output: XReal, XImag, Error                                   -}
{-                                                                 -}
{-   Purpose: This procedure performs a fast Fourier transform     -}
{-            of the complex data XReal, XImag. The vectors XReal  -}
{-            and XImag are transformed in place.                  -}
{-                                                                 -}
{- User Defined Types:                                             -}
{-         TNvector = array[0..TNArraySize] of real                -}
{-         TNvectorPtr = ^TNvector                                 -}
{-                                                                 -}
{- Global Variables:  NumPoints : integer      Number of data      -}
{-                                             points in X         -}
{-                    Inverse   : BOOLEAN      FALSE => Forward    -}
{-                                                      Transform  -}
{-                                             TRUE => Inverse     -}
{-                                                     Transform   -}
{-                    XReal,                                       -}
{-                    XImag     : TNvectorPtr  Data points         -}
{-                    Error     : byte         Indicates an error  -}
{-                                                                 -}
{-             Errors:  0: No Errors                               -}
{-                      1: NumPoints < 2                           -}
{-                      2: NumPoints not a power of two            -}
{-                                                                 -}
{-------------------------------------------------------------------}

procedure ComplexConvolution(NumPoints : integer;
                         var XReal     : TNvectorPtr;
                         var XImag     : TNvectorPtr;
                         var HReal     : TNvectorPtr;
                         var HImag     : TNvectorPtr;
                         var Error     : byte);

{-------------------------------------------------------------------}
{-                                                                 -}
{-   Input: NumPoints, XReal, XImag, HReal, HImag                  -}
{-   Output: XReal, XImag, Error                                   -}
{-                                                                 -}
{-   Purpose: This procedure performs a convolution of the         -}
{-            data XReal, XImag and the data HReal and HImag. The  -}
{-            vectors XReal, XImag, HReal and HImag are            -}
{-            transformed in place.                                -}
{-                                                                 -}
{- User Defined Types:                                             -}
{-         TNvector = array[0..TNArraySize] of real                -}
{-      TNvectorPtr = ^TNvector                                    -}
{-                                                                 -}
{- Global Variables:  NumPoints   : integer     Number of data     -}
{-                                              points in X        -}
{-                    XReal,XImag : TNvectorPtr Data points        -}
{-                    HReal,HImag : TNvectorPtr Data points        -}
{-                    Error       : byte        Indicates an error -}
{-                                                                 -}
{-             Errors:  0: No Errors                               -}
{-                      1: NumPoints < 2                           -}
{-                      2: NumPoints not a power of two            -}
{-                                                                 -}
{-------------------------------------------------------------------}

procedure ComplexCorrelation(NumPoints : integer;
                         var Auto      : boolean;
                         var XReal     : TNvectorPtr;
                         var XImag     : TNvectorPtr;
                         var HReal     : TNvectorPtr;
                         var HImag     : TNvectorPtr;
                         var Error     : byte);

{-------------------------------------------------------------------}
{-                                                                 -}
{-   Input: NumPoints, Auto, XReal, XImag, HReal, HImag            -}
{-   Output: XReal, XImag, Error                                   -}
{-                                                                 -}
{-   Purpose: This procedure performs a correlation (auto or       -}
{-            cross) of the complex data XReal, XImag and the      -}
{-            complex data HReal, HImag. The vectors XReal, XImag, -}
{-            HReal, and HImag are transformed in place.           -}
{-                                                                 -}
{- User Defined Types:                                             -}
{-         TNvector = array[0..TNArraySize] of real                -}
{-      TNvectorPtr = ^TNvector                                    -}
{-                                                                 -}
{- Global Variables:  NumPoints   : integer   Number of data       -}
{-                                            points in X          -}
{-                    Auto        : boolean   True => auto-        -}
{-                                                    correlation  -}
{-                                            False=> cross-       -}
{-                                                    correlation  -}
{-                    XReal,XImag : TNvectorPtr First sample       -}
{-                    HReal,HImag : TNvectorPtr Second sample      -}
{-                    Error       : byte        Indicates an error -}
{-                                                                 -}
{-             Errors:  0: No Errors                               -}
{-                      1: NumPoints < 2                           -}
{-                      2: NumPoints not a power of two            -}
{-                                                                 -}
{-------------------------------------------------------------------}

implementation

procedure TestInput{(NumPoints    : integer;
                 var NumberOfBits : byte;
                 var Error        : byte)};
type
  ShortArray = array[1..13] of integer;

var
  Term : integer;

const
  PowersOfTwo : ShortArray = (2, 4, 8, 16, 32, 64, 128, 256,
                              512, 1024, 2048, 4096, 8192);

begin
  Error := 2;            { Assume NumPoints not a power of two  }
  if NumPoints < 2 then
    Error := 1;     { NumPoints < 2  }
  Term := 1;
  while (Term <= 13) and (Error = 2) do
  begin
    if NumPoints = PowersOfTwo[Term] then
    begin
      NumberOfBits := Term;
      Error := 0;  { NumPoints is a power of two  }
    end;
    Term := Succ(Term);
  end;
end; { procedure TestInput }

procedure MakeSinCosTable{(NumPoints : integer;
                       var SinTable  : TNvectorPtr;
                       var CosTable  : TNvectorPtr)};
var
  RealFactor, ImagFactor : Float;
  Term : integer;
  TermMinus1 : integer;
  UpperLimit : integer;

begin
  RealFactor :=  Cos(2 * Pi / NumPoints);
  ImagFactor := -Sqrt(1 - Sqr(RealFactor));
  CosTable^[0] := 1;
  SinTable^[0] := 0;
  CosTable^[1] := RealFactor;
  SinTable^[1] := ImagFactor;
  UpperLimit := NumPoints shr 1 - 1;
  for Term := 2 to UpperLimit do
  begin
    TermMinus1 := Term - 1;
    CosTable^[Term] :=  CosTable^[TermMinus1] * RealFactor -
                        SinTable^[TermMinus1] * ImagFactor;
    SinTable^[Term] :=  CosTable^[TermMinus1] * ImagFactor +
                        SinTable^[TermMinus1] * RealFactor;
  end;
end; { procedure MakeSinCosTable }

procedure FFT{(NumberOfBits : byte;
               NumPoints    : integer;
               Inverse      : boolean;
           var XReal        : TNvectorPtr;
           var XImag        : TNvectorPtr;
           var SinTable     : TNvectorPtr;
           var CosTable     : TNvectorPtr)};

const
  RootTwoOverTwo = 0.707106781186548;

var
  Term : byte;
  CellSeparation : integer;
  NumberOfCells : integer;
  NumElementsInCell : integer;
  NumElInCellLess1 : integer;
  NumElInCellSHR1 : integer;
  NumElInCellSHR2 : integer;
  RealRootOfUnity, ImagRootOfUnity : Float;
  Element : integer;
  CellElements : integer;
  ElementInNextCell : integer;
  Index : integer;
  RealDummy, ImagDummy : Float;

procedure BitInvert(NumberOfBits : byte;
                    NumPoints    : integer;
                var XReal        : TNvectorPtr;
                var XImag        : TNvectorPtr);

{-----------------------------------------------------------}
{- Input: NumberOfBits, NumPoints                          -}
{- Output: XReal, XImag                                    -}
{-                                                         -}
{- This procedure bit inverts the order of data in the     -}
{- vector X.  Bit inversion reverses the order of the      -}
{- binary representation of the indices; thus 2 indices    -}
{- will be switched.  For example, if there are 16 points, -}
{- Index 7 (binary 0111) would be switched with Index 14   -}
{- (binary 1110).  It is necessary to bit invert the order -}
{- of the data so that the transformation comes out in the -}
{- correct order.                                          -}
{-----------------------------------------------------------}

var
  Term : integer;
  Invert : integer;
  Hold : Float;
  NumPointsDiv2, K : integer;

begin
  NumPointsDiv2 := NumPoints shr 1;
  Invert := 0;
  for Term := 0 to NumPoints - 2 do
  begin
    if Term < Invert then   { Switch these two indices  }
    begin
      Hold := XReal^[Invert];
      XReal^[Invert] := XReal^[Term];
      XReal^[Term] := Hold;
      Hold := XImag^[Invert];
      XImag^[Invert] := XImag^[Term];
      XImag^[Term] := Hold;
    end;
    K := NumPointsDiv2;
    while K <= Invert do
    begin
      Invert := Invert - K;
      K := K shr 1;
    end;
    Invert := Invert + K;
  end;
end; { procedure BitInvert }

begin { procedure FFT }
  { The data must be entered in bit inverted order }
  { for the transform to come out in proper order  }
  BitInvert(NumberOfBits, NumPoints, XReal, XImag);

  if Inverse then
    { Conjugate the input  }
    for Element := 0 to NumPoints - 1 do
      XImag^[Element] := -XImag^[Element];

  NumberOfCells := NumPoints;
  CellSeparation := 1;
  for Term := 1 to NumberOfBits do
  begin
    { NumberOfCells halves; equals 2^(NumberOfBits - Term)  }
    NumberOfCells := NumberOfCells shr 1;
    { NumElementsInCell doubles; equals 2^(Term-1)  }
    NumElementsInCell := CellSeparation;
    { CellSeparation doubles; equals 2^Term  }
    CellSeparation := CellSeparation SHL 1;
    NumElInCellLess1 := NumElementsInCell - 1;
    NumElInCellSHR1 := NumElementsInCell shr 1;
    NumElInCellSHR2 := NumElInCellSHR1 shr 1;

    { Special case: RootOfUnity = EXP(-i 0)  }
    Element := 0;
    while Element < NumPoints do
    begin
      { Combine the X[Element] with the element in  }
      { the identical location in the next cell     }
      ElementInNextCell := Element + NumElementsInCell;
      RealDummy := XReal^[ElementInNextCell];
      ImagDummy := XImag^[ElementInNextCell];
      XReal^[ElementInNextCell] := XReal^[Element] - RealDummy;
      XImag^[ElementInNextCell] := XImag^[Element] - ImagDummy;
      XReal^[Element] := XReal^[Element] + RealDummy;
      XImag^[Element] := XImag^[Element] + ImagDummy;
      Element := Element + CellSeparation;
    end;

    for CellElements := 1 to NumElInCellSHR2 - 1 do
    begin
      Index := CellElements * NumberOfCells;
      RealRootOfUnity := CosTable^[Index];
      ImagRootOfUnity := SinTable^[Index];
      Element := CellElements;

      while Element < NumPoints do
      begin
        { Combine the X[Element] with the element in  }
        { the identical location in the next cell     }
        ElementInNextCell := Element + NumElementsInCell;
        RealDummy := XReal^[ElementInNextCell] * RealRootOfUnity -
                     XImag^[ElementInNextCell] * ImagRootOfUnity;
        ImagDummy := XReal^[ElementInNextCell] * ImagRootOfUnity +
                     XImag^[ElementInNextCell] * RealRootOfUnity;
        XReal^[ElementInNextCell] := XReal^[Element] - RealDummy;
        XImag^[ElementInNextCell] := XImag^[Element] - ImagDummy;
        XReal^[Element] := XReal^[Element] + RealDummy;
        XImag^[Element] := XImag^[Element] + ImagDummy;
        Element := Element + CellSeparation;
      end;
    end;

    { Special case: RootOfUnity = EXP(-i PI/4)  }
    if Term > 2 then
    begin
      Element := NumElInCellSHR2;
      while Element < NumPoints do
      begin
        { Combine the X[Element] with the element in  }
        { the identical location in the next cell     }
        ElementInNextCell := Element + NumElementsInCell;
        RealDummy := RootTwoOverTwo * (XReal^[ElementInNextCell] +
                     XImag^[ElementInNextCell]);
        ImagDummy := RootTwoOverTwo * (XImag^[ElementInNextCell] -
                     XReal^[ElementInNextCell]);
        XReal^[ElementInNextCell] := XReal^[Element] - RealDummy;
        XImag^[ElementInNextCell] := XImag^[Element] - ImagDummy;
        XReal^[Element] := XReal^[Element] + RealDummy;
        XImag^[Element] := XImag^[Element] + ImagDummy;
        Element := Element + CellSeparation;
      end;
    end;

    for CellElements := NumElInCellSHR2 + 1 to NumElInCellSHR1 - 1 do
    begin
      Index := CellElements * NumberOfCells;
      RealRootOfUnity := CosTable^[Index];
      ImagRootOfUnity := SinTable^[Index];
      Element := CellElements;
      while Element < NumPoints do
      begin
        { Combine the X[Element] with the element in  }
        { the identical location in the next cell     }
        ElementInNextCell := Element + NumElementsInCell;
        RealDummy := XReal^[ElementInNextCell] * RealRootOfUnity -
                     XImag^[ElementInNextCell] * ImagRootOfUnity;
        ImagDummy := XReal^[ElementInNextCell] * ImagRootOfUnity +
                     XImag^[ElementInNextCell] * RealRootOfUnity;
        XReal^[ElementInNextCell] := XReal^[Element] - RealDummy;
        XImag^[ElementInNextCell] := XImag^[Element] - ImagDummy;
        XReal^[Element] := XReal^[Element] + RealDummy;
        XImag^[Element] := XImag^[Element] + ImagDummy;
        Element := Element + CellSeparation;
      end;
    end;

    { Special case: RootOfUnity = EXP(-i PI/2)  }
    if Term > 1 then
    begin
      Element := NumElInCellSHR1;
      while Element < NumPoints do
      begin
        { Combine the X[Element] with the element in  }
        { the identical location in the next cell     }
        ElementInNextCell := Element + NumElementsInCell;
        RealDummy :=  XImag^[ElementInNextCell];
        ImagDummy := -XReal^[ElementInNextCell];
        XReal^[ElementInNextCell] := XReal^[Element] - RealDummy;
        XImag^[ElementInNextCell] := XImag^[Element] - ImagDummy;
        XReal^[Element] := XReal^[Element] + RealDummy;
        XImag^[Element] := XImag^[Element] + ImagDummy;
        Element := Element + CellSeparation;
      end;
    end;

    for CellElements := NumElInCellSHR1 + 1 to
                        NumElementsInCell - NumElInCellSHR2 - 1 do
    begin
      Index := CellElements * NumberOfCells;
      RealRootOfUnity := CosTable^[Index];
      ImagRootOfUnity := SinTable^[Index];
      Element := CellElements;
      while Element < NumPoints do
      begin
        { Combine the X[Element] with the element in  }
        { the identical location in the next cell     }
        ElementInNextCell := Element + NumElementsInCell;
        RealDummy := XReal^[ElementInNextCell] * RealRootOfUnity -
                     XImag^[ElementInNextCell] * ImagRootOfUnity;
        ImagDummy := XReal^[ElementInNextCell] * ImagRootOfUnity +
                     XImag^[ElementInNextCell] * RealRootOfUnity;
        XReal^[ElementInNextCell] := XReal^[Element] - RealDummy;
        XImag^[ElementInNextCell] := XImag^[Element] - ImagDummy;
        XReal^[Element] := XReal^[Element] + RealDummy;
        XImag^[Element] := XImag^[Element] + ImagDummy;
        Element := Element + CellSeparation;
      end;
    end;

    { Special case: RootOfUnity = EXP(-i 3PI/4)  }
    if Term > 2 then
    begin
      Element := NumElementsInCell - NumElInCellSHR2;
      while Element < NumPoints do
      begin
        { Combine the X[Element] with the element in  }
        { the identical location in the next cell     }
        ElementInNextCell := Element + NumElementsInCell;
        RealDummy := -RootTwoOverTwo * (XReal^[ElementInNextCell] -
                                        XImag^[ElementInNextCell]);
        ImagDummy := -RootTwoOverTwo * (XReal^[ElementInNextCell] +
                                        XImag^[ElementInNextCell]);
        XReal^[ElementInNextCell] := XReal^[Element] - RealDummy;
        XImag^[ElementInNextCell] := XImag^[Element] - ImagDummy;
        XReal^[Element] := XReal^[Element] + RealDummy;
        XImag^[Element] := XImag^[Element] + ImagDummy;
        Element := Element + CellSeparation;
      end;
    end;

    for CellElements := NumElementsInCell - NumElInCellSHR2 + 1 to
                                            NumElInCellLess1 do
    begin
      Index := CellElements * NumberOfCells;
      RealRootOfUnity := CosTable^[Index];
      ImagRootOfUnity := SinTable^[Index];
      Element := CellElements;
      while Element < NumPoints do
      begin
        { Combine the X[Element] with the element in  }
        { the identical location in the next cell     }
        ElementInNextCell := Element + NumElementsInCell;
        RealDummy := XReal^[ElementInNextCell] * RealRootOfUnity -
                     XImag^[ElementInNextCell] * ImagRootOfUnity;
        ImagDummy := XReal^[ElementInNextCell] * ImagRootOfUnity +
                     XImag^[ElementInNextCell] * RealRootOfUnity;
        XReal^[ElementInNextCell] := XReal^[Element] - RealDummy;
        XImag^[ElementInNextCell] := XImag^[Element] - ImagDummy;
        XReal^[Element] := XReal^[Element] + RealDummy;
        XImag^[Element] := XImag^[Element] + ImagDummy;
        Element := Element + CellSeparation;
      end;
    end;
  end;

  {----------------------------------------------------}
  {-  Divide all the values of the transformation     -}
  {-  by the square root of NumPoints. If taking the  -}
  {-  inverse, conjugate the output.                  -}
  {----------------------------------------------------}

  if Inverse then
    ImagDummy := -1/Sqrt(NumPoints)
  else
    ImagDummy :=  1/Sqrt(NumPoints);
  RealDummy := ABS(ImagDummy);
  for Element := 0 to NumPoints - 1 do
  begin
    XReal^[Element] := XReal^[Element] * RealDummy;
    XImag^[Element] := XImag^[Element] * ImagDummy;
  end;
end; { procedure FFT }

{$I FFT.inc} { Include procedure code }

end. { FFT87B2 }
