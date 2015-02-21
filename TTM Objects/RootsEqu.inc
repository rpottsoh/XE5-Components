procedure Newt_Horn_Defl{(InitDegree : integer;
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
                      var Error      : byte)};

var
  Iter1 : integer;

procedure SynDiv(Degree  : integer;
                 Poly    : TNvector;
                 X       : Float;
             var NewPoly : TNvector);

{--------------------------------------------------------------------------}
{- Input:  Degree, Poly                                                   -}
{- Output: NewPoly                                                        -}
{-                                                                        -}
{- This procedure applies the technique of synthetic division             -}
{- to a polynomial, Poly, at the value X.  The kth element of NewPoly     -}
{- is the (k-1)th element of the new polynomial. The 0th element          -}
{- of the resulting polynomial, NewPoly, is the value of the polynomial   -}
{- at X                                                                   -}
{--------------------------------------------------------------------------}

var
  Term : integer;

begin
  NewPoly[Degree] := Poly[Degree];
  for Term := Degree - 1 downto 0 do
    NewPoly[Term] := NewPoly[Term + 1] * X + Poly[Term];
end; { procedure SynDiv }

procedure QuadraticFormula(A       : Float;
                           B       : Float;
                           C       : Float;
                       var ReRoot1 : Float;
                       var ImRoot1 : Float;
                       var ReRoot2 : Float;
                       var ImRoot2 : Float);

{----------------------------------------------------------------}
{- Input:  A, B, C                                              -}
{- Output: ReRoot1, ImRoot1, ReRoot2, ImRoot2                   -}
{-                                                              -}
{- This procedure applies the quadratic formula to the equation -}
{- AX^2 + BX + C, where A,B,C are real.  It returns the real or -}
{- complex roots of the equation                                -}
{----------------------------------------------------------------}

var
  Denominator, Discrim : Float;

begin
  Denominator := 2 * A;
  ReRoot1 := -B / Denominator;
  ReRoot2 := ReRoot1;
  Discrim := B * B - 4 * A * C;
  if Discrim < 0 then
    begin
      ImRoot1 := -Sqrt(-Discrim) / Denominator;
      ImRoot2 :=  Sqrt(-Discrim) / Denominator;
    end
  else
    begin
      if B < 0 then  { Choose ReRoot1 to have the greatest absolute value }
        ReRoot1 := ReRoot1 + Sqrt(Discrim) / Denominator
      else
        ReRoot1 := ReRoot1 - Sqrt(Discrim) / Denominator;
      ReRoot2 := C / (A * ReRoot1);   { The product of the 2 roots is C/A }
      ImRoot1 := 0;
      ImRoot2 := 0;
    end;
end;    { procedure QuadraticFormula }

procedure TestData(InitDegree : integer;
                   InitPoly   : TNvector;
                   Tol        : Float;
                   MaxIter    : integer;
               var Degree     : integer;
               var Poly       : TNvector;
               var NumRoots   : integer;
               var Roots      : TNvector;
               var yRoots     : TNvector;
               var Iter       : TNIntVector;
               var Error      : byte);

{----------------------------------------------------------}
{- Input:  InitDegree, InitPoly, Tol, MaxIter             -}
{- Output: Degree, Poly, NumRoots, Roots, yRoots,         -}
{-         Iter, Error                                    -}
{-                                                        -}
{- This procedure sets the initial value of the above     -}
{- variables.  This procedure also tests the tolerance    -}
{- (Tol), maximum number of iterations (MaxIter), and     -}
{- Degree for errors and returns the appropriate error    -}
{- code.  Finally, it examines the coefficients of Poly.  -}
{- If the constant term is zero, then zero is one of the  -}
{- roots and the polynomial is deflated accordingly. Also -}
{- if the leading coefficient is zero, then Degree is     -}
{- reduced until the leading coefficient is non-zero.     -}
{----------------------------------------------------------}

var
  Term : integer;

begin
  Error := 0;
  NumRoots := 0;
  Degree := InitDegree;
  Poly := InitPoly;
  if Tol <= 0 then
    Error := 4;
  if MaxIter < 0 then
    Error :=5;
  { Reduce Degree until leading coefficient <> zero }
  while (Degree > 0) and (ABS(Poly[Degree]) < TNNearlyZero) do
    { Reduce Degree until leading coefficient <> zero }
    Degree  :=  Pred(Degree);
  if Degree <= 0 then
    Error := 3;
  { Deflate polynomial until the constant term <> zero }
  while (ABS(Poly[0]) < TNNearlyZero) and (Degree > 0) do
  begin
    NumRoots := Succ(NumRoots);
    Roots[NumRoots] := 0;
    yRoots[NumRoots] := 0;
    Iter[NumRoots] := 0;
    Degree := Pred(Degree);
    for Term := 0 to Degree do
      Poly[Term] := Poly[Term + 1];
  end;
end; { procedure TestData }

procedure FindValueAndDeriv(Degree : integer;
                            Poly   : TNvector;
                            X      : Float;
                        var Value  : Float;
                        var Deriv  : Float);

{--------------------------------------------------------------------}
{- Input:  Degree, Poly, X                                          -}
{- Output: Value, Deriv                                             -}
{-                                                                  -}
{- This procedure applies the technique of synthetic division to    -}
{- determine both the Value and derivative of the polynomial, Poly, -}
{- at X.  The 0th element of the first synthetic division is the    -}
{- value of the polynomial at X, and the 1st element of the second  -}
{- synthetic division is the derivative of the polynomial at X.     -}
{--------------------------------------------------------------------}

var
  Poly1, Poly2 : TNvector;
begin
  SynDiv(Degree, Poly, X, Poly1);
  Value := Poly1[0];
  SynDiv(Degree, Poly1, X, Poly2);
  Deriv := Poly2[1];
end; { procedure FindValueAndDeriv }

procedure FindOneRoot(Degree  : integer;
                      Poly    : TNvector;
                      Guess   : Float;
                      Tol     : Float;
                      MaxIter : integer;
                  var Root    : Float;
                  var Value   : Float;
                  var Deriv   : Float;
                  var Iter    : integer;
                  var Error   : byte);

{-------------------------------------------------------------------}
{- Input:  Degree, Poly, Guess, Tol, MaxIter                       -}
{- Output: Root, Value, Deriv, Iter, Error                         -}
{-                                                                 -}
{- A single root of the polynomial Poly.  The root must be         -}
{- approximated within MaxIter iterations to a tolerance of Tol.   -}
{- The root, value of the polynomial at the root (Value), and the  -}
{- value of the derivative of the polynomial at the root (Deriv),  -}
{- and the number of iterations (Iter) are returned. If no root    -}
{- is found, the appropriate error code (Error) is returned.       -}
{-------------------------------------------------------------------}

var
  Found : boolean;
  OldX, OldY, OldDeriv,
  NewX, NewY, NewDeriv : Float;

procedure CheckSlope(Slope : Float;
                 var Error : byte);

{---------------------------------------------------}
{- Input:  Slope                                   -}
{- Output: Error                                   -}
{-                                                 -}
{- This procedure checks the slope to see if it is -}
{- zero.  The Newton Raphson algorithm may not be  -}
{- applied at a point where the slope is zero.     -}
{---------------------------------------------------}

begin
  if ABS(Slope) <= TNNearlyZero then
    Error := 2;
end; { procedure CheckSlope }

procedure Initial(Degree   : integer;
                  Poly     : TNvector;
                  Guess    : Float;
              var OldX     : Float;
              var OldY     : Float;
              var OldDeriv : Float;
              var Found    : boolean;
              var Iter     : integer;
              var Error    : byte);

{-------------------------------------------------------------}
{- Input:  Degree, Poly, Guess                               -}
{- Output: OldX, OldY, OldDeriv, Found, Iter, Error          -}
{-                                                           -}
{- This procedure sets the initial values of the above       -}
{- variables. If OldY is zero, then a root has been          -}
{- found and Found = TRUE.                                   -}
{-------------------------------------------------------------}

begin
  Found := false;
  Iter := 0;
  Error := 0;
  OldX := Guess;
  FindValueAndDeriv(Degree, Poly, OldX, OldY, OldDeriv);
  if ABS(OldY) <= TNNearlyZero then
    Found := true
  else
    CheckSlope(OldDeriv, Error);
end; { procedure Initial }

function TestForRoot(X, OldX, Y, Tol : Float) : boolean;

{----------------------------------------------------------------}
{ These are the stopping criteria.  Four different ones are     -}
{ provided.  If you wish to change the active criteria, simply  -}
{ comment off the current criteria (including the preceding OR) -}
{ and remove the comment brackets from the criteria (including  -}
{ the following OR) you wish to be active.                      -}
{----------------------------------------------------------------}

begin
  TestForRoot :=                      {---------------------------}
    (ABS(Y) <= TNNearlyZero)          {- Y=0                     -}
                                      {-                         -}
           or                         {-                         -}
                                      {-                         -}
    (ABS(X - OldX) < ABS(OldX*Tol))   {- Relative change in X    -}
                                      {-                         -}
 (*        or                      *) {-                         -}
 (*                                *) {-                         -}
 (* (ABS(OldX - X) < Tol)          *) {- Absolute change in X    -}
 (*                                *) {-                         -}
 (*        or                      *) {-                         -}
 (*                                *) {-                         -}
 (* (ABS(Y) <= Tol)                *) {- Absolute change in Y    -}
                                      {---------------------------}

{-----------------------------------------------------------------------}
{- The first criteria simply checks to see if the value of the         -}
{- function is zero.  You should probably always keep this criteria    -}
{- active.                                                             -}
{-                                                                     -}
{- The second criteria checks the relative error in X. This criteria   -}
{- evaluates the fractional change in X between interations. Note      -}
{- that X has been multiplied through the inequality to avoid divide   -}
{- by zero errors.                                                     -}
{-                                                                     -}
{- The third criteria checks the absolute difference in X between      -}
{- iterations.                                                         -}
{-                                                                     -}
{- The fourth criteria checks the absolute difference between          -}
{- the value of the function and zero.                                 -}
{-----------------------------------------------------------------------}

end; { procedure TestForRoot }

begin { procedure FindOneRoot }
  Initial(Degree, Poly, Guess, OldX, OldY, OldDeriv, Found, Iter, Error);
  while not(Found) and (Error = 0) and (Iter<MaxIter) do
  begin
    Iter := Succ(Iter);
    NewX := OldX - OldY / OldDeriv;
    FindValueAndDeriv(Degree, Poly, NewX, NewY, NewDeriv);
    Found := TestForRoot(NewX, OldX, NewY, Tol);
    OldX := NewX;
    OldY := NewY;
    OldDeriv := NewDeriv;
    if not(Found) then
      CheckSlope(OldDeriv, Error);
  end;
  Root := OldX;
  Value := OldY;
  Deriv := OldDeriv;
  if not(Found) and (Error = 0) and (Iter >= MaxIter) then
    Error := 1;
  if Found then
    Error := 0;
end; { procedure FindOneRoot }

procedure ReducePolynomial(var Degree : integer;
                           var Poly   : TNvector;
                               Root   : Float);

{------------------------------------------------------}
{- Input:  Degree, Poly, Root                         -}
{- Output: Degree, Poly                               -}
{-                                                    -}
{- This procedure deflates the polynomial Poly by     -}
{- factoring out the Root.  Degree is reduced by one. -}
{------------------------------------------------------}

var
  NewPoly : TNvector;
  Term : integer;
begin
  SynDiv(Degree, Poly, Root, NewPoly);
  Degree := Pred(Degree);
  for Term := 0 to Degree do
    Poly[Term] := NewPoly[Term+1];
end; { procedure ReducePolynomial }

begin  { procedure Newt_Horn_Defl }
  TestData(InitDegree, InitPoly, Tol, MaxIter,
           Degree, Poly, NumRoots, Root, Value, Iter, Error);
  while (Error=0) and (Degree>2) do
  begin
    FindOneRoot(Degree, Poly, Guess, Tol, MaxIter, Root[NumRoots+1],
                Value[NumRoots+1], Deriv[NumRoots+1], Iter[NumRoots+1], Error);
    if Error = 0 then
    begin
      NumRoots := Succ(NumRoots);
      {------------------------------------------------------}
      {- The next statement refines the approximate root by -}
      {- plugging it into the original polynomial.  This    -}
      {- eliminates a lot of the round-off error            -}
      {- accumulated through many iterations                -}
      {------------------------------------------------------}
      if NumRoots > 1 then
      begin
        Iter1 := 0;
        FindOneRoot(InitDegree, InitPoly, Root[NumRoots],
                    Tol, MaxIter, Root[NumRoots], Value[NumRoots],
                    Deriv[NumRoots], Iter1, Error);
        Iter[NumRoots] := Iter[NumRoots] + Iter1;
      end;
      ReducePolynomial(Degree, Poly, Root[NumRoots]);
      Guess := Root[NumRoots];
    end;
  end;
  case Degree of
    1 : begin           { Solve this linear }
          Degree := 0;
          NumRoots := Succ(NumRoots);
          Root[NumRoots] := -Poly[0] / Poly[1];
          FindOneRoot(InitDegree, InitPoly, Root[NumRoots], Tol,
                      MaxIter, Root[NumRoots], Value[NumRoots],
                      Deriv[NumRoots], Iter[NumRoots], Error);
        end;

    2 : begin           { Solve this quadratic }
          Degree := 0;
          NumRoots := Succ(Succ(NumRoots));
          QuadraticFormula(Poly[2], Poly[1], Poly[0],
                           Root[NumRoots - 1], Imag[NumRoots - 1],
                           Root[NumRoots], Imag[NumRoots]);
          if ABS(Imag[NumRoots]) < TNNearlyZero then
            { if the roots are real, they can be     }
            { made more accurate using Newton-Horner }
            begin
              FindOneRoot(InitDegree, InitPoly, Root[NumRoots-1], Tol,
                          MaxIter, Root[NumRoots-1], Value[NumRoots-1],
                          Deriv[NumRoots-1], Iter[NumRoots-1], Error);

              FindOneRoot(InitDegree, InitPoly, Root[NumRoots], Tol,
                          MaxIter, Root[NumRoots], Value[NumRoots],
                          Deriv[NumRoots], Iter[NumRoots], Error);
            end
          else
            { If the roots are complex, then assign    }
            { the value to be zero (which is true,     }
            { except for some roundoff error) and the  }
            { derivative to be zero (which is usually  }
            { FALSE; the derivative is usually complex }
            begin
              Value[NumRoots-1] := 0;    Value[NumRoots] := 0;
              Deriv[NumRoots-1] := 0;    Deriv[NumRoots] := 0;
              Iter[NumRoots-1] := 0;     Iter[NumRoots] := 0;
            end;
        end;
  end; { case }
end; { procedure Newt_Horn_Defl }

procedure Laguerre{(var Degree   : integer;
                   var Poly      : TNCompVector;
                       InitGuess : TNcomplex;
                       Tol       : Float;
                       MaxIter   : integer;
                   var NumRoots  : integer;
                   var Roots     : TNCompVector;
                   var yRoots    : TNCompVector;
                   var Iter      : TNIntVector;
                   var Error     : byte)};

type
  TNquadratic = record
                  A, B, C : Float;
                end;

var
  AddIter    : integer;
  InitDegree : integer;
  InitPoly   : TNCompVector;
  GuessRoot  : TNcomplex;

{----------- Here are a few complex operations ------------}

procedure Conjugate(var C1, C2 : TNcomplex);
begin
  C2.Re := C1.Re;
  C2.Im := -C1.Im;
end; { procedure Conjugate }

function Modulus(var C1 : TNcomplex) : Float;
begin
  Modulus := Sqrt(Sqr(C1.Re) + Sqr(C1.Im));
end; { function Modulus }

procedure Add(var C1, C2, C3 : TNcomplex);
begin
  C3.Re := C1.Re + C2.Re;
  C3.Im := C1.Im + C2.Im;
end; { procedure Add }

procedure Sub(var C1, C2, C3 : TNcomplex);
begin
  C3.Re := C1.Re - C2.Re;
  C3.Im := C1.Im - C2.Im;
end; { procedure Sub }

procedure Mult(var C1, C2, C3 : TNcomplex);
begin
  C3.Re := C1.Re * C2.Re - C1.Im * C2.Im;
  C3.Im := C1.Im * C2.Re + C1.Re * C2.Im;
end; { procedure Mult }

procedure Divide(var C1, C2, C3 : TNcomplex);
var
  Dum1, Dum2 : TNcomplex;
  E : Float;
begin
  Conjugate(C2, Dum1);
  Mult(C1, Dum1, Dum2);
  E := Sqr(Modulus(C2));
  C3.Re := Dum2.Re / E;
  C3.Im := Dum2.Im / E;
end;  { procedure Divide }

procedure SquareRoot(var C1, C2 : TNcomplex);
const
  NearlyZero = 1E-015;
var
  R, Theta : Float;
begin
  R := Sqrt(Sqr(C1.Re) + Sqr(C1.Im));
  if ABS(C1.Re) < NearlyZero then
    begin
      if C1.Im < 0 then
        Theta := Pi / 2
      else
        Theta := -Pi / 2;
    end
  else
    if C1.Re < 0 then
      Theta := ArcTan(C1.Im / C1.Re) + Pi
    else
      Theta := ArcTan(C1.Im / C1.Re);
  C2.Re := Sqrt(R) * Cos(Theta / 2);
  C2.Im := Sqrt(R) * Sin(Theta / 2);
end; { procedure SquareRoot }

procedure InitAndTest(var Degree     : integer;
                      var Poly       : TNCompVector;
                          Tol        : Float;
                          MaxIter    : integer;
                          InitGuess  : TNcomplex;
                      var NumRoots   : integer;
                      var Roots      : TNCompVector;
                      var yRoots     : TNCompVector;
                      var Iter       : TNIntVector;
                      var GuessRoot  : TNcomplex;
                      var InitDegree : integer;
                      var InitPoly   : TNCompVector;
                      var Error      : byte);

{----------------------------------------------------------}
{- Input:  Degree, Poly, Tol, MaxIter, InitGuess          -}
{- Output: InitDegree, InitPoly, Degree, Poly, NumRoots,  -}
{-         Roots, yRoots, Iter, GuessRoot, Error          -}
{-                                                        -}
{- This procedure sets the initial value of the above     -}
{- variables.  This procedure also tests the tolerance    -}
{- (Tol), maximum number of iterations (MaxIter), and     -}
{- code.  Finally, it examines the coefficients of Poly.  -}
{- If the constant term is zero, then zero is one of the  -}
{- roots and the polynomial is deflated accordingly. Also -}
{- if the leading coefficient is zero, then Degree is     -}
{- reduced until the leading coefficient is non-zero.     -}
{----------------------------------------------------------}

var
  Term : integer;

begin
  Error := 0;
  if Degree <= 0 then
    Error := 2;      { degree is less than 2 }
  if Tol <= 0 then
    Error := 3;
  if MaxIter < 0 then
    Error := 4;

  if Error = 0 then
  begin
    NumRoots := 0;
    GuessRoot := InitGuess;
    InitDegree := Degree;
    InitPoly := Poly;
    { Reduce degree until leading coefficient <> zero }
    while (Degree > 0) and (Modulus(Poly[Degree]) < TNNearlyZero) do
      Degree := Pred(Degree);
    { Deflate polynomial until the constant term <> zero }
    while (Modulus(Poly[0]) = 0) and (Degree > 0) do
    begin
      { Zero is a root }
      NumRoots := Succ(NumRoots);
      Roots[NumRoots].Re := 0;
      Roots[NumRoots].Im := 0;
      yRoots[NumRoots].Re := 0;
      yRoots[NumRoots].Im := 0;
      Iter[NumRoots] := 0;
      Degree := Pred(Degree);
      for Term := 0 to Degree do
        Poly[Term] := Poly[Term + 1];
    end;
  end;
end; { procedure InitAndTest }

procedure FindOneRoot(Degree    : integer;
                      Poly      : TNCompVector;
                      GuessRoot : TNcomplex;
                      Tol       : Float;
                      MaxIter   : integer;
                  var Root      : TNcomplex;
                  var yValue    : TNcomplex;
                  var Iter      : integer;
                  var Error     : byte);

{-------------------------------------------------------------------}
{- Input:  Degree, Poly, GuessRoot, Tol, MaxIter                   -}
{- Output: Root, yValue, Iter, Error                               -}
{-                                                                 -}
{- This procedure approximates a single root of the polynomial     -}
{- Poly.  The root must be approximated within MaxIter             -}
{- iterations to a tolerance of Tol.  The root, value of the       -}
{- polynomial at the root (yValue), and the number of iterations   -}
{- (Iter) are returned. If no root is found, the appropriate error -}
{- code (Error) is returned.                                       -}
{-------------------------------------------------------------------}

var
  Found : boolean;
  Dif : TNcomplex;
  yPrime, yDoublePrime : TNcomplex;

procedure EvaluatePoly(Degree       : integer;
                       Poly         : TNCompVector;
                       X            : TNcomplex;
                   var yValue       : TNcomplex;
                   var yPrime       : TNcomplex;
                   var yDoublePrime : TNcomplex);

{--------------------------------------------------------------------}
{- Input:  Degree, Poly, X                                          -}
{- Output: yValue, yPrime, yDoublePrime                             -}
{-                                                                  -}
{- This procedure applies the technique of synthetic division to    -}
{- determine value (yValue), first derivative (yPrime) and second   -}
{- derivative (yDoublePrime) of the  polynomial, Poly, at X.        -}
{- The 0th element of the first synthetic division is the           -}
{- value of Poly at X, the 1st element of the second synthetic      -}
{- division is the first derivative of Poly at X, and twice the     -}
{- 2nd element of the third synthetic division is the second        -}
{- derivative of Poly at X.                                         -}
{--------------------------------------------------------------------}

var
  Loop : integer;
  Dummy, yDPdummy : TNcomplex;
  Deriv, Deriv2 : TNCompVector;

begin
  Deriv[Degree] := Poly[Degree];
  for Loop := Degree - 1 downto 0 do
  begin
    Mult(Deriv[Loop + 1], X, Dummy);
    Add(Dummy, Poly[Loop], Deriv[Loop]);
  end;
  yValue := Deriv[0];    { Value of Poly at X }

  Deriv2[Degree] := Deriv[Degree];
  for Loop := Degree - 1 downto 1 do
  begin
    Mult(Deriv2[Loop + 1], X, Dummy);
    Add(Dummy, Deriv[Loop], Deriv2[Loop]);
  end;
  yPrime := Deriv2[1];   { 1st deriv. of Poly at X }

  yDPdummy := Deriv2[Degree];
  for Loop := Degree - 1 downto 2 do
  begin
    Mult(yDPdummy, X, Dummy);
    Add(Dummy, Deriv2[Loop], yDPdummy);
  end;
  yDoublePrime.Re := 2 * yDPdummy.Re;    { 2nd derivative of Poly at X }
  yDoublePrime.Im := 2 * yDPdummy.Im;
end; { procedure EvaluatePoly }

procedure ConstructDifference(Degree       : integer;
                              yValue       : TNcomplex;
                              yPrime       : TNcomplex;
                              yDoublePrime : TNcomplex;
                          var Dif          : TNcomplex);

{------------------------------------------------------------------}
{- Input:  Degree, yValue, yPrime, yDoublePrime                   -}
{- Output: Dif                                                    -}
{-                                                                -}
{- This procedure computes the difference between approximations; -}
{- given information about the function and its first two         -}
{- derivatives.                                                   -}
{-----------------------------------------------------------------}

var
  yPrimeSQR, yTimesyDPrime, Sum, SRoot,
  Numer1, Numer2, Numer, Denom : TNcomplex;

begin
  Mult(yPrime, yPrime, yPrimeSQR);
  yPrimeSQR.Re := Sqr(Degree - 1) * yPrimeSQR.Re;
  yPrimeSQR.Im := Sqr(Degree - 1) * yPrimeSQR.Im;
  Mult(yValue, yDoublePrime, yTimesyDPrime);
  yTimesyDPrime.Re := (Degree - 1) * Degree * yTimesyDPrime.Re;
  yTimesyDPrime.Im := (Degree - 1) * Degree * yTimesyDPrime.Im;
  Sub(yPrimeSQR, yTimesyDPrime, Sum);
  SquareRoot(Sum, SRoot);
  Add(yPrime, SRoot, Numer1);
  Sub(yPrime, SRoot, Numer2);
  if Modulus(Numer1) > Modulus(Numer2) then
    Numer := Numer1
  else
    Numer := Numer2;
  Denom.Re := Degree * yValue.Re;
  Denom.Im := Degree * yValue.Im;
  if Modulus(Numer) < TNNearlyZero then
    begin
      Dif.Re := 0;
      Dif.Im := 0;
    end
  else
    Divide(Denom, Numer, Dif);  { The difference is the   }
                                { inverse of the fraction }
end; { procedure ConstructDifference }

function TestForRoot(X, Dif, Y, Tol : Float) : boolean;

{--------------------------------------------------------------------}
{-  These are the stopping criteria.  Four different ones are       -}
{-  provided.  If you wish to change the active criteria, simply    -}
{-  comment off the current criteria (including the appropriate OR) -}
{-  and remove the comment brackets from the criteria (including    -}
{-  the appropriate OR) you wish to be active.                      -}
{--------------------------------------------------------------------}

begin
  TestForRoot :=                      {---------------------------}
    (ABS(Y) <= TNNearlyZero)          {- Y=0                     -}
                                      {-                         -}
           or                         {-                         -}
                                      {-                         -}
    (ABS(Dif) < ABS(X * Tol))         {- Relative change in X    -}
                                      {-                         -}
                                      {-                         -}
 (*       or                      *)  {-                         -}
 (*                               *)  {-                         -}
 (* (ABS(Dif) < Tol)              *)  {- Absolute change in X    -}
 (*                               *)  {-                         -}
 (*       or                      *)  {-                         -}
 (*                               *)  {-                         -}
 (* (ABS(Y) <= Tol)               *)  {- Absolute change in Y    -}
                                      {---------------------------}

{-----------------------------------------------------------------------}
{- The first criteria simply checks to see if the value of the         -}
{- function is zero.  You should probably always keep this criteria    -}
{- active.                                                             -}
{-                                                                     -}
{- The second criteria checks the relative error in X. This criteria   -}
{- evaluates the fractional change in X between interations. Note      -}
{- that X has been multiplied throught the inequality to avoid divide  -}
{- by zero errors.                                                     -}
{-                                                                     -}
{- The third criteria checks the absolute difference in X between      -}
{- iterations.                                                         -}
{-                                                                     -}
{- The fourth criteria checks the absolute difference between          -}
{- the value of the function and zero.                                 -}
{-----------------------------------------------------------------------}

end; { procedure TestForRoot }

begin { procedure FindOneRoot }
  Root := GuessRoot;
  Found := false;
  Iter := 0;
  EvaluatePoly(Degree, Poly, Root, yValue, yPrime, yDoublePrime);
  while (Iter < MaxIter) and not(Found) do
  begin
    Iter := Succ(Iter);
    ConstructDifference(Degree, yValue, yPrime, yDoublePrime, Dif);
    Sub(Root, Dif, Root);
    EvaluatePoly(Degree, Poly, Root, yValue, yPrime, yDoublePrime);
    Found := TestForRoot(Modulus(Root), Modulus(Dif), Modulus(yValue), Tol);
  end;
  if not(Found) then Error := 1;   { Iterations execeeded MaxIter }
end; { procedure FindOneRoot }

procedure ReducePoly(var Degree : integer;
                     var Poly   : TNCompVector;
                     Root       : TNcomplex);

{------------------------------------------------------}
{- Input: Degree, Poly, Root                          -}
{- Output: Degree, Poly                               -}
{-                                                    -}
{- This procedure deflates the polynomial Poly by     -}
{- factoring out the Root.  Degree is reduced by one. -}
{------------------------------------------------------}

var
  Term : integer;
  NewPoly : TNCompVector;
  Dummy : TNcomplex;

begin
  NewPoly[Degree - 1] := Poly[Degree];
  for Term := Degree - 1 downto 1 do
  begin
    Mult(NewPoly[Term], Root, Dummy);
    Add(Dummy, Poly[Term], NewPoly[Term - 1]);
  end;
  Degree := Pred(Degree);
  Poly := NewPoly;
end; { procedure ReducePoly }

begin  { procedure Laguerre }
  InitAndTest(Degree, Poly, Tol, MaxIter, InitGuess, NumRoots, Roots,
              yRoots, Iter, GuessRoot, InitDegree, InitPoly, Error);
  while (Degree > 0) and (Error = 0) do
  begin
    FindOneRoot(Degree, Poly, GuessRoot, Tol, MaxIter,
                Roots[NumRoots + 1], yRoots[NumRoots + 1],
                Iter[NumRoots + 1], Error);
    if Error = 0 then
    begin
      {------------------------------------------------------}
      {- The next statement refines the approximate root by -}
      {- plugging it into the original polynomial.  This    -}
      {- eliminates a lot of the round-off error            -}
      {- accumulated through many iterations                -}
      {------------------------------------------------------}
      FindOneRoot(InitDegree, InitPoly, Roots[NumRoots + 1],
                  Tol, MaxIter, Roots[NumRoots + 1],
                  yRoots[NumRoots + 1], AddIter, Error);
      Iter[NumRoots + 1] := Iter[NumRoots + 1] + AddIter;
      NumRoots := Succ(NumRoots);
      ReducePoly(Degree, Poly, Roots[NumRoots]); { Reduce polynomial }
    end;
    GuessRoot := Roots[NumRoots];
  end;
end; { procedure Laguerre }
