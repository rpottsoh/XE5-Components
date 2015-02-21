unit TMSIDataTypes;

interface
uses {stdate,}classes;

const
  MaxPkEntries    = 256;      // compatible with CrashAnalysis in DOS mode
  MinAnalogChan   =   0;
  CMaxAnalogChan  =  799;
  MinABTimer      = 1;
  CMaxABTimer     = 4;
//  Vmax            =  10;

  KistFx     = 1;
  KistFy     = 2;
  KistFz     = 3;
  KistMx     = 4;
  KistMz     = 5;
  Kist1Y     = 6;
  Kist1Z     = 7;
  Kist2X     = 8;
  Kist2Y     = 9;
  Kist3Y     = 10;
  Kist3Z     = 11;
  Kist4X     = 12;
  Kist4Y     = 13;
  Bear1Y     = 14;
  Bear1Z     = 15;
  Bear2X     = 16;
  Bear2Y     = 17;
  Bear3Y     = 18;
  Bear3Z     = 19;
  Bear4X     = 20;
  Bear4Y     = 21;
  Spin1Y     = 22;
  Spin1Z     = 23;
  Spin2X     = 24;
  Spin2Y     = 25;
  Spin3Y     = 26;
  Spin3Z     = 27;
  Spin4X     = 28;
  Spin4Y     = 29;
  OncePerRev = 30;
  Hammer     = 31;

  DFMNames : array[1..5] of string[5] = ('FdfmX',
                                         'FdfmY',
                                         'FdfmZ',
                                         'MdfmX',
                                         'MdfmZ');

  TrackingTireOpt = 0;
  ImpedanceOpt    = 1;
  CustomerOpt     = 2;
  EverythingOpt   = 3;

{-- Conversion Constants --}
       siLoad          : extended =  4.4482216;   { N    /lb.   }
       siLoadKg        : extended =  0.453592368; { kg/lb   }
       siForce         : extended =  4.4482216;   { N    /lb.   }
       siMoment        : extended =  0.1130;     { Nm   /Inch-lbs }
       siMomentftlbNm  : extended =  1.35582;  {ftlbs per Nm}
       FTLBStoKGM      : extended =  0.13814159258; {kgm / ft-lbs}
       siMass          : extended = 28.349523028;   { g    /oz.   }
       siDistance      : extended =  25.4;       { mm   /in.   }
       siDistanceCM    : extended =  2.54;       { cm   /in.   }
       siSpeed         : extended =  1.609344;      { km/h /mph   }
       siPressure      : extended =  6.89475728;      {kPa / PSI    }
       siPressureKGCM2 : extended =  0.07032349;  {kg/cm2 divided by siPressureKGCM2 equals PSI}
       siPressureBAR   : extended =  0.06896552;  {Bar divided by siPressureBAR equals PSI}
       siKilo          : extended =  0.453592368;
       OZtoGram        : extended = 28.349523028;     {1 ounce equals 28.3527 grams}
       MPHtoRPM        : extended = 10.0;
       RPMtoKPH        : extended =  0.1609;
       KGtoN           : extended =  9.81;
       GPMtoI3pSEC     : extended =  3.849999961;     {Gallons/minute --> in^3/sec.}
       BarToPSI        : extended = 14.503773801;   // 1 Bar = 14.503774 PSI
       PSItoBar        : extended =  0.068947573; // 1 PSI = 0.0689... Bar
       GPMtoLPM        : extended =  3.7854118; //Liters/Minute per Gallons/Minute
       CM3pSECtoLPM    : extended = 0.06; // cm^3/sec per Liters/Minute
       IN3pSECtoLPM    : extended = 0.983223854; // in^3/sec per Liters/Minute

       CR_LF = #13+#10;
       _tab = #9;

   TESTNUM        = 0;
   MCONFIG        = 1;
   CNFFilename    = 2;
   OutPath        = 3;
   TireID         = 4;
   Spec           = 5;
   TireSize       = 6;
   DRLProjectNum  = 7;
   PersNum        = 8;
   Engineer       = 9;
   DRLTech        = 10;
   TireMake       = 11;
   Manufacturer   = 12;
   Inflation      = 13;
   RimWidth       = 14;
   Speed          = 15;
   Load           = 16;
   DrumPosition   = 17;
   InflationEU    = 18; // 0==PSI 1==kPa
   RimWidthEU     = 19; // 0==IN 1==CM
   SpeedEU        = 20; // 0==MPH 1==KPH
   RimType        = 21; // 0==Alloy 1==Steel 2==Custom 3==Other
   LoadEU         = 22; // 0==LBS 1==N
   TestType       = 23; //    0==Ford 1==GM 3==Other
   ReqDate        = 24;
   IsTrackingTire = 25; // true=Tracking false==standard
   WConfig        = 26;
   WheelSize      = 27;
   Comment1       = 28;
   Comment2       = 29;
   OutputDir      = 30;
   OutputFile     = 31;
   FullFileName   = 32;
   TWWeight       = 33;
   TWOffset       = 34;
   DashNo         = 35;
   TestTime       = 36;
   TestDate       = 37;

type
    TParametersRec = packed record
                     StringData : array[TESTNUM..MANUFACTURER] of string[50];
                     FloatData  : array[INFLATION..DRUMPOSITION] of single;
                     IntData    : array[INFLATIONEU..TESTTYPE] of integer;
                     DateData   : array[REQDATE..REQDATE] of LongInt;//TStDate;
                     BoolData   : array[ISTRACKINGTIRE..ISTRACKINGTIRE] of boolean;
                     StringData2: array[WConfig..FullFileName] of string[100];
                     FloatData2 : array[TWWeight..TWOffset] of single;
                     IntData2   : array[DashNo..DashNo] of integer;
                     TimeData   : array[TestTime..TestTime] of LongInt;//TStTime;
                     DateData2  : array[TESTDATE..TESTDATE] of LongInt;//TStDate;
    end; // TParametersRec
   TForceTypes = (FxForce, FyForce, FzForce, MxMoment, MzMoment);
   TMassRec = packed record
                   Mass,
                   MInertia,
                   Diameter,
                   CGOffset : single;
                   filler   : array[0..49] of byte;
   end; // TMassRec

   TMassParameters = packed record
                     NumberOfMasses : byte;
                     Masses  : array[1..3] of TMassRec; // 1=Kistler 2=Bearing 3=Spindle
                     Radius  : array[1..3] of single;
                     CGAttachFace : array[1..3] of single;  // 3=Spindle;
                     filler  : array[0..187] of byte;
   end; // TMassParameters

   TWheelParameters = packed record
                     Mass : single;
                     MInertia : single;
                     CGAttachFace : single;  // 3=Spindle;
                     filler  : array[0..199] of byte;
   end;

   TSystemDefaults = packed record
                     ControlVoltageCal  : Single;
                     BeginSpeed         : longint;
                     EndSpeed           : longint;
                     SampleRate         : byte;   // 0==6.25 1==10.0 2==12.5
                     TrigLevel          : double; // Volts
                     TrigResetLevel     : double; // Volts
                     Options            : byte;   // 0==Tracking Tire
                                                  // 1==Impedance Study
                                                  // 2==Customer
                                                  // 3==Everything
                     MaxDataSampsDiff   : longint;
                     MaxSpeedTol        : double;
                     TrigOffset         : double;
                     LateralMode        : array[1..4] of byte;  // 0 = Load Control
                                                                // 1 = Slip Control
                     ZeroSlipLatLoadMove : array[1..4] of integer;
                     ZeroSlipStopOff     : array[1..4] of integer;
                     MultiOptionMode    : boolean;
                     OutFileComment1    : string[80];
                     OutFileComment2    : string[80];
                     StoreRawOption     : boolean;
                     OutFileComment3    : string[80];
                     SisHiLimit,
                     SisLoLimit         : double;
                     SpeedOffset        : single;
                     filler             : array[0..701] of byte;
   end; // TSystemDefaults;

  TBufferFFTType = array[0..4096] of double;
  TBufferFloatType = array[0..8191] of double;
  TBufferIntType = array[0..8191] of smallint;

  TChannelBuffer = array[1..37] of TBufferFloatType;
  TChannelBufferIntData = array[1..32] of TBufferIntType;

   TIDAndElement = record
                     id : LongInt;
                     el : byte;
                   end;
   TIDAndElementArrayPtr = ^TIDAndElementArray;
   TIDAndElementArray = array[0..0] of TIDAndElement;

   tSensorHist = packed record
                   sensitivity : real;
                   caldate     : LongInt;
                 end;
   tSensorHistArray = array[1..20] of tSensorHist;
   XdcrRecType = packed RECORD
                  RefNum      : LongInt;    { RefNum = ID * 10 + Element }
                  Sensitivity : real;
                  LastCalDate : LongInt;
                  BridgeRes   : real;
                  Excitation  : real;
                  Range       : real;
                  OutputAtFS  : real;
                  XType       : String[2];
                  Units       : String[3];
                  SerialNo    : String[12];
                  ModelNo     : String[15];
                  NextCalDate : LongInt;
                  calrun      : boolean;
                  ExtraBool   : Boolean;
                  ExtraWord   : word;
                  CalPlusLev  : real;
                  CalMinusLev : real;
                  NumCalRuns  : longint;
                  CalGain     : real;
                  calhistcount: smallint;
                  sensorhist  : tSensorHistArray;
                  Version     : string[9];
                  Offset      : double;
                  Axis        : Integer;
                  Extras      : string[88];
                end;

{   oldXdcrRecType = RECORD  // from DTL Source Code
                  RefNum      : LongInt;    // RefNum = ID * 10 + Element
                  Sensitivity : real;
                  LastCalDate : Longint;
                  BridgeRes   : real;
                  Excitation  : real;
                  MaxFullScale: real;
                  OutputAtFS  : real;
                  XType       : String[2];
                  Units       : String[3];
                  SerialNo    : String[12];
                  ModelNo     : String[15];
                  NextCalDate : Longint;
                  CalRun      : boolean;
                  ExtraBool   : boolean;
                  CalGain     : word;
                  CalPlusLev  : real;
                  CalMinusLev : real;
                  NumCalRuns  : longint;
                  Extras      : string[46];
                END;{}

  tTransducerArrayPtr = ^tTransducerArray;
  tTransducerArray = array[0..0] of XdcrRecType;

  ABTrec  = packed record // Kyowa DIS 3500 Airbag Timer Setup Record
              Active         : boolean;
              CurrentLevel   : double;  // 0.1 .. 5.0 Amps
              FireDelay      : double;  // 0.0001 .. 99.0 Seconds
              MeasureCurrent : boolean;
              CurrentPolarity: string[1];
              CurrLowPassFilt: boolean;
              MeasureVoltage : boolean;
              VoltagePolarity: string[1];
              VoltLowPassFilt: boolean;
              filler         : array[0..2047] of byte;
  end; //ABTrec

  ChnABTArray   = ARRAY[MinABTimer..CMaxABTimer] OF ABTRec;
  ChnABTArrPtr  = ^ChnABTArray;
  ABTfileType = FILE OF ABTrec;

  {$ifdef UseOldCNFrec}
  CNFrec  = packed RECORD     {199 bytes}         { used for chnl config 'format' files }
              ChanNum  : BYTE;
              SENTYP   : String[2];
              DataDesc : String[16];
              SenID    : String[7];
              SENLOC   : String[2];
              SENATT   : String[4];
              AXIS     : String[2];
              ReqScale : real;
              Spare    : WORD;
              Polarity : string[1];
              CalcSensi: real;
              ReptFilt : String[4];
              Gain     : real;
              Excitation : real;
              OutPutAtFS,
              Range : real;
              MAXExcitation : real;
              HardWare    : string[2];
              CCSlotNum : string[3];
              ZeroOfs   : single;
              Units       : String[3];
              BoxNum    : byte;
              BoxChanNum: byte;
              IntChanNum   : integer;
              ActualRange : double;
              MicroStrain : word;
              SerialNo    : String[12];
              Filler      : string[20];  //SenLoc in New Version of CNFrec
              Offset      : double;
          // Added for ISO/DTR 13499 - Annex B ; Hyundai OOP Test 1/14/03, rp
              ISO13499TestObject  : string[1];
              ISO13499Position    : string[1];
              ISO13499MainLocation : string[4];
              ISO13499FineLocation1 : string[2];
              ISO13499FineLocation2 : string[2];
              ISO13499FineLocation3 : string[2];
              ISO13499Direction     : string[1];
              ISO13499FilterClass   : string[1];
              ChannelUsed           : boolean;
              PostTestShuntCalStat  : boolean; // true means passed, false means failed
           // Added for Magna 207; 7/3/2003, rp
              RecordVideo           : byte; //0 = no, 1 = yes
           // Added for Kyowa DIS-3500 3/16/04 rp
              AutoBalance   : boolean;
              LowPassFilter : boolean;
           // ---------
              FilePassedTPSCheck : boolean;
              extra   : string[6];
            END; { RECORD }
  {$else}
  CNFrec  = packed RECORD   {200 bytes}           { used for chnl config 'format' files }
              ChanNum  : BYTE;
              SENTYP   : String[2]; //Also known as Physical Dimension for ISO/DTR 13499 - Annex B
              DataDesc : String[16];
              SenID    : String[7];
              OldSENLOC   : String[2];
              SENATT   : String[4];
              AXIS     : String[2];
              ReqScale : real;
              Spare    : WORD;
              Polarity : string[1];
              CalcSensi: real;
              ReptFilt : String[4];
              Gain     : real;
              Excitation : real;
              OutPutAtFS,
              Range : real;
              MAXExcitation : real;
              HardWare    : string[2];
              CCSlotNum : string[3];
              ZeroOfs   : single;
              Units       : String[3];
              BoxNum    : byte;
              BoxChanNum: byte;
              IntChanNum   : integer;
              ActualRange : double;
              MicroStrain : word;
              SerialNo    : String[12];
              SenLoc      : string[20];
              Offset      : double;
          // Added for ISO/DTR 13499 - Annex B ; Hyundai OOP Test 1/14/03, rp
              ISO13499TestObject  : string[1];
              ISO13499Position    : string[1];
              ISO13499MainLocation : string[4];
              ISO13499FineLocation1 : string[2];
              ISO13499FineLocation2 : string[2];
              ISO13499FineLocation3 : string[2];
              ISO13499Direction     : string[1];
              ISO13499FilterClass   : string[1];
              ChannelUsed           : boolean;
              PostTestShuntCalStat  : boolean; // true means passed, false means failed
           // Added for Magna 207; 7/3/2003, rp
              RecordVideo           : byte; //0 = no, 1 = yes
           // Added for Kyowa DIS-3500 3/16/04 rp
              AutoBalance   : boolean;
              LowPassFilter : boolean;
           // ---------
              FilePassedTPSCheck : boolean;
              extra   : string[7];
            END; { RECORD }
  {$endif}
  CNFfileType = FILE OF CNFrec;

  ChnCNFArray   = ARRAY[MinAnalogChan..CMaxAnalogChan] OF CNFRec;
  ChnCNFArrPtr  = ^ChnCNFArray;

//   tDataSource = (EMEData,MicroStarData,OtherData);
//  { this is the record that analysis.exe uses }
//   EMETestCFGrec  = packed RECORD                  { used for unique test .CFG files }
//                   ChanNum    : BYTE;
//                   SENTYP     : String[40];  { qualifier }
//                   SenTyp2    : String[2];
//                   AXIS       : String[5];
//                   Units      : String[10];
//                   SampRate   : real;
//                   DataDesc   : string[16];
//                   DataSource : tDataSource;
//                   Extras     : string[62];
//                 END; { RECORD }

  procedure CreateArray( var TheArray : tTransducerArrayPtr;
                         var TheIDELArray : TIDAndElementArrayPtr;
                             NumElements : LongInt );
  procedure FreeArray( var TheArray : tTransducerArrayPtr;
                       var TheIDELArray : TIDAndElementArrayPtr;
                           NumElements : LongInt );
  procedure ReSizeArray( var TheArray : tTransducerArrayPtr;
                         var TheIDELArray : TIDAndElementArrayPtr;
                             OldNumElements : LongInt;
                             NewNumElements : LongInt );

implementation

procedure CreateArray( var TheArray : tTransducerArrayPtr;
                       var TheIDELArray : TIDAndElementArrayPtr;
                           NumElements : LongInt );
begin
  GetMem(TheArray, sizeof(XdcrRecType) * NumElements);
  fillchar(TheArray^, sizeof(XdcrRecType) * NumElements, #0);
  GetMem(TheIDELArray, sizeof(TIDAndElement) * NumElements);
  fillchar(TheArray^, sizeof(TIDAndElement) * NumElements, #0);
end;

procedure FreeArray( var TheArray : tTransducerArrayPtr;
                     var TheIDELArray : TIDAndElementArrayPtr;
                         NumElements : LongInt );
begin
  FreeMem(TheArray, Sizeof(XdcrRecType) * NumElements);
  FreeMem(TheIDELArray, Sizeof(TIDAndElement) * NumElements);
end;

procedure ReSizeArray( var TheArray : tTransducerArrayPtr;
                       var TheIDELArray : TIDAndElementArrayPtr;
                           OldNumElements : LongInt;
                           NewNumElements : LongInt );
var TheNewArray : tTransducerArrayPtr;
    TheNewIDELArray : TIDAndElementArrayPtr;
begin
  getmem(TheNewArray, Sizeof(XdcrRecType) * NewNumElements);
  getmem(TheNewIDELArray, Sizeof(TIDAndElement) * NewNumElements);
  if NewNumElements > OldNumElements then
  begin
    move(TheArray^, TheNewArray^, OldNumElements * Sizeof(XdcrRecType));
    move(TheIDELArray^, TheNewIDELArray^, OldNumElements * Sizeof(TIDAndElement));
  end
  else
  begin
    move(TheArray^, TheNewArray^, NewNumElements * Sizeof(XdcrRecType));
    move(TheIDELArray^, TheNewIDELArray^, NewNumElements * Sizeof(TIDAndElement));
  end;
  freemem(TheArray, Sizeof(XdcrRecType) * OldNumElements);
  freemem(TheIDELArray, Sizeof(TIDAndElement) * OldNumElements);
  TheArray := TheNewArray;
  TheIDELArray := TheNewIDELArray;
end;

end.
