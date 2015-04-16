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

unit PLCMonitor;

interface

uses Windows, Forms, Messages, SysUtils, Classes, StdCtrls, ExtCtrls, ABCTLLib_TLB,
     OleCtrls,StRegINI;

const
  MaximumModules = 20;
Type
{$IFDEF INGEAR_Version_52}
 TintErrorCode = smallint;
{$endif}
{$IFDEF INGEAR_Version_60}
 TintErrorCode = longint;
{$endif}

 TBitArray = array[0..15] of Boolean;
 TWord = SmallInt;
 TBitsArray = array[0..99] of TBitArray;
 TWordsArray = array[0..99] of TWord;
 TModuleWords = array[0..1,0..1] of integer; // Index zero is the location of the first module word the second index holds the location of the last module word

 TPLCWritePacket = Class(TObject)
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

// TProcessorInfo = packed record
//                    ProcessorMode : Integer;
// end; // TProcessorInfo

 TModule = record // Generic Module container
             ModuleNumber : Integer;
             ModuleType : Integer; // 0 Input 1 Output
             ModuleWords : TModuleWords;
             ChannelDataValue : array[0..3] of Double;
             ChannelSign : array[0..3] of Integer;
             ChannelStatus : array[0..3] of boolean;
             ChannelOverRangeFlag : array[0..3] of boolean;
             ChannelUnderRangeFlag : array[0..3] of boolean;
 end; // TModule

 TPLCMainModule = class(TObject)
               ModuleNumber : Integer;
               ModuleType : Integer; // 0 Main 1 Input 2 Output
               ModuleError : Boolean;
               MajorErrorCode : integer;
               ProcessorMode : Integer;
               ForcedIO,
               ControlRegisterError,
               BatteryOK : Boolean;
               DigitalInputModuleWords,
               DigitalOutputModuleWords,
               AnalogInputModuleWords,
               AnalogOutputModuleWords,
               RequestBits_ModuleWords : TModuleWords;
               DigitalInputData : array[0..3] of TBitArray;
               AnalogInputData : array[0..3] of Double;
               DigitalOutputData : array[0..3] of TBitArray;
               AnalogOutputData : array[0..1] of Double;
               Request_Bits_Status : array[0..9] of TBitArray;
             public
               Constructor Create;
 end; // TPLCModule

 TDigitalInputModule = class(TObject)
               ModuleNumber : Integer;
               ModuleType : Integer; // 0 Main 1 Input 2 Output
               ModuleError : Boolean;
               ModuleWords : TModuleWords;
               DigitalInputData : TBitArray;
             public
               Constructor Create;
 end; // TDigitalInputModule

 TDigitalOutputModule = class(TObject)
               ModuleNumber : Integer;
               ModuleType : Integer; // 0 Input 1 Output
               ModuleError : Boolean;
               ModuleWords : TModuleWords;
               DigitalOutputData : TBitArray;
             public
               Constructor Create;
 end; // TDigitalOutputModule

 TRelayedDigitalOutputModule = class(TObject)
                 ModuleNumber : Integer;
                 ModuleType : Integer; // 0 Input 1 Output
                 ModuleError : Boolean;
                 ModuleWords : TModuleWords;
                 RelayedDigitalOutputData : TBitArray;
               public
                 Constructor Create;
 end; // TRelayedDigitalOutputModule

 TAnalogInputModule = class(TObject)
               ModuleNumber : Integer;
               ModuleType : Integer; // 0 Input 1 Output
               ModuleError : Boolean;
               ModuleWords : TModuleWords;
               ChannelDataValue : array[0..3] of Double;
               ChannelStatus : array[0..3] of boolean;
               ChannelOverRangeFlag : array[0..3] of boolean;
               ChannelUnderRangeFlag : array[0..3] of boolean;
             public
               Constructor Create;
 end; // TAnalogInputModule

 TRTDAnalogInputModule = class(TObject)
               ModuleNumber          : Integer;
               ModuleType            : Integer;
               ModuleError           : Boolean;
               ModuleWords           : TModuleWords;
               ChannelDataValue      : array[0..3] of Double;
               ChannelStatus         : array[0..3] of Boolean;
               ChannelOverRangeFlag  : array[0..3] of Boolean;
               ChannelUnderRangeFlag : array[0..3] of Boolean;
               FChannelOpenCircuitFlag : Array[0..3] of boolean;
               procedure SetChannelOCFlag(Channel : Byte; Value : Boolean);
               function GetChannelOCFlag(Channel : Byte) : Boolean;
             public
               Constructor Create;
               property ChannelOpenCircuitFlag[Channel : Byte] : Boolean read GetChannelOCFlag write SetChannelOCFlag;
 end;  // TRTDAnalogInputModule

 TAnalogOutputModule = class(TObject)
             ModuleNumber : Integer;
             ModuleType : Integer; // 0 Input 1 Output
             ModuleError : Boolean;
             ModuleWords : TModuleWords;
             ChannelDataValue : array[0..3] of Double;
             ChannelStatus : array[0..3] of boolean;
             ChannelOverRangeFlag : array[0..3] of boolean;
             ChannelUnderRangeFlag : array[0..3] of boolean;
             public
               Constructor Create;
 end; // TAnalogOutputModule

 TAnalogInputModule1762_IF4 = record // 1762-IF4 I/O Expansion Module
                                ModuleType : String[255];
                                ChannelDataInputValue : array[0..3] of double;
                                ChannelSign : array[0..3] of integer;
                                ChannelStatus : array[0..3] of boolean;
                                ChannelOverRangeFlag : array[0..3] of boolean;
                                ChannelUnderRangeFlag : array[0..3] of boolean;
 end; // TAnalogInputModule1762_IF4

 TAnalogOutputModule1762_OF4 = record // 1762-OF4 Expansion Module
                                 ModuleType : String[255];
                                 ChannelDataOutputValue : array[0..3] of double;
                                 ChannelDataFormat : array[0..3,0..3] of boolean; // Raw Proportional or Scaled for PID
                                 ChannelTypeRange : array[0..3,0..4] of boolean; // Either Voltage (0-10V) or Current(4 to 20mA)
                                 ChannelStatus : array[0..3] of boolean;
                                 ChannelOverRangeFlag : array[0..3] of boolean;
                                 ChannelUnderRangeFlag : array[0..3] of boolean;
 end; // TAnalogOutputModule1762_OF4

 TModuleArray = array[0..7] of TObject;
 TModuleType = array[0..7] of Integer;

 TConfigurationError = procedure(Sender : TObject; ErrorNumber : Integer; PLCErrorMessage : ShortString) of Object;
 TReadWriteErrorEvent = procedure(Sender : TObject; ErrorNumber : Integer; PLCErrorMessage : ShortString; ErrorPacket : TPLCWritePacketRecord; ExceededFaultTollerance : Boolean) of Object;
 TReadWriteRecoverableErrorEvent = procedure(Sender : TObjecT; ErrorNumber : Integer; PLCErrorMessage : ShortString) of Object;
 TPLCMajorError = procedure(Sender : TObject; ErrorNumber : SmallInt; HexValue : ShortString) of Object;
 TNewDataReadFromPLC = procedure(Sender : TObject; BitDataFromPLC : TBitsArray;  WordDataFromPLC : TWordsArray) of Object;
 TSendModuleData = procedure(Sender : TObject; Modules : TModuleArray; ModuleTypes : TModuleType; ModuleCount : Integer) of Object;
 TValueReadFromPLC = procedure(Sender : TObject; ReturnedPacket : TPLCReadPacketRec) of Object;

 TPLCMonitor = class;
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
   PLCMonitor : TPLCMonitor;
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
   procedure Execute; Override;
 public
   constructor Create(var lParent : TPLCMonitor);
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
   property EthernetTimeOut : SmallInt read GetEthernetTimeOut write SetEthernetTimeOut;
   property WriteAttemptsBeforeFail : LongInt read FWriteAttemptsBeforeFail write FWriteAttemptsBeforeFail;
 end; // TPLCWriteThread

 TPLCReadThread = class(TThread)
 private
   PLCMonitor : TPLCMonitor;
   FSleepTime : LongInt;
   FPLCRead : TABCTL;
   FBinaryBits,
   FInputBits,
   FOutputBits,
   FStatusBits : TBitsArray;
   FBinaryWords,
   FInputWords,
   FOutputWords,
   FStatusWords : TWordsArray;
   FReadFault : boolean;
   FBinaryFile,
   FInputFile,
   FOutputFile,
   FStatusFile : ShortString;
   FBinaryReadSize,
   FInputReadSize,
   FOutputReadSize,
   FStatusReadSize : integer;
   FReadState : integer; // 0 = Binary, 1 = Inputs, 2 = Outputs, 3 = Status
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
   procedure Execute; Override;
 public
   constructor Create(Var lParent : TPLCMonitor);
   destructor Destroy; Override;
   procedure ReadBitFromPLC(pFile : ShortString; pWordNumber : integer; BitNumber : integer; intSize : integer);
   procedure ReadWordFromPLC(pFile : ShortString; pWordNumber : integer; intSize : integer);
   property SleepTime : LongInt read FSleepTime write SetSleepTime;
   property ReadEnabled : Boolean read FReadEnabled write SetReadEnabled;
   property ReadIPAddress : ShortString read FReadIPAddress write SetReadIPAddress;
   property ReadAdapterNum : LongInt read GetAdapterNum write SetAdapterNum;
   property ReadQue : LongInt read FPacketQueLength;
   property BinaryFile : ShortString read FBinaryFile write FBinaryFile;
   property InputFile : ShortString read FInputFile write FInputFile;
   property OutputFile : ShortString read FOutputFile write FOutputFile;
   property StatusFile : ShortString read FStatusFile write FStatusFile;
   property BinaryReadSize : Integer read FBinaryReadSize write FBinaryReadSize;
   property InputReadSize : Integer read FInputReadSize write FInputReadSize;
   property OutputReadSize : Integer read FOutputReadSize write FOutputReadSize;
   property StatusReadSize : Integer read FStatusReadSize write FStatusReadSize;
   property ReadFault : Boolean read FReadFault write FReadFault;
   property LastError : Integer read FReadErrorNum;
   property Modules : TModuleArray read GetModules write SetModules;
   property ModuleCount : Integer read FModuleCount write FModuleCount;
   property ModuleTypes : TModuleType read GetModuleTypes write SetModuleTypes;
   property ReadFaultTollerance : LongInt read GetReadFaultTol write SetReadFaultTol;
   property EthernetTimeOut : SmallInt read GetEthernetTimeOut write SetEthernetTimeOut;
 end; // TPLCReadThread

 TPLCMonitor = class(TComponent)
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
   FBinarySize : LongInt;
   FInputSize : LongInt;
   FOutputSize : LongInt;
   FStatusSize : LongInt;
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
   function GetEnabled : boolean;
   procedure SetEnabled(Value : Boolean);
   procedure SetReadIPAddress(Value : ShortString);
   function GetReadIPAddress : ShortString;
   procedure SetWriteIPAddress(Value : ShortString);
   function GetWriteIPAddress : ShortString;
   procedure SetBinarySize(Value : Integer);
   function GetBinarySize : Integer;
   procedure SetInputSize(Value : Integer);
   function GetInputSize : Integer;
   procedure SetOutputSize(Value : Integer);
   function GetOutputSize : Integer; 
   procedure SetStatusSize(Value : Integer);
   function GetStatusSize : Integer;
   function GetWriteFault : Boolean;
   function GetReadFault : Boolean;
   procedure SetWatchDogState(Value : boolean);
   procedure SetWatchDogInterval(Value : longint);
   procedure SetReadInterval(Value : LongInt);
   function GetReadInterval : LongInt;
   procedure SavePLCConfiguration(lFileName : ShortString);
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
   property EmbededIOResolution : LongInt read FEmbededIOResolution;
   property ExpandedIOResolution :LongInt read FExpandedIOResolution;
 published
 {Published Declarations}
   property Version : ShortString read FVersion write SetVersion;
   property Enabled : boolean read GetEnabled write SetEnabled default False;
   property ReadIPAddress : ShortString read GetReadIPAddress write SetReadIPAddress;
   property WriteIPAddress : ShortString read GetWriteIPAddress write SetWriteIPAddress;
   property ReadAdapterNum : LongInt read GetReadAdapterNum write SetReadAdapterNum default 0;
   property WriteAdapterNum : LongInt read GetWriteAdapterNum write SetWriteAdapterNum default 0;
   property BinarySize : integer read GetBinarySize write SetBinarySize default 1;
   property InputSize : integer read GetInputSize write SetInputSize default 6;
   property OutputSize : integer read GetOutputSize write SetOutputSize default 4;
   property StatusSize : Integer read GetStatusSize write SetStatusSize default 66;
   property WriteFault : boolean read GetWriteFault default False;
   property ReadFault : boolean read GetReadFault default False;
   property EnableWatchDog : boolean read FWatchDogActive write SetWatchDogState default False;
   property WatchDogHi : ShortString read FWatchDogHi write FWatchDogHi;
   property WatchDogLo : ShortString read FWatchDogLo write FWatchDogLo;
   property WatchDogTimeOut : LongInt read FWatchDogTimeOut write SetWatchDogTimeOut default 500;
   property WatchDogWordNumber : integer read FWatchDogWordNumber write SetWatchDogWordNumber default 1;
   property WatchDogBitNumber : integer read FWatchDogBitNumber write SetWatchDogBitNumber default 2;
   property WatchDogInterval : integer read FWatchDogInterval write SetWatchDogInterval;
   property ReadInterval : longInt read GetReadInterval write SetReadInterval default 60;
   property LastReadError : ShortString read GetLastReadError;
   property LastWriteError : ShortString read GetLastWriteError;
   property ReadPacketsInQue : LongInt read GetReadPacketsInQue;
   property WritePacketsInQue : LongInt read GetWritePacketsInQue;
   property EthernetTimeOut : SmallInt read GetEthernetTimeOut write SetEthernetTimeOut;
   property MaximumWriteAttempts : LongInt read GetMaximumWriteAttempts write SetMaximumWriteAttempts;

   property OnConfigurationError : TConfigurationError read FOnConfigurationError write FOnConfigurationError;
   property OnReadError : TReadWriteErrorEvent read FOnReadError write FOnReadError;
   property OnReadRecoverableError : TReadWriteRecoverableErrorEvent read FOnReadRecoverableError write FOnReadRecoverableError;
   property OnWriteError : TReadWriteErrorEvent read FOnWriteError write FOnWriteError;
   property OnWriteRecoverableError : TReadWriteRecoverableErrorEvent read FOnWriteRecoverableError write FOnWriteRecoverableError;
   property OnNewModuleData : TSendModuleData read FOnSendModuleData write FOnSendModuleData;
   property OnValueReadFromPLC : TValueReadFromPLC read FOnValueReadFromPLC write FOnValueReadFromPLC;
 end; // TPLCMonitor

procedure Register;

implementation
{_R PLCMonitor.dcr}

uses Math;

var
  UsingWriteStack : LongInt;
  UsingReadStack  : LongInt;

procedure Register;
begin
  RegisterComponents('TMSI', [TPLCMonitor]);
end;

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
    if Not Terminated then
      DoSendWatchDogToggle;
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
              FileType := 'B3';
              Size := FBinaryReadSize;
            end; // 0
        1 : begin
              FileType := 'I';
              Size := FInputReadSize;
            end; // 1
        2 : begin
              FileType := 'O';
              Size := FOutputReadSize;
            end; // 2
        3 : begin
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

constructor TPLCReadThread.Create(Var lParent : TPLCMonitor);
begin
  inherited Create(True);
  PLCMonitor := lParent;
  FSleepTime := 1;
  FModuleCount := 0;
  FillChar(FModuleType,SizeOf(FModuleType),#0);
  FillChaR(FModules,SizeOf(FModules),#0);
  FillChar(FBinaryBits, SizeOf(FBinaryBits), #0);
  FillChar(FInputBits, SizeOf(FInputBits), #0);
  FillChar(FOutputBits, SizeOf(FOutputBits), #0);
  FillChar(FStatusBits, SizeOf(FStatusBits), #0);
  FillChar(FBinaryWords, SizeOf(FBinaryWords), #0);
  FillChar(FInputWords, SizeOf(FInputWords), #0);
  FillChar(FOutputWords, SizeOf(FOutputWords), #0);
  FillChar(FStatusWords, SizeOf(FStatusWords), #0);
  FReadFault := False;
  FBinaryFile := 'B3';
  FInputFile := 'I';
  FOutputFile := 'O';
  FStatusFile := 'S';
  FReadIPAddress := '';
  FBinaryReadSize := 0;
  FInputReadSize := 0;
  FOutputReadSize := 0;
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
  {$ifndef NoPLC}
  FPLCRead := TABCTL.Create(Nil);
  with FPLCRead do
  begin
    Adapter      := 0;
    Enabled      := False;
    Function_    := 0;
    FileAddr     := 'B3';
    Size         := 1;
    Timeout      := 1000{ms};
    OnErrorEvent := PLCReadErrorEvent;
    OnReadDone   := PLCReadReadDone
  end; // With
  {$endif}
end; // TPLCReadThread.Create

function TPLCReadThread.GetSleepTime : LongInt;
begin
  Result := FSleepTime * 4;
end; // TPLCReadThread.GetSleepTime

procedure TPLCReadThread.SetSleepTime(Value : LongInt);
begin
  FSleepTime := Trunc(Value / 4);
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
  end; // If
end; // TPLCReadThread.DoReadFromPLC

procedure TPLCReadThread.Execute;
var
  OKToProcess : LongInt;
begin
  repeat
    if Assigned(FPLCRead) then
    begin
      OKToProcess := WaitForSingleObject(UsingReadStack,1000);
      if (OKToProcess = Wait_Object_0) then
      begin
        DoReadPacket;
        ReleaseSemaphore(UsingReadStack,1,Nil);
      end; // If
      DoReadFromPLC;
      if FNewDataReady then
        PopulateModules;
    end; // If
    if Not Terminated then
      Sleep(FSleepTime);
  until Terminated;
end; // TPLCReadThread.Execute

procedure TPLCMonitor.SetWatchDogWordNumber(Value : Integer);
begin
  FWatchDogWordNumber := Value;
  if Assigned(FPLCWatchDogThread) then
    FPLCWatchDogThread.WatchDogWordNum := FWatchDogWordNumber;
end; // TPLCMonitor.SetWatchDogWordNumber

procedure TPLCMonitor.SetWatchDogBitNumber(Value : Integer);
begin
  FWatchDogBitNumber := Value;
  if Assigned(FPLCWatchDogThread) then
    FPLCWatchDogThread.WatchDogBitNum := FWatchDogBitNumber;
end; // TPLCMonitor.SetWatchDogBitNumber

function TPLCMonitor.WriteWordToPLC(pFile : Shortstring; pWordNumber : integer; intSize : integer; Value : SmallInt) : Boolean;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteWordToPLC(pFile,pWordNumber,intSize,Value)
  else
    Result := False;
end; // TPLCMonitor.WriteWordToPLC

function TPLCMonitor.WriteBitToPLC(pFile : Shortstring; pWordNumber : integer; BitNumber : integer; intSize : integer; Value : boolean) : Boolean;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteBitToPLC(pFile,pWordNumber,BitNumber,intSize,Value)
  else
    Result := False;
end; // TPLCMonitor.WriteBitToPLC

function TPLCMonitor.GetReadIPAddress : ShortString;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadIPAddress
  else
    Result := FReadIPAddress;
end; // TPLCMonitor.GetReadIPAddress

procedure TPLCMonitor.SetReadIPAddress(Value : ShortString);
begin
  if ValidIPAddress(Value) then
  begin
    FReadIPAddress := Value;
  end
  else
  begin
    if Assigned(FOnConfigurationError) then
      FOnConfigurationError(Self,3,'Attempted to apply invalid read IP address.');
  end; // If
  if Assigned(FPLCReadThread) then
      FPLCReadThread.ReadIPAddress := Value
end; // TPLCMonitor.SetReadIPAddress

Constructor TPLCMonitor.Create(AOwner : TComponent);
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
  FVersion := '1.2.4';
  FReadInterval := 100;
  FBinarySize := 1;
  FInputSize := 6;
  FOutputSize := 4;
  FStatusSize := 66;
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
  FExpandedIOResolution := 32760;
  {$ifndef NoPLC}
  if not (csDesigning in ComponentState) then
  begin
    FPLCReadThread := TPLCReadThread.Create(Self);
    FPLCWriteThread := TPLCWriteThread.Create(Self);
    FPLCWatchDogThread := TPLCWatchDogThread.Create(FPLCWriteThread);
  end; // If
  {$endif}
end; // TPLCMonitor.Create

Destructor TPLCMonitor.Destroy;
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
//    FPLCReadThread.Suspend;
//    FPLCWatchdogThread.Suspend;
//    FPLCWriteThread.Suspend;
    FPLCReadThread.Free;
    FPLCWatchDogThread.Free;
    FPLCWriteThread.Free;
    FPLCWatchDogThread := Nil;
    FPLCReadThread := Nil;
    FPLCWriteThread := Nil;
  end; // If
  {$ENDIF}
  inherited Destroy;
end; // TPLCMonitor.Destroy

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

constructor TPLCWriteThread.Create(Var lParent : TPLCMonitor);
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
  {$ifndef NoPLC}
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
  {$endif}
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
                if Not FWriteFault then
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
  if Assigned(lPacket) then
  begin
    if (lPacket.Size > 0) and (lPacket.FileType <> '') and (lPacket.WriteBit or lPacket.WriteWord) then
    begin
      lPacket.TransactionPhase := 1;
      Result := True;
    end; // If
  end
  else
    Result := False;
end; // TPLCWriteThread.ValidatePacket

procedure TPLCWriteThread.Execute;
var
  OKToProcess : LongInt;
begin
  repeat
    OKToProcess := WaitForSingleObject(UsingWriteStack,1000);
    if (OKToProcess = Wait_Object_0) then
    begin
      DoTransmitPacket;
      ReleaseSemaphore(UsingWriteStack,1,Nil);
    end; // If
    Sleep(1);
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

Constructor TPLCMainModule.Create;
begin
  inherited Create;
  ModuleNumber := 0;
  ModuleType := 0;
  ModuleError := False;
  ForcedIO := False;
  ControlRegisterError := False;
  BatteryOK := True;
  ProcessorMode := 0;
  FillChar(DigitalInputModuleWords,SizeOf(DigitalInputModuleWords),#0);
  FillChar(DigitalOutputModuleWords,SizeOf(DigitalOutputModuleWords),#0);
  FillChar(AnalogInputModuleWords,SizeOf(AnalogInputModuleWords),#0);
  FillChar(AnalogOutputModuleWords,SizeOf(AnalogOutputModuleWords),#0);
  FillChar(DigitalInputData,SizeOf(DigitalInputData),#0);
  FillChar(AnalogInputData,SizeOf(AnalogInputData),#0);
  FillChar(DigitalOutputData,SizeOf(DigitalOutputData),#0);
  FillChar(AnalogOutputData,SizeOf(AnalogOutputData),#0);
end; // TPLCMainModule.Create

Constructor TDigitalInputModule.Create;
begin
  inherited Create;
  ModuleNumber := 0;
  ModuleType := 0;
  ModuleError := False;
  FillChar(ModuleWords,SizeOf(ModuleWords),#0);
  FillChar(DigitalInputData,SizeOf(DigitalInputData),#0);
end; // TDigitalInputMoodule.Create

Constructor TDigitalOutputModule.Create;
begin
  inherited Create;
  ModuleNumber := 0;
  ModuleType := 0;
  ModuleError := False;
  FillChar(ModuleWords,SizeOf(ModuleWords),#0);
  FillChar(DigitalOutputData,SizeOf(DigitalOutputData),#0);
end; // TDigitalOutputModule.Create

Constructor TRelayedDigitalOutputModule.Create;
begin
  inherited Create;
  ModuleNumber := 0;
  ModuleType := 0;
  ModuleError := False;
  FillChar(ModuleWords,SizeOf(ModuleWords),#0);
  FillChar(RelayedDigitalOutputData,SizeOf(RelayedDigitalOutputData),#0);
end; // TRelayedDigitalOutputModule.Create

Constructor TAnalogInputModule.Create;
begin
  inherited Create;
  ModuleNumber := 0;
  ModuleType := 0;
  ModuleError := False;
  FillChar(ModuleWords,SizeOf(ModuleWords),#0);
  FillChar(ChannelDataValue,SizeOf(ChannelDataValue),#0);
  FillChar(ChannelStatus,SizeOf(ChannelStatus),#0);
  FillChar(ChannelOverRangeFlag,SizeOf(ChannelOverRangeFlag),#0);
  FillChar(ChannelUnderRangeFlag,SizeOf(ChannelUnderRangeFlag),#0);
end; // TAnalogInputModule.Create

Constructor TRTDAnalogInputModule.Create;
begin
  inherited Create;
  ModuleNumber := 0;
  ModuleType := 0;
  ModuleError := False;
  FillChar(ModuleWords,SizeOf(ModuleWords),#0);
  FillChar(ChannelDataValue,SizeOf(ChannelDataValue),#0);
  FillChar(ChannelStatus,SizeOf(ChannelStatus),#0);
  FillChar(ChannelOverRangeFlag,SizeOf(ChannelOverRangeFlag),#0);
  FillChar(ChannelUnderRangeFlag,SizeOf(ChannelUnderRangeFlag),#0);
  FillChar(FChannelOpenCircuitFlag,SizeOf(FChannelOpenCircuitFlag),#0);
end; // TRTDAnalogInputModule.Create

Constructor TAnalogOutputModule.Create;
begin
  inherited Create;
  ModuleNumber := 0;
  ModuleType := 0;
  ModuleError := False;
  FillChar(ModuleWords,SizeOf(ModuleWords),#0);
  FillChar(ChannelDataValue,SizeOf(ChannelDataValue),#0);
  FillChar(ChannelStatus,SizeOf(ChannelStatus),#0);
  FillChar(ChannelOverRangeFlag,SizeOf(ChannelOverRangeFlag),#0);
  FillChar(ChannelUnderRangeFlag,SizeOf(ChannelUnderRangeFlag),#0);
end; // TAnalogOutputModule.Create

procedure TRTDAnalogInputModule.SetChannelOCFlag(Channel : Byte; Value : Boolean);
begin
  if (Channel in [Low(FChannelOpenCircuitFlag)..High(FChannelOpenCircuitFlag)]) then
    FChannelOpenCircuitFlag[Channel] := Value;
end; // TRTDAnalogInputModule.SetChannelURFlag

function TRTDAnalogInputModule.GetChannelOCFlag(Channel : Byte) : Boolean;
begin
  if (Channel in [Low(FChannelOpenCircuitFlag)..High(FChannelOpenCircuitFlag)]) then
    Result := FChannelOpenCircuitFlag[Channel]
  else
    Result := False;
end; // TRTDAnalogInputModule.GetChannelURFlag

function TPLCMonitor.GetEnabled : boolean;
begin
  if Assigned(FPLCReadThread) and Assigned(FPLCWriteThread) then
    Result := FPLCReadThread.ReadEnabled and FPLCWriteThread.WriteEnabled
  else
    Result := False;
end; // TPLCMonitor.GetEnabled

procedure TPLCMonitor.SetWriteIPAddress(Value : ShortString);
begin
  if ValidIPAddress(Value) then
  begin
    FWriteIPAddress := Value;
  end
  else
  begin
    if Assigned(FOnConfigurationError) then
      FOnConfigurationError(Self,4,'Attempted to apply invalid write IP address.');
  end; // If
  if Assigned(FPLCWriteThread) then
      FPLCWriteThread.WriteIPAddress := Value
end; // TPLCMonitor.SetWriteIPAddress

function TPLCMonitor.GetWriteIPAddress : ShortString;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteIPAddress
  else
    Result := FWriteIPAddress;
end; // TPLCMonitor.GetWriteIPAddress

procedure TPLCMonitor.SetBinarySize(Value : Integer);
begin
  FBinarySize := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.BinaryReadSize := Value;
end; // TPLCMonitor.SetBinarySize

function TPLCMonitor.GetBinarySize : Integer;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.BinaryReadSize
  else
    Result := FBinarySize;
end; // TPLCMonitor.GetBinarySize

procedure TPLCMonitor.SetInputSize(Value : Integer);
begin
  FInputSize := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.InputReadSize := Value;
end; // TPLCMonitor.SetInputSize

function TPLCMonitor.GetInputSize : Integer;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.InputReadSize
  else
    Result := FInputSize;
end; // TPLCMonitor.GetInputSize

procedure TPLCMonitor.SetOutputSize(Value : Integer);
begin
  FOutputSize := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.OutputReadSize := Value;
end; // TPLCMonitor.SetOutputSize

function TPLCMonitor.GetOutputSize : Integer;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.OutputReadSize
  else
    Result := FOutputSize;
end; // TPLCMonitor.GetOutputSize

procedure TPLCMonitor.SetStatusSize(Value : Integer);
begin
  FStatusSize := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.StatusReadSize := Value;
end; // TPLCMonitor.SetStatusSize

function TPLCMonitor.GetStatusSize : Integer;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.StatusReadSize
  else
    Result := FStatusSize;
end; // TPLCMonitor.GetStautsSize

function TPLCMonitor.GetWriteFault : Boolean;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteFault
  else
    Result := False;
end; // TPLCMonitor.GetWriteFault

function TPLCMonitor.GetReadFault : Boolean;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCReadThread.ReadFault
  else
    Result := False;
end; // TPLCMonitor.GetReadFault

procedure TPLCMonitor.SetEnabled(Value : Boolean);
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
end; // TPLCMonitor.SetEnabled

function TPLCMonitor.ValidIPAddress(Value : ShortString) : Boolean;
var
  i : integer;
  IP1 : ShortString;
  IP2 : ShortString;
  IP3 : ShortString;
  IP4 : ShortString;
  TMP : ShortString;
  DotCount : integer;
  DotPos : array[0..2] of integer;
  ErrorCount : integer;
begin
  Result := False;
  DotCount := 0;
  ErrorCount := 0;
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
end; // TPLCMonitor.SetPLCIPAddress

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
      0 : begin // Read Binary bits
            FillChar(FBinaryWords,Sizeof(FBinaryWords),#0);
            FillChar(FBinaryBits,SizeOf(FBinaryBits),#0);
            for i := 0 to (FBinaryReadSize - 1) do
            begin
              FBinaryWords[i] := FPLCRead.WordVal[i];
              for j := 0 to 15 do
              begin
                lBoolean := Ord(FPLCRead.BitVal[i,j]) <> 0;
                FBinaryBits[i,j] := lBoolean;
              end; // for j
            end; // for i
          end; // 0
      1 : begin // Read Input bits
            FillChar(FInputWords,SizeOf(FInputWords),#0);
            Fillchar(FInputBits,SizeOf(FInputBits),#0);
            for i := 0 to (FInputReadSize - 1) do
            begin
              FInputWords[i] := FPLCRead.WordVal[i];
              for j := 0 to 15 do
              begin
                lBoolean := Ord(FPLCRead.BitVal[i,j]) <> 0;
                FInputBits[i,j] := lBoolean;
              end; // for j
            end; // for i
          end; // 1
      2 : begin // Read Output bits
            FillChar(FOutputWords,SizeOf(FOutputWords),#0);
            FillChar(FOutputBits,SizeOf(FOutputbits),#0);
            for i := 0 to (FOutputReadSize - 1) do
            begin
              FOutputWords[i] := FPLCRead.WordVal[i];
              for j := 0 to 15 do
              begin
                lBoolean := Ord(FPLCRead.BitVal[i,j]) <> 0;
                FOutputBits[i,j] := lBoolean;
              end; // for j
            end; // for i
          end; // 2
      3 : begin // Read Stats bits
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
            FNewDataReady := True;
          end; // 3
    end; // Case
    PrimePLCForNextRead(FReadState);
    if FReadState < 3 then
      inc(FReadState)
    else
      FReadState := 0;
  end; // If
end;// TPLCMonitor.PLCReadReadDone

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
end; // TPLCReadThread.PLCReadErrorEvent3

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

procedure TPLCMonitor.InitializePLC;
var
  i : integer;
begin
  if Assigned(FPLCReadThread) and Assigned(FPLCWriteThread) then
  begin
    FPLCReadThread.ReadFault := False;
    FPLCWriteThread.WriteFault := False;
    for i := 0 to (FPLCReadThread.BinaryReadSize - 1) do
      FPLCWriteThread.WriteWordToPLC('B3',i,1,0);
  end; // If
end; // TPLCMonitor.InitializePLC

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
end; // TPLCMonitor.WriteWordToPLC

procedure TPLCMonitor.SetWatchDogState(Value : boolean);
begin
  FWatchDogActive := Value;
  if Assigned(FPLCWatchDogThread) then
  begin
    FPLCWatchDogThread.SleepInterval := FWatchDogInterval;
    FPLCWatchDogThread.WatchDogEnabled := FWatchDogActive;
  end; // If
end; // TPLCMonitor.SetWatchDogState

procedure TPLCMonitor.SetWatchDogInterval(Value : longint);
begin
  FWatchDogInterval := Value;
  if Assigned(FPLCWatchDogThread) then
    FPLCWatchDogThread.SleepInterval := FWatchDogInterval;
end; // TPLCMonitor.SetWatchDogInterval

procedure TPLCReadThread.PrimePLCForNextRead(Value : integer);
begin
  FPLCRead.ClearControl;
  case Value of
    0 : begin // Binary;
          FPLCRead.FileAddr := FInputFile;
          FPLCRead.Size := FInputReadSize;
        end; // 0
    1 : begin // Input
          FPLCRead.FileAddr := FOutputFile;
          FPLCRead.Size := FOutputReadSize;
        end; // 1
    2 : begin // Output
          FPLCRead.FileAddr := FStatusFile;
          FPLCRead.Size := FStatusReadSize;
        end; // 2
    3 : begin // Status
          FPLCRead.FileAddr := FBinaryFile;
          FPLCRead.Size := FBinaryReadSize;
        end; // 3
  end; // Case
end; // TPLCWriteThread.PrimePLCForNextRead

function TPLCMonitor.ProcessorMode(ModuleType,intProcessorMode : Integer) : ShortString;
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
end; // TPLCMonitor.ProcessorMode

function TPLCWriteThread.AddToWriteStack(lPacket : TPLCWritePacket) : Boolean;
var
  OKToAdd : Boolean;
begin
  OKToAdd := False;
  if Assigned(FWriteStack) then
  begin
    if Assigned(lPacket) then
    begin
      OKToAdd := WaitForSingleObject(UsingWriteStack,1000) = Wait_Object_0;
      if OKToAdd then
      begin
        FWriteStack.AddObject(IntToStr(FWriteStack.Count),lPacket);
        ReleaseSemaphore(UsingWriteStack,1,Nil);
      end
      else
      begin
        lPacket.Free;
      end; // If
    end; // If
  end; // If
  Result := OKToAdd;
end; // TPLCWriteThread.AddToWriteStack

function TPLCMonitor.GetReadInterval : LongInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.SleepTime
  else
    Result := FReadInterval;
end; // TPLCMonitor.GetReadInterval

procedure TPLCMonitor.SetReadInterval(Value : longInt);
begin
  FReadInterval := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.SleepTime := FReadInterval;
end; // TPLCMonitor.SetReadInterval

procedure TPLCMonitor.LoadPLCConfiguration(lFileName : ShortString);
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
begin
  if FileExists(lFileName) then
  begin
    if FModuleCount > 0 then
    begin
      SetEnabled(False);
      for i := 0 to (FModuleCount - 1) do
      begin
//        if Assigned(FPLCReadThread) then
//          FPLCReadThread.Suspend;
        Modules[i].Free;
        Modules[i] := Nil;
        if Assigned(FPLCReadThread) then
          FPLCReadThread.Start;
      end; // For i
    end; // If
    // Format of the file is as follows:
    // 1. CurSubKey = 'PLC'
    //    This record contains the config data for the entire PLC including
    //    - IP address
    //    - Number of words of the various PLC files to read.  Files are read
    //      sequentially:
    //      'B3'   - PC Request Bits (Latches, etc.)
    //      'I'    - Input data:  Processor, Digital, Analog
    //      'O'    - Output data: Processor, Digital, Analog
    //      'S'    - Processor Status
    //    - Watchdog timer config data
    //    - Number of modules installed (including processor module)
    FConfigurationFile := lFileName;
    INIFile := TStRegINI.Create(FConfigurationFile,True);
    with INIFile do
    begin
      CurSubKey := 'PLC';
      SetReadIPAddress(ReadString('ReadIPAddress','0.0.0.0'));
      SetWriteIPAddress(ReadString('WriteIPAddress','0.0.0.0'));
      SetBinarySize(ReadInteger('NumberOfBinaryWords',1));
      SetInputSize(ReadInteger('NumberOfInputWords',1));
      SetOutputSize(ReadInteger('NumberOfOutputWords',1));
      SetStatusSize(ReadInteger('NumberofStatusWords',1));
      SetWatchdogBitNumber(ReadInteger('WatchdogBit',0));
      SetWatchDogWordNumber(ReadInteger('WatchdogWord',0));
      SetWatchDogInterval(ReadInteger('WatchdogInterval',1000));
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
                  // Start Digital Input Data word for the Processor module should be set to 0
                  // End Digital Input Data word should be set to 3
                  // ** Data included in the 'I' (Inputs) file **
                  lMainModule.DigitalInputModuleWords[0,0] := ReadInteger('StartDigitalInputWord',0);
                  lMainModule.DigitalInputModuleWords[0,1] := ReadInteger('EndDigitalInputWord',0);
                  // Start Digital Output Data word for the Processor module should be set to 0
                  // End Digital Output Data word should be set to 3
                  // ** Data included in the 'O' (Outputs) file **
                  lMainModule.DigitalOutputModuleWords[0,0] := ReadInteger('StartDigitalOutputDataWord',0);
                  lMainModule.DigitalOutputModuleWords[0,1] := ReadInteger('EndDigitalOutputDataWord',0);
                  // Stsrt Analog Input Data word for the Processor module should be set to 4
                  // End Analog Input Data word should be set to 7
                  // ** Data included in the 'I' (Inputs) file **
                  lMainModule.AnalogInputModuleWords[0,0] := ReadInteger('StartAnalogInputWord',0);
                  lMainModule.AnalogInputModuleWords[0,1] := ReadInteger('EndAnalogInputWord',0);
                  lMainModule.AnalogInputModuleWords[1,0] := ReadInteger('StartAnalogInputStatusWord',0);
                  lMainModule.AnalogInputModuleWords[1,1] := ReadInteger('EndAnalogInputStatusWord',0);
                  // Stsrt Analog Output Data word for the Processor module should be set to 4
                  // End Analog Output Data word should be set to 5
                  // ** Data included in the 'O' (Outputs) file **
                  lMainModule.AnalogOutputModuleWords[0,0] := ReadInteger('StartAnalogOutputDataWord',0);
                  lMainModule.AnalogOutputModuleWords[0,1] := ReadInteger('EndAnalogOutputDataWord',0);
                  lMainModule.AnalogOutputModuleWords[1,0] := ReadInteger('StartAnalogOutputStatusWord',0);
                  lMainModule.AnalogOutputModuleWords[1,1] := ReadInteger('EndAnalogOutputStatusWord',0);
                  // Start Request Bits word for the Processor module should be set to 0
                  // End Request Bits word should be set to [# of words in the 'B3' PLC file minus 1]
                  // ** Data included in the 'B3' (PC Request Bits) file **
                  lMainModule.RequestBits_ModuleWords[0,0] := ReadInteger('StartRequestBitsWord',0);
                  lMainModule.RequestBits_ModuleWords[0,1] := ReadInteger('EndRequestBitsWord',0);
                  Modules[i] := lMainModule;
                end; // 0
            1 : begin // Digital Input Module
                  lDigitalInputModule := TDigitalInputModule.Create;
                  lDigitalInputModule.ModuleType := ModuleType[i];
                  lDigitalInputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                  // Start and End Digital Input Data words for the Expansion modules should be set to the same number
                  // Look at the 'I' (Inputs) file on the PLC for the value based on slot (module number)
                  // ** Data included in the 'I' (Inputs) file **
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
                  // Start and End Digital Output Data words for the Expansion modules should be set to the same number
                  // Look at the 'O' (Outputs) file on the PLC for the value based on slot (module number)
                  // ** Data included in the 'O' (Outputs) file **
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
                  // Look at the 'I' (Inputs) file on the PLC for the Start Analog Input Data word based on slot (module number)
                  // End Analog Input Data word should be set to [Start Analog Input Data word + 3]
                  // Start Analog Input Status word should be set to [Start Analog Input Data word + 4]
                  // End Analog Input Status word should be set to [Start Analog Input Data word + 6]
                  // ** Data and Status included in the 'I' (Inputs) file **
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
                  // Look at the 'O' (Outputs) file on the PLC for the Start Analog Output Data word based on slot (module number)
                  // End Analog Output Data word should be set to [Start Analog Output Data word + 3]
                  // ** Data and Status included in the 'O' (Outputs) file **
                  lAnalogOutputModule.ModuleWords[0,0] := ReadInteger('StartDataWord',0);
                  lAnalogOutputModule.ModuleWords[0,1] := ReadInteger('EndDataWord',0);
                  lAnalogOutputModule.ModuleWords[1,0] := ReadInteger('StartStatusWord',0);
                  lAnalogOutputModule.ModuleWords[1,1] := ReadInteger('EndStatusWord',0);
                  Modules[i] := lAnalogOutputModule
                end; // 4
            5 : begin
                  lRelayedDigitalOutputModule := TRelayedDigitalOutputModule.Create;
                  lRelayedDigitalOutputModule.ModuleType := ModuleType[i];
                  lRelayedDigitalOutputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                  // Start and End Digital Output Data words for the Expansion modules should be set to the same number
                  // Look at the 'O' (Outputs) file on the PLC for the value based on slot (module number)
                  // ** Data included in the 'O' (outputs) file **
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
                  // Look at the 'I' (Inputs) file on the PLC for the Start RTD Analog Input Data word based on slot (module number)
                  // End RTD Analog Input Data word should be set to [Start RTDAnalog Input Data word + 3]
                  // Start RTD Analog Input Status word should be set to [Start RTD Analog Input Data word + 4]
                  // End RTD Analog Input Status word should be set to [Start RTD Analog Input Data word + 6]
                  // ** Data and Status included in the 'I' (Inputs) file **
                  lRTDAnalogInputModule.ModuleWords[0,0] := ReadInteger('StartDataWord',0);
                  lRTDAnalogInputModule.ModuleWords[0,1] := ReadInteger('EndDataWord',0);
                  lRTDAnalogInputModule.ModuleWords[1,0] := ReadInteger('StartStatusWord',0);
                  lRTDAnalogInputModule.ModuleWords[1,1] := ReadInteger('EndStatusWord',0);
                  Modules[i] := lRTDAnalogInputModule;
                end; // 6
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
    end; // With
    if Assigned(FPLCReadThread) then
    begin
      FPLCReadThread.Modules := Modules;
      FPLCReadThread.ModuleTypes := ModuleType;
      FPLCReadThread.ModuleCount := FModuleCount;
    end; // If
    INIFile.Free;
  end; // If
end; // TPLCMonitor.LoadPLCConfiguration

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
  lChannel1,
  UCount,
  OCount : integer;
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

                DigitalInputData[0] := FInputBits[lStartDataWord];
                DigitalInputData[1] := FInputBits[lStartDataWord + 1];
                DigitalInputData[2] := FInputBits[lStartDataWord + 2];
                DigitalInputData[3] := FInputBits[lEndDataWord];
                AnalogInputData[0] := FInputWords[lStartAnalogDataWord];
                AnalogInputData[1] := FInputWords[lStartAnalogDataWord + 1];
                AnalogInputData[2] := FInputWords[lStartAnalogDataWord + 2];
                AnalogInputData[3] := FInputWords[lEndAnalogDataWord];

                lStartDataWord := DigitalOutputModuleWords[0,0];
                lEndDataWord := DigitalOutputModuleWords[0,1];
                lStartAnalogDataWord := AnalogOutputModuleWords[0,0];
                lEndAnalogDataWord := AnalogOutputModuleWords[0,1];

                DigitalOutputData[0] := FOutputBits[lStartDataWord];
                DigitalOutputData[1] := FOutputBits[lStartDataWord + 1];
                DigitalOutputData[2] := FOutputBits[lStartDataWord + 2];
                DigitalOutputData[3] := FOutputBits[lEndDataWord];
                AnalogOutputData[0] := FOutputWords[lStartAnalogDataWord];
                AnalogOutputData[1] := FOutputWords[lEndAnalogDataWord];

                // Request Bits are used to control and monitor logic at the PLC
                // The "B3" file in the PLC holds this data
                lStartDataWord := RequestBits_ModuleWords[0,0];
                lEndDataWord := RequestBits_ModuleWords[0,1];
                lChannel1 := 0;
                for j := 0 to (FBinaryReadSize - 1) do
                begin
                  if j in [lStartDataWord..lEndDataWord] then
                  begin
                    Request_Bits_Status[lChannel1] := FBinaryBits[j];
                    inc(lChannel1);
                  end; // If
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
                ProcessorMode := lProcessorMode;
                ForcedIO := FStatusBits[1,6];
                ControlRegisterError := FStatusBits[5,2];
                BatteryOK := Not(FStatusBits[5,11]);
                MajorErrorCode := lMajorError;
              end; // With
            end; // 0
        1 : begin // Digital Input Module
              lDigitalInputModule := (FModules[i] as TDigitalInputModule);
              with lDigitalInputModule do
              begin
                lStartDataWord := ModuleWords[0,0];
                DigitalInputData := FInputBits[lStartDataWord];
              end; // With
            end; // 1
        2 : begin // Digital Output Module
              lDigitalOutputModule := (FModules[i] as TDigitalOutputModule);
              with lDigitalOutputModule do
              begin
                lStartDataWord := ModuleWords[0,0];
                DigitalOutputData := FOutputBits[lStartDataWord];
              end; // With
            end; // 2
        3 : begin // Analog Input Module
              lAnalogInputModule := (FModules[i] as TAnalogInputModule);
              with lAnalogInputModule do
              begin
                // The Analog Input expansion module (IF4) provides 7 words of data:
                //   Words 0-3 : Channels 0-3 data
                //   Word 4    : bits 0-3             = Channels 0-3 status
                //   Word 5    : bits 15,13,11,9      = Channels 0-3 Under-Range status
                //             : bits 14,12,10,8      = Channels 0-3 Over-Range status
                //   Word 6    : (IF4 only) Reserved
                lStartDataWord := ModuleWords[0,0];
                lEndDataWord := ModuleWords[0,1];
                lStartStatusWord := ModuleWords[1,0];
                OCount := 0;
                UCount := 0;
                ChannelDataValue[0] := FInputWords[lStartDataWord];
                ChannelDataValue[1] := FInputWords[lStartDataWord + 1];
                ChannelDataValue[2] := FInputWords[lStartDataWord + 2];
                ChannelDataValue[3] := FInputWords[lEndDataWord];
                for k := 1 to 4 do
                begin
                  ChannelStatus[k - 1] := (FInputWords[lStartStatusWord] Shr k and 1) <> 0;
                  lModuleError := lModuleError or ChannelStatus[k - 1];
                end; // For k
                for k := 15 downto 8 do
                begin
                  lModuleError := lModuleError or ((FInputWords[lStartStatusWord + 1] Shr k and 1 <> 0));
                  if (k mod 2) = 0 then
                  begin
                    // Even numbered bits = Over-range
                    ChannelOverRangeFlag[UCount] := ((FInputWords[lStartStatusWord + 1] Shr k and 1 <> 0));
                    inc(UCount);
                  end
                  else
                  begin
                    // Odd numbered bits = Under-range
                    ChannelUnderRangeFlag[OCount] := ((FInputWords[lStartStatusWord + 1] Shr k and 1 <> 0));
                    inc(OCount);
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
                UCount := 0;
                OCount := 0;
                // The Analog Output expansion module provides 4 output words and 2 input words of data:
                //   Output Words 0-3 :                   = Channels 0-3 data
                //   Input Word 0     : bits 0-3          = Channels 0-3 status
                //   Input Word 1     : bits 7,5,3,1      = Channels 0-3 Under-Range status
                //                    : bits 6,4,2,0      = Channels 0-3 Over-Range status
                ChannelDataValue[0] := FOutputWords[lStartDataWord];
                ChannelDataValue[1] := FOutputWords[lStartDataWord + 1];
                ChannelDataValue[2] := FOutputWords[lStartDataWord + 2];
                ChannelDataValue[3] := FOutputWords[lEndDataWord];
                lModuleError := False; // Initialize
                for k := 1 to 4 do
                begin
                  ChannelStatus[k - 1] := ((FInputWords[lStartStatusWord] Shr k and 1) <> 0);
                  lModuleError := lModuleError or ChannelStatus[k - 1];
                end; // For k
                for k := 7 downto 0 do
                begin
                  lModuleError := lModuleError or ((FInputWords[lStartStatusWord + 1] Shr k and 1) <> 0); // Input section holds the status of the output module
                  if (k mod 2) <> 0 then
                  begin
                    // Even numbered bits = Over-range
                    ChannelOverRangeFlag[UCount] := (FInputWords[lStartStatusWord + 1] Shr k and 1 <> 0);
                    Inc(UCount);
                  end
                  else
                  begin
                    // Odd numbered bits = Under-range
                    ChannelUnderRangeFlag[OCount] := (FInputWords[lStartStatusWord + 1] Shr k and 1 <> 0);
                    Inc(OCount);
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
                RelayedDigitalOutputData := FOutputBits[lStartDataWord];
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
                ChannelDataValue[0] := FInputWords[lStartDataWord];
                ChannelDataValue[1] := FInputWords[lStartDataWord + 1];
                ChannelDataValue[2] := FInputWords[lStartDataWord + 2];
                ChannelDataValue[3] := FInputWords[lEndDataWord];
                for k := 0 to 3 do
                begin
                  ChannelStatus[k] := (FInputWords[lStartStatusWord] Shr k and 1) <> 0;
                  lModuleError := lModuleError or ChannelStatus[k];
                end; // For k
                j := 0;
                for k := 8 to 11 do
                begin
                  ChannelOpenCircuitFlag[j] := (FInputWords[lStartStatusWord] Shr k and 1) <> 0;
                  lModuleError := lModuleError or ChannelOpenCircuitFlag[j];
                  inc(j);
                end; // For k
                j := 0;
                for k := 15 downto 8 do
                begin
                  lModuleError := lModuleError or ((FInputWords[lStartStatusWord + 1] Shr k and 1 <> 0));
                  if (k mod 2) = 0 then
                  begin
                    // Even numbered bits = Over-range
                    ChannelOverRangeFlag[j] := ((FInputWords[lStartStatusWord + 1] Shr k and 1 <> 0));
                    if j < 3 then
                    begin
                      inc(j);
                    end;
                  end
                  else
                  begin
                    // Odd numbered bits = Under-range
                    ChannelUnderRangeFlag[j] := ((FInputWords[lStartStatusWord + 1] Shr k and 1 <> 0));
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
end; // TPLCMonitor.PopulateModules

procedure TPLCMonitor.SavePLCConfiguration;
var
  INIFile : TStRegINI;
  i : integer;
begin
  if FileExists(FConfigurationFile) then
  begin
    if Assigned(FPLCReadThread) then
    begin
      // See LoadPLCConfiguration procedure for the format information on this file
      Modules := FPLCReadThread.Modules;
      ModuleType := FPLCReadThread.ModuleTypes;
      FModuleCount := FPLCReadThread.ModuleCount;
      INIFile := TStRegINI.Create(FConfigurationFile,True);
      with INIFile do
      begin
        CurSubKey := 'PLC';
        WriteString('ReadIPAddress',GetReadIPAddress);
        WriteString('WriteIPAddress',GetWriteIPAddress);
        WriteInteger('NumberOfBinaryWords',GetBinarySize);
        WriteInteger('NumberOfInputWords',GetInputSize);
        WriteInteger('NumberOfOutputWords',GetOutputSize);
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
      INIFile.Free;
    end; // If
  end; // If
end; // TPLCMonitor.SavePLCConfiguration

function TPLCMonitor.GetErrorMessage(nErrorCode : TintErrorCode) : ShortString;
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
end; // TPLCMonitor.GetErrorMessage

function TPLCMonitor.GetLastReadError : ShortString;
begin
  Result := GetErrorMessage(FPLCReadThread.LastError);
end; // TPLCMonitor.GetLastReadError

function TPLCMonitor.GetLastWriteError : ShortString;
begin
  Result := GetErrorMessage(FPLCWriteThread.LastError);
end; // TPLCMonitor.GetLastWriteError

procedure TPLCMonitor.ResetPLC;
begin
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadFault := False;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteFault := False;
end; // TPLCMonitor.ResetPLC

procedure TPLCMonitor.SetVersion(Value : ShortString);
begin
  // Do Nothing...
end; // TPLCMonitor.SetVersion

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

procedure TPLCMonitor.SetWatchDogTimeOut(Value : LongInt);
begin
  FWatchDogTimeOut := Value;
  if Assigned(FPLCWriteThread) then
  begin
    if (FWatchDogHi <> '') and (FWatchDogLo <> '') then
    begin
      FPLCWriteThread.WriteWordToPLC(FWatchDogHi,0,1,FWatchDogTimeOut);
      FPLCWriteThread.WriteWordToPLC(FWatchDogLo,0,1,FWatchDogTimeOut);
    end
    else
    begin
      if Assigned(FOnConfigurationError) then
      begin
        if (FWatchDogHi = '') then
          FOnConfigurationError(Self,1,'WatchdogHi Name not assigned');
        if (FWatchDogLo = '') then
          FOnConfigurationError(Self,2,'WatchdogLo Name not assigned');
      end; // If
    end; // If
  end; // If
end; // TPLCMonitor.SetWatchDogTimeOut

procedure TPLCReadThread.DoReturnValueFromPLC;
begin
  if Assigned(PLCMonitor.OnValueReadFromPLC) then
    PLCMonitor.OnValueReadFromPLC(Self,FReadPacketRec);
end; // TPLCReadThread.DoReturnValueFromPLC

procedure TPLCReadThread.AddToReadStack(lPacket : TPLCReadPacket);
var
  OKToAdd : LongInt;
begin
  if Assigned(FReadStack) then
  begin
    if Assigned(lPacket) then
    begin
      OKToAdd := WaitForSingleObject(UsingReadStack,1000);
      if (OKToAdd = Wait_Object_0) then
      begin
        FReadStack.AddObject(IntToStr(FReadStack.Count + 1),lPacket);
        ReleaseSemaphore(UsingReadStack,1,Nil);
      end
      else
      begin
        lPacket.Free;
      end; // If
    end; // If
  end; // If
end; // TPLCReadThread.AddToReadStack
 
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

procedure TPLCMonitor.ReadBitFromPLC(pFile : ShortString; pWordNumber : integer; BitNumber : integer; intSize : integer);
begin
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadBitFromPLC(pFile,pWordNumber,BitNumber,intSize);
end; // TPLCMonitor.ReadBitFromPLC

procedure TPLCMonitor.ReadWordFromPLC(pFile : ShortString; pWordNumber : integer; intSize : integer);
begin
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadWordFromPLC(pFile,pWordNumber,intSize);
end; // TPLCMonitor.ReadWordFromPLC

function TPLCMonitor.CheckModuleConfigutaion : Boolean;
var
  i : LongInt;
  ConfigError : Boolean;
  lMainModule : TPLCMainModule;
  lDigitalInputModule : TDigitalInputModule;
  lDigitalOutputModule : TDigitalOutputModule;
  lAnalogInputModule : TAnalogInputModule;
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
              ConfigError := ((RequestBits_ModuleWords[0,1] - RequestBits_ModuleWords[0,0]) > (High(Request_Bits_Status) + 1)) or ((RequestBits_ModuleWords[0,1] - RequestBits_ModuleWords[0,0]) < 0);
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
    end; // Case
  end; // For i
  if (StrErrorMessages <> '') then
  begin
    Result := False;
    if Assigned(FOnConfigurationError) then
      FOnConfigurationError(Self,5,StrErrorMessages);
  end; // If
end; // TPLCMonitor.CheckConfigurationFile

function TPLCMonitor.GetReadPacketsInQue : LongInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadQue
  else
    Result := 0;
end; // TPLCMonitor.GetReadPacketsInQue

function TPLCMonitor.GetWritePacketsInQue : LongInt;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteQue
  else
    Result := 0;
end; // TPLCMonitor.GetWritePacketsInQue

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

function TPLCMonitor.GetReadAdapterNum : LongInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadAdapterNum
  else
    Result := FReadAdapterNum;
end; // TPLCMonitor.GetReadAdapterNum

procedure TPLCMonitor.SetReadAdapterNum(Value : LongInt);
begin
  FReadAdapterNum := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadAdapterNum := FReadAdapterNum;
end; // TPLCMonitor.SetReadAdapterNum

function TPLCMonitor.GetWriteAdapterNum : LongInt;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteAdapterNum
  else
    Result := FWriteAdapterNum;
end; // TPLCMonitor.GetWriteAdapterNum

procedure TPLCMonitor.SetWriteAdapterNum(Value : LongInt);
begin
  FWriteAdapterNum := Value;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteAdapterNum := Value;
end; // TPLCMonitor.SetWriteAdapterNum

function TPLCMonitor.GetReadFaultTollerance : LongInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadFaultTollerance
  else
    Result := FReadFaultTollerance;
end; // TPLCMonitor.GetReadFaultTollerance

procedure TPLCMonitor.SetReadFaultTollerance(Value : LongInt);
begin
  FReadFaultTollerance := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadFaultTollerance := FReadFaultTollerance;
end; // TPLCMonitor.SetReadFaultTollerance

function TPLCMonitor.GetWriteFaultTollerance : LongInt;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteFaultTollerance
  else
    Result := FWriteFaultTollerance;
end; // TPLCMonitor.GetWriteFaultTollerance

procedure TPLCMonitor.SetWriteFaultTollerance(Value : LongInt);
begin
  FWriteFaultTollerance := Value;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteFaultTollerance := FWriteFaultTollerance;
end; // TPLCMonitor.SetWriteFaultTollerance

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

procedure TPLCMonitor.SetEthernetTimeOut(Value : SmallInt);
begin
  FEthernetTimeOut := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.EthernetTimeOut := FEthernetTimeOut;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.EthernetTimeOut := FEthernetTimeOut;
end; // TPLCMonitor.SetEthernetTimeOut

function TPLCMonitor.GetEthernetTimeOut : SmallInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.EthernetTimeOut
  else
    Result := FEthernetTimeOut;
end; // TPLCMonitor.GetEthernetTimeOut

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

procedure TPLCMonitor.SetMaximumWriteAttempts(Value : LongInt);
begin
  FMaximumWriteAttempts := Value;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteAttemptsBeforeFail := FMaximumWriteAttempts
end; // TPLCMonitor.SetMaximumWriteAttempts

function TPLCMonitor.GetMaximumWriteAttempts : LongInt;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteAttemptsBeforeFail
  else
    Result := FMaximumWriteAttempts;
end; // TPLCMonitor.GetMaximumWriteAttemps

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

