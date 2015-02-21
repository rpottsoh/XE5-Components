{_I Conditionals.Inc}
////////////////////////////////////////////////////////////////////////////////
//                         Created By: Daniel Muncy                           //
//                         Date : 4/8/2009                                    //
//                         For : TMSI OnLevel                                 //
//                         Copywrite TMSI all rights reserved.                //
//                                                                            //
// This component handles all reading and writing to a PLC using the INGEAR   //
// Allen Bradly PLC component. The component makes the data available in      //
// module format to better visualize the information.  The component can be   //
// configured using an INI file.                                              //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

// Compiler Directives for this Unit
{INGEAR_Version_52}
{$DEFINE INGEAR_Version_60} // Modifies OnErrorEvent and adds new error codes.

{$IFDEF INGEAR_Version_60}
  {$IFDEF INGEAR_Version_52}
    {$DEFINE INGEAR_Version_52}
  {$ENDIF}
{$ENDIF}

{$IFDEF INGEAR_Version_52}
  {$IFDEF INGEAR_Version_60}
     {$UNDEF INGEAR_Version_60}
  {$ENDIF}
{$ENDIF}
{$IFDEF INGEAR_Version_60}
  {$IFDEF INGEAR_Version_52}
     {$UNDEF INGEAR_Version_52}
  {$ENDIF}
{$ENDIF}

{$IFNDEF INGEAR_Version_52}
  {$IFNDEF INGEAR_Version_60}
    {$DEFINE INGEAR_Version_52}
  {$ENDIF}
{$ENDIF}

unit MicroLogixComms;

interface

uses Windows, Forms, Messages, SysUtils, Classes, StdCtrls, ExtCtrls, ABCTLLib_TLB,
     OleCtrls,StRegINI;

const
  MaximumModules = 20;
Type
{$IFDEF INGEAR_Version_52}
 TintErrorCode = SmallInt;
{$endif}
{$IFDEF INGEAR_Version_60}
 TintErrorCode = LongInt;
{$endif}

 TBitArray = Array[0..15] of Boolean;
 TWord = SmallInt;
 TBitsArray = Array[0..99] of TBitArray;
 TWordsArray = Array[0..99] of TWord;
 TModuleWords = Array[0..1,0..1] of integer; // Index zero is the location of the first module word the second index holds the location of the last module word

 TOptionalParamWordRec = record
   FileType : ShortString;
   WordPos  : Byte;
   Size     : Byte;
   Value    : SmallInt;
 end; // TOptionalParamWordRec

 TOptionalParamBitRec = record
   FileType : ShortString;
   WordPos  : Byte;
   Size     : Byte;
   BitPos   : Byte;
   Value    : Boolean;
 end; // TOptionalParamBitRec

 TPLCWritePacket = Class(TObject)
                     private
                       FSize : LongInt;
                       FFileType : ShortString;
                       FWordNumber : LongInt;
                       FBitPosition : Integer;
                       FWriteBit : Boolean;
                       FWriteWord : Boolean;
                       FBitToWrite : Boolean;
                       FWordToWrite : Smallint;
                       FTransactionPhase : LongInt; // -1 = Just Created, 0 = Pending, 1 = Validated, 2 = Sent, 3 = Error
                       FTransmitAttempts : LongInt;
                     public
                       Constructor Create;
                       property Size : LongInt read FSize write FSize;
                       property FileType : ShortString read FFileType write FFileType;
                       property WordNumber : LongInt read FWordNumber write FWordNumber;
                       property BitPosition : LongInt read FBitPosition write FBitPosition;
                       property WriteBit : Boolean read FWriteBit write FWriteBit;
                       property WriteWord : Boolean read FWriteWord write FWriteWord;
                       property BitToWrite : Boolean read FBitToWrite write FBitToWrite;
                       property WordToWrite : SmallInt read FWordToWrite write FWordToWrite;
                       property TransactionPhase : LongInt read FTransactionPhase write FTransactionPhase;
                       property TransmitAttempts : LongInt read FTransmitAttempts write FTransmitAttempts;
 end; // TPLCWritePacket

 TPLCWritePacketRecord = record
                           Size : Integer;
                           FileType : ShortString;
                           WordNumber : Integer;
                           BitPosition : Integer;
                           WriteBit : Boolean;
                           WriteWord : Boolean;
                           BitToWrite : Boolean;
                           WordToWrite : Smallint;
                           TransactionPhase : LongInt;
 end; // TPLCWritePacketRecord

 TPLCReadPacket = Class(TObject)
                     private
                       FSize : Integer;
                       FFileType : ShortString;
                       FWordNumber : Integer;
                       FBitPosition : Integer;
                       FReadBit : Boolean;
                       FReadWord : Boolean;
                       FBitRead : Boolean;
                       FWordRead : Smallint;
                       FTransactionPhase : LongInt; // -1 = Just Created, 0 = Pending, 1 = Sent, 2 = Returned
                     public
                       Constructor Create;
                       property Size : LongInt read FSize write FSize;
                       property FileType : ShortString read FFileType write FFileType;
                       property WordNumber : LongInt read FWordNumber write FWordNumber;
                       property BitPosition : LongInt read FBitPosition write FBitPosition;
                       property ReadBit : Boolean read FReadBit write FReadBit;
                       property ReadWord : Boolean read FReadWord write FReadWord;
                       property BitRead : Boolean read FBitRead write FBitRead;
                       property WordRead : SmallInt read FWordRead write FWordRead;
                       property TransactionPhase : LongInt read FTransactionPhase write FTransactionPhase;
 end; // TReadPacket

 TPLCReadPacketRec = record
                       Size : Integer;
                       FileType : ShortString;
                       WordNumber : Integer;
                       BitPosition : Integer;
                       ReadBit : Boolean;
                       ReadWord : Boolean;
                       BitRead : Boolean;
                       WordRead : Smallint;
                       TransactionPhase : LongInt;
 end; // TReadPacketRec

 TBaseModule = class(TObject)
   private
     FModuleNumber : Integer;
     FModuleType : Integer; // 0 Main 1 Input 2 Output
     FModuleError : Boolean;
     FModuleWords : TModuleWords;
     procedure SetModuleWord(HiIndex : LongInt; LowIndex : LongInt; Value : LongInt);
     function GetModuleWord(HiIndex : LongInt; LowIndex : LongInt) : LongInt;
     property ModuleNumber : Integer read FModuleNumber write FModuleNumber;
     property ModuleType : Integer read FModuleType write FModuleType;
     property ModuleError : Boolean read FModuleError write FModuleError;
     property ModuleWords[HiIndex :LongInt; LowIndex : LongInt] : LongInt read GetModuleWord write SetModuleWord;
   public
     Constructor Create;
 end; // TBaseModule

 TBaseAnalogModule = class(TBaseModule)
   private
     FChannelDataValue : Array[0..3] of LongInt;
     FChannelStatus : Array[0..3] of boolean;
     FChannelOverRangeFlag : Array[0..3] of boolean;
     FChannelUnderRangeFlag : Array[0..3] of boolean;
     procedure SetChannelDataValue(Channel : Byte; Value : LongInt);
     function GetChannelDataValue(Channel : Byte) : LongInt;
     procedure SetChannelStatus(Channel : Byte; Value : Boolean);
     function GetChannelStatus(Channel : Byte) : Boolean;
     procedure SetChannelORFlag(Channel : Byte; Value : Boolean);
     function GetChannelORFlag(Channel : Byte) : Boolean;
     procedure SetChannelURFlag(Channel : Byte; Value : Boolean);
     function GetChannelURFlag(Channel : Byte) : Boolean;
   public
     Constructor Create;
     property ChannelDataValue[Channel : Byte] : LongInt read GetChannelDataValue write SetChannelDataValue;
     property ChannelStatus[Channel : Byte] : Boolean read GetChannelStatus write SetChannelStatus;
     property ChannelOverRangeFlag[Channel : Byte] : Boolean read GetChannelORFlag write SetChannelORFlag;
     property ChannelUnderRangeFlag[Channel : Byte] : Boolean read GetChannelURFlag write SetChannelURFlag;
 end; // TBaseAnalogModule

 TPLCMainModule = class(TBaseModule)
             private
               FMajorErrorCode : integer;
               FProcessorMode : Integer;
               FKeySwitchPos : Byte;
               FForcedIO,
               FControlRegisterError,
               FMajorErrorHalt,
               FBatteryOK : Boolean;
               FDigitalInputModuleWords,
               FDigitalOutputModuleWords,
               FAnalogInputModuleWords,
               FAnalogOutputModuleWords,
               FRequestBits_ModuleWords : TModuleWords;
               FDigitalInputData : Array[0..3] of TBitArray;
               FAnalogInputData : Array[0..3] of LongInt;
               FDigitalOutputData : Array[0..3] of TBitArray;
               FAnalogOutputData : Array[0..1] of LongInt;
               FRequest_Bits_Status : Array[0..9] of TBitArray;
               function FindModuleWord(HiIndex : LongInt; LowIndex : LongInt; Item : Byte) : LongInt; // Item refers to Digital Input, Digital Ouptut, Analog Input, Analog Output, or Request Bits
               procedure SetModuleWord(HiIndex : LongInt; LowIndex : LongInt; Item : Byte; Value : LongInt);

               procedure SetDigInputModuleWord(HiIndex : LongInt; LowIndex : LongInt; Value : LongInt);
               function GetDigInputModuleWord(HiIndex : LongInt; LowIndex : LongInt) : LongInt;
               procedure SetDigOutputModuleWord(HiIndex : LongInt; LowIndex : LongInt; Value : LongInt);
               function GetDigOutputModuleWord(HiIndex : LongInt; LowIndex : LongInt) : LongInt;
               procedure SetAnalogInputModuleWord(HiIndex : LongInt; LowIndex : LongInt; Value : LongInt);
               function GetAnalogInputModuleWord(HiIndex : LongInt; LowIndex : LongInt) : LongInt;
               procedure SetAnalogOutputModuleWord(HiIndex : LongInt; LowIndex : LongInt; Value : LongInt);
               function GetAnalogOutputModuleWord(HiIndex : LongInt; LowIndex : LongInt) : LongInt;
               procedure SetRequestBitsModuleWord(HiIndex : LongInt; LowIndex : LongInt; Value : LongInt);
               function GetRequestBitsModuleWord(HiIndex : LongInt; LowIndex : LongInt) : LongInt;
               procedure SetDigitalInputData(InputNum : Byte; Value : TBitArray);
               function GetDigitalInputData(InputNum : Byte) : TBitArray;
               procedure SetAnalogInputData(InputNum : Byte; Value : LongInt);
               function GetAnalogInputData(InputNum : Byte) : LongInt;
               procedure SetDigitalOutputData(Output : Byte; Value : TBitArray);
               function GetDigitalOutputData(Output : Byte) : TBitArray;
               procedure SetAnalogOutputData(Output : Byte; Value : LongInt);
               function GetAnalogOutputData(Output : Byte) : LongInt;
               procedure SetRequestBitsStatus(WordNum : Byte; Value : TBitArray);
               function GetRequestBitsStatus(WordNum : Byte) : TBitArray;
             public
               Constructor Create;
               property ModuleNumber;
               property ModuleType;
               property ModuleError;
               property MajorErrorCode : integer read FMajorErrorCode write FMajorErrorCode;
               property MajorErrorHalt : Boolean read FMajorErrorHalt write FMajorErrorHalt;
               property ProcessorMode : Integer read FProcessorMode write FProcessorMode;
               property KeySwitchPosition : Byte read FKeySwitchPos write FKeySwitchPos;
               property ForcedIO : Boolean read FForcedIO write FForcedIO;
               property ControlRegisterError : Boolean read FControlRegisterError write FControlRegisterError;
               property BatteryOK : Boolean read FBatteryOK write FBatteryOK;
               property DigitalInputModuleWords[HiIndex : LongInt; LowIndex : LongInt] : LongInt read GetDigInputModuleWord write SetDigInputModuleWord;
               property DigitalOutputModuleWords[HiIndex : LongInt; LowIndex : LongInt] : LongInt read GetDigOutputModuleWord write SetDigOutputModuleWord;
               property AnalogInputModuleWords[HiIndex : LongInt; LowIndex : LongInt] : LongInt read GetAnalogInputModuleWord write SetAnalogInputModuleWord;
               property AnalogOutputModuleWords[HiIndex : LongInt; LowIndex : LongInt] : LongInt read GetAnalogOutputModuleWord write SetAnalogOutputModuleWord;
               property RequestBits_ModuleWords[HiIndex : LongInt; LowIndex : LongInt] : LongInt read GetRequestBitsModuleWord write SetRequestBitsModuleWord;
               property DigitalInputData[InputNum : Byte] : TBitArray read GetDigitalInputData write SetDigitalInputData;
               property AnalogInputData[InputNum : Byte] : LongInt read GetAnalogInputData write SetAnalogInputData;
               property DigitalOutputData[OutputNum : Byte] : TBitArray read GetDigitalOutputData write SetDigitalOutputData;
               property AnalogOutputData[OutputNum : Byte] : LongInt read GetAnalogOutputData write SetAnalogOutputData;
               property Request_Bits_Status[WordNum : Byte] : TBitArray read GetRequestBitsStatus write SetRequestBitsStatus;

 end; // TPLCModule

 TDigitalInputModule = class(TBaseModule)
             private
               FDigitalInputData : TBitArray;
             public
               Constructor Create;
               property ModuleNumber;
               property ModuleType;
               property ModuleError;
               property ModuleWords;
               property DigitalInputData : TBitArray read FDigitalInputData write FDigitalInputData;

 end; // TDigitalInputModule

 TDigitalOutputModule = class(TBaseModule)
             private
               FDigitalOutputData : TBitArray;
             public
               Constructor Create;
               property ModuleNumber;
               property ModuleType;
               property ModuleError;
               property ModuleWords;
               property DigitalOutputData : TBitArray read FDigitalOutputData write FDigitalOutputData;
 end; // TDigitalOutputModule

 TRelayedDigitalOutputModule = class(TBaseModule)
               private
                 FRelayedDigitalOutputData : TBitArray;
               public
                 Constructor Create;
                 property ModuleNumber;
                 property ModuleType;
                 property ModuleError;
                 property ModuleWords;
                 property RelayedDigitalOutputData : TBitArray read FRelayedDigitalOutputData write FRelayedDigitalOutputData;
 end; // TRelayedDigitalOutputModule

 TAnalogInputModule = class(TBaseAnalogModule)
   public
     property ModuleNumber;
     property ModuleType;
     property ModuleError;
     property ModuleWords;
     property ChannelDataValue;
     property ChannelStatus;
     property ChannelOverRangeFlag;
     property ChannelUnderRangeFlag;
 end;

 TRTDAnalogInputModule = class(TBaseAnalogModule)
   private
     FChannelOpenCircuitFlag : Array[0..3] of boolean;
     procedure SetChannelOCFlag(Channel : Byte; Value : Boolean);
     function GetChannelOCFlag(Channel : Byte) : Boolean;
   public
     Constructor Create;
     property ModuleNumber;
     property ModuleType;
     property ModuleError;
     property ModuleWords;
     property ChannelDataValue;
     property ChannelStatus;
     property ChannelOverRangeFlag;
     property ChannelUnderRangeFlag;
     property ChannelOpenCircuitFlag[Channel : Byte] : Boolean read GetChannelOCFlag write SetChannelOCFlag;
 end;

 TAnalogOutputModule = class(TBaseAnalogModule)
   public
     property ModuleNumber;
     property ModuleType;
     property ModuleError;
     property ModuleWords;
     property ChannelDataValue;
     property ChannelStatus;
     property ChannelOverRangeFlag;
     property ChannelUnderRangeFlag;
 end; // TAnalogOutputModule

 TAnalogInputModule1762_IF4 = record // 1762-IF4 I/O Expansion Module
                                ModuleType : String[255];
                                ChannelDataInputValue : Array[0..3] of double;
                                ChannelSign : Array[0..3] of integer;
                                ChannelStatus : Array[0..3] of boolean;
                                ChannelOverRangeFlag : Array[0..3] of boolean;
                                ChannelUnderRangeFlag : Array[0..3] of boolean;
 end; // TAnalogInputModule1762_IF4

 TRTDAnalogInputModule1762_IR4 = record // 1762-IF4 I/O Expansion Module
                                   ModuleType : String[255];
                                   ChannelDataInputValue : Array[0..3] of double;
                                   ChannelSign : Array[0..3] of integer;
                                   ChannelStatus : Array[0..3] of boolean;
                                   ChannelOverRangeFlag : Array[0..3] of boolean;
                                   ChannelUnderRangeFlag : Array[0..3] of boolean;
                                   ChannelOpenCircuitFlag : Array[0..3] of boolean;
 end; // TRTDAnalogInputModule1762_IR4

 TAnalogOutputModule1762_OF4 = record // 1762-OF4 Expansion Module
                                 ModuleType : String[255];
                                 ChannelDataOutputValue : Array[0..3] of double;
                                 ChannelDataFormat : Array[0..3,0..3] of boolean; // Raw Proportional or Scaled for PID
                                 ChannelTypeRange : Array[0..3,0..4] of boolean; // Either Voltage (0-10V) or Current(4 to 20mA)
                                 ChannelStatus : Array[0..3] of boolean;
                                 ChannelOverRangeFlag : Array[0..3] of boolean;
                                 ChannelUnderRangeFlag : Array[0..3] of boolean;
 end; // TAnalogOutputModule1762_OF4

 TModuleArray = Array[0..7] of TObject;
 TModuleType = Array[0..7] of Integer;

 TConfigurationError = procedure(Sender : TObject; ErrorNumber : Integer; PLCErrorMessage : ShortString) of Object;
 TReadWriteErrorEvent = procedure(Sender : TObject; ErrorNumber : Integer; PLCErrorMessage : ShortString; ErrorPacket : TPLCWritePacketRecord; ExceededFaultTollerance : Boolean) of Object;
 TReadWriteRecoverableErrorEvent = procedure(Sender : TObjecT; ErrorNumber : Integer; PLCErrorMessage : ShortString) of Object;
 TPLCMajorError = procedure(Sender : TObject; ErrorNumber : SmallInt; HexValue : ShortString) of Object;
 TNewDataReadFromPLC = procedure(Sender : TObject; BitDataFromPLC : TBitsArray;  WordDataFromPLC : TWordsArray) of Object;
 TSendModuleData = procedure(Sender : TObject; Modules : TModuleArray; ModuleTypes : TModuleType; ModuleCount : Integer) of Object;
 TValueReadFromPLC = procedure(Sender : TObject; ReturnedPacket : TPLCReadPacketRec) of Object;

 TMicroLogixPLC = class;
 TPLCWriteThread = class;

 TPLCWatchDogThread = Class(TThread)
 private
   FPLCWriteThread : TPLCWriteThread;
   FWatchDogValue : Boolean;
   FWatchDogBit : Integer;
   FWatchDogWordNum : Integer;
   FSleepInterval : LongInt;
   FWatchDogEnabled : Boolean;
 protected
   procedure DoSendWatchDogToggle;
   procedure Execute; Override;
 public
   constructor Create(Var ParentThread : TPLCWriteThread);
   destructor Destroy; Override;
   property WatchDogEnabled : Boolean read FWatchDogEnabled write FWatchDogEnabled;
   property WatchDogBitNum : Integer read FWatchDogBit write FWatchDogBit;
   property WatchDogWordNum : Integer read FWatchDogWordNum write FWatchDogWordNum;
   property SleepInterval : LongInt read FSleepInterval write FSleepInterval;
 end; // TPLCWatchDogThread

 TPLCWriteThread = class(TThread)
 private
   PLCMonitor : TMicroLogixPLC;
   FPLCWrite : TABCTL;
   FWriteFault : Boolean;
   FWriteStack : TStringList;
   FLastPacketWritten : TPLCWritePacketRecord;
   FLastPacketWithError : TPLCWritePacketRecord;
   FWriteErrorNum : Integer;
   FWriteErrorStr : ShortString;
   FWriteEnabled : Boolean;
   FWriteIPAddress : ShortString;
   FWriteFaultTol : LongInt;
   FWriteFaultCount : LongInt;
   FPacketQueLength : LongInt;
   FWriteAttemptsBeforeFail : LongInt;
   FThreadRunning : Boolean;
   FWriteWaitTimeOut : DWord;
   procedure PLCWriteWriteDone(Sender : TObject);
   procedure PLCWriteErrorEvent(Sender : TObject; nErrorCode : TintErrorCode);
   procedure SetWriteEnabled(Value : Boolean);
   procedure SetIPAddress(Value : ShortString);
   function GetAdapterNum : LongInt;
   procedure SetAdapterNum(Value : LongInt);
   procedure SetWriteFaultTol(Value : LongInt);
   function GetWriteFaultTol : LongInt;
   procedure SetEthernetTimeOut(Value : SmallInt);
   function GetEthernetTimeOut : SmallInt;
 protected
   procedure DoTransmitPacket;
   procedure DoWriteErrorEvent;
   procedure DoWriteRecoverableErrorEvent;
   function ValidatePacket(lPacket : TPLCWritePacket) : boolean;
   function AddToWriteStack(lPacket : TPLCWritePacket) : Boolean;
   function Get_ThreadWriteStackAccess(TimeOutms : DWord) : Boolean;
   procedure Release_ThreadWriteStackAccess;
   procedure Execute; Override;
 public
   constructor Create(var lParent : TMicroLogixPLC);
   destructor Destroy; Override;
   function WriteBitToPLC(pFile : ShortString; pWordNumber : integer; BitNumber : integer; intSize : integer; Value : boolean) : Boolean;
   function WriteWordToPLC(pFile : ShortString; pWordNumber : integer; intSize : integer; Value : SmallInt) : Boolean;
   property WriteEnabled : Boolean read FWriteEnabled write SetWriteEnabled;
   property WriteIPAddress : ShortString read FWriteIPAddress write SetIPAddress;
   property WriteQue : LongInt read FPacketQueLength;
   property WriteAdapterNum : LongInt read GetAdapterNum write SetAdapterNum;
   property WriteFault : Boolean read FWriteFault write FWriteFault;
   property LastError : Integer read FWriteErrorNum;
   property WriteFaultTollerance : LongInt read GetWriteFaultTol write SetWriteFaultTol;
   property WriteWaitTimeOut_ms : DWord read FWriteWaitTimeOut write FWriteWaitTimeOut; // This property controls how long (in ms) a thread will wait for the shared resource "FWriteStack".
   property EthernetTimeOut : SmallInt read GetEthernetTimeOut write SetEthernetTimeOut;
   property WriteAttemptsBeforeFail : LongInt read FWriteAttemptsBeforeFail write FWriteAttemptsBeforeFail;
   property ThreadRunning : Boolean read FThreadRunning write FThreadRunning;
 end; // TPLCWriteThread

 TPLCReadThread = class(TThread)
 private
   PLCMonitor : TMicroLogixPLC;
   FSleepTime : LongInt;
   FPLCRead : TABCTL;
   FDataBits,
   FStatusBits : TBitsArray;
   FDataWords,
   FStatusWords : TWordsArray;
   FReadFault : boolean;
   FDataFile,
   FStatusFile : ShortString;
   FDataReadSize,
   FStatusReadSize : DWord;
   FReadState : integer; // 0 = Integer File, 1 = Status
   FNewDataReady : Boolean;
   FReadErrorNum : Integer;
   FReadErrorStr : ShortString;
   FReadEnabled : Boolean;
   FReadIPAddress : ShortString;
   FModulesLoaded : Boolean;
   FModuleCount : Integer;
   FModuleType : TModuleType;
   FModules : TModuleArray;
   FReadStack : TStringList;
   FProcessReadPacket : Boolean;
   FReadPacketRec : TPLCReadPacketRec;
   FReadFaultTol : LongInt;
   FReadFaultCount : LongInt;
   FPacketQueLength : LongInt;
   procedure SetSleepTime(Value : LongInt);
   function GetSleepTime : LongInt;
   procedure PLCReadReadDone(Sender : TObject);
   procedure PLCReadErrorEvent(Sender : TObject; nErrorCode : TintErrorCode);
   procedure SetReadEnabled(Value : Boolean);
   procedure SetReadIPAddress(Value : ShortString);
   procedure SetModules(Modules : TModuleArray);
   function GetModules : TModuleArray;
   procedure SetModuleTypes(ModuleTypes : TModuleType);
   function GetModuleTypes : TModuleType;
   function GetAdapterNum : LongInt;
   procedure SetAdapterNum(Value : LongInt);
   procedure SetReadFaultTol(Value : LongInt);
   function GetReadFaultTol : LongInt;
   procedure SetEthernetTimeOut(Value : SmallInt);
   function GetEthernetTimeOut : SmallInt;
 protected
   procedure DoReadPacket;
   procedure DoReadFromPLC;
   procedure DoReadErrorEvent;
   procedure DoReturnValueFromPLC;
   procedure DoPassModuleData;
   procedure DoReadRecoverableErrorEvent;
   procedure PrimePLCForNextRead(Value : Integer);
   procedure PopulateModules;
   procedure AddToReadStack(lPacket : TPLCReadPacket);
   function Get_ThreadReadStackAccess(TimeOutms : DWord) : Boolean;
   procedure Release_ThreadReadStackAccess;
   procedure Execute; Override;
 public
   constructor Create(Var lParent : TMicroLogixPLC);
   destructor Destroy; Override;
   procedure ReadBitFromPLC(pFile : ShortString; pWordNumber : integer; BitNumber : integer; intSize : integer);
   procedure ReadWordFromPLC(pFile : ShortString; pWordNumber : integer; intSize : integer);
   property SleepTime : LongInt read FSleepTime write SetSleepTime;
   property ReadEnabled : Boolean read FReadEnabled write SetReadEnabled;
   property ReadIPAddress : ShortString read FReadIPAddress write SetReadIPAddress;
   property ReadAdapterNum : LongInt read GetAdapterNum write SetAdapterNum;
   property ReadQue : LongInt read FPacketQueLength;
   property DataFile : ShortString read FDataFile write FDataFile;
   property StatusFile : ShortString read FStatusFile write FStatusFile;
   property DataReadSize : DWord read FDataReadSize write FDataReadSize;
   property StatusReadSize : Cardinal read FStatusReadSize write FStatusReadSize;
   property ReadFault : Boolean read FReadFault write FReadFault;
   property LastError : Integer read FReadErrorNum;
   property Modules : TModuleArray read GetModules write SetModules;
   property ModuleCount : Integer read FModuleCount write FModuleCount;
   property ModuleTypes : TModuleType read GetModuleTypes write SetModuleTypes;
   property ReadFaultTollerance : LongInt read GetReadFaultTol write SetReadFaultTol;
   property EthernetTimeOut : SmallInt read GetEthernetTimeOut write SetEthernetTimeOut;
 end; // TPLCReadThread

 TMicroLogixPLC = class(TComponent)
 private
 {Private Declarations}
   FOnReadError,
   FOnWriteError : TReadWriteErrorEvent;
   FOnSendModuleData : TSendModuleData;
   FOnReadRecoverableError,
   FOnWriteRecoverableError : TReadWriteRecoverableErrorEvent;
   FOnConfigurationError : TConfigurationError;
   FOnValueReadFromPLC : TValueReadFromPLC;
   FEnabled,
   FWatchDogActive : Boolean;
   FWatchDogWordNumber,
   FWatchDogBitNumber : integer;
   FWatchDogInterval : integer;
   FWatchDogValue : boolean;
   FPLCWriteThread : TPLCWriteThread;
   FPLCReadThread : TPLCReadThread;
   FPLCWatchDogThread : TPLCWatchDogThread;
   FThreadsStarted : boolean;
   FModuleCount : Integer;
   Modules : TModuleArray;
   ModuleType : TModuleType;
   FModulesPresent : Boolean;
   FConfigurationFile : ShortString;
   FVersion : ShortString;
   FReadInterval : Integer;
   FBinaryReadSize : DWord;
   FDataReadSize : DWord;
   FStatusSize : LongInt;
   FDataFile : ShortString;
   FWatchDogTimeOut : LongInt;
   FWatchDogHi : ShortString;
   FWatchDogLo : ShortString;
   FReadIPAddress : ShortString;
   FWriteIPAddress : ShortString;
   FReadFaultTollerance : LongInt;
   FWriteFaultTollerance : LongInt;
   FReadAdapterNum : LongInt;
   FWriteAdapterNum : LongInt;
   FEthernetTimeOut : SmallInt;
   FMaximumWriteAttempts : LongInt;
   FEmbededIOResolution : LongInt;
   FExpandedIOResolution : LongInt;
   FWriteWaitTimeOut : DWord;
   function GetEnabled : boolean;
   procedure SetEnabled(Value : Boolean);
   procedure SetReadIPAddress(Value : ShortString);
   function GetReadIPAddress : ShortString;
   procedure SetWriteIPAddress(Value : ShortString);
   function GetWriteIPAddress : ShortString;
   procedure SetDataSize(Value : DWord);
   function GetDataSize : DWord;
   procedure SetDataFile(Value : ShortString);
   function GetDataFile : ShortString;
   procedure SetStatusSize(Value : Integer);
   function GetStatusSize : Integer;
   function GetWriteFault : Boolean;
   function GetWriteWaitTimeOut :  DWord;
   procedure SetWriteWaitTimeOut(Value : DWord);
   function GetReadFault : Boolean;
   procedure SetWatchDogState(Value : boolean);
   procedure SetWatchDogInterval(Value : longint);
   procedure SetReadInterval(Value : LongInt);
   function GetReadInterval : LongInt;
   function GetErrorMessage(nErrorCode : TintErrorCode) : ShortString;
   function GetLastReadError : ShortString;
   function GetLastWriteError : ShortString;
   function ValidIPAddress(Value : ShortString) : Boolean;
   procedure SetVersion(Value : ShortString);
   procedure SetWatchDogWordNumber(Value : Integer);
   procedure SetWatchDogBitNumber(Value : Integer);
   procedure SetWatchDogTimeOut(Value : LongInt);
   function GetReadAdapterNum : LongInt;
   procedure SetReadAdapterNum(Value : LongInt);
   function GetWriteAdapterNum : LongInt;
   procedure SetWriteAdapterNum(Value : LongInt);
   function GetReadPacketsInQue : LongInt;
   function GetWritePacketsInQue : LongInt;
   function GetReadFaultTollerance : LongInt;
   procedure SetReadFaultTollerance(Value : LongInt);
   function GetWriteFaultTollerance : LongInt;
   procedure SetWriteFaultTollerance(Value : LongInt);
   function GetEthernetTimeOut : SmallInt;
   procedure SetEthernetTimeOut(Value : SmallInt);
   procedure SetMaximumWriteAttempts(Value : LongInt);
   function GetMaximumWriteAttempts : LongInt;
 protected
 {Protected Declarations}
   function CheckModuleConfigutaion : Boolean;
   procedure SavePLCConfiguration(lFileName : ShortString);
   procedure DoConfigurationError(ErrorNum : LongInt; ErrorMsg : String);
   procedure ClearWatchDogAccumulator(WatchDog : String);
 public
 {Public Declarations}
   Constructor Create(AOwner : TComponent); Override;
   Destructor Destroy; Override;
   procedure InitializePLC;
   procedure LoadPLCConfiguration(lFileName : ShortString);
   procedure ResetPLC;
   function ProcessorMode(ModuleType,intProcessorMode : Integer) : ShortString;
   function WriteBitToPLC(pFile : shortstring; pWordNumber : integer; BitNumber : integer; intSize : integer; Value : boolean) : Boolean;
   function WriteWordToPLC(pFile : shortstring; pWordNumber : integer; intSize : integer; Value : SmallInt) : Boolean;
   procedure ReadBitFromPLC(pFile : shortstring; pWordNumber : integer; BitNumber : integer; intSize : integer);
   procedure ReadWordFromPLC(pFile : shortstring; pWordNumber : integer; intSize : integer);
   procedure LoadOptionalParams(ValueName : TStringList);
   procedure SaveOptionalWordParam(ParamNumber : LongInt; FileType : ShortString; WordPos : Byte; Size : Byte; Value : SmallInt);
   procedure SaveOptionalBitParam(ParamNumber : LongInt; FileType : ShortString; WordPos : Byte; BitPos : Byte; Size : Byte; Value : Boolean);
   property EmbededIOResolution : LongInt read FEmbededIOResolution;
   property ExpandedIOResolution :LongInt read FExpandedIOResolution;
 published
 {Published Declarations}
   property Version : ShortString read FVersion write SetVersion;
   property Enabled : boolean read GetEnabled write SetEnabled default False;
   property BinarySize : DWord read FBinaryReadSize write FBinaryReadSize;
   property DataSize : DWord read GetDataSize write SetDataSize;
   property DataFile : ShortString read GetDataFile write SetDataFile;
   property StatusSize : Integer read GetStatusSize write SetStatusSize default 66;
   property EthernetTimeOut : SmallInt read GetEthernetTimeOut write SetEthernetTimeOut;
   property ReadIPAddress : ShortString read GetReadIPAddress write SetReadIPAddress;
   property ReadAdapterNum : LongInt read GetReadAdapterNum write SetReadAdapterNum default 0;
   property ReadFault : boolean read GetReadFault default False;
   property ReadInterval : longInt read GetReadInterval write SetReadInterval default 60;
   property ReadPacketsInQue : LongInt read GetReadPacketsInQue;
   property LastReadError : ShortString read GetLastReadError;
   property WriteIPAddress : ShortString read GetWriteIPAddress write SetWriteIPAddress;
   property WriteAdapterNum : LongInt read GetWriteAdapterNum write SetWriteAdapterNum default 0;
   property WriteFault : Boolean read GetWriteFault default False;
   property WriteWaitTimeOut_ms : DWord read GetWriteWaitTimeOut write SetWriteWaitTimeOut;
   property WritePacketsInQue : LongInt read GetWritePacketsInQue;
   property MaximumWriteAttempts : LongInt read GetMaximumWriteAttempts write SetMaximumWriteAttempts;
   property LastWriteError : ShortString read GetLastWriteError;
   property EnableWatchDog : boolean read FWatchDogActive write SetWatchDogState default False;
   property WatchDogHi : ShortString read FWatchDogHi write FWatchDogHi;
   property WatchDogLo : ShortString read FWatchDogLo write FWatchDogLo;
   property WatchDogTimeOut : LongInt read FWatchDogTimeOut write SetWatchDogTimeOut default 500;
   property WatchDogWordNumber : integer read FWatchDogWordNumber write SetWatchDogWordNumber default 1;
   property WatchDogBitNumber : integer read FWatchDogBitNumber write SetWatchDogBitNumber default 2;
   property WatchDogInterval : integer read FWatchDogInterval write SetWatchDogInterval;

   property OnConfigurationError : TConfigurationError read FOnConfigurationError write FOnConfigurationError;
   property OnReadError : TReadWriteErrorEvent read FOnReadError write FOnReadError;
   property OnReadRecoverableError : TReadWriteRecoverableErrorEvent read FOnReadRecoverableError write FOnReadRecoverableError;
   property OnWriteError : TReadWriteErrorEvent read FOnWriteError write FOnWriteError;
   property OnWriteRecoverableError : TReadWriteRecoverableErrorEvent read FOnWriteRecoverableError write FOnWriteRecoverableError;
   property OnNewModuleData : TSendModuleData read FOnSendModuleData write FOnSendModuleData;
   property OnValueReadFromPLC : TValueReadFromPLC read FOnValueReadFromPLC write FOnValueReadFromPLC;
 end; // TMicroLogixPLC

//procedure Register;

implementation
{_R MicroLogixComms.dcr}

uses Dialogs, Math, TMSIStrFuncs;

var
  UsingWriteStack : LongInt;
  UsingReadStack  : LongInt;

//procedure Register;
//begin
//  RegisterComponents('TMSI', [TMicroLogixPLC]);
//end;

procedure TPLCWatchDogThread.DoSendWatchDogToggle;
begin
  if Assigned(FPLCWriteThread) then
  begin
    if FWatchDogEnabled then
    begin
      FPLCWriteThread.WriteBitToPLC('B3',FWatchDogWordNum,FWatchDogBit,1,FWatchDogValue);
      FWatchDogValue := Not FWatchDogValue;
    end; // If
  end; // If
end; // TPLCWatchDogThread.DoSendWatchDogToggle

procedure TPLCWatchDogThread.Execute;
begin
  while Not Terminated do
  begin
    Sleep(FSleepInterval);
    {$ifndef NOPLC}
    if Not Terminated then
      DoSendWatchDogToggle;
    {$endif}
  end; // While
end; // TPLCWatchDogThread.Execute

constructor TPLCWatchDogThread.Create(Var ParentThread : TPLCWriteThread);
begin
  inherited Create(True);
  FPLCWriteThread := ParentThread;
  FWatchDogValue := False;
  FWatchDogBit := 0;
  FWatchDogWordNum := 0;
  FSleepInterval := 1000;
  FWatchDogEnabled := False;
end; // TPLCWatchDogThread.Create

destructor TPLCWatchDogThread.Destroy;
begin
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread := Nil;
  inherited Destroy;
end; // TPLCWatchDogThread.Destroy

procedure TPLCReadThread.SetModules(Modules : TModuleArray);
var
  i : Integer;
begin
  for i := Low(Modules) to High(Modules) do
    FModules[i] := Modules[i];
  FModulesLoaded := True;
end; // TPLCReadThread.SetModules

function TPLCReadThread.GetModules : TModuleArray;
begin
  Result := FModules;
end; // TPLCReadThread.GetModules

procedure TPLCReadThread.SetModuleTypes(ModuleTypes : TModuleType);
var
  i : Integer;
begin
  for i := Low(ModuleTypes) to High(ModuleTypes) do
    FModuleType[i] := ModuleTypes[i]
end; // TPLCReadThread.SetModuleTypes

function TPLCReadThread.GetModuleTypes;
begin
  Result := FModuleType;
end; // TPLCReadThread.GetModuleTypes

procedure TPLCReadThread.SetReadIPAddress(Value : ShortString);
begin
  if Assigned(FPLCRead) then
  begin
    FReadIPAddress := Value;
    FPLCRead.Host := FReadIPAddress;
  end; // If
end; // If

procedure TPLCReadThread.DoReadErrorEvent;
var
  PacketRec : TPLCWritePacketRecord;
begin
  if Assigned(PLCMonitor.OnReadError) then
  begin
    FillChar(PacketRec,SizeOf(PacketRec),#0);
    with PacketRec do
    begin
      case FReadState of
        0 : begin
              FileType := 'N7';
              Size := FDataReadSize;
            end; // 0
        1 : begin
              FileType := 'S';
              Size := FStatusReadSize;
            end; // 3
      end; // Case
    end; // With
    PLCMonitor.OnReadError(Self,FReadErrorNum,FReadErrorStr,PacketRec,FReadFault);
  end; // If
end; // TPLCReadThread.DoReadErrorEvent

procedure TPLCReadThread.SetReadEnabled(Value : Boolean);
begin
  if Assigned(FPLCRead) then
  begin
    FReadEnabled := Value;
    PrimePLCForNextRead(FReadState);
    FPLCRead.Enabled := FReadEnabled;
  end; // If
end; // TPLCReadThread.SetReadEnabled

destructor TPLCReadThread.Destroy;
var
  ReadPacket : TPLCReadPacket;
begin
  if Assigned(FPLCRead) then
  begin
    FPLCRead.Enabled := False;
    FPLCRead.Free;
    FPLCRead := Nil;
  end; // If
  if FReadStack.Count > 0 then
  begin
    repeat
      ReadPacket := FReadStack.Objects[0] as TPLCReadPacket;
      ReadPacket.Free;
      ReadPacket := Nil;
      FReadStack.Delete(0);
    until FReadStack.Count = 0;
  end; // If
  FReadStack.Free;
  FReadStack := Nil;
  inherited Destroy;
end; // TPLCReadThread.Destroy

constructor TPLCReadThread.Create(Var lParent : TMicroLogixPLC);
begin
  inherited Create(True);
  PLCMonitor := lParent;
  FSleepTime := 1;
  FModuleCount := 0;
  FillChar(FModuleType,SizeOf(FModuleType),#0);
  FillChaR(FModules,SizeOf(FModules),#0);
  FillChar(FDataBits,SizeOf(FDataBits),#0);
  FillChar(FStatusBits, SizeOf(FStatusBits), #0);
  FillChar(FDataWords,SizeOf(FDataWords),#0);
  FillChar(FStatusWords, SizeOf(FStatusWords), #0);
  FReadFault := False;
  FDataFile := 'N7';
  FStatusFile := 'S';
  FReadIPAddress := '';
  FStatusReadSize := 0;
  FReadState := 0;
  FNewDataReady := False;
  FReadErrorNum := 0;
  FReadErrorStr := '';
  FReadEnabled := False;
  FReadIPAddress := '0.0.0.0';
  FModulesLoaded := False;
  FReadStack := TStringList.Create;
  FReadStack.Clear;
  FProcessReadPacket := False;
  FillChar(FReadPacketRec,SizeOf(FReadPacketRec),#0);
  FReadFaultTol := 4;
  FReadFaultCount := 0;
  FPacketQueLength := 0;
  FPLCRead := nil;
  {$IFNDEF NOPLC}
  FPLCRead := TABCTL.Create(Nil);
  with FPLCRead do
  begin
    Adapter      := 0;
    Enabled      := False;
    Function_    := 0;
    FileAddr     := 'N7';
    Size         := 1;
    Timeout      := 1000{ms};
    OnErrorEvent := PLCReadErrorEvent;
    OnReadDone   := PLCReadReadDone
  end; // With
  {$ENDIF}
end; // TPLCReadThread.Create

function TPLCReadThread.GetSleepTime : LongInt;
begin
  Result := FSleepTime * 2;
end; // TPLCReadThread.GetSleepTime

procedure TPLCReadThread.SetSleepTime(Value : LongInt);
begin
  FSleepTime := Trunc(Value / 2);
  if (FSleepTime = 0) then
    FSleepTime := 1;
end; // TPLCReadThread.SetSleepTime

procedure TPLCReadThread.DoReadPacket;
var
  ReadPacket : TPLCReadPacket;
begin
  if Assigned(FReadStack) then
  begin
    FPacketQueLength := FReadStack.Count;
    if (FPacketQueLength > 0) then
    begin
      if Terminated then
        Exit;
      ReadPacket := FReadStack.Objects[0] as TPLCReadPacket;
      if Assigned(ReadPacket) then
      begin
        FProcessReadPacket := True;
        ReadPacket.TransactionPhase := 1;
        with FReadPacketRec do
        begin
          Size := ReadPacket.Size;
          FileType := ReadPacket.FileType;
          WordNumber := ReadPacket.WordNumber;
          BitPosition := ReadPacket.BitPosition;
          ReadBit := ReadPacket.ReadBit;
          ReadWord := ReadPacket.ReadWord;
          TransactionPhase := ReadPacket.TransactionPhase;
        end; // With
        with FPLCRead do
        begin
          Size := ReadPacket.Size;
          FileAddr := format('%s:%d',[ReadPacket.FileType,ReadPacket.WordNumber]);
          if Not Terminated and Not FReadFault then
            Trigger;
        end; // With
        ReadPacket := Nil;
      end; // If
    end; // If
  end; // If
end; // TPLCReadThread.DoReadPacket

procedure TPLCReadThread.DoReadFromPLC;
begin
  if Not Terminated then
  begin
    {$ifndef NOPLC}
    if Assigned(FPLCRead) then
    begin
      if FPLCRead.Enabled then
      begin
        if Not FReadFault then
        begin
          if Not FPLCRead.Busy then
            FPLCRead.Trigger;
        end; // If
      end; // If
    end; // If
    {$endif}
  end; // If
end; // TPLCReadThread.DoReadFromPLC

procedure TPLCReadThread.Execute;
begin
  repeat
    {$ifndef NOPLC}
    if Assigned(FPLCRead) then
    begin
      if Get_ThreadReadStackAccess(1000{ms}) then
      begin
        DoReadPacket;
        Release_ThreadReadStackAccess;
      end; // If
      DoReadFromPLC;
      if Not Terminated and FNewDataReady then
        PopulateModules;
    end; // If
    {$endif}
    if Not Terminated then
      Sleep(FSleepTime);
  until Terminated;
end; // TPLCReadThread.Execute

procedure TMicroLogixPLC.SetWatchDogWordNumber(Value : Integer);
begin
  FWatchDogWordNumber := Value;
  if Assigned(FPLCWatchDogThread) then
    FPLCWatchDogThread.WatchDogWordNum := FWatchDogWordNumber;
end; // TMicroLogixPLC.SetWatchDogWordNumber

procedure TMicroLogixPLC.SetWatchDogBitNumber(Value : Integer);
begin
  FWatchDogBitNumber := Value;
  if Assigned(FPLCWatchDogThread) then
    FPLCWatchDogThread.WatchDogBitNum := FWatchDogBitNumber;
end; // TMicroLogixPLC.SetWatchDogBitNumber

function TMicroLogixPLC.WriteWordToPLC(pFile : Shortstring; pWordNumber : integer; intSize : integer; Value : SmallInt) : Boolean;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteWordToPLC(pFile,pWordNumber,intSize,Value)
  else
    Result := False;
end; // TMicroLogixPLC.WriteWordToPLC

function TMicroLogixPLC.WriteBitToPLC(pFile : Shortstring; pWordNumber : integer; BitNumber : integer; intSize : integer; Value : boolean) : Boolean;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteBitToPLC(pFile,pWordNumber,BitNumber,intSize,Value)
  else
    Result := False;
end; // TMicroLogixPLC.WriteBitToPLC

function TMicroLogixPLC.GetReadIPAddress : ShortString;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadIPAddress
  else
    Result := FReadIPAddress;
end; // TMicroLogixPLC.GetReadIPAddress

procedure TMicroLogixPLC.SetReadIPAddress(Value : ShortString);
begin
  if ValidIPAddress(Value) then
  begin
    FReadIPAddress := Value;
  end
  else
    DoConfigurationError(3,'Attempted to apply invalid read IP address.');
  if Assigned(FPLCReadThread) then
      FPLCReadThread.ReadIPAddress := Value
end; // TMicroLogixPLC.SetReadIPAddress

Constructor TMicroLogixPLC.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FEnabled := False;
  FWatchDogActive := False;
  FWatchDogWordNumber := 0;
  FWatchDogBitNumber := 0;
  FWatchDogInterval := 1000;
  FWatchDogValue := False;
  FThreadsStarted := False;
  FModuleCount := 0;
  FModulesPresent := False;
  FConfigurationFile := '';
  FillChar(ModuleType,SizeOf(ModuleType),#0);
  FVersion := '2.0.1';
  FReadInterval := 100;
  FBinaryReadSize := 3;
  FDataReadSize := 40;
  FStatusSize := 66;
  FDataFile := 'N7';
  FWatchDogTimeOut := 0;
  FWatchDogHi := '';
  FWatchDogLo := '';
  FReadIPAddress := '0.0.0.0';
  FWriteIPAddress := '0.0.0.0';
  FReadAdapterNum := 0;
  FWriteAdapterNum := 0;
  FReadFaultTollerance := 0;
  FWriteFaultTollerance := 0;
  FEthernetTimeOut := 1000{ms};
  FEmbededIOResolution := 4096;
//  FExpandedIOResolution := 32760;
  FExpandedIOResolution := 30389;
  FWriteWaitTimeOut := 1000{ms};
  {$IFNDEF NOPLC}
  if not (csDesigning in ComponentState) then
  begin
    FPLCReadThread := TPLCReadThread.Create(Self);
    FPLCWriteThread := TPLCWriteThread.Create(Self);
    FPLCWatchDogThread := TPLCWatchDogThread.Create(FPLCWriteThread);
  end; // If
  {$ELSE}
    FPLCReadThread := Nil;
    FPLCWriteThread := Nil;
    FPLCWatchDogThread := Nil;
  {$ENDIF}
end; // TMicroLogixPLC.Create

Destructor TMicroLogixPLC.Destroy;
begin
  {$IFNDEF NOPLC}
  if not (csDesigning in ComponentState) then
  begin
    SavePLCConfiguration(FConfigurationFile);
    if FThreadsStarted then
    begin
      FPLCWatchDogThread.Terminate;
      FPLCReadThread.Terminate;
      FPLCWriteThread.Terminate;
    end; // If
    FPLCReadThread.Free;
    FPLCWatchDogThread.Free;
    FPLCWriteThread.Free;
    FPLCWatchDogThread := Nil;
    FPLCReadThread := Nil;
    FPLCWriteThread := Nil;
  end; // If
  {$ENDIF}
  inherited Destroy;
end; // TMicroLogixPLC.Destroy

procedure TPLCWriteThread.SetIPAddress(Value : ShortString);
begin
  if Assigned(FPLCWrite) then
  begin
    FWriteIPAddress := Value;
    FPLCWrite.Host := FWriteIPAddress;
  end; // If
end; // TPLCWriteThread.SetIPAddress

procedure TPLCWriteThread.SetWriteEnabled(Value : Boolean);
begin
  if Assigned(FPLCWrite) then
  begin
    FWriteEnabled := Value;
    FPLCWrite.Enabled := FWriteEnabled;
  end; // If
end; // TPLCWriteThread.SetEnabled

destructor TPLCWriteThread.Destroy;
var
  TransmitPacket : TPLCWritePacket;
begin
  if Assigned(FPLCWrite) then
  begin
    FPLCWrite.Enabled := False;
    FPLCWrite.Free;
    FPLCWrite := Nil;
  end; // If
  if FWriteStack.Count > 0 then
  begin
    repeat
      TransmitPacket := FWriteStack.Objects[0] as TPLCWritePacket;
      TransmitPacket.Free;
      TransmitPacket := Nil;
      FWriteStack.Delete(0);
    until FWriteStack.Count = 0;
  end; // If
  FWriteStack.Free;
  FWriteStack := Nil;
  inherited Destroy;
end; // TPLCWriteThread.Destroy

constructor TPLCWriteThread.Create(Var lParent : TMicroLogixPLC);
begin
  inherited Create(True);
  PLCMonitor := lParent;
  FWriteEnabled := False;
  FillChar(FLastPacketWritten,SizeOf(FLastPacketWritten),#0);
  Fillchar(FLastPacketWithError,SizeOf(FLastPacketWithError),#0);
  FWriteStack := TStringList.Create;
  FWriteStack.Clear;
  FWriteErrorNum := 0;
  FWriteErrorStr := '';
  FWriteIPAddress := '0.0.0.0';
  FWriteFaultTol := 1;
  FWriteFaultCount := 0;
  FPacketQueLength := 0;
  FWriteAttemptsBeforeFail := 0;
  FThreadRunning := False;
  FWriteWaitTimeOut := 1000{ms};
  FPLCWrite := nil;
  {$IFNDEF NOPLC}
  FPLCWrite := TABCTL.Create(Nil);
  with FPLCWrite do
  begin
    Adapter          := 0;
    Enabled          := False;
    Function_        := 1;
    FileAddr         := 'N7:0';
    Size             := 1;
    TimeOut          := 1000{ms};
    OnErrorEvent     := PLCWriteErrorEvent;
    OnWriteDone      := PLCWriteWriteDone;
  end; // With
  {$ENDIF}
end; // TPLCWriteThread.Create

procedure TPLCWriteThread.DoWriteErrorEvent;
begin
  if Assigned(PLCMonitor.OnWriteError) then
    PLCMonitor.OnWriteError(Self,FWriteErrorNum,FWriteErrorStr,FLastPacketWritten,FWriteFault);
end; // TPLCWriteThread.DoWriteErrorEvent

procedure TPLCWriteThread.DoTransmitPacket;
var
  TransmitPacket : TPLCWritePacket;
  lAddress : ShortString;
begin
  if Not Terminated then
  begin
    if Assigned(FPLCWrite) then
    begin
      FPacketQueLength := FWriteStack.Count;
      if (FPacketQueLength > 0) then
      begin
        repeat
          if Not FPLCWrite.Busy then
          begin
            FillChar(FLastPacketWritten,SizeOf(FLastPacketWritten),#0);
            TransmitPacket := FWriteStack.Objects[0] as TPLCWritePacket;
            if ValidatePacket(TransmitPacket) then
            begin
              if (TransmitPacket.TransactionPhase = 1) then
                TransmitPacket.TransactionPhase := 2;
              FLastPacketWritten.FileType := TransmitPacket.FileType;
              FLastPacketWritten.Size := TransmitPacket.Size;
              FLastPacketWritten.WordNumber := TransmitPacket.WordNumber;
              FLastPacketWritten.BitPosition := TransmitPacket.BitPosition;
              FLastPacketWritten.WriteBit := TransmitPacket.WriteBit;
              FLastPacketWritten.WriteWord := TransmitPacket.WriteWord;
              FLastPacketWritten.BitToWrite := TransmitPacket.BitToWrite;
              FLastPacketWritten.WordToWrite := TransmitPacket.WordToWrite;
              FLastPacketWritten.TransactionPhase := TransmitPacket.TransactionPhase;
              if FPLCWrite.Enabled then
              begin
                if TransmitPacket.WriteBit then
                  lAddress := format('%s:%d/%d',[TransmitPacket.FileType,TransmitPacket.WordNumber,TransmitPacket.BitPosition])
                else
                  lAddress := format('%s:%d',[TransmitPacket.FileType,TransmitPacket.WordNumber]);
                FPLCWrite.Size := TransmitPacket.Size;
                FPLCWrite.FileAddr := lAddress;
                if TransmitPacket.WriteBit then
                  FPLCWrite.WordVal[0] := ord(TransmitPacket.BitToWrite)
                else
                  FPLCWrite.WordVal[0] := TransmitPacket.WordToWrite;
                if Not Terminated and Not FWriteFault then
                  FPLCWRite.Trigger;
              end; // If
            end; // If
            if Assigned(TransmitPacket) then
            begin
              if (TransmitPacket.TransactionPhase <> 3) or (TransmitPacket.TransmitAttempts = FWriteAttemptsBeforeFail) then
              begin
                TransmitPacket.Free;
              end
              else
              begin // Put Packet back at the top to try again later...
                TransmitPacket.TransmitAttempts := TransmitPacket.TransmitAttempts + 1;
                FWriteStack.AddObject(IntToStr(FWriteStack.Count),TransmitPacket); // Add to top of write stack.
              end; // If
            end; // If
            TransmitPacket := Nil;
            FWriteStack.Delete(0);
          end; // If
        until Terminated or (FWriteStack.Count = 0);
      end; // If
    end; // If
  end; // if
end; // TPLCWriteThread.DoTransmitPacket

function TPLCWriteThread.ValidatePacket(lPacket : TPLCWritePacket) : boolean;
begin
  Result := False;
  if Assigned(lPacket) then
  begin
    if (lPacket.Size > 0) and (lPacket.FileType <> '') and (lPacket.WriteBit or lPacket.WriteWord) then
    begin
      lPacket.TransactionPhase := 1;
      Result := True;
    end; // If
  end
  else
  begin
    Result := False;
  end; // If
end; // TPLCWriteThread.ValidatePacket

procedure TPLCWriteThread.Execute;
begin
  repeat
    {$ifndef NOPLC}
    if Get_ThreadWriteStackAccess(FWriteWaitTimeOut) then
    begin
      DoTransmitPacket;
      Release_ThreadWriteStackAccess;
    end; // If
    {$endif}
    if Not Terminated then
      Sleep(10);
  until Terminated;
end; // TPLCWriteThread.Execute

Constructor TPLCReadPacket.Create;
begin
  inherited Create;
  Size := 0;
  FileType := '';
  WordNumber := 0;
  BitPosition := 0;
  ReadBit := False;
  REadWord := False;
  BitRead := False;
  WordRead := 0;
  TransactionPhase := -1;
end; // TPLCReadPacket.Create

Constructor TPLCWritePacket.Create;
begin
  inherited Create;
  FSize := 0;
  FFileType := '';
  FWordNumber := 0;
  FBitPosition := 0;
  FWriteBit := False;
  FWriteWord := False;
  FBitToWrite := False;
  FWordToWrite := 0;
  FTransactionPhase := -1;
  FTransmitAttempts := 0;
end; // TPLCWritePacket

constructor TBaseModule.Create;
begin
  inherited Create;
  FModuleNumber := 0;
  FModuleType := 0;
  FModuleError := False;
  FillChar(FModuleWords,SizeOf(FModuleWords),#0);
end; // TBaseModule.Create

constructor TBaseAnalogModule.Create;
begin
  inherited Create;
  FillChar(FChannelDataValue,SizeOf(FChannelDataValue),#0);
  FillChar(FChannelStatus,SizeOf(FChannelStatus),#0);
  FillChar(FChannelOverRangeFlag,SizeOf(FChannelOverRangeFlag),#0);
  FillChar(FChannelUnderRangeFlag,SizeOf(FChannelUnderRangeFlag),#0);
end; // TBaseAnalogModule.Create

procedure TBaseAnalogModule.SetChannelDataValue(Channel : Byte; Value : LongInt);
begin
  if (Channel in [Low(FChannelDataValue)..High(FChannelDataValue)]) then
    FChannelDataValue[Channel] := Value;
end; // TBaseAnalogModule.SetChannelDataValue

function TBaseAnalogModule.GetChannelDataValue(Channel : Byte) : LongInt;
begin
  if (Channel in [Low(FChannelDataValue)..High(FChannelDataValue)]) then
    Result := FChannelDataValue[Channel]
  else
    Result := 0;
end; // TBaseAnalogModule.GetChannelDataValue

procedure TBaseAnalogModule.SetChannelStatus(Channel : Byte; Value : Boolean);
begin
  if (Channel in [Low(FChannelStatus)..High(FChannelStatus)]) then
    FChannelStatus[Channel] := Value;
end; // TBaseAnalogModule.SetChannelStatus

function TBaseAnalogModule.GetChannelStatus(Channel : Byte) : Boolean;
begin
  if (Channel in [Low(FChannelStatus)..High(FChannelStatus)]) then
    Result := FChannelStatus[Channel]
  else
    Result := False;
end; // TBaseAnalogModule.GetChannelStatus

procedure TBaseAnalogModule.SetChannelORFlag(Channel : Byte; Value : Boolean);
begin
  if (Channel in [Low(FChannelOverRangeFlag)..High(FChannelOverRangeFlag)]) then
    FChannelOverRangeFlag[Channel] := Value;
end; // TBaseAnalogModule.SetChannelORFlag

function TBaseAnalogModule.GetChannelORFlag(Channel : Byte) : Boolean;
begin
  if (Channel in [Low(FChannelOverRangeFlag)..High(FChannelOverRangeFlag)]) then
    Result := FChannelOverRangeFlag[Channel]
  else
    Result := False;
end; // TBaseAnalogModule.GetChannelORFlag

procedure TBaseAnalogModule.SetChannelURFlag(Channel : Byte; Value : Boolean);
begin
  if (Channel in [Low(FChannelUnderRangeFlag)..High(FChannelUnderRangeFlag)]) then
    FChannelUnderRangeFlag[Channel] := Value;
end; // TBaseAnalogModule.SetChannelURFlag

function TBaseAnalogModule.GetChannelURFlag(Channel : Byte) : Boolean;
begin
  if (Channel in [Low(FChannelUnderRangeFlag)..High(FChannelUnderRangeFlag)]) then
    Result := FChannelUnderRangeFlag[Channel]
  else
    Result := False;
end; // TBaseAnalogModule.GetChannelURFlag

constructor TRTDAnalogInputModule.Create;
begin
  inherited Create;
  FillChar(FChannelOpenCircuitFlag,SizeOf(FChannelOpenCircuitFlag),#0);
end; // TBaseRTDAnalogInputModule.Create

procedure TRTDAnalogInputModule.SetChannelOCFlag(Channel : Byte; Value : Boolean);
begin
  if (Channel in [Low(FChannelOpenCircuitFlag)..High(FChannelOpenCircuitFlag)]) then
    FChannelOpenCircuitFlag[Channel] := Value;
end; // TBaseAnalogModule.SetChannelURFlag

function TRTDAnalogInputModule.GetChannelOCFlag(Channel : Byte) : Boolean;
begin
  if (Channel in [Low(FChannelOpenCircuitFlag)..High(FChannelOpenCircuitFlag)]) then
    Result := FChannelOpenCircuitFlag[Channel]
  else
    Result := False;
end; // TBaseAnalogModule.GetChannelURFlag

procedure TBaseModule.SetModuleWord(HiIndex : LongInt; LowIndex : LongInt; Value : LongInt);
begin
  if (HiIndex in [Low(FModuleWords)..High(FModuleWords)]) then
  begin
    if (LowIndex in [Low(FModuleWords[HiIndex])..High(FModuleWords[HiIndex])]) then
      FModuleWords[HiIndex,LowIndex] := Value;
  end; // If
end; // TBaseModule.SetModuleWord

function TBaseModule.GetModuleWord(HiIndex : LongInt; LowIndex : LongInt) : LongInt;
begin
  Result := 0;
  if (HiIndex in [Low(FModuleWords)..High(FModuleWords)]) then
  begin
    if (LowIndex in [Low(FModuleWords[HiIndex])..High(FModuleWords[HiIndex])]) then
      Result := FModuleWords[HiIndex,LowIndex];
  end; // If
end; // TBaseModule.GetModuleWord

Constructor TPLCMainModule.Create;
begin
  inherited Create;
  FMajorErrorCode := 0;
  FProcessorMode := 0;
  FKeySwitchPos := 0;
  FForcedIO := False;
  FControlRegisterError := False;
  FBatteryOK := False;
  FMajorErrorHalt := False;
  FillChar(FDigitalInputModuleWords,SizeOf(FDigitalInputModuleWords),#0);
  FillChar(FDigitalOutputModuleWords,SizeOf(FDigitalOutputModuleWords),#0);
  FillChar(FAnalogInputModuleWords,SizeOf(FAnalogInputModuleWords),#0);
  FillChar(FAnalogOutputModuleWords,SizeOf(FAnalogOutputModuleWords),#0);
  FillChar(FDigitalInputData,SizeOf(FDigitalInputData),#0);
  FillChar(FAnalogInputData,SizeOf(FAnalogInputData),#0);
  FillChar(FDigitalOutputData,SizeOf(FDigitalOutputData),#0);
  FillChar(FAnalogOutputData,SizeOf(FAnalogOutputData),#0);
end; // TPLCMainModule.Create

function TPLCMainModule.FindModuleWord(HiIndex : LongInt; LowIndex : LongInt; Item : Byte) : LongInt;
begin
  Result := 0;
  if (HiIndex in [Low(FDigitalInputModuleWords)..High(FDigitalInputModuleWords)]) then
  begin
    if (LowIndex in [Low(FDigitalInputModuleWords[HiIndex])..High(FDigitalInputModuleWords[HiIndex])]) then
    begin
      case Item of
        0 : Result := FDigitalInputModuleWords[HiIndex,LowIndex];
        1 : Result := FDigitalOutputModuleWords[HiIndex,LowIndex];
        2 : Result := FAnalogInputModuleWords[HiIndex,LowIndex];
        3 : Result := FAnalogOutputModuleWords[HiIndex,LowIndex];
        4 : Result := FRequestBits_ModuleWords[HiIndex,LowIndex];
      end; // Case
    end; // If
  end; // If
end; // TPLCMainModule.FindModuleWord

procedure TPLCMainModule.SetModuleWord(HiIndex : LongInt; LowIndex : LongInt; Item : Byte; Value : LongInt);
begin
  if (HiIndex in [Low(FDigitalInputModuleWords)..High(FDigitalInputModuleWords)]) then
  begin
    if (LowIndex in [Low(FDigitalInputModuleWords[HiIndex])..High(FDigitalInputModuleWords[HiIndex])]) then
    begin
      case Item of
        0 : FDigitalInputModuleWords[HiIndex,LowIndex] := Value;
        1 : FDigitalOutputModuleWords[HiIndex,LowIndex] := Value;
        2 : FAnalogInputModuleWords[HiIndex,LowIndex] := Value;
        3 : FAnalogOutputModuleWords[HiIndex,LowIndex] := Value;
        4 : FRequestBits_ModuleWords[HiIndex,LowIndex] := Value;
      end; // Case
    end; // If
  end; // If
end; // TPLCMainModule.SetModuleWord

procedure TPLCMainModule.SetDigInputModuleWord(HiIndex : LongInt; LowIndex : LongInt; Value : LongInt);
begin
  SetModuleWord(HiIndex,LowIndex,0,Value);
end; // TPLCMainModule.SetDigInputModuleWord

function TPLCMainModule.GetDigInputModuleWord(HiIndex : LongInt; LowIndex : LongInt) : LongInt;
begin
  Result := FindModuleWord(HiIndex,LowIndex,0);
end; // TPLCMainModule.GetDigInputModuleWord

procedure TPLCMainModule.SetDigOutputModuleWord(HiIndex : LongInt; LowIndex : LongInt; Value : LongInt);
begin
  SetModuleWord(HiIndex,LowIndex,1,Value);
end; // TPLCMainModule.SetDigOutputModuleWord

function TPLCMainModule.GetDigOutputModuleWord(HiIndex : LongInt; LowIndex : LongInt) : LongInt;
begin
  Result := FindModuleWord(HiIndex,LowIndex,1);
end; // TPLCMainModule.GetDigOutputModuleWord

procedure TPLCMainModule.SetAnalogInputModuleWord(HiIndex : LongInt; LowIndex : LongInt; Value : LongInt);
begin
  SetModuleWord(HiIndex,LowIndex,2,Value);
end; // TPLCMainModule.SetAnalogInputModuleWord

function TPLCMainModule.GetAnalogInputModuleWord(HiIndex : LongInt; LowIndex : LongInt) : LongInt;
begin
  Result := FindModuleWord(HiIndex,LowIndex,2);
end; // TPLCMainModule.GetAnalogInputModuleWord

procedure TPLCMainModule.SetAnalogOutputModuleWord(HiIndex : LongInt; LowIndex : LongInt; Value : LongInt);
begin
  SetModuleWord(HiIndex,LowIndex,3,Value);
end; // TPLCMainModule.SetAnalogOutputModuleWord

function TPLCMainModule.GetAnalogOutputModuleWord(HiIndex : LongInt; LowIndex : LongInt) : LongInt;
begin
  Result := FindModuleWord(HiIndex,LowIndex,3);
end; // TPLCMainModule.GetAnalogOutputModuleWord

procedure TPLCMainModule.SetRequestBitsModuleWord(HiIndex : LongInt; LowIndex : LongInt; Value : LongInt);
begin
  SetModuleWord(HiIndex,LowIndex,4,Value);
end; // TPLCMainModule.SetRequestBitsModuleWord

function TPLCMainModule.GetRequestBitsModuleWord(HiIndex : LongInt; LowIndex : LongInt) : LongInt;
begin
  Result := FindModuleWord(HiIndex,LowIndex,4);
end; // TPLCMainModule.GetRequestBitsModuleWord

procedure TPLCMainModule.SetDigitalInputData(InputNum : Byte; Value : TBitArray);
begin
  if (InputNum in [Low(FDigitalInputData)..High(FDigitalInputData)]) then
    FDigitalInputData[InputNum] := Value;
end; // TPLCMainModule.SetDigialInputData

function TPLCMainModule.GetDigitalInputData(InputNum : Byte) : TBitArray;
begin
  FillChar(Result,SizeOf(Result),#0);
  if (InputNum in [Low(FDigitalInputData)..High(FDigitalInputData)]) then
    Result := FDigitalInputData[InputNum];
end; // TPLCMainModule.GetDigitalInputData

procedure TPLCMainModule.SetAnalogInputData(InputNum : Byte; Value : LongInt);
begin
  if (InputNum in [Low(FAnalogInputData)..High(FAnalogInputData)]) then
    FAnalogInputData[InputNum] := Value;
end; // TPLCMainModule.SetAnalogInputData

function TPLCMainModule.GetAnalogInputData(InputNum : Byte) : LongInt;
begin
  FillChar(Result,SizeOf(Result),#0);
  if (InputNum in [Low(FAnalogInputData)..High(FAnalogInputData)]) then
    Result := FAnalogInputData[InputNum];
end; // TPLCMainModule.GetAnalogInputData

procedure TPLCMainModule.SetDigitalOutputData(Output : Byte; Value : TBitArray);
begin
  if (Output in [Low(FDigitalOutputData)..High(FDigitalOutputData)]) then
    FDigitalOutputData[Output] := Value;
end; // TPLCMainModule.SetDigitalOutputData

function TPLCMainModule.GetDigitalOutputData(Output : Byte) : TBitArray;
begin
  FillChar(Result,SizeOf(Result),#0);
  if (Output in [Low(FDigitalOutputData)..High(FDigitalOutputData)]) then
    Result := FDigitalOutputData[Output];
end; // TPLCMainModule.GetDigitalOutputData

procedure TPLCMainModule.SetAnalogOutputData(Output : Byte; Value : LongInt);
begin
  if (Output in [Low(FAnalogOutputData)..High(FAnalogOutputData)]) then
    FAnalogOutputData[Output] := Value;
end; // TPLCMainModule.SetAnalogOutputData

function TPLCMainModule.GetAnalogOutputData(Output : Byte) : LongInt;
begin
  FillChar(Result,SizeOf(Result),#0);
  if (Output in [Low(FAnalogOutputData)..High(FAnalogOutputData)]) then
    Result := FAnalogOutputData[Output];
end; // TPLCMainModule.GetAnalogOutputData

procedure TPLCMainModule.SetRequestBitsStatus(WordNum : Byte; Value : TBitArray);
begin
  if (WordNum in [Low(FRequest_Bits_Status)..High(FRequest_Bits_Status)]) then
    FRequest_Bits_Status[WordNum] := Value;
end; // TPLCMainModule.SetRequestBitsStatus

function TPLCMainModule.GetRequestBitsStatus(WordNum : Byte) : TBitArray;
begin
  FillChar(Result,SizeOf(Result),#0);
  if (WordNum in [Low(FRequest_Bits_Status)..High(FRequest_Bits_Status)]) then
    Result := FRequest_Bits_Status[WordNum];
end; // TPLCMainModule.GetRequestBitsStatus

Constructor TDigitalInputModule.Create;
begin
  inherited Create;
  FModuleNumber := 0;
  FModuleType := 0;
  FModuleError := False;
  FillChar(FModuleWords,SizeOf(FModuleWords),#0);
  FillChar(FDigitalInputData,SizeOf(FDigitalInputData),#0);
end; // TDigitalInputMoodule.Create

Constructor TDigitalOutputModule.Create;
begin
  inherited Create;
  FillChar(FDigitalOutputData,SizeOf(FDigitalOutputData),#0);
end; // TDigitalOutputModule.Create

Constructor TRelayedDigitalOutputModule.Create;
begin
  inherited Create;
  FillChar(FRelayedDigitalOutputData,SizeOf(FRelayedDigitalOutputData),#0);
end; // TRelayedDigitalOutputModule.Create

function TMicroLogixPLC.GetEnabled : boolean;
begin
  if Assigned(FPLCReadThread) and Assigned(FPLCWriteThread) then
    Result := FPLCReadThread.ReadEnabled and FPLCWriteThread.WriteEnabled
  else
    Result := False;
end; // TMicroLogixPLC.GetEnabled

procedure TMicroLogixPLC.SetWriteIPAddress(Value : ShortString);
begin
  if ValidIPAddress(Value) then
  begin
    FWriteIPAddress := Value;
  end
  else
    DoConfigurationError(4,'Attempted to apply invalid write IP address.');
  if Assigned(FPLCWriteThread) then
      FPLCWriteThread.WriteIPAddress := Value
end; // TMicroLogixPLC.SetWriteIPAddress

function TMicroLogixPLC.GetWriteIPAddress : ShortString;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteIPAddress
  else
    Result := FWriteIPAddress;
end; // TMicroLogixPLC.GetWriteIPAddress

procedure TMicroLogixPLC.SetDataSize(Value : DWord);
begin
  FDataReadSize := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.DataReadSize := Value;
end; // TMicroLogixPLC.SetDataSize

function TMicroLogixPLC.GetDataSize : DWord;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.DataReadSize
  else
    Result := FDataReadSize;
end; // TMicroLogixPLC.GetDataSize

procedure TMicroLogixPLC.SetDataFile(Value : ShortString);
begin
  FDataFile := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.DataFile := FDataFile;
end; // TMicroLogixPLC.SetDataFile

function TMicroLogixPLC.GetDataFile : ShortString;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.DataFile
  else
    Result := FDataFile;
end; // TMicroLogixPLC.SetDataFile

procedure TMicroLogixPLC.SetStatusSize(Value : Integer);
begin
  FStatusSize := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.StatusReadSize := Value;
end; // TMicroLogixPLC.SetStatusSize

function TMicroLogixPLC.GetStatusSize : Integer;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.StatusReadSize
  else
    Result := FStatusSize;
end; // TMicroLogixPLC.GetStautsSize

function TMicroLogixPLC.GetWriteFault : Boolean;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteFault
  else
    Result := False;
end; // TMicroLogixPLC.GetWriteFault

function TMicroLogixPLC.GetWriteWaitTimeOut :  DWord;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteWaitTimeOut_ms
  else
    Result := FWriteWaitTimeOut;
end; // TMicroLogixPLC.GetWriteWaitTimeOut

procedure TMicroLogixPLC.SetWriteWaitTimeOut(Value : DWord);
begin
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteWaitTimeOut_ms := Value;
end; // TMicroLogixPLC.SetWriteWaitTimeOut

function TMicroLogixPLC.GetReadFault : Boolean;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCReadThread.ReadFault
  else
    Result := False;
end; // TMicroLogixPLC.GetReadFault

procedure TMicroLogixPLC.SetEnabled(Value : Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    FPLCReadThread.ReadEnabled := FEnabled;
    FPLCWriteThread.WriteEnabled := FEnabled;
    FPLCWatchDogThread.WatchDogEnabled := FEnabled and FWatchDogActive;
    if FEnabled and Not FThreadsStarted then
    begin
      FPLCReadThread.Start;
      FPLCWriteThread.Start;
      FPLCWatchDogThread.Start;
      FThreadsStarted := True;
    end; // If
    if FEnabled then
    begin
      InitializePLC;
      SetReadInterval(FReadInterval);
    end; // If
  end; // If
end; // TMicroLogixPLC.SetEnabled

function TMicroLogixPLC.ValidIPAddress(Value : ShortString) : Boolean;
var
  i : integer;
  IP1 : ShortString;
  IP2 : ShortString;
  IP3 : ShortString;
  IP4 : ShortString;
  TMP : ShortString;
  DotCount : integer;
  DotPos : Array[0..2] of integer;
  ErrorCount : integer;
begin
  DotCount := 0;
  ErrorCount := 0;
  Result := False;
  for i := 1 to Length(Value) do
  begin
    if Value[i] = '.' then
    begin
      DotPos[DotCount] := i;
      inc(DotCount);
    end; // If
  end; // for i
  if DotCount = 3 then
  begin
    for i := 0 to 3 do
    begin
      if i = 0 then
        TMP := copy(Value,0,Pos('.',Value) - 1)
      else
        if i < 3 then
          TMP := copy(Value,DotPos[i - 1] + 1,(DotPos[i] - DotPos[i - 1]) - 1)
        else
          TMP := copy(Value,DotPos[i -1] + 1, Length(Value) - DotPos[i - 1]);
      if StrToInt(TMP) < 257 then
      begin
        case i of
          0 : IP1 := TMP;
          1 : IP2 := TMP;
          2 : IP3 := TMP;
          3 : IP4 := TMP;
        end; // Case
      end
      else
      begin
        inc(ErrorCount);
      end; // If
    end; // for i
    if ErrorCount > 0 then
      Result := False
    else
      Result := True;
  end; // If
end; // TMicroLogixPLC.SetPLCIPAddress

procedure TPLCReadThread.PLCReadReadDone(Sender : TObject);
var
  i, j : integer;
  lBoolean : boolean;
  ReadPacket : TPLCReadPacket;
begin
  FReadFaultCount := 0;
  if FProcessReadPacket then
  begin
    ReadPacket := FReadStack.Objects[0] as TPLCReadPacket;
    if Assigned(ReadPacket) then
    begin
      ReadPacket.TransactionPhase := 2;
      with FReadPacketRec do
      begin
        Size        := ReadPacket.Size;
        FileType    := ReadPacket.FileType;
        WordNumber  := ReadPacket.WordNumber;
        BitPosition := ReadPacket.BitPosition;
        ReadBit     := ReadPacket.ReadBit;
        ReadWord    := ReadPacket.ReadWord;
        BitRead     := FPLCRead.BitVal[0{ReadPacket.WordNumber},ReadPacket.BitPosition];
        WordRead    := FPLCRead.WordVal[0{ReadPacket.WordNumber}];
        TransactionPhase := ReadPacket.TransactionPhase;
      end; // With
      ReadPacket.Free;
      ReadPacket := Nil;
      FReadStack.Delete(0);
      FProcessReadPacket := False;
      Synchronize(DoReturnValueFromPLC);
      PrimePLCForNextRead(FReadState);
    end; // If
  end
  else
  begin
    case FReadState of
      0 : begin // Read Status bits
            FillChar(FStatusWords,SizeOf(FStatusWords),#0);
            FillChar(FStatusBits,SizeOf(FStatusBits),#0);
            for i := 0 to (FStatusReadSize - 1) do
            begin
              FStatusWords[i] := FPLCRead.WordVal[i];
              for j := 0 to 15 do
              begin
                lBoolean := Ord(FPLCRead.BitVal[i,j]) <> 0;
                FStatusBits[i,j] := lBoolean;
              end; // for j
            end; // for i
          end; // 1
      1 : begin // Read Data bits
            FillChar(FDataWords,Sizeof(FDataWords),#0);
            FillChar(FDataBits,SizeOf(FDataBits),#0);
            for i := 0 to (FDataReadSize - 1) do
            begin
              FDataWords[i] := FPLCRead.WordVal[i];
              for j := 0 to 15 do
                FDataBits[i,j] := ((FPLCRead.WordVal[i] shr j) and 1) = 1;
            end; // for i
            FNewDataReady := True;            
          end; // 0
    end; // Case
    if FReadState < 1 then
      inc(FReadState)
    else
      FReadState := 0;
    PrimePLCForNextRead(FReadState);
  end; // If
end;// TMicroLogixPLC.PLCReadReadDone

procedure TPLCReadThread.PLCReadErrorEvent(Sender :TObject; nErrorCode : TintErrorCode);
var
  Msg : ShortString;
  ReadPacket : TPLCReadPacket;
begin
  case nErrorCode of
    // ----------------- INGEAR COMPONENT ERROR MESSAGES -------------------------
    {$IFDEF INGEAR_Version_52}
    -32768 : msg := 'IN-GEAR Says: compatability mode file missing.';
    -28672 : msg := 'IN-GEAR Says: Remote node cannot buffer command';
    -20480 : msg := 'IN-GEAR Says: Remote node problem due to download.';
    -16284 : msg := 'IN-GEAR Says: Cannot execute due to active IPBS.';
    -4095  : msg := 'IN-GEAR Says: A field has an illegal value.';
    -4094  : msg := 'IN-GEAR Says: Less levels specified in adddress than minimum for any address.';
    -4093  : msg := 'IN-GEAR Says: More levels specified in address than system supports.';
    -4092  : msg := 'IN-GEAR Says: Symbol not found.';
    -4091  : msg := 'IN-GEAR Says: Symbol is not proper format.';
    -4090  : msg := 'IN-GEAR Says: File address doesn''t point to something useful.';
    -4089  : msg := 'IN-GEAR Says: File is wrong size.';
    -4088  : msg := 'IN-GEAR Says: Cannot complete request.';
    -4087  : msg := 'IN-GEAR Says: Data or file is too large.';
    -4086  : msg := 'IN-GEAR Says: Transaction plus word size is too large.';
    -4085  : msg := 'IN-GEAR Says: Access Denied.';
    -4084  : msg := 'IN-GEAR Says: Condition cannot be generated.';
    -4083  : msg := 'IN-GEAR Says: Condition already exists.';
    -4082  : msg := 'IN-GEAR Says: Command cannot be executed.';
    -4081  : msg := 'IN-GEAR Says: Histogram overflow.';
    -4080  : msg := 'IN-GEAR Says: No Access.';
    -4079  : msg := 'IN-GEAR Says: Illegal data type.';
    -4078  : msg := 'IN-GEAR Says: Invalid paramerter or invalid data.';
    -4077  : msg := 'IN-GEAR Says: Address reference exists to deleted area.';
    -4076  : msg := 'IN-GEAR Says: Command execution failure for unknown reason';
    -4075  : msg := 'IN-GEAR Says: Data Conversion Error.';
    {$ENDIF}
    -1     : msg := 'IN-GEAR Says: The Adapter Property is pointing to an adpater that has not been properly configured, or is not operating.';
    -2     : msg := 'IN-GEAR Says: Reserved';
    -3     : msg := 'IN-GEAR Says: The PLC did not respoind to the Read/Write request and the IN-GEAR driver timed out.';
    -4     : msg := 'IN-GEAR Says: The Ethernet PLC did not respond with in the required time. TIMEOUT.';
    -5     : msg := 'IN-GEAR Says: IN-GEAR driver error. More than one application or process is trying to use a KT/KTx/SST/DF1 connection on the PLC Network.';
    -6     : msg := 'IN-GEAR Says: Invalid funtion for this PLC.';
    -7     : msg := 'IN-GEAR Says: Ethernet connection request failed to PLC.';
    260    : msg := 'IN-GEAR Says: Invalid Tag Name.';
    511    : msg := 'IN-GEAR Says: Invalid data type for tag name(ControlLogix5550) - invalid type-declaration character for tag name.';
    512    : msg := 'IN-GEAR Says: Cannot guarantee delivery. Invalid node assigned.  Non existing DH+/DH-485 network address.';
    768    : msg := 'IN-GEAR Says: Duplicate token hold detected.';
    1024   : msg := 'IN-GEAR Says: Local port is disconnected.';
    1280   : msg := 'IN-GEAR Says: Application layer timed out waiting for response.';
    1536   : msg := 'IN-GEAR Says: Duplicate Node detected.';
    1792   : msg := 'IN-GEAR Says: Station is offline';
    2048   : msg := 'IN-GEAR Says: Hardware Fault';
    4096   : msg := 'IN-GEAR Says: Illegal command format.  The PLC does not recognize the FileAddr Property setting or cannot execute the Function Property command.';
    8192   : msg := 'IN-GEAR Says: Host has problems and cannot commuicate.';
    12288  : msg := 'IN-GEAR Says: Remote node is missing, disconnected or shutdown.';
    16384  : msg := 'IN-GEAR Says: Host could not complete function due to hardware fault.';
    20480  : msg := 'IN-GEAR Says: Addressing Problem.';
    24576  : msg := 'IN-GEAR Says: Function disallowed.';
    28672  : msg := 'IN-GEAR Says: Processor in program mode.';
    30539  : msg := 'IN-GEAR Says: INGEAR license is invalid or has expired.';
    {$IFDEF INGEAR_Version_60}
    // Expanded Micrologix/SLC/PLC-5 Error Codes
    32768  : msg := 'IN-GEAR Says: Compatibility mode file missing.';
    36864  : msg := 'IN-GEAR Says: Remote node cannot buffer command.';
    45056  : msg := 'IN-GEAR Says: Remote node problem due to download.';
    49152  : msg := 'IN-GEAR Says: Cannot execute due to active IPBS.';
    61441  : msg := 'IN-GEAR Says: A fild has an illegal value.';
    61442  : msg := 'IN-GEAR Says: Less levels specified in address than system supports.';
    61443  : msg := 'IN-GEAR Says: More levels specified in address than system supports.';
    61444  : msg := 'IN-GEAR Says: Symbol not found';
    61445  : msg := 'IN-GEAR Says: Symbol is not proper format.';
    61446  : msg := 'IN-GEAR Says: File address doesn''t point to something useful.';
    61447  : msg := 'IN-GEAR Says: File is wrong size.';
    61448  : msg := 'IN-GEAR Says: Cannot complete request.';
    61449  : msg := 'IN-GEAR Says: Data or file is too large.';
    61450  : msg := 'IN-GEAR Says: Transaction plus word size is too large.';
    61451  : msg := 'IN-GEAR Says: Access denied.';
    61452  : msg := 'IN-GEAR Says: Condition cannot be generated.';
    61453  : msg := 'IN-GEAR Says: Condition already exists.';
    61454  : msg := 'IN-GEAR Says: Command cannot be executed.';
    61455  : msg := 'IN-GEAR Says: Histogram Overflow.';
    61456  : msg := 'IN-GEAR Says: No access.';
    61457  : msg := 'IN-GEAR Says: Illegal data type.';
    61458  : msg := 'IN-GEAR Says: Invalid parameteror invalid data.';
    61459  : msg := 'IN-GEAR Says: Address reference exists to deleted area.';
    61460  : msg := 'IN-GEAR Says: Command execution failure for unknown reason.';
    61461  : msg := 'IN-GEAR Says: Data conversion error.';
    // Ethernet IP and CIP Error Codes
    1      : msg := 'IN-GEAR Says: Connection failure.';
    2      : msg := 'IN-GEAR Says: Insufficient resources.';
    3      : msg := 'IN-GEAR Says: Value invalid.';
    4      : msg := 'IN-GEAR Says: Malformed tag or tag does not exist.';
    5      : msg := 'IN-GEAR Says: Unknown destination.';
    6      : msg := 'IN-GEAR Says: Data requested would not fin in response packet.';
    7      : msg := 'IN-GEAR Says: Loss of connection.';
    8      : msg := 'IN-GEAR Says: Unsupported service.';
    9      : msg := 'IN-GEAR Says: Error in data segment or inalid attribute value.';
    10     : msg := 'IN-GEAR Says: Attribute list error.';
    11     : msg := 'IN-GEAR Says: State already exists.';
    12     : msg := 'IN-GEAR Says: Object model conflict.';
    13     : msg := 'IN-GEAR Says: Object already exists.';
    14     : msg := 'IN-GEAR Says: Attribute not settable.';
    15     : msg := 'IN-GEAR Says: Permission Denied.';
    16     : msg := 'IN-GEAR Says: Device state conflict.';
    17     : msg := 'IN-GEAR Says: Relpy to large.';
    18     : msg := 'IN-GEAR Says: Fragment primitive.';
    19     : msg := 'IN-GEAR Says: Insufficient command data or parameters specified to execute service.';
    20     : msg := 'IN-GEAR Says: Attribute not supported.';
    21     : msg := 'IN-GEAR Says: Too much data specified.';
    26     : msg := 'IN-GEAR Says: Bridge request too large.';
    27     : msg := 'IN-GEAR Says: Bridge response too large.';
    28     : msg := 'IN-GEAR Says: Attribute list short.';
    29     : msg := 'IN-GEAR Says: Invalid attribute list.';
    30     : msg := 'IN-GEAR Says: Failure during connection.';
    34     : msg := 'IN-GEAR Says: Invalid received.';
    35     : msg := 'IN-GEAR Says: Key segment error.';
    37     : msg := 'IN-GEAR Says: Number of IO words specified does not match IO word count.';
    38     : msg := 'IN-GEAR Says: Unexpected attribute in list.';
    255    : msg := 'IN-GEAR Says: General Error.';
    // Extended CIP Error Codes
    65792  : msg := 'IN-GEAR Says: Connection failure(Connection in use).';
    65795  : msg := 'IN-GEAR Says: Connection failure(Transport not supported).';
    65798  : msg := 'IN-GEAR Says: Connection failure(Ownership conflict).';
    65799  : msg := 'IN-GEAR Says: Connection failure(Connection not found).';
    65800  : msg := 'IN-GEAR Says: Connection failure(Invalid connection type).';
    65801  : msg := 'IN-GEAR Says: Connection failure(Invalid connection size).';
    65808  : msg := 'IN-GEAR Says: Connection failure(Module not configured).';
    65809  : msg := 'IN-GEAR Says: Connection failure(ERP not supported).';
    65812  : msg := 'IN-GEAR Says: Connection failure(Wrong module).';
    65813  : msg := 'IN-GEAR Says: Connect failure(Wrong device type).';
    65814  : msg := 'IN-GEAR Says: Connect failure(Wrong revision).';
    65816  : msg := 'IN-GEAR Says: Connect failure(Invalid configuration format).';
    65818  : msg := 'IN-GEAR Says: Connect failure(Application out of connections).';
    66051  : msg := 'IN-GEAR Says: Connect failure(Connection timeout).';
    66053  : msg := 'IN-GEAR Says: Connect failure(Unconnected message timeout).';
    66054  : msg := 'IN-GEAR Says: Connect failure(Message too large).';
    66305  : msg := 'IN-GEAR Says: Connect failure(No buffer memory).';
    66306  : msg := 'IN-GEAR Says: Connect failure(Bandwidth not available).';
    66307  : msg := 'IN-GEAR Says: Connect failure(No screeners available).';
    66309  : msg := 'IN-GEAR Says: Connect failure(Signature match).';
    66321  : msg := 'IN-GEAR Says: Connect failure(Port not available).';
    66322  : msg := 'IN-GEAR Says: Connect failure(Link address not available).';
    66325  : msg := 'IN-GEAR Says: Connect failure(Invalid segment type).';
    66327  : msg := 'IN-GEAR Says: Connect failure(Connection not scheduled).';
    66328  : msg := 'IN-GEAR Says: Connect failure(Link address to self is invalid).';
    {$ENDIF}
    // ------------------ END INGEAR COMPONENT ERROR MESSAGES --------------------
    // ------------------ WINSOCK ERROR MESSAGES ---------------------------------
    10004  : msg := 'Winsock Says: A blocking operation was interruped by a call to WSACancelBlockingCall.';
    10013  : msg := 'Winsock Says: An attempt was made to access a socket in a way forbidden by its access permissions.';
    10014  : msg := 'Winsock Says: The system detected an invalid pointer address in attempting to use a pointer argument in a call.';
    10024  : msg := 'Winsock Says: Too man open sockets.';
    10035  : msg := 'Winsock Says: A non-blocking socket operation could not be completed immediately';
    10036  : msg := 'Winsock Says: A blocking opperation is currently executing.';
    10037  : msg := 'Winsock Says: An operation was attempted on a non-blocking socket that already had an operation in progress.';
    10038  : msg := 'Winsock Says: An operation was attempted on something that is not a socket.';
    10050  : msg := 'Winsock Says: A socket operation encountered a dead network.';
    10051  : msg := 'Winsock Says: A socket operation was attempted to an unreachable network.';
    10052  : msg := 'Winsock Says: The connection has been broken due to keep-alive activity detecting a failure while the operation was in progress.';
    10053  : msg := 'Winsock Says: An established connection was aborted by the software in your host machine.';
    10054  : msg := 'Winsock Says: An existing connection was forcibly closed by the remote host.';
    10055  : msg := 'Winsock Says: An operation on a socket could not be performed because the system lacked sufficient buffer space or because a queue was full.';
    10056  : msg := 'Winsock Says: A connect request was made on an already connected socket.';
    10057  : msg := 'Winsock Says: A request to send or recieve data was disallowed because the socket is not connected and (when sending on a datagram socket using sendto call) no address was supplied.';
    10058  : msg := 'Winsock Says: A request to send or recieve was disallowed because the socket had already been shutdown in that direction with previous shutdown call.';
    10059  : msg := 'Winsock Says: Too many references to some kernel object.';
    10060  : msg := 'Winsock Says: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection fialed because connected host has failed to respond.';
    10061  : msg := 'Winsock Says: No connection could be made because the traget machine activley refused it.';
    10062  : msg := 'Winsock Says: Cannot translate name.';
    10063  : msg := 'Winsock Says: Name component or name was too long.';
    10064  : msg := 'Winsock Says: A socket operation failed because the destination host was down.';
    10065  : msg := 'Winsock Says: A socket operation was attempted to an unreachable host.';
    10067  : msg := 'Winsock Says: A Windows Sockets implementation may have a limit on the number of applications that may use it simultaneously.';
    // ------------------ END WINSOCK ERROR MESSAGES -----------------------------
  else
    msg := 'Undocumented Error.'
  end; // Case
  if (FReadStack.Count > 0) then
  begin
    FProcessReadPacket := False;
    ReadPacket := FReadStack.Objects[0] as TPLCReadPacket;
    if Assigned(ReadPacket) then
    begin
      ReadPacket.Free;
      ReadPacket := Nil;
      FReadStack.Delete(0);
    end; // If
    PrimePLCForNextRead(FReadState);
  end; // If
  FReadErrorNum := nErrorCode;
  FReadErrorStr := Msg;
  if ((FReadErrorNum = 10035) or (FReadErrorNum = 10036)) then
  begin
    if Not Terminated then;
      Synchronize(DoReadRecoverableErrorEvent);
  end
  else
  begin       
    Inc(FReadFaultCount);
    FReadFault := (FReadFaultCount >= FReadFaultTol);
    if Not Terminated then
      Synchronize(DoReadErrorEvent);
  end; // If
end; // TPLCReadThread.PLCReadErrorEvent

procedure TPLCWriteThread.PLCWriteErrorEvent(Sender : TObject; nErrorCode : TintErrorCode);
var
  Msg : ShortString;
  lWritePacket : TPLCWritePacket;
begin
  case nErrorCode of
    // ----------------- INGEAR COMPONENT ERROR MESSAGES -------------------------
    {$IFDEF INGEAR_Version_52}
    -32768 : msg := 'IN-GEAR Says: compatability mode file missing.';
    -28672 : msg := 'IN-GEAR Says: Remote node cannot buffer command';
    -20480 : msg := 'IN-GEAR Says: Remote node problem due to download.';
    -16284 : msg := 'IN-GEAR Says: Cannot execute due to active IPBS.';
    -4095  : msg := 'IN-GEAR Says: A field has an illegal value.';
    -4094  : msg := 'IN-GEAR Says: Less levels specified in adddress than minimum for any address.';
    -4093  : msg := 'IN-GEAR Says: More levels specified in address than system supports.';
    -4092  : msg := 'IN-GEAR Says: Symbol not found.';
    -4091  : msg := 'IN-GEAR Says: Symbol is not proper format.';
    -4090  : msg := 'IN-GEAR Says: File address doesn''t point to something useful.';
    -4089  : msg := 'IN-GEAR Says: File is wrong size.';
    -4088  : msg := 'IN-GEAR Says: Cannot complete request.';
    -4087  : msg := 'IN-GEAR Says: Data or file is too large.';
    -4086  : msg := 'IN-GEAR Says: Transaction plus word size is too large.';
    -4085  : msg := 'IN-GEAR Says: Access Denied.';
    -4084  : msg := 'IN-GEAR Says: Condition cannot be generated.';
    -4083  : msg := 'IN-GEAR Says: Condition already exists.';
    -4082  : msg := 'IN-GEAR Says: Command cannot be executed.';
    -4081  : msg := 'IN-GEAR Says: Histogram overflow.';
    -4080  : msg := 'IN-GEAR Says: No Access.';
    -4079  : msg := 'IN-GEAR Says: Illegal data type.';
    -4078  : msg := 'IN-GEAR Says: Invalid paramerter or invalid data.';
    -4077  : msg := 'IN-GEAR Says: Address reference exists to deleted area.';
    -4076  : msg := 'IN-GEAR Says: Command execution failure for unknown reason';
    -4075  : msg := 'IN-GEAR Says: Data Conversion Error.';
    {$ENDIF}
    -1     : msg := 'IN-GEAR Says: The Adapter Property is pointing to an adpater that has not been properly configured, or is not operating.';
    -2     : msg := 'IN-GEAR Says: Reserved';
    -3     : msg := 'IN-GEAR Says: The PLC did not respoind to the Read/Write request and the IN-GEAR driver timed out.';
    -4     : msg := 'IN-GEAR Says: The Ethernet PLC did not respond with in the required time. TIMEOUT.';
    -5     : msg := 'IN-GEAR Says: IN-GEAR driver error. More than one application or process is trying to use a KT/KTx/SST/DF1 connection on the PLC Network.';
    -6     : msg := 'IN-GEAR Says: Invalid funtion for this PLC.';
    -7     : msg := 'IN-GEAR Says: Ethernet connection request failed to PLC.';
    260    : msg := 'IN-GEAR Says: Invalid Tag Name.';
    511    : msg := 'IN-GEAR Says: Invalid data type for tag name(ControlLogix5550) - invalid type-declaration character for tag name.';
    512    : msg := 'IN-GEAR Says: Cannot guarantee delivery. Invalid node assigned.  Non existing DH+/DH-485 network address.';
    768    : msg := 'IN-GEAR Says: Duplicate token hold detected.';
    1024   : msg := 'IN-GEAR Says: Local port is disconnected.';
    1280   : msg := 'IN-GEAR Says: Application layer timed out waiting for response.';
    1536   : msg := 'IN-GEAR Says: Duplicate Node detected.';
    1792   : msg := 'IN-GEAR Says: Station is offline';
    2048   : msg := 'IN-GEAR Says: Hardware Fault';
    4096   : msg := 'IN-GEAR Says: Illegal command format.  The PLC does not recognize the FileAddr Property setting or cannot execute the Function Property command.';
    8192   : msg := 'IN-GEAR Says: Host has problems and cannot commuicate.';
    12288  : msg := 'IN-GEAR Says: Remote node is missing, disconnected or shutdown.';
    16384  : msg := 'IN-GEAR Says: Host could not complete function due to hardware fault.';
    20480  : msg := 'IN-GEAR Says: Addressing Problem.';
    24576  : msg := 'IN-GEAR Says: Function disallowed.';
    28672  : msg := 'IN-GEAR Says: Processor in program mode.';
    30539  : msg := 'IN-GEAR Says: INGEAR license is invalid or has expired.';
    {$IFDEF INGEAR_Version_60}
    // Expanded Micrologix/SLC/PLC-5 Error Codes
    32768  : msg := 'IN-GEAR Says: Compatibility mode file missing.';
    36864  : msg := 'IN-GEAR Says: Remote node cannot buffer command.';
    45056  : msg := 'IN-GEAR Says: Remote node problem due to download.';
    49152  : msg := 'IN-GEAR Says: Cannot execute due to active IPBS.';
    61441  : msg := 'IN-GEAR Says: A fild has an illegal value.';
    61442  : msg := 'IN-GEAR Says: Less levels specified in address than system supports.';
    61443  : msg := 'IN-GEAR Says: More levels specified in address than system supports.';
    61444  : msg := 'IN-GEAR Says: Symbol not found';
    61445  : msg := 'IN-GEAR Says: Symbol is not proper format.';
    61446  : msg := 'IN-GEAR Says: File address doesn''t point to something useful.';
    61447  : msg := 'IN-GEAR Says: File is wrong size.';
    61448  : msg := 'IN-GEAR Says: Cannot complete request.';
    61449  : msg := 'IN-GEAR Says: Data or file is too large.';
    61450  : msg := 'IN-GEAR Says: Transaction plus word size is too large.';
    61451  : msg := 'IN-GEAR Says: Access denied.';
    61452  : msg := 'IN-GEAR Says: Condition cannot be generated.';
    61453  : msg := 'IN-GEAR Says: Condition already exists.';
    61454  : msg := 'IN-GEAR Says: Command cannot be executed.';
    61455  : msg := 'IN-GEAR Says: Histogram Overflow.';
    61456  : msg := 'IN-GEAR Says: No access.';
    61457  : msg := 'IN-GEAR Says: Illegal data type.';
    61458  : msg := 'IN-GEAR Says: Invalid parameteror invalid data.';
    61459  : msg := 'IN-GEAR Says: Address reference exists to deleted area.';
    61460  : msg := 'IN-GEAR Says: Command execution failure for unknown reason.';
    61461  : msg := 'IN-GEAR Says: Data conversion error.';
    // Ethernet IP and CIP Error Codes
    1      : msg := 'IN-GEAR Says: Connection failure.';
    2      : msg := 'IN-GEAR Says: Insufficient resources.';
    3      : msg := 'IN-GEAR Says: Value invalid.';
    4      : msg := 'IN-GEAR Says: Malformed tag or tag does not exist.';
    5      : msg := 'IN-GEAR Says: Unknown destination.';
    6      : msg := 'IN-GEAR Says: Data requested would not fin in response packet.';
    7      : msg := 'IN-GEAR Says: Loss of connection.';
    8      : msg := 'IN-GEAR Says: Unsupported service.';
    9      : msg := 'IN-GEAR Says: Error in data segment or inalid attribute value.';
    10     : msg := 'IN-GEAR Says: Attribute list error.';
    11     : msg := 'IN-GEAR Says: State already exists.';
    12     : msg := 'IN-GEAR Says: Object model conflict.';
    13     : msg := 'IN-GEAR Says: Object already exists.';
    14     : msg := 'IN-GEAR Says: Attribute not settable.';
    15     : msg := 'IN-GEAR Says: Permission Denied.';
    16     : msg := 'IN-GEAR Says: Device state conflict.';
    17     : msg := 'IN-GEAR Says: Relpy to large.';
    18     : msg := 'IN-GEAR Says: Fragment primitive.';
    19     : msg := 'IN-GEAR Says: Insufficient command data or parameters specified to execute service.';
    20     : msg := 'IN-GEAR Says: Attribute not supported.';
    21     : msg := 'IN-GEAR Says: Too much data specified.';
    26     : msg := 'IN-GEAR Says: Bridge request too large.';
    27     : msg := 'IN-GEAR Says: Bridge response too large.';
    28     : msg := 'IN-GEAR Says: Attribute list short.';
    29     : msg := 'IN-GEAR Says: Invalid attribute list.';
    30     : msg := 'IN-GEAR Says: Failure during connection.';
    34     : msg := 'IN-GEAR Says: Invalid received.';
    35     : msg := 'IN-GEAR Says: Key segment error.';
    37     : msg := 'IN-GEAR Says: Number of IO words specified does not match IO word count.';
    38     : msg := 'IN-GEAR Says: Unexpected attribute in list.';
    255    : msg := 'IN-GEAR Says: General Error.';
    // Extended CIP Error Codes
    65792  : msg := 'IN-GEAR Says: Connection failure(Connection in use).';
    65795  : msg := 'IN-GEAR Says: Connection failure(Transport not supported).';
    65798  : msg := 'IN-GEAR Says: Connection failure(Ownership conflict).';
    65799  : msg := 'IN-GEAR Says: Connection failure(Connection not found).';
    65800  : msg := 'IN-GEAR Says: Connection failure(Invalid connection type).';
    65801  : msg := 'IN-GEAR Says: Connection failure(Invalid connection size).';
    65808  : msg := 'IN-GEAR Says: Connection failure(Module not configured).';
    65809  : msg := 'IN-GEAR Says: Connection failure(ERP not supported).';
    65812  : msg := 'IN-GEAR Says: Connection failure(Wrong module).';
    65813  : msg := 'IN-GEAR Says: Connect failure(Wrong device type).';
    65814  : msg := 'IN-GEAR Says: Connect failure(Wrong revision).';
    65816  : msg := 'IN-GEAR Says: Connect failure(Invalid configuration format).';
    65818  : msg := 'IN-GEAR Says: Connect failure(Application out of connections).';
    66051  : msg := 'IN-GEAR Says: Connect failure(Connection timeout).';
    66053  : msg := 'IN-GEAR Says: Connect failure(Unconnected message timeout).';
    66054  : msg := 'IN-GEAR Says: Connect failure(Message too large).';
    66305  : msg := 'IN-GEAR Says: Connect failure(No buffer memory).';
    66306  : msg := 'IN-GEAR Says: Connect failure(Bandwidth not available).';
    66307  : msg := 'IN-GEAR Says: Connect failure(No screeners available).';
    66309  : msg := 'IN-GEAR Says: Connect failure(Signature match).';
    66321  : msg := 'IN-GEAR Says: Connect failure(Port not available).';
    66322  : msg := 'IN-GEAR Says: Connect failure(Link address not available).';
    66325  : msg := 'IN-GEAR Says: Connect failure(Invalid segment type).';
    66327  : msg := 'IN-GEAR Says: Connect failure(Connection not scheduled).';
    66328  : msg := 'IN-GEAR Says: Connect failure(Link address to self is invalid).';
    {$ENDIF}
    // ------------------ END INGEAR COMPONENT ERROR MESSAGES --------------------
    // ------------------ WINSOCK ERROR MESSAGES ---------------------------------
    10004  : msg := 'Winsock Says: A blocking operation was interruped by a call to WSACancelBlockingCall.';
    10013  : msg := 'Winsock Says: An attempt was made to access a socket in a way forbidden by its access permissions.';
    10014  : msg := 'Winsock Says: The system detected an invalid pointer address in attempting to use a pointer argument in a call.';
    10024  : msg := 'Winsock Says: Too man open sockets.';
    10035  : msg := 'Winsock Says: A non-blocking socket operation could not be completed immediately';
    10036  : msg := 'Winsock Says: A blocking opperation is currently executing.';
    10037  : msg := 'Winsock Says: An operation was attempted on a non-blocking socket that already had an operation in progress.';
    10038  : msg := 'Winsock Says: An operation was attempted on something that is not a socket.';
    10050  : msg := 'Winsock Says: A socket operation encountered a dead network.';
    10051  : msg := 'Winsock Says: A socket operation was attempted to an unreachable network.';
    10052  : msg := 'Winsock Says: The connection has been broken due to keep-alive activity detecting a failure while the operation was in progress.';
    10053  : msg := 'Winsock Says: An established connection was aborted by the software in your host machine.';
    10054  : msg := 'Winsock Says: An existing connection was forcibly closed by the remote host.';
    10055  : msg := 'Winsock Says: An operation on a socket could not be performed because the system lacked sufficient buffer space or because a queue was full.';
    10056  : msg := 'Winsock Says: A connect request was made on an already connected socket.';
    10057  : msg := 'Winsock Says: A request to send or recieve data was disallowed because the socket is not connected and (when sending on a datagram socket using sendto call) no address was supplied.';
    10058  : msg := 'Winsock Says: A request to send or recieve was disallowed because the socket had already been shutdown in that direction with previous shutdown call.';
    10059  : msg := 'Winsock Says: Too many references to some kernel object.';
    10060  : msg := 'Winsock Says: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection fialed because connected host has failed to respond.';
    10061  : msg := 'Winsock Says: No connection could be made because the traget machine activley refused it.';
    10062  : msg := 'Winsock Says: Cannot translate name.';
    10063  : msg := 'Winsock Says: Name component or name was too long.';
    10064  : msg := 'Winsock Says: A socket operation failed because the destination host was down.';
    10065  : msg := 'Winsock Says: A socket operation was attempted to an unreachable host.';
    10067  : msg := 'Winsock Says: A Windows Sockets implementation may have a limit on the number of applications that may use it simultaneously.';
    // ------------------ END WINSOCK ERROR MESSAGES -----------------------------
  else
    msg := 'Undocumented Error.'
  end; // Case
  FWriteErrorNum := nErrorCode;
  FWriteErrorStr := Msg;
  if ((FWriteErrorNum = 10035) or (FWriteErrorNum = 10036)) then
  begin
    if Not Terminated then
      Synchronize(DoWriteRecoverableErrorEvent);
  end
  else
  begin
    lWritePacket := FWriteStack.Objects[0] as TPLCWritePacket;
    lWritePacket.TransactionPhase := 3;
    Inc(FWriteFaultCount);
    FWriteFault := (FWriteFaultCount >= FWriteFaultTol);
    if Not Terminated then
      Synchronize(DoWriteErrorEvent);
  end; // If
end; // TPLCWriteThread.PLCWriteErrorEvent

procedure TMicroLogixPLC.InitializePLC;
var
  i : Byte;
begin
  if Assigned(FPLCReadThread) and Assigned(FPLCWriteThread) then
  begin
    FPLCReadThread.ReadFault := False;
    FPLCWriteThread.WriteFault := False;
    for i := 0 to (FBinaryReadSize - 1) do
      FPLCWriteThread.WriteWordToPLC('B3',i,1,0);
    if (FWatchDogHi <> '') then
      ClearWatchDogAccumulator(FWatchDogHi);
    if (FWatchDogLo <> '') then
      ClearWatchDogAccumulator(FWatchDogLo);
  end; // If
end; // TMicroLogixPLC.InitializePLC

function TPLCWriteThread.WriteBitToPLC(pFile : Shortstring; pWordNumber : integer; BitNumber : integer; intSize : integer; Value : boolean) : Boolean;
var
  lPacket : TPLCWritePacket;
begin
  Result := False;
  if Not FWriteFault then
  begin
    lPacket := TPLCWritePacket.Create;
    if BitNumber in [0..15] then
    begin
      with lPacket do
      begin
        WriteBit := True;
        Size := intSize;
        FileType := pFile;
        WordNumber := pWordNumber;
        BitPosition := BitNumber;
        BitToWrite := Value;
        TransactionPhase := 0;
      end; // With
      Result := AddToWriteStack(lPacket);
    end; // If
  end; // If
end; // TPLCWriteThread.WriteBitToPLC

function TPLCWriteThread.WriteWordToPLC(pFile : Shortstring; pWordNumber : integer; intSize : integer; Value : SmallInt) : Boolean;
var
  lPacket : TPLCWritePacket;
begin
  Result := False;
  if Not FWriteFault then
  begin
    lPacket := TPLCWritePacket.Create;
    with lPacket do
    begin
      WriteWord := True;
      Size := intSize;
      FileType := pFile;
      WordNumber := pWordNumber;
      WordToWrite := Value;
      TransactionPhase := 0;
    end; // With
    Result := AddToWriteStack(lPacket);
  end; // If
end; // TMicroLogixPLC.WriteWordToPLC

procedure TMicroLogixPLC.SetWatchDogState(Value : boolean);
begin
  FWatchDogActive := Value;
  if Assigned(FPLCWatchDogThread) then
  begin
    FPLCWatchDogThread.SleepInterval := FWatchDogInterval;
    FPLCWatchDogThread.WatchDogEnabled := FWatchDogActive;
  end; // If
end; // TMicroLogixPLC.SetWatchDogState

procedure TMicroLogixPLC.SetWatchDogInterval(Value : longint);
begin
  FWatchDogInterval := Value;
  if Assigned(FPLCWatchDogThread) then
    FPLCWatchDogThread.SleepInterval := FWatchDogInterval;
end; // TMicroLogixPLC.SetWatchDogInterval

procedure TPLCReadThread.PrimePLCForNextRead(Value : integer);
begin
  FPLCRead.ClearControl;
  case Value of
    0 : begin // Data;
          FPLCRead.FileAddr := FStatusFile;
          FPLCRead.Size := FStatusReadSize;
        end; // 0
    1 : begin // Status
          FPLCRead.FileAddr := FDataFile;
          FPLCRead.Size := FDataReadSize;
        end; // 3
  end; // Case
end; // TPLCWriteThread.PrimePLCForNextRead

function TMicroLogixPLC.ProcessorMode(ModuleType,intProcessorMode : Integer) : ShortString;
begin
  case ModuleType of
    0 : begin
          Case intProcessorMode of
            0  :  Result := 'PLC Processor Mode is Unknown.';
            1  :  Result := 'PLC Processor Mode is REMOTE PROGRAM MODE.';
            6  :  Result := 'PLC Processor Mode is REMOTE RUN MODE.';
            17 :  Result := 'PLC Processor Mode is PROGRAM MODE.';
            30 :  Result := 'PLC Processor Mode is RUN MODE.';
          end; // Case
        end; // 0
  end; // Case
end; // TMicroLogixPLC.ProcessorMode

function TPLCWriteThread.AddToWriteStack(lPacket : TPLCWritePacket) : Boolean;
begin
  Result := False;
  if Assigned(FWriteStack) then
  begin
    if Assigned(lPacket) then
    begin
      if Get_ThreadWriteStackAccess(FWriteWaitTimeOut) then
      begin
        FWriteStack.AddObject(IntToStr(FWriteStack.Count),lPacket);
        Result := True;
        Release_ThreadWriteStackAccess;
      end
      else
        lPacket.Free;
    end; // If
  end; // If
end; // TPLCWriteThread.AddToWriteStack

function TPLCWriteThread.Get_ThreadWriteStackAccess(TimeOutms : DWord) : Boolean;
begin
  Result := (WaitForSingleObject(UsingWriteStack,TimeOutms) = Wait_Object_0);
end; // TPLCWriteThread.Get_ThreadWriteStackAccess

procedure TPLCWriteThread.Release_ThreadWriteStackAccess;
begin
  ReleaseSemaphore(UsingWriteStack,1,Nil);
end; // TPLCWriteThread.Release_ThreadWriteStackAccess

function TMicroLogixPLC.GetReadInterval : LongInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.SleepTime
  else
    Result := FReadInterval;
end; // TMicroLogixPLC.GetReadInterval

procedure TMicroLogixPLC.SetReadInterval(Value : longInt);
begin
  FReadInterval := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.SleepTime := FReadInterval;
end; // TMicroLogixPLC.SetReadInterval

procedure TMicroLogixPLC.LoadPLCConfiguration(lFileName : ShortString);
var
  INIFile : TStRegINI;
  i : integer;
  lMainModule : TPLCMainModule;
  lDigitalInputModule : TDigitalInputModule;
  lDigitalOutputModule : TDigitalOutputModule;
  lAnalogInputModule : TAnalogInputModule;
  lRTDAnalogInputModule : TRTDAnalogInputModule;
  lAnalogOutputModule : TAnalogOutputModule;
  lRelayedDigitalOutputModule : TRelayedDigitalOutputModule;
  OptionalParams : TStringList;
begin
  if FileExists(lFileName) then
  begin
    if FModuleCount > 0 then
    begin
      SetEnabled(False);
      if Assigned(FPLCReadThread) then
        FPLCReadThread.Terminate;
      for i := 0 to (FModuleCount - 1) do
      begin
        Modules[i].Free;
        Modules[i] := Nil;
      end; // For i
      if Assigned(FPLCReadThread) then
        FPLCReadThread.Start;
    end; // If
    FConfigurationFile := lFileName;
    OptionalParams := TStringList.Create;
    INIFile := TStRegINI.Create(FConfigurationFile,True);
    try
      try
        with INIFile do
        begin
          CurSubKey := 'Version';
          if (ReadString('Version','') <> FVersion) then
            DoConfigurationError(6,'Configuration file version does not match component version.');
          CurSubKey := 'PLC';
          SetReadIPAddress(ReadString('ReadIPAddress','0.0.0.0'));
          SetWriteIPAddress(ReadString('WriteIPAddress','0.0.0.0'));
          SetDataFile(ReadString('ReadFile','N7'));
          SetDataSize(ReadInteger('NumberOfDataWords',1));
          SetStatusSize(ReadInteger('NumberofStatusWords',1));
          SetWatchdogBitNumber(ReadInteger('WatchdogBit',0));
          SetWatchDogWordNumber(ReadInteger('WatchdogWord',0));
          SetWatchDogInterval(ReadInteger('WatchdogInterval',1000));
          SetReadInterval(ReadInteger('ReadInterval',60));
          FModuleCount := ReadInteger('ModulesInstalled',0);
          if FModuleCount > 0 then
          begin
            FModulesPresent := True;
            for i := 0 to (FModuleCount - 1) do
            begin
              CurSubKey := format('Module%d',[i]);
              ModuleType[i] := ReadInteger('ModuleType',0);
              case ModuleType[i] of
                0 : begin // Main Module
                      lMainModule := TPLCMainModule.Create;
                      lMainModule.ModuleType := ModuleType[i];
                      lMainModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                      lMainModule.DigitalInputModuleWords[0,0] := ReadInteger('StartDigitalInputWord',0);
                      lMainModule.DigitalInputModuleWords[0,1] := ReadInteger('EndDigitalInputWord',0);
                      lMainModule.DigitalOutputModuleWords[0,0] := ReadInteger('StartDigitalOutputDataWord',0);
                      lMainModule.DigitalOutputModuleWords[0,1] := ReadInteger('EndDigitalOutputDataWord',0);
                      // Analog
                      lMainModule.AnalogInputModuleWords[0,0] := ReadInteger('StartAnalogInputWord',0);
                      lMainModule.AnalogInputModuleWords[0,1] := ReadInteger('EndAnalogInputWord',0);
                      lMainModule.AnalogInputModuleWords[1,0] := ReadInteger('StartAnalogInputStatusWord',0);
                      lMainModule.AnalogInputModuleWords[1,1] := ReadInteger('EndAnalogInputStatusWord',0);
                      lMainModule.AnalogOutputModuleWords[0,0] := ReadInteger('StartAnalogOutputDataWord',0);
                      lMainModule.AnalogOutputModuleWords[0,1] := ReadInteger('EndAnalogOutputDataWord',0);
                      lMainModule.AnalogOutputModuleWords[1,0] := ReadInteger('StartAnalogOutputStatusWord',0);
                      lMainModule.AnalogOutputModuleWords[1,1] := ReadInteger('EndAnalogOutputStatusWord',0);
                      // Request Bits
                      lMainModule.RequestBits_ModuleWords[0,0] := ReadInteger('StartRequestBitsWord',0);
                      lMainModule.RequestBits_ModuleWords[0,1] := ReadInteger('EndRequestBitsWord',0);
                      Modules[i] := lMainModule;
                    end; // 0
                1 : begin // Digital Input Module
                      lDigitalInputModule := TDigitalInputModule.Create;
                      lDigitalInputModule.ModuleType := ModuleType[i];
                      lDigitalInputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                      lDigitalInputModule.ModuleWords[0,0] := ReadInteger('StartDataWord',0);
                      lDigitalInputModule.ModuleWords[0,1] := ReadInteger('EndDataWord',0);
                      lDigitalInputModule.ModuleWords[1,0] := ReadInteger('StartStatusWord',0);
                      lDigitalInputModule.ModuleWords[1,1] := ReadInteger('EndStatusWord',0);
                      Modules[i] := lDigitalInputModule;
                    end; // 1
                2 : begin // Digital Output Module
                      lDigitalOutputModule := TDigitalOutputModule.Create;
                      lDigitalOutputModule.ModuleType := ModuleType[i];
                      lDigitalOutputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                      lDigitalOutputModule.ModuleWords[0,0] := ReadInteger('StartDataWord',0);
                      lDigitalOutputModule.ModuleWords[0,1] := ReadInteger('EndDataWord',0);
                      lDigitalOutputModule.ModuleWords[1,0] := ReadInteger('StartStatusWord',0);
                      lDigitalOutputModule.ModuleWords[1,1] := ReadInteger('EndStatusWord',0);
                      Modules[i] := lDigitalOutputModule;
                    end; // 2
                3 : begin // Analog Input Module
                      lAnalogInputModule := TAnalogInputModule.Create;
                      lAnalogInputModule.ModuleType := ModuleType[i];
                      lAnalogInputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                      lAnalogInputModule.ModuleWords[0,0] := ReadInteger('StartDataWord',0);
                      lAnalogInputModule.ModuleWords[0,1] := ReadInteger('EndDataWord',0);
                      lAnalogInputModule.ModuleWords[1,0] := ReadInteger('StartStatusWord',0);
                      lAnalogInputModule.ModuleWords[1,1] := ReadInteger('EndStatusWord',0);
                      Modules[i] := lAnalogInputModule;
                    end; // 3
                4 : begin // Analog Output Module
                      lAnalogOutputModule := TAnalogOutputModule.Create;
                      lAnalogOutputModule.ModuleType := ModuleType[i];
                      lAnalogOutputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                      lAnalogOutputModule.ModuleWords[0,0] := ReadInteger('StartDataWord',0);
                      lAnalogOutputModule.ModuleWords[0,1] := ReadInteger('EndDataWord',0);
                      lAnalogOutputModule.ModuleWords[1,0] := ReadInteger('StartStatusWord',0);
                      lAnalogOutputModule.ModuleWords[1,1] := ReadInteger('EndStatusWord',0);
                      Modules[i] := lAnalogOutputModule
                    end; // 4
                5 : begin // Relayed Digital Output Module
                      lRelayedDigitalOutputModule := TRelayedDigitalOutputModule.Create;
                      lRelayedDigitalOutputModule.ModuleType := ModuleType[i];
                      lRelayedDigitalOutputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                      lRelayedDigitalOutputModule.ModuleWords[0,0] := ReadInteger('StartDataWord',0);
                      lRelayedDigitalOutputModule.ModuleWords[0,1] := ReadInteger('EndDataWord',0);
                      lRelayedDigitalOutputModule.ModuleWords[1,0] := ReadInteger('StartStatusWord',0);
                      lRelayedDigitalOutputModule.ModuleWords[1,1] := ReadInteger('EndStatusWord',0);
                      Modules[i] := lRelayedDigitalOutputModule;
                    end; // 5
                6 : begin // RTD Analog Input Module
                      lRTDAnalogInputModule := TRTDAnalogInputModule.Create;
                      lRTDAnalogInputModule.ModuleType := ModuleType[i];
                      lRTDAnalogInputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                      lRTDAnalogInputModule.ModuleWords[0,0] := ReadInteger('StartDataWord',0);
                      lRTDAnalogInputModule.ModuleWords[0,1] := ReadInteger('EndDataWord',0);
                      lRTDAnalogInputModule.ModuleWords[1,0] := ReadInteger('StartStatusWord',0);
                      lRTDAnalogInputModule.ModuleWords[1,1] := ReadInteger('EndStatusWord',0);
                      Modules[i] := lRTDAnalogInputModule;
                    end; // 3
              end; // Case
            end; // For i
          end; // If
    //      CheckModuleConfigutaion;
          CurSubKey := 'PLC';
          FWatchDogHi := ReadString('WatchDogHi','');
          FWatchDogLo := ReadString('WatchDogLo','');
          SetEnabled(ReadBoolean('Enabled',False));
          SetWatchDogTimeOut(ReadInteger('WatchDogTimeOut',500));
          SetReadFaultTollerance(ReadInteger('ReadFaultTollerance',0));
          SetWriteFaultTollerance(ReadInteger('WriteFaultTollerance',0));
          CurSubKey := 'Optional';
          GetValues(OptionalParams);
          LoadOptionalParams(OptionalParams);
        end; // With
        if Assigned(FPLCReadThread) then
        begin
          FPLCReadThread.Modules := Modules;
          FPLCReadThread.ModuleTypes := ModuleType;
          FPLCReadThread.ModuleCount := FModuleCount;
        end; // If
        OptionalParams.Free;
      except
        On E : Exception do
          DoConfigurationError(7,format('Error reading configuration file, "%s".',[ExtractFileName(FConfigurationFile)]));
      end; // Try E
    finally
      INIFile.Free;
    end; // Try F
  end; // If
end; // TMicroLogixPLC.LoadPLCConfiguration

procedure TPLCReadThread.DoPassModuleData;
begin
  if Assigned(PLCMonitor.OnNewModuleData) then
    PLCMonitor.OnNewModuleData(Self,FModules,FModuleType,FModuleCount);
  FNewDataReady := False;
end; // TPLCReadThread.DoPassModuleData;

procedure TPLCReadThread.PopulateModules;
var
  i,
  j,
  k,
  lStartDataWord,
  lEndDataWord,
  lStartAnalogDataWord,
  lEndAnalogDataWord,
  lStartStatusWord,
  lEndStatusWord,
  lChannel1               : integer;
  lModuleError : boolean;
  lProcessorMode,
  lMajorError : integer;
  lMainModule : TPLCMainModule;
  lDigitalInputModule : TDigitalInputModule;
  lDigitalOutputModule : TDigitalOutputModule;
  lAnalogInputModule : TAnalogInputModule;
  lRTDAnalogInputModule : TRTDAnalogInputModule;
  lAnalogOutputModule : TAnalogOutputModule;
  lRelayedDigitalOutputModule : TRelayedDigitalOutputModule;
begin
  if Not Terminated and FModulesLoaded then
  begin
    for i := 0 to (FModuleCount - 1) do
    begin
      if Terminated then
        Break;
      lModuleError := False;
      case FModuleType[i] of
        0 : begin // Main Module
              lMainModule := (FModules[i] as TPLCMainModule);
              with lMainModule do
              begin
                // The MicroLogix 1400 processor module includes some or all of the following inputs and outputs:
                //   1.  20 Digital Inputs     = I:0.0 through I:0.3 (I:0.0 - 16 bits and I:0.1 - 4 bits are valid)
                //   2.  4 Analog Inputs       = I:0.4 through I:0.7
                //   3.  12 Digital Outputs    = O:0.0 through O:0.3 (O:0.0 - 12 bits are valid)
                //   4.  2 Analog Outputs      = O:0.4 through O:0.5
                lStartDataWord := DigitalInputModuleWords[0,0];
                lEndDataWord := DigitalInputModuleWords[0,1];
                lStartAnalogDataWord := AnalogInputModuleWords[0,0];
                lEndAnalogDataWord := AnalogInputModuleWords[0,1];

                DigitalInputData[0] := FDataBits[lStartDataWord];
                DigitalInputData[1] := FDataBits[lStartDataWord + 1];
                DigitalInputData[2] := FDataBits[lStartDataWord + 2];
                DigitalInputData[3] := FDataBits[lEndDataWord];
                AnalogInputData[0] := FDataWords[lStartAnalogDataWord];
                AnalogInputData[1] := FDataWords[lStartAnalogDataWord + 1];
                AnalogInputData[2] := FDataWords[lStartAnalogDataWord + 2];
                AnalogInputData[3] := FDataWords[lEndAnalogDataWord];

                lStartDataWord := DigitalOutputModuleWords[0,0];
                lEndDataWord := DigitalOutputModuleWords[0,1];
                lStartAnalogDataWord := AnalogOutputModuleWords[0,0];
                lEndAnalogDataWord := AnalogOutputModuleWords[0,1];

                DigitalOutputData[0] := FDataBits[lStartDataWord];
                DigitalOutputData[1] := FDataBits[lStartDataWord + 1];
                DigitalOutputData[2] := FDataBits[lStartDataWord + 2];
                DigitalOutputData[3] := FDataBits[lEndDataWord];
                AnalogOutputData[0] := FDataWords[lStartAnalogDataWord];
                AnalogOutputData[1] := FDataWords[lEndAnalogDataWord];
                // Request Bits are used to control and monitor logic at the PLC
                // The "B3" file in the PLC holds this data
                lStartDataWord := RequestBits_ModuleWords[0,0];
                lEndDataWord := RequestBits_ModuleWords[0,1];
                lChannel1 := 0;
                for j := lStartDataWord to lEndDataWord do
                begin
                  Request_Bits_Status[lChannel1] := FDataBits[j];
                  Inc(lChannel1);
                end; // For j
                // There are 66 words of status read from the PLC.
                //   The "S" file in the PLC holds this data
                //   This status data includes the following data:
                //   S:1/0 - 1/4   = Controller Mode
                //                   0  - Remote download in progress
                //                   1  - Remote Program mode
                //                   3  - Remote Suspend mode
                //                   6  - Remote Run
                //                   7  - Remote Test - continuous mode
                //                   8  - Remote Test - single scan mode
                //                   16 - Download in progress
                //                   17 - Program mode
                //                   27 - Suspend mode
                //                   30 - Run mode
                //   S:1/5         = Forces Enabled
                //   S:1/6         = Forces installed
                //   S:1/8         = Fault override at power-up
                //   S:1/9         = Startup protection fault
                //   S:1/10        = Load memory module on error or default program
                //   S:1/11        = Load memory module always
                //   S:1/12        = Power-up behavior
                //   S:1/13        = Major error halted
                //   S:1/14        = Future access (OEM lock)
                //   S:1/15        = First scan bit
                //   S:5/2         = Control register error
                //   S:5/11        = Processor battery low
                //   S:6           = Major Error Code
                lProcessorMode := 0;
                lMajorError := 0;
                for k := 0 to 15 do
                begin
                  if k in [0..4] then
                  begin
                    if FStatusBits[1,k] then
                      lProcessorMode := Trunc(lProcessorMode + power(2,k));
                  end; // IF
                  if FStatusBits[6,k] then
                    lMajorError := Trunc(lMajorError + power(2,k));
                end; // For k
                case lProcessorMode of
                  1,6,7,8 : KeySwitchPosition := 3;
                  17      : KeySwitchPosition := 2;
                  30      : KeySwitchPosition := 1;
                end; // Case
                ProcessorMode := lProcessorMode;
                ForcedIO := FStatusBits[1,6];
                ControlRegisterError := FStatusBits[5,2];
                BatteryOK := Not(FStatusBits[5,11]);
                MajorErrorCode := lMajorError;
                MajorErrorHalt := FStatusBits[1,13];
              end; // With
            end; // 0
        1 : begin // Digital Input Module
              lDigitalInputModule := (FModules[i] as TDigitalInputModule);
              with lDigitalInputModule do
              begin
                lStartDataWord := ModuleWords[0,0];
                DigitalInputData := FDataBits[lStartDataWord];
              end; // With
            end; // 1
        2 : begin // Digital Output Module
              lDigitalOutputModule := (FModules[i] as TDigitalOutputModule);
              with lDigitalOutputModule do
              begin
                lStartDataWord := ModuleWords[0,0];
                DigitalOutputData := FDataBits[lStartDataWord];
              end; // With
            end; // 2
        3 : begin // Analog Input Module
              lAnalogInputModule := (FModules[i] as TAnalogInputModule);
              with lAnalogInputModule do
              begin
                lStartDataWord := ModuleWords[0,0];
                lEndDataWord := ModuleWords[0,1];
                lStartStatusWord := ModuleWords[1,0];
                // The Analog Input expansion module (IF4) provides 7 words of data:
                //   Words 0-3 : Channels 0-3 data
                //   Word 4    : bits 0-3             = Channels 0-3 status
                //   Word 5    : bits 15,13,11,9      = Channels 0-3 Under-Range status
                //             : bits 14,12,10,8      = Channels 0-3 Over-Range status
                //   Word 6    : (IF4 only) Reserved
                ChannelDataValue[0] := FDataWords[lStartDataWord];
                ChannelDataValue[1] := FDataWords[lStartDataWord + 1];
                ChannelDataValue[2] := FDataWords[lStartDataWord + 2];
                ChannelDataValue[3] := FDataWords[lEndDataWord];
                for k := 0 to 3 do
                begin
                  ChannelStatus[k] := (FDataWords[lStartStatusWord] Shr k and 1) <> 0;
                  lModuleError := lModuleError or ChannelStatus[k];
                end; // For k
                j := 0;
                for k := 15 downto 8 do
                begin
                  lModuleError := lModuleError or ((FDataWords[lStartStatusWord + 1] Shr k and 1 <> 0));
                  if (k mod 2) = 0 then
                  begin
                    // Even numbered bits = Over-range
                    ChannelOverRangeFlag[j] := ((FDataWords[lStartStatusWord + 1] Shr k and 1 <> 0));
                    if j < 3 then
                    begin
                      inc(j);
                    end;
                  end
                  else
                  begin
                    // Odd numbered bits = Under-range
                    ChannelUnderRangeFlag[j] := ((FDataWords[lStartStatusWord + 1] Shr k and 1 <> 0));
                  end; // If
                end; // For k
                ModuleError := lModuleError;
              end; // With
            end; // 3
        4 : begin // Analog Output Module
              lAnalogOutputModule := (FModules[i] as TAnalogOutputModule);
              with lAnalogOutputModule do
              begin
                lStartDataWord := ModuleWords[0,0];
                lEndDataWord := ModuleWords[0,1];
                lStartStatusWord := ModuleWords[1,0];
                // The Analog Output expansion module provides 4 output words and 2 input words of data:
                //   Output Words 0-3 :                   = Channels 0-3 data
                //   Input Word 0     : bits 0-3          = Channels 0-3 status
                //   Input Word 1     : bits 7,5,3,1      = Channels 0-3 Under-Range status
                //                    : bits 6,4,2,0      = Channels 0-3 Over-Range status
                ChannelDataValue[0] := FDataWords[lStartDataWord];
                ChannelDataValue[1] := FDataWords[lStartDataWord + 1];
                ChannelDataValue[2] := FDataWords[lStartDataWord + 2];
                ChannelDataValue[3] := FDataWords[lEndDataWord];
                lModuleError := False; // Initialize
                for k := 0 to 3 do
                begin
                  ChannelStatus[k] := ((FDataWords[lStartStatusWord] Shr k and 1) <> 0);
                  lModuleError := lModuleError or ChannelStatus[k];
                end; // For k
                j := 0;
                for k := 7 downto 0 do
                begin
                  lModuleError := lModuleError or ((FDataWords[lStartStatusWord + 1] Shr k and 1) <> 0); // Input section holds the status of the output module
                  if (k mod 2) = 0 then
                  begin
                    // Even numbered bits = Over-range
                    ChannelOverRangeFlag[j] := (FDataWords[lStartStatusWord + 1] Shr k and 1 <> 0);
                    if j < 3 then
                    begin
                      inc(j);
                    end;
                  end
                  else
                  begin
                    // Odd numbered bits = Under-range
                    ChannelUnderRangeFlag[j] := (FDataWords[lStartStatusWord + 1] Shr k and 1 <> 0);
                  end; // If
                end; // For k
                ModuleError := lModuleError;
              end; // With
            end; // 4
        5 : begin // Relayed Digital Output Module
              lRelayedDigitalOutputModule := TRelayedDigitalOutputModule.Create;
              with lRelayedDigitalOutputModule do
              begin
                lStartDataWord := ModuleWords[0,0];
                RelayedDigitalOutputData := FDataBits[lStartDataWord];
              end; // With
            end; // 5
        6 : begin // RTD Analog Input Module
              lRTDAnalogInputModule := (FModules[i] as TRTDAnalogInputModule);
              with lRTDAnalogInputModule do
              begin
                lStartDataWord := ModuleWords[0,0];
                lEndDataWord := ModuleWords[0,1];
                lStartStatusWord := ModuleWords[1,0];
                // The RTD Analog Input expansion module (IR4) provides 6 words of data:
                //   Words 0-3 :                      = Channels 0-3 data
                //   Word 4    : bits 0-3             = Channels 0-3 status
                //             : bits 8-11 (IR4 only) = Channels 0-3 Open-Circuit status
                //   Word 5    : bits 15,13,11,9      = Channels 0-3 Under-Range status
                //             : bits 14,12,10,8      = Channels 0-3 Over-Range status
                ChannelDataValue[0] := FDataWords[lStartDataWord];
                ChannelDataValue[1] := FDataWords[lStartDataWord + 1];
                ChannelDataValue[2] := FDataWords[lStartDataWord + 2];
                ChannelDataValue[3] := FDataWords[lEndDataWord];
                for k := 0 to 3 do
                begin
                  ChannelStatus[k] := (FDataWords[lStartStatusWord] Shr k and 1) <> 0;
                  lModuleError := lModuleError or ChannelStatus[k];
                end; // For k
                j := 0;
                for k := 8 to 11 do
                begin
                  ChannelOpenCircuitFlag[j] := (FDataWords[lStartStatusWord] Shr k and 1) <> 0;
                  lModuleError := lModuleError or ChannelOpenCircuitFlag[j];
                  inc(j);
                end; // For k
                j := 0;
                for k := 15 downto 8 do
                begin
                  lModuleError := lModuleError or ((FDataWords[lStartStatusWord + 1] Shr k and 1 <> 0));
                  if (k mod 2) = 0 then
                  begin
                    // Even numbered bits = Over-range
                    ChannelOverRangeFlag[j] := ((FDataWords[lStartStatusWord + 1] Shr k and 1 <> 0));
                    if j < 3 then
                    begin
                      inc(j);
                    end;
                  end
                  else
                  begin
                    // Odd numbered bits = Under-range
                    ChannelUnderRangeFlag[j] := ((FDataWords[lStartStatusWord + 1] Shr k and 1 <> 0));
                  end; // If
                end; // For k
                ModuleError := lModuleError;
              end; // With
            end; // 6
      end; // Case
    end; // For i
    if Not Terminated then
      Synchronize(DoPassModuleData);
  end; // If
end; // TMicroLogixPLC.PopulateModules

procedure TMicroLogixPLC.SavePLCConfiguration;
var
  INIFile : TStRegINI;
  i : integer;
begin
  if FileExists(FConfigurationFile) then
  begin
    if Assigned(FPLCReadThread) then
    begin
      Modules := FPLCReadThread.Modules;
      ModuleType := FPLCReadThread.ModuleTypes;
      FModuleCount := FPLCReadThread.ModuleCount;
      INIFile := TStRegINI.Create(FConfigurationFile,True);
      try
        try
          with INIFile do
          begin
            CurSubKey := 'PLC';
            WriteString('ReadIPAddress',GetReadIPAddress);
            WriteString('WriteIPAddress',GetWriteIPAddress);
            WriteInteger('NumberOfDataWords',GetDataSize);
            WriteInteger('NumberofStatusWords',GetStatusSize);
            WriteInteger('WatchdogBit',FWatchdogBitNumber);
            WriteInteger('WatchdogWord',FWatchDogWordNumber);
            WriteInteger('WatchdogInterval',FWatchdogInterval);
            WriteInteger('WatchDogTimeOut',FWatchDogTimeOut);
            WriteInteger('ModulesInstalled',FModuleCount);
            if FModuleCount > 0 then
            begin
              for i := 0 to (FModuleCount - 1) do
              begin
                CurSubKey := format('Module%d',[i]);
                WriteInteger('ModuleType',ModuleType[i]);
                case ModuleType[i] of
                  0 : begin // Main Module
                        WriteInteger('ModuleType',(Modules[i] as TPLCMainModule).ModuleType);
                        WriteInteger('ModuleNumber',(Modules[i] as TPLCMainModule).ModuleNumber);
                        // Digital
                        WriteInteger('StartDigitalInputWord',(Modules[i] as TPLCMainModule).DigitalInputModuleWords[0,0]);
                        WriteInteger('EndDigitalInputWord',(Modules[i] as TPLCMainModule).DigitalInputModuleWords[0,1]);
                        WriteInteger('StartDigitalOutputDataWord',(Modules[i] as TPLCMainModule).DigitalOutputModuleWords[0,0]);
                        WriteInteger('EndDigitalOutputDataWord',(Modules[i] as TPLCMainModule).DigitalOutputModuleWords[0,1]);
                        // Analog
                        WriteInteger('StartAnalogInputWord',(Modules[i] as TPLCMainModule).AnalogInputModuleWords[0,0]);
                        WriteInteger('EndAnalogInputWord',(Modules[i] as TPLCMainModule).AnalogInputModuleWords[0,1]);
                        WriteInteger('StartAnalogInputStatusWord',(Modules[i] as TPLCMainModule).AnalogInputModuleWords[1,0]);
                        WriteInteger('EndAnalogInputStatusWord',(Modules[i] as TPLCMainModule).AnalogInputModuleWords[1,1]);
                        WriteInteger('StartAnalogOutputDataWord',(Modules[i] as TPLCMainModule).AnalogOutputModuleWords[0,0]);
                        WriteInteger('EndAnalogOutputDataWord',(Modules[i] as TPLCMainModule).AnalogOutputModuleWords[0,1]);
                        WriteInteger('StartAnalogOutputStatusWord',(Modules[i] as TPLCMainModule).AnalogOutputModuleWords[1,0]);
                        WriteInteger('EndAnalogOutputStatusWord',(Modules[i] as TPLCMainModule).AnalogOutputModuleWords[1,1]);
                        WriteInteger('StartRequestBitsWord',(Modules[i] as TPLCMainModule).RequestBits_ModuleWords[0,0]);
                        WriteInteger('EndRequestBitsWord',(Modules[i] as TPLCMainModule).RequestBits_ModuleWords[0,1]);
                      end; // 0
                  1 : begin // Digital Input Module
                        WriteInteger('ModuleType',(Modules[i] as TDigitalInputModule).ModuleType);
                        WriteInteger('ModuleNumber',(Modules[i] as TDigitalInputModule).ModuleNumber);
                        WriteInteger('StartDataWord',(Modules[i] as TDigitalInputModule).ModuleWords[0,0]);
                        WriteInteger('EndDataWord',(Modules[i] as TDigitalInputModule).ModuleWords[0,1]);
                        WriteInteger('StartStatusWord',(Modules[i] as TDigitalInputModule).ModuleWords[1,0]);
                        WriteInteger('EndStatusWord',(Modules[i] as TDigitalInputModule).ModuleWords[1,1]);
                      end; // 1
                  2 : begin // Digital OutputModule
                        WriteInteger('ModuleType',(Modules[i] as TDigitalOutputModule).ModuleType);
                        WriteInteger('ModuleNumber',(Modules[i] as TDigitalOutputModule).ModuleNumber);
                        WriteInteger('StartDataWord',(Modules[i] as TDigitalOutputModule).ModuleWords[0,0]);
                        WriteInteger('EndDataWord',(Modules[i] as TDigitalOutputModule).ModuleWords[0,1]);
                        WriteInteger('StartStatusWord',(Modules[i] as TDigitalOutputModule).ModuleWords[1,0]);
                        WriteInteger('EndStatusWord',(Modules[i] as TDigitalOutputModule).ModuleWords[1,1]);
                      end; // 2
                  3 : begin // Analog Input Module
                        WriteInteger('ModuleType',(Modules[i] as TAnalogInputModule).ModuleType);
                        WriteInteger('ModuleNumber',(Modules[i] as TAnalogInputModule).ModuleNumber);
                        WriteInteger('StartDataWord',(Modules[i] as TAnalogInputModule).ModuleWords[0,0]);
                        WriteInteger('EndDataWord',(Modules[i] as TAnalogInputModule).ModuleWords[0,1]);
                        WriteInteger('StartStatusWord',(Modules[i] as TAnalogInputModule).ModuleWords[1,0]);
                        WriteInteger('EndStatusWord',(Modules[i] as TAnalogInputModule).ModuleWords[1,1]);
                      end; // 3
                  4 : begin // Analog Output Module
                        WriteInteger('ModuleType',(Modules[i] as TAnalogOutputModule).ModuleType);
                        WriteInteger('ModuleNumber',(Modules[i] as TAnalogOutputModule).ModuleNumber);
                        WriteInteger('StartDataWord',(Modules[i] as TAnalogOutputModule).ModuleWords[0,0]);
                        WriteInteger('EndDataWord',(Modules[i] as TAnalogOutputModule).ModuleWords[0,1]);
                        WriteInteger('StartStatusWord',(Modules[i] as TAnalogOutputModule).ModuleWords[1,0]);
                        WriteInteger('EndStatusWord',(Modules[i] as TAnalogOutputModule).ModuleWords[1,1]);
                      end; // 4
                  5 : begin // Relayed Digital Ouput Module
                        WriteInteger('ModuleType',(Modules[i] as TRelayedDigitalOutputModule).ModuleType);
                        WriteInteger('ModuleNumber',(Modules[i] as TRelayedDigitalOutputModule).ModuleNumber);
                        WriteInteger('StartDataWord',(Modules[i] as TRelayedDigitalOutputModule).ModuleWords[0,0]);
                        WriteInteger('EndDataWord',(Modules[i] as TRelayedDigitalOutputModule).ModuleWords[0,1]);
                        WriteInteger('StartStatusWord',(Modules[i] as TRelayedDigitalOutputModule).ModuleWords[1,0]);
                        WriteInteger('EndStatusWord',(Modules[i] as TRelayedDigitalOutputModule).ModuleWords[1,1]);
                      end; // 5
                  6 : begin // RTD Analog Input Module
                        WriteInteger('ModuleType',(Modules[i] as TRTDAnalogInputModule).ModuleType);
                        WriteInteger('ModuleNumber',(Modules[i] as TRTDAnalogInputModule).ModuleNumber);
                        WriteInteger('StartDataWord',(Modules[i] as TRTDAnalogInputModule).ModuleWords[0,0]);
                        WriteInteger('EndDataWord',(Modules[i] as TRTDAnalogInputModule).ModuleWords[0,1]);
                        WriteInteger('StartStatusWord',(Modules[i] as TRTDAnalogInputModule).ModuleWords[1,0]);
                        WriteInteger('EndStatusWord',(Modules[i] as TRTDAnalogInputModule).ModuleWords[1,1]);
                      end; // 3
                end; // Case
                Modules[i].Free;
                Modules[i] := nil;
              end; // For i
            end; // If
          end; // With
        except
          DoConfigurationError(8,format('Error saving configuration file "%s".',[FConfigurationFile]));
        end; // Try E
      finally
        INIFile.Free;
      end; // Try F
    end; // If
  end; // If
end; // TMicroLogixPLC.SavePLCConfiguration

procedure TMicroLogixPLC.DoConfigurationError(ErrorNum : LongInt; ErrorMsg : String);
begin
  if Assigned(FOnConfigurationError) then
    FOnConfigurationError(Self,ErrorNum,ErrorMsg)
  else
    MessageDlg(format('PLC Configuraiton Error# %d' +#13#10+
                      '%s',[ErrorNum,ErrorMsg]),mtError,[mbOK],0);
end; // TMicroLogixPLC.DoConfigurationError

procedure TMicroLogixPLC.ClearWatchDogAccumulator(WatchDog : String);
var
  WatchDogACC : String;
begin
  if (WatchDog <> '') then
  begin // Clear timer accumulator...
    if (OccuranceNo(WatchDog,'.',False) > 0) then
      WatchDogACC := ExtractFromString(WatchDog,1,(MatchString(WatchDog,'.',1,1,False,False) - 1));
    WatchDogACC := WatchDogACC + '.ACC';
    FPLCWriteThread.WriteWordToPLC(WatchDogACC,0,1,0);
  end; // If
end; // TMicroLogixPLC.ClearWatchDogAccumulator

procedure TMicroLogixPLC.LoadOptionalParams(ValueName : TStringList);
var
  i : LongInt;
  OccNum : Byte;
  OptionalWordRec : TOptionalParamWordRec;
  OptionalBitRec : TOptionalParamBitRec;
  ValueStr : String;
begin
  if Assigned(ValueName) then
  begin
    if (ValueName.Count > 0) then
    begin
      for i := 0 to (ValueName.Count - 1) do
      begin
        ValueStr := ExtractFromString(ValueName.Strings[i],(MatchString(ValueName.Strings[i],'=',1,1,False,False) + 1),Length(ValueName.Strings[i]));
        OccNum := OccuranceNo(ValueStr,';',True);
        if (OccNum > 0) then
        begin
          case OccNum of
            3 : begin
                  FillChar(OptionalWordRec,SizeOf(OptionalWordRec),#0);
                  with OptionalWordRec do
                  begin
                    FileType := ExtractFromString(ValueStr,1,(MatchString(ValueStr,';',1,1,False,False) - 1));
                    WordPos := StrToInt(ExtractFromString(ValueStr,(MatchString(ValueStr,';',1,1,False,False) + 1),(MatchString(ValueStr,';',2,1,False,False) - 1)));
                    Size := StrToInt(ExtractFromString(ValueStr,(MatchString(ValueStr,';',2,1,False,False) + 1),(MatchString(ValueStr,';',3,1,False,False) - 1)));
                    Value := StrToInt(ExtractFromString(ValueStr,(MatchString(ValueStr,';',3,1,False,False) + 1),Length(ValueStr)));
                    WriteWordToPLC(FileType,WordPos,Size,Value);
                  end; // With
                end; // Word
            4 : begin
                  FillChar(OptionalBitRec,SizeOf(OptionalBitRec),#0);
                  with OptionalBitRec do
                  begin
                    FileType := ExtractFromString(ValueStr,1,(MatchString(ValueStr,';',1,1,False,False) - 1));
                    WordPos := StrToInt(ExtractFromString(ValueStr,(MatchString(ValueStr,';',1,1,False,False) + 1),(MatchString(ValueStr,';',2,1,False,False) - 1)));
                    Size := StrToInt(ExtractFromString(ValueStr,(MatchString(ValueStr,';',2,1,False,False) + 1),(MatchString(ValueStr,';',3,1,False,False) - 1)));
                    BitPos := StrToInt(ExtractFromString(ValueStr,(MatchString(ValueStr,';',3,1,False,False) + 1),(MatchString(ValueStr,';',4,1,False,False) - 1)));
                    Value := (StrToInt(ExtractFromString(ValueStr,(MatchString(ValueStr,';',4,1,False,False) + 1),Length(ValueStr))) = 1);
                    WriteBitToPLC(FileType,WordPos,BitPos,Size,Value);
                  end; // With
                end; // Bit
          end; // Case
        end; // If
      end; // For i
    end; // If
  end; // If
end; // TMicroLogixPLC.LoadOptionalParams

procedure TMicroLogixPLC.SaveOptionalWordParam(ParamNumber : LongInt; FileType : ShortString; WordPos : Byte; Size : Byte; Value : SmallInt);
var
  INIFile : TStRegINI;
begin
  if FileExists(FConfigurationFile) then
  begin
    INIFile := TStRegIni.Create(FConfigurationFile,True);
    with INIFile do
    begin
      CurSubKey := 'Optional';
      WriteString(format('Param%d',[ParamNumber]),format('%s;%d;%d;%d',[FileType,WordPos,Size,Value]));
      Free;
    end; // With
  end; // If
end; // TMicroLogixPLC.SaveOptionalWordParam

procedure TMicroLogixPLC.SaveOptionalBitParam(ParamNumber : LongInt; FileType : ShortString; WordPos : Byte; BitPos : Byte; Size : Byte; Value : Boolean);
var
  INIFile : TStRegINI;
begin
  if FileExists(FConfigurationFile) then
  begin
    INIFile := TStRegINI.Create(FConfigurationFile,True);
    with INIFile do
    begin
      CurSubKey := 'Optional';
      WriteString(format('Param%d',[ParamNumber]),format('%s;%d;%d;%d;%d',[FileType,WordPos,BitPos,Size,Ord(Value)]));
      Free;
    end; // With
  end; // If
end; // TMicroLogixPLC.SaveOptionalBirParam

function TMicroLogixPLC.GetErrorMessage(nErrorCode : TintErrorCode) : ShortString;
var
  msg : ShortString;
begin
  case nErrorCode of
         0 : msg := 'No Errors Have occured.';
    // ----------------- INGEAR COMPONENT ERROR MESSAGES -------------------------
    {$IFDEF INGEAR_Version_52}
    -32768 : msg := 'IN-GEAR Says: compatability mode file missing.';
    -28672 : msg := 'IN-GEAR Says: Remote node cannot buffer command';
    -20480 : msg := 'IN-GEAR Says: Remote node problem due to download.';
    -16284 : msg := 'IN-GEAR Says: Cannot execute due to active IPBS.';
    -4095  : msg := 'IN-GEAR Says: A field has an illegal value.';
    -4094  : msg := 'IN-GEAR Says: Less levels specified in adddress than minimum for any address.';
    -4093  : msg := 'IN-GEAR Says: More levels specified in address than system supports.';
    -4092  : msg := 'IN-GEAR Says: Symbol not found.';
    -4091  : msg := 'IN-GEAR Says: Symbol is not proper format.';
    -4090  : msg := 'IN-GEAR Says: File address doesn''t point to something useful.';
    -4089  : msg := 'IN-GEAR Says: File is wrong size.';
    -4088  : msg := 'IN-GEAR Says: Cannot complete request.';
    -4087  : msg := 'IN-GEAR Says: Data or file is too large.';
    -4086  : msg := 'IN-GEAR Says: Transaction plus word size is too large.';
    -4085  : msg := 'IN-GEAR Says: Access Denied.';
    -4084  : msg := 'IN-GEAR Says: Condition cannot be generated.';
    -4083  : msg := 'IN-GEAR Says: Condition already exists.';
    -4082  : msg := 'IN-GEAR Says: Command cannot be executed.';
    -4081  : msg := 'IN-GEAR Says: Histogram overflow.';
    -4080  : msg := 'IN-GEAR Says: No Access.';
    -4079  : msg := 'IN-GEAR Says: Illegal data type.';
    -4078  : msg := 'IN-GEAR Says: Invalid paramerter or invalid data.';
    -4077  : msg := 'IN-GEAR Says: Address reference exists to deleted area.';
    -4076  : msg := 'IN-GEAR Says: Command execution failure for unknown reason';
    -4075  : msg := 'IN-GEAR Says: Data Conversion Error.';
    {$ENDIF}
    -1     : msg := 'IN-GEAR Says: The Adapter Property is pointing to an adpater that has not been properly configured, or is not operating.';
    -2     : msg := 'IN-GEAR Says: Reserved';
    -3     : msg := 'IN-GEAR Says: The PLC did not respoind to the Read/Write request and the IN-GEAR driver timed out.';
    -4     : msg := 'IN-GEAR Says: The Ethernet PLC did not respond with in the required time. TIMEOUT.';
    -5     : msg := 'IN-GEAR Says: IN-GEAR driver error. More than one application or process is trying to use a KT/KTx/SST/DF1 connection on the PLC Network.';
    -6     : msg := 'IN-GEAR Says: Invalid funtion for this PLC.';
    -7     : msg := 'IN-GEAR Says: Ethernet connection request failed to PLC.';
    260    : msg := 'IN-GEAR Says: Invalid Tag Name.';
    511    : msg := 'IN-GEAR Says: Invalid data type for tag name(ControlLogix5550) - invalid type-declaration character for tag name.';
    512    : msg := 'IN-GEAR Says: Cannot guarantee delivery. Invalid node assigned.  Non existing DH+/DH-485 network address.';
    768    : msg := 'IN-GEAR Says: Duplicate token hold detected.';
    1024   : msg := 'IN-GEAR Says: Local port is disconnected.';
    1280   : msg := 'IN-GEAR Says: Application layer timed out waiting for response.';
    1536   : msg := 'IN-GEAR Says: Duplicate Node detected.';
    1792   : msg := 'IN-GEAR Says: Station is offline';
    2048   : msg := 'IN-GEAR Says: Hardware Fault';
    4096   : msg := 'IN-GEAR Says: Illegal command format.  The PLC does not recognize the FileAddr Property setting or cannot execute the Function Property command.';
    8192   : msg := 'IN-GEAR Says: Host has problems and cannot commuicate.';
    12288  : msg := 'IN-GEAR Says: Remote node is missing, disconnected or shutdown.';
    16384  : msg := 'IN-GEAR Says: Host could not complete function due to hardware fault.';
    20480  : msg := 'IN-GEAR Says: Addressing Problem.';
    24576  : msg := 'IN-GEAR Says: Function disallowed.';
    28672  : msg := 'IN-GEAR Says: Processor in program mode.';
    30539  : msg := 'IN-GEAR Says: INGEAR license is invalid or has expired.';
    {$IFDEF INGEAR_Version_60}
    // Expanded Micrologix/SLC/PLC-5 Error Codes
    32768  : msg := 'IN-GEAR Says: Compatibility mode file missing.';
    36864  : msg := 'IN-GEAR Says: Remote node cannot buffer command.';
    45056  : msg := 'IN-GEAR Says: Remote node problem due to download.';
    49152  : msg := 'IN-GEAR Says: Cannot execute due to active IPBS.';
    61441  : msg := 'IN-GEAR Says: A fild has an illegal value.';
    61442  : msg := 'IN-GEAR Says: Less levels specified in address than system supports.';
    61443  : msg := 'IN-GEAR Says: More levels specified in address than system supports.';
    61444  : msg := 'IN-GEAR Says: Symbol not found';
    61445  : msg := 'IN-GEAR Says: Symbol is not proper format.';
    61446  : msg := 'IN-GEAR Says: File address doesn''t point to something useful.';
    61447  : msg := 'IN-GEAR Says: File is wrong size.';
    61448  : msg := 'IN-GEAR Says: Cannot complete request.';
    61449  : msg := 'IN-GEAR Says: Data or file is too large.';
    61450  : msg := 'IN-GEAR Says: Transaction plus word size is too large.';
    61451  : msg := 'IN-GEAR Says: Access denied.';
    61452  : msg := 'IN-GEAR Says: Condition cannot be generated.';
    61453  : msg := 'IN-GEAR Says: Condition already exists.';
    61454  : msg := 'IN-GEAR Says: Command cannot be executed.';
    61455  : msg := 'IN-GEAR Says: Histogram Overflow.';
    61456  : msg := 'IN-GEAR Says: No access.';
    61457  : msg := 'IN-GEAR Says: Illegal data type.';
    61458  : msg := 'IN-GEAR Says: Invalid parameteror invalid data.';
    61459  : msg := 'IN-GEAR Says: Address reference exists to deleted area.';
    61460  : msg := 'IN-GEAR Says: Command execution failure for unknown reason.';
    61461  : msg := 'IN-GEAR Says: Data conversion error.';
    // Ethernet IP and CIP Error Codes
    1      : msg := 'IN-GEAR Says: Connection failure.';
    2      : msg := 'IN-GEAR Says: Insufficient resources.';
    3      : msg := 'IN-GEAR Says: Value invalid.';
    4      : msg := 'IN-GEAR Says: Malformed tag or tag does not exist.';
    5      : msg := 'IN-GEAR Says: Unknown destination.';
    6      : msg := 'IN-GEAR Says: Data requested would not fin in response packet.';
    7      : msg := 'IN-GEAR Says: Loss of connection.';
    8      : msg := 'IN-GEAR Says: Unsupported service.';
    9      : msg := 'IN-GEAR Says: Error in data segment or inalid attribute value.';
    10     : msg := 'IN-GEAR Says: Attribute list error.';
    11     : msg := 'IN-GEAR Says: State already exists.';
    12     : msg := 'IN-GEAR Says: Object model conflict.';
    13     : msg := 'IN-GEAR Says: Object already exists.';
    14     : msg := 'IN-GEAR Says: Attribute not settable.';
    15     : msg := 'IN-GEAR Says: Permission Denied.';
    16     : msg := 'IN-GEAR Says: Device state conflict.';
    17     : msg := 'IN-GEAR Says: Relpy to large.';
    18     : msg := 'IN-GEAR Says: Fragment primitive.';
    19     : msg := 'IN-GEAR Says: Insufficient command data or parameters specified to execute service.';
    20     : msg := 'IN-GEAR Says: Attribute not supported.';
    21     : msg := 'IN-GEAR Says: Too much data specified.';
    26     : msg := 'IN-GEAR Says: Bridge request too large.';
    27     : msg := 'IN-GEAR Says: Bridge response too large.';
    28     : msg := 'IN-GEAR Says: Attribute list short.';
    29     : msg := 'IN-GEAR Says: Invalid attribute list.';
    30     : msg := 'IN-GEAR Says: Failure during connection.';
    34     : msg := 'IN-GEAR Says: Invalid received.';
    35     : msg := 'IN-GEAR Says: Key segment error.';
    37     : msg := 'IN-GEAR Says: Number of IO words specified does not match IO word count.';
    38     : msg := 'IN-GEAR Says: Unexpected attribute in list.';
    255    : msg := 'IN-GEAR Says: General Error.';
    // Extended CIP Error Codes
    65792  : msg := 'IN-GEAR Says: Connection failure(Connection in use).';
    65795  : msg := 'IN-GEAR Says: Connection failure(Transport not supported).';
    65798  : msg := 'IN-GEAR Says: Connection failure(Ownership conflict).';
    65799  : msg := 'IN-GEAR Says: Connection failure(Connection not found).';
    65800  : msg := 'IN-GEAR Says: Connection failure(Invalid connection type).';
    65801  : msg := 'IN-GEAR Says: Connection failure(Invalid connection size).';
    65808  : msg := 'IN-GEAR Says: Connection failure(Module not configured).';
    65809  : msg := 'IN-GEAR Says: Connection failure(ERP not supported).';
    65812  : msg := 'IN-GEAR Says: Connection failure(Wrong module).';
    65813  : msg := 'IN-GEAR Says: Connect failure(Wrong device type).';
    65814  : msg := 'IN-GEAR Says: Connect failure(Wrong revision).';
    65816  : msg := 'IN-GEAR Says: Connect failure(Invalid configuration format).';
    65818  : msg := 'IN-GEAR Says: Connect failure(Application out of connections).';
    66051  : msg := 'IN-GEAR Says: Connect failure(Connection timeout).';
    66053  : msg := 'IN-GEAR Says: Connect failure(Unconnected message timeout).';
    66054  : msg := 'IN-GEAR Says: Connect failure(Message too large).';
    66305  : msg := 'IN-GEAR Says: Connect failure(No buffer memory).';
    66306  : msg := 'IN-GEAR Says: Connect failure(Bandwidth not available).';
    66307  : msg := 'IN-GEAR Says: Connect failure(No screeners available).';
    66309  : msg := 'IN-GEAR Says: Connect failure(Signature match).';
    66321  : msg := 'IN-GEAR Says: Connect failure(Port not available).';
    66322  : msg := 'IN-GEAR Says: Connect failure(Link address not available).';
    66325  : msg := 'IN-GEAR Says: Connect failure(Invalid segment type).';
    66327  : msg := 'IN-GEAR Says: Connect failure(Connection not scheduled).';
    66328  : msg := 'IN-GEAR Says: Connect failure(Link address to self is invalid).';
    {$ENDIF}
    // ------------------ END INGEAR COMPONENT ERROR MESSAGES --------------------
    // ------------------ WINSOCK ERROR MESSAGES ---------------------------------
    10004  : msg := 'Winsock Says: A blocking operation was interruped by a call to WSACancelBlockingCall.';
    10013  : msg := 'Winsock Says: An attempt was made to access a socket in a way forbidden by its access permissions.';
    10014  : msg := 'Winsock Says: The system detected an invalid pointer address in attempting to use a pointer argument in a call.';
    10024  : msg := 'Winsock Says: Too man open sockets.';
    10035  : msg := 'Winsock Says: A non-blocking socket operation could not be completed immediately';
    10036  : msg := 'Winsock Says: A blocking opperation is currently executing.';
    10037  : msg := 'Winsock Says: An operation was attempted on a non-blocking socket that already had an operation in progress.';
    10038  : msg := 'Winsock Says: An operation was attempted on something that is not a socket.';
    10050  : msg := 'Winsock Says: A socket operation encountered a dead network.';
    10051  : msg := 'Winsock Says: A socket operation was attempted to an unreachable network.';
    10052  : msg := 'Winsock Says: The connection has been broken due to keep-alive activity detecting a failure while the operation was in progress.';
    10053  : msg := 'Winsock Says: An established connection was aborted by the software in your host machine.';
    10054  : msg := 'Winsock Says: An existing connection was forcibly closed by the remote host.';
    10055  : msg := 'Winsock Says: An operation on a socket could not be performed because the system lacked sufficient buffer space or because a queue was full.';
    10056  : msg := 'Winsock Says: A connect request was made on an already connected socket.';
    10057  : msg := 'Winsock Says: A request to send or recieve data was disallowed because the socket is not connected and (when sending on a datagram socket using sendto call) no address was supplied.';
    10058  : msg := 'Winsock Says: A request to send or recieve was disallowed because the socket had already been shutdown in that direction with previous shutdown call.';
    10059  : msg := 'Winsock Says: Too many references to some kernel object.';
    10060  : msg := 'Winsock Says: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection fialed because connected host has failed to respond.';
    10061  : msg := 'Winsock Says: No connection could be made because the traget machine activley refused it.';
    10062  : msg := 'Winsock Says: Cannot translate name.';
    10063  : msg := 'Winsock Says: Name component or name was too long.';
    10064  : msg := 'Winsock Says: A socket operation failed because the destination host was down.';
    10065  : msg := 'Winsock Says: A socket operation was attempted to an unreachable host.';
    10067  : msg := 'Winsock Says: A Windows Sockets implementation may have a limit on the number of applications that may use it simultaneously.';
    // ------------------ END WINSOCK ERROR MESSAGES -----------------------------
  else
    msg := 'Undocumented Error.'
  end; // Case
  Result := msg;
end; // TMicroLogixPLC.GetErrorMessage

function TMicroLogixPLC.GetLastReadError : ShortString;
begin
  if Assigned(FPLCReadThread) then
    Result := GetErrorMessage(FPLCReadThread.LastError)
  else
    Result := '';
end; // TMicroLogixPLC.GetLastReadError

function TMicroLogixPLC.GetLastWriteError : ShortString;
begin
  if Assigned(FPLCWriteThread) then
    Result := GetErrorMessage(FPLCWriteThread.LastError)
  else
    Result := '';
end; // TMicroLogixPLC.GetLastWriteError

procedure TMicroLogixPLC.ResetPLC;
begin
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadFault := False;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteFault := False;
end; // TMicroLogixPLC.ResetPLC

procedure TMicroLogixPLC.SetVersion(Value : ShortString);
begin
  // Do Nothing...
end; // TMicroLogixPLC.SetVersion

procedure TPLCReadThread.DoReadRecoverableErrorEvent;
begin
  if Assigned(PLCMonitor.OnReadRecoverableError) then
    PLCMonitor.OnReadRecoverableError(Self,FReadErrorNum,FReadErrorStr);
end; // TPLCReadThread.DoReadRevocerbleErrorEvent

procedure TPLCWriteThread.DoWriteRecoverableErrorEvent;
begin
  if Assigned(PLCMonitor.OnWriteRecoverableError) then
    PLCMonitor.OnWriteRecoverableError(Self,FWriteErrorNum,FWriteErrorStr);
end; // TPLCWriteThread.DoWriteRecoverableErrorEvent

procedure TMicroLogixPLC.SetWatchDogTimeOut(Value : LongInt);
begin
  FWatchDogTimeOut := Value;
  if Assigned(FPLCWriteThread) then
  begin
    if FEnabled then
    begin
      if (FWatchDogHi <> '') and (FWatchDogLo <> '') then
      begin
        FPLCWriteThread.WriteWordToPLC(FWatchDogHi,0{PRE},1,FWatchDogTimeOut);
        FPLCWriteThread.WriteWordToPLC(FWatchDogLo,0{PRE},1,FWatchDogTimeOut);
      end
      else
      begin
        if (FWatchDogHi = '') then
          DoConfigurationError(1,'WatchdogHi Name not assigned!');
        if (FWatchDogLo = '') then
          DoConfigurationError(2,'WatchDogLo Name not assigned!');
      end; // If
    end; // If
  end; // If
end; // TMicroLogixPLC.SetWatchDogTimeOut

procedure TPLCReadThread.DoReturnValueFromPLC;
begin
  if Assigned(PLCMonitor.OnValueReadFromPLC) then
    PLCMonitor.OnValueReadFromPLC(Self,FReadPacketRec);
end; // TPLCReadThread.DoReturnValueFromPLC

procedure TPLCReadThread.AddToReadStack(lPacket : TPLCReadPacket);
begin
  if Assigned(FReadStack) then
  begin
    if Assigned(lPacket) then
    begin
      if Get_ThreadReadStackAccess(1000{ms}) then
      begin
        FReadStack.AddObject(IntToStr(FReadStack.Count + 1),lPacket);
        Release_ThreadReadStackAccess;
      end
      else
        lPacket.Free;
    end; // If
  end; // If
end; // TPLCReadThread.AddToReadStack

function TPLCReadThread.Get_ThreadReadStackAccess(TimeOutms : DWord) : Boolean;
begin
  Result := (WaitForSingleObject(UsingReadStack,TimeOutms) = Wait_Object_0);
end; // TPLCReadThread.Get_ThreadReadStackAccess

procedure TPLCReadThread.Release_ThreadReadStackAccess;
begin
  ReleaseSemaphore(UsingReadStack,1,Nil);
end; // TPLCReadThread.Release_ThreadReadStackAccess

procedure TPLCReadThread.ReadBitFromPLC(pFile : ShortString; pWordNumber : integer; BitNumber : integer; intSize : integer);
var
  PLCReadPacket : TPLCReadPacket;
begin
  PLCReadPacket := TPLCReadPacket.Create;
  with PLCReadPacket do
  begin
    Size := intSize;
    FileType := pFile;
    WordNumber := pWordNumber;
    BitPosition := BitNumber;
    ReadBit := True;
    TransactionPhase := 0;
  end; // With
  AddToReadStack(PLCReadPacket);
end; // TPLCReadThread.ReadBitFromPLC

procedure TPLCReadThread.ReadWordFromPLC(pFile : ShortString; pWordNumber : integer; intSize : integer);
var
  PLCReadPacket : TPLCReadPacket;
begin
  PLCReadPacket := TPLCReadPacket.Create;
  with PLCReadPacket do
  begin
    Size := intSize;
    FileType := pFile;
    WordNumber := pWordNumber;
    ReadWord := True;
    TransactionPhase := 0;
  end; // With
  AddToReadStack(PLCReadPacket);
end; // TPLCReadThread.ReadWordFromPLC

procedure TMicroLogixPLC.ReadBitFromPLC(pFile : ShortString; pWordNumber : integer; BitNumber : integer; intSize : integer);
begin
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadBitFromPLC(pFile,pWordNumber,BitNumber,intSize);
end; // TMicroLogixPLC.ReadBitFromPLC

procedure TMicroLogixPLC.ReadWordFromPLC(pFile : ShortString; pWordNumber : integer; intSize : integer);
begin
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadWordFromPLC(pFile,pWordNumber,intSize);
end; // TMicroLogixPLC.ReadWordFromPLC

function TMicroLogixPLC.CheckModuleConfigutaion : Boolean;
var
  i : LongInt;
  TempSum : LongInt;
  ConfigError : Boolean;
  lMainModule : TPLCMainModule;
  lDigitalInputModule : TDigitalInputModule;
  lDigitalOutputModule : TDigitalOutputModule;
  lAnalogInputModule : TAnalogInputModule;
  lRTDAnalogInputModule : TRTDAnalogInputModule;
  lAnalogOutputModule : TAnalogOutputModule;
  lRelayedDigitalOutputModule : TRelayedDigitalOutputModule;
  StrErrorMessages : ShortString;
begin
  Result := True;
  for i := 0 to (FModuleCount - 1) do
  begin
    StrErrorMessages := '';
    case ModuleType[i] of
      0 : begin // Main Module
            lMainModule := Modules[i] as TPLCMainModule;
            with lMainModule do
            begin
              ConfigError := ((DigitalInputModuleWords[0,1] - DigitalInputModuleWords[0,0]) > 3) or ((DigitalInputModuleWords[0,1] - DigitalInputModuleWords[0,0]) < 0);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Main Module]Invalid range defined for Digital Input Module Words',[ModuleNumber]) + #13#10;
              ConfigError := ((DigitalOutputModuleWords[0,1] - DigitalOutputModuleWords[0,0]) > 3) or ((DigitalOutputModuleWords[0,1] - DigitalOutputModuleWords[0,0]) < 0);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Main Module]Invalid range defined for Digital Output Module Words',[ModuleNumber]) + #13#10;
              ConfigError := ((AnalogInputModuleWords[0,1] - AnalogInputModuleWords[0,0]) > 3) or ((AnalogInputModuleWords[0,1] - AnalogInputModuleWords[0,0]) < 0);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Main Module]Invalid range defined for Analog Input Module Words',[ModuleNumber]) + #13#10;
              ConfigError := ((AnalogOutputModuleWords[0,1] - AnalogOutputModuleWords[0,0]) > 1) or ((AnalogOutputModuleWords[0,1] - AnalogOutputModuleWords[0,0]) < 0);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Main Module]Invalid range defined for Analog Output Module Words',[ModuleNumber]) + #13#10;
              ConfigError := ((RequestBits_ModuleWords[0,1] - RequestBits_ModuleWords[0,0]) > (High(Request_Bits_Status[0]) + 1)) or ((RequestBits_ModuleWords[0,1] - RequestBits_ModuleWords[0,0]) < 0);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Main Module]Invalid range defined for Request Bits Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 0
      1 : begin // Digital Input Module
            lDigitalInputModule := Modules[i] as TDigitalInputModule;
            with lDigitalInputModule do
            begin
              ConfigError := ((ModuleWords[0,1] - ModuleWords[0,0]) > 1) or ((ModuleWords[0,1] - ModuleWords[0,0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Digital Input Module]Invalid range defined for Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 1
      2 : begin // Digital Output Module
            lDigitalOutputModule := Modules[i] as TDigitalOutputModule;
            with lDigitalOutputModule do
            begin
              ConfigError := ((ModuleWords[0,1] - ModuleWords[0,0]) > 1) or ((ModuleWords[0,1] - ModuleWords[0,0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Digital Output Module]Invalid range defined for Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; //2
      3 : begin // Analog Input Module
            lAnalogInputModule := Modules[i] as TAnalogInputModule;
            with lAnalogInputModule do
            begin
              ConfigError := ((ModuleWords[0,1] - ModuleWords[0,0]) > 1) or ((ModuleWords[0,1] - ModuleWords[0,0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Analog Input Module]Invalid range defined for Data Module Words',[ModuleNumber]) + #13#10;
              ConfigError := ((ModuleWords[1,1] - ModuleWords[1,0]) > 1) or ((ModuleWords[1,1] - ModuleWords[1,0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Analog Input Module]Invalid range defined for Status Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 3
      4 : begin // Analog Output Module
            lAnalogOutputModule := Modules[i] as TAnalogOutputModule;
            with lAnalogOutputModule do
            begin
              ConfigError := ((ModuleWords[0,1] - ModuleWords[0,0]) > 1) or ((ModuleWords[0,1] - ModuleWords[0,0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Analog Output Module]Invalid range defined for Data Module Words',[ModuleNumber]) + #13#10;
              ConfigError := ((ModuleWords[1,1] - ModuleWords[1,0]) > 1) or ((ModuleWords[1,1] - ModuleWords[1,0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Analog Output Module]Invalid range defined for Status Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 4
      5 : begin // Relayed Digital Output Module
            lRelayedDigitalOutputModule := Modules[i] as TRelayedDigitalOutputModule;
            with lRelayedDigitalOutputModule do
            begin
              ConfigError := ((ModuleWords[0,1] - ModuleWords[0,0]) > 1) or ((ModuleWords[0,1] - ModuleWords[0,0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Relayed Digital Output Module]Invalid range defined for Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 5
      6 : begin // RTD Analog Input Module
            lRTDAnalogInputModule := Modules[i] as TRTDAnalogInputModule;
            with lRTDAnalogInputModule do
            begin
              ConfigError := ((ModuleWords[0,1] - ModuleWords[0,0]) > 1) or ((ModuleWords[0,1] - ModuleWords[0,0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d RTD Analog Input Module]Invalid range defined for Data Module Words',[ModuleNumber]) + #13#10;
              ConfigError := ((ModuleWords[1,1] - ModuleWords[1,0]) > 1) or ((ModuleWords[1,1] - ModuleWords[1,0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d RTD Analog Input Module]Invalid range defined for Status Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 3
    end; // Case
  end; // For i
  if (StrErrorMessages <> '') then
  begin
    Result := False;
    DoConfigurationError(5,StrErrorMessages);
  end; // If
end; // TMicroLogixPLC.CheckModuleConfiguration

function TMicroLogixPLC.GetReadPacketsInQue : LongInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadQue
  else
    Result := 0;
end; // TMicroLogixPLC.GetReadPacketsInQue

function TMicroLogixPLC.GetWritePacketsInQue : LongInt;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteQue
  else
    Result := 0;
end; // TMicroLogixPLC.GetWritePacketsInQue

function TPLCWriteThread.GetAdapterNum : LongInt;
begin
  if Assigned(FPLCWrite) then
    Result := FPLCWrite.Adapter
  else
    Result := -1;
end; // TPLCWriteThread.GetAdapterNum

procedure TPLCWriteThread.SetAdapterNum(Value : LongInt);
begin
  if Assigned(FPLCWrite) then
    FPLCWrite.Adapter := Value;
end; // TPLCWriteThread.SetAdapter

function TPLCReadThread.GetAdapterNum : LongInt;
begin
  if Assigned(FPLCRead) then
    Result := FPLCRead.Adapter
  else                
    Result := -1;
end; // TPLCReadThread.GetAdapterNum

procedure TPLCReadThread.SetAdapterNum(Value : LongInt);
begin
  if Assigned(FPLCRead) then
    FPLCRead.Adapter := Value;
end; // TPLCReadThread.SetAdapterNum

function TMicroLogixPLC.GetReadAdapterNum : LongInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadAdapterNum
  else
    Result := FReadAdapterNum;
end; // TMicroLogixPLC.GetReadAdapterNum

procedure TMicroLogixPLC.SetReadAdapterNum(Value : LongInt);
begin
  FReadAdapterNum := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadAdapterNum := FReadAdapterNum;
end; // TMicroLogixPLC.SetReadAdapterNum

function TMicroLogixPLC.GetWriteAdapterNum : LongInt;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteAdapterNum
  else
    Result := FWriteAdapterNum;
end; // TMicroLogixPLC.GetWriteAdapterNum

procedure TMicroLogixPLC.SetWriteAdapterNum(Value : LongInt);
begin
  FWriteAdapterNum := Value;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteAdapterNum := Value;
end; // TMicroLogixPLC.SetWriteAdapterNum

function TMicroLogixPLC.GetReadFaultTollerance : LongInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadFaultTollerance
  else
    Result := FReadFaultTollerance;
end; // TMicroLogixPLC.GetReadFaultTollerance

procedure TMicroLogixPLC.SetReadFaultTollerance(Value : LongInt);
begin
  FReadFaultTollerance := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadFaultTollerance := FReadFaultTollerance;
end; // TMicroLogixPLC.SetReadFaultTollerance

function TMicroLogixPLC.GetWriteFaultTollerance : LongInt;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteFaultTollerance
  else
    Result := FWriteFaultTollerance;
end; // TMicroLogixPLC.GetWriteFaultTollerance

procedure TMicroLogixPLC.SetWriteFaultTollerance(Value : LongInt);
begin
  FWriteFaultTollerance := Value;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteFaultTollerance := FWriteFaultTollerance;
end; // TMicroLogixPLC.SetWriteFaultTollerance

procedure TPLCWriteThread.PLCWriteWriteDone(Sender : TObject);
begin
  FWriteFaultCount := 0;
end; // TPLCWriteThread.PLCWriteWriteDone

function TPLCReadThread.GetReadFaultTol : LongInt;
begin
  Result := FReadFaultTol;
end; // TPLCReadThread.GetReadFaultToll

procedure TPLCReadThread.SetReadFaultTol(Value : LongInt);
begin
  FReadFaultTol := Value;
end; // TPLCReadThread.SetReadFaultToll

function TPLCWriteThread.GetWriteFaultTol : LongInt;
begin
  Result := FWriteFaultTol;
end; // TPLCWriteThread.GetWriteFaultTol

procedure TPLCWriteThread.SetWriteFaultTol(Value : LongInt);
begin
  FWriteFaultTol :=  Value;
end; // TPLCWriteThread.SetWriteFaultTol

procedure TMicroLogixPLC.SetEthernetTimeOut(Value : SmallInt);
begin
  FEthernetTimeOut := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.EthernetTimeOut := FEthernetTimeOut;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.EthernetTimeOut := FEthernetTimeOut;
end; // TMicroLogixPLC.SetEthernetTimeOut

function TMicroLogixPLC.GetEthernetTimeOut : SmallInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.EthernetTimeOut
  else
    Result := FEthernetTimeOut;
end; // TMicroLogixPLC.GetEthernetTimeOut

procedure TPLCReadThread.SetEthernetTimeOut(Value : SmallInt);
begin
  FPLCRead.Timeout := Value;
end; // TPLCReadThread.SetEthernetTimeOut

function TPLCReadThread.GetEthernetTimeOut : SmallInt;
begin
  Result := FPLCRead.Timeout;
end; // TPLCReadThread.GetEthernetTimeOut

procedure TPLCWriteThread.SetEthernetTimeOut(Value : SmallInt);
begin
  FPLCWrite.Timeout := Value;
end; // TPLCWriteThread.SetEthernetTimeOut

function TPLCWriteThread.GetEthernetTimeOut : SmallInt;
begin
  Result := FPLCWrite.Timeout;
end; // TPLCWriteThread.GetEthernetTimeOut

procedure TMicroLogixPLC.SetMaximumWriteAttempts(Value : LongInt);
begin
  FMaximumWriteAttempts := Value;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteAttemptsBeforeFail := FMaximumWriteAttempts
end; // TMicroLogixPLC.SetMaximumWriteAttempts

function TMicroLogixPLC.GetMaximumWriteAttempts : LongInt;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteAttemptsBeforeFail
  else
    Result := FMaximumWriteAttempts;
end; // TMicroLogixPLC.GetMaximumWriteAttemps

Initialization
UsingWriteStack := CreateSemaphore(Nil,1,1,'WriteSemaphore');
UsingReadStack := CreateSemaphore(Nil,1,1,'ReadSemaphore');
// Initialize Semaphores
ReleaseSemaphore(UsingWriteStack,1,Nil);
ReleaseSemaphore(UsingReadStack,1,Nil);

Finalization
CloseHandle(UsingWriteStack);
CloseHandle(UsingReadStack);

end.

