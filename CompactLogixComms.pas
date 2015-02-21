////////////////////////////////////////////////////////////////////////////////
//                         Created By: Daniel Muncy                           //
//                         Date : 7/14/2009                                   //
//                         For : Apollo TTM4                                  //
//                         Copywrite TMSI all rights reserved.                //
//                                                                            //
// This component handles all reading and writing to a CompactLogix PLC using //
// the INGEAR Allen Bradly PLC component. The component makes the data        //
// available in module format to better visualize the information. The        //
// component is configured using an INI file.                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

{$ifndef Package_Build}
{$ifdef systest}
  {$I ..\Conditionals.inc}
{$else}
  {$I Conditionals.inc}
{$endif}
{$endif}
// Compiler Directives for this Unit
{_DEFINE INGEAR_Version_52}
{$DEFINE INGEAR_Version_60} // Modifies OnErrorEvent and adds new error codes.
{$ifndef INGEAR_Version_60}
  {$ifndef INGEAR_Version_52}
    {$define INGEAR_Version_52}
  {$endif}
{$endif}


unit CompactLogixComms;

interface

uses Windows, Messages, SysUtils, Classes, StdCtrls, ExtCtrls, ABCTLLib_TLB,
     OleCtrls;


Const
  MaximumModules = 20; // Use this to increase the maximum number of modules the component will handle

Type
{$IFDEF INGEAR_Version_52}
 TIntErrorCode = smallint;
{$endif}
{$IFDEF INGEAR_Version_60}
 TIntErrorCode = longint;
{$endif}
 TModuleTypes = (M_AnlgInput,M_AnlgOutput,M_DigIn,M_DigOut,M_RDigOut,M_Drive,M_Processor);

 TModuleWords = array[0..1,0..1] of integer; // Index zero is the location of the first module word the second index holds the location of the last module word

 TPLCWritePacket = Class(TObject)
                       FSize : LongInt;
                       FTag : ShortString;
                       FValue : LongInt;
                       FTransactionPhase : LongInt; // -1 = Just Created, 0 = Pending, 1 = Validated, 2 = Sent, 3 = Error
                       FTransmitAttempts : LongInt;
                     public
                       Constructor Create;
                       property Size : LongInt read FSize write FSize;
                       property Tag : ShortString read FTag write FTag;
                       property Value : LongInt read FValue write FValue;
                       property TransactionPhase : LongInt read FTransactionPhase write FTransactionPhase;
                       property TransmitAttempts : LongInt read FTransmitAttempts write FTransmitAttempts;
 end; // TPLCWritePacket

 TPLCWritePacketRecord = record
                       Size : Integer;
                       Tag : ShortString;
                       Value : Integer;
                       TransactionPhase : LongInt;
 end; // TPLCWritePacketRecord

 TPLCReadPacket = Class(TObject)
                      FSize : LongInt;
                      FTag : ShortString;
                      FValue : LongInt;
                      FTransactionPhase : LongInt; // -1 = Just Created, 0 = Pending, 1 = Sent, 2 = Returned
                    public
                      Constructor Create;
                      property Size : LongInt read FSize write FSize;
                      property Tag : ShortString read FTag write FTag;
                      property Value : LongInt read FValue write FValue;
                      property TransactionPhase : LongInt read FTransactionPhase write FTransactionPhase;
 end; // TPLCWritePacket

 TPLCReadPacketRecord = record
                          Size : Integer;
                          Tag : ShortString;
                          Value : LongInt;
                          TransactionPhase : LongInt;
 end; // TPLCWritePacketRecord
 TModuleElement = Integer;
 TModuleElements = Array[0..1] of TModuleElement;
 TAnalogIOData = Array[0..7] of Integer;
 TDigitalIOData = Array[0..15] of Boolean;
 TRelayDigitalIOData = Array[0..7] of Boolean;
 TFaultBits = Array[0..31] of Boolean;
 TOverRange = Array[0..7] of Boolean;
 TUnderRange = Array[0..7] of Boolean;
 THighAlarm = Array[0..7] of Boolean;
 TLowAlarm = Array[0..7] of Boolean;
 TDriveStatus = Array[0..15] of Boolean;
 TDriveLogicRslt = Array[0..15] of Boolean;
 TProcessorStatus = Array[0..15] of Boolean;
 TRequestBits = Array[0..1,0..31] of Boolean;
 TOutputSettings = Array[0..1] of LongInt; // 0 = ±10VDC, 1 = 0 to 5VDC, 2 = 0 to 10VDC, 3 = 4 to 20mA, 4 = 1 to 5VDC, 5 = 0 to 20mA

 TCommModule = class(TObject)
 private
   FModuleNumber : Integer;
   FModuleType : Integer; // 0 Input 1 Output
   FModuleString : ShortString;
   FModuleArrayElements : TModuleElements;
   FFault : TFaultBits;
   FModuleEntryStatus : Integer;
   procedure SetModuleArrayElement(Element : Integer; ModuleArrayElement : TModuleElement);
   function GetModuleArrayElement(Element : Integer) : TModuleElement;
   procedure SetFault(Channel : Integer; Value : Boolean);
   function GetFault(Channel : Integer) : Boolean;
 public
   constructor Create; Virtual;
   property ModuleNumber : Integer read FModuleNumber write FModuleNumber;
   property ModuleType : Integer read FModuleType write FModuleType;
   property ModuleString : ShortString read FModuleString write FModuleString;
   property ModuleEntryStatus : Integer read FModuleEntryStatus write FModuleEntryStatus;
   property ModuleArrayElements[Element : Integer] : TModuleElement read GetModuleArrayElement write SetModuleArrayElement;
   property Fault[Channel : Integer] : Boolean read GetFault write SetFault;
 end; // TCommModule

 TAnalogCommModule = class(TCommModule)
 private
   FInputData : TAnalogIOData;
   FOutputData : TAnalogIOData;
   FOverRange : TOverRange;
   FUnderRange : TUnderRange;
   FHighAlarm : THighAlarm;
   FLowAlarm : TLowAlarm;
   FOutputSetting : TOutputSettings;
   procedure SetInputData(Element : Integer; Value : Integer);
   function GetInputData(Element : Integer) : Integer;
   procedure SetOutputData(Element : Integer; Value : Integer);
   function GetOutputData(Element : Integer) : Integer;
   procedure SetOverRange(Channel : Integer; Value : Boolean);
   function GetOverRange(Channel : Integer) : Boolean;
   procedure SetUnderRange(Channel : Integer; Value : Boolean);
   function GetUnderRange(Channel : Integer) : Boolean;
   procedure SetHighAlarm(Channel : Integer; Value : Boolean);
   function GetHighAlarm(Channel : Integer) : Boolean;
   procedure SetLowAlarm(Channel : Integer; Value : Boolean);
   function GetLowAlarm(Channel : Integer) : Boolean;
   procedure SetOutputSetting(Channel : Integer; Value : Integer);
   function GetOutputSetting(Channel : Integer) : Integer;
   property InputData[Element : Integer] : Integer read GetInputData write SetInputData;
   property OutputData[Element : Integer] : Integer read GetOutputData write SetOutputData;
   property OutputSetting[Channel : Integer] : Integer read GetOutputSetting write SetOutputSetting;
 public
   constructor Create; Override;
   property OverRange[Channel : Integer] : Boolean read GetOverRange write SetOverRange;
   property UnderRange[Channel : Integer] : Boolean read GetUnderRange write SetUnderRange;
   property HighAlarm[Channel : Integer] : Boolean read GetHighAlarm write SetHighAlarm;
   property LowAlarm[Channel : Integer] : Boolean read GetLowAlarm write SetLowAlarm;
 end; // TAnalogCommModule

 TDigitalCommModule = class(TCommModule)
 private
   FModuleEntryStatus : Integer;
   FInputData : TDigitalIOData;
   FOutputData : TDigitalIOData;
   FRelayedOutputData : TRelayDigitalIOData;
   procedure SetInputData(Channel : Integer; Value : Boolean);
   function GetInputData(Channel : Integer) : Boolean;
   procedure SetOutputData(Channel : Integer; Value : Boolean);
   function GetOutputData(Channel : Integer) : Boolean;
   procedure SetRelayedOutputData(Channel : Integer; Value : Boolean);
   function GetRelayedOutputData(Channel : Integer) : Boolean;
   property InputData[Channel : Integer] : Boolean read GetInputData write SetInputData;
   property OutputData[Channel : Integer] : Boolean read GetOutputData write SetOutputData;
   property RelayedOutputData[Channel : Integer] : Boolean read GetRelayedOutputData write SetRelayedOutputData;
 public
   constructor Create; Override;
   property ModuleEntryStatus : Integer read FModuleEntryStatus write FModuleEntryStatus;
 end; // TDigitalCommModule

 TAnalogInputModule = Class(TAnalogCommModule) // 1769-IF8/A Analog Input Module
 public
   property InputData;
 end; // TAnalogInputModule

 TAnalogOutputModule = Class(TAnalogCommModule) // 1769-OF8V/A Analog Input Module
 public
   property OutputData;
 end; // TAnalogInputModule

 TDigitalInputModule = Class(TDigitalCommModule) // 1769-IQ16/A
 public
   property InputData;
 end; // TAnalogInputModule

 TDigitalOutputModule = Class(TDigitalCommModule) // 1769-OW16/A
 public
   property OutputData;
 end; // TDigitalOutputModule

 TRelayedDigitalOutputModule = Class(TDigitalCommModule) // 1769-OW8I/B
 public
   property RelayedOutputData;
 end; // TRelayedDigitalOutputModule

 TDriveModule = Class(TCommModule) // PowerFlex 700 Vector-400V-E
   FDriveStatus : TDriveStatus;
   FOutputFrequency : Integer;
   FDriveLogicResult : TDriveLogicRslt;
   FCommandedFrequency : Integer;
   procedure SetDriveStatus(DrvStat :Integer; Value : Boolean);
   function GetDriveStatus(DrvStat : Integer) : Boolean;
   procedure SetDriveLogicResult(LogicRslt : Integer; Value : Boolean);
   function GetDriveLogicResult(LogicRslt : Integer) : Boolean;
 public
   Constructor Create; Override;
   property DriveStatus[DrvStat : Integer] : Boolean read GetDriveStatus write SetDriveStatus;
   property OutputFrequency : Integer read FOutputFrequency write FOutputFrequency;
   property DriveLogicResult[LogicRslt : Integer] : Boolean read GetDriveLogicResult write SetDriveLogicResult;
   property CommandedFrequency : Integer read FCommandedFrequency write FCommandedFrequency;
 end; // TDriveModule

 TProcessorModule = Class(TCommModule) // CompactLogix 1769-L32E
   FProcessorStatus : TProcessorStatus;
   FRequest_Bits_Status : TRequestBits;
   FProcessorSerialNumber : Extended;
   FProcessorMode : Integer;
   FKeySwitchPosition : Integer;
   FMinorFault : LongInt;
   FPowerUPOK : Boolean;
   FIO_OK : Boolean;
   FProgramOK : Boolean;
   FPLC_Internal_WatchDogOK : Boolean; // Not the ladder logic WatchDog
   FSerialPortOK : Boolean;
   FNonvolatileMemoryOK : Boolean;
   FBatteryOK : Boolean;
   FForcesInstalled : Boolean;
   FForcesEnabled : Boolean;
   procedure SetProcessorStatus(Bit : Integer; Value : Boolean);
   function GetProcessorStatus(Bit : Integer) : Boolean;
   procedure SetRequestBitStatus(Word : Integer; Bit : Integer; Value : Boolean);
   function GetRequestBitStatus(Word : Integer; Bit : Integer) : Boolean;
 public
   Constructor Create; Override;
   property ProcessorStatus[Bit : Integer] : Boolean read GetProcessorStatus write SetProcessorStatus;
   property Request_Bits_Status[Word : Integer; Bit : Integer] : Boolean read GetRequestBitStatus write SetRequestBitStatus;
   property ProcessorSerialNumber : Extended read FProcessorSerialNumber write FProcessorSerialNumber;
   property ProcessorMode : Integer read FProcessorMode write FProcessorMode;
   property KeySwitchPosition : Integer read FKeySwitchPosition write FKeySwitchPosition;
   property MinorFault : LongInt read FMinorFault write FMinorFault;
   property PowerUPOK : Boolean read FPowerUPOK write FPowerUPOK;
   property IO_OK : Boolean read FIO_OK write FIO_OK;
   property ProgramOK : Boolean read FProgramOK write FProgramOK;
   property PLC_Internal_WatchDogOK : Boolean read FPLC_Internal_WatchDogOK write FPLC_Internal_WatchDogOK;
   property SerialPortOK : Boolean read FSerialPortOK write FSerialPortOK;
   property NonvolatileMemoryOK : Boolean read FNonvolatileMemoryOK write FNonvolatileMemoryOK;
   property BatteryOK : Boolean read FBatteryOK write FBatteryOK;
   property ForcesInstalled : Boolean read FForcesInstalled write FForcesInstalled;
   property ForcesEnabled : Boolean read FForcesEnabled write FForcesEnabled;
 end; // TProcessorModule

 TAnalogOutputModule_IV = Class(TAnalogCommModule)
 public
   property OutputData;
   property OutputSetting;
 end; // TAnalogOutputModule_IV

 TModuleArray = array[0..MaximumModules] of TObject;
 TModuleType = array[0..MaximumModules] of Integer;
 TControllerSerialNumbers = array[0..MaximumModules] of Extended;

 TConfigurationError = procedure(Sender : TObject; ErrorNumber : integer; PLCErrorMessage : ShortString) of Object;
 TReadWriteErrorEvent = procedure(Sender : TObject; ErrorNumber : integer; PLCErrorMessage : ShortString; ErrorPacket : TPLCWritePacketRecord; ExceededFaultTollerance : Boolean) of Object;
 TReadWriteRecoverableErrorEvent = procedure(Sender : TObjecT; ErrorNumber : Integer; PLCErrorMessage : ShortString) of Object;
 TPLCMajorError = procedure(Sender : TObject; ErrorNumber : smallint; HexValue : ShortString) of Object;
 TSendModuleData = procedure(Sender : TObject; Modules : TModuleArray; ModuleTypes : TModuleType; ModuleCount : Integer) of Object;
 TValueReadFromPLC = procedure(Sender : TObject; ReturnedPacket : TPLCReadPacketRecord) of Object;

 TCompactLogixPLC = class;
 TPLCWriteThread = class;

 TPLCWatchDogThread = Class(TThread)
 private
   FPLCWriteThread : TPLCWriteThread;
   FWatchDogValue : Boolean;
   FWatchDogTag : ShortString;
   FSleepInterval : LongInt;
   FWatchDogEnabled : Boolean;
 protected
   procedure DoSendWatchDogToggle;
   procedure Execute; Override;
 public
   constructor Create(Var ParentThread : TPLCWriteThread);
   destructor Destroy; Override;
   property WatchDogEnabled : Boolean read FWatchDogEnabled write FWatchDogEnabled;
   property WatchDogTag : ShortString read FWatchDogTag write FWatchDogTag;
   property SleepInterval : LongInt read FSleepInterval write FSleepInterval;
 end; // TPLCWatchDogThread

 TPLCWriteThread = class(TThread)
 private
   PLCMonitor : TCompactLogixPLC;
   FPLCWrite : TABCTL;
   FWriteFault : Boolean;
   FWriteStack : TStringList;
   FWritePacketsInQue : longInt;
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
   procedure PLCWriteErrorEvent(Sender : TObject; nErrorCode : TIntErrorCode);
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
   function ValidatePacket(lPacket : TPLCWritePacket) : Boolean;
   function AddToWriteStack(lPacket : TPLCWritePacket) : Boolean;
   procedure Execute; Override;
 public
   constructor Create(var lParent : TCompactLogixPLC);
   destructor Destroy; Override;
   function WriteToPLC(vTag : ShortString; vSize : integer; vValue : Integer) : Boolean;
   property WriteEnabled : Boolean read FWriteEnabled write SetWriteEnabled;
   property WriteIPAddress : ShortString read FWriteIPAddress write SetIPAddress;
   property WriteQue : LongInt read FPacketQueLength;
   property WriteAdapterNum : LongInt read GetAdapterNum write SetAdapterNum;
   property WriteFault : Boolean read FWriteFault write FWriteFault;
   property LastError : Integer read FWriteErrorNum;
   property WriteFaultTollerance : LongInt read FWriteFaultTol write FWriteFaultTol;
   property EthernetTimeOut : SmallInt read GetEthernetTimeOut write SetEthernetTimeOut;
   property WriteAttemptsBeforeFail : LongInt read FWriteAttemptsBeforeFail write FWriteAttemptsBeforeFail;
 end; // TPLCWriteThread

 TPLCReadThread = class(TThread)
 private
   PLCMonitor : TCompactLogixPLC;
   FSleepTime : LongInt;
   FPLCRead : TABCTL;
   FReadFault : Boolean;
   FReadErrorNum : Integer;
   FReadErrorStr : ShortString;
   FReadEnabled : Boolean;
   FReadIPAddress : ShortString;
   FModulesLoaded : Boolean;
   FModuleCount : Integer;
   FModuleType : TModuleType;
   FModules : TModuleArray;
   FPLCReadTag : ShortString;
   FPLCReadSize : Integer;
   FFirstRead : Boolean;
   FReadStack : TStringList;
   FProcessReadPacket : Boolean;
   FReadPacketRec : TPLCReadPacketRecord;
   FReadFaultTol : LongInt;
   FReadFaultCount : LongInt;
   FPacketQueLength : LongInt;
   procedure SetSleepTime(Value : LongInt);
   procedure PLCReadErrorEvent(Sender : TObject; nErrorCode : TIntErrorCode);
   procedure PLCReadReadDone(Sender : TObject);
   procedure SetReadEnabled(Value : Boolean);
   procedure SetReadIPAddress(Value : ShortString);
   procedure SetModules(Modules : TModuleArray);
   function GetModules : TModuleArray;
   procedure SetModuleTypes(ModuleTypes : TModuleType);
   function GetModuleTypes : TModuleType;
   function GetControllerSerialNumber : TControllerSerialNumbers;
   procedure SetReadSize(Value : Integer);
   procedure SetReadTag(Value : ShortString);
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
   procedure DoReadRecoverableErrorEvent;
   procedure DoPassModuleData;
   procedure PopulateModules;
   procedure Execute; Override;
   procedure AddToReadStack(lPacket : TPLCReadPacket);
 public
   constructor Create(Var lParent : TCompactLogixPLC);
   destructor Destroy; Override;
   procedure ReadFromPLC(vTag : ShortString; vSize : LongInt);
   property SleepTime : LongInt read FSleepTime write SetSleepTime;
   property ReadEnabled : Boolean read FReadEnabled write SetReadEnabled;
   property ReadIPAddress : ShortString read FReadIPAddress write SetReadIPAddress;
   property ReadQue : LongInt read FPacketQueLength;
   property ReadAdapterNum : LongInt read GetAdapterNum write SetAdapterNum;
   property ReadFault : Boolean read FReadFault write FReadFault;
   property LastError : Integer read FReadErrorNum;
   property Modules : TModuleArray read GetModules write SetModules;
   property ModuleCount : Integer read FModuleCount write FModuleCount;
   property ModuleTypes : TModuleType read GetModuleTypes write SetModuleTypes;
   property ReadTag : ShortString read FPLCReadTag write SetReadTag;
   property ReadSize : Integer read FPLCReadSize write SetReadSize;
   property ReadFaultTollerance : LongInt read FReadFaultTol write FReadFaultTol;
   property ControllerSerialNumbers : TControllerSerialNumbers read GetControllerSerialNumber;
   property EthernetTimeOut : SmallInt read GetEthernetTimeOut write SetEthernetTimeOut;
 end; // TPLCReadThread

 TCompactLogixPLC = class(TComponent)
 private
 {Private Declarations}
   FOnSendModuleData : TSendModuleData;
   FOnConfigurationError : TConfigurationError;
   FOnReadError,
   FOnWriteError : TReadWriteErrorEvent;
   FOnReadRecoverableError,
   FOnWriteRecoverableError : TReadWriteRecoverableErrorEvent;
   FOnPLCWriteDisabled : TNotifyEvent;
   FOnValueReadFromPLC : TValueReadFromPLC;
   FEnabled,
   FWatchDogActive : boolean;
   FWatchDogInterval : integer;
   FWatchDogTag : ShortString;
   FPLCWriteThread : TPLCWriteThread;
   FPLCReadThread : TPLCReadThread;
   FPLCWatchDogThread : TPLCWatchDogThread;
   FReadInterval : longInt;
   FThreadStarted : boolean;
   FModuleCount : Integer;
   Modules : TModuleArray;
   ModuleType : TModuleType;
   FModulesPresent : Boolean;
   FConfigurationFile : ShortString;
   FVersion : ShortString;
   FReadAddress : ShortString;
   FReadSize : Integer;
   FReadIPAddress : ShortString;
   FWriteIPAddress : ShortString;
   FWatchDogTimeOut : LongInt;
   FWatchDogHi : ShortString;
   FWatchDogLo : ShortString;
   FReadFaultTollerance : LongInt;
   FWriteFaultTollerance : LongInt;
   FEthernetTimeOut : SmallInt;
   FMaximumWriteAttempts : LongInt;
   FReadAdapterNo : LongInt;
   FWriteAdapterNo : LongINt;
   function GetEnabled : boolean;
   procedure SetEnabled(Value : Boolean);
   procedure SetReadIPAddress(Value : ShortString);
   function GetReadIPAddress : ShortString;
   procedure SetWriteIPAddress(Value : ShortString);
   function GetWriteIPAddress : ShortString;
   procedure SetReadAddress(Value : ShortString);
   procedure SetReadSize(Value : Integer);
   procedure SetWatchDogState(Value : boolean);
   procedure SetWatchDogInterval(Value : longint);
   procedure SetReadInterval(Value : LongInt);
   function GetReadInterval : LongInt;
   function GetErrorMessage(nErrorCode : TIntErrorCode) : String;
   function GetLastReadError : String;
   function GetLastWriteError : String;
   procedure SetVersion(Value : ShortString);
   function GetWriteFault : Boolean;
   function GetReadFault : Boolean;
   procedure SetWatchDogTag(Value : ShortString);
   procedure SetPLCIPAddress(Value : ShortString);
   function GetPLCIPAddress : ShortString;
   function GetReadAdapterNum : LongInt;
   procedure SetReadAdapterNum(Value : LongInt);
   function GetWriteAdapterNum : LongInt;
   procedure SetWriteAdapterNum(Value : LongInt);
   function GetReadPacketsInQue : LongInt;
   function GetWritePacketsInQue : LongInt;
   procedure SetWatchDogTimeOut(Value : LongInt);
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
   procedure SavePLCConfiguration(lFileName : ShortString);
   function ValidIPAddress(Value : ShortString) : Boolean;
   procedure SetModuleCount(Value : Integer);
   function GetControllerSerialNumber : TControllerSerialNumbers;
   function CheckModuleConfigutaion : Boolean;
 public
 {Public Declarations}
   Constructor Create(AOwner : TComponent); Override;
   Destructor Destroy; Override;
   procedure LoadPLCConfiguration(lFileName : String);
   procedure ResetPLCError;
   function ProcessorMode(ProcessorMode : Integer) : ShortString;
   function KeySwitchPosition(KeySwitchPosition : Integer) : ShortString;
   function WriteToPLC(vTag : ShortString; vSize : integer; vValue : Integer) : Boolean;
   property ControllerSerialNumbers : TControllerSerialNumbers read GetControllerSerialNumber;
   procedure ReadFromPLC(vTag : ShortString; vSize : LongInt);
   procedure InputConfiguredModules(InputModules : TModuleArray);
   function RetrieveConfiguredModules : TModuleArray;
 published
 {Published Declarations}
   property Version : ShortString read FVersion write SetVersion;
   property Enabled : boolean read GetEnabled write SetEnabled;
   property ReadIPAddress : ShortString read GetReadIPAddress write SetReadIPAddress;
   property WriteIPAddress : ShortString read GetWriteIPAddress write SetWriteIPAddress;
   property ReadAdapterNum : LongInt read GetReadAdapterNum write SetReadAdapterNum;
   property WriteAdapterNum : LongInt read GetWriteAdapterNum write SetWriteAdapterNum;
   property WriteFault : boolean read GetWriteFault;
   property ReadFault : boolean read GetReadFault;
   property EnableWatchDog : boolean read FWatchDogActive write SetWatchDogState;
   property WatchDogHi : ShortString read FWatchDogHi write FWatchDogHi;
   property WatchDogLo : ShortString read FWatchDogLo write FWatchDogLo;
   property WatchDogTimeOut : LongInt read FWatchDogTimeOut write SetWatchDogTimeOut default 500;
   property WatchDogInterval : integer read FWatchDogInterval write SetWatchDogInterval;
   property WatchDogTag : ShortString read FWatchDogTag write SetWatchDogTag;
   property ReadTag : ShortString read FReadAddress write SetReadAddress;
   property ReadSize : Integer read FReadSize write SetReadSize;
   property ReadInterval : LongInt read GetReadInterval write SetReadInterval default 100;
   property ModuleCount : Integer read FModuleCount write SetModuleCount;
   property LastReadError : String read GetLastReadError;
   property LastWriteError : String read GetLastWriteError;
   property PLCIPAddress : ShortString read GetPLCIPAddress write SetPLCIPAddress;
   property ReadPacketsInQue : LongInt read GetReadPacketsInQue;
   property WritePacketsInQue : LongInt read GetWritePacketsInQue;
   property ReadFaultTollerance : LongInt read GetReadFaultTollerance write SetReadFaultTollerance;
   property WriteFaultTollerance : LongInt read GetWriteFaultTollerance write SetWriteFaultTollerance;
   property EthernetTimeOut : SmallInt read GetEthernetTimeOut write SetEthernetTimeOut;
   property MaximumWriteAttempts : LongInt read GetMaximumWriteAttempts write SetMaximumWriteAttempts;

   property OnConfigurationError : TConfigurationError read FOnConfigurationError write FOnConfigurationError;
   property OnReadError : TReadWriteErrorEvent read FOnReadError write FOnReadError;
   property OnReadRecoverableError : TReadWriteRecoverableErrorEvent read FOnReadRecoverableError write FOnReadRecoverableError;
   property OnWriteError : TReadWriteErrorEvent read FOnWriteError write FOnWriteError;
   property OnWriteRecoverableError : TReadWriteRecoverableErrorEvent read FOnWriteRecoverableError write FOnWriteRecoverableError;
   property OnNewModuleData : TSendModuleData read FOnSendModuleData write FOnSendModuleData;
   property OnPLCWriteDisabled : TNotifyEvent read FOnPLCWriteDisabled write FOnPLCWriteDisabled;
   property OnValueReadFromPLC : TValueReadFromPLC read FOnValueReadFromPLC write FOnValueReadFromPLC;
 end; // TCompactLogixPLC

const
  StrModuleTypes : Array[M_AnlgInput..M_Processor] of String = ('Analog Input','Analog Output','Digital Input','Digital Output','Relayed Digital Output','Drive','Processor');

procedure Register;

implementation
{_R CompactLogixComms.dcr}

uses StRegINI, Math, Forms;

var
  UsingReadStack : LongInt;
  UsingWriteStack : LongInt;

procedure Register;
begin
  RegisterComponents('TMSI', [TCompactLogixPLC]);
end;

constructor TCommModule.Create;
begin
  inherited Create;
  FModuleNumber := 0;
  FModuleType := 0;
  FModuleString := '';
  FModuleEntryStatus := 0;
  FillChar(FModuleArrayElements,SizeOf(FModuleArrayElements),#0);
  FillChar(FFault,SizeOf(FFault),#0);
end; // TCommModule.Create

procedure TCommModule.SetModuleArrayElement(Element : Integer; ModuleArrayElement : TModuleElement);
begin
  FModuleArrayElements[Element] := ModuleArrayElement;
end; // TCommModule.SetModuleElement

function TCommModule.GetModuleArrayElement(Element : Integer) : TModuleElement;
begin
  Result := FModuleArrayElements[Element];
end; // TCommModule.GetModuleElement

procedure TCommModule.SetFault(Channel : Integer; Value : Boolean);
begin
  FFault[Channel] := Value;
end; // TCommModule.SetFault

function TCommModule.GetFault(Channel : Integer) : Boolean;
begin
  Result := FFault[Channel];
end; // TCommModule.GetFault

constructor TAnalogCommModule.Create;
begin
  inherited Create;
  FillChar(FInputData,SizeOf(FInputData),#0);
  FillChar(FOutputData,SizeOf(FOutputData),#0);
  FillChar(FOverRange,SizeOf(FOverRange),#0);
  FillChar(FUnderRange,SizeOf(FUnderRange),#0);
  FillChar(FHighAlarm,SizeOf(FHighAlarm),#0);
  FillChar(FLowAlarm,SizeOf(FLowAlarm),#0);
  FillChar(FOutputSetting,SizeOf(FOutputSetting),#0);
end; // TAnalogCommModule.Create

procedure TAnalogCommModule.SetInputData(Element : Integer; Value : Integer);
begin
  FInputData[Element] := Value;
end; // TAnalogCommModule.SetInputData

function TAnalogCommModule.GetInputData(Element : Integer) : Integer;
begin
  Result := FInputData[Element];
end; // TAnalogCommModule.GetInputData

procedure TAnalogCommModule.SetOutputData(Element : Integer; Value : Integer);
begin
  FOutputData[Element] := Value;
end; // TAnalogCommModule.SetOutputData

function TAnalogCommModule.GetOutputData(Element : Integer) : Integer;
begin
  Result := FOutputData[Element];
end; // TAnalogCommModule.GetOutputData

procedure TAnalogCommModule.SetOverRange(Channel : Integer; Value : Boolean);
begin
  FOverRange[Channel] := Value;
end; // TAnalogCommModule.SetOverRange

function TAnalogCommModule.GetOverRange(Channel : Integer) : Boolean;
begin
  Result := FOverRange[Channel];
end; // TAnalogCommModule.GetOverRange

procedure TAnalogCommModule.SetUnderRange(Channel : Integer; Value : Boolean);
begin
  FUnderRange[Channel] := Value;
end; // TAnalogCommModule.SetUnderRange

function TAnalogCommModule.GetUnderRange(Channel : Integer) : Boolean;
begin
  Result := FUnderRange[Channel];
end; // TAnalogCommModule.GetUnderRange

procedure TAnalogCommModule.SetHighAlarm(Channel : Integer; Value : Boolean);
begin
  FHighAlarm[Channel] := Value;
end; // TAnalogCommModule.SetHighAlarm

function TAnalogCommModule.GetHighAlarm(Channel : Integer) : Boolean;
begin
  Result := FHighAlarm[Channel];
end; // TAnalogCommModule.GetHighAlarm

procedure TAnalogCommModule.SetLowAlarm(Channel : Integer; Value : Boolean);
begin
  FLowAlarm[Channel] := Value;
end; // TAnalogCommModule.SetLowAlarm

function TAnalogCommModule.GetLowAlarm(Channel : Integer) : Boolean;
begin
  Result := FLowAlarm[Channel];
end; // TAnalogCommModule.GetLowAlarm

procedure TAnalogCommModule.SetOutputSetting(Channel : Integer; Value : Integer);
begin
  FOutputSetting[Channel] := Value;
end; // TAnalogCommModule.SetOutputSetting

function TAnalogCommModule.GetOutputSetting(Channel : Integer) : Integer;
begin
  Result := FOutputSetting[Channel];
end; // TAnalogCommModule.GetOutputSetting

constructor TDigitalCommModule.Create;
begin
  inherited Create;
  FillChar(FInputData,SizeOf(FInputData),#0);
  FillChar(FOutputData,SizeOf(FOutputData),#0);
  FillChar(FRelayedOutputData,SizeOf(FRelayedOutputData),#0);
end; // TDigitalCommModule.Create

procedure TDigitalCommModule.SetInputData(Channel : Integer; Value : Boolean);
begin
  FInputData[Channel] := Value;
end; // TDigitalCommModule.SetInputData

function TDigitalCommModule.GetInputData(Channel : Integer) : Boolean;
begin
  Result := FInputData[Channel];
end; // TDigitalCommModule.GetInputData

procedure TDigitalCommModule.SetOutputData(Channel : Integer; Value : Boolean);
begin
  FOutputData[Channel] := Value;
end; // TDigitalCommModule.SetOutputData

function TDigitalCommModule.GetOutputData(Channel : Integer) : Boolean;
begin
  Result := FOutputData[Channel];
end; // TDigitalCommModule.GetOutputData

procedure TDigitalCommModule.SetRelayedOutputData(Channel : Integer; Value : Boolean);
begin
  FRelayedOutputData[Channel] := Value;
end; // TDigitalCommModule.SetRelayedOutputData

function TDigitalCommModule.GetRelayedOutputData(Channel : Integer) : Boolean;
begin
  Result := FRelayedOutputData[Channel];
end; // TDigitalCommModule.GetRelayedOtuputData

procedure TPLCWatchDogThread.DoSendWatchDogToggle;
begin
  if Assigned(FPLCWriteThread) then
  begin
    if FWatchDogEnabled then
    begin
      FPLCWriteThread.WriteToPLC(FWatchDogTag,1,Ord(FWatchDogValue));
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
  FWatchDogTag := '';
  FSleepInterval := 1000;
  FWatchDogEnabled := False;
end; // TPLCWatchDogThread.Create

destructor TPLCWatchDogThread.Destroy;
begin
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread := Nil;
  inherited Destroy;
end; // TPLCWatchDogThread.Destroy

procedure TPLCReadThread.SetReadTag(Value : ShortString);
begin
  FPLCReadTag := Value;
  if Assigned(FPLCRead) then
    FPLCRead.FileAddr := FPLCReadTag;
end; // TPLCReadThread.SetReadTag

procedure TPLCReadThread.SetReadSize(Value : Integer);
begin
  FPLCReadSize := Value;
  if Assigned(FPLCRead) then
    FPLCRead.Size := FPLCReadSize;
end; // TPLCReadThread.SetReadSize

function TCompactLogixPLC.GetControllerSerialNumber : TControllerSerialNumbers;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ControllerSerialNumbers;
end; // TCompactLogixPLC.GetControllerSerialNumber

function TPLCReadThread.GetControllerSerialNumber : TControllerSerialNumbers;
var
  i : Integer;
  lProcessorModule : TProcessorModule;
  lProcessorSerialNumbers : TControllerSerialNumbers;
begin
  FillChar(lProcessorSerialNumbers,SizeOf(lProcessorSerialNumbers),#0);
  for i := 0 to (FModuleCount - 1) do
  begin
    if (FModuleType[i] = 6) then // Processor Module
    begin
      lProcessorModule := FModules[i] as TProcessorModule;
      lProcessorSerialNumbers[i] := lProcessorModule.ProcessorSerialNumber;
    end; // If
  end; // For i
  Result := lProcessorSerialNumbers;
end; // TPLCReadThread.GetControllerSerialNumber

function TCompactLogixPLC.WriteToPLC(vTag : ShortString; vSize : Integer; vValue : Integer) : Boolean;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteToPLC(vTag,vSize,vValue);
end; // TCompactLogixPLC.WriteToPLC

procedure TCompactLogixPLC.SetModuleCount(Value : Integer);
begin
  FModuleCount := Value;
end; // TCompactLogixPLC.SetModuleCount

procedure TCompactLogixPLC.SetWatchDogTag(Value : ShortString);
begin
  FWatchDogTag := Value;
  if Assigned(FPLCWatchDogThread) then
    FPLCWatchDogThread.WatchDogTag := FWatchDogTag;
end; // TCompactLogixPLC.SetWatchDogTag

function TCompactLogixPLC.GetWriteFault : Boolean;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteFault
  else
    Result := False;
end; // TCompactLogixPLC.GetWriteFault

function TCompactLogixPLC.GetReadFault : Boolean;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadFault
  else
    Result := False;
end; // TCompactLogixPLC.GetReadFault

function TCompactLogixPLC.GetWriteIPAddress : ShortString;
begin
  if Assigned(FPLCWriteThread) then
  begin
    FWriteIPAddress := FPLCWriteThread.WriteIPAddress;
    Result := FWriteIPAddress;
  end
  else
  begin
    Result := FWriteIPAddress;
  end; // If
end; // TCompactLogixPLC.GetWriteIPAddress

procedure TCompactLogixPLC.SetWriteIPAddress(Value : ShortString);
begin
  if ValidIPAddress(Value) then
    FWriteIPAddress := Value
  else
  begin
    if Assigned(FOnConfigurationError) then
      FOnConfigurationError(Self,4,'Attempted to apply invalid write IP address.');
  end; // If
  if Assigned(FPLCWriteThread) then
      FPLCWriteThread.WriteIPAddress := Value
end; // TCompactLogixPLC.SetWriteIPAddress

function TCompactLogixPLC.GetReadIPAddress : ShortString;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadIPAddress
  else
    Result := FReadIPAddress;
end; // TCompactLogixPLC.GetReadIPAddress

procedure TCompactLogixPLC.SetReadIPAddress(Value : ShortString);
begin
  if ValidIPAddress(Value) then
    FReadIPAddress := Value
  else
  begin
    if Assigned(FOnConfigurationError) then
      FOnConfigurationError(Self,3,'Attempted to apply invalid read IP address.');
  end; // If
  if Assigned(FPLCReadThread) then
      FPLCReadThread.ReadIPAddress := Value
end; // TPLCReadThread.SetReadIPAddress

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

constructor TPLCReadThread.Create(var lParent : TCompactLogixPLC);
begin
  inherited Create(True);
  PLCMonitor := lParent;
  FSleepTime := 0;
  FReadFault := False;
  FReadErrorNum := 0;
  FReadErrorStr := '';
  FReadEnabled := False;
  FReadIPAddress := '0.0.0.0';
  FModulesLoaded := False;
  FModuleCount := 0;
  FillChar(FModuleType,SizeOf(FModuleType),#0);
  FillChar(FModules,SizeOf(FModules),#0);
  FPLCReadTag := '';
  FPLCReadSize := 0;
  FFirstRead := True;
  FReadStack := TStringList.Create;
  FReadStack.Clear;
  FProcessReadPacket := False;
  FillChar(FReadPacketRec,SizeOf(FReadPacketRec),#0);
  FReadFaultTol := 4;
  FReadFaultCount := 0;
  FPacketQueLength := 0;
  {$IFNDEF NOPLC}
  FPLCRead := TABCTL.Create(Nil);
  with FPLCRead do
  begin
    Adapter          := 0;
    Enabled          := False;
    Function_        := 0;
    FileAddr         := 'N7:0';
    Size             := 1;
    TimeOut          := 1000;
    Host             := FReadIPAddress;
    OnErrorEvent     := PLCReadErrorEvent;
    OnReadDone       := PLCReadReadDone
  end; // With
  {$ENDIF}
end; // TPLCReadThread.Create

procedure TPLCReadThread.Execute;
var
  OKToProcess : LongInt;
begin
  repeat
    if Not Terminated then                                   
    begin
      Sleep(FSleepTime);
      OKToProcess := WaitForSingleObject(UsingReadStack,1000);
      if (OKToProcess = Wait_Object_0) then
      begin
        DoReadPacket;
        ReleaseSemaphore(UsingReadStack,1,Nil);
      end; // If
      DoReadFromPLC;
    end; // If
  until Terminated;
end; // TPLCReadThread.Execute

procedure TPLCReadThread.DoPassModuleData;
begin
  if Assigned(PLCMonitor.OnNewModuleData) then
    PLCMonitor.OnNewModuleData(Self,FModules,FModuleType,FModuleCount);
end; // TPLCReadThread.DoPassModuleData;

procedure TPLCReadThread.DoReadRecoverableErrorEvent;
begin
  if Assigned(PLCMonitor.OnReadRecoverableError) then
    PLCMonitor.OnReadRecoverableError(Self,FReadErrorNum,FReadErrorStr);
end; // TPLCReadThread.DoReadRevocerbleErrorEvent

procedure TPLCReadThread.DoReadErrorEvent;
var
  PacketRec : TPLCWritePacketRecord;
begin
  if Assigned(PLCMonitor.OnReadError) then
  begin
    with PacketRec do
    begin
      Tag := FPLCReadTag;
      Size := FPLCReadSize;
      Value := 0;
    end; // With
    PLCMonitor.OnReadError(Self,FReadErrorNum,FReadErrorStr,PacketRec, FReadFault);
  end; // If
end; // TPLCReadThread.DoReadErrorEvent

procedure TPLCReadThread.DoReadFromPLC;
begin
  if Assigned(FPLCRead) then
  begin
    if Not FReadFault then
    begin
      if FPLCRead.Enabled then
      begin
        if Not FPLCRead.Busy then
        begin
          if Not Terminated then
            FPLCRead.Trigger;
          if Not Terminated then
            PopulateModules;
        end; // If
      end; // If
    end; // If
  end; // If
end; // TPLCReadThread.DoReadFromPLC

function TPLCReadThread.GetModuleTypes;
begin
  Result := FModuleType;
end; // TPLCReadThread.GetModuleTypes

procedure TPLCReadThread.SetModuleTypes(ModuleTypes : TModuleType);
var
  i : Integer;
begin
  for i := Low(ModuleTypes) to High(ModuleTypes) do
    FModuleType[i] := ModuleTypes[i]
end; // TPLCReadThread.SetModuleTypes

function TPLCReadThread.GetModules : TModuleArray;
begin
  Result := FModules;
end; // TPLCReadThread.GetModules

procedure TPLCReadThread.SetModules(Modules : TModuleArray);
var
  i : Integer;
begin
  for i := Low(Modules) to High(Modules) do
  begin
    if (Modules[i] <> Nil) then
    begin
      FModules[i] := Modules[i];
      if (FModules[i] is TAnalogInputModule) then
        FModuleType[i] := 0;
      if (FModules[i] is TAnalogOutputModule) then
        FModuleType[i] := 1;
      if (FModules[i] is TDigitalInputModule) then
        FModuleType[i] := 2;
      if (FModules[i] is TDigitalOutputModule) then
        FModuleType[i] := 3;
      if (FModules[i] is TRelayedDigitalOutputModule) then
        FModuleType[i] := 4;
      if (FModules[i] is TDriveModule) then
        FModuleType[i] := 5;
      if (FModules[i] is TProcessorModule) then
        FModuleType[i] := 6;
      if (FModules[i] is TAnalogOutputModule_IV) then
        FModuleType[i] := 7;
    end
    else
    begin
      FModuleCount := i;
      Break;
    end; // If
  end; // For i
  FModulesLoaded := True;
end; // TPLCReadThread.SetModules

procedure TPLCReadThread.SetReadIPAddress(Value : ShortString);
begin
  if Assigned(FPLCRead) then
  begin
    FReadIPAddress := Value;
    FPLCRead.Host := FReadIPAddress;
  end; // If
end; // If

procedure TPLCReadThread.SetReadEnabled(Value : Boolean);
begin
  if Assigned(FPLCRead) then
  begin
    FReadEnabled := Value;
    FPLCRead.Enabled := FReadEnabled;
  end; // If
end; // TPLCReadThread.SetReadEnabled

procedure TPLCReadThread.SetSleepTime(Value : LongInt);
begin
  FSleepTime := Value;
  if (FSleepTime = 0) then
    FSleepTime := 1;
end; // TPLCReadThread.SetSleepTime

procedure TPLCWriteThread.DoWriteRecoverableErrorEvent;
begin
  if Assigned(PLCMonitor.OnWriteRecoverableError) then
    PLCMonitor.OnWriteRecoverableError(Self,FWriteErrorNum,FWriteErrorStr);
end; // TPLCWriteThread.DoWriteRecoverableErrorEvent

procedure TPLCWriteThread.DoWriteErrorEvent;
begin
  if Assigned(PLCMonitor.OnWriteError) then
    PLCMonitor.OnWriteError(Self,FWriteErrorNum,FWriteErrorStr,FLastPacketWritten,FWriteFault);
end; // TPLCWriteThread.DoWriteErrorEvent

procedure TPLCWriteThread.SetIPAddress(Value : ShortString);
begin
  if Assigned(FPLCWrite) then
  begin
    FWriteIPAddress := Value;
    FPLCWrite.Host := FWriteIPAddress;
  end; // If
end; // TPLCWriteThread.SetIPAddress

procedure TPLCWriteThread.SetWriteEnabled;
begin
  if Assigned(FPLCWrite) then
  begin
    FWriteEnabled := Value;
    FPLCWrite.Enabled := FWriteEnabled;
  end; // If
end; // TPLCWriteThread.SetWriteEnabled

Constructor TDriveModule.Create;
begin
  inherited Create;
  FOutputFrequency := 0;
  FCommandedFrequency := 0;
  FillChar(FDriveLogicResult,SizeOf(FDriveLogicResult),#0);
  FillChar(FDriveStatus,SizeOf(FDriveStatus),#0);
end; // TDriveModule.Create

procedure TDriveModule.SetDriveStatus(DrvStat :Integer; Value : Boolean);
begin
  FDriveStatus[DrvStat] := Value;
end; // TDriveModule.SetDriveStatus

function TDriveModule.GetDriveStatus(DrvStat : Integer) : Boolean;
begin
  Result := FDriveStatus[DrvStat];
end; // TDriveModule.GetDriveStatus

procedure TDriveModule.SetDriveLogicResult(LogicRslt : Integer; Value : Boolean);
begin
  FDriveLogicResult[LogicRslt] := Value;
end; // TDriveModule.SetDriveLogicResult

function TDriveModule.GetDriveLogicResult(LogicRslt : Integer) : Boolean;
begin
  Result := FDriveLogicResult[LogicRslt];
end; // TDriveModule.GetDriveLogicResult

Constructor TProcessorModule.Create;
begin
  inherited Create;
  FProcessorSerialNumber := 0;
  FProcessorMode := 0;
  FKeySwitchPosition := 0;
  FMinorFault := 0;
  FPowerUPOK := False;
  FIO_OK := False;
  FProgramOK := False;
  FPLC_Internal_WatchDogOK := False; // Not the ladder logic WatchDog
  FSerialPortOK := False;
  FNonvolatileMemoryOK := False;
  FBatteryOK := False;
  FForcesInstalled := False;
  FForcesEnabled := False;
  FillChar(FProcessorStatus,SizeOf(FProcessorStatus),#0);
  FillChar(FRequest_Bits_Status,SizeOf(FRequest_Bits_Status),#0);
end; // TProcessorModule.Create

procedure TProcessorModule.SetProcessorStatus(Bit : Integer; Value : Boolean);
begin
  FProcessorStatus[Bit] := Value;
end; //TProcessorModule.SetProcessorStatus

function TProcessorModule.GetProcessorStatus(Bit : Integer) : Boolean;
begin
  Result := FProcessorStatus[Bit];
end; // TProcessorModule.GetProcessorStatus

procedure TProcessorModule.SetRequestBitStatus(Word : Integer; Bit : Integer; Value : Boolean);
begin
  FRequest_Bits_Status[Word,Bit] := Value;
end; // TProcessorModule.SetRequestBitStatus

function TProcessorModule.GetRequestBitStatus(Word : Integer; Bit : Integer) : Boolean;
begin
  Result := FRequest_Bits_Status[Word,Bit];
end; // TProcessorModule.GetRequestBitStatus

Constructor TCompactLogixPLC.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FEnabled := False;
  FWatchDogActive := False;
  FWatchDogInterval := 1000;
  FThreadStarted := False;
  FModuleCount := 0;
  FModulesPresent := False;
  FConfigurationFile := '';
  FillChar(ModuleType,SizeOf(ModuleType),#0);
  FWatchDogTag := '';
  FVersion := '1.2.5';
  FReadInterval := 100;
  FReadAddress := '';
  FReadSize := 0;
  FReadIPAddress := '0.0.0.0';
  FWriteIPAddress := '0.0.0.0';
  FWatchDogTimeOut := 2000;
  FWatchDogHi := '';
  FWatchDogLo := '';
  FReadFaultTollerance := 0;
  FWriteFaultTollerance := 0;
  FEthernetTimeOut := 1000{ms};
  FReadAdapterNo := 0;
  FWriteAdapterNo := 0;
  {$IFNDEF NOPLC}
  if not (csDesigning in ComponentState) then
  begin
    FPLCWriteThread := TPLCWriteThread.Create(Self);
    FPLCReadThread := TPLCReadThread.Create(Self);
    FPLCWatchDogThread := TPLCWatchDogThread.Create(FPLCWriteThread);
  end; // If
  {$ENDIF}
end; // TCompactLogixPLC.Create

Destructor TCompactLogixPLC.Destroy;
begin
  {$IFNDEF NOPLC}
  if not (csDesigning in ComponentState) then
  begin
    SavePLCConfiguration(FConfigurationFile);
    if FThreadStarted then
    begin
      FPLCWatchDogThread.Terminate;
      FPLCReadThread.Terminate;
      FPLCWriteThread.Terminate;
      FPLCWatchDogThread.Suspend;
      FPLCReadThread.Suspend;
      FPLCWriteThread.Suspend;
    end; // If
    FPLCWatchDogThread.Free;
    FPLCReadThread.Free;
    FPLCWriteThread.Free;
    FPLCWatchDogThread := Nil;
    FPLCReadThread := Nil;
    FPLCWriteThread := Nil;
  end; // If
  {$ENDIF}
  inherited Destroy;
end; // TCompactLogixPLC.Destroy

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

constructor TPLCWriteThread.Create(Var lParent : TCompactLogixPLC);
begin
  inherited Create(True);
  PLCMonitor := lParent;
  FWriteEnabled := False;
  FillChar(FLastPacketWritten,SizeOf(FLastPacketWritten),#0);
  Fillchar(FLastPacketWithError,SizeOf(FLastPacketWithError),#0);
  FWriteStack := TStringList.Create;
  FWriteStack.Clear;
  FWritePacketsInQue := 0;
  FWriteErrorNum := 0;
  FWriteErrorStr := '';
  FWriteIPAddress := '0.0.0.0';
  FWriteFaultTol := 1;
  FWriteFaultCount := 0;
  FPacketQueLength := 0;
  FWriteAttemptsBeforeFail := 0;
  {$IFNDEF NOPLC}
  FPLCWrite := TABCTL.Create(Nil);
  with FPLCWrite do
  begin
    Adapter          := 0;
    Enabled          := False;
    Function_        := 1;
    FileAddr         := 'N7:0';
    Size             := 1;
    TimeOut          := 1000;
    Host             := FWriteIPAddress;
    OnErrorEvent     := PLCWriteErrorEvent;
    OnWriteDone      := PLCWriteWriteDone;
  end; // With
  {$ENDIF}
end; // TPLCWriteThread.Create

procedure TPLCWriteThread.DoTransmitPacket;
var
  TransmitPacket : TPLCWritePacket;
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
              FLastPacketWritten.Size := TransmitPacket.Size;
              FLastPacketWritten.Tag := TransmitPacket.Tag;
              FLastPacketWritten.Value := TransmitPacket.Value;
              if FPLCWrite.Enabled and Not FWriteFault then
              begin
                FPLCWrite.Size := TransmitPacket.Size;
                FPLCWrite.FileAddr := TransmitPacket.Tag;
                FPLCWrite.LongVal[0] := TransmitPacket.Value;
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
  end; // If
end;

function TPLCWriteThread.ValidatePacket(lPacket : TPLCWritePacket) : boolean;
begin
  Result := False;
  if Assigned(lPacket) then
  begin
    if (lPacket.Size > 0) and (lPacket.Tag <> '') then
    begin
      lPacket.TransactionPhase := 1;
      Result := True;
    end; // If
  end
  else
  begin
    Result := False;
  end; // If
end; // If

procedure TPLCWriteThread.Execute;
var
  OKToProcess : LongInt;
begin
  repeat
    if Not Terminated then
    begin
      OKToProcess := WaitForSingleObject(UsingWriteStack,1000);
      if (OKToProcess = Wait_Object_0) then
      begin
        DoTransmitPacket;
        ReleaseSemaphore(UsingWriteStack,1,Nil);
      end; // If
      Sleep(1);
    end; // If
  until Terminated;
end; // TPLCWriteThread.Execute

Constructor TPLCReadPacket.Create;
begin
  inherited Create;
  Size := 0;
  Tag := '';
  Value := 0;
  TransactionPhase := -1;
end; // TPCReadPacket.Create

Constructor TPLCWritePacket.Create;
begin
  inherited Create;
  Size := 0;
  Tag := '';
  Value := 0;
  TransactionPhase := -1;
  TransmitAttempts := 0;
end; // TPLCWritePacket

function TCompactLogixPLC.GetEnabled : boolean;
begin
  if Assigned(FPLCReadThread) and Assigned(FPLCWriteThread) then
    result := FPLCReadThread.ReadEnabled and FPLCWriteThread.WriteEnabled
  else
    result := False;
end; // TCompactLogixPLC.GetEnabled

procedure TCompactLogixPLC.SetEnabled(Value : Boolean);
begin
  FEnabled := Value;
  if Assigned(FPLCReadThread) and Assigned(FPLCWriteThread) then
  begin
    FPLCReadThread.ReadEnabled := FEnabled;
    FPLCWriteThread.WriteEnabled := FEnabled;
    if FThreadStarted then
      FPLCWatchDogThread.WatchDogEnabled := FEnabled and FWatchDogActive;
    if FEnabled then
    begin
      ResetPLCError;
      SetReadInterval(FReadInterval);
    end; // If
    if FEnabled and Not FThreadStarted then
    begin
      FPLCWriteThread.Resume;
      FPLCReadThread.Resume;
      FPLCWatchDogThread.Resume;
      FThreadStarted := True;
    end; // If
  end; // If
end; // TCompactLogixPLC.SetEnabled

function TCompactLogixPLC.ValidIPAddress(Value : ShortString) : Boolean;
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
end; // TCompactLogixPLC.SetPLCIPAddress

procedure TPLCReadThread.PLCReadErrorEvent(Sender :TObject; nErrorCode : TIntErrorCode);
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
    FPLCRead.Size := FPLCReadSize;
    FPLCRead.FileAddr := FPLCReadTag;
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
end; // TCompactLogixPLC.PLCReadErrorEvent

procedure TPLCWriteThread.PLCWriteErrorEvent(Sender : TObject; nErrorCode : TIntErrorCode);
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

function TPLCWriteThread.WriteToPLC(vTag : ShortString; vSize : Integer; vValue : Integer) : Boolean;
var
  lPacket : TPLCWritePacket;
begin
  Result := False;
  if Not FWriteFault then
  begin
    lPacket := TPLCWritePacket.Create;
    with lPacket do
    begin
      Size := vSize;
      Tag := vTag;
      Value := vValue;
      TransactionPhase := 0;
    end; // With
    Result := AddToWriteStack(lPacket);
  end; // If
end; // TCompactLogixPLC.WriteWordToPLC

procedure TCompactLogixPLC.SetWatchDogState(Value : boolean);
begin
  FWatchDogActive := Value;
  if Assigned(FPLCWatchDogThread) then
  begin
    FPLCWatchDogThread.SleepInterval := FWatchDogInterval;
    FPLCWatchDogThread.WatchDogEnabled := FWatchDogActive;
  end; // If
end; // TCompactLogixPLC.SetWatchDogState

procedure TCompactLogixPLC.SetWatchDogInterval(Value : longint);
begin
  FWatchDogInterval := Value;
  if Assigned(FPLCWatchDogThread) then
    FPLCWatchDogThread.SleepInterval := FWatchDogInterval;
end; // TCompactLogixPLC.SetWatchDogInterval

function TCompactLogixPLC.ProcessorMode(ProcessorMode : Integer) : ShortString;
begin
  Case ProcessorMode of
    6 :  Result := 'PLC Processor Mode is RUN MODE.';
    7 :  Result := 'PLC Processor Mode is PROGRAM MODE.';
  end; // Case
end; // TCompactLogixPLC.ProcessorMode

function TPLCWriteThread.AddToWriteStack(lPacket : TPLCWritePacket) : Boolean;
var
  OkToAdd : Boolean;
begin
  OKToAdd := False;
  if Assigned(FWriteStack) then
  begin
    OKToAdd := WaitForSingleObject(UsingWriteStack,1000) = Wait_Object_0;
    if OKToAdd then
    begin
      FWriteStack.AddObject(IntToStr(FWriteStack.Count + 1),lPacket);
      ReleaseSemaphore(UsingWriteStack,1,Nil);
    end
    else
    begin
      lPacket.Free;
    end; // If
  end; // If
  Result := OKToAdd;
end; // TPLCWriteThread.AddToWriteStack

procedure TCompactLogixPLC.SetReadInterval(Value : longInt);
begin
  FReadInterval := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.SleepTime := FReadInterval;
end; // TCompactLogixPLC.SetReadInterval

function TCompactLogixPLC.GetReadInterval : LongInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.SleepTime
  else
    Result := FReadInterval;
end; // TCompactLogixPLC.GetReadInterval

procedure TCompactLogixPLC.LoadPLCConfiguration(lFileName : String);
var
  INIFile : TStRegINI;
  i : integer;
  lAnalogInputModule : TAnalogInputModule;
  lAnalogOutputModule : TAnalogOutputModule;
  lDigitalInputModule : TDigitalInputModule;
  lDigitalOutputModule : TDigitalOutputModule;
  lRelayedDigitalOutputModule : TRelayedDigitalOutputModule;
  lDriveModule : TDriveModule;
  lProcessorModule : TProcessorModule;
  lAnalogOutputModule_IV : TAnalogOutputModule_IV;
begin
  FConfigurationFile := lFileName;
  if FileExists(FConfigurationFile) then
  begin
    if FModuleCount > 0 then
    begin
      SetEnabled(False);
      for i := 0 to (FModuleCount - 1) do
      begin
        if Assigned(FPLCReadThread) then
          FPLCReadThread.Suspend;
        Modules[i].Free;
        Modules[i] := Nil;
        if Assigned(FPLCReadThread) then
          FPLCReadThread.Resume;
      end; // For i
    end; // If
    INIFile := TStRegINI.Create(FConfigurationFile,True);
    with INIFile do
    begin
      CurSubKey := 'PLC';
      SetReadIPAddress(ReadString('ReadIPAddress','0.0.0.0'));
      SetWriteIPAddress(ReadString('WriteIPAddress','0.0.0.0'));
      SetWatchDogTag(ReadString('WatchDogTag','vWatchDogReset?'));
      SetReadAddress(ReadString('ReadTag','PC_Data.Data[0]'));
      SetReadSize(ReadInteger('ReadSize',1));
      SetReadInterval(ReadInteger('ReadInterval',100));
      SetWatchDogInterval(ReadInteger('WatchdogInterval',1000));
      SetReadFaultTollerance(ReadInteger('ReadFaultTollerance',0));
      SetWriteFaultTollerance(ReadInteger('WriteFaultTollerance',0));
      SetEthernetTimeOut(ReadInteger('EthernetTimeOut',1000));
      SetModuleCount(ReadInteger('ModulesInstalled',0));
      if FModuleCount > 0 then
      begin
        FModulesPresent := True;
        for i := 0 to (FModuleCount - 1) do
        begin
          CurSubKey := format('Module%d',[i]);
          ModuleType[i] := ReadInteger('ModuleType',0);
          case ModuleType[i] of
            0 : begin // Analog Input Module
                  lAnalogInputModule := TAnalogInputModule.Create;
                  lAnalogInputModule.ModuleType := ReadInteger('ModuleType',0);
                  lAnalogInputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                  lAnalogInputModule.ModuleString := ReadString('ModuleString','');
                  lAnalogInputModule.ModuleArrayElements[0] := ReadInteger('StartElement',0);
                  lAnalogInputModule.ModuleArrayElements[1] := ReadInteger('EndElement',0);
                  Modules[i] := lAnalogInputModule;
                end; // 0
            1 : begin // Analog Output Module
                  lAnalogOutputModule := TAnalogOutputModule.Create;
                  lAnalogOutputModule.ModuleType := ReadInteger('ModuleType',0);
                  lAnalogOutputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                  lAnalogOutputModule.ModuleString := ReadString('ModuleString','');
                  lAnalogOutputModule.ModuleArrayElements[0] := ReadInteger('StartElement',0);
                  lAnalogOutputModule.ModuleArrayElements[1] := ReadInteger('EndElement',0);
                  Modules[i] := lAnalogOutputModule;
                end; // 1
            2 : begin // Digital Input Module
                  lDigitalInputModule := TDigitalInputModule.Create;
                  lDigitalInputModule.ModuleType := ReadInteger('ModuleType',0);
                  lDigitalInputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                  lDigitalInputModule.ModuleString := ReadString('ModuleString','');
                  lDigitalInputModule.ModuleArrayElements[0] := ReadInteger('StartElement',0);
                  lDigitalInputModule.ModuleArrayElements[1] := ReadInteger('EndElement',0);
                  Modules[i] := lDigitalInputModule;
                end; // 2
            3 : begin // Digital Output Module
                  lDigitalOutputModule := TDigitalOutputModule.Create;
                  lDigitalOutputModule.ModuleType := ReadInteger('ModuleType',0);
                  lDigitalOutputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                  lDigitalOutputModule.ModuleString := ReadString('ModuleString','');
                  lDigitalOutputModule.ModuleArrayElements[0] := ReadInteger('StartElement',0);
                  lDigitalOutputModule.ModuleArrayElements[1] := ReadInteger('EndElement',0);
                  Modules[i] := lDigitalOutputModule;
                end; // 3
            4 : begin // Relayed Digital Output Module
                  lRelayedDigitalOutputModule := TRelayedDigitalOutputModule.Create;
                  lRelayedDigitalOutputModule.ModuleType := ReadInteger('ModuleType',0);
                  lRelayedDigitalOutputModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                  lRelayedDigitalOutputModule.ModuleString := ReadString('ModuleString','');
                  lRelayedDigitalOutputModule.ModuleArrayElements[0] := ReadInteger('StartElement',0);
                  lRelayedDigitalOutputModule.ModuleArrayElements[1] := ReadInteger('EndElement',0);
                  Modules[i] := lRelayedDigitalOutputModule;
                end; // 4
            5 : begin // Drive Module
                  lDriveModule := TDriveModule.Create;
                  lDriveModule.ModuleType := ReadInteger('ModuleType',0);
                  lDriveModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                  lDriveModule.ModuleString := ReadString('ModuleString','');
                  lDriveModule.ModuleArrayElements[0] := ReadInteger('StartElement',0);
                  lDriveModule.ModuleArrayElements[1] := ReadInteger('EndElement',0);
                  Modules[i] := lDriveModule;
                end; // 5
            6 : begin // Processor Module
                  lProcessorModule := TProcessorModule.Create;
                  lProcessorModule.ModuleType := ReadInteger('ModuleType',0);
                  lProcessorModule.ModuleNumber := ReadInteger('ModuleNumber',0);
                  lProcessorModule.ModuleString := ReadString('ModuleString','');
                  lProcessorModule.ModuleArrayElements[0] := ReadInteger('StartElement',0);
                  lProcessorModule.ModuleArrayElements[1] := ReadInteger('EndElement',0);
                  Modules[i] := lProcessorModule;
                end; // 6
            7 : begin // Analog Output Voltage/Current Module
                  lAnalogOutputModule_IV := TAnalogOutputModule_IV.Create;
                  lAnalogOutputModule_IV.ModuleType := ReadInteger('ModuleType',0);
                  lAnalogOutputModule_IV.ModuleNumber := ReadInteger('ModuleNumber',0);
                  lAnalogOutputModule_IV.ModuleString := ReadString('ModuleString','');
                  lAnalogOutputModule_IV.ModuleArrayElements[0] := ReadInteger('StartElement',0);
                  lAnalogOutputModule_IV.ModuleArrayElements[1] := ReadInteger('EndElement',0);
                  Modules[i] := lAnalogOutputModule_IV;
                end; // 7
          end; // Case
        end; // For i
        if Assigned(FPLCReadThread) then
        begin
          FPLCReadThread.ModuleCount := FModuleCount;
          FPLCReadThread.ModuleTypes := ModuleType;
          FPLCReadThread.Modules := Modules;
        end; // If
      end; // If
//      CheckModuleConfigutaion;
      CurSubKey := 'PLC';
      FWatchDogHi := ReadString('WatchDogHi','');
      FWatchDogLo := ReadString('WatchDogLo','');
      SetEnabled(ReadBoolean('Enabled',False));
      SetWatchDogTimeOut(ReadInteger('WatchdogTimeOut',4000));
    end; // With
    INIFile.Free;
  end
  else
  begin
    FConfigurationFile := '';
  end; // If
end; // TCompactLogixPLC.LoadPLCConfiguration

procedure TPLCReadThread.PopulateModules;
var
  i : Integer;
  j : Integer;
  k : Integer;
  lAnalogInputModule : TAnalogInputModule;
  lAnalogOutputModule : TAnalogOutputModule;
  lDigitalInputModule : TDigitalInputModule;
  lDigitalOutputModule : TDigitalOutputModule;
  lRelayedDigitalOutputModule : TRelayedDigitalOutputModule;
  lDriveModule : TDriveModule;
  lProcessorModule : TProcessorModule;
  lAnalogOutputModule_IV : TAnalogOutputModule_IV;
  lProcessorMode : Single;
  lProcessorSerialNumber : Extended;
  lKeySwitchPosition : Extended;
  lChannel : Integer;
  lTempInt : LongInt;
begin
  if Not Terminated  and FModulesLoaded then
  begin
    for i := 0 to (FModuleCount - 1) do
    begin
      if Terminated then
        Exit;
      lProcessorMode := 0;
      lProcessorSerialNumber := 0;
      lKeySwitchPosition := 0;
      lChannel := 0;
      case FModuleType[i] of
        0 : begin // Analog Input Module
              lAnalogInputModule := Modules[i] as TAnalogInputModule;
              with lAnalogInputModule do
              begin
                for j := ModuleArrayElements[0] to (ModuleArrayElements[1] - 1) do
                begin
                  InputData[j - ModuleArrayElements[0]] := FPLCRead.LongVal[j];
                end; // For j
                for k := 0 to 31 do
                  Fault[k] := (FPLCRead.LongVal[ModuleArrayElements[1]] SHR k and 1) = 1;
                for k := 0 to 31 do
                begin
                  if k in [0,8,16,24] then
                  begin
                    OverRange[lChannel] := Fault[k];
                    UnderRange[lChannel] := Fault[k + 1];
                    HighAlarm[lChannel] := Fault[k + 2];
                    LowAlarm[lChannel] := Fault[k + 3];
                    inc(lChannel);
                  end; // If
                end; // For k
              end; // With
            end; // 0
        1 : begin // Analog Output Module
              lAnalogOutputModule := Modules[i] as TAnalogOutputModule;
              with lAnalogOutputModule do
              begin
                for j := ModuleArrayElements[0] to (ModuleArrayElements[1] - 1) do
                begin
                  OutputData[j - ModuleArrayElements[0]] := FPLCRead.LongVal[j];
                end; // For j
                for k := 0 to 31 do
                  Fault[k] := (FPLCRead.LongVal[ModuleArrayElements[1]] SHR k and 1) = 1;
                for k := 0 to 31 do
                begin
                  if k in [0,8,16,24] then
                  begin
                    OverRange[lChannel] := Fault[k];
                    UnderRange[lChannel] := Fault[k + 1];
                    HighAlarm[lChannel] := Fault[k + 2];
                    LowAlarm[lChannel] := Fault[k + 3];
                    inc(lChannel);
                  end; // If
                end; // For k
              end; // With
            end; // 1
        2 : begin // Digital Input Module
              lDigitalInputModule := Modules[i] as TDigitalInputModule;
              with lDigitalInputModule do
              begin
                for k := 0 to 15 do
                  InputData[k] := (FPLCRead.LongVal[ModuleArrayElements[0]] SHR k and 1) = 1;
                for k := 0 to 31 do
                  Fault[k] := (FPLCRead.LongVal[ModuleArrayElements[1]] SHR k and 1) = 1;
              end; // With
            end; // 2
        3 : begin // Digital Output Module
              lDigitalOutputModule := Modules[i] as TDigitalOutputModule;
              with lDigitalOutputModule do
              begin
                for k := 0 to 15 do
                  OutputData[k] := (FPLCRead.LongVal[ModuleArrayElements[0]] SHR k and 1) = 1;
                for k := 0 to 31 do
                  Fault[k] := (FPLCRead.LongVal[ModuleArrayElements[1]] SHR k and 1) = 1;
              end; // With
            end; // 3
        4 : begin // Relayed Digital Output Module
              lRelayedDigitalOutputModule := Modules[i] as TRelayedDigitalOutputModule;
              with lRelayedDigitalOutputModule do
              begin
                for k := 0 to 7 do
                  RelayedOutputData[k] := (FPLCRead.LongVal[ModuleArrayElements[0]] SHR k and 1) = 1;
                for k := 0 to 31 do
                  Fault[k] := (FPLCRead.LongVal[ModuleArrayElements[1]] SHR k and 1) = 1;
              end; // With
            end; // 4
        5 : begin // Drive Module
              lDriveModule := Modules[i] as TDriveModule;
              with lDriveModule do
              begin
                for j := 0 to 15 do
                begin
                  DriveStatus[j] := (FPLCRead.LongVal[ModuleArrayElements[0]] SHR j and 1) = 1;
                  DriveLogicResult[j] := (FPLCRead.LongVal[(ModuleArrayElements[0] + 2)] SHR j and 1) = 1;
                end; // For j
                OutputFrequency := FPLCRead.LongVal[(ModuleArrayElements[0] + 1)];
                CommandedFrequency := FPLCRead.LongVal[(ModuleArrayElements[0] + 3)];
                ModuleEntryStatus := FPLCRead.LongVal[(ModuleArrayElements[0] + 4)];
              end; // With
            end; //
        6 : begin // ProcessorModule
              lProcessorModule := Modules[i] as TProcessorModule;
              with lProcessorModule do
              begin
                for j := 0 to 15 do
                  ProcessorStatus[j] := (FPLCRead.LongVal[ModuleArrayElements[0]] SHR j and 1) = 1;
                MinorFault := FPLCRead.LongVal[(ModuleArrayElements[0] + 1)];
                PowerUPOK := (MinorFault SHR 1 and 1) = 0;
                IO_OK := (MinorFault SHR 3 and 1) = 0;
                ProgramOK := (MinorFault SHR 4 and 1) = 0;
                PLC_Internal_WatchDogOK := (MinorFault SHR 6 and 1) = 0;
                SerialPortOK := (MinorFault SHR 9 and 1) = 0;
                NonvolatileMemoryOK := (MinorFault SHR 7 and 1) = 0;
                BatteryOk := (MinorFault SHR 10 and 1) = 0;
                for j := 0 to 32 do
                  if (FPLCRead.LongVal[ModuleArrayElements[0] + 2] SHR j and 1) = 1 then
                    lProcessorSerialNumber := lProcessorSerialNumber + Power(2,j);
                for j := 4 to 7 do
                begin
                  if (FPLCRead.LongVal[ModuleArrayElements[0]] SHR j and 1) = 1 then
                    lProcessorMode := lProcessorMode + Power(2,(j - 4));
                end; // For j
                ProcessorMode := Trunc(lProcessorMode);
                for j := 12 to 13 do
                begin
                  if (FPLCRead.LongVal[ModuleArrayElements[0]] SHR j and 1) = 1 then
                    lKeySwitchPosition := lKeySwitchPosition + Power(2,(j - 12));
                end; // For j
                for j := 0 to 1 do
                begin
                  for k := 0 to 31 do
                  begin
                    if j = 0 then
  {$ifdef ApolloPCR95644}
                      Request_Bits_Status[j,k] := (FPLCRead.LongVal[ModuleArrayElements[1] - 1] SHR k and 1) = 1
  {$else}
                      Request_Bits_Status[j,k] := (FPLCRead.LongVal[ModuleArrayElements[1] - 2] SHR k and 1) = 1
  {$endif}
                    else
  {$ifdef ApolloPCR95644}
                      Request_Bits_Status[j,k] := (FPLCRead.LongVal[ModuleArrayElements[1]] SHR k and 1) = 1;
  {$else}
                      Request_Bits_Status[j,k] := (FPLCRead.LongVal[ModuleArrayElements[1] - 1] SHR k and 1) = 1;
  {$endif}
                  end; // For k
                end; // For j
                ForcesInstalled := (FPLCRead.LongVal[ModuleArrayElements[1]] SHR 0 and 1) = 1;
                ForcesEnabled := (FPLCRead.LongVal[ModuleArrayElements[1]] SHR 1 and 1) = 1;
                KeySwitchPosition := Trunc(lKeySwitchPosition);
                ProcessorSerialNumber := lProcessorSerialNumber;
              end; // With
            end; // 6
        7 : begin // Analog Output Voltage/Current Module
              lAnalogOutputModule_IV := Modules[i] as TAnalogOutputModule_IV;
              with lAnalogOutputModule_IV do
              begin
                for j := 0 to 1 do
                begin
                  lTempINt := 0;
                  for k := 8 to 11 do
                  begin
                    if ((FPLCRead.LongVal[ModuleArrayElements[0] + j] SHR k and 1) = 1) then
                      lTempInt := lTempInt + (2*(k - 8));
                  end; // If
                  OutputSetting[j] := lTempInt;
                end; // For j
                lChannel := 0;
                for k := 12 to 15 do
                begin
                  if k in [12,14] then
                    OverRange[lChannel] := ((FPLCRead.LongVal[ModuleArrayElements[0] + 2] SHR k and 1) = 1);
                  if k in [13,15] then
                  begin
                    OverRange[lChannel] := ((FPLCRead.LongVal[ModuleArrayElements[0] + 2] SHR k and 1) = 1);
                    Inc(lChannel);
                  end; // If
                end; // For k
                lChannel := 0;
                for j := (ModuleArrayElements[0] + 3) to (ModuleArrayElements[0] + 4) do
                begin
                  OutputData[lChannel] := FPLCRead.LongVal[j];
                  Inc(lChannel);
                end; // For j
                ModuleEntryStatus := FPLCRead.LongVal[ModuleArrayElements[0] + 5];
                for k := 0 to 31 do
                  Fault[k] := (FPLCRead.LongVal[ModuleArrayElements[1]] SHR k and 1) = 1;
              end; // With
            end; // 7
      end; // Case
    end; // For i
    if Not Terminated then
      Synchronize(DoPassModuleData);
  end; // If
end; // TCompactLogixPLC.PopulateModules

procedure TCompactLogixPLC.SavePLCConfiguration;
var
  INIFile : TStRegINI;
  i : integer;
  lAnalogInputModule : TAnalogInputModule;
  lAnalogOutputModule : TAnalogOutputModule;
  lDigitalInputModule : TDigitalInputModule;
  lDigitalOutputModule : TDigitalOutputModule;
  lRelayedDigitalOutputModule : TRelayedDigitalOutputModule;
  lDriveModule : TDriveModule;
  lProcessorModule : TProcessorModule;
  lAnalogOutputModule_IV : TAnalogOutputModule_IV;
begin
  if FileExists(FConfigurationFile) then
  begin
    if Assigned(FPLCReadThread) then
    begin
      Modules := FPLCReadThread.Modules;
      ModuleType := FPLCReadThread.ModuleTypes;
      FModuleCount := FPLCReadThread.ModuleCount;
      INIFile := TStRegINI.Create(FConfigurationFile,True);
      with INIFile do
      begin
        CurSubKey := 'PLC';
        WriteString('ReadIPAddress',GetReadIPAddress);
        WriteString('WriteIPAddress',GetWriteIPAddress);
        WriteString('ReadTag',FReadAddress);
        WriteInteger('ReadSize',FReadSize);
        WriteInteger('ReadInterval',FReadInterval);
        FWatchdogInterval := ReadInteger('WatchdogInterval',1000);
        WriteInteger('ReadFaultTollerance',GetReadFaultTollerance);
        WriteInteger('WriteFaultTollerance',GetWriteFaultTollerance);
        WriteInteger('EthernetTimeOut',GetEthernetTimeOut);
        WriteInteger('ModulesInstalled',FModuleCount);
        if FModuleCount > 0 then
        begin
          for i := 0 to MaximumModules{(FModuleCount - 1)} do
          begin
            if (i in [0..(FModuleCount - 1)]) then
            begin
              CurSubKey := format('Module%d',[i]);
              WriteInteger('ModuleType',ModuleType[i]);
              case ModuleType[i] of
                0 : begin // Analog Input Module
                      lAnalogInputModule := Modules[i] as TAnalogInputModule;
                      WriteInteger('ModuleType',lAnalogInputModule.ModuleType);
                      WriteInteger('ModuleNumber',lAnalogInputModule.ModuleNumber);
                      WriteString('ModuleString',lAnalogInputModule.ModuleString);
                      WriteInteger('StartElement',lAnalogInputModule.ModuleArrayElements[0]);
                      WriteInteger('EndElement',lAnalogInputModule.ModuleArrayElements[1]);
                    end; // 0
                1 : begin // Analog Output Module
                      lAnalogOutputModule := Modules[i] as TAnalogOutputModule;
                      WriteInteger('ModuleType',lAnalogOutputModule.ModuleType);
                      WriteInteger('ModuleNumber',lAnalogOutputModule.ModuleNumber);
                      WriteString('ModuleString',lAnalogOutputModule.ModuleString);
                      WriteInteger('StartElement',lAnalogOutputModule.ModuleArrayElements[0]);
                      WriteInteger('EndElement',lAnalogOutputModule.ModuleArrayElements[1]);
                    end; // 1
                2 : begin // Digital Input Module
                      lDigitalInputModule := Modules[i] as TDigitalInputModule;
                      WriteInteger('ModuleType',lDigitalInputModule.ModuleType);
                      WriteInteger('ModuleNumber',lDigitalInputModule.ModuleNumber);
                      WriteString('ModuleString',lDigitalInputModule.ModuleString);
                      WriteInteger('StartElement',lDigitalInputModule.ModuleArrayElements[0]);
                      WriteInteger('EndElement',lDigitalInputModule.ModuleArrayElements[1]);
                    end; // 2
                3 : begin // Digital Output Module
                      lDigitalOutputModule := Modules[i] as TDigitalOutputModule;
                      WriteInteger('ModuleType',lDigitalOutputModule.ModuleType);
                      WriteInteger('ModuleNumber',lDigitalOutputModule.ModuleNumber);
                      WriteString('ModuleString',lDigitalOutputModule.ModuleString);
                      WriteInteger('StartElement',lDigitalOutputModule.ModuleArrayElements[0]);
                      WriteInteger('EndElement',lDigitalOutputModule.ModuleArrayElements[1]);
                    end; // 3
                4 : begin // Relayed Digital Output Module
                      lRelayedDigitalOutputModule := Modules[i] as TRelayedDigitalOutputModule;
                      WriteInteger('ModuleType',lRelayedDigitalOutputModule.ModuleType);
                      WriteInteger('ModuleNumber',lRelayedDigitalOutputModule.ModuleNumber);
                      WriteString('ModuleString',lRelayedDigitalOutputModule.ModuleString);
                      WriteInteger('StartElement',lRelayedDigitalOutputModule.ModuleArrayElements[0]);
                      WriteInteger('EndElement',lRelayedDigitalOutputModule.ModuleArrayElements[1]);
                    end; // 4
                5 : begin // Drive Module
                      lDriveModule := Modules[i] as TDriveModule;
                      WriteInteger('ModuleType',lDriveModule.ModuleType);
                      WriteInteger('ModuleNumber',lDriveModule.ModuleNumber);
                      WriteString('ModuleString',lDriveModule.ModuleString);
                      WriteInteger('StartElement',lDriveModule.ModuleArrayElements[0]);
                      WriteInteger('EndElement',lDriveModule.ModuleArrayElements[1]);
                    end; // 5
                6 : begin // Processor Module
                      lProcessorModule := Modules[i] as TProcessorModule;
                      WriteInteger('ModuleType',lProcessorModule.ModuleType);
                      WriteInteger('ModuleNumber',lProcessorModule.ModuleNumber);
                      WriteString('ModuleString',lProcessorModule.ModuleString);
                      WriteInteger('StartElement',lProcessorModule.ModuleArrayElements[0]);
                      WriteInteger('EndElement',lProcessorModule.ModuleArrayElements[1]);
                    end; // 6
                7 : begin  // Analog Output Voltage/Current Module
                      lAnalogOutputModule_IV := Modules[i] as TAnalogOutputModule_IV;
                      WriteInteger('ModuleType',lAnalogOutputModule_IV.ModuleType);
                      WriteInteger('ModuleNumber',lAnalogOutputModule_IV.ModuleNumber);
                      WriteString('ModuleString',lAnalogOutputModule_IV.ModuleString);
                      WriteInteger('StartElement',lAnalogOutputModule_IV.ModuleArrayElements[0]);
                      WriteInteger('EndElement',lAnalogOutputModule_IV.ModuleArrayElements[1]);
                    end; // 7
              end; // Case
              Modules[i].Free;
              Modules[i] := nil;
            end
            else
            begin
              if INIFile.KeyExists(format('Module%d',[i])) then
                INIFile.DeleteKey(format('Module%d',[i]),True);
            end; // If
          end; // For i
        end; // If
      end; // With
      INIFile.Free;
    end; // If
  end; // If
end; // TCompactLogixPLC.SavePLCConfiguration

function TCompactLogixPLC.GetErrorMessage(nErrorCode : TIntErrorCode) : String;
var
  msg : String;
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
end; // TCompactLogixPLC.GetErrorMessage

function TCompactLogixPLC.GetLastReadError : String;
begin
  if Assigned(FPLCReadThread) then
    Result := GetErrorMessage(FPLCReadThread.LastError);
end; // TCompactLogixPLC.GetLastReadError

function TCompactLogixPLC.GetLastWriteError : String;
begin
  if Assigned(FPLCWriteThread) then
    Result := GetErrorMessage(FPLCWriteThread.LastError);
end; // TCompactLogixPLC.GetLastWriteError

procedure TCompactLogixPLC.ResetPLCError;
begin
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteFault := False;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadFault := False;
end; // TCompactLogixPLC.ResetPLCError

procedure TCompactLogixPLC.SetReadAddress(Value : ShortString);
begin
  FReadAddress := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadTag := FReadAddress;
end; // TCompactLogixPLC

procedure TCompactLogixPLC.SetReadSize(Value : Integer);
begin
  FReadSize := Value;
  if Assigned(FPLCReadThread) then
  begin
    FPLCReadThread.ReadSize := FReadSize;
  end; // IF
end; // TCompactLogixPLC.SetReadSize

function TCompactLogixPLC.KeySwitchPosition(KeySwitchPosition : Integer) : ShortString;
begin
  case KeySwitchPosition of
    1 : Result := 'Keyswitch is in RUN mode.';
    2 : Result := 'Keyswitch is in PROGRAM mode.';
    3 : Result := 'Keyswitch is in REMOTE mode.';
  end; // Case
end; // TCompactLogixPLC.KeySwitchPosition

procedure TCompactLogixPLC.SetVersion(Value : ShortString);
begin
  // Do nothing...
end; // TCompactLogixPLC.SetVersion

procedure TCompactLogixPLC.SetPLCIPAddress(Value : ShortString);
begin
  FReadIPAddress := Value;
  FWriteIPAddress := Value;
  if ValidIPAddress(FReadIPAddress) then
  begin
    if Assigned(FPLCReadThread) then
      FPLCReadThread.ReadIPAddress := Value;
    if Assigned(FPLCWriteThread) then
      FPLCWriteThread.WriteIPAddress := Value;
  end
  else
  begin
    FReadIPAddress := '0.0.0.0';
    FWriteIPAddress := '0.0.0.0';
  end; // If
end; // TCompactLogixPLC.SetPLCIPAddress

function TCompactLogixPLC.GetPLCIPAddress : ShortString;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadIPAddress
  else
    Result := FReadIPAddress;
end; // TCompactLogixPLC.GetPLCIPAddress

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

function TCompactLogixPLC.GetReadAdapterNum : LongInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadAdapterNum
  else
    Result := FReadAdapterNo;
end; // TCompactLogixPLC.GetReadAdapterNum

procedure TCompactLogixPLC.SetReadAdapterNum(Value : LongInt);
begin
  FReadAdapterNo := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadAdapterNum := FReadAdapterNo;
end; // TCompactLogixPLC.SetReadAdapterNum

function TCompactLogixPLC.GetWriteAdapterNum : LongInt;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteAdapterNum
  else
    Result := FWriteAdapterNo;
end; // TCompactLogixPLC.GetWriteAdapterNum

procedure TCompactLogixPLC.SetWriteAdapterNum(Value : LongInt);
begin
  FWriteAdapterNo := Value;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteAdapterNum := FWriteAdapterNo;
end; // TCompactLogixPLC.SetWriteAdapterNum

procedure TPLCReadThread.AddToReadStack(lPacket : TPLCReadPacket);
var
  OKToAdd : LongInt;
begin
  if Assigned(FReadStack) then
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
end; // TPLCReadThread.AddToReadStack

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
          Tag := ReadPacket.Tag;
          TransactionPhase := ReadPacket.TransactionPhase;
        end; // With
        with FPLCRead do
        begin
          Size := ReadPacket.Size;
          FileAddr := ReadPacket.Tag;
          if Not Terminated and Not FReadFault then
            Trigger;
        end; // With
        ReadPacket := Nil;
      end; // If
    end; // If
  end; // If
end; // TPLCReadThread.DoReadPacket

procedure TPLCReadThread.DoReturnValueFromPLC;
begin
  if Assigned(PLCMonitor.OnValueReadFromPLC) then
    PLCMonitor.OnValueReadFromPLC(Self,FReadPacketRec);
end; // TPLCReadThread.DoReturnValueFromPLC

procedure TCompactLogixPLC.ReadFromPLC(vTag : ShortString; vSize : LongInt);
begin
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadFromPLC(vTag,vSize);
end; // TCompactLogixPLC.ReadFromPLC

procedure TPLCReadThread.ReadFromPLC(vTag : ShortString; vSize : LongInt);
var
  PLCReadPacket : TPLCReadPacket;
begin
  PLCReadPacket := TPLCReadPacket.Create;
  with PLCReadPacket do
  begin
    Size := vSize;
    Tag := vTag;
    TransactionPhase := 0;
  end; // With
  AddToReadStack(PLCReadPacket);
end; // TPLCReadThread.ReadFromPLC

procedure TPLCReadThread.PLCReadReadDone(Sender : TObject);
var
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
        Size   := FPLCRead.Size;
        Tag    := FPLCRead.FileAddr;
        Value  := FPLCRead.LongVal[0];
        TransactionPhase := ReadPacket.TransactionPhase;
      end; // With
      ReadPacket.Free;
      ReadPacket := Nil;
      FReadStack.Delete(0);
      FProcessReadPacket := False;
      Synchronize(DoReturnValueFromPLC);
      FPLCRead.Size := FPLCReadSize;
      FPLCRead.FileAddr := FPLCReadTag;
    end; // If
  end
end; // TPLCReadThread.PLCReadReadDone

function TCompactLogixPLC.GetReadPacketsInQue : LongInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadQue
  else
    Result := 0;
end; // TCompactLogixPLC.GetReadPacketsInQue

function TCompactLogixPLC.GetWritePacketsInQue : LongInt;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteQue
  else
    Result := 0;
end; // TCompactLogix.GetWritePacketsInQue

procedure TCompactLogixPLC.SetWatchDogTimeOut(Value : LongInt);
begin
  FWatchDogTimeOut := Value;
  if Assigned(FPLCWriteThread) then
  begin
    if (FWatchDogHi <> '') and (FWatchDogLo <> '') then
    begin
      FPLCWriteThread.WriteToPLC(FWatchDogHi,1,FWatchDogTimeOut);
      FPLCWriteThread.WriteToPLC(FWatchDogLo,1,FWatchDogTimeOut);
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
end; // TCompactLogixPLC.SetWatchDogTimeOut

function TCompactLogixPLC.CheckModuleConfigutaion : Boolean;
var
  i : LongInt;
  ConfigError : Boolean;
  lProcessorModule : TProcessorModule;
  lDigitalInputModule : TDigitalInputModule;
  lDigitalOutputModule : TDigitalOutputModule;
  lAnalogInputModule : TAnalogInputModule;
  lAnalogOutputModule : TAnalogOutputModule;
  lRelayedDigitalOutputModule : TRelayedDigitalOutputModule;
  lDriveModule : TDriveModule;
  StrErrorMessages : String;
begin
  Result := True;
  for i := 0 to (FModuleCount - 1) do
  begin
    StrErrorMessages := '';
    case ModuleType[i] of
      0 : begin // Analog Input Module
            lAnalogInputModule := Modules[i] as TAnalogInputModule;
            with lAnalogInputModule do
            begin
              ConfigError := ((ModuleArrayElements[1] - ModuleArrayElements[0]) > 9) or ((ModuleArrayElements[1] - ModuleArrayElements[0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Analog Input Module]Invalid range defined for Data Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 0
      1 : begin // Analog Output Module
            lAnalogOutputModule := Modules[i] as TAnalogOutputModule;
            with lAnalogOutputModule do
            begin
              ConfigError := ((ModuleArrayElements[1] - ModuleArrayElements[0]) > 9) or ((ModuleArrayElements[1] - ModuleArrayElements[0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Analog Output Module]Invalid range defined for Data Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 1
      2 : begin // Digital Input Module
            lDigitalInputModule := Modules[i] as TDigitalInputModule;
            with lDigitalInputModule do
            begin
              ConfigError := ((ModuleArrayElements[1] - ModuleArrayElements[0]) > 2) or ((ModuleArrayElements[1] - ModuleArrayElements[0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Digital Input Module]Invalid range defined for Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 2
      3 : begin // Digital Output Module
            lDigitalOutputModule := Modules[i] as TDigitalOutputModule;
            with lDigitalOutputModule do
            begin
              ConfigError := ((ModuleArrayElements[1] - ModuleArrayElements[0]) > 2) or ((ModuleArrayElements[1] - ModuleArrayElements[0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Digital Output Module]Invalid range defined for Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 3
      4 : begin // Relayed Digital Output Module
            lRelayedDigitalOutputModule := Modules[i] as TRelayedDigitalOutputModule;
            with lRelayedDigitalOutputModule do
            begin
              ConfigError := ((ModuleArrayElements[1] + ModuleArrayElements[0]) > 2) or ((ModuleArrayElements[1] - ModuleArrayElements[0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Relayed Digital Output Module]Invalid range defined for Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 4
      5 : begin // Drive Module
            lDriveModule := Modules[i] as TDriveModule;
            with lDriveModule do
            begin
              ConfigError := ((ModuleArrayElements[1] - ModuleArrayElements[0]) > 5) or ((ModuleArrayElements[1] - ModuleArrayElements[0]) < 1);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Drive Module]Invalid range defined for Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 5
      6 : begin // Main Module
            lProcessorModule := Modules[i] as TProcessorModule;
            with lProcessorModule do
            begin
              ConfigError := ((ModuleArrayElements[1] - ModuleArrayElements[0]) > 6) or ((ModuleArrayElements[1] - ModuleArrayElements[0]) < 0);
              if ConfigError then
                StrErrorMessages := StrErrorMessages + format('[Module:%d Main Module]Invalid range defined for Module Words',[ModuleNumber]) + #13#10;
            end; // With
          end; // 6
    end; // Case
  end; // For i
  if (StrErrorMessages <> '') then
  begin
    Result := False;
    if Assigned(FOnConfigurationError) then
      FOnConfigurationError(Self,5,StrErrorMessages);
  end; // If
end; // TCompactLogixPLC.CheckConfigurationFile

function TPLCReadThread.GetReadFaultTol : LongInt;
begin
  Result := FreadFaultTol;
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

procedure TPLCWriteThread.PLCWriteWriteDone(Sender : TObject);
begin
  FWriteFaultCount := 0;
end; // TPLCWriteThread.PLCWriteWriteDone

function TCompactLogixPLC.GetReadFaultTollerance : LongInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.ReadFaultTollerance
  else
    Result := FReadFaultTollerance;
end; // TCompactLogixPLC.GetReadFaultTollerance

procedure TCompactLogixPLC.SetReadFaultTollerance(Value : LongInt);
begin
  FReadFaultTollerance := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.ReadFaultTollerance := FReadFaultTollerance;
end; // TCompactLogixPLC.SetReadFaultTollerance

function TCompactLogixPLC.GetWriteFaultTollerance : LongInt;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteFaultTollerance
  else
    Result := FWriteFaultTollerance;
end; // TCompactLogixPLC.GetWriteFaultTollerance

procedure TCompactLogixPLC.SetWriteFaultTollerance(Value : LongInt);
begin
  FWriteFaultTollerance := Value;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteFaultTollerance := FWriteFaultTollerance;
end; // TCompactLogixPLC.SetWriteFaultTollerance

procedure TCompactLogixPLC.SetEthernetTimeOut(Value : SmallInt);
begin
  FEthernetTimeOut := Value;
  if Assigned(FPLCReadThread) then
    FPLCReadThread.EthernetTimeOut := FEthernetTimeOut;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.EthernetTimeOut := FEthernetTimeOut;
end; // TCompactLogixPLC.SetEthernetTimeOut

function TCompactLogixPLC.GetEthernetTimeOut : SmallInt;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.EthernetTimeOut
  else
    Result := FEthernetTimeOut;
end; // TCompactLogixPLC.GetEthernetTimeOut

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

procedure TCompactLogixPLC.SetMaximumWriteAttempts(Value : LongInt);
begin
  FMaximumWriteAttempts := Value;
  if Assigned(FPLCWriteThread) then
    FPLCWriteThread.WriteAttemptsBeforeFail := FMaximumWriteAttempts
end; // TPLCMonitor.SetMaximumWriteAttempts

function TCompactLogixPLC.GetMaximumWriteAttempts : LongInt;
begin
  if Assigned(FPLCWriteThread) then
    Result := FPLCWriteThread.WriteAttemptsBeforeFail
  else
    Result := FMaximumWriteAttempts;
end; // TPLCMonitor.GetMaximumWriteAttemps

procedure TCompactLogixPLC.InputConfiguredModules(InputModules : TModuleArray);
begin
  if Assigned(FPLCReadThread) then
    FPLCReadThread.Modules := InputModules;
end; // TCompactLogixPLC.InputConfiguredModules

function TCompactLogixPLC.RetrieveConfiguredModules : TModuleArray;
begin
  if Assigned(FPLCReadThread) then
    Result := FPLCReadThread.Modules
end; // TCompactLogixPLC.RetrieveConfiguredMoudles

Initialization
UsingReadStack := CreateSemaphore(Nil,1,1,'ReadSemaphore');
UsingWriteStack := CreateSemaphore(Nil,1,1,'WriteSemaphore');
// Initialize Semaphores
ReleaseSemaphore(UsingWriteStack,1,Nil);
ReleaseSemaphore(UsingReadStack,1,Nil);

Finalization
CloseHandle(UsingReadStack);
CloseHandle(UsingWriteStack);

end.

