{==========================================================================}
{                                                                          }
{  File Name     : CBWDLLTMSI.PAS                                          }
{                                                                          }
{  Programmer(s) : Mark Herman                                             }
{                  Matt Laun                                               }
{                  Ryan Potts                                              }
{  Original Ver  : 11/07/97                                                }
{                                                                          }
{  Description : This is a driver library for the Computerboards DIO and   }
{                CTR series cards.  It uses WinRT driver to make           }
{                non-supported Delphi port calls.                          }
{                This DLL was built under Delphi 3.01                      }
{                                                                          }
{--------------------------------------------------------------------------}
{                                                                          }
{   (c) Copyright 1997           Test Measurement Systems, Inc.            }
{         by TMSI              202 Montrose West Ave.  Suite 140           }
{                                      Akron, OH  44321                    }
{   ALL RIGHTS RESERVED                 (330) 668-2010                     }
{                                                                          }
{--------------------------------------------------------------------------}

UNIT cbwdlltmsi;

INTERFACE

{_DEFINE DLLBUILD}

const
  DIO_SERIES      =    $400;
  CTR_SERIES      =    $800;

  CIO_DIO24       =   (DIO_SERIES + 1);
  CIO_DIO24H      =   (DIO_SERIES + 2);
  CIO_DIO48       =   (DIO_SERIES + 3);
  CIO_DIO96       =   (DIO_SERIES + 4);
  CIO_DIO192      =   (DIO_SERIES + 5);
  CIO_CTR05       =   (CTR_SERIES + 1);
  CIO_CTR10       =   (CTR_SERIES + 2);

{ Current Revision Number}
  CURRENTREVNUM = 3.6;

{ System error code }
  NOERRORS           = 0;    { No error occurred }
  BADBOARD           = 1;    { Invalid board number specified }
  DEADDIGITALDEV     = 2;    { Digital I/O is not responding }
  DEADCOUNTERDEV     = 3;    { Counter is not responding }
  DEADDADEV          = 4;    { D/A is not responding }
  DEADADDEV          = 5;    { A/D is not responding }
  NOTDIGITALCONF     = 6;    { Specified board does not have digital I/O }
  NOTCOUNTERCONF     = 7;    { Specified board does not have a counter }
  NOTDACONF          = 8;    { Specified board is does not have D/A }
  NOTADCONF          = 9;    { Specified board does not have A/D }
  NOTMUXCONF         = 10;   { Specified board does not have thermocouple inputs }
  BADPORTNUM         = 11;   { Invalid port number specified }
  BADCOUNTERDEVNUM   = 12;   { Invalid counter device }
  BADDADEVNUM        = 13;   { Invalid D/A device }
  BADSAMPLEMODE      = 14;   { Inavlid sampling mode option specified }
  BADINT             = 15;   { Board configured for invalid interrupt level }
  BADADCHAN          = 16;   { Invalid A/D channel Specified }
  BADCOUNT           = 17;   { Invalid count specified }
  BADCNTRCONFIG      = 18;   { invalid counter configuration specified }
  BADDAVAL           = 19;   { Invalid D/A output value specified }
  BADDACHAN          = 20;   { Invalid D/A channel specified }
  ALREADYACTIVE      = 22;   { A background process is already in progress }
  BADRATE            = 24;   { Inavlid sampling rate specified }
  COMPATMODE         = 25;   { Board switches set for "compatible" mode }
  TRIGSTATE          = 26;   { Incorrect intial trigger state D0 must=TTL low) }
  ADSTATUSHUNG       = 27;   { A/D is not responding }
  TOOFEW             = 28;   { Too few samples before trigger occurred }
  OVERRUN            = 29;   { Data lost due to overrun, rate too high }
  BADRANGE           = 30;   { Invalid range specified }
  NOPROGGAIN         = 31;   { Board does not have programmable gain }
  BADFILENAME        = 32;   { Not a legal DOS filename }
  DISKISFULL         = 33;   { Couldn't complete, disk is full }
  COMPATWARN         = 34;   { Board is in compatible mode, so DMA will be used }
  BADPOINTER         = 35;   { Invalid pointer (NULL) }
  RATEWARNING        = 37;   { Rate may be too high for interrupt I/O }
  CONVERTDMA         = 38;   { CONVERTDATA cannot be used with DMA I/O }
  DTCONNECTERR       = 39;   { Board doesn't have DT Connect }
  FORECONTINUOUS     = 40;   { CONTINUOUS can only be used with BACKGROUND }
  BADBOARDTYPE       = 41;   { This function can not be used with this board }
  WRONGDIGCONFIG     = 42;   { Digital I/O is configured incorrectly }
  NOTCONFIGURABLE    = 43;   { Digital port is not configurable }
  BADPORTCONFIG      = 44;   { Invalid port configuration specified }
  BADFIRSTPOINT      = 45;   { First point argument is not valid }
  ENDOFFILE          = 46;   { Attempted to read past end of file }
  NOT8254CTR         = 47;   { This board does not have an 8254 counter }
  NOT9513CTR         = 48;   { This board does not have a 9523 counter }
  BADTRIGTYPE        = 49;   { Invalid trigger type }
  BADTRIGVALUE       = 50;   { Invalid trigger value }
  BADOPTION          = 52;   { Invalid option sepcified for this function }
  BADPRETRIGCOUNT    = 53;   { Invalid pre-trigger count sepcified }
  BADDIVIDER         = 55;   { Invalid fout divider value }
  BADSOURCE          = 56;   { Invalid source value  }
  BADCOMPARE         = 57;   { Invalid compare value }
  BADTIMEOFDAY       = 58;   { Invalid time of day value }
  BADGATEINTERVAL    = 59;   { Invalid gate interval value }
  BADGATECNTRL       = 60;   { Invalid gate control value }
  BADCOUNTEREDGE     = 61;   { Invalid counter edge value }
  BADSPCLGATE        = 62;   { Invalid special gate value }
  BADRELOAD          = 63;   { Invalid reload value }
  BADRECYCLEFLAG     = 64;   { Invalid recycle flag value }
  BADBCDFLAG         = 65;   { Invalid BCD flag value }
  BADDIRECTION       = 66;   { Invalid count direction value }
  BADOUTCONTROL      = 67;   { Invalid output control value }
  BADBITNUMBER       = 68;   { Invalid bit number }
  NONEENABLED        = 69;   { None of the counter channels are enabled }
  BADCTRCONTROL      = 70;   { Element of control array not ENABLED/DISABLED }
  BADMUXCHAN         = 71;   { Invalid MUX channel }
  WRONGADRANGE       = 72;   { Wrong A/D range selected for cbtherm }
  OUTOFRANGE         = 73;   { Temperature input is out of range }
  BADTEMPSCALE       = 74;   { Invalid temperate scale }
  BADERRCODE         = 75;   { Invalid error code specified }
  NOQUEUE            = 76;   { Specified board does not have chan/gain queue}
  CONTINUOUSCOUNT    = 77;   { CONTINUOUS option can't be used with this count value }
  UNDERRUN           = 78;   { D/A FIFO hit empty while doing output }
  BADMEMMODE         = 79;   { Invalid memory mode specified }
  FREQOVERRUN        = 80;   { Measured freq to high for gating interval }
  NOCJCCHAN          = 81;   { Board does not have CJC chan configured }
  BADCHIPNUM         = 82;   { Invalid chip number used with cbC9513Init() }
  DIGNOTENABLED      = 83;   { Digital I/O on board is not enabled }
  CONVERT16BITS      = 84;   { Convert option not allowed with 16 bit A/D }
  NOMEMBOARD         = 85;   { EXTMEMORY option requires a memory board }
  DTACTIVE           = 86;   { Memory I/O while DT was active }
  NOTMEMCONF         = 87;   { Specified board is not a memory board }
  ODDCHAN            = 88;   { First chan in queue can not be odd }
  CTRNOINIT          = 89;   { Counter was not initialized }
  NOT8536CTR         = 90;   { Specified counter is not an 8536 }
  FREERUNNING        = 91;   { A/D is not timed. Running at fastest possible speed }
  INTERRUPTED        = 92;   { Operation was interrupted with CTRL-C key }
  NOSELECTORS        = 93;   { No selectors could be allocated }
  NOBURSTMODE        = 94;   { Burst mode is not supported on this board }
  NOTWINDOWSFUNC     = 95;   { This function not available in Windows lib }
  NOTSIMULCONF       = 96;   { Board not configured for simultaneous option }
  EVENODDMISMATCH    = 97;   { Even channel in odd slot in the queue }
  M1RATEWARNING      = 98;   { DAS16/M1 sample rate too fast for count }
  NOTRS485           = 99;   { Specified board is not a COM-485 }
  NOTDOSFUNC         = 100;  { This function not avaliable in DOS }
  RANGEMISMATCH      = 101;  { Unipolar and Bipolar can not be used together in A/D que }
  CLOCKTOOSLOW       = 102;  { Sample rate too fast for clock jumper setting }
  BADCALFACTORS      = 103;  { Cal factors were out of expected range of values }
  BADCONFIGTYPE      = 104;  { Invaid configuration type information requested }
  BADCONFIGITEM      = 105;  { Invalid configuration item specified }
  NOPCMCIABOARD      = 106;  { Can't acces PCMCIA board }
  NOBACKGROUND       = 107;  { Board does not support background I/O }
  STRINGTOOSHORT     = 108;  { String argument is not long enough }
  CONVERTEXTMEM      = 109;  { CONVERTDATA not allowed with EXTMEM }
  BADEUADD              = 110;   { e_ToEngUnits addition error }
  DAS16JRRATEWARNING    = 111;   { use 10 MHz clock for rates > 125KHz }
  DAS08TOOLOWRATE       = 112;   { DAS08 rate set too low for AInScan warning }
  MEMBOARDPROGERROR     = 113;   { Program error getting memory board source }
  AMBIGSENSORONGP       = 114;   { more than one sensor type defined for EXP-GP }
  NOSENSORTYPEONGP      = 115;   { no sensor type defined for EXP-GP }
  NOCONVERSIONNEEDED    = 116;   { 12 bit board without chan tags - converted in ISR }
  NOEXTCONTINUOUS       = 117;   { External memory cannot be used in CONTINUOUS mode }
  BADPCMSLOTREF         = 118;   { Bad PCM Card slot reference }
  AMBIGPCMSLOTREF       = 119;   { Ambiguous PCM Card slot reference }
  INVALIDPRETRIGCONVERT = 120;   { cbAConvertPretrigData was called after failure in cbAPretrig }
  CSSCALLFAILURE        = 121;   { error return from C&SS }
  BADSENSORTYPE         = 129;   { Bad sensor type selected in Instacal }
  NO_PCM_CHIP_ADDR      = 130;   { Can't find PCM chip addr }

  INTERNALERR        = 200;  { Internal library error  }

{ Windows error codes}
  CANTLOCKDMABUF = 301;
  DMAINUSE = 302;
  BADMEMHANDLE = 303;
  NOENHANCEDMODE = 304;
  NOVDDINSTALLED = 305;
  NOWINDOWSMEMORY = 306;
  OUTOFDOSMEMORY = 307;

{ These are the commonly occurring remapped DOS error codes }
  DOSBADFUNC         = 501;
  DOSFILENOTFOUND    = 502;
  DOSPATHNOTFOUND    = 503;
  DOSNOHANDLES       = 504;
  DOSACCESSDENIED    = 505;
  DOSINVALIDHANDLE   = 506;
  DOSNOMEMORY        = 507;
  DOSBADDRIVE        = 515;
  DOSTOOMANYFILES    = 518;
  DOSWRITEPROTECT    = 519;
  DOSDRIVENOTREADY   = 521;
  DOSSEEKERROR       = 525;
  DOSWRITEFAULT      = 529;
  DOSREADFAULT       = 530;
  DOSGENERALFAULT    = 531;

  WIN_UNK_INT            = 607;
  WIN_CANNOT_SET_INT     = 608;
  WIN_CANNOT_ENABLE_INT  = 609;
  WIN_CANNOT_RESET_INT   = 610;
  WIN_CANNOT_DISABLE_INT = 611;


  NOTUSED          = -1;

{ Maximum length of error string}
  ERRSTRLEN = 80;

{ Maximum length of board name string}
  BOARDNAMELEN = 25;


{ Status values }
  IDLE             = 0;
  RUNNING          = 1;

{ Option Flags }
  FOREGROUND       = $0000;    { Run in foreground, don't return till done }
  BACKGROUND       = $0001;    { Run in background, return immediately }

  SINGLEEXEC       = $0000;    { One execution }
  CONTINUOUS       = $0002;    { Run continuously until cbstop() called }

  TIMED            = $0000;    { Time conversions with internal clock }
  EXTCLOCK         = $0004;    { Time conversions with external clock }

  NOCONVERTDATA    = $0000;    { Return converted data }
  CONVERTDATA      = $0008;    { Return raw A/D data }

  NODTCONNECT      = $0000;    { Disable DT Connect }
  DTCONNECT        = $0010;    { Enable DT Connect }

  DEFAULTIO        = $0000;    { Use whatever makes sense for board }
  SINGLEIO         = $0020;    { Interrupt per A/D conversion }
  DMAIO            = $0040;    { DMA transfer }
  BLOCKIO          = $0060;    { Interrupt per block of conversions }

  BYTEXFER         = $0000;    { Digital IN/OUT a byte at a time }
  WORDXFER         = $0100;    { Digital IN/OUT a word at a time }

  INDIVIDUAL       = $0000;    { Individual D/A output }
  SIMULTANEOUS     = $0200;    { Simultaneous D/A output }

  FILTER           = $0000;    { Filter the input signal }
  NOFILTER         = $0400;    { Disable input filter }

  NORMMEMORY       = $0000;    { Return data to data array }
  EXTMEMORY        = $0800;    { Send data to memory board via DT-Connect }

  BURSTMODE        = $1000;    { Enable burst mode }

  NOTODINTS        = $2000;    { Disable time of day Interrupts }

  EXTTRIGGER       = $4000;    { A/D is triggered externally }

  NOCALIBRATEDATA  = $8000;    { Return uncalibrated PCM data }
  CALIBRATEDATA    = $0000;    { Return calibrated PCM A/D data }

  ENABLED          = 1;
  DISABLED         = 0;


{ types of error reporting }
  DONTPRINT        = 0;
  PRINTWARNINGS    = 1;
  PRINTFATAL       = 2;
  PRINTALL         = 3;

{ types of error handling }
  DONTSTOP         = 0;
  STOPFATAL        = 1;
  STOPALL          = 2;

{ Types of digital input ports }
  DIGITALOUT       = 1;
  DIGITALIN        = 2;

{ Types of DT Modes for cbMemSetDTMode() }
  DTIN             = 0;
  DTOUT            = 2;

  FROMHERE        = -1;       { Read/Write from current poistion }
  GETFIRST        = -2;       { Get first item in list }
  GETNEXT         = -3;       { Get next item in list }


{ Temperature scales }
  CELSIUS          = 0;
  FAHRENHEIT       = 1;
  KELVIN           = 2;


{ Types of digital I/O Ports }
  AUXPORT          = 1;
  FIRSTPORTA       = 10;
  FIRSTPORTB       = 11;
  FIRSTPORTCL      = 12;
  FIRSTPORTCH      = 13;
  SECONDPORTA      = 14;
  SECONDPORTB      = 15;
  SECONDPORTCL     = 16;
  SECONDPORTCH     = 17;
  THIRDPORTA       = 18;
  THIRDPORTB       = 19;
  THIRDPORTCL      = 20;
  THIRDPORTCH      = 21;
  FOURTHPORTA      = 22;
  FOURTHPORTB      = 23;
  FOURTHPORTCL     = 24;
  FOURTHPORTCH     = 25;
  FIFTHPORTA       = 26;
  FIFTHPORTB       = 27;
  FIFTHPORTCL      = 28;
  FIFTHPORTCH      = 29;
  SIXTHPORTA       = 30;
  SIXTHPORTB       = 31;
  SIXTHPORTCL      = 32;
  SIXTHPORTCH      = 33;
  SEVENTHPORTA     = 34;
  SEVENTHPORTB     = 35;
  SEVENTHPORTCL    = 36;
  SEVENTHPORTCH    = 37;
  EIGHTHPORTA      = 38;
  EIGHTHPORTB      = 39;
  EIGHTHPORTCL     = 40;
  EIGHTHPORTCH     = 41;


{ Selectable A/D Ranges codes }
  BIP10VOLTS       = 1;               { -10 to +10 Volts }
  BIP5VOLTS        = 0;               { -5 to +5 Volts }
  BIP2PT5VOLTS     = 2;               { -2.5 to +2.5 Volts }
  BIP1PT25VOLTS    = 3;               { -1.25 to +1.25 Volts }
  BIP1VOLTS        = 4;               { -1 to +1 Volts }
  BIPPT625VOLTS    = 5;               { -.625 to +.625 Volts }
  BIPPT5VOLTS      = 6;               { -.5 to +.5 Volts }
  BIPPT1VOLTS      = 7;               { -.1 to +.1 Volts }
  BIPPT05VOLTS     = 8;               { -.05 to +.05 Volts }
  BIPPT01VOLTS     = 9;               { -.01 to +.01 Volts }
  BIPPT005VOLTS    = 10;              { -.005 to +.005 Volts }
  BIP1PT67VOLTS    = 11;              { -.1.67 to + 1.67 Volts }

  UNI10VOLTS       = 100;             { 0 to 10 Volts }
  UNI5VOLTS        = 101;             { 0 to 5 Volts }
  UNI2PT5VOLTS     = 102;             { 0 to 2.5 Volts }
  UNI2VOLTS        = 103;             { 0 to 2 Volts }
  UNI1PT25VOLTS    = 104;             { 0 to 1.25 Volts }
  UNI1VOLTS        = 105;             { 0 to 1 Volts }
  UNIPT1VOLTS      = 106;             { 0 to .1 Volts }
  UNIPT01VOLTS     = 107;             { 0 to .01 Volts }
  UNIPT02VOLTS     = 108;             { 0 to .02 Volts }
  UNI1PT67VOLTS    = 109;             { 0 to 1.67 Volts }

  MA4TO20          = 200;             { 4 to 20 ma }
  MA2TO10          = 201;             { 2 to 10 ma }
  MA1TO5           = 202;             { 1 to 5 ma }
  MAPT5TO2PT5      = 203;             { .5 to 2.5 ma }


{ Types of D/A    }
  ADDA1     = 0;
  ADDA2     = 1;

{ 8536 counter output 1 control }
  NOTLINKED           = 0;
  GATECTR2            = 1;
  TRIGCTR2            = 2;
  INCTR2              = 3;

{ Types of 8254 Counter configurations }
  HIGHONLASTCOUNT     = 0;
  ONESHOT             = 1;
  RATEGENERATOR       = 2;
  SQUAREWAVE          = 3;
  SOFTWARESTROBE      = 4;
  HARDWARESTROBE      = 5;

{ Where to reload from for 9513 counters }
  LOADREG         = 0;
  LOADANDHOLDREG  = 1;

{ Counter recycle modes }
  ONETIME         = 0;
  RECYCLE         = 1;

{ Direction of counting for 9513 counters }
  COUNTDOWN       = 0;
  COUNTUP         = 1;

{ Types of count detection for 9513 counters }
  POSITIVEEDGE    = 0;
  NEGATIVEEDGE    = 1;

{ Counter output control }
  ALWAYSLOW       = 0;    { 9513 }
  HIGHPULSEONTC   = 1;    { 9513 and 8536 }
  TOGGLEONTC      = 2;    { 9513 and 8536 }
  DISCONNECTED    = 4;    { 9513 }
  LOWPULSEONTC    = 5;    { 9513 }
  HIGHUNTILTC     = 6;    { 8536 }

{ Counter input sources }
  TCPREVCTR       = 0;
  CTRINPUT1       = 1;
  CTRINPUT2       = 2;
  CTRINPUT3       = 3;
  CTRINPUT4       = 4;
  CTRINPUT5       = 5;
  GATE1           = 6;
  GATE2           = 7;
  GATE3           = 8;
  GATE4           = 9;
  GATE5           = 10;
  FREQ1           = 11;
  FREQ2           = 12;
  FREQ3           = 13;
  FREQ4           = 14;
  FREQ5           = 15;
  CTRINPUT6       = 101;
  CTRINPUT7       = 102;
  CTRINPUT8       = 103;
  CTRINPUT9       = 104;
  CTRINPUT10      = 105;
  GATE6           = 106;
  GATE7           = 107;
  GATE8           = 108;
  GATE9           = 109;
  GATE10          = 110;
  FREQ6           = 111;
  FREQ7           = 112;
  FREQ8           = 113;
  FREQ9           = 114;
  FREQ10          = 115;
  CTRINPUT11       = 201;
  CTRINPUT12       = 202;
  CTRINPUT13       = 203;
  CTRINPUT14       = 204;
  CTRINPUT15       = 205;
  GATE11           = 206;
  GATE12           = 207;
  GATE13           = 208;
  GATE14           = 209;
  GATE15           = 210;
  FREQ11           = 211;
  FREQ12           = 212;
  FREQ13           = 213;
  FREQ14           = 214;
  FREQ15           = 215;
  CTRINPUT16       = 301;
  CTRINPUT17       = 302;
  CTRINPUT18       = 303;
  CTRINPUT19       = 304;
  CTRINPUT20       = 305;
  GATE16           = 306;
  GATE17           = 307;
  GATE18           = 308;
  GATE19           = 309;
  GATE20           = 310;
  FREQ16           = 311;
  FREQ17           = 312;
  FREQ18           = 313;
  FREQ19           = 314;
  FREQ20           = 315;

{ Counter registers }
  LOADREG1        = 1;
  LOADREG2        = 2;
  LOADREG3        = 3;
  LOADREG4        = 4;
  LOADREG5        = 5;
  LOADREG6        = 6;
  LOADREG7        = 7;
  LOADREG8        = 8;
  LOADREG9        = 9;
  LOADREG10       = 10;
  LOADREG11       = 11;
  LOADREG12       = 12;
  LOADREG13       = 13;
  LOADREG14       = 14;
  LOADREG15       = 15;
  LOADREG16       = 16;
  LOADREG17       = 17;
  LOADREG18       = 18;
  LOADREG19       = 19;
  LOADREG20       = 20;
  HOLDREG1        = 101;
  HOLDREG2        = 102;
  HOLDREG3        = 103;
  HOLDREG4        = 104;
  HOLDREG5        = 105;
  HOLDREG6        = 106;
  HOLDREG7        = 107;
  HOLDREG8        = 108;
  HOLDREG9        = 109;
  HOLDREG10       = 110;
  HOLDREG11       = 111;
  HOLDREG12       = 112;
  HOLDREG13       = 113;
  HOLDREG14       = 114;
  HOLDREG15       = 115;
  HOLDREG16       = 116;
  HOLDREG17       = 117;
  HOLDREG18       = 118;
  HOLDREG19       = 119;
  HOLDREG20       = 120;

  ALARM1CHIP1     = 201;
  ALARM2CHIP1     = 202;
  ALARM1CHIP2     = 301;
  ALARM2CHIP2     = 302;
  ALARM1CHIP3     = 401;
  ALARM2CHIP3     = 402;
  ALARM1CHIP4     = 501;
  ALARM2CHIP4     = 502;

{  Counter Gate Control }
  NOGATE         = 0;
  AHLTCPREVCTR    = 1;
  AHLNEXTGATE     = 2;
  AHLPREVGATE     = 3;
  AHLGATE         = 4;
  ALLGATE         = 5;
  AHEGATE         = 6;
  ALEGATE         = 7;


{ Types of triggers }
  TRIGABOVE           = 0;
  TRIGBELOW           = 1;

{ Types of configuration information }
  GLOBALINFO = 1;
//  BOARDINFO = 2;
  DIGITALINFO = 3;
  CTRINFO = 4;
  EXPINFO = 5;
  MISCINFO = 6;


{ Types of global configuration information }
  GIVERSION = 36;
  GINUMBOARDS = 38;
  GINUMEXPBOARDS = 40;

{ Types of board configuration information }
  BIBASEADR = 0;
  BIBOARDTYPE = 1;
  BIINTLEVEL = 2;
  BIDMACHAN = 3;
  BIINITIALIZED = 4;
  BICLOCK = 5;
  BIRANGE = 6;
  BINUMADCHANS = 7;
  BIUSESEXPS = 8;
  BIDINUMDEVS = 9;
  BIDIDEVNUM = 10;
  BICINUMDEVS = 11;
  BICIDEVNUM = 12;
  BINUMDACHANS = 13;
  BIWAITSTATE = 14;
  BINUMIOPORTS = 15;
  BIPARENTBOARD = 16;
  BIDTBOARD = 17;

{ Types of digital device information }
  DIBASEADR = 0;
  DIINITIALIZED = 1;
  DIDEVTYPE = 2;
  DIMASK = 3;
  DIREADWRITE = 4;
  DICONFIG = 5;
  DINUMBITS = 6;
  DICURVAL = 7;

{ Types of counter device information }
  CIBASEADR = 0;
  CIINITIALIZED = 1;
  CICTRTYPE = 2;
  CICTRNUM = 3;
  CICONFIGBYTE = 4;

{ Types of expansion board information }
  XIBOARDTYPE = 0;
  XIMUXADCHAN1 = 1;
  XIMUXADCHAN2 = 2;
  XIRANGE1 = 3;
  XIRANGE2 = 4;
  XICJCCHAN = 5;
  XITHERMTYPE = 6;
  XINUMEXPCHANS = 7;
  XIPARENTBOARD = 8;
  XISPARE0 = 9;

{$ifndef DLLBUILD}

procedure RemoveBoard(bn:integer);
function AddBoard( BoardNum, BoardType : integer ) : integer;
function AddBoardWithDefinePorts( BoardNum, BoardType : integer; PortA, PortB, PortC : byte ) : integer;
function cbDConfigPort( board, portnum, direction : integer ) : integer;
function cbDOUT(Board, Portnum : integer; DataVal : word):integer;
function cbDIN(Board, Portnum : integer; var DataVal : word):integer;
function cbDBitOut(Board, Portnum, BitNum : integer; DataVal : byte):integer;
function cbDBitIn(Board, Portnum, BitNum : integer; var DataVal : integer):integer;
function cbC9513Config (BoardNum:Integer; CounterNum:Integer; GateControl:Integer;
                        CounterEdge:Integer; CountSource:Integer;
                        SpecialGate:Integer; Reload:Integer; RecycleMode:Integer;
                        BCDMode:Integer; CountDirection:Integer;
                        OutputControl:Integer):Integer;
function cbC9513Init (BoardNum:Integer; ChipNum:Integer; FOutDivider:Integer;
                      FOutSource:Integer; Compare1:Integer; Compare2:Integer;
                      TimeOfDay:Integer):Integer;
function cbCLoad (BoardNum:Integer; RegNum:Integer; LoadValue:Word):Integer;
function cbArmCounter(Board_Num, Counter_num : integer):integer;
function cbDisarmCounter(Board_Num, Counter_num : integer):integer;
function cbInByte (BoardNum:Integer; PortNum:Integer):Integer;
function cbOutByte (BoardNum:Integer; PortNum:Integer; PortVal:Integer):Integer;
function SetCounterLOW( board_num, counter_num : integer):integer;
Function SetCounterHigh( board_num, counter_num : integer):integer;

{$else}

procedure RemoveBoard(bn:integer); stdcall; export;
function AddBoard( BoardNum, BoardType : integer ) : integer; stdcall; export;
function AddBoardWithDefinePorts( BoardNum, BoardType : integer; PortA, PortB, PortC : byte ) : integer; stdcall; export;
function cbDConfigPort( board, portnum, direction : integer ) : integer; stdcall; export;
function cbDOUT(Board, Portnum : integer; DataVal : word):integer; stdcall; export;
function cbDIN(Board, Portnum : integer; var DataVal : word):integer; stdcall; export;
function cbDBitOut(Board, Portnum, BitNum : integer; DataVal : byte):integer; stdcall; export;
function cbDBitIn(Board, Portnum, BitNum : integer; var DataVal : integer):integer; stdcall; export;
function cbC9513Config (BoardNum:Integer; CounterNum:Integer; GateControl:Integer;
                        CounterEdge:Integer; CountSource:Integer;
                        SpecialGate:Integer; Reload:Integer; RecycleMode:Integer;
                        BCDMode:Integer; CountDirection:Integer;
                        OutputControl:Integer):Integer; StdCall; export;
function cbC9513Init (BoardNum:Integer; ChipNum:Integer; FOutDivider:Integer;
                      FOutSource:Integer; Compare1:Integer; Compare2:Integer;
                      TimeOfDay:Integer):Integer; StdCall; export;
function cbCLoad (BoardNum:Integer; RegNum:Integer; LoadValue:Word):Integer; StdCall; export;
function cbArmCounter(Board_Num, Counter_num : integer):integer; StdCall; export;
function cbDisarmCounter(Board_Num, Counter_num : integer):integer; StdCall; export;
function cbInByte (BoardNum:Integer; PortNum:Integer):Integer; StdCall; export;
function cbOutByte (BoardNum:Integer; PortNum:Integer; PortVal:Integer):Integer; StdCall; export;
function SetCounterLOW( board_num, counter_num : integer):integer; StdCall; export;
function SetCounterHigh( board_num, counter_num : integer):integer; StdCall; export;

{$endif}

IMPLEMENTATION
uses
//        winsvc,
        Math,
	    Windows,
	    WinRTctl,
      WinRt,
//	WinRTOb,
      dialogs,
      sysutils;


const
  PortA  = 0;
  PortB  = 1;
  PortCL = 2;
  PortCH = 3;
  PortC  = 2;

//============ Function Level Error codes for Counter Timers ===================

  board_num_err = 2;
  Chip_num_err = 3;
  interrupt_level_err = 4;
  counter_num_err = 5;
  fout_div_err = 6;
  fout_source_err = 7;
  comp2_err = 8;
  comp1_err = 9;
  tod_err = 10;
  gate_cntrl_err = 11;
  count_edge_err = 12;
  count_source_err = 13;
  special_gate_err = 14;
  reload_err = 15;
  count_repeat_err = 16;
  count_type_err = 17;
  count_dir_err = 18;
  output_cntrl_err = 19;
  counter_command_err = 20;
  select_counter_err = 21;
  counter_data_err = 22;
  digout_data_err = 23;
  count_err = 24;
  start_ipo_err = 25;
  gate_interval_err = 26;
  signal_source_err = 27;
//============================================================================

  ErrChkOn: BOOLEAN = TRUE;

      // VxDLoader Function Requests
  VXDLDR_APIFUNC_LOADDEVICE     = 1;
  VXDLDR_APIFUNC_UNLOADDEVICE   = 2;
      // VxDLoader Error codes
  VXDLDR_ERR_OUT_OF_MEMORY      = 1;
  VXDLDR_ERR_IN_DOS             = 2;
  VXDLDR_ERR_FILE_OPEN_ERROR    = 3;
  VXDLDR_ERR_FILE_READ          = 4;
  VXDLDR_ERR_DUPLICATE_DEVICE   = 5;
  VXDLDR_ERR_BAD_DEVICE_FILE    = 6;
  VXDLDR_ERR_DEVICE_REFUSED     = 7;
  VXDLDR_ERR_NO_SUCH_DEVICE     = 8;
  VXDLDR_ERR_DEVICE_UNLOADABLE  = 9;
  VXDLDR_ERR_ALLOC_V86_AREA     = 10;
  VXDLDR_ERR_BAD_API_FUNCTION   = 11;

type

_W32Ioctlpkt = record
                 W32IO_ErrorCode,
                 W32IO_DeviceID   : smallint;
                 W32IO_ModuleName : array[0..31] of char;
               end;
IOCTL_PKT    = record
                 Res_DL_Pkt  : _W32Ioctlpkt;
               end;

ShadowBytes_type = record
                  dig_port: array[PortA..PortC] of byte;
                  dig_cntrl_port: byte;
                  dig_val : array[PortA..PortC] of byte;
                  ftt: integer;
                end;

BoardInfoRec = record
                 BoardType : smallint;
                 BaseAddr  : smallint;
                 PortCnfg  : array[PortA..PortCH] of byte;
                 PortValue : array[PortA..PortCH] of byte;
                 AuxByte   : byte;
               end;

var
  WinRTObj    : array[0..9] of tWinrt;
  BoardInfo     : array[0..9,0..7] of BoardInfoRec;
  ShadowBytes    : array[0..9,0..7] of ShadowBytes_type;        // Based on GROUP Method (calulated from PortNum) DIO Only
  TotalDIOs   : integer;
  PortSetup   : array[FIRSTPORTA..EIGHTHPORTCH] of boolean;
  DevicesLoaded : array[0..9] of boolean;

//===============================Driver Section================================
//                                DON'T TOUCH!
//=============================================================================

function check_range(test_val, low_val, high_val: integer): boolean;
var temp: boolean;
begin
  if (test_val >= low_val) and (test_val <= high_val) then temp := false
  else temp := true;
  check_range := temp;
end;

function Init9513(board_num,
                  ChipNum,
                  fout_div,
                  fout_source,
                  comp2,
                  comp1,
                  tod: integer):integer;
var temp               : word;
    CheckRange         : integer;
    command_reg_offset,
    Data_Reg_offset    : integer;
begin
  if not DevicesLoaded[board_num] then
  begin
    Result := -1;
    Exit;
  end;
  if check_range(chipnum, 0, 3) then
  begin
    result := Chip_Num_err;
    exit;
  end
  else
    case BoardInfo[Board_num,Chipnum].BoardType of
      CIO_CTR05 :  checkrange := 0;
      CIO_CTR10 :  checkrange := 1;
//  cio_ctr20 : checkrange := 4;
    else
      begin
         result := -1;
         exit;
      end;
    end; {case}
  if check_range(board_num,0,9) then result := board_num_err
  else
    if check_range(ChipNum,0,checkrange) then result := Chip_Num_err
    else
    if check_range(fout_div,0,15) then result := fout_div_err
     else
       if check_range(fout_source,0,15) then result := fout_source_err
       else
         if check_range(comp2,0,1) then result := comp2_err
         else
           if check_range(comp1,0,1) then result := comp1_err
           else
            if check_range(tod,0,3) then result := tod_err
            else
            begin
                data_reg_offset := (chipnum * 4) + 0;
                command_reg_offset := (chipnum * 4) + 1;
                temp := $c000 or (fout_div shl 8) or (fout_source shl 4) or
                        (comp2 shl 3) or (comp1 shl 2) or tod;
                with winrtobj[board_num] do
                begin
                  outp([], command_reg_offset, $FF);   // Master RESET
//                  outp([], command_reg_offset, $5F);   // Load all counters with source (Load Reg)
                  outp([], command_reg_offset, $17);   // Prepare for 16bit Master Mode Register Load
                  outp([], data_reg_offset, lo(temp)); // Send Lower 8 bits of master mode
                  outp([], data_reg_offset, hi(temp)); // Send Upper 8 bits of master mode
                  declend;
                  ProcessBuffer;
                  clear;
                end;
                DevicesLoaded[Board_Num] := true;
                result := 0;
            end;
end;

// Configure counter mode register
function Config9513(board_num,
                    counter_num,
                    gate_cntrl,
                    count_edge,
                    count_source,
                    special_gate,
                    reload,
                    count_repeat,
                    count_type,
                    count_dir,
                    output_cntrl: integer):integer;

var temp, temp2: word;
    CheckRange         : integer;
    command_reg_offset,
    Data_Reg_offset    : integer;
begin
  if not DevicesLoaded[board_num] then
  begin
    Result := -1;
    Exit;
  end;
  if check_range(counter_num,1,20) then
  begin
    result := counter_num_err;
    exit;
  end
  else
    case BoardInfo[Board_num,((Counter_Num - 1) div 5)].BoardType of
      CIO_CTR05 :  checkrange := 5;
      CIO_CTR10 :  checkrange := 10;
//  cio_ctr20 : checkrange := 20;
    else
      begin
         result := -1;
         exit;
      end;
    end; {case}
  if check_range(board_num,0,9) then result := board_num_err
  else
    if check_range(counter_num,1,checkrange) then result := counter_num_err
     else
       if check_range(gate_cntrl,0,7) then result := gate_cntrl_err
       else
         if check_range(count_edge,0,1) then result := count_edge_err
         else
           if check_range(count_source,0,15) then result := count_source_err
           else
            if check_range(special_gate,0,1) then result := special_gate_err
            else
              if check_range(reload,0,1) then result := reload_err
              else
                if check_range(count_repeat,0,1) then result := count_repeat_err
                else
                  if check_range(count_type,0,1) then result := count_type_err
                  else
                    if check_range(count_dir,0,1) then result := count_dir_err
                    else
                      if check_range(output_cntrl,0,5) or (output_cntrl =  3)
                       then result := output_cntrl_err
                      else
                        with winrtobj[board_num] do
                        begin
                          data_reg_offset := (((Counter_Num - 1) div 5) * 4) + 0;
                          command_reg_offset := (((Counter_Num - 1) div 5) * 4) + 1;
                          temp := gate_cntrl shl 1;
                          temp := (temp or count_edge) shl 4;
                          temp := (temp or count_source) shl 1;
                          temp := (temp or special_gate) shl 1;
                          temp := (temp or reload) shl 1;
                          temp := (temp or count_repeat) shl 1;
                          temp := (temp or count_type) shl 1;
                          temp := (temp or count_dir) shl 3;
                          temp := temp or output_cntrl;
                          temp2 := (((counter_num-1) mod 5)+1);
                          outp([],command_reg_offset, temp2);
                          outp([],data_reg_offset,lo(temp));
                          outp([],data_reg_offset,hi(temp));
                          declend;
                          processbuffer;
                          clear;
                          result := 0;
                        end;
end;

//  Enter command code into command register
function CommandCounters(board_num,
                         Chip_Num,    // add range check on this
                         counter_command,
                         select_counter1,
                         select_counter2,
                         select_counter3,
                         select_counter4,
                         select_counter5: integer):integer;

var temp: word;
    checkrange : integer;
    command_reg_offset : integer;
begin
  if not DevicesLoaded[board_num] then
  begin
    Result := -1;
    Exit;
  end;
  if check_range(Chip_num, 0, 7) then
  begin
    result := Chip_Num_err;
    exit;
  end
  else
    case BoardInfo[Board_num,Chip_num].BoardType of
      CIO_CTR05 :  checkrange := 0;
      CIO_CTR10 :  checkrange := 1;
//  cio_ctr20 : checkrange := 4;
    else
      begin
         result := -1;
         exit;
      end;
    end; {case}
  if check_range(board_num,0,9) then result := board_num_err
  else
    if check_range(chip_num,0, checkrange) then result := Chip_num_err
    else
      if check_range(counter_command,1,6) then result := counter_command_err
      else
         if (check_range(select_counter1,0,1) or
            check_range(select_counter2,0,1) or
            check_range(select_counter3,0,1) or
            check_range(select_counter4,0,1) or
            check_range(select_counter5,0,1)) then result := select_counter_err
            else
              with WinrtObj[board_num] do
              begin
                command_reg_offset := (chip_num * 4) + 1;
                temp := counter_command shl 1;
                temp := (temp or select_counter5) shl 1;
                temp := (temp or select_counter4) shl 1;
                temp := (temp or select_counter3) shl 1;
                temp := (temp or select_counter2) shl 1;
                temp := temp or select_counter1;
                outp([], command_reg_offset, temp);
                declend;
                processbuffer;
                clear;
                result := 0;
              end;
end;


// Enter Value into Counter Load Register
function FillLoadRegister(board_num,
                          counter_num,
                          counter_data: integer):integer;

var checkrange,
    Command_Reg_Offset,
    Data_Reg_Offset : integer;
    temp : word;
begin
  if not DevicesLoaded[board_num] then
  begin
    Result := -1;
    Exit;
  end;
  if check_range(counter_num, 1, 20) then
  begin
    result := Counter_num_err;
    exit;
  end
  else
    case BoardInfo[Board_num,((Counter_Num - 1) div 5)].BoardType of
      CIO_CTR05 :  checkrange := 5;
      CIO_CTR10 :  checkrange := 10;
//  cio_ctr20 : checkrange := 20;
    else
      begin
         result := -1;
         exit;
      end;
    end; {case}
  if check_range(board_num,0,9) then result := board_num_err
  else
    if check_range(counter_num,1,CheckRange) then result := counter_num_err
     else
         with WinRTObj[board_num] do
         begin
           data_reg_offset := (((Counter_Num - 1) div 5) * 4) + 0;
           command_reg_offset := (((Counter_Num - 1) div 5) * 4) + 1;
           temp := (((counter_num-1) mod 5)+1) or 8;
           outp([], command_reg_offset, temp);
           outp([], data_reg_offset, lo(counter_data));
           outp([], data_reg_Offset, hi(counter_data));
           declend;
           processbuffer;
           clear;
           result := 0;
         end;
end;

// Enter Value into Counter Hold Register
function FillHoldRegister(board_num,
                          counter_num,
                          counter_data: integer):integer;

var checkrange,
    Command_Reg_Offset,
    Data_Reg_Offset : integer;
    temp : word;
begin
  if not DevicesLoaded[board_num] then
  begin
    Result := -1;
    Exit;
  end;
  if check_range(counter_num, 1, 20) then
  begin
    result := Counter_num_err;
    exit;
  end
  else
    case BoardInfo[Board_num,((Counter_Num - 1) div 5)].BoardType of
      CIO_CTR05 :  checkrange := 5;
      CIO_CTR10 :  checkrange := 10;
//  cio_ctr20 : checkrange := 20;
    else
      begin
         result := -1;
         exit;
      end;
    end; {case}
  if check_range(board_num,0,9) then result := board_num_err
  else
    if check_range(counter_num,1,CheckRange) then result := counter_num_err
     else
         with WinRTObj[board_num] do
         begin
           data_reg_offset := (((Counter_Num - 1) div 5) * 4) + 0;
           command_reg_offset := (((Counter_Num - 1) div 5) * 4) + 1;
           temp := (((counter_num-1) mod 5)+1) or 16;
           outp([], command_reg_offset, temp);
           outp([], data_reg_offset, lo(counter_data));
           outp([], data_reg_Offset, hi(counter_data));
           declend;
           processbuffer;
           clear;
           result := 0;
         end;
end;


// make counter output high
Function SetCounterHigh( board_num, counter_num : integer):integer;
var command_reg_Offset,
    checkrange : integer;
    temp : word;
begin
  if not DevicesLoaded[board_num] then
  begin
    Result := -1;
    Exit;
  end;
  if check_range(counter_num, 1, 20) then
  begin
    result := Counter_num_err;
    exit;
  end
  else
    case BoardInfo[Board_num,((Counter_Num - 1) div 5)].BoardType of
      CIO_CTR05 :  checkrange := 5;
      CIO_CTR10 :  checkrange := 10;
//  cio_ctr20 : checkrange := 20;
    else
      begin
         result := -1;
         exit;
      end;
    end; {case}
  if check_range(board_num,0,9) then result := board_num_err
  else
    if check_range(counter_num,1,checkrange) then result := counter_num_err
     else
         with winrtObj[board_num] do
         begin
           command_reg_offset := (((Counter_Num - 1) div 5) * 4) + 1;
           temp := ((((counter_num-1) mod 5)+1) or 232);
           outp([], command_reg_Offset, temp);
           declend;
           processbuffer;
           clear;
           Result := 0;
         end;

end;

// make counter output low
function SetCounterLOW( board_num, counter_num : integer):integer;
var command_reg_Offset,
    checkrange : integer;
    temp : word;
begin
  if not DevicesLoaded[board_num] then
  begin
    Result := -1;
    Exit;
  end;
  if check_range(counter_num, 1, 20) then
  begin
    result := Counter_num_err;
    exit;
  end
  else
    case BoardInfo[Board_num,((Counter_Num - 1) div 5)].BoardType of
      CIO_CTR05 :  checkrange := 5;
      CIO_CTR10 :  checkrange := 10;
//  cio_ctr20 : checkrange := 20;
    else
      begin
         result := -1;
         exit;
      end;
    end; {case}
  if check_range(board_num,0,9) then result := board_num_err
  else
    if check_range(counter_num,1,checkrange) then result := counter_num_err
     else
         with winrtObj[board_num] do
         begin
           command_reg_offset := (((Counter_Num - 1) div 5) * 4) + 1;
           temp := (((counter_num-1) mod 5)+1) or 224;
           outp([], command_reg_Offset, temp);
           declend;
           processbuffer;
           clear;
           Result := 0;
         end;
end;

//======================= END DRIVER SECTION =================================

//=============== START DEVICE DRIVER LOAD AND UNLOAD SECTION ================
function LoadDriver(devicenumber : longint):longint;
var
     hVxDLdr         : thandle;
     szCVxDName      : string; //array[0..MAX_PATH] of char;
     usErrorcode     : word;
     DL_IOCTL_Pkt    : IOCTL_PKT;
     cbBytesReturned : DWORD;
     version         : tOSVersionInfo;
(*     hManager,
     hService  : sc_Handle;
     error     : DWORD;
     temp : pansichar;(**)
begin
  version.dwOSVersionInfoSize := sizeof(tOSVersionInfo);
  if not GetVersionEx(Version) then
  begin
    messagedlg('Error getting Version info: ' + inttostr(GetLastError), mterror,[mbok],0);
    result := -1;
    exit
  end;
{$ifdef XPbuild}
  version.dwPlatformId := VER_PLATFORM_WIN32_NT;
{$endif}
  case version.dwPlatformId of
    VER_PLATFORM_WIN32_NT      : begin
(*                                   temp := '';
                                     hManager := OpenSCManager(nil,nil, GENERIC_READ OR GENERIC_WRITE OR GENERIC_EXECUTE);
                                     if hManager = null then
                                     begin
                                       error := GetLastError;
                                       case error of
                                         ERROR_ACCESS_DENIED            : messagedlg('ERROR_ACCESS_DENIED (OM)',mterror,[mbok],0);
                                         ERROR_DATABASE_DOES_NOT_EXIST  : messagedlg('ERROR_DATABASE_DOES_NOT_EXIST (OM)',mterror,[mbok],0);
                                         ERROR_INVALID_PARAMETER        : messagedlg('ERROR_INVALID_PARAMETER (OM)',mterror,[mbok],0);
                                       else
                                         messagedlg('Open Service Manager error: ' + inttostr(error) + ' (OM)',mterror,[mbok],0);
                                       end; {case}
                                       result := -1;
                                       exit;
                                     end;
                                     hService := OpenService(hManager, 'WinRT', GENERIC_READ OR GENERIC_WRITE OR GENERIC_EXECUTE);
                                     if hService = null then
                                     begin
                                       error := GetLastError;
                                       case error of
                                         ERROR_ACCESS_DENIED            : messagedlg('ERROR_ACCESS_DENIED (OM)',mterror,[mbok],0);
                                         ERROR_DATABASE_DOES_NOT_EXIST  : messagedlg('ERROR_DATABASE_DOES_NOT_EXIST (OM)',mterror,[mbok],0);
                                         ERROR_INVALID_PARAMETER        : messagedlg('ERROR_INVALID_PARAMETER (OM)',mterror,[mbok],0);
                                       else
                                         messagedlg('Open Service Manager error: ' + inttostr(error) + ' (OM)',mterror,[mbok],0);
                                       end; {case}
                                       result := -1;
                                       exit;
                                     end;
                                     if not StartService(hService, 0, temp) then
                                     begin
                                       error := GetLastError;
                                       case error of
                                         ERROR_ACCESS_DENIED              :  messagedlg('ERROR_ACCESS_DENIED (OM)',mterror,[mbok],0);
                                         ERROR_INVALID_HANDLE             :  messagedlg('ERROR_INVALID_HANDLE (OM)',mterror,[mbok],0);
                                         ERROR_PATH_NOT_FOUND             :  messagedlg('ERROR_PATH_NOT_FOUND (OM)',mterror,[mbok],0);
                                         ERROR_SERVICE_ALREADY_RUNNING    :  messagedlg('The WinRT driver is already running',mterror,[mbok],0);
                                         ERROR_SERVICE_DATABASE_LOCKED    :  messagedlg('ERROR_SERVICE_DATABASE_LOCKED (OM)',mterror,[mbok],0);
                                         ERROR_SERVICE_DEPENDENCY_DELETED :  messagedlg('ERROR_SERVICE_DEPENDENCY_DELETED (OM)',mterror,[mbok],0);
                                         ERROR_SERVICE_DEPENDENCY_FAIL    :  messagedlg('ERROR_SERVICE_DEPENDENCY_FAIL (OM)',mterror,[mbok],0);
                                         ERROR_SERVICE_DISABLED           :  messagedlg('ERROR_SERVICE_DISABLED (OM)',mterror,[mbok],0);
                                         ERROR_SERVICE_LOGON_FAILED       :  messagedlg('ERROR_SERVICE_LOGON_FAILED (OM)',mterror,[mbok],0);
                                         ERROR_SERVICE_MARKED_FOR_DELETE  :  messagedlg('ERROR_SERVICE_MARKED_FOR_DELETE (OM)',mterror,[mbok],0);
                                         ERROR_SERVICE_NO_THREAD          :  messagedlg('ERROR_SERVICE_NO_THREAD (OM)',mterror,[mbok],0);
                                         ERROR_SERVICE_REQUEST_TIMEOUT    :  messagedlg('ERROR_SERVICE_REQUEST_TIMEOUT (OM)',mterror,[mbok],0);
                                       else
                                         messagedlg('Error starting WinRT: ' + inttostr(error) + ' (SS)',mterror,[mbok],0);
                                       end; {case}
                                       CloseServiceHandle(hManager);
                                       CloseServiceHandle(hService);
                                       result := -1;
                                       exit;
                                     end;
                                     CloseServiceHandle(hManager);
                                     CloseServiceHandle(hService);(**)
                                   result := 0;
                                 end;
    VER_PLATFORM_WIN32_WINDOWS : begin
                                   hVxdLdr := createfile('\\.\VXDLDR',0,0,nil,OPEN_EXISTING,0,0);
                                   if hVXDLdr = INVALID_HANDLE_VALUE then
                                   begin
                                     Messagedlg('Unable to open VXDLDR',mterror,[mbok],0);
                                     result := -1;
                                     exit;
                                   end;
                                 //  GetSystemDirectory(szCVxDName, MAX_PATH);
                                   szCVxDName := 'C:\WINDOWS\SYSTEM';
                                   szCVxDName := szCVxDName + '\VMM32\WRTDEV' + inttostr(devicenumber) + '.VXD';
                                   DeviceIoControl(hVxDLdr, VXDLDR_APIFUNC_LOADDEVICE, pchar(szCVxDName),
                                                  length(szCVxDName) + 1, @DL_IOCTL_Pkt, Sizeof(IOCTL_PKT),
                                                  cbBytesReturned, nil);
                                   usErrorCode := DL_IOCTL_Pkt.Res_DL_pkt.W32IO_ErrorCode;
                                   CloseHandle(hVxDLdr);

                                   if usErrorCode <> 0 then
                                   begin
                                     case usErrorCode of
                                       VXDLDR_ERR_OUT_OF_MEMORY    :  messagedlg('Not Enough Memory',mterror,[mbok],0);
                                       VXDLDR_ERR_IN_DOS           :  messagedlg('Loader could not reenter DOS',mterror,[mbok],0);
                                       VXDLDR_ERR_FILE_OPEN_ERROR  :  messagedlg('Could not find device',mterror,[mbok],0);
                                       VXDLDR_ERR_FILE_READ        :  messagedlg('Error reading device',mterror,[mbok],0);
                                       VXDLDR_ERR_DUPLICATE_DEVICE :  messagedlg('Device already loaded',mterror,[mbok],0);
                                       VXDLDR_ERR_BAD_DEVICE_FILE  :  messagedlg('Not a valid device',mterror,[mbok],0);
                                       VXDLDR_ERR_DEVICE_REFUSED   :  messagedlg('Device refused to load',mterror,[mbok],0);
                                       VXDLDR_ERR_NO_SUCH_DEVICE   :  messagedlg('Device not found',mterror,[mbok],0);
                                     else
                                       messagedlg('Error code ' + inttostr(usErrorCode),mterror,[mbok],0);
                                     end; {Case}
                                     result := -1;
                                     exit;
                                   end;
                                   result := 0;
                                 end;
    VER_PLATFORM_WIN32s        : begin
                                   Messagedlg('Windows 3.1 Win32s not supported.' + #13#13 +
                                              'Halting program.', mterror, [mbok],0);
                                   result := -1;
                                   halt(255);
                                   exit;
                                 end;
    else
    begin
      messagedlg('Unknown operating system' + #13#13 +
                 'Halting program.', mterror,[mbok],0);
      result := -1;
      halt(200);
      exit;
    end;
  end; {case}
end;

function UnLoadDriver(devicenumber:longint):longint;
var
     hVxDLdr         : thandle;
     tempstr         : string;
     tempchar        : char;
     usErrorcode     : word;
     DL_IOCTL_Pkt    : IOCTL_PKT;
     cbBytesReturned : DWORD;
     version         : tOSVersionInfo;
(*     hManager,
     hService  : SC_Handle;
     ss        : TServiceStatus;
     error     : DWORD;(**)
begin
  version.dwOSVersionInfoSize := sizeof(tOSVersionInfo);
  if not GetVersionEx(Version) then
  begin
    messagedlg('Error getting Version info: ' + inttostr(GetLastError), mterror,[mbok],0);
    result := -1;
    exit
  end;

  case version.dwPlatformId of
    VER_PLATFORM_WIN32_NT      : begin
(*                                   hManager := OpenSCManager(nil,nil, GENERIC_READ OR GENERIC_WRITE OR GENERIC_EXECUTE);
                                   if hManager = null then
                                   begin
                                     error := GetLastError;
                                     case error of
                                       ERROR_ACCESS_DENIED            : messagedlg('ERROR_ACCESS_DENIED (OM)',mterror,[mbok],0);
                                       ERROR_DATABASE_DOES_NOT_EXIST  : messagedlg('ERROR_DATABASE_DOES_NOT_EXIST (OM)',mterror,[mbok],0);
                                       ERROR_INVALID_PARAMETER        : messagedlg('ERROR_INVALID_PARAMETER (OM)',mterror,[mbok],0);
                                     else
                                       messagedlg('Open Service Manager error: ' + inttostr(error) + ' (OM)',mterror,[mbok],0);
                                     end; {case}
                                     result := -1;
                                     exit;
                                   end;
                                   hService := OpenService(hManager, 'WinRT', GENERIC_READ OR GENERIC_WRITE OR GENERIC_EXECUTE);
                                   if hService = null then
                                   begin
                                     error := GetLastError;
                                     case error of
                                       ERROR_ACCESS_DENIED            : messagedlg('ERROR_ACCESS_DENIED (OM)',mterror,[mbok],0);
                                       ERROR_DATABASE_DOES_NOT_EXIST  : messagedlg('ERROR_DATABASE_DOES_NOT_EXIST (OM)',mterror,[mbok],0);
                                       ERROR_INVALID_PARAMETER        : messagedlg('ERROR_INVALID_PARAMETER (OM)',mterror,[mbok],0);
                                     else
                                       messagedlg('Open Service Manager error: ' + inttostr(error) + ' (OM)',mterror,[mbok],0);
                                     end; {case}
                                     CloseServiceHandle(hManager);
                                     result := -1;
                                     exit;
                                   end;
                                   if not ControlService(hService, SERVICE_CONTROL_STOP, ss) then
                                   begin
                                     error := GetLastError;
                                     case error of
                                        ERROR_ACCESS_DENIED              : messagedlg('ERROR_ACCESS_DENIED (CS)',mterror,[mbok],0);
                                        ERROR_INVALID_HANDLE             : messagedlg('ERROR_INVALID_HANDLE (CS)',mterror,[mbok],0);
                                        ERROR_DEPENDENT_SERVICES_RUNNING : messagedlg('ERROR_DEPENDENT_SERVICES_RUNNING (CS)',mterror,[mbok],0);
                                        ERROR_INVALID_SERVICE_CONTROL    : messagedlg('ERROR_INVALID_SERVICE_CONTROL (CS)',mterror,[mbok],0);
                                        ERROR_SERVICE_CANNOT_ACCEPT_CTRL : messagedlg('The WinRT Driver is Already Stopped',mterror,[mbok],0);
                                        ERROR_SERVICE_NOT_ACTIVE         : messagedlg('ERROR_SERVICE_NOT_ACTIVE (CS)',mterror,[mbok],0);
                                        ERROR_SERVICE_REQUEST_TIMEOUT    : messagedlg('ERROR_SERVICE_REQUEST_TIMEOUT (CS)',mterror,[mbok],0);
                                     else
                                        Messagedlg('Driver Stop Failed: '+ inttostr(error) + ' (CS)',mterror,[mbok],0);
                                     end; {case}
                                     CloseServiceHandle(hManager);
                                     CloseServiceHandle(hService);
                                     result := -1;
                                     exit;
                                   end;
                                   CloseServiceHandle(hManager);
                                   CloseServiceHandle(hService);(**)
                                   DevicesLoaded[devicenumber] := false;
                                   result := 0;
                                 end;
    VER_PLATFORM_WIN32_WINDOWS : begin
                                   hVxdLdr := createfile('\\.\VXDLDR',0,0,nil,OPEN_EXISTING,0,0);
                                   if hVXDLdr = INVALID_HANDLE_VALUE then
                                   begin
                                     Messagedlg('Unable to open VXDLDR',mterror,[mbok],0);
                                     result := -1;
                                     exit;
                                   end;
                                   str(devicenumber:1,tempstr);
                                   tempchar := tempstr[1];
                                   DL_IOCTL_Pkt.Res_DL_Pkt.W32IO_ModuleName[0] := 'W';
                                   DL_IOCTL_Pkt.Res_DL_Pkt.W32IO_ModuleName[1] := 'R';
                                   DL_IOCTL_Pkt.Res_DL_Pkt.W32IO_ModuleName[2] := 'T';
                                   DL_IOCTL_Pkt.Res_DL_Pkt.W32IO_ModuleName[3] := 'D';
                                   DL_IOCTL_Pkt.Res_DL_Pkt.W32IO_ModuleName[4] := 'E';
                                   DL_IOCTL_Pkt.Res_DL_Pkt.W32IO_ModuleName[5] := 'V';
                                   DL_IOCTL_Pkt.Res_DL_Pkt.W32IO_ModuleName[6] := tempchar;
                                   DL_IOCTL_Pkt.Res_DL_Pkt.W32IO_ModuleName[7] := #0;
                                   DL_IOCTL_Pkt.Res_DL_Pkt.W32IO_DeviceID := -1;
                                   DeviceIoControl(hVxDLdr, VXDLDR_APIFUNC_UNLOADDEVICE, @DL_IOCTL_Pkt,
                                                   sizeof(DL_IOCTL_PKT), @usErrorCode, Sizeof(word),
                                                   cbBytesReturned, nil);
                                   CloseHandle(hVxDLdr);
                                   if usErrorCode <> 0 then
                                   begin
                                     case usErrorCode of
                                       VXDLDR_ERR_OUT_OF_MEMORY    :  messagedlg('Not Enough Memory',mterror,[mbok],0);
                                       VXDLDR_ERR_IN_DOS           :  messagedlg('Loader could not reenter DOS',mterror,[mbok],0);
                                       VXDLDR_ERR_FILE_OPEN_ERROR  :  messagedlg('Could not find device',mterror,[mbok],0);
                                       VXDLDR_ERR_FILE_READ        :  messagedlg('Error reading device',mterror,[mbok],0);
                                       VXDLDR_ERR_DUPLICATE_DEVICE :  messagedlg('Device already loaded',mterror,[mbok],0);
                                       VXDLDR_ERR_BAD_DEVICE_FILE  :  messagedlg('Not a valid device',mterror,[mbok],0);
                                       VXDLDR_ERR_DEVICE_REFUSED   :  messagedlg('Device refused to load',mterror,[mbok],0);
                                       VXDLDR_ERR_NO_SUCH_DEVICE   :  messagedlg('Device not found',mterror,[mbok],0);
                                     else
                                       messagedlg('Error code ' + inttostr(usErrorCode),mterror,[mbok],0);
                                     end; {case}
                                     result := -1;
                                     exit;
                                   end;
                                   DevicesLoaded[devicenumber] := false;
                                   result := 0;
                                 end;
    VER_PLATFORM_WIN32s        : begin
                                   Messagedlg('Windows 3.1 Win32s not supported.' + #13#13 +
                                              'Halting program.', mterror, [mbok],0);
                                   result := -1;
                                   halt(255);
                                   exit;
                                 end;
    else
    begin
      messagedlg('Unknown operating system' + #13#13 +
                 'Halting program.', mterror,[mbok],0);
      result := -1;
      halt(200);
      exit;
    end;
  end; {case}
end;
//=============== END DEVICE DRIVER LOAD AND UNLOAD SECTION ================

//=============== START MISC. FUNCTIONS USED THROUGHOUT DLL ================
function Get_GroupPort(portnum:integer):integer;
begin
  Result := ((PortNum - FirstPortA) MOD 4);
end;

function Get_Group(portnum:integer):integer;
begin
  Result := ((PortNum - FirstPortA ) DIV 4);
end;

Function ReturnBit( Value :byte; BitNum : integer ):integer;
var
  TempBit : byte;
  ValByte : byte;
begin
  ValByte := Value;
  TempBit := byte(ValByte SHL (7-BitNum));
  TempBit := byte(TempBit SHR 7);
  ReturnBit := TempBit;
end;
//================ END MISC. FUNCTIONS USED THROUGHOUT DLL =================

function cbDConfigPort( board, portnum, direction : integer ) : integer;
var i: integer;
    dig_cntrl_code : byte;
    dig_cntrl_int  : integer;
    base_adr       : smallint;
    Group          : smallint;
    GroupPort      : smallint;
begin
  if not DevicesLoaded[board] then
  begin
    Result := -1;
    Exit;
  end;
  result := 0;
  Group     := Get_Group(PortNum);
  GroupPort := Get_GroupPort(PortNum);
{  if groupport = PORTCH then
    groupport := PORTCL;{}
  base_adr := BoardInfo[board, Group].BaseAddr;

  BoardInfo[ board, Group ].PortCnfg[ GroupPort ] := 0;
  if Direction = DigitalIn then
  begin
    case Groupport of
      PortA : BoardInfo[ board, Group ].PortCnfg[ GroupPort ] := 16;
      PortB : BoardInfo[ board, Group ].PortCnfg[ GroupPort ] := 2;
      PortCL : BoardInfo[ board, Group ].PortCnfg[ GroupPort ] := 1;
      PortCH : BoardInfo[ board, Group ].PortCnfg[ GroupPort ] := 8;
    end; {case}
  end;

  dig_cntrl_code := $80;

  for i := PortA to PortCH do
    dig_cntrl_code := dig_cntrl_code + BoardInfo[ board, Group ].PortCnfg[ i ];

  with WinRTObj[board] do
  begin
      with ShadowBytes[board,group] do
      begin
        for i := 0 to 2 do
          dig_port[i] := base_adr +  i;
        dig_cntrl_port := base_adr + 3;
        dig_cntrl_int := dig_cntrl_code;
        if PortSetup[portnum] then
        begin
          outp( [], dig_cntrl_port, dig_cntrl_int );
          DeclEnd;					// This is the end of the statements
          ProcessBuffer;			// That's it! the actual work is done here
          clear;
        end
        else
          PortSetup[portnum] := true;
        ftt := 1;
      end;
  end;
end;

function cbDOUT(Board, Portnum : integer; DataVal : word):integer;
var Group          : smallint;
    GroupPort      : smallint;
    dig_val_int    : integer;
begin
  if not DevicesLoaded[board] then
  begin
    Result := -1;
    Exit;
  end;
  if portnum = AUXPORT then
  begin
    with WinRTObj[Board] do
    begin
      outp([], 3, lo(DataVal));
      if Boardinfo[Board,1].boardtype = CIO_CTR10 then
        outp([], 7, hi(DataVal));
      declend;
      processbuffer;
      clear;
    end;
  end
  else
  begin
    Group     := Get_Group(PortNum);
    GroupPort := Get_GroupPort(PortNum);
    if groupport = PORTCH then
      groupport := PORTC;
    with WinrtObj[board] do
    begin
        with ShadowBytes[board,group] do
        begin
          dig_val[groupport] := DataVal;
          dig_val_int := dig_val[groupport];
          outp([],dig_port[groupport], dig_val_int);
          DeclEnd;					// This is the end of the statements
          ProcessBuffer;			// That's it! the actual work is done here
          clear;
        end;
    end;
  end;
  result := 0;
end;

function cbDBitOut(Board, Portnum, BitNum : integer; DataVal : byte):integer;
var
  DataByteVal    : byte;
  Group          : smallint;
  GroupPort      : smallint;
  MaskVal        : byte;
begin
  Group     := Get_Group(PortNum);
  GroupPort := Get_GroupPort(PortNum);
  if groupport = PORTCH then
    groupport := PORTC;
  BitNum := BitNum - (GroupPort) * 8;
  with ShadowBytes[board,group] do
  begin
    if DataVal >= 1 then
    begin
      MaskVal := byte(round(power(2, BitNum)));
      DataByteVal := dig_val[GroupPort] OR MaskVal;
    end
    else
    begin
      MaskVal := NOT(byte( round(power( 2, BitNum ))));
      DataByteVal := dig_val[GroupPort] AND MaskVal;
    end;
  end;
  Result := cbDOut( Board, PortNum, DataByteVal );
  if Result <> 0 then
    exit;
  Result := 0;
end;

function cbDIN(Board, Portnum : integer; var DataVal : word):integer;
var Group          : smallint;
    GroupPort      : smallint;
    LoOrder,
    HiOrder        : byte;

begin
  if not DevicesLoaded[board] then
  begin
    Result := -1;
    Exit;
  end;
  if Portnum = AUXPORT then
  begin
    LoOrder := 0;
    HiOrder := 0;
    DataVal := 0;
    with winrtobj[board] do
    begin
      inp([], 2, loOrder); // Need Address
      if BoardInfo[Board,1].BoardType = CIO_CTR10 then
        inp([], 6, HiOrder);
      declend;
      processbuffer;
      clear;
      DataVal := (HiOrder shl 8) or LoOrder;
    end;
  end
  else
  begin
    Group     := Get_Group(PortNum);
    GroupPort := Get_GroupPort(PortNum);
    if groupport = PORTCH then
      groupport := PORTC;
    with WinrtObj[board] do
    begin
        with ShadowBytes[board,group] do
        begin
          inp([],dig_port[groupport], DataVal);
          declend;
          ProcessBuffer;
          clear;
        end;
    end;
  end;
  result := 0;
end;

function cbDBitIn(Board, Portnum, BitNum : integer; var DataVal : integer):integer;
var
  DataByteVal : word;
  GroupPort : smallint;
begin
  Result := cbDIn( Board, PortNum, DataByteVal );
  if Result <> 0 then
    exit;
  GroupPort := Get_GroupPort(PortNum);
  if GroupPort = PortCH then
    GroupPort := PortC;  // keep CL and CH referencing the same port
  BitNum := BitNum - (GroupPort) * 8;
  DataVal := ReturnBit( lo(DataByteVal), BitNum );
  Result := 0;
end;

function cbC9513Config (BoardNum:Integer; CounterNum:Integer; GateControl:Integer;
                        CounterEdge:Integer; CountSource:Integer;
                        SpecialGate:Integer; Reload:Integer; RecycleMode:Integer;
                        BCDMode:Integer; CountDirection:Integer;
                        OutputControl:Integer):Integer;
begin
  result := Config9513(BoardNum, CounterNum, GateControl, CounterEdge,
                       CountSource, SpecialGate, ReLoad, RecycleMode,
                       BCDMode, CountDirection, OutPutControl);
end;

function cbC9513Init (BoardNum:Integer; ChipNum:Integer; FOutDivider:Integer;
                      FOutSource:Integer; Compare1:Integer; Compare2:Integer;
                      TimeOfDay:Integer):Integer;
begin
  result := Init9513(Boardnum,(Chipnum-1), FOutDivider, FOutSource, Compare2, Compare1, TimeOfDay);
end;

function cbCLoad (BoardNum:Integer; RegNum:Integer; LoadValue:Word):Integer;
var Counter_Num : integer;
begin
  result := 0;
  case Regnum of
    LoadReg1..LoadReg20 : result := FillLoadRegister(BoardNum, regnum, LoadValue);
    HoldReg1..HoldReg20 : result := FillHoldRegister(BoardNum, (Regnum - 100), LoadValue);
  else
    begin
      result := -1;
      exit;
    end;
  end; {case}
  if RegNum > 100 then
    Counter_Num := Regnum - 100
  else
    Counter_Num := Regnum;
{ Forces Load Register contents into the counter. Based on 'Reload' setting in Config. }
  case Counter_Num of
    1, 6,11,16 : result := CommandCounters(boardnum, ((Counter_Num - 1) div 5), 2, 1, 0, 0, 0, 0);
    2, 7,12,17 : result := CommandCounters(boardnum, ((Counter_Num - 1) div 5), 2, 0, 1, 0, 0, 0);
    3, 8,13,18 : result := CommandCounters(boardnum, ((Counter_Num - 1) div 5), 2, 0, 0, 1, 0, 0);
    4, 9,14,19 : result := CommandCounters(boardnum, ((Counter_Num - 1) div 5), 2, 0, 0, 0, 1, 0);
    5,10,15,20 : result := CommandCounters(boardnum, ((Counter_Num - 1) div 5), 2, 0, 0, 0, 0, 1);
  else
    result := -1;
  end; {case}
//  CommandCounters();   {optional 'arm' command to mimic old computerboards method}
end;

function cbArmCounter(Board_Num, Counter_Num : integer):integer;
var Checkrange : integer;
begin
  if check_range(counter_num, 1, 20) then
  begin
    result := Counter_num_err;
    exit;
  end
  else
    case BoardInfo[Board_num,((Counter_Num - 1) div 5)].BoardType of
      CIO_CTR05 :  checkrange := 5;
      CIO_CTR10 :  checkrange := 10;
//  cio_ctr20 : checkrange := 20;
    else
      begin
         result := -1;
         exit;
      end;
    end; {case}
  if check_range(board_num,0,9) then result := board_num_err
  else
    if check_range(counter_num,1,CheckRange) then result := counter_num_err
     else
       case Counter_Num of    { Arms one counter for counting. }
         1, 6,11,16 : result := CommandCounters(board_num, ((Counter_Num - 1) div 5), 1, 1, 0, 0, 0, 0);
         2, 7,12,17 : result := CommandCounters(board_num, ((Counter_Num - 1) div 5), 1, 0, 1, 0, 0, 0);
         3, 8,13,18 : result := CommandCounters(board_num, ((Counter_Num - 1) div 5), 1, 0, 0, 1, 0, 0);
         4, 9,14,19 : result := CommandCounters(board_num, ((Counter_Num - 1) div 5), 1, 0, 0, 0, 1, 0);
         5,10,15,20 : result := CommandCounters(board_num, ((Counter_Num - 1) div 5), 1, 0, 0, 0, 0, 1);
       else
         result := -1;
       end; {case}
end;

function cbDisarmCounter(Board_Num, Counter_num : integer):integer;
var Checkrange : integer;
begin
  if check_range(counter_num, 1, 20) then
  begin
    result := Counter_num_err;
    exit;
  end
  else
    case BoardInfo[Board_num,((Counter_Num - 1) div 5)].BoardType of
      CIO_CTR05 :  checkrange := 5;
      CIO_CTR10 :  checkrange := 10;
//  cio_ctr20 : checkrange := 20;
    else
      begin
         result := -1;
         exit;
      end;
    end; {case}
  if check_range(board_num,0,9) then result := board_num_err
  else
    if check_range(counter_num,1,CheckRange) then result := counter_num_err
     else
       case Counter_Num of
         1, 6,11,16 : result := CommandCounters(board_num, ((Counter_Num - 1) div 5), 6, 1, 0, 0, 0, 0);
         2, 7,12,17 : result := CommandCounters(board_num, ((Counter_Num - 1) div 5), 6, 0, 1, 0, 0, 0);
         3, 8,13,18 : result := CommandCounters(board_num, ((Counter_Num - 1) div 5), 6, 0, 0, 1, 0, 0);
         4, 9,14,19 : result := CommandCounters(board_num, ((Counter_Num - 1) div 5), 6, 0, 0, 0, 1, 0);
         5,10,15,20 : result := CommandCounters(board_num, ((Counter_Num - 1) div 5), 6, 0, 0, 0, 0, 1);
       else
         result := -1;
       end; {case}
end;

function cbInByte (BoardNum:Integer; PortNum:Integer):Integer;
var temp : word;
begin
  cbDin(BoardNum, PortNum, temp);
  result := temp;
end;

function cbOutByte (BoardNum:Integer; PortNum:Integer; PortVal:Integer):Integer;
begin
  result := cbdout(boardnum,portnum,portval);
end;

function AddBoard( BoardNum, BoardType : integer ) : integer;
begin
  result := AddBoardWithDefinePorts( BoardNum, BoardType, 255, 255, 255);
end;

function AddBoardWithDefinePorts( BoardNum, BoardType : integer; PortA, PortB, PortC : byte ) : integer;
var BaseAddr : smallint;
    i          : integer;
begin
{$ifndef NoDio}
  TotalDIOs := 0;
  DevicesLoaded[BoardNum] := LoadDriver(BoardNum) = 0;
  if DevicesLoaded[BoardNum] then
  begin
    WinRTObj[BoardNum] := tWinrt.create(BoardNum, FALSE);
    if WinRTObj[BoardNum].Handle <> -1 then
    begin
      BaseAddr := 0;  // addressing is relative not absolute
      if boardtype > CTR_SERIES then
      begin
        if BoardType >= CIO_CTR05 then
        begin
          BoardInfo[BoardNum, 0].BoardType := BoardType;
          BoardInfo[BoardNum, 0].BaseAddr  := BaseAddr;
        end;
        if BoardType >= CIO_CTR10 then
        begin
          BoardInfo[BoardNum, 1].BoardType := BoardType;
          BoardInfo[BoardNum, 1].BaseAddr  := BaseAddr + 4;
        end;
      end
      else
      begin
        if BoardType >= CIO_DIO24 then
        begin
          BoardInfo[BoardNum, 0].BoardType := BoardType;
          BoardInfo[BoardNum, 0].BaseAddr  := BaseAddr;
          TotalDIOs := 1;
        end;
        if BoardType >= CIO_DIO48 then
        begin
          BoardInfo[BoardNum, 1].BoardType := BoardType;
          BoardInfo[BoardNum, 1].BaseAddr  := BaseAddr + 3;
          TotalDIOs := 2;
        end;
        if BoardType >= CIO_DIO96 then
        begin
          BoardInfo[BoardNum, 2].BoardType := BoardType;
          BoardInfo[BoardNum, 2].BaseAddr  := BaseAddr + 7;
          BoardInfo[BoardNum, 3].BoardType := BoardType;
          BoardInfo[BoardNum, 3].BaseAddr  := BaseAddr + 11;
          TotalDIOs := 4;
        end;
      end;
    end;
    case BoardType of
      CIO_DIO24,
      CIO_DIO24H : for i := FirstPorta to FirstPortCH do
                   begin
                     cbdconfigport(Boardnum,i,digitalout);
                     case (i-FirstPortA) of
                       0 : cbDOut(boardnum,i,PortA);
                       1 : cbDOut(boardnum,i,PortB);
                       2 : cbDOut(boardnum,i,PortC);
                     end; //case
                   end;
//      CIO_DIO48  : for i := FirstPorta to SecondPortCH do
//                   begin
//                     cbdconfigport(Boardnum,i,digitalout);
//                     cbDOut(boardnum,i,255);
//                   end;
//      CIO_DIO96  : for i := FirstPortA to FourthPortCH do
//                   begin
//                     cbdconfigport(Boardnum,i,digitalout);
//                     cbDOut(boardnum,i,255);
//                   end;
//      CIO_DIO192 : for i := FirstPortA to EighthPortCH do
//                   begin
//                     cbdconfigport(Boardnum,i,digitalout);
//                     cbDOut(boardnum,i,255);
//                   end;
      CIO_CTR05,
      CIO_CTR10  : cbDOut(boardnum,AUXPORT, 0);
    end; {case}
    Result := WinRTObj[BoardNum].Handle;
  end
  else
    Result := -1;
{$else}
  result := 0;
{$endif}
end;

procedure RemoveBoard(bn:integer);
begin
  if DevicesLoaded[bn] then
  begin
    WinRTObj[bn].Destroy;
    UnLoadDriver(bn);  // If win95 will unload VxD, if NT does nothing.
  end;(**)
end;

procedure RemoveBoards;
var loop : integer;
begin
  for loop := low(DevicesLoaded) to high(DevicesLoaded) do
    if DevicesLoaded[loop] then
    begin
      WinRTObj[loop].Destroy;
      UnLoadDriver(loop);  // If win95 will unload VxD, if NT does nothing.
    end;(**)
end;

initialization

  fillchar(BoardInfo,sizeof(BoardInfo),#0);
  fillchar(ShadowBytes,sizeof(ShadowBytes),#0);
  fillchar(PortSetup,sizeof(PortSetup),#0);
  fillchar(DevicesLoaded,sizeof(DevicesLoaded),#0);

finalization
  RemoveBoards;
end.
