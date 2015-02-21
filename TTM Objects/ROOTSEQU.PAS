unit RootsEqu;

{----------------------------------------------------------------------------}
{-                                                                          -}
{-     Turbo Pascal Numerical Methods Toolbox                               -}
{-     Copyright (c) 1986, 87 by Borland International, Inc.                -}
{-                                                                          -}
{-  This unit provides procedures for finding the roots                     -}
{-  of a single equation in one variable.                                   -}
{-                                                                          -}
{----------------------------------------------------------------------------}

interface

{$IFOPT N+}
type
  Float = Double; { 8 byte real, requires 8087 math chip }

const
  TNNearlyZero = 1E-015;
{$ELSE}
type
  Float = real;   { 6 byte real, no math chip required }

const
  TNNearlyZero = 1E-07;
{$ENDIF}

  TNArraySize  = 30;   { maximum size of vectors }

type
  TNvector     = array[0..TNArraySize] of Float;
  TNIntVector  = array[0..TNArraySize] of integer;
  TNcomplex    = record
                   Re, Im : Float;
                 end;
  TNCompVector = array[0..TNArraySize] of TNcomplex;


procedure Newt_Horn_Defl(InitDegree : integer;
                         InitPoly   : TNvector;
                         Guess      : Float;
                         Tol        : Float;
                         MaxIter    : integer;
                     var Degree     : integer;
                     var NumRoots   : integer;
                     var Poly       : TNvector;
                     var Root       : TNvector;
                     var Imag       : TNvector;
                     var Value      : TNvector;
                     var Deriv      : TNvector;
                     var Iter       : TNIntVector;
                     var Error      : byte);

{----------------------------------------------------------------------------}
{-                                                                          -}
{-             Input: InitDegree, InitPoly, Guess, Tol, MaxIter             -}
{-            Output: Degree, NumRoots, Poly, Root, Imag, Value, Deriv      -}
{-                    Iter, Error                                           -}
{-                                                                          -}
{-           Purpose: This unit provides a procedure for finding several    -}
{-                    roots of a user specified polynomial given a user     -}
{-                    specified initial guess.  The procedure implements    -}
{-                    Newton-Horner's algorithm for finding a single        -}
{-                    root of a polynomial and deflation techniques for     -}
{-                    reducing a polynomial given one of its roots.         -}
{-                    Should the polynomial contain no more than two        -}
{-                    complex roots, they may also be determined.           -}
{-                    The user must specify the desired tolerance in the    -}
{-                    answer and the maximum number of iterations.          -}
{-                                                                          -}
{- Pre-Defined Types: TNvector    = array[0..TNArraySize] of real;          -}
{-                    TNIntVector = array[0..TNArraySize] of integer;       -}
{-                                                                          -}
{-  Global Variables: InitDegree : integer;  degree of user's polynomial    -}
{-                    InitPoly   : TNvector; coefficients of user's         -}
{-                                           polynomial where InitPoly[n]   -}
{-                                           is the coefficient of X^n      -}
{-                    Guess      : real;     user's estimate of root        -}
{-                    Tol        : real;     tolerance in answer            -}
{-                    Degree     : real;     degree of reduced polynomial   -}
{-                                           left when procedure is done    -}
{-                                           (>0 if all the roots were      -}
{-                                           not Found)                     -}
{-                    Poly       : TNvector; coefficients of reduced poly   -}
{-                    NumRoots   : integer;  number of roots calculated     -}
{-                    Root       : TNvector; real parts of calculated roots -}
{-                    Imag       : TNvector; imaginary parts of roots (non- -}
{-                                           zero for no more than 2)       -}
{-                    Value      : TNvector; value of the polynomial at     -}
{-                                           each root                      -}
{-                    Deriv      : TNvector; value of the derivative at     -}
{-                                           each root                      -}
{-                    Iter       : TNIntVector; number of iterations it     -}
{-                                              took to find each root      -}
{-                    Error      : byte;     flags if something went wrong  -}
{-                                                                          -}
{-            Errors: 0: No error                                           -}
{-                    1: Iter >= MaxIter                                    -}
{-                    2: The slope was zero at some point                   -}
{-                    3: Degree <= 0                                        -}
{-                    4: Tol <= 0                                           -}
{-                    5: MaxIter < 0                                        -}
{-                                                                          -}
{----------------------------------------------------------------------------}


procedure Laguerre(var Degree    : integer;
                   var Poly      : TNCompVector;
                       InitGuess : TNcomplex;
                       Tol       : Float;
                       MaxIter   : integer;
                   var NumRoots  : integer;
                   var Roots     : TNCompVector;
                   var yRoots    : TNCompVector;
                   var Iter      : TNIntVector;
                   var Error     : byte);

{----------------------------------------------------------------------------}
{-                                                                          -}
{-            Input: Degree, Poly, InitGuess, Tol, MaxIter                  -}
{-           Output: Degree, Poly, NumRoots, Roots, yRoots, Iter, Error     -}
{-                                                                          -}
{-          Purpose: This unit provides a procedure for finding all the     -}
{-                   roots (real and complex) to a polynomial.              -}
{-                   Laguerre's method with deflation is used.              -}
{-                   The user must input the coefficients of the quadratic  -}
{-                   and the tolerance in the answers generated.            -}
{-                                                                          -}
{-  Pre-defined Types: TNcomplex    = record                                -}
{-                                      Re, Im : real;                      -}
{-                                    end;                                  -}
{-                                                                          -}
{-                     TNIntVector  = array[0..TNArraySize] of integer;     -}
{-                     TNCompVector = array[0..TNArraySize] of TNcomplex;   -}
{-                                                                          -}
{- Global Variables: Degree    : integer;      degree of deflated           -}
{-                                             polynomial                   -}
{-                   Poly      : TNCompVector; coefficients of deflated     -}
{-                                             polynomial where Poly[n] is  -}
{-                                             the coefficient of X^n       -}
{-                   InitGuess : TNcomplex;    initial guess to a root      -}
{-                                             (may be very crude)          -}
{-                   Tol       : real;         tolerance in the answer      -}
{-                   MaxIter   : integer;      number of iterations         -}
{-                   NumRoots  : integer;      number of roots calculated   -}
{-                   Roots     : TNCompVector; the roots calculated         -}
{-                   yRoots    : TNCompVector; the value of the function    -}
{-                                             at the calculated roots      -}
{-                   Iter      : TNIntVector;  number iteration it took to  -}
{-                                             find each root               -}
{-                   Error     : byte;         flags an error               -}
{-                                                                          -}
{-           Errors: 0: No error                                            -}
{-                   1: Iter > MaxIter                                      -}
{-                   2: Degree <= 0                                         -}
{-                   3: Tol <= 0                                            -}
{-                   4: MaxIter < 0                                         -}
{-                                                                          -}
{----------------------------------------------------------------------------}

implementation

{$I RootsEqu.inc}  { Include procedure code }

end. { RootsEqu }
