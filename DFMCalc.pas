{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O-,P+,Q-,R+,S-,T-,U-,V+,W-,X+,Y-,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
unit DFMCalc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CNFtoCFG, TMSIDataTypes{, globals{};

const
  DFMItems   = OncePerRev; //The last channel not including Hammer
  WindowSize = 8192;
  OverlapSize = 2293;  {trunc of 28% * WindowSize}
  HalfWindowSize = WindowSize DIV 2;
  QuarterWindowSize = WindowSize DIV 4;
  MaxRevs    = WindowSize DIV 2;  // Maximum possible revs seen in WindowSize
  MaxWin     = (12500 * 200) DIV OverlapSize;
type
  DataStoreType       = smallint;
  SmallIntWindowArray = array[1..WindowSize] of smallint;
  TReadOptions         = ( QuickRead, DiskRead );
  AxisDir =  ( X, Y, Z );
  FFTRes  =  ( Re, Im );
  ForcePos = ( PosKist, PosDFM );
  DoubleWindowArray   = array[1..WindowSize] of double;
  TRevArray = array[0..MaxRevs] of integer;
  DoubleFlatNoAliasArray = array[1..QuarterWindowSize] of double;
  FFTDoubleFlatNoAliasArray = array[FFTRes,1..QuarterWindowSize] of double;


  TDFMCalcer = class(TComponent)
  private
    FConfig     : TCNFtoCFG;
    FMassParameters : TMassParameters;
    FWheelParameters : TWheelParameters;
    FSysDefs        : TSystemDefaults;
    FPercentComplete : integer;
    FPostProcessRunning : integer;
    ChanData   : array[1..60] of TFileStream;
    DFMChan    : array[1..DFMItems] of integer;  // holds channel num for that item
    StreamPointer : integer; // not a pointer per se, but does "point"
    DFMBuffer     : array[1..DFMItems] of DoubleWindowArray;
    TempRawBuffer : SmallIntWindowArray;
    SineBuffer,
    CosineBuffer  : DoubleWindowArray;
    PointsEndRev  : TRevArray;
    //Kistler
      r1        : single;
      d1        : single;
      M1        : single;
      I1        : single;
    // bearing
      r3        : single;
      d3        : single;
      M3        : single;
      I3        : single;
    // spindle
      r2        : single;
      d2        : single;
      M2        : single;
      I2        : single;
      r23,r31   : single;

    Fdfm,
    Mdfm    : array[AxisDir] of DoubleWindowArray;
    Adfm,
    Alphadfm : array[AxisDir] of DoubleWindowArray;
    RecMagInfo,
    RecPhaInfo  : array[ForcePos,0..9{x},0..9{y}] of DoubleFlatNoAliasArray;
    SpectraX,
    SpectraY : FFTDoubleFlatNoAliasArray;
    FRawSpectra,
    MRawSpectra  : array[ForcePos,AxisDir] of FFTDoubleFlatNoAliasArray;   // comes back from FFT twice as large as necessary
    ARawSpectra  : array[AxisDir] of FFTDoubleFlatNoAliasArray;
    AlphaRawSpectra : array[AxisDir] of FFTDoubleFlatNoAliasArray;
    FHan     : DoubleWindowArray;
    DFMUsed  : boolean;
    TestStartPos : integer;  // place in file where test starts
    FDataPath : string;
    Avgs      : integer;  // running FFT Averages
    WindowsInData : integer;
    ChanDum : TChannelBufferIntData;
    FPushAbort : boolean;
    FTimeSave : boolean;
    FTimeCount : integer;
    CalcsNeeded : integer;
    function GetHanning(index : integer): double;
    procedure PSDCalc( Pos, xx, yy : integer);
    procedure CSDCalc( Pos, xx, yy : integer);
    function OverWriteData : integer;
    function SaveCalculationOutputs : integer;
  protected
    function  InitMasses : integer;
    procedure CreateFHanningWindow;
    function Process : integer;
    procedure DFMFreqResultsToBuffer;
    procedure DFMCalcResultsToBuffer;
    procedure DFMTimeResultsToBuffer;
    procedure FillDFMBuffers( const ChanInt : TChannelBufferIntData; ReadOption : TReadOptions);
    function  SinCosToBuffer : integer;
    procedure FillOnceRevBuffer( const ChanInt : TChannelBufferIntData; ReadOption : TReadOptions );
    procedure InitializeParameters;
    function InitPost : integer;
  public
    constructor create(AOwner : TComponent); override;
    destructor Destroy; override;
    function Init8192 : integer;
    function Process8192( const ChanInt : TChannelBufferIntData; var ChanRes : TChannelBuffer ) : integer;
    function PostTestProcess( DataPath : string ): integer;
    property Hanning[ index : integer ] : double
      read GetHanning;
    property MassParameters : TMassParameters
      read FMassParameters
      write FMassParameters;
    property WheelParameters : TWheelParameters
      read FWheelParameters
      write FWheelParameters;
    property SysDefs : TSystemDefaults
      read FSysDefs
      write FSysDefs;
    property PercentComplete : integer
      read FPercentComplete;
    property PostProcessRunning : integer
      read FPostProcessRunning;
    property PushAbort : boolean
      write FPushAbort;
    property TimeSave : boolean
      write FTimeSave;
  published
    property Config : TCNFtoCFG
      read FConfig
      write FConfig;
  end;


implementation
uses
  FFT87B2,
  Math;
{$define DFMPlus}

var
  datafile : textfile;
  FirstRev,
  FirstBuffer : boolean;
  PointsInPrevFullRev : integer;
  XReal, XImag,
  YReal, YImag : TNVectorPtr;{}

constructor TDFMCalcer.create;
begin
  inherited create(Aowner);
  CreateFHanningWindow;
  FPushAbort    := FALSE;
  FTimeSave     := FALSE;
  FTimeCount    := 1;
end;

destructor TDFMCalcer.destroy;
var i : integer;
begin
  for i := 1 to DFMItems do
    if fileexists(format('%s\Chan%d.bin',[FDataPath,DFMChan[i]])) then
      ChanData[ DFMChan[i] ].Destroy;
  inherited Destroy;
end;

function TDFMCalcer.InitMasses : integer;
begin
  Result := 0;
  // fill in old mass parameters with new nomenclature --see 1/21/99 moment equations in job file
  //Kistler
  with FMassParameters.Masses[1] do
  begin
    r1        := CGOffset;
    d1        := Diameter;
    M1        := Mass;
    I1        := MInertia;
  end;
  // Bearing
  with FMassParameters.Masses[2] do
  begin
    r3        := CGOffset;
    d3        := Diameter;
    M3        := Mass;
    I3        := MInertia;
  end;
  // spindle
  with FMassParameters.Masses[3] do
  begin
    M2        := Mass + FWheelParameters.Mass;
    r2        := (FWheelParameters.CGAttachFace * FWheelParameters.Mass + CGOffset*Mass) / M2;
    d2        := Diameter;
    I2        := {Rotor} MInertia + Mass*SQR(CGOffset-R2) +
                 {Wheel} FWheelParameters.MInertia + FWheelParameters.Mass*SQR(r2-FWheelParameters.CGAttachFace);
  end;
  r31 := FMassParameters.Radius[1];
  r23 := FMassParameters.Radius[2];
  if (d1 = 0) OR (d2 = 0) OR (d3 = 0) then
    Result := 1;
end;

//-------------------------------------------------------------------------//
// Installs parameters from various setup files into data module's         //
// variables.                                                              //
//-------------------------------------------------------------------------//
procedure TDFMCalcer.InitializeParameters;
var i : integer;
begin
  StreamPointer := 1;
  for i := 1 to DFMItems do
  begin
  // assign the Channel number from Config to the proper DFM Item
    DFMChan[i] := FConfig.DFMPosChanNum[i];
  // open file data streams -- File read version
    ChanData[ DFMChan[i] ] := TFileStream.Create(format('c:\binData\Chan%d.bin',[DFMChan[i]]), fmOpenRead or fmShareExclusive);
  end;
  InitMasses;
end;


procedure TDFMCalcer.FillOnceRevBuffer( const ChanInt : TChannelBufferIntData; ReadOption : TReadOptions );
var ConvertFactor : double;
    pnt           : integer;
begin
  if FConfig.ChannelUsed[ DFMChan[ OncePerRev ] ] then
  begin
    // read in data
    if ReadOption = DiskRead then
    begin
      with ChanData[ DFMChan[OncePerRev] ] do
      begin
        Position := StreamPointer * sizeof( DataStoreType );
        ReadBuffer( TempRawBuffer, WindowSize * sizeof( DataStoreType ) );
      end;
    end
    else
      move( ChanInt[ DFMChan[OncePerRev] ], TempRawBuffer, sizeof( ChanInt[1] ) );
    ConvertFactor :=   ( 1000.0                                { mv/V }
                       * FConfig.MaxAnalogVoltage / 32768.0          { V/ADcounts }
                       / FConfig.Sensitivity[ DFMChan[OncePerRev] ]      { mv/Units }
                       / FConfig.Gain[ DFMChan[OncePerRev] ])
                       * FConfig.Polarity[ DFMChan[OncePerRev] ];
    for pnt := 1 to WindowSize do
      DFMBuffer[ OncePerRev, pnt ] := (TempRawBuffer[ pnt ] - FConfig.ZeroOffset[ DFMChan[OncePerRev] ]) * ConvertFactor;
  end
  else
    fillchar( DFMBuffer[ OncePerRev ], sizeof( DFMBuffer[ OncePerRev ] ), #0 );
end;

//------------------------------------------------------------------------------
// Creates a Sine and Cosine Buffer across block of data.
// Additional feature of Sync Check (Result = 1 or 2) added 10/04/99 --meh
//------------------------------------------------------------------------------
function TDFMCalcer.SinCosToBuffer : integer;
var
  pnt, RevNo, i : integer;
  ThetaBuffer      : DoubleWindowArray;
  totalpnt : integer;
  TwoPI : Double;
  PointsInRev,
  revpnt,
  rev : integer;
  datafile : textfile;
  TotalFullRevs : integer;
  SampRate : double;
  SpeedConvert : single;
  MeasuredSpeed, ControlSpeed : double;
begin
  // scan to set angle
  RevNo := 0;
  pnt   := 1;
// diagnostic to look at trigger
//  assignfile( datafile, 'dfm_trig.txt' );
//  rewrite( datafile );
//  for pnt := 1 to WindowSize do
//    writeln( datafile, DFMBuffer[ OncePerRev, pnt ]:8:4 );
//  close( datafile );
//  halt;

  while pnt < WindowSize do
  begin
  // Count until pulses go high to account for trigger to pass
    while (pnt < WindowSize) AND (DFMBuffer[ OncePerRev, pnt ] < FSysDefs.TrigResetLevel) do
      inc( pnt );
// then count until first point below TrigLevel volts to be a trigger.
    while (pnt < WindowSize) AND (DFMBuffer[ OncePerRev, pnt ] > FSysDefs.TrigLevel) do
      inc( pnt );
    if pnt <> WindowSize then
    begin
      PointsEndRev[RevNo] := (pnt-1); // rev 0 is partial rev
      inc( RevNo );
    end;
  end;
  // forget about sines and cosines up to first good trigger for now
  totalpnt := PointsEndRev[0]; // start at first
  TotalFullRevs := RevNo - 1;
  TwoPi := 2 * pi; // pi is a function
  for rev := 1 to TotalFullRevs do
  begin
    revpnt := 0;
    PointsInRev := PointsEndRev[rev]-PointsEndRev[rev-1];
    if NOT FirstRev then
    begin
      if abs(PointsInPrevFullRev - PointsInRev) > FSysDefs.MaxDataSampsDiff then
      begin
        Result := 1;  // encoder check failed
        exit;
      end;
    end
    else
    begin
       MeasuredSpeed := (FConfig.SampleRate * 3600) / (300 * PointsInRev);
       if FConfig.SpeedUnits = 'KPH' then
         SpeedConvert := siSpeed
       else
         SpeedConvert := 1.0;
       ControlSpeed  := FConfig.StartSpeed/SpeedConvert;
       if abs(MeasuredSpeed - ControlSpeed) > FSysDefs.MaxSpeedTol then
       begin
         Result := 2;
         exit;
       end;
       FirstRev := FALSE;
    end;
    PointsInPrevFullRev := PointsInRev;
    while revpnt < PointsInRev do
    begin
      inc( totalpnt );
      ThetaBuffer[totalpnt] := ((revpnt/PointsInRev)*TwoPi)-(FSysDefs.TrigOffset/360*TwoPi); //Theta triggers 13 degrees off
      SineBuffer[totalpnt]   := sin( ThetaBuffer[totalpnt] );
      CosineBuffer[totalpnt] := cos( ThetaBuffer[totalpnt] );
      inc( revpnt );
    end;
    if (rev = 1) then // assume the first part is the same as the first full rev
    begin
      for i := 1 to PointsEndRev[0] do
      begin
        SineBuffer[i]   := SineBuffer[i+PointsInRev];
        CosineBuffer[i] := CosineBuffer[i+PointsInRev];
      end;
    end;
    if (rev = TotalFullRevs) then // assume the last part is the same as the last full rev
    begin
      for i := (PointsEndRev[Rev]+1) to WindowSize do
      begin
        SineBuffer[i]   := SineBuffer[i-PointsInRev];
        CosineBuffer[i] := CosineBuffer[i-PointsInRev];
      end;
    end;

  end;
end;

procedure TDFMCalcer.FillDFMBuffers( const ChanInt : TChannelBufferIntData; ReadOption : TReadOptions);
var
  DFMPos        : integer;
  ConvertFactor : double;
  pnt : integer;
begin
  // read in data and convert to Engineering Units
  for DFMPos := KistFx to Spin4Y do // take care of all DFM Positions
  begin
    if FConfig.ChannelUsed[ DFMChan[ DFMPos ] ] then
    begin
      if ReadOption = DiskRead then
      begin
        with ChanData[ DFMChan[DFMPos] ] do
        begin
          Position := StreamPointer * sizeof( DataStoreType );
          ReadBuffer( TempRawBuffer, WindowSize * sizeof( DataStoreType ) );
        end;
      end
      else
        move( ChanInt[ DFMChan[DFMPos] ], TempRawBuffer, sizeof(ChanInt[1]));
      ConvertFactor :=   ( 1000.0                                { mv/V }
                         * FConfig.MaxAnalogVoltage / 32768.0          { V/ADcounts }
                         / FConfig.Sensitivity[ DFMChan[DFMPos] ]      { mv/Units }
                         / FConfig.Gain[ DFMChan[DFMPos] ])
                         * FConfig.Polarity[ DFMChan[DFMPos] ];
      for pnt := 1 to WindowSize do
        DFMBuffer[ DFMPos, pnt ] := (TempRawBuffer[ pnt ] - FConfig.ZeroOffset[ DFMChan[DFMPos] ]) * ConvertFactor;
    end
    else
      fillchar( DFMBuffer[ DFMPos ], sizeof( DFMBuffer[ DFMPos ] ), #0 );
  end;
end;

procedure TDFMCalcer.DFMFreqResultsToBuffer;
var
  pnt : integer;
  error : byte;
  Magscale : double;
  OutfileName : string;
  dataout : textfile;
begin

  // FdfmX
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := Fdfm[X,pnt] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    FRawSpectra[PosDFM,X,Re,pnt] := XReal^[pnt-1];
    FRawSpectra[PosDFM,X,Im,pnt] := XImag^[pnt-1];
  end;

  // FdfmY
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := Fdfm[Y,pnt] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do// Flat, NonAliased Portion
  begin
    FRawSpectra[PosDFM,Y,Re,pnt] := XReal^[pnt-1];
    FRawSpectra[PosDFM,Y,Im,pnt] := XImag^[pnt-1];
  end;

  // FdfmZ
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := Fdfm[Z,pnt] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    FRawSpectra[PosDFM,Z,Re,pnt] := XReal^[pnt-1];
    FRawSpectra[PosDFM,Z,Im,pnt] := XImag^[pnt-1];
  end;

   // MdfmX
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := Mdfm[X,pnt] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    MRawSpectra[PosDFM,X,Re,pnt] := XReal^[pnt-1];
    MRawSpectra[PosDFM,X,Im,pnt] := XImag^[pnt-1];
  end;

  // MdfmZ
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := Mdfm[Z,pnt] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    MRawSpectra[PosDFM,Z,Re,pnt] := XReal^[pnt-1];
    MRawSpectra[PosDFM,Z,Im,pnt] := XImag^[pnt-1];
  end;

 // AdfmX
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := Adfm[X,pnt] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    ARawSpectra[X,Re,pnt] := XReal^[pnt-1];
    ARawSpectra[X,Im,pnt] := XImag^[pnt-1];
  end;

  // AdfmY
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := Adfm[Y,pnt] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do// Flat, NonAliased Portion
  begin
    ARawSpectra[Y,Re,pnt] := XReal^[pnt-1];
    ARawSpectra[Y,Im,pnt] := XImag^[pnt-1];
  end;

  // AdfmZ
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := Adfm[Z,pnt] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    ARawSpectra[Z,Re,pnt] := XReal^[pnt-1];
    ARawSpectra[Z,Im,pnt] := XImag^[pnt-1];
  end;

   // AlphadfmX
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := Alphadfm[X,pnt] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    AlphaRawSpectra[X,Re,pnt] := XReal^[pnt-1];
    AlphaRawSpectra[X,Im,pnt] := XImag^[pnt-1];
  end;

  // AlphadfmZ
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := Alphadfm[Z,pnt] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    AlphaRawSpectra[Z,Re,pnt] := XReal^[pnt-1];
    AlphaRawSpectra[Z,Im,pnt] := XImag^[pnt-1];
  end;

  // KistFx
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := DFMBuffer[ KistFx, pnt ] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    FRawSpectra[PosKist,X,Re,pnt] := XReal^[pnt-1];
    FRawSpectra[PosKist,X,Im,pnt] := XImag^[pnt-1];
  end;

  // PosKistY
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := DFMBuffer[ KistFy, pnt ] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    FRawSpectra[PosKist,Y,Re,pnt] := XReal^[pnt-1];
    FRawSpectra[PosKist,Y,Im,pnt] := XImag^[pnt-1];
  end;

  // PosKistZ
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := DFMBuffer[ KistFz, pnt ] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    FRawSpectra[PosKist,Z,Re,pnt] := XReal^[pnt-1];
    FRawSpectra[PosKist,Z,Im,pnt] := XImag^[pnt-1];
  end;

  // MKistX
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := DFMBuffer[ KistMx, pnt ] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    MRawSpectra[PosKist,X,Re,pnt] := XReal^[pnt-1];
    MRawSpectra[PosKist,X,Im,pnt] := XImag^[pnt-1];
  end;

  // MKistZ
  for pnt := 1 to WindowSize do
    XReal^[pnt-1] := DFMBuffer[ KistMz, pnt ] * FHan[pnt];
  fillchar( XImag^, sizeof( XImag^ ), #0 );
  RealFFT(WindowSize,false,Xreal,XImag,error);
  if error <> 0 then
    showmessage( inttostr(error) + ' occurred in FreqResultsToBuffer');
  for pnt := 1 to QuarterWindowSize do // Flat, NonAliased Portion
  begin
    MRawSpectra[PosKist,Z,Re,pnt] := XReal^[pnt-1];
    MRawSpectra[PosKist,Z,Im,pnt] := XImag^[pnt-1];
  end;

end;

procedure TDFMCalcer.DFMCalcResultsToBuffer;
var
  pos,
  xx,
  yy : integer;
begin
  // begin writing all Results
  for Pos := ord(PosKist) to ord(PosDFM) do
    for xx := 0 to 9 do
      for yy := 0 to 9 do
      begin
        if (ForcePos(Pos) = PosDFM) OR
           ((ForcePos(Pos) = PosKist) AND (xx < 5) AND (yy < 5)) then
        begin
          case xx of
            0 {Fx}    : SpectraX := FRawSpectra[ForcePos(Pos),X];
            1 {Fy}    : SpectraX := FRawSpectra[ForcePos(Pos),Y];
            2 {Fz}    : SpectraX := FRawSpectra[ForcePos(Pos),Z];
            3 {Mx}    : SpectraX := MRawSpectra[ForcePos(Pos),X];
            4 {Mz}    : SpectraX := MRawSpectra[ForcePos(Pos),Z];
            5 {Ax}    : SpectraX := ARawSpectra[X];
            6 {Ay}    : SpectraX := ARawSpectra[Y];
            7 {Az}    : SpectraX := ARawSpectra[Z];
            8 {Alphax}: SpectraX := AlphaRawSpectra[X];
            9 {Alphaz}: SpectraX := AlphaRawSpectra[Z];
          end;
          case yy of
            0 {Fx}    : SpectraY := FRawSpectra[ForcePos(Pos),X];
            1 {Fy}    : SpectraY := FRawSpectra[ForcePos(Pos),Y];
            2 {Fz}    : SpectraY := FRawSpectra[ForcePos(Pos),Z];
            3 {Mx}    : SpectraY := MRawSpectra[ForcePos(Pos),X];
            4 {Mz}    : SpectraY := MRawSpectra[ForcePos(Pos),Z];
            5 {Ax}    : SpectraY := ARawSpectra[X];
            6 {Ay}    : SpectraY := ARawSpectra[Y];
            7 {Az}    : SpectraY := ARawSpectra[Z];
            8 {Alphax}: SpectraY := AlphaRawSpectra[X];
            9 {Alphaz}: SpectraY := AlphaRawSpectra[Z];
          end;
          if NOT((FSysDefs.Options = ImpedanceOpt) AND (ForcePos(Pos) = PosKist)) then
          begin
            if xx = yy then
              psdCalc( Pos, xx, yy )
            else if (yy > xx) AND // don't calculate duplicate cross values
                  (FSysDefs.Options > TrackingTireOpt) then
            csdCalc( Pos, xx, yy );
          end;
        end;
      end;
end;

procedure TDFMCalcer.DFMTimeResultsToBuffer;
var
  XVal          : double;
  AlphaX2, AlphaZ2 : double;
  Ax2, Az2, Ax1, Az1, Ax3, Az3 : double;
  x2, z2, x1, z1, x3, z3, x2d,z2d   : double;
  AGx1, AGx2, AGz1, AGz2, AGx3, AGz3 : double;
  Ay1, Ay2, Ay3 : double;
  pnt : integer;
begin
  // now calculate DFM Results
  if FTimeSave AND (FTimeCount = 1) then
  begin
    assignfile( datafile, FDataPath +'\TimeSave.txt');
    rewrite( datafile );
  end;
  for pnt := 1 to WindowSize do
  begin
  // Spindle
    AlphaX2 := (DFMBuffer[Spin3y,pnt]{3y}-DFMBuffer[Spin1y,pnt]{1y})/d2;
    AlphaZ2 := (DFMBuffer[Spin2y,pnt]{2y}-DFMBuffer[Spin4y,pnt]{4y})/d2;
  // calc A2s
    Ax2 := AlphaZ2*SineBuffer[pnt] + AlphaX2*CosineBuffer[pnt];
    Ay2 := (DFMBuffer[Spin1y,pnt]{1y}+DFMBuffer[Spin2y,pnt]{2y}+DFMBuffer[Spin3y,pnt]{3y}+DFMBuffer[Spin4y,pnt]{4y})/4;
    Az2 := AlphaZ2*CosineBuffer[pnt] - AlphaX2*SineBuffer[pnt];
   // calc AG2s
    x2 := (DFMBuffer[Spin2x,pnt]{2x} + DFMBuffer[Spin4x,pnt]{4x})/2;
    z2 := (DFMBuffer[Spin1z,pnt]{1z} + DFMBuffer[Spin3z,pnt]{3z})/2;
    x2d := z2*SineBuffer[pnt] + x2*CosineBuffer[pnt];
    z2d := z2*CosineBuffer[pnt] - x2*SineBuffer[pnt];

    AGx2 := x2d - r2*Az2;
    AGz2 := (z2d + r2*Ax2)-1;

    Alphadfm[X,pnt] := Ax2;
    Alphadfm[Z,pnt] := Az2;
    Adfm[X,pnt] := AGx2;
    Adfm[Y,pnt] := Ay2;
    Adfm[Z,pnt] := AGz2;

    if FTimeSave then
      write( datafile, ((pnt-1)/6250):10:4, Ax2:10:4, Az2:10:4, AGx2:10:4, Ay2:10:4, AGz2:10:4 );

 // Kistler
     // calc A1s
     Ax1 := (DFMBuffer[Kist3y,pnt]{3y}-DFMBuffer[Kist1y,pnt]{1y})/d1;
     Ay1 := (DFMBuffer[Kist1y,pnt]{1y}+DFMBuffer[Kist2y,pnt]{2y}+DFMBuffer[Kist3y,pnt]{3y}+DFMBuffer[Kist4y,pnt]{4y})/4;
     Az1 := (DFMBuffer[Kist2y,pnt]{2y}-DFMBuffer[Kist4y,pnt]{4y})/d1;
     // calc AG1s
     x1 := (DFMBuffer[Kist2x,pnt]{2x} + DFMBuffer[Kist4x,pnt]{4x})/2;
     z1 := (DFMBuffer[Kist1z,pnt]{1z} + DFMBuffer[Kist3z,pnt]{3z})/2;

     AGx1 := x1 - r1*Az1;
     AGz1 := z1 + r1*Ax1;

     if FTimeSave then
       write( datafile, DFMBuffer[Kist2x,pnt]:10:4,
                        DFMBuffer[Kist4x,pnt]:10:4,
                        DFMBuffer[Kist1y,pnt]:10:4,
                        DFMBuffer[Kist2y,pnt]:10:4,
                        DFMBuffer[Kist3y,pnt]:10:4,
                        DFMBuffer[Kist4y,pnt]:10:4,
                        DFMBuffer[Kist1z,pnt]:10:4,
                        DFMBuffer[Kist3z,pnt]:10:4);

 // Bearing Housing
     // calc A3s
     Ax3 := (DFMBuffer[Bear3y,pnt]{3y}-DFMBuffer[Bear1y,pnt]{1y})/d3;
     Ay3 := (DFMBuffer[Bear1y,pnt]{1y}+DFMBuffer[Bear2y,pnt]{2y}+DFMBuffer[Bear3y,pnt]{3y}+DFMBuffer[Bear4y,pnt]{4y})/4;
     Az3 := (DFMBuffer[Bear2y,pnt]{2y}-DFMBuffer[Bear4y,pnt]{4y})/d3;
     // calc AG3s
     x3 := (DFMBuffer[Bear2x,pnt]{2x} + DFMBuffer[Bear4x,pnt]{4x})/2;
     z3 := (DFMBuffer[Bear1z,pnt]{1z} + DFMBuffer[Bear3z,pnt]{3z})/2;

     AGx3 := x3 - r3*Az3;
     AGz3 := z3 + r3*Ax3;

     if FTimeSave then
       write( datafile, DFMBuffer[Bear2x,pnt]:10:4,
                        DFMBuffer[Bear4x,pnt]:10:4,
                        DFMBuffer[Bear1y,pnt]:10:4,
                        DFMBuffer[Bear2y,pnt]:10:4,
                        DFMBuffer[Bear3y,pnt]:10:4,
                        DFMBuffer[Bear4y,pnt]:10:4,
                        DFMBuffer[Bear1z,pnt]:10:4,
                        DFMBuffer[Bear3z,pnt]:10:4);
 // DFM Calcs
     Fdfm[X,pnt] := DFMBuffer[KistFx,pnt]{Fx} + M1*AGx1 + M2*AGx2 + M3*AGx3;
     Fdfm[Y,pnt] := DFMBuffer[KistFy,pnt]{Fy} + M1*Ay1  + M2*Ay2  + M3*Ay3;
     Fdfm[Z,pnt] := DFMBuffer[KistFz,pnt]{Fz} + M1*AGz1 + M2*AGz2 + M3*AGz3;
     Mdfm[X,pnt] := DFMBuffer[KistMx,pnt]{Mx} + I1*Ax1  + I2*Ax2 + I3*Ax3 +
                    DFMBuffer[KistFz,pnt]{Fz}*(r2+r23+r31) +
                    M1*AGz1*(r2+r23+r31) + M2*AGz2*r2 + M3*AGz3*(r2+r23);
     Mdfm[Z,pnt] := DFMBuffer[KistMz,pnt]{Mz} + I1*Az1  + I2*Az2 + I3*Az3 -
                    DFMBuffer[KistFx,pnt]{Fx}*(r2+r23+r31) -
                    M1*AGx1*(r2+r23+r31) - M2*AGx2*r2 - M3*AGx3*(r2+r23);
     if FTimeSave then
       writeln( datafile, DFMBuffer[KistFx,pnt]:10:4,
                          DFMBuffer[KistFy,pnt]:10:4,
                          DFMBuffer[KistFz,pnt]:10:4,
                          Fdfm[X,pnt]:10:4,
                          Fdfm[Y,pnt]:10:4,
                          Fdfm[Z,pnt]:10:4 );

  end; {each pnt in Window }
  if FTimeSave AND (FTimeCount = 4) then
  begin
    closefile(datafile);
    FTimeSave := FALSE;
    FTimeCount := 1;
  end
  else if FTimeSave then
    inc(FTimeCount);

end;

procedure TDFMCalcer.PSDCalc( Pos, xx, yy : integer);
var
  pnt : integer;
  magscale : double;
begin
  MagScale := (4/3)  * (2 / WindowSize) * (2 * WindowSize / (FConfig.SampleRate* 1000));  //latter is to adjust to BFS data
  for pnt := 1 to QuarterWindowSize do
    RecMagInfo[ForcePos(Pos), xx, yy, pnt] := ((RecMagInfo[ForcePos(Pos), xx, yy, pnt]*Avgs)+((sqr(SpectraX[Re,pnt]) + sqr(SpectraX[Im,pnt])) * MagScale))/(Avgs+1);
end;

procedure TDFMCalcer.CSDCalc( Pos, xx, yy : integer);
var
  pnt : integer;
  TempRecInfoReal,
  TempRecInfoImag,
  TempRecInfo,
  magscale : double;
begin
  MagScale := (4/3)  * (2 / WindowSize)* (2 * WindowSize / (FConfig.SampleRate*1000));  //latter is to adjust to BFS data
  for pnt := 1 to QuarterWindowSize do
  begin
    TempRecInfoReal := SpectraX[Re,pnt]*SpectraY[Re,pnt] - SpectraX[Im,pnt]*SpectraY[Im,pnt];
    TempRecInfoImag := SpectraX[Im,pnt]*SpectraY[Re,pnt] + SpectraX[Re,pnt]*SpectraY[Im,pnt];
    // mag
    RecMagInfo[ForcePos(Pos), xx, yy, pnt] := ((RecMagInfo[ForcePos(Pos), xx, yy, pnt]*Avgs)+ (sqrt(sqr(TempRecInfoReal) + sqr(TempRecInfoImag)) * MagScale))/(Avgs+1);
    // phase
    TempRecInfo     := RecPhaInfo[ForcePos(Pos), xx, yy, pnt]; // old value
    RecPhaInfo[ForcePos(Pos), xx, yy, pnt] := (arctan2(TempRecInfoImag,TempRecInfoReal) * (180/pi)) * -1.0;
    if RecPhaInfo[ForcePos(Pos), xx, yy, pnt] < 0 then
      RecPhaInfo[ForcePos(Pos), xx, yy, pnt] := RecPhaInfo[ForcePos(Pos), xx, yy, pnt] + 360.0;{}
    RecPhaInfo[ForcePos(Pos), xx, yy, pnt] := ((TempRecInfo*Avgs) + RecPhaInfo[ForcePos(Pos), xx, yy, pnt]) / (Avgs+1);
  end;
end;


function TDFMCalcer.SaveCalculationOutputs : integer;
var
  DlgRes : word;
  XStr, YStr : string;
  xx, yy     : byte;
  CheckForOverwrite : boolean;
  dataout : textfile;
  pnt : integer;
  StartTime,
  EndTime : TDateTime;
  loopnum : integer;
  OutFileName : string;
  Ext : string[5];
  pos : integer;
begin
  Result := 0;
  // begin writing all Results
  loopnum := 0;
  for Pos := ord(PosKist) to ord(PosDFM) do
    for xx := 0 to 9 do
      for yy := 0 to 9 do
        if (ForcePos(Pos) = PosDFM) OR
           ((ForcePos(Pos) = PosKist) AND (xx < 5) AND (yy < 5)) then
        begin
          case xx of
            0 {Fx}    : XStr     := 'Fx';
            1 {Fy}    : XStr     := 'Fy';
            2 {Fz}    : XStr     := 'Fz';
            3 {Mx}    : XStr     := 'Mx';
            4 {Mz}    : XStr     := 'Mz';
            5 {Ax}    : XStr     := 'Ax';
            6 {Ay}    : XStr     := 'Ay';
            7 {Az}    : XStr     := 'Az';
            8 {Alphax}: XStr     := 'Alphax';
            9 {Alphaz}: XStr     := 'Alphaz';
          end;
          case yy of
            0 {Fx}    : YStr     := 'Fx';
            1 {Fy}    : YStr     := 'Fy';
            2 {Fz}    : YStr     := 'Fz';
            3 {Mx}    : YStr     := 'Mx';
            4 {Mz}    : YStr     := 'Mz';
            5 {Ax}    : YStr     := 'Ax';
            6 {Ay}    : YStr     := 'Ay';
            7 {Az}    : YStr     := 'Az';
            8 {Alphax}: YStr     := 'Alphax';
            9 {Alphaz}: YStr     := 'Alphaz';
          end;
          inc(loopnum);
          if Pos = ord(PosKist) then
            Ext := 'K.txt'
          else
            Ext := 'D.txt';
          if NOT((FSysDefs.Options = ImpedanceOpt) AND (ForcePos(Pos) = PosKist)) then
          begin
            if (xx = yy) then
            begin
              OutFileName := FDataPath + '\'+XStr + XStr + Ext;
              assignfile( dataout, OutFileName );
              rewrite( dataout );
              for pnt := 1 to QuarterWindowSize do
                writeln( dataout, RecMagInfo[ForcePos(Pos), xx, yy, pnt] );
              closefile( dataout );
            end
            else if (yy > xx) AND // duplicate crosses were not saved
                 (FSysDefs.Options > TrackingTireOpt) then
            begin
              OutFileName := FDataPath +'\'+ XStr + YStr + Ext;
              assignfile( dataout, OutFileName );
              rewrite( dataout );
              for pnt := 1 to QuarterWindowSize do
                writeln( dataout, RecMagInfo[ForcePos(Pos), xx, yy, pnt], RecPhaInfo[ForcePos(Pos), xx, yy, pnt] );
              closefile( dataout );{}
            end;
          end;
          FPercentComplete := round(loopnum / 70{CalcsNeeded} * 100);
          if FPushAbort then
            break;
          application.processmessages;
        end;
  if FPushAbort then
  begin
    Result := 1;
    exit;
  end;
end;

function TDFMCalcer.OverWriteData : integer;
var
  DlgRes : word;
  XStr, YStr : string;
  xx, yy     : byte;
  CheckForOverwrite : boolean;
  dataout : textfile;
  pnt : integer;
  StartTime,
  EndTime : TDateTime;
  loopnum : integer;
  OutFileName : string;
  Ext : string[5];
  pos : integer;
begin
  Result := 0;
// Check For Overwrite
  CheckForOverwrite := TRUE;
  for xx := 0 to 9 do
    for yy := 0 to 9 do
    begin
      case xx of
        0 {Fx}    : XStr     := 'Fx';
        1 {Fy}    : XStr     := 'Fy';
        2 {Fz}    : XStr     := 'Fz';
        3 {Mx}    : XStr     := 'Mx';
        4 {Mz}    : XStr     := 'Mz';
        5 {Ax}    : XStr     := 'Ax';
        6 {Ay}    : XStr     := 'Ay';
        7 {Az}    : XStr     := 'Az';
        8 {Alphax}: XStr     := 'Alphax';
        9 {Alphaz}: XStr     := 'Alphaz';
      end;
      case yy of
        0 {Fx}    : YStr     := 'Fx';
        1 {Fy}    : YStr     := 'Fy';
        2 {Fz}    : YStr     := 'Fz';
        3 {Mx}    : YStr     := 'Mx';
        4 {Mz}    : YStr     := 'Mz';
        5 {Ax}    : YStr     := 'Ax';
        6 {Ay}    : YStr     := 'Ay';
        7 {Az}    : YStr     := 'Az';
        8 {Alphax}: YStr     := 'Alphax';
        9 {Alphaz}: YStr     := 'Alphaz';
      end;
      if xx = yy then
      begin
        OutFileName := FDataPath +'\'+ XStr + XStr + 'D.txt';
        if CheckForOverwrite and fileexists( OutFileName ) then
        begin
          DlgRes := MessageDlg('File '+ OutFileName + ' already exists!'+#13+#10+'Overwrite it?'+#13+#10+
                               'NOTE:  Choosing [All] will allow overwriting of all subsequent files.',mtWarning,[mbOK,mbAbort,mbAll],0);
          if DlgRes = mrNo then
          begin
            MessageDlg('Please remove needed results from the destination directory.'+#13+#10+
                       'Then start Analysis again.',mtInformation,[mbOK],0);
            Result := 1;
            exit;
          end else
          if DlgRes = mrAll then
            CheckForOverwrite := FALSE;
        end;
        OutFileName := FDataPath +'\'+ XStr + XStr + 'K.txt';
        if CheckForOverwrite and fileexists( OutFileName ) then
        begin
          DlgRes := MessageDlg('File '+ OutFileName + ' already exists!'+#13+#10+'Overwrite it?'+#13+#10+
                               'NOTE:  Choosing [All] will allow overwriting of all subsequent files.',mtWarning,[mbOK,mbAbort,mbAll],0);
          if DlgRes = mrNo then
          begin
            MessageDlg('Please remove needed results from the destination directory.'+#13+#10+
                       'Then start Analysis again.',mtInformation,[mbOK],0);
            Result := 1;
            exit;
          end else
          if DlgRes = mrAll then
            CheckForOverwrite := FALSE;
        end;
      end
      else
      begin
        OutFileName := FDataPath +'\'+ XStr + YStr +'D.txt';
        if CheckForOverwrite and fileexists( OutFileName ) then
        begin
          DlgRes := MessageDlg('File '+ OutFileName + ' already exists!'+#13+#10+'Overwrite it?'+#13+#10+
                               'NOTE:  Choosing [All] will allow overwriting of all subsequent files.',mtWarning,[mbOK,mbAbort,mbAll],0);
          if DlgRes = mrNo then
          begin
            MessageDlg('Please remove needed results from the destination directory.'+#13+#10+
                       'Then start Analysis again.',mtInformation,[mbOK],0);
            Result := 1;
            exit;
          end else
          if DlgRes = mrAll then
            CheckForOverwrite := FALSE;
        end;
        OutFileName := FDataPath + '\'+XStr + YStr +'K.txt';
        if CheckForOverwrite and fileexists( OutFileName ) then
        begin
          DlgRes := MessageDlg('File '+ OutFileName + ' already exists!'+#13+#10+'Overwrite it?'+#13+#10+
                               'NOTE:  Choosing [All] will allow overwriting of all subsequent files.',mtWarning,[mbOK,mbAbort,mbAll],0);
          if DlgRes = mrNo then
          begin
            MessageDlg('Please remove needed results from the destination directory.'+#13+#10+
                       'Then start Analysis again.',mtInformation,[mbOK],0);
            Result := 1;
            exit;
          end else
          if DlgRes = mrAll then
            CheckForOverwrite := FALSE;
        end;
      end;
    end; // checking for overwrite loop

  if FPushAbort then
  begin
    Result := 1;
    exit;
  end;
end;

function TDFMCalcer.Init8192 : integer;
var
  i,
  dlgResult : integer;
  NumBads   : integer;
  BadPosStr : string;
begin
  DFMUsed := TRUE;
  StreamPointer := 1;  // not used in Process8192 procedure
  Result := 0;  // no error
  BadPosStr := '';
  NumBads := 0;
  for i := 1 to DFMItems do
  begin
  // assign the Channel number from Config to the proper DFM Item
    DFMChan[i] := FConfig.DFMPosChanNum[i];
    if DFMChan[i] = 0 then
    begin
      inc( NumBads );
      if i > KistMz then  // do not do DFM if this occurs
        DFMUsed := FALSE;
      if NOT odd(NumBads) then
        BadPosStr := BadPosStr + '  '+ FConfig.DFMPos[i] + #13+#10
      else
        BadPosStr := BadPosStr + FConfig.DFMPos[i];
    end;
  end;
  DFMUsed := FALSE;     // remove later when bugs fixed  {rp 7/9/99}
  if BadPosStr <> '' then
  begin
    if odd(NumBads) then
      BadPosStr := BadPosStr + #13+#10;
    dlgResult := MessageDlg('The following DFMS Positions do not exist'+#13+#10+
                            'in the Transducer Configuration:'+#13+#10+BadPosStr +
                            'DFMS Results may not be as expected.',mtWarning,[mbAbort,mbIgnore],0);
    if dlgResult = mrAbort then
    begin
      Result := 1;
      exit;
    end;
  end;
  if InitMasses <> 0 then
  begin
    DFMUsed := FALSE;
    dlgResult := MessageDlg('A mass diameter parameter is zero.'+#13+#10+'DFMS Results will not be calculated.',mtWarning,[mbAbort,mbIgnore],0);
    if dlgResult = mrAbort then
    begin
      Result := 1;
      exit;
    end;
  end;
end;


//-------------------------------------------------------------------------//
// Call this routine to quick calculate DFMS for 8192 points.  All         //
// channels necessary must be present in the array                         //
//-------------------------------------------------------------------------//
function TDFMCalcer.Process8192( const ChanInt : TChannelBufferIntData; var ChanRes : TChannelBuffer ) : integer;
var
  DFMPos : integer;
begin
  FillOnceRevBuffer( ChanInt, QuickRead );
  if DFMUsed then
    SinCosToBuffer;
  FillDFMBuffers( ChanInt, QuickRead );
  if DFMUsed then
    DFMTimeResultsToBuffer
  else
  begin
    fillchar( Fdfm, sizeof( Fdfm ), #0 );
    fillchar( Mdfm, sizeof( Mdfm ), #0 );
  end;
  for DFMPos := 1 to DFMItems do
    if FConfig.ChannelUsed[ DFMChan[ DFMPos ] ] then
      move( DFMBuffer[ DFMPos ], ChanRes[ DFMChan[DFMPos] ], sizeof( DFMBuffer[1] ));
  move( Fdfm[X], ChanRes[33], sizeof( Fdfm[X] ));
  move( Fdfm[Y], ChanRes[34], sizeof( Fdfm[X] ));
  move( Fdfm[Z], ChanRes[35], sizeof( Fdfm[X] ));
  move( Mdfm[X], ChanRes[36], sizeof( Fdfm[X] ));
  move( Mdfm[Z], ChanRes[37], sizeof( Fdfm[X] ));
end;

//-------------------------------------------------------------------------//
// Call this routine to run the entire DFMS Process on the initial and     //
// subsequent overlaps.                                                    //
// Return Codes : 0 No more data to process                                //
//                1 More data to process                                   //
//-------------------------------------------------------------------------//
function TDFMCalcer.Process : integer;
begin
//     Result := 1;
//     SinCosToBuffer;
//     DFMTimeResultsToBuffer;
//     DFMFreqResultsToBuffer;
//     inc( StreamPointer, 2457 );  // for 30% overlap
//     // check for next set of data
//     for i := 1 to FConfig.MaxAnalogChan do
//       if (StreamPointer * sizeof(DataStoreType)) > ChanData[i].Size) then
//         Result := 0;
end;

function TDFMCalcer.InitPost : integer;
var
  i,
  dlgResult : integer;
  NumBads   : integer;
  BadPosStr : string;
  FileLengthKnown : boolean;
begin
  DFMUsed := TRUE;
  FirstBuffer := TRUE;
  Result := 0;  // no error
  BadPosStr := '';
  NumBads := 0;
  FileLengthKnown := FALSE;
  TestStartPos    := 0;
  Avgs := 0;
  for i := 1 to DFMItems do
  begin
  // assign the Channel number from Config to the proper DFM Item
    DFMChan[i] := FConfig.DFMPosChanNum[i];
    if (DFMChan[i] = 0) then
    begin
      inc( NumBads );
      if i > KistMz then  // do not do DFM if this occurs
        DFMUsed := FALSE;
      if NOT odd(NumBads) then
        BadPosStr := BadPosStr + '  '+ FConfig.DFMPos[i] + #13+#10
      else
        BadPosStr := BadPosStr + FConfig.DFMPos[i];
    end;
  // open file data streams -- File read version
    if fileexists(format(FDataPath+'\Chan%d.bin',[DFMChan[i]])) then
    begin
      ChanData[ DFMChan[i] ] := TFileStream.Create(format(FDataPath+'\Chan%d.bin',[DFMChan[i]]), fmOpenRead or fmShareExclusive);
      if NOT FileLengthKnown then
      begin
        FileLengthKnown := TRUE;
        // now check length of file.  Knowing sample rate you can use the last 200 secs.
        // of the test to be the testing data.  All Channel Data files are the same
        // length, so last file can be checked.
        TestStartPos := trunc(ChanData[ DFMChan[i] ].Size - (FConfig.SampleRate * 1000) * sizeof(DataStoreType) * 200 {seconds in test}) Div 2 {to get to smallint size};
        WindowsInData := round(((FConfig.SampleRate * 1000) * 200) / OverlapSize) - round(WindowSize / OverlapSize) - 1;  // make certain there is 8192 in the last window
      end;
    end
    else
    begin
      if i <= KistMz then
        MessageDlg('The following Kistler Channel data file does not exist:'+#13+#10+
                    format(FDataPath+'\Chan%d.bin',[DFMChan[i]])+#13+#10 +
                   'The '+FConfig.DataDescription[DFMChan[i]]+ ' Channel cannot be converted.',mtError,[mbOK],0)
      else
      begin
        MessageDlg('The following Channel data file does not exist:'+#13+#10+
                  format(FDataPath+'\Chan%d.bin',[DFMChan[i]])+#13+#10+
                FConfig.DataDescription[DFMChan[i]]+#13+#10+
                'DFMS Results cannot be calculated.',mtError,[mbOK],0);
        Result := 1;
        exit;
      end;
    end;
  end;
  if BadPosStr <> '' then
  begin
    if odd(NumBads) then
      BadPosStr := BadPosStr + #13+#10;
    dlgResult := MessageDlg('The following DFMS Positions do not exist'+#13+#10+
                            'Test Data:'+#13+#10+BadPosStr +
                            'DFMS Results cannot be calculated.',mtError,[mbOK],0);
    if dlgResult = mrOK then
    begin
      Result := 1;
      exit;
    end;
  end;
  if InitMasses <> 0 then
  begin
    DFMUsed := FALSE;
    dlgResult := MessageDlg('A mass diameter parameter is zero.'+#13+#10+'DFMS Results cannot be calculated.',mtError,[mbOK],0);
    if dlgResult = mrOK then
    begin
      Result := 1;
      exit;
    end;
  end;
  if OverWriteData <> 0 then
  begin
    Result := 1;
    exit;
  end;
  case FSysDefs.Options of
    TrackingTireOpt : CalcsNeeded := 10;
    ImpedanceOpt    : CalcsNeeded := 55;
    CustomerOpt     : CalcsNeeded := 70;
    EverythingOpt   : CalcsNeeded := 70;
  end;
  StreamPointer := TestStartPos;
end;

//------------------------------------------------------------------------------
// Return Codes:  0 : Ok
//                1 : General Error
//                2 : Encoder Sync Check Error
//                3 : Encoder Problem -- Control Speed and Read Speed do not match
//------------------------------------------------------------------------------
function TDFMCalcer.PostTestProcess( DataPath : string ): integer;
var i : integer;
    DFMPos  : integer;
    win : integer;
    SyncCheckVal : integer;
begin
  Result := 0;
  FirstRev := TRUE;
  FDataPath := DataPath;
  fillchar( ChanDum, sizeof(ChanDum), #0 );
  if InitPost <> 0 then
  begin
    Result := 1;
    exit;
  end;
  FPostProcessRunning := 1;
  for win := 1 to WindowsInData do
  begin
    FillOnceRevBuffer( ChanDum, DiskRead );
    if DFMUsed then
    begin
      SyncCheckVal := SinCosToBuffer;
      if SyncCheckVal <> 0 then
      begin
        Result := SyncCheckVal + 1;
        exit;
      end;
    end;
    FillDFMBuffers( ChanDum, DiskRead );
    if DFMUsed then
    begin
      DFMTimeResultsToBuffer;
      DFMFreqResultsToBuffer;
      DFMCalcResultsToBuffer;
      inc(Avgs);
    end;
    inc( StreamPointer, OverlapSize );
    FPercentComplete := round( win / WindowsInData * 100 );
    if FPushAbort then
      Break;
    application.processmessages;
  end;
  if FPushAbort then
  begin
    Result := 1;
    exit;
  end;
  if SaveCalculationOutputs <> 0 then
    Result := 1;
end;

function TDFMCalcer.GetHanning(index : integer): double;
begin
  if (index >= low(FHan)) and (index <= high(FHan)) then
    result := FHan[index]
  else
    Result := 1;
end;

procedure TDFMCalcer.CreateFHanningWindow;
var
  pnt : integer;
  twopi : double;
begin
  TwoPi := 2 * pi;
  for pnt := 1 to WindowSize do
    FHan[pnt] := 0.5 * (1 - cos(TwoPi * pnt/WindowSize));
end;

initialization
  new( XReal );
  new( XImag );
end.


