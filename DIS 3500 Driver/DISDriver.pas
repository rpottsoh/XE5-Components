unit DISDriver;

interface

uses
  Windows, Messages, SysUtils, Classes, extctrls, Graphics, Controls, Forms,
  Dialogs, OoMisc, AdPort, AdWnPort, IpUtils, IpSock, IpIcmp;

const
  CPreTrigSamples : array[1..16] of integer = (512,
                                               1024,
                                               1536,
                                               2048,
                                               2560,
                                               3072,
                                               3584,
                                               4096,
                                               4608,
                                               5120,
                                               5632,
                                               6144,
                                               6656,
                                               7168,
                                               7680,
                                               8192);

  C3500SampRates : array[0..10] of integer = (100,
                                              200,
                                              500,
                                              1000,
                                              2000,
                                              5000,
                                              10000,
                                              16000,
                                              20000,
                                              50000,
                                              100000);
type
     // --- used with DIS 3500 EXE-TEST-MEASUREMENT ---
  TChansToMeasure = array[1..32] of boolean;
  TChansMeasured = array[1..32] of smallint;
     // ----
     
  TDisChanDataBlock = array[0..1279999] of smallint; //-32768 to 32767 for A/D range
  TDisDataBlock = array[0..8191] of smallint;
  TResponseBlock = array[0..16383] of byte;
  TResponse = (rtNone, rtByte, rtWord, rtString);
  TMeasuredData = (mdRaw,mdPosCal,mdNegCal);
  TMemClearStatus = (mcComplete,
                     mcNotExecuted,
                     mcBusy);
  TTestTime = (ttPreTest, ttPostTest);

  TSensorType = (stStrainFB_AB,
                 stStrainHB_AB,
                 stVoltage_AB,
                 stStrainFB,
                 stStrainHB,
                 stVoltage);

  TMemHealth = (mhGood, mhNotGood, mhUndetermined, mhNonExisting);
  TDisMemHealthArray = array[1..32] of TMemHealth;

  TBatChargeStatus = (csDischarging,
                   csCharging,
                   csFullCharge);

  TModuleStatus = (msUnmounted,
                   msSigCond,
                   msDigIn,
                   msAirbagTimer);

  TTriggers   = (trNone,
                 trSW1,
                 trSW2,
                 trCASCADE,
                 trLEVEL1,
                 trLEVEL2,
                 trLEVEL3);

  TMeasStatus = record
                  Measuring           : boolean;
                  TriggerOccurred     : boolean;
                  PwrFailAfterTrigger : boolean;
                  SW2TriggerOccurred  : boolean;
                end;

  TBQ2010 = array[0..10] of word;

  TTrigUse = (tuUse, tuDoNotUse);
  TUse = (uOff, uOn);
  TChargeStatus = (csCharged, csChargeIncomplete, csMeasurementStarted);
  TSquibFireResult = (sfrFired, sfrNotFired);
  TLockPinStatus = (lsNotEngagedNotSafe, lsEngagedSafe);
  TDISBoxType = (bt3000, bt3500);

  TOnGetDataStatus = procedure(sender : TObject; Chan, PacketsRequested, PacketsReceived, PointsReceived, PointsRequested : integer; var AbortDownload : boolean) of object;

const

  wdDefault = 10000; //default watchdog of 10 seconds

  GainCheckConst = 26214;
  ShuntEmuConst = 26214;

  CTrigUse : array[tuUse..tuDoNotUse] of string = ('"use"', '"do not use"');

  {$i CommandDec.inc }

type
  TDISBaseDrv = class(TComponent)
  private
    { Private declarations }
    FApdWsk : TApdWinsockPort;
    FIPAddress : string;
    FConnected : boolean;
    FErrCode : integer;
    FInterruptProcess : boolean;
    FInterruptShuntEmu : boolean;
    FResponseBlockSize : integer;
    FResponseBlock     : array[0..16383] of byte;
    FResponseType : TResponse;
    FStatusFlag : word;
    FBytesReceived : word;
    FStatusBytes : word;
    FBoxType : TDISBoxType;
    FCommonCmd : TDISBaseCmdStrings;
    FCommandStr : string;
    FTriggerProcessed : boolean;
    FLastTriggerCount : integer;
    FByteResponse : string;
    FStringResponse : string;
    FDISDataBlock : TDISDataBlock;
    FIpIcmp: TIpIcmp;
    FPingStatus,
    FPingCompleted : boolean;
    FWatchDog      : TTimer;
    FOnGetDataStatus : TOnGetDataStatus;
    function GetErrorStr : string;
    procedure FApdWskTriggerAvail(CP: TObject; Count: Word);
    procedure FApdWskWsConnect(Sender: TObject);
    procedure FApdWskWsDisconnect(Sender: TObject);
    procedure FApdWskWsError(Sender: TObject; ErrCode: Integer);
//    procedure ProcessResponseBlock;
    function ProcessResponseBlock:boolean;
    procedure InitResponseVars( const Cmd : string;
                                const Typ : TResponse;
                                const Siz : integer );
//    function SetEmergencyStop : boolean;
    procedure SetEmergencyStop; virtual;
    procedure delay( msec : longint );
    procedure FIpIcmpPingComplete(Icmp: TIpCustomIcmp;
      const Replies: TStringList; PingOK: Boolean);
    procedure FOnWatchDog(Sender : TObject);
    procedure StartWatchDog(IntMsec : integer);
    procedure StopWatchDog;
  protected
    { Protected declarations }
    procedure DoGetDataStatus(Chan, Packets, PacketsReceived, PointsReceived, PointsRequested : integer; var AbortDownload : boolean);
  public
    { Public declarations }
    constructor create(aowner : TComponent); override;
    destructor destroy; override;
     //This is the IP Address the computer will try to use when try to connect to a DIS
    property Address : string read FIpAddress write FIpAddress;
    property ConnectedToDIS : boolean read FConnected;
    function ConnectToDIS:boolean; virtual;
    function DisconnectFromDIS:boolean; virtual;
    function ping(value : string):boolean; virtual;
    property ErrorCode : integer read FErrCode;
    property BytesReceived : word read FBytesReceived;
    property ErrorStr  : string read GetErrorStr;
  //Box Level Properties and Methods
  //General DIS Methods/Properties
    function GetRomVersion(var Version : string):boolean; virtual;
     // This programs a new IP address into the DIS that will be used the next time power
     //   is cycled on the DIS.
    function SetIPAddress(const IPAddr : string):boolean; virtual;
     // This will force a read back from DIS memory of the IP Address it will use
     //   the next time it is powered on.  Use this to confirm the SetIPAddress method
    function GetIPAddress(var IPAddr : string):boolean; virtual;
//    property InterruptProcess : boolean read FInterruptProcess write FInterruptProcess default false;
    procedure InterruptProcess;

  //Header Set-up
    function SetMemo(const MemoNum:integer{0-44}; const MemoStr:string):boolean; virtual;
    function GetMemo(const MemoNum:integer{0-44}; var MemoStr:string):boolean; virtual;

  //Measurement Set-up
    function SetSampRate(const RateToSet:integer):boolean; virtual;
    function GetSampRate(var RateSet:integer):boolean; virtual;
    function SetNumPreData(const DataPoints:integer):boolean; virtual;
    function GetNumPreData(var DataPoints:integer):boolean; virtual;

  //Trigger Set-up
    function SetTriggerSW1(const Use : TTrigUse):boolean; virtual;
    function GetTriggerSW1(var Use : TTrigUse):boolean; virtual;
    function SetTriggerSW2(const Use : TTrigUse):boolean; virtual;
    function GetTriggerSW2(var Use : TTrigUse):boolean; virtual;
    function SetTriggerCascade(const Use : TTrigUse):boolean; virtual;
    function GetTriggerCascade(var Use : TTrigUse):boolean; virtual;
    function SetTriggerLevel1(const Use : TTrigUse; const chan : integer; const ADLevel : smallint):boolean; virtual;
    function GetTriggerLevel1(var Use : TTrigUse; var chan : integer; var ADLevel : smallint):boolean; virtual;
    function SetTriggerLevel2(const Use : TTrigUse; const chan : integer; const ADLevel : smallint):boolean; virtual;
    function GetTriggerLevel2(var Use : TTrigUse; var chan : integer; var ADLevel : smallint):boolean; virtual;
    function SetTriggerLevel3(const Use : TTrigUse; const chan : integer; const ADLevel : smallint):boolean; virtual;
    function GetTriggerLevel3(var Use : TTrigUse; var chan : integer; var ADLevel : smallint):boolean; virtual;

  //Check Trigger Function
    function StartTriggerCheck:boolean; virtual;
    function GetTriggerCheckStatus(var Status : TMeasStatus):boolean; virtual;
    function StopTriggerCheck:boolean; virtual;

  // Trigger Enable
    function SetTriggerToEnable:boolean; virtual;

  // Post-test Trigger Information
    function GetTriggerSource(var TrigSrce : TTriggers):boolean; virtual;

  //Test Measurement Process
    function StartMeasAcquire:boolean; virtual;
    function GetMeasAcquireStatus(var Status : TMeasStatus):boolean; virtual;
    function StopMeasAcquire:boolean; virtual;

  //Real-time Measurement Diagnostic
    function SetRealTimeMonitorChans(const Chan1, Chan2, Chan3, Chan4 : integer;
                                             const DataKind : tMeasuredData):boolean; virtual;
    function GetRealTimeMonitorData(var Ch1Data, Ch2Data, Ch3Data, Ch4Data : smallint):boolean; virtual;
    function StopRealTimeMonitor:boolean; virtual;
    function GetTestMeasurement(ChansToMeasure : TChansToMeasure; var Measurements : TChansMeasured):boolean; virtual;

//Module Level Methods
  //Battery Managment
    function GetBatteryRemainder(const Slot : integer; var RemainPct : single):boolean; virtual;
    function StartBatteryDischarge(const Slot : integer):boolean; virtual;
    function GetBatteryStatus(const Slot : integer; var Status : TBatChargeStatus):boolean; virtual;

//Channel Level Methods
  //General
    function GetAllChannelsMemoryHealth(var MemHealth : TDisMemHealthArray):boolean; virtual;
    function ClearChannelMemory(const Chan : integer):boolean; virtual;

  //Measurement Set-up
    function SetChannelGain(const Chan : integer; const Gain : single):boolean; virtual;
    function GetChannelGain(const Chan : integer; var Gain : single):boolean; virtual;
    function SetChannelSensorTypeAndAutoBalanceUse(const chan : integer; const SensorType : TSensorType):boolean; virtual;
    function GetChannelSensorTypeandAutoBalanceUse(const Chan : integer; var SensorType : TSensorType):boolean; virtual;
    function StartBalance:boolean; virtual;
    function StartZeroRead(const WhenZero : TTestTime):boolean; virtual;
    function StartCalPlus(const WhenCal : TTestTime):boolean; virtual;
    function StartCalMinus(const WhenCal : TTestTime):boolean; virtual;
//    function StartShuntEmulation(const Chan : integer):boolean; virtual;
//    function StopShuntEmulation(const Chan : integer):boolean; virtual;
//    function GetShuntEmulationResult(const Chan : integer; var ShuntEmuVal : smallint):boolean; virtual;
//    function StartBridgeExciterCheck(const Chan : integer):boolean; virtual;
//    function GetBridgeExciterCheckResult(const Chan : integer; var Value : smallint):boolean; virtual;
//    function StartReferenceInputCheck(const Chan : integer):boolean; virtual;
//    function GetReferenceInputCheckResult(const Chan : integer; var Value : smallint):boolean; virtual;

  //Preparing for Test Measurement
  function GetTriggerStatus(var Occurred : boolean) : boolean; virtual;

  //Retrieving Data after a Test
    function GetChannelData(const Chan : integer; StartPos : integer;
      const Count : integer; var Data : TMemoryStream{TDisDataBlock}; var Packets : integer{byte{}):boolean; virtual;
  published
    { Published declarations }
    property OnGetDataStatus : TOnGetDataStatus read FOnGetDataStatus write FOnGetDataStatus;
  end;

  TDis3500Drv = class(TDISBaseDrv)
  private
//    function SetEmergencyStop : boolean;
    procedure SetEmergencyStop; override;
  protected
  public
    function ConnectToDIS:boolean; override;
    function GetModuleInformation(const Slot : byte; var ModInfo : tModuleStatus):boolean; virtual; //How will I know what type of module is in each slot?
    function SetTriggerMode(const TrigMode : integer):boolean; virtual;
    function GetTriggerMode(var TrigMode : integer):boolean; virtual;
//    function SetMemo(const Slot, MemoNum:integer{0-44}; const MemoStr:string):boolean; override;
//    function GetMemo(const Slot, MemoNum:integer{0-44}; var MemoStr:string):boolean; override;
    function SetLowPassFilterUse(const Chan : integer; const ChanUse : tUse):boolean; virtual;
    function SetSampRate(const RateToSet:integer):boolean; override;
    function GetSampRate(var RateSet:integer):boolean; override;
    function SetTriggerSW1(const Use : TTrigUse):boolean; override;
    function GetTriggerSW1(var Use : TTrigUse):boolean; override;
    function SetTriggerSW2(const Use : TTrigUse):boolean; override;
    function GetTriggerSW2(var Use : TTrigUse):boolean; override;
    function SetTriggerCascade(const Use : TTrigUse):boolean; override;
    function GetTriggerCascade(var Use : TTrigUse):boolean; override;
    function SetTriggerLevel1(const Use : TTrigUse; const chan : integer; const ADLevel : smallint):boolean; override;
    function GetTriggerLevel1(var Use : TTrigUse; var chan : integer; var ADLevel : smallint):boolean; override;
    function SetTriggerLevel2(const Use : TTrigUse; const chan : integer; const ADLevel : smallint):boolean; override;
    function GetTriggerLevel2(var Use : TTrigUse; var chan : integer; var ADLevel : smallint):boolean; override;
    function SetTriggerLevel3(const Use : TTrigUse; const chan : integer; const ADLevel : smallint):boolean; override;
    function GetTriggerLevel3(var Use : TTrigUse; var chan : integer; var ADLevel : smallint):boolean; override;
    function SetChannelGain(const Chan : integer; const Gain : single):boolean; override;
    function GetChannelGain(const Chan : integer; var Gain : single):boolean; override;
    function SetChannelSensorTypeAndAutoBalanceUse(const chan : integer; const SensorType : TSensorType):boolean; override;
    function GetChannelSensorTypeandAutoBalanceUse(const Chan : integer; var SensorType : TSensorType):boolean; override;
    function SetRealTimeMonitorChans(const Chan1, Chan2, Chan3, Chan4 : integer;
       const DataKind : tMeasuredData):boolean; override;
    function GetTriggerSource(var TrigSrce : TTriggers):boolean; override;
    function GetTriggerMode2PointOfTrigger(var TrigPoint : integer):boolean; virtual;

// Airbag Timer functions only on DIS-3500
    function SetSquibUse(const Chan : integer; const ChanUse : tUse):boolean; virtual;
    function GetSquibUse(const Chan : integer; var ChanUse : tUse):boolean; virtual;
    function GetLockPinStatus(var LockPinStatus : tLockPinStatus):boolean; virtual;
    function GetChargeStatus(const Chan : integer; var ChargeStatus : tChargeStatus):boolean; virtual;
    function SetSquibAmplitude(const Chan : integer; const Current : single):boolean; virtual;
    function GetSquibAmplitudeSetting(const Chan : integer; var Current : single):boolean; virtual;
    function StartSquibResistanceCheck(const Chan : integer):boolean; virtual;
    function GetSquibResistance(const Chan : integer; var Resistance : single):boolean; virtual;
    function SetSquibDelay(const Chan : integer; const seconds : double):boolean; virtual;
    function GetSquibDelaySetting(const Chan : integer; var Seconds : double):boolean; virtual;
    function SetInhibitSquibState(const InhibitUse : tUse):boolean; virtual;
    function GetSquibFireResult(const Chan : integer; var SquibFireResult : tSquibFireResult):boolean; virtual;
    function StopSquibFire:boolean; virtual;

    function CheckGain(const Chan : integer; var Deviation : single):boolean; virtual;
    function CheckShuntEmulation(const Chan : integer; var Deviation : single):boolean; virtual;
    function CheckExcitation(const Chan : integer; var Excitation : single):boolean; virtual;
    function CheckReferenceInput(const Chan : integer; var RefInput : single):boolean; virtual;
    function SetShuntEmulationStop : boolean; virtual;
    function GetTestMeasurement(ChansToMeasure : TChansToMeasure; var Measurements : TChansMeasured):boolean; override;
    property InterruptShuntEmu : boolean read FInterruptShuntEmu write FInterruptShuntEmu default false;
    function GetBatteryRemainder(const Slot : integer; var RemainPct : single):boolean; override;
    function StartBatteryDischarge(const Slot : integer):boolean; override;
    function GetBatteryStatus(const Slot : integer; var Status : TBatChargeStatus):boolean; override;
    function SetModuleBatteryControllerToReset(const Slot : integer):boolean; virtual;
    function GetModuleBatteryControllerStatus(const Slot : integer; var Status : tBQ2010):boolean; virtual;

  published
    property Address;
  end;

//procedure Register;

implementation
{_R *.DCR}

var
  WrongCommand : string;
//========================[ Component Maintenence ]=============================
//------------------------------------------------------------------------------

constructor TDISBaseDrv.create(AOwner : TComponent);
begin
  inherited create(AOwner);
  FPingStatus := false;
  FPingCompleted := false;
  FIpAddress := '';
  FApdWsk := nil;
  FConnected := false;
  FInterruptProcess := false;
  FBoxType := bt3500;
  case FBoxType of
    bt3000 : FCommonCmd := C3000Common;
    bt3500 : FCommonCmd := C3500Common;
  end;
  FWatchDog := TTimer.Create(self);
  FWatchDog.Enabled := false;
  FWatchDog.Interval := wdDefault; 
  FWatchDog.OnTimer := FOnWatchDog;
end;

//------------------------------------------------------------------------------
destructor TDISBaseDrv.destroy;
begin
  DisconnectFromDIS;
  FWatchDog.enabled := false;
  FWatchDog.free;
  inherited destroy;
end;

procedure TDISBaseDrv.delay(msec:longint);
var   StartTime : TdateTime;
      delaylength : real;
begin
//  sleep( msec );
  starttime := now;
  delaylength := msec / 86400000 {1000 / 60 / 60 / 24};
  repeat
    application.processmessages;
  until now-starttime > delaylength;(**)
end;

procedure TDISBaseDrv.DoGetDataStatus(Chan, Packets, PacketsReceived, PointsReceived, PointsRequested : integer; var AbortDownload : boolean);
begin
  if assigned(FOnGetDataStatus) then
    FOnGetDataStatus(self,Chan,Packets,PacketsReceived,PointsReceived,PointsRequested,AbortDownload);
end;

procedure TDISBaseDrv.FOnWatchDog(Sender : TObject);
begin
  FWatchDog.enabled := false;
  FInterruptProcess := true;
end;

procedure TDISBaseDrv.InterruptProcess;
begin
  FOnWatchDog(FWatchDog);
end;

procedure TDISbaseDrv.StartWatchDog(IntMsec : integer);
begin
  FWatchDog.Interval := IntMsec;
  FWatchDog.enabled := true;
end;

procedure TDISBaseDrv.StopWatchDog;
begin
  FWatchDog.Enabled := false;
end;

//===========================[ Winsock Connection ]=============================

//------------------------------------------------------------------------------

function TDISBaseDrv.ping(value : string):boolean;
const count = 4;
begin
  result := false;
  // Create the IpIcmp component.  This performs the PING
  FIpIcmp := TIpIcmp.Create(Self);
  with FIpIcmp do
  begin
    Name := 'FIpIcmp';
    AllowFragmentation := False;
    EchoStringFormat := 'Reply from $A: bytes=$B time=$T TTL=$P';
    PacketData := 'DIS 3500A Ping Check';
    ResolveAddress := True;
    DebugLog.BufferSize := 65536;
    DebugLog.WriteMode := wmAppend;
    DebugLog.Enabled := False;
    DebugLog.FileName := 'debug.log';
    EventLog.DateTimeFormat := 'yyyy.mm.dd hh:nn:ss';
    EventLog.Enabled := False;
    EventLog.FileName := 'event.log';
//    OnIcmpEcho := IpIcmp1IcmpEcho;
//    OnIcmpEchoString := IpIcmp1IcmpEchoString;
    OnPingComplete := FIpIcmpPingComplete;
  end; //with
  // Start the PING and wait for the result
  FPingCompleted := false;
  FIpIcmp.Ping(value,count);
  repeat
    application.ProcessMessages;
  until FPingCompleted;
  result := FPingStatus;
  // All done.  Clean up
  FIpIcmp.free;
  FIpIcmp := nil;
end;

procedure TDISBaseDrv.FIpIcmpPingComplete(Icmp: TIpCustomIcmp;
  const Replies: TStringList; PingOK: Boolean);
begin
  FPingStatus := PingOK;
  FPingCompleted := true;
end;

function TDis3500Drv.ConnectToDis:boolean;
begin
  result := inherited ConnectToDis;
end;

function TDISBaseDrv.ConnectToDIS:boolean;
var PingOK : boolean;
    VerStr : string;
begin
  Result := TRUE;
  if not FConnected then
  begin
    if FIpAddress = '' then
    begin
      result := false;
      FErrCode := 100;
      exit;
    end;
    // First lets PING the DIS 3500A to make sure it is there
    PingOK := Ping(FIpAddress);
    if not PingOK then
    begin
      result := false;
      FErrCode := 103;
      exit;
    end;
    //
    if not assigned(FApdWsk) then
      FApdWsk := TApdWinsockPort.Create(self);
    with FApdWsk do
    begin
      WsTelnet := false;
      AutoOpen := false;
      DeviceLayer := dlWinsock;
      OnTriggerAvail := FApdWskTriggerAvail;
      OnWsConnect    := FApdWskWsConnect;
      OnWsDisconnect := FApdWskWsDisconnect;
      OnWsError      := FApdWskWsError;
      WsAddress := FIPAddress;
      WsPort := '8000'; //This could be made to a property later like the IP address is
    end; //with
    FApdWsk.open := true;
    if FApdWsk.open then
    begin
      // Get ROM Version from DIS to confirm that is functioning
      FConnected := true;
      if GetRomVersion(VerStr) then
      begin
        result := true;
      end
      else
      begin
        DisconnectFromDIS;
        result := false;
        FErrCode := 104;
        exit;
      end;
    end
    else
    begin
      result := false;
      FErrCode := 101; // unable to connect
      FConnected := false;
    end;
  end
  else
  begin
    FErrCode := 102;
    result := false;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.DisconnectFromDIS:boolean;
begin
  if FConnected and assigned(FApdWsk) then
    FApdWsk.Open := false;
  FConnected := false;
  if assigned(FApdWsk) then
    FApdWsk.Free;
  FApdWsk := nil;
  result := true; // This method could end up a procedure if only TRUE is conceivable
end;

//------------------------[ Internal Component Processes ]----------------------
//------------------------------------------------------------------------------
procedure TDISBaseDrv.FApdWskTriggerAvail(CP: TObject; Count: Word);
var
  I : Word;
  BeginVal, EndVal : integer;
begin
  BeginVal := FLastTriggerCount + 1;
  EndVal   := FLastTriggerCount + Count;
  for I := BeginVal to EndVal do //1 to count do
    FResponseBlock[i-1] := byte(FApdWsk.GetChar);
  if (EndVal >= FResponseBlockSize) AND (FResponseBlockSize <> 0) AND
      NOT(FTriggerProcessed) then
  begin
//    ProcessResponseBlock;
//    FTriggerProcessed := TRUE;
//    StopWatchDog;
    FTriggerProcessed := ProcessResponseBlock;
    if FTriggerProcessed then
      StopWatchDog;
  end;
  FLastTriggerCount := EndVal;
end;

//------------------------------------------------------------------------------
procedure TDISBaseDrv.FApdWskWsConnect(Sender: TObject);
begin
end;

//------------------------------------------------------------------------------
procedure TDISBaseDrv.FApdWskWsDisconnect(Sender: TObject);
begin
end;

//------------------------------------------------------------------------------
procedure TDISBaseDrv.FApdWskWsError(Sender: TObject; ErrCode: Integer);
begin
end;

//------------------------------------------------------------------------------
//procedure TDISBaseDrv.ProcessResponseBlock;
function TDISBaseDrv.ProcessResponseBlock:boolean;
var i : integer; //word;
    MemoStr : string;
    TempWord : smallint;
    ResponseSizeBack : word;
begin
  FErrCode := FResponseBlock[0] shl 8 + FResponseBlock[1];
  if FErrCode <> 0 then
    exit;
  ResponseSizeBack := FResponseBlock[2] shl 8 + FResponseBlock[3];
  FBytesReceived :=  ResponseSizeBack;
  result := (FBytesReceived > 0) or (FResponseType = rtNone);
  if not result then
    exit;
  case FResponseType of
    rtByte : begin
               MemoStr := format('%2x', [FResponseBlock[16]]);
               for i := 1 to (ResponseSizeBack-1) do
                 MemoStr :=  MemoStr + #13#10+ format('%2x', [FResponseBlock[i+16]]);
               FByteResponse := MemoStr;
             end;
    rtWord : begin
//               TempWord := smallint(((FResponseBlock[18] shl 8 + FResponseBlock[17]) AND $0FFF) shl 4) DIV 16;
              TempWord := smallint(FResponseBlock[16] shl 8 + FResponseBlock[17]);
               //MemoStr := IntToStr(TempWord);
               FDISDataBlock[0] := TempWord;
               for i := 1 to ((ResponseSizeBack DIV 2)-1) do
               begin
//                 TempWord := smallint(((FResponseBlock[i*2+17] shl 8 + FResponseBlock[i*2+16]) AND $0FFF) shl 4) DIV 16;
                 TempWord := smallint(FResponseBlock[i*2+16] shl 8 + FResponseBlock[i*2+17]);
                 FDISDataBlock[i] := TempWord;
                 //MemoStr :=  MemoStr + #13#10+ inttostr(TempWord);
               end;
               //memoResponseData.lines[0] := MemoStr;
             end;
    rtString : begin
                 MemoStr := '';
                 for i := 0 to (ResponseSizeBack-1) do
                   MemoStr := MemoStr + chr(FResponseBlock[i+16]);
                 // memoResponseData.lines[0] := MemoStr;
                 FStringResponse := MemoStr;
               end;
    rtNone : begin
               // memoResponseData.lines[0] := 'N/A';
             end;
  end;
end;

//------------------------------------------------------------------------------
procedure TDISBaseDrv.InitResponseVars( const Cmd : string;
                                        const Typ : TResponse;
                                        const Siz : integer );
begin
  FCommandStr := Cmd;
  FResponseType := Typ;
  FResponseBlockSize := siz;
  FStatusFlag := 0;
  FBytesReceived := 0;
  FStatusBytes := 0;
  FTriggerProcessed := FALSE;
  FLastTriggerCount := 0;
end;

//========================[ Component Methods ]=================================

//------------------------------------------------------------------------------
function TDISBaseDrv.GetErrorStr : string;
begin
  case FErrCode of
    {$i ErrCodes.inc}
  else
    Result := 'Error Code from DIS-3500A: '+inttostr(FErrCode);  
  end;
end;

//------------------------------------------------------------------------------
//function TDISBaseDrv.SetEmergencyStop :boolean;
procedure TDISBaseDrv.SetEmergencyStop;
begin
  FErrCode := 201;
//  result := true;
  FInterruptProcess := FALSE; // so it won't E-Stop won't recursively occur
end;

//------------------------------------------------------------------------------
//function TDis3500Drv.SetEmergencyStop :boolean ;
procedure TDis3500Drv.SetEmergencyStop;
begin
//  result := FALSE;
  FInterruptProcess := FALSE;
  InitResponseVars( 'EXE-EMERGENCY-STOP', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
//  if FErrCode = 0 then
//  begin
//    result := true;
//  end;
  FInterruptProcess := FALSE; // so it won't E-Stop won't recursively occur
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetRomVersion(var Version : string):boolean;
var VerInt : integer;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetROMVersion ], rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed OR FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    VerInt := FDISDataBlock[0];
    Version := inttostr(VerInt);
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetIPAddress(const IPAddr : string):boolean;
var
  i,
  valu,
  locerr,
  dotpos : integer;
  st,
  SetIPStr : string;
  LocIPAddr : string;
begin
  result := FALSE;
  SetIPStr := '';
  LocIPAddr := trim(IPAddr);
  InitResponseVars( FCommonCmd[ disSetIPAddress ], rtNone, 256 );
  for i := 0 to 3 do
  begin
    if i < 3 then
    begin
      dotpos := pos('.',LocIPAddr );
      if (dotpos = 0) then
      begin
        FErrCode := 300;
        exit;
      end;
    end
    else
      dotpos := length(LocIPAddr)+1;
    st := copy(LocIPAddr,1,dotpos-1);
    if i < 3 then
      LocIPAddr := copy(LocIPAddr,dotpos+1,length(LocIPAddr)-dotpos) // assign rest to IPAddr
    else
      LocIPAddr := '';
    val(st,valu,locerr);
    if (locerr <> 0) OR (valu < 0) OR (valu > 255) then
    begin
      FErrCode := 300;
      exit;
    end;
    SetIPStr := SetIPStr + inttostr(valu);
    if i <> 3 then
      SetIPStr := SetIPStr + ',';
  end;  // for
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+SetIPStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetIPAddress(var IPAddr : string):boolean;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetIPAddress ], rtString, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    IPAddr := FStringResponse;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetMemo(const MemoNum:integer{0-44}; const MemoStr:string):boolean;
var MemoNumStr : string;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disSetMemo ], rtNone, 256 );
  if (MemoNum < 0) OR (MemoNum > 44) then
  begin
    FErrCode := 302;
    exit;
  end;
  if pos(',',MemoStr) <> 0 then
  begin
    FErrCode := 303;
    exit;
  end;
  MemoNumStr := inttostr(MemoNum);
  if length(MemoNumStr) = 1 then
    MemoNumStr := '0'+MemoNumStr;
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+ ' '+MemoNumStr+', '+MemoStr;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetMemo(const MemoNum:integer{0-44}; var MemoStr:string):boolean;
var MemoNumStr : string;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetMemo ], rtString, 256 );
  if (MemoNum < 0) OR (MemoNum > 44) then
  begin
    FErrCode := 302;
    exit;
  end;
  MemoNumStr := inttostr(MemoNum);
  if length(MemoNumStr) = 1 then
  MemoNumStr := '0'+MemoNumStr;
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+ MemoNumStr;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    MemoStr := FStringResponse;
    result := true;
  end;
end;

(*
//------------------------------------------------------------------------------
function TDis3500Drv.SetMemo(const Slot, MemoNum:integer{0-44}; const MemoStr:string):boolean;
var
  CmdStr : PChar;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disSetMemo ], rtNone, 256 );
  if (MemoNum < 0) OR (MemoNum > 44) then
  begin
    FErrCode := 302;
    exit;
  end;
  if pos(',',MemoStr) <> 0 then
  begin
    FErrCode := 303;
    exit;
  end;
  if assigned(FApdWsk) then
  begin
  //   this was an intended method that Kyowa never implemented
  //    CmdStr := PChar(FCommandStr+ ' '+inttostr(Slot)+', '+inttostr(MemoNum)+', '+PChar(MemoStr)+#0);
    CmdStr := PChar(FCommandStr+ ' '+inttostr(Slot)+', '+inttostr(MemoNum)+', '+PChar(MemoStr)+#0);
    FApdWsk.Output := CmdStr;
  end;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDis3500Drv.GetMemo(const Slot, MemoNum:integer{0-44}; var MemoStr:string):boolean;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetMemo ], rtString, 256 );
  if (MemoNum < 0) OR (MemoNum > 44) then
  begin
    FErrCode := 302;
    exit;
  end;
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' 1,'+ inttostr(MemoNum)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    MemoStr := FStringResponse;
    result := true;
  end;
end;
*)

//------------------------------------------------------------------------------
function TDISBaseDrv.SetSampRate(const RateToSet:integer):boolean;
var
  DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disSetSampRate ], rtNone, 256 );
  case RateToSet of
    100    : DisCode := 7;   // these are intentionally out of order
    200    : DisCode := 8;
    500    : DisCode := 0;
    1000   : DisCode := 1;
    2000   : DisCode := 2;
    5000   : DisCode := 4;
    10000  : DisCode := 5;
    16000  : DisCode := 3;
    20000  : DisCode := 6;
   else
   begin
     FErrCode := 305;
     exit;
   end;
  end;
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(DisCode)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetSampRate(var RateSet:integer):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetSampRate ], rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    case DisCode of
      0: RateSet := 500;
      1: RateSet := 1000;
      2: RateSet := 2000;
      3: RateSet := 16000;
      4: RateSet := 5000;
      5: RateSet := 10000;
      6: RateSet := 20000;
      7: RateSet := 100;
      8: RateSet := 200;
      else
      begin
        FErrCode := 306;
        exit;
      end;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetNumPreData(const DataPoints:integer):boolean;
var
  DisCode : integer;
  Remainder : integer;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disSetNumPreData ], rtNone, 256 );
  if DataPoints in [1..16] then // added 1/12/04 by rp.  In case user has already DIV'd predata points by 512
    DisCode := DataPoints
  else
  begin
    DisCode := DataPoints DIV 512;
    Remainder := DataPoints MOD 512;
    if Remainder <> 0 then
    begin
      FErrcode := 307;
      exit;
    end;
  end;
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(DisCode)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetNumPreData(var DataPoints:integer):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetNumPreData ], rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    DataPoints := DisCode * 512;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetTriggerSW1(const Use : TTrigUse):boolean;
begin
  result := false;
  FErrCode := 500;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetTriggerSW1(var Use : TTrigUse):boolean;
begin
  result := false;
  FErrCode := 500;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetTriggerSW1(const Use : TTrigUse):boolean;
begin
  result := FALSE;
  if Use = tuUse then
    InitResponseVars( 'SET-TRIGGER-SW1', rtNone, 256 )
  else
    InitResponseVars( 'RESET-TRIGGER-SW1', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetTriggerSW1(var Use : TTrigUse):boolean;
var Discode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-TRIGGER-SW1', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    case DisCode of
      0: Use := tuDoNotUse;
      1: Use := tuUse;
      else
      begin
        FErrCode := 308;
        exit;
      end;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetTriggerSW2(const Use : TTrigUse):boolean;
begin
  result := false;
  FErrCode := 500;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetTriggerSW2(var Use : TTrigUse):boolean;
begin
  result := false;
  FErrCode := 500;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetTriggerSW2(const Use : TTrigUse):boolean;
begin
  result := FALSE;
  if Use = tuUse then
    InitResponseVars( 'SET-TRIGGER-SW2', rtNone, 256 )
  else
    InitResponseVars( 'RESET-TRIGGER-SW2', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetTriggerSW2(var Use : TTrigUse):boolean;
var Discode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-TRIGGER-SW2', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    case DisCode of
      0: Use := tuDoNotUse;
      1: Use := tuUse;
      else
      begin
        FErrCode := 308;
        exit;
      end;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetTriggerSource(var TrigSrce : TTriggers):boolean;
var Discode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-TRIGGER-SOURCE', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    case DisCode of
      0: TrigSrce := trNone;
      1: TrigSrce := trSW1;
      2: TrigSrce := trSW2;
      3: TrigSrce := trCASCADE;
      4: TrigSrce := trLEVEL1;
      5: TrigSrce := trLEVEL2;
      6: TrigSrce := trLEVEL3;
      else
      begin
        FErrCode := 317;
        exit;
      end;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetTriggerCascade(const Use : TTrigUse):boolean;
begin
  result := false;
  FErrCode := 500;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetTriggerCascade(var Use : TTrigUse):boolean;
begin
  result := false;
  FErrCode := 500;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetTriggerCascade(const Use : TTrigUse):boolean;
begin
  result := FALSE;
  if Use = tuUse then
    InitResponseVars( 'SET-TRIGGER-CASCADE', rtNone, 256 )
  else
    InitResponseVars( 'RESET-TRIGGER-CASCADE', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetTriggerCascade(var Use : TTrigUse):boolean;
var Discode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-TRIGGER-CASCADE', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    case DisCode of
      0: Use := tuDoNotUse;
      1: Use := tuUse;
      else
      begin
        FErrCode := 308;
        exit;
      end;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetTriggerLevel1(const Use : TTrigUse; const chan : integer; const ADLevel : smallint):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetTriggerLevel1(const Use : TTrigUse; const chan : integer; const ADLevel : smallint):boolean;
var PctLevel : integer;
begin
  result := FALSE;
  if Use = tuUse then
  begin
    if (ADLevel < 0) OR (ADLevel > 32767) then
    begin
      FErrCode := 308;
      exit;
    end
    else
      PctLevel := trunc((ADLevel / 32767)*100);
    InitResponseVars( 'SET-TRIGGER-LEVEL1', rtNone, 256 );
    if assigned(FApdWsk) then
      FApdWsk.Output := FCommandStr+' '+inttostr(chan)+','+inttostr(PctLevel)+#0;
  end
  else
  begin
    InitResponseVars( 'RESET-TRIGGER-LEVEL1', rtNone, 256 );
    if assigned(FApdWsk) then
      FApdWsk.Output := FCommandStr+#0;
  end;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetTriggerLevel1(var Use : ttrigUse ; var chan : integer; var ADLevel : smallint):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetTriggerLevel1(var Use : ttrigUse; var chan : integer; var ADLevel : smallint):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-TRIGGER-LEVEL1', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    chan := FDISDataBlock[0];
    if (chan = 0) then
      Use := tuDoNotUse
    else
      Use := tuUse;
    DisCode := FDISDataBlock[1];
    ADLevel := trunc((DisCode/100) * 32767);
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetTriggerLevel2(const Use : ttriguse; const chan : integer; const ADLevel : smallint):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetTriggerLevel2(const Use : ttriguse; const chan : integer; const ADLevel : smallint):boolean;
var PctLevel : integer;
begin
  result := FALSE;
  if Use = tuUse then
  begin
    if (ADLevel < 0) OR (ADLevel > 32767) then
    begin
      FErrCode := 308;
      exit;
    end
    else
      PctLevel := trunc((ADLevel / 32767)*100);
    InitResponseVars( 'SET-TRIGGER-LEVEL2', rtNone, 256 );
    if assigned(FApdWsk) then
      FApdWsk.Output := FCommandStr+' '+inttostr(chan)+','+inttostr(PctLevel)+#0;
  end
  else
  begin
    InitResponseVars( 'RESET-TRIGGER-LEVEL2', rtNone, 256 );
    if assigned(FApdWsk) then
      FApdWsk.Output := FCommandStr+#0;
  end;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetTriggerLevel2(var Use : ttrigUse; var  chan : integer; var ADLevel : smallint):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetTriggerLevel2(var Use : ttrigUse; var  chan : integer; var ADLevel : smallint):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-TRIGGER-LEVEL2', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    chan := FDISDataBlock[0];
    if (chan = 0) then
      Use := tuDoNotUse
    else
      Use := tuUse;
    DisCode := FDISDataBlock[1];
    ADLevel := trunc((DisCode/100) * 32767);
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetTriggerLevel3(const Use : ttriguse; const chan : integer; const ADLevel : smallint):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetTriggerLevel3(const Use : ttriguse; const chan : integer; const ADLevel : smallint):boolean;
var PctLevel : integer;
begin
  result := FALSE;
  if Use = tuUse then
  begin
    if (ADLevel < 0) OR (ADLevel > 32767) then
    begin
      FErrCode := 308;
      exit;
    end
    else
      PctLevel := trunc((ADLevel / 32767)*100);
    InitResponseVars( 'SET-TRIGGER-LEVEL3', rtNone, 256 );
    if assigned(FApdWsk) then
      FApdWsk.Output := FCommandStr+' '+inttostr(chan)+','+inttostr(PctLevel)+#0;
  end
  else
  begin
    InitResponseVars( 'RESET-TRIGGER-LEVEL3', rtNone, 256 );
    if assigned(FApdWsk) then
      FApdWsk.Output := FCommandStr+#0;
  end;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetTriggerLevel3(var Use : ttrigUse; var  chan : integer; var ADLevel : smallint):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetTriggerLevel3(var Use : ttrigUse; var  chan : integer; var ADLevel : smallint):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-TRIGGER-LEVEL3', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    chan := FDISDataBlock[0];
    if (chan = 0) then
      Use := tuDoNotUse
    else
      Use := tuUse;
    DisCode := FDISDataBlock[1];
    ADLevel := trunc((DisCode/100) * 32767);
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDis3500Drv.GetSampRate(var RateSet:integer):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetSampRate ], rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    case DisCode of
      0: RateSet := 100;
      1: RateSet := 200;
      2: RateSet := 500;
      3: RateSet := 1000;
      4: RateSet := 2000;
      5: RateSet := 5000;
      6: RateSet := 10000;
      7: RateSet := 16000;
      8: RateSet := 20000;
      9: RateSet := 50000;
     10: RateSet := 100000;
      else
      begin
        FErrCode := 306;
        exit;
      end;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDis3500Drv.SetSampRate(const RateToSet:integer):boolean;
var
  DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disSetSampRate ], rtNone, 256 );
  case RateToSet of
    0..10  : DisCode := RateToSet; // added 1/12/04 by rp; in case user has already converted sample rate to one of the 11 codes
    100    : DisCode := 0;
    200    : DisCode := 1;
    500    : DisCode := 2;
    1000   : DisCode := 3;
    2000   : DisCode := 4;
    5000   : DisCode := 5;
    10000  : DisCode := 6;
    16000  : DisCode := 7;
    20000  : DisCode := 8;
    50000  : DisCode := 9;
    100000 : DisCode := 10;
   else
   begin
     FErrCode := 305;
     exit;
   end;
  end;
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(DisCode)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDis3500Drv.SetTriggerMode(const TrigMode : integer):boolean;
begin
  result := FALSE;
  InitResponseVars( 'SET-TRIGGER-MODE', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(TrigMode)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDis3500Drv.GetTriggerMode(var TrigMode : integer):boolean;
begin
  result := FALSE;
  InitResponseVars( 'GET-TRIGGER-MODE', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    TrigMode := FDISDataBlock[0];
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDis3500Drv.SetLowPassFilterUse(const Chan : integer; const ChanUse : tUse):boolean;
var
  CommandStr : string;
begin
  result := FALSE;
  if (Chan < 1) then
  begin
    FErrCode := 304;
    exit;
  end;
  if ChanUse = uOff then
    InitResponseVars( 'SET-LPF-OFF', rtNone, 256 )
  else
    InitResponseVars( 'SET-LPF-ON', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDis3500Drv.SetInhibitSquibState(const InhibitUse : tUse):boolean;
var
  CommandStr : string;
begin
  result := FALSE;
  if InhibitUse = uOn then
    InitResponseVars( 'RESET-TIMER-READY', rtNone, 256 )
  else
    InitResponseVars( 'EXE-TIMER-READY', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.StartTriggerCheck:boolean;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[disStartTriggerCheck], rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetTriggerCheckStatus(var Status : TMeasStatus):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.StopMeasAcquire:boolean;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[disStopMeasurement], rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;
//------------------------------------------------------------------------------
function TDIS3500Drv.StopSquibFire:boolean;
begin
  result := FALSE;
  InitResponseVars( 'EXE-EMERGENCY-STOP', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.StartMeasAcquire:boolean;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[disStartMeasurement], rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.StopTriggerCheck:boolean;
begin
  result := FALSE;
  if StopMeasAcquire then
    result := TRUE;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetTriggerStatus(var Occurred : boolean) : boolean;
var MeasStatus : TMeasStatus;
begin
  result := FALSE;
  Occurred := FALSE;
  if GetMeasAcquireStatus( MeasStatus ) then
  begin
    if MeasStatus.TriggerOccurred OR MeasStatus.SW2TriggerOccurred then
      Occurred := TRUE;
    result := TRUE;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetTriggerToEnable:boolean;
var
  DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disTrigEnable ], rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetTriggerSource(var TrigSrce : TTriggers):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetTriggerMode2PointOfTrigger(var TrigPoint : integer):boolean;
begin
  result := FALSE;
  InitResponseVars( 'GET-TRIGGER-POINT', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed OR FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    TrigPoint := integer(FDISDataBlock[0] shl 16 + FDISDataBlock[1]);
    result := true;
  end;
end;


//------------------------------------------------------------------------------
function TDISBaseDrv.GetMeasAcquireStatus(var Status : TMeasStatus):boolean;
var AcqStatus : word;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetMeasStatus ], rtWord, 256 );
  fillchar(Status, sizeof(Status), #0);
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    AcqStatus := FDISDataBlock[0];
    if (AcqStatus AND 1) = 1 then
      Status.Measuring := TRUE;
    if (AcqStatus AND 2) = 2 then
      Status.TriggerOccurred := TRUE;
    if (AcqStatus AND 8) = 8 then
      Status.PwrFailAfterTrigger := TRUE;
    if (AcqStatus AND 64) = 64 then
      Status.SW2TriggerOccurred := TRUE;
    result := true;
  end;
//  else
//    WrongCommand := FCommandStr;

end;

function TDISBaseDrv.GetTestMeasurement(ChansToMeasure : TChansToMeasure; var Measurements : TChansMeasured):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.StopRealTimeMonitor:boolean;
var
  DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disStopMonitor ], rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetRealTimeMonitorChans(const Chan1, Chan2, Chan3, Chan4 : integer;
                                             const DataKind : tMeasuredData):boolean;
var
  SendString : string;
  res : byte;
  LocTimeOut : boolean;
begin
  Result := False;
  if NOT (StopRealTimeMonitor) then
  begin
    FErrCode := 313;
    exit;  // always stop before proceeding
  end;
  InitResponseVars( 'MONX', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := format( FCommandStr+' %.2d,%.2d,%.2d,%.2d,%.2d'#0, [Chan1,Chan2,Chan3,Chan4,ord(DataKind)+1]);
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
    result := true;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetRealTimeMonitorChans(const Chan1, Chan2, Chan3, Chan4 : integer;
  const DataKind : tMeasuredData):boolean;
begin
  Result := False;
  if NOT (StopRealTimeMonitor) then
  begin
    FErrCode := 313;
    exit;  // always stop before proceeding
  end;
  InitResponseVars( 'SET-MONITOR-CONDITION', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := format( FCommandStr+' %.2d,%.2d,%.2d,%.2d'#0, [Chan1,Chan2,Chan3,Chan4]);
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
    result := true;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetRealTimeMonitorData(var Ch1Data, Ch2Data, Ch3Data, Ch4Data : smallint):boolean;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetMonitorData ], rtWord, 32 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    Ch1Data := FDISDataBlock[0];
    Ch2Data := FDISDataBlock[1];
    Ch3Data := FDISDataBlock[2];
    Ch4Data := FDISDataBlock[3];
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDis3500Drv.GetModuleInformation(const Slot : byte; var ModInfo : tModuleStatus):boolean;
begin
  result := FALSE;
  InitResponseVars( 'GET-MODULE-INFORMATION', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    if (Slot > 0) AND (Slot <= (FBytesReceived DIV 2)) then
      ModInfo := TModuleStatus(FDISDataBlock[Slot-1])
    else
    begin
      FErrCode := 301;
      exit;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDis3500Drv.GetBatteryRemainder(const Slot : integer; var RemainPct : single):boolean;
var Remain : single;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetBatteryRemainder ], rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Slot)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    Remain := FDISDataBlock[0];
    RemainPct := (Remain / $5800) * 100;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDis3500Drv.GetModuleBatteryControllerStatus(const Slot : integer; var Status : tBQ2010):boolean;
var i : byte;
begin
  result := FALSE;
  InitResponseVars( 'GET-BQ2010', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Slot)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    for i := 0 to 10 do
      Status[i] := FDISDataBlock[i];   // may be bytes not words
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDis3500Drv.GetBatteryStatus(const Slot : integer; var Status : tBatChargeStatus):boolean;
var BattStatus : word;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetBatteryStatus ], rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Slot)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    BattStatus := FDISDataBlock[0];
    if (BattStatus AND 1) = 1 then
      Status := csDischarging
    else if (BattStatus AND 2) = 1 then
      Status := csCharging
    else if (BattStatus AND 4) = 1 then
      Status := csFullCharge
    else
    begin
      FErrCode := 319;
      exit;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDisBaseDrv.GetBatteryStatus(const Slot : integer; var Status : TBatChargeStatus):boolean;
var BattStatus : word;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetBatteryStatus ], rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    BattStatus := FDISDataBlock[0];
    if (BattStatus AND 1) = 1 then
      Status := csDischarging
    else if (BattStatus AND 2) = 1 then
      Status := csCharging
    else if (BattStatus AND 4) = 1 then
      Status := csFullCharge
    else
    begin
      FErrCode := 319;
      exit;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDisBaseDrv.GetBatteryRemainder(const Slot : integer; var RemainPct : single):boolean;
var Remain : single;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disGetBatteryRemainder ], rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    Remain := FDISDataBlock[0];
    RemainPct := (Remain / $5800) * 100;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
//function TDISBaseDrv.GetModuleBatteryRemainPct(const Module : byte; var RemainPct : byte):boolean;
//begin
//  result := true;
//end;

//------------------------------------------------------------------------------
function TDISBaseDrv.StartBatteryDischarge(const Slot : integer):boolean;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[disStartBatteryDischarge], rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.StartBatteryDischarge(const Slot : integer):boolean;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[disStartBatteryDischarge], rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Slot)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetModuleBatteryControllerToReset(const Slot : integer):boolean;
begin
  result := FALSE;
  InitResponseVars( 'RESET-BQ2010', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Slot)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
//function TDISBaseDrv.GetModuleBatteryChargeStatus(const Module : byte; var Status : TChargeStatus):boolean;
//begin
//  result := true;
//end;

//------------------------------------------------------------------------------
//function TDISBaseDrv.SetModuleBatteryControllerToReset(const Module : byte):boolean;
//begin
//  result := true;
//end;

//------------------------------------------------------------------------------
//function TDISBaseDrv.GetModuleBatteryControllerStatus(const Module : byte; var Status : smallint):boolean;
//begin
//  result := true;
//end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetAllChannelsMemoryHealth(var MemHealth : TDisMemHealthArray):boolean;
var
  StrProcessed : boolean;
  count : integer;
  tempstr : string;
begin
  fillchar( MemHealth, sizeof(MemHealth), ord(TMemHealth(mhUndetermined)));
  result := FALSE;
  InitResponseVars( FCommonCmd[ disStartMemCheck ], rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode <> 0 then
    exit;
  // call out for Memory Result
  InitResponseVars( FCommonCmd[ disGetMemCheckRes ], rtString, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin;
    StrProcessed := FALSE;
    count := 1;
    while NOT(StrProcessed) do
    begin
      tempstr := copy(FStringResponse,1,1);
      if tempstr = '0' then
        MemHealth[count] := mhGood
      else if tempstr = '1' then
        MemHealth[count] := mhNotGood
      else if tempstr = '9' then
        MemHealth[count] := mhNonExisting;
      if length(FStringResponse) > 1 then
      begin
        FStringResponse := copy(FStringResponse,3,length(FStringResponse)-2);
        inc(count);
      end
      else
        StrProcessed := TRUE;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.ClearChannelMemory(const Chan : integer):boolean;
var
  discode : integer;
begin
  result := FALSE;

  InitResponseVars( FCommonCmd[ disStartMemClear ], rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode <> 0 then
    exit;
  // call out for Memory Result
  repeat
    delay(200);  // must do this or there will be a hang on FApdWsk.Output
    InitResponseVars( FCommonCmd[ disGetMemClearRes ], rtWord, 256 );
    if assigned(FApdWsk) then
      FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+ ','+inttostr(Chan)+#0;
    repeat
      application.processmessages;
    until FTriggerProcessed or FInterruptProcess;
    if FInterruptProcess then
    begin
      SetEmergencyStop;
      if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
        FErrCode := 200
      else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
        FErrCode := 202;
    end;
    if FErrCode = 0 then
      DisCode := FDISDataBlock[0]
    else
      exit;
  until (DisCode <> 2);
  if DisCode = 1 then
    FErrCode := 311;
  if DisCode = 2 then  // never hit this case, but useful for debugging
    FErrCode := 312;
  Result := TRUE;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetChannelGain(const Chan : integer; const Gain : single):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetChannelGain(const Chan : integer; const Gain : single):boolean;
var
  DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'SET-GAIN', rtNone, 256 );
  DisCode := trunc(Gain*10);
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+','+inttostr(DisCode)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetChannelGain(const Chan : integer; var Gain : single):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetChannelGain(const Chan : integer; var Gain : single):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-GAIN', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    Gain := DisCode / 10.0;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.SetChannelSensorTypeAndAutoBalanceUse(const chan : integer;
  const SensorType : TSensorType):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetChannelSensorTypeAndAutoBalanceUse(const chan : integer;
  const SensorType : TSensorType):boolean;
var
  DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disSensorType ], rtNone, 256 );
  case SensorType of
    stStrainFB_AB: DisCode := 1;
    stStrainHB_AB: DisCode := 2;
    stVoltage_AB : DisCode := 3;
    stStrainFB   : DisCode := 11;
    stStrainHB   : DisCode := 12;
    stVoltage    : DisCode := 13;
  end;
  // absolutely no spaces after the comma in next line!
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+','+inttostr(DisCode)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.GetChannelSensorTypeandAutoBalanceUse(const Chan : integer;
  var SensorType : TSensorType):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetChannelSensorTypeandAutoBalanceUse(const Chan : integer;
  var SensorType : TSensorType):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-SENSOR-KIND', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+ ' '+ inttostr(Chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    case DisCode of
      1: SensorType := stStrainFB_AB;
      2: SensorType := stStrainHB_AB;
      3: SensorType := stVoltage_AB;
      11:SensorType := stStrainFB;
      12:SensorType := stStrainHB;
      13:SensorType := stVoltage;
      else
      begin
        FErrCode := 310;
        exit;
      end;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.StartBalance:boolean;
var
  DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( FCommonCmd[ disStartBalance ], rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDisBaseDrv.GetChannelData(const Chan : integer; StartPos : integer;
      const Count : integer; var Data : TMemoryStream{TDisDataBlock}; var Packets : integer{byte{}):boolean;
var
  i,DisCode,loop, blocksize : integer;
  tempstr : string;
  PointsAskedFor : integer;
  TotalPointsAskedFor : integer;
  VerStr              : string;
  AbortDownLoad       : boolean;
begin
  Blocksize := 4088;//2048;
  result := FALSE;
  TotalPointsAskedFor := 0;
  AbortDownLoad := false;
  packets := (count DIV Blocksize) + 1;
  if (count MOD Blocksize) = 0 then
    dec(packets);
  loop := 0;
//  fillchar( Data, sizeof(data), #0 );
  if not assigned(Data) then
    Data := TMemoryStream.Create;
  Data.Clear;
  repeat
    InitResponseVars( FCommonCmd[ disGetMeasuredData ], rtWord, 8192 );
    if assigned(FApdWsk) then
    begin
      if (loop <> (packets-1)) or (count = Blocksize) then
        PointsAskedFor := blocksize
      else
        PointsAskedFor := count mod blocksize;
      tempstr :=  FCommandStr+' '+inttostr(chan)+',1,'+inttostr(StartPos)+','+
                  inttostr(PointsAskedFor);
      inc(TotalPointsAskedFor,PointsAskedFor);
      FApdWsk.Output :=  tempstr+#0;
    end;
    StartWatchDog(20000{wdDefault{});
    repeat
      application.processmessages;
    until FTriggerProcessed or FInterruptProcess;
    FTriggerProcessed := FALSE;
    inc( loop );
    if (loop mod 1 = 0) and not FInterruptProcess then
    begin
      FInterruptProcess := not GetRomVersion(VerStr);
    end;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
//    for i := 0 to (blocksize-1) do
//      Data[StartPos + i] := FDISDataBlock[i];
    DoGetDataStatus(Chan,Packets,loop,TotalPointsAskedFor,Count,AbortDownLoad);
    for i := 0 to (PointsAskedFor-1) do
      Data.Write(FDISDataBlock[i],sizeof(FDISDataBlock[i]));
    StartPos := StartPos + blocksize; // for next iteration
  end;
  until FInterruptProcess OR (loop >= packets) OR (FErrCode <> 0) or AbortDownLoad;
  if AbortDownload then
  begin
    FErrCode := 200;
    AbortDownload := false;
  end;
  if FErrCode = 0 then
    result := true;
end;


//------------------------------------------------------------------------------
function TDISBaseDrv.StartZeroRead(const WhenZero : TTestTime):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.StartCalPlus(const WhenCal : TTestTime):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TDISBaseDrv.StartCalMinus(const WhenCal : TTestTime):boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
//function TDISBaseDrv.StartShuntEmulation(const Chan : integer):boolean;
//begin
//  result := true;
//end;

//------------------------------------------------------------------------------
//function TDISBaseDrv.StopShuntEmulation(const Chan : integer):boolean;
//begin
//  result := true;
//end;

//------------------------------------------------------------------------------
//function TDISBaseDrv.GetShuntEmulationResult(const Chan : integer; var ShuntEmuVal : smallint):boolean;
//begin
//  result := true;
//end;

//------------------------------------------------------------------------------
function TDIS3500Drv.CheckGain(const Chan : integer; var Deviation : single):boolean;
var
  GainRead : integer;
  count : integer;
  tempstr : string;
begin
  result := FALSE;
  InitResponseVars( 'EXE-GAIN-CHECK', rtNone, 256 );
  tempstr := FCommandStr+' '+inttostr(chan)+','+inttostr(GainCheckConst)+#0;   // no space after comma!
  if assigned(FApdWsk) then
    FApdWsk.Output := tempstr;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode <> 0 then
    exit;
  // call out for Gain Result
  InitResponseVars( 'GET-GAIN-CHECK-RESULT', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin;
    GainRead := FDISDataBlock[0];
    Deviation := (abs(GainRead - GainCheckConst) / GainCheckConst) * 100.0;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.CheckShuntEmulation(const Chan : integer; var Deviation : single):boolean;
var
  ValRead : integer;
  count : integer;
  tempstr : string;
begin
  result := FALSE;
  InitResponseVars( 'EXE-SHUNT-EMU', rtNone, 256 );
  tempstr := FCommandStr+' '+inttostr(chan)+','+inttostr(ShuntEmuConst)+#0;   // no space after comma!
  if assigned(FApdWsk) then
    FApdWsk.Output := tempstr;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess or FInterruptShuntEmu;
  if FTriggerProcessed then
    delay(6000);
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FInterruptShuntEmu then
  begin
    SetShuntEmulationStop;
    if (FErrCode = 0) then  // Shunt Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 318;
  end;
  if FErrCode <> 0 then
    exit;
  // call out for Gain Result
  InitResponseVars( 'GET-SHUNT-EMU-RESULT', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin;
    ValRead := FDISDataBlock[0];
    Deviation := (abs(ValRead - ShuntEmuConst) / ShuntEmuConst) * 100.0;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.CheckExcitation(const Chan : integer; var Excitation : single):boolean;
var
  ExcitationRead : integer;
  count : integer;
  tempstr : string;
begin
  result := FALSE;
  InitResponseVars( 'EXE-EXCITER-CHECK', rtNone, 256 );
  tempstr := FCommandStr+' '+inttostr(chan)+#0;
  if assigned(FApdWsk) then
    FApdWsk.Output := tempstr;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode <> 0 then
    exit;
  // call out for Excitation Result
  InitResponseVars( 'GET-EXCITER-CHECK-RESULT', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin;
    ExcitationRead := FDISDataBlock[0];
    Excitation := ExcitationRead;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.CheckReferenceInput(const Chan : integer; var RefInput : single):boolean;
var
  RefInputRead : integer;
  count : integer;
  tempstr : string;
begin
  result := FALSE;
  InitResponseVars( 'EXE-REFERENCE-INPUT-CHECK', rtNone, 256 );
  tempstr := FCommandStr+' '+inttostr(chan)+#0;
  if assigned(FApdWsk) then
    FApdWsk.Output := tempstr;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode <> 0 then
    exit;
  // call out for Excitation Result
  InitResponseVars( 'GET-REFERENCE-INPUT-CHECK-RESULT', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin;
    RefInputRead := FDISDataBlock[0];
    RefInput := RefInputRead;  // calculation here as it is determined
    result := true;
  end;
end;

//------------------------------------------------------------------------------
//function TDISBaseDrv.GetBridgeExciterCheckResult(const Chan : integer; var Value : smallint):boolean;
//begin
//  result := true;
//end;

//------------------------------------------------------------------------------
//function TDISBaseDrv.StartReferenceInputCheck(const Chan : integer):boolean;
//begin
//  result := true;
//end;

//------------------------------------------------------------------------------
//function TDISBaseDrv.GetReferenceInputCheckResult(const Chan : integer; var Value : smallint):boolean;
//begin
//  result := true;
//end;

//------------------------------------------------------------------------------
function TDis3500Drv.SetSquibUse(const Chan : integer; const ChanUse : tUse):boolean;
var
  CommandStr : string;
begin
  result := FALSE;
  if (Chan < 1) then
  begin
    FErrCode := 304;
    exit;
  end;
  if ChanUse = uOff then
    InitResponseVars( 'SET-TIMER-OFF', rtNone, 256 )
  else
    InitResponseVars( 'SET-TIMER-ON', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetSquibUse(const Chan : integer; var ChanUse : tUse):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-TIMER', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    case DisCode of
     0 : ChanUse := uOff;
     1 : ChanUse := uOn;
     else
     begin
       FErrCode := 314;
       exit;
     end;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetChargeStatus(const Chan : integer; var ChargeStatus : tChargeStatus):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-CONFIRM-CHARGED-STATUS', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    case DisCode of
     0  : ChargeStatus := csCharged;
     1  : ChargeStatus := csChargeIncomplete;
     -1 : ChargeStatus := csMeasurementStarted;
     else
     begin
       FErrCode := 320;
       exit;
     end;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetSquibFireResult(const Chan : integer; var SquibFireResult : tSquibFireResult):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-FIRING-RESULT', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    case DisCode of
     0  : SquibFireResult := sfrFired;
     1  : SquibFireResult := sfrNotFired;
     else
     begin
       FErrCode := 322;
       exit;
     end;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetLockPinStatus(var LockPinStatus : tLockPinStatus):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-SAFETY-LOCK-PIN', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    case DisCode of
     1 : LockPinStatus := lsNotEngagedNotSafe;
     0 : LockPinStatus := lsEngagedSafe;
     else
     begin
       FErrCode := 321;
       exit;
     end;
    end;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetSquibAmplitude(const Chan : integer; const Current : single):boolean;
var
  DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'SET-SQUIB-CURRENT', rtNone, 256 );
  DisCode := trunc(Current*10);
  if (DisCode > 50) OR (DisCode < 1) then
  begin
    FErrCode := 316;
    exit;
  end;
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+','+inttostr(DisCode)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetSquibAmplitudeSetting(const Chan : integer; var Current : single):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-SQUIB-CURRENT', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    Current := DisCode / 10.0;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetSquibResistance(const Chan : integer; var Resistance : single):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-SQUIB-RESISTANCE-RESULT', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    Resistance := 6 * (DisCode / 32768);
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.StartSquibResistanceCheck(const Chan : integer):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'EXE-SQUIB-RESISTANCE', rtNone, 256 ); // Un-complete return type
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+#0;
//  result := TRUE;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetSquibDelay(const Chan : integer; const seconds : double):boolean;
var
  DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'SET-TIMER-DELAY', rtNone, 256 );
  DisCode := trunc(seconds*10000);
  if (DisCode > 990000) OR (DisCode < 1) then
  begin
    FErrCode := 315;
    exit;
  end;
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+','+inttostr(DisCode)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.GetSquibDelaySetting(const Chan : integer; var seconds : double):boolean;
var DisCode : integer;
begin
  result := FALSE;
  InitResponseVars( 'GET-TIMER-DELAY', rtWord, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+' '+inttostr(Chan)+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    DisCode := FDISDataBlock[0];
    Seconds := DisCode / 10000.0;
    result := true;
  end;
end;

//------------------------------------------------------------------------------
function TDIS3500Drv.SetShuntEmulationStop :boolean;
begin
  result := FALSE;
  InitResponseVars( 'RESET-SHUNT-EMU', rtNone, 256 );
  if assigned(FApdWsk) then
    FApdWsk.Output := FCommandStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed;
  if FErrCode = 0 then
  begin
    result := true;
  end;
  FInterruptShuntEmu := FALSE; // so it won't E-Stop won't recursively occur
end;

function TDIS3500Drv.GetTestMeasurement(ChansToMeasure : TChansToMeasure;
   var Measurements : TChansMeasured):boolean;
var tempstr : string;
    chan    : integer;
    workstr : string;
    LastChan : boolean;
    Count    : integer;
begin
  fillchar(Measurements, sizeof(Measurements), #0);
  result := false;
  WorkStr := '';
  LastChan := true;
  for chan := 32 downto 1 do
  begin
    if ChansToMeasure[Chan] and LastChan then
    begin
      workstr := inttostr(chan);
      LastChan := false;
    end
    else
    if ChansToMeasure[Chan] then
      insert(format('%d,',[Chan]),WorkStr,1);
  end;
  if WorkStr = '' then
  begin
    result := true;
    exit;
  end;

  InitResponseVars(FCommonCmd[disTestMeasurement], rtWord, 256 );
  TempStr := format('%s 1,%s',[FCommandStr,WorkStr]);
  if assigned(FApdWsk) then
    FApdWsk.Output := TempStr+#0;
  StartWatchDog(wdDefault);
  repeat
    application.processmessages;
  until FTriggerProcessed or FInterruptProcess;
  if FInterruptProcess then
  begin
    SetEmergencyStop;
    if (FErrCode = 0) then  // E-Stop sent OK, so just note E-Stopped code for this function
      FErrCode := 200
    else if (FErrCode <> 201) then  // If not a DIS-3000A, then E-Stop didn't even send properly
      FErrCode := 202;
  end;
  if FErrCode = 0 then
  begin
    Count := 0;
    for Chan := 1 to 32 do
    begin
      if ChansToMeasure[Chan] then
      begin
        Measurements[Chan] := FDISDataBlock[Count];
        inc(Count);
      end;
    end;
    result := true;
  end;
end;

//procedure Register;
//begin
//  RegisterComponents('TMSI', [TDis3500Drv]);
//end;

end.
