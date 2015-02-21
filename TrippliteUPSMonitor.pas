unit TrippliteUPSMonitor;

interface

Uses  Windows, Messages, Forms, SysUtils, Classes, ExtCtrls, AdPort, OoMisc, AdPacket, AdExcept;

const
  ACLine = 0;
  BatteryState = 1;
  BatteryPercent = 2;
  BatteryLifeTime = 3;
  BatteryFullLifeTime = 4;
  TrippLiteCommands : Array[0..8] of ShortString = ('','~00P003RAT','~00P003STI','~00P003STO','~00P003STB','~00S','~00S','~00S','~00S');

type
  TTimeEvent = procedure( Sender : TObject ) of object; // Event for update of everything
  TACStatus = procedure( Sender : TObject; strState: ShortString; IntCode : LongInt ) of object; // Event that fires when the AC status changes.
  TBattStatus = procedure( Sender : TObject; strState: ShortString; IntCode : LongInt ) of object; // Event that fires when the Battery status changes.
  TBattLifePercent = procedure( Sender : TObject; State: LongInt; IntCode : LongInt ) of object; // Event that fires when the Battery Life Percent changes.
  TBattLifeTime = procedure( Sender : TObject; strState: ShortString; IntCode : LongInt ) of object; // Event that fires when the Battery Life Time changes.
  TBattFullLifeTime = procedure( Sender : TObject; strState: ShortString; IntCode : LongInt ) of object; // Event that fires when the Battery Life Full Time changes.
  TLowBatteryWarn = procedure( Sender : TObject; strState: ShortString; IntCode : LongInt ) Of Object; // Event that fires when the battery gets below a certin percent.

  TTLCmds = (Upd_NONE,Upd_Ratings,Upd_Input,Upd_Output,Upd_Battery,
             Set_ShutdownType,Set_ShutdownAction,Set_ShuntDownRestart,Set_Test);
  TAction = (A_ShutdownOutputs,A_ShutdownSystem);
  TTLCmd_String = Array[1..7] of Char;

  TBatteryState = record
                    BatteryFlag             : ShortString;
                    BatteryLifePercent      : LongInt;
                    ACLineStatus            : ShortString;
                    BatteryLifeTime         : ShortString;
                    BatteryFullLifeTime     : ShortString;
                    BatteryFlagCode         : LongInt;
                    BatteryLifePercentCode  : LongInt;
                    ACLineStatusCode        : LongInt;
                    BatteryLifeTimeCode     : LongInt;
                    BatteryFullLifeTimeCode : LongInt;
  end; // TBatteryState

  TUPSInputStatus = record
                      InputLineCount : LongInt;
                      InputFrequency : Double;
                      InputVoltage   : Double;
  end; // TUPSInputStatus

  TUPSOutputStatus = record
                       OutputSource      : LongInt;
                       OutputFrequency   : Double;
                       OutputLineCount   : LongInt;
                       OutputVoltage     : Double;
                       OutputCurrent     : Double;
                       OutputPower       : Double;
                       OutputLoadPercent : Double;
  end; // TUPSOutputStatus

  TUPSRatings = record
                  RatedInputVoltage       : Double;
                  RatedInputFrequencey    : Double;
                  RatedOutputVoltage      : Double;
                  RatedOutputFrequencey   : Double;
                  RatedVA                 : Double;
                  RatedOutputPower        : Double;
                  LowTxVoltagePoint       : Double;
                  HighTxVoltagePoint      : Double;
                  LowTxVoltageUpperBound  : Double;
                  LowTxVoltageLowerBound  : Double;
                  HighTxVoltageUpperBound : Double;
                  HighTxVoltageLowerBound : Double;
                  UPSType                 : LongInt;
                  RatedBatteryVoltage     : Double;
                  LowTxFrequencyPoint      : Double;
                  HighTxFrequencyPoint     : Double;
  end; // TUPSRatings

  TUPSBatteryStatus = record
                        BatteryCondition           : LongInt;
                        BatteryStatus              : LongInt;
                        BatteryCharge              : LongInt;
                        SecondsOnBattery           : Double;
                        EstimatedMinutesRemaining  : LongInt;
                        EstimatedPercentChargeUsed : LongInt;
                        BatteryVoltage             : Double;
                        TemperatureCelsius         : Double;
                        BatteryLevelPercent        : Double;
  end; // TUPSBatteryStatus

  TTransmitUPSRatings = procedure(Sender : TObject; UPSRatings : TUPSRatings) of Object;
  TTransmitUPSInputStatus = procedure(Sender : TObject; UPSInputStatus : TUPSInputStatus) of Object;
  TTransmitUPSOutputStatus = procedure(Sender : TObject; UPSOutputStatus : TUPSOutputStatus) of Object;
  TTransmitUPSBatteryStatus = procedure(Sender : TObject; UPSBatteryStatus : TUPSBatteryStatus) of Object;
  TSerialPortError = procedure(Sender : TObject; strMessage : ShortString) of Object;

  TTrippLiteUSBPowerMonitor = class(TComponent)
  private
    FTimeEvent : TTimeEvent;
    FOnACStatus : TACStatus;
    FOnBattStatus : TBattStatus;
    FOnBattLifePercent : TBattLifePercent;
    FOnBattLifeTime : TBattLifeTime;
    FOnBattFullLifeTime : TBattFullLifeTime;
    FOnLowBatteryWarning : TLowBatteryWarn;
    FCurrACCode : Byte;
    FCurrBattCode : Byte;
    FCurrBattPercentCode : Byte;
    FCurrBattLifeCode : LongInt;
    FCurrBattFullLifeCode : LongInt;
    FWarnBatteryLevel : LongInt;
    FTimerTrigger : LongInt;
    TmrPowerStatus : TTimer;
    FPowerState : TBatteryState;
    FOnBattStatusStr : ShortString;
    FVersion : ShortString;
    FACLineState : Integer;
    FBatteryState : Integer;
    FEnabled : Boolean;
  protected
    procedure Initialize;
    procedure SetTimerInterval( Interval : LongInt );
    procedure SetWarnBatteryLevel( WarnLevel : LongInt );
    Function GetACLineStatus( ACValue : Byte ) : ShortString;
    Function GetBatteryState( BattValue : Byte ) : ShortString;
    Function GetBatteryLifePercent( BattLifePercent : Byte ) : LongInt;
    Function GetBatteryLifeTime( BattLifeTime : LongInt ): ShortString;
    Function GetBatteryFullLifeTime( BattFullLifeTime : LongInt ) : ShortString;
    procedure SetEnabled( EnableMe : Boolean ); Virtual;
    procedure SetVersion(Value : ShortString);
    procedure MyTimerEvent( Sender : TObject);
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
  published
    property Version : ShortString read FVersion write SetVersion;
    property PollingInterval : LongInt read FTimerTrigger write SetTimerInterval default 10000;
    property BatteryWaringLevel : LongInt read FWarnBatteryLevel write SetWarnBatteryLevel default 10;
    property Enabled : Boolean read FEnabled write SetEnabled default False;
    property ACLineStatus : ShortString read FPowerState.ACLineStatus;
    property BatteryState : ShortString read FPowerState.BatteryFlag;
    property BatteryLifeAsPercent : LongInt read FPowerState.BatteryLifePercent;
    property BatteryLifeTime : ShortString read FPowerState.BatteryLifeTime;
    property BatteryFullLifeTime: ShortString read FPowerState.BatteryFullLifeTime;
    property CurrentACLineStatus : Byte read FCurrACCode;
    property CurrentBatteryLifePercent : Byte read FCurrBattPercentCode;
    property CurrentBatteryState : ShortString read FOnBattStatusStr;

    property OnTimerUpdate : TTimeEvent read FTimeEvent write FTimeEvent;
    property OnACStatusChange : TACStatus read FOnACStatus write FOnACStatus;
    property OnBatteryStateChange : TBattStatus read FOnBattStatus write FOnBattStatus;
    property OnBatteryLifePercentChange : TBattLifePercent read FOnBattLifePercent write FOnBattLifePercent;
    property OnBatteryLifeTimeChange : TBattLifeTime read FOnBattLifeTime write FOnBattLifeTime;
    property OnBatteryFullLifeTimeChange : TBattFullLifeTime read FOnBattFullLifeTime write FOnBattFullLifeTime;
    property OnLowBattery : TLowBatteryWarn read FOnLowBatteryWarning write FOnLowBatteryWarning;
  end; // TTrippLiteUSBPowerMonitor

  TTrippLiteSerialPowerMonitor = class(TTrippLiteUSBPowerMonitor)
  private
    FOnNewUPSRatings : TTransmitUPSRatings;
    FOnNewUPSInputStatus : TTransmitUPSInputStatus;
    FOnNewUPSOutputStatus : TTransmitUPSOutputStatus;
    FOnNewUPSBatteryStatus : TTransmitUPSBatteryStatus;
    FOnSerialPortError : TSerialPortError;
    FSerialPort : TApdComPort;
    FSerialPortPacket : TApdDataPacket;
    FtmrSendCommand : TTimer;
    FtmrCommsWatchdog : TTimer;
    FComNumber : LongInt;
    FBaudRate : LongInt;
    FParity : TParity;
    FStopBits : LongInt;
    FDataBits : LongInt;
    FPacketData : String;
    FPacketTimeOut : Boolean;
    FPollStatus : Array[Upd_NONE..Upd_Battery] of Boolean;
    FSerialPollingInterval : LongInt;
    FCommsTimeOutPeriod : LongInt;
    FUseSerialComms : Boolean;
    FSentCommand : TTLCmds;
    FCommandToSend : TTLCmds;
    FWaitingForResponse : Boolean;
    FCmdProcessed : Array[Upd_NONE..Upd_Battery] of Boolean;
    procedure SerialPortPacket1Packet(Sender: TObject; Data: Pointer;
      Size: Integer);
    procedure SerialPortPacket1Timeout(Sender: TObject);
    procedure tmrSendCommandTimer(Sender : TObject);
    procedure SetComNumber(Value : LongInt);
    procedure SetSerialPollingInterval(Value : LongInt);
    procedure tmrCommsWatchDogTimer(Sender : TObject);
  protected
    procedure DoSendUPSRatings(Ratings : TUPSRatings);
    procedure DoSendUPSInputStatus(InputStatus : TUPSInputStatus);
    procedure DoSendUPSOutputStatus(OutputStatus : TUPSOutputStatus);
    procedure DoSendUPSBatteryStatus(BattStatus : TUPSBatteryStatus);
    procedure Delay(WaitTimeMs : LongInt);
    function InitializeComPort : Boolean;
    procedure CloseComPort;
    function Send_Cmd(TLCommand : String; DataSize : LongInt; UseWatchDog : Boolean) : Boolean;
    function Valid_Response(Var Response : TTLCmd_String) : Boolean;
    function TestComms : Boolean;
    function Send_UPS_Command(Command : TTLCmds; OptionalString : ShortString; DataSize : LongInt; UseWatchDog : Boolean) : Boolean;
    function Update_UPS_Ratings : Boolean;
    procedure ProcessUPSRatings(Response : String);
    function Update_UPS_Inputs : Boolean;
    procedure ProcessUPSInputs(Response : String);
    function Update_UPS_Outputs : Boolean;
    procedure ProcessUPSOutputs(Response : String);
    function Update_UPS_Battery : Boolean;
    procedure ProcessUPSBattery(Response : String);
    procedure ParseRatings(RatingsString : ShortString);
    procedure ParseInputStatus(InputString : ShortString);
    procedure ParseOutputStatus(OutputString : ShortString);
    procedure ParseBatteryStatus(BatteryString : ShortString);
    function NextCommandToSend : TTLCmds;
    procedure SetBaudRate(Value : LongInt);
    procedure SetParity(Value : TParity);
    procedure SetStopBits(Value : LongInt);
    procedure SetDataBits(Value : LongInt);
    procedure SetCommsTimeOutPeriod(Value : LongInt);
    procedure SetEnabled(Value : Boolean); Override;
    procedure SetSerialPort(SerialPort : TApdComPort);
    function GetCommsPassed : Boolean;
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    function LookUpUPSType(UPSType : LongInt) : ShortString;
    function LookUpUPSBatteryCondition(BatteryCondition : LongInt) : ShortString;
    function LookUpUPSBatteryStatus(BatteryStatus : LongInt) : ShortString;
    function LookUpUPSBatteryCharge(BatteryCharge : LongInt) : ShortString;
    function LookUpUPSOutputSource(OutputSource : LongInt) : ShortString;
    function ShutdownAction(DelaySeconds : DWord) : Boolean;
    function ShutdownRestart(DelayMinutes : DWord) : Boolean;
    function ShutdownType(SDType : TAction) : Boolean;
    function TestUPS(Abort : Boolean) : Boolean;
    property CommsPassed : Boolean read GetCommsPassed;
  published
    property SerialPort : TApdComPort read FSerialPort write SetSerialPort;
    property UseSerialComms : Boolean read FUseSerialComms write FUseSerialComms;
    property CommPortNumber : LongInt read FComNumber write SetComNumber;
    property BuadRate : LongInt read FBaudRate write SetBaudRate;
    property Parity : TParity read FParity write SetParity;
    property StopBits : LongInt read FStopBits write SetStopBits;
    property DataBits : LongInt read FDataBits write SetDataBits;
    property SerialPollingInterval : LongInt read FSerialPollingInterval write SetSerialPollingInterval;
    property CommsTimeOutPeriod : LongInt read FCommsTimeOutPeriod write SetCommsTimeOutPeriod;
    property PollRatings : Boolean read FPollStatus[Upd_Ratings] write FPollStatus[Upd_Ratings];
    property PollInput : Boolean read FPollStatus[Upd_Input] write FPollStatus[Upd_Input];
    property PollOutput : Boolean read FPollStatus[Upd_Output] write FPollStatus[Upd_Output];
    property PollBattery : Boolean read FPollStatus[Upd_Battery] write FPollStatus[Upd_Battery];

    property OnNewUPSRatings  : TTransmitUPSRatings read FOnNewUPSRatings write FOnNewUPSRatings;
    property OnNewUPSInputStatus : TTransmitUPSInputStatus read FOnNewUPSInputStatus write FOnNewUPSInputStatus;
    property OnNewUPSOutputStatus : TTransmitUPSOutputStatus read FOnNewUPSOutputStatus write FOnNewUPSOutputStatus;
    property OnNewUPSBatteryStatus : TTransmitUPSBatteryStatus read FOnNewUPSBatteryStatus write FOnNewUPSBatteryStatus;
    property OnSerialPortError : TSerialPortError read FOnSerialPortError write FOnSerialPortError;
  end; // TTrippLiteSerialPowerMonitor

  TTrippLitePowerMonitor = class(TTrippLiteSerialPowerMonitor);

  procedure Register;

implementation
{_R TrippliteUPSMonitor.dcr}

procedure Register;
begin
  RegisterComponents('TMSI',[TTrippLitePowerMonitor]);
end; // Register

constructor TTrippLiteSerialPowerMonitor.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FComNumber := 1;
  FBaudRate := 2400;
  FParity := pNone;
  FStopBits := 1;
  FDataBits := 8;
  FPacketData := '';
  FPacketTimeOut := False;
  FSerialPollingInterval := 500{ms};
  FCommsTimeOutPeriod := 1000;
  FUseSerialComms := False;
  FSentCommand := Upd_NONE;
  FCommandToSend := Upd_NONE;
  FWaitingForResponse := False;
  FillChar(FPollStatus,SizeOf(FPollStatus),#49);
  FillChar(FCmdProcessed,SizeOf(FCmdProcessed),#0);
  if Not (csDesigning in ComponentState) then
  begin
    FtmrSendCommand := TTimer.Create(Self);
    with FtmrSendCommand do
    begin
      Enabled := False;
      Interval := FSerialPollingInterval;
      OnTimer := tmrSendCommandTimer;
    end; // With
    FtmrCommsWatchdog := TTimer.Create(Self);
    with FtmrCommsWatchdog do
    begin
      Enabled := False;
      Interval := FCommsTimeOutPeriod + 2000{ms};
      OnTimer := tmrCommsWatchDogTimer;
    end; // With
    FSerialPort := TApdComPort.Create(Self);
    with FSerialPort do
    begin
      Open := False;
      ComNumber := FComNumber;
      Baud := FBaudRate;
      AutoOpen := True;
    end; // With
    FSerialPortPacket := TApdDataPacket.Create(Self);
    with FSerialPortPacket do
    begin
      Enabled := False;
      AutoEnable := False;
      ComPort := FSerialPort;
      StartCond := scAnyData;
      EndCond := [ecPacketSize];
      PacketSize := 0;
      TimeOut := 182;
      OnPacket := SerialPortPacket1Packet;
      OnTimeout := SerialPortPacket1Timeout;
    end; // With
  end; // If
end; // TTrippLiteSerialPowerMonitor.Create

destructor TTrippLiteSerialPowerMonitor.Destroy;
begin
  CloseComPort;
  if Not (csDesigning in ComponentState) then
  begin
    FtmrSendCommand.Enabled := False;
    FtmrSendCommand.Free;
    FSerialPortPacket.Free;
    FSerialPort.Free;
  end; // If
  inherited Destroy;
end; // TTrippLiteSerialPowerMonitor.Destroy

procedure TTrippLiteSerialPowerMonitor.DoSendUPSRatings(Ratings : TUPSRatings);
begin
  if Assigned(FOnNewUPSRatings) then
    FOnNewUPSRatings(Self,Ratings);
end; // TTrippLiteSerialPowerMonitor.DoSendUPSRatings

procedure TTrippLiteSerialPowerMonitor.DoSendUPSInputStatus(InputStatus : TUPSInputStatus);
var
  ACState : ShortString;
  Code : LongInt;
begin
  if Assigned(FOnACStatus) then
  begin
    if (InputStatus.InputVoltage > 100) then
    begin
      ACState := 'AC Power is ONLINE';
      Code := 1; // Good
    end
    else
    begin
      ACState := 'AC Power is OFFLINE';
      Code := 0; // Bad
    end; // If
    if (FACLineState <> Code) then
    begin
      FACLineState := Code;
      if Assigned(FOnACStatus) then
        FOnACStatus(Self,ACState,Code);
    end; // If
  end; // If
  if Assigned(FOnNewUPSInputStatus) then
    FOnNewUPSInputStatus(Self,InputStatus);
end; // TTrippLiteSerialPowerMonitor.DoSendUPSInputStatus

procedure TTrippLiteSerialPowerMonitor.DoSendUPSOutputStatus(OutputStatus : TUPSOutputStatus);
begin
  if Assigned(FOnNewUPSOutputStatus) then
    FOnNewUPSOutputStatus(Self,OutputStatus);
end; // TTrippLiteSerialPowerMonitor.DoSendUPSOutputStatus

procedure TTrippLiteSerialPowerMonitor.DoSendUPSBatteryStatus(BattStatus : TUPSBatteryStatus);
var
  BatteryState : ShortString;
begin
  if Assigned(FOnBattStatus) then
  begin
    Case BattStatus.BatteryStatus of
      0 : BatteryState := 'Battery Level is HIGH';
      1 : BatteryState := 'Battery Level is LOW';
      2 : BatteryState := 'Battery Level is Critical';
    end; // Case
    if (FACLineState = 1) and (BattStatus.BatteryLevelPercent < 100) then
    begin
      case BattStatus.BatteryCharge of
        1 : BatteryState := 'Battery is Charging';
      end; // Case
    end; // if
    if (FBatteryState <> BattStatus.BatteryStatus) then
    begin
      FBatteryState := BattStatus.BatteryStatus;
      FOnBattStatus(Self,BatteryState,BattStatus.BatteryStatus);
    end; // If
  end; // If
  if Assigned(FOnBattLifePercent) then
    FOnBattLifePercent(Self,Trunc(BattStatus.BatteryLevelPercent),Trunc(BattStatus.BatteryLevelPercent));
  if Assigned(FOnLowBatteryWarning) then
  begin
    if (FWarnBatteryLevel > BattStatus.BatteryLevelPercent) then
      FOnLowBatteryWarning(Self,'Battery Low',Trunc(BattStatus.BatteryLevelPercent));
  end; // If
  if Assigned(FOnNewUPSBatteryStatus) then
    FOnNewUPSBatteryStatus(Self,BattStatus);
end; // TTrippLiteSerialPowerMonitor.DoSendUPSBatteryStatus

procedure TTrippLiteSerialPowerMonitor.Delay(WaitTimeMS : LongInt);
var
  lStart : LongInt;
  lCurr  : LongInt;
begin
  lStart := GetTickCount;
  repeat
    lCurr := GetTickCount - lStart;
    Sleep(1);
    Application.ProcessMessages;
  until (lCurr >= WaitTimeMS);
end; // TTrippLiteUSBPowerMonitor.Dela

procedure TTrippLiteSerialPowerMonitor.SerialPortPacket1Packet(Sender: TObject;
  Data: Pointer; Size: Integer);
var
  i : LongInt;
  DataChar : Array[0..255] of ANSIChar;
begin
  FtmrCommsWatchdog.Enabled := False;
  FPacketData := '';
  FillChar(DataChar,SizeOf(DataChar),#0);
  StrLCopy(PAnsiChar(@DataChar[0]),Data,SizeOf(DataChar));
  DataChar[Size] := #0;
  for i := 0 to (Size - 1) do
    FPacketData := FPacketData + DataChar[i];
  case FSentCommand of
    Upd_Ratings                : ProcessUPSRatings(FPacketData);
    Upd_Input                  : ProcessUPSInputs(FPacketData);
    Upd_Output                 : ProcessUPSOutputs(FPacketData);
    Upd_Battery                : ProcessUPSBattery(FPacketData);
    Set_ShutdownType..Set_Test : FCmdProcessed[FSentCommand] := True;
  end; // Case
  FWaitingForResponse := False;
end;

procedure TTrippLiteSerialPowerMonitor.SerialPortPacket1Timeout(Sender: TObject);
begin
  FWaitingForResponse := False;
  FtmrCommsWatchdog.Enabled := False;
  FPacketTimeOut := True;
  if Assigned(FOnSerialPortError) then
    FOnSerialPortError(Self,format('Command Failed (#%d); Command Timmed out.',[Ord(FSentCommand)]));
end;

procedure TTrippLiteSerialPowerMonitor.tmrSendCommandTimer(Sender : TObject);
begin
  FtmrSendCommand.Enabled := False;
  if FEnabled then
  begin
    if Not FWaitingForResponse then
    begin
      FCommandToSend := NextCommandToSend;
      if FPollStatus[FCommandToSend] and FEnabled then
      begin
        case FCommandToSend of
          Upd_Ratings : Update_UPS_Ratings;
          Upd_Input   : Update_UPS_Inputs;
          Upd_Output  : Update_UPS_Outputs;
          Upd_Battery : Update_UPS_Battery;
        end; // Case
      end; // If
    end; // If
  end; // If
  FtmrSendCommand.Enabled := FEnabled and (FCommandToSend in [Upd_Ratings..Upd_Battery]);
end; // TTrippLiteUSBPowerMonitor.tmrSendCommandTimer

procedure TTrippLiteSerialPowerMonitor.tmrCommsWatchDogTimer(Sender : TObject);
begin
  FtmrCommsWatchdog.Enabled := False;
  if Assigned(FSerialPortPacket) then
  begin
    FPacketTimeOut := True;
    FSerialPortPacket.Enabled := False;
  end; // If
end; // TTrippLiteSerialPowerMonitor.tmrCommsWatchDogTimer

function TTrippLiteSerialPowerMonitor.InitializeComPort : Boolean;
begin
  Result := True;
  if Not (csDesigning in ComponentState) then
  begin
    try
      with FSerialPort do
      begin
        Baud := FBaudRate;
        DataBits := FDataBits;
        StopBits := FStopBits;
        Parity := pNone;
        SWFlowOptions := swfNone;
        Open := True;
      end; // With
      FSerialPortPacket.ComPort := FSerialPort;
    except
      On E : Exception do
      begin
        Result := False;
        if Assigned(FOnSerialPortError) then
          FOnSerialPortError(Self,format('Error opening comm port %d.',[FComNumber]));
      end; // If
    end; // Try
  end; // If
end; // TTrippLiteUSBPowerMonitor.InitializeComPort

procedure TTrippLiteSerialPowerMonitor.CloseComPort;
begin
  if Not (csDesigning in ComponentState) then
    FSerialPort.Open := False;
end; // TTrippLiteUSBPowerMonitor.CloseComPort

function TTrippLiteSerialPowerMonitor.Send_Cmd(TLCommand : String; DataSize : LongInt; UseWatchDog : Boolean) : Boolean;
begin
  Result := True;
  FPacketTimeOut := False;
  FPacketData := '';
  FSerialPortPacket.PacketSize := DataSize;
  FSerialPortPacket.Enabled := True;
  FtmrCommsWatchdog.Enabled := UseWatchDog;
  if (FSerialPort.OutBuffFree > Length(TLCommand)) then
  begin
    FWaitingForResponse := True;
    FSerialPort.PutString(TLCommand);
  end
  else
    Result := False;
end; // TTrippLiteUSBPowerMonitor.Send_Cmd

function TTrippLiteSerialPowerMonitor.Valid_Response(Var Response : TTLCmd_String) : Boolean;
var
  ResponseOK : Boolean;
  i : LongInt;
begin
  ResponseOK := False;
  if (Length(Response) = 7) then
  begin
    if (Response[1] = '~') then
    begin
      if (Response[2] in ['0'..'9']) and (Response[3] in ['0'..'9']) then
      begin
        if (Response[4] = Char('D')) then
        begin
          ResponseOK := (Response[2] in ['0'..'9']);
          for i := (Low(Response) + 1) to High(Response) do
          begin
            if (i <> 4) then
              ResponseOK := ResponseOK and (Response[i] in ['0'..'9']);
          end; // If
        end; // If
      end; // If
    end; // If
  end; // If
  Result := ResponseOK;
end; // TTrippLiteUSBPowerMonitor.Valid_Response

function TTrippLiteSerialPowerMonitor.TestComms : Boolean;
const
  DataSize : Array[Upd_Ratings..Upd_Battery] of Byte = (71,17,33,41);
var
  CMD : TTLCmds;
  TmpBool : Boolean;
  TmpInt : Byte;
  ElapsedTime : DWord;
begin
  FtmrSendCommand.Enabled := False;
  TmpInt := 0;
  for CMD := Upd_Ratings to Upd_Battery do
  begin
    ElapsedTime := 0;
    TmpBool := Send_UPS_Command(CMD,'',DataSize[CMD],True);
    repeat
      Delay(100);
      Inc(ElapsedTime,100);
    until FCmdProcessed[CMD] or FPacketTimeOut or Not FEnabled or (ElapsedTime >= FCommsTimeOutPeriod);
    if Not FCmdProcessed[CMD] then
      Break
    else
      Inc(TmpInt);
  end; // For CMD
  FEnabled := FEnabled and (TmpInt = 4);
  FtmrSendCommand.Enabled := FEnabled;
  Result := (TmpInt = 4);
end; // TTrippLiteSerialPowerMonitor.TestComms

function TTrippLiteSerialPowerMonitor.Send_UPS_Command(Command : TTLCmds; OptionalString : ShortString; DataSize : LongInt; UseWatchDog : Boolean) : Boolean;
begin
  FSentCommand := Command;
  FCmdProcessed[Command] := False;
  Result := Send_Cmd(format('%s%0.3d%s',[TrippLiteCommands[Ord(FSentCommand)],Length(OptionalString),OptionalString]), DataSize, UseWatchDog);
  if Not Result then
  begin
    if Assigned(FOnSerialPortError) then
      FOnSerialPortError(Self,format('Command Failed (#%d); Output buffer full.',[Ord(Command)]));
  end; // If
end; // TTrippLiteUSBPowerMonitor.Send_UPS_Command

procedure TTrippLiteSerialPowerMonitor.ProcessUPSRatings(Response : String);
var
  i : LongInt;
  Returned_Cmd : TTLCmd_String;
begin
  if (Length(Response) >= 7) then
  begin
    for i := 1 to 7 do
      Returned_Cmd[i] := Response[i];
    if Valid_Response(Returned_Cmd) and (Length(Response) = 71) then
    begin
      ParseRatings(Response);
      FCmdProcessed[Upd_Ratings] := True;
    end
    else
    begin
      if Assigned(FOnSerialPortError) then
        FOnSerialPortError(Self,'Response from UPS garbbled, unable to update Ratings Status.');
    end; // If
  end; // If
end; // TTrippLiteSerialPowerMontior.ProcessUPSRatings

function TTrippLiteSerialPowerMonitor.Update_UPS_Ratings : Boolean;
begin
  Result := Send_UPS_Command(Upd_Ratings,'',71, False);
end; // TTrippLiteUSBPowerMonitor.Update_UPS_Ratings

procedure TTrippLiteSerialPowerMonitor.ProcessUPSInputs(Response : String);
var
  Returned_Cmd : TTLCmd_String;
  i : LongInt;
begin
  if (Length(Response) >= 7) then
  begin
    for i := 1 to 7 do
      Returned_Cmd[i] := Response[i];
    if Valid_Response(Returned_Cmd) and (Length(Response) = 17) then
    begin
      ParseInputStatus(Response);
      FCmdProcessed[Upd_Input] := True;
    end
    else
    begin
      if Assigned(FOnSerialPortError) then
        FOnSerialPortError(Self,'Response from UPS garbbled, unable to update Input Status.');
    end; // If
  end; // If
end; // TTrippLiteSerialPowerMonitor.ProcessUPSInputs

function TTrippLiteSerialPowerMonitor.Update_UPS_Inputs : Boolean;
begin
  Result := Send_UPS_Command(Upd_Input,'',17,False);
end; // TTrippLiteUSBPowerMonitor.Update_UPS_Inputs

procedure TTrippLiteSerialPowerMonitor.ProcessUPSOutputs(Response : String);
var
  Returned_Cmd : TTLCmd_String;
  i : LongInt;
begin
  if (Length(Response) >= 7) then
  begin
    for i := 1 to 7 do
      Returned_Cmd[i] := Response[i];
    if Valid_Response(Returned_Cmd) and (Length(Response) = 33) then
    begin
      ParseOutputStatus(Response);
      FCmdProcessed[Upd_Output] := True;
    end
    else
    begin
      if Assigned(FOnSerialPortError) then
        FOnSerialPortError(Self,'Response from UPS garbbled, unable to update Output Status.');
    end; // If
  end; // If
end; // TTrippLiteSerialPowerMonitor.ProcessUPSInputs

function TTrippLiteSerialPowerMonitor.Update_UPS_Outputs : Boolean;
begin
  Result := Send_UPS_Command(Upd_Output,'',33,False);
end; // TTrippLiteUSBPowerMonitor.Update_UPS_Outputs

procedure TTrippLiteSerialPowerMonitor.ProcessUPSBattery(Response : String);
var
  Returned_Cmd : TTLCmd_String;
  i : LongInt;
begin
  if (Length(Response) >= 7) then
  begin
    for i := 1 to 7 do
      Returned_Cmd[i] := Response[i];
    if Valid_Response(Returned_Cmd) and (Length(Response) = 41) then
    begin
      ParseBatteryStatus(Response);
      FCmdProcessed[Upd_Battery] := True;
    end
    else
    begin
      if Assigned(FOnSerialPortError) then
        FOnSerialPortError(Self,'Response from UPS garbbled, unable to update Battery Status.');
    end; // If
  end; // If
end; // TTrippLiteSerialPowerMonitor.ProcessUPSBattery

function TTrippLiteSerialPowerMonitor.ShutdownAction(DelaySeconds : DWord) : Boolean;
var
  TmpDelay : String;
begin
  if (DelaySeconds > 9999) then
    DelaySeconds := 9999; // Max
  TmpDelay := format('SDA%d',[DelaySeconds]);
  if Not FCmdProcessed[FSentCommand] then
  begin
    repeat
      Delay(1); // Wait for current command to finish or until the component is disabled...
    until Not FWaitingForResponse or Not FEnabled;
  end; // If
  Result := Send_UPS_Command(Set_ShutdownAction,TmpDelay,4,False);
end; // TTrippLiteSerialPowerMonitor.Set_ShutdownAction

function TTrippLiteSerialPowerMonitor.ShutdownRestart(DelayMinutes : DWord) : Boolean;
var
  TmpDelay : String;
begin
  if (DelayMinutes > 65535) then
    DelayMinutes := 65535;
  TmpDelay := format('SDR%d',[DelayMinutes]);
  if Not FCmdProcessed[FSentCommand] then
  begin
    repeat
      Delay(1); // Wait for current command to finish or until the component is disabled...
    until Not FWaitingForResponse or Not FEnabled;
  end; // If
  Result := Send_UPS_Command(Set_ShuntDownRestart,TmpDelay,4,False);
end; // TTrippLiteSerialPowerMonitor.ShutdownRestart

function TTrippLiteSerialPowerMonitor.ShutdownType(SDType : TAction) : Boolean;
begin
  if Not FCmdProcessed[FSentCommand] then
  begin
    repeat
      Delay(1); // Wait for current command to finish or until the component is disabled...
    until Not FWaitingForResponse or Not FEnabled;
  end; // If
  Result := Send_UPS_Command(Set_ShutdownType,format('SDT%d',[(Ord(SDType) + 1)]),4,False)
end; // TTrippLiteSerialPowerMonitor.ShutdownType

function TTrippLiteSerialPowerMonitor.TestUPS(Abort : Boolean) : Boolean;
var
  Param : Byte;
  PrevTimeOut : DWord;
begin
  if Abort then
    Param := 0 // Abort
  else
    Param := 3; // Perform Test
  PrevTimeOut := FSerialPortPacket.TimeOut; // Save current TimeOut
  FSerialPortPacket.TimeOut := 200; // ~11 seconds
  if Not FCmdProcessed[FSentCommand] then
  begin
    repeat
      Delay(1); // Wait for current command to finish or until the component is disabled...
    until Not FWaitingForResponse or Not FEnabled;
  end; // If
  FtmrSendCommand.Enabled := False; // Disable automatic updating of status commands...
  Result := Send_UPS_Command(Set_Test,format('TST%d',[Param]),4,False);
  FSerialPortPacket.TimeOut := PrevTimeOut;
  FtmrSendCommand.Enabled := FEnabled;
end; // TTrippLiteSerialPowerMonitor.TestUPS

function TTrippLiteSerialPowerMonitor.Update_UPS_Battery : Boolean;
begin
  Result := Send_UPS_Command(Upd_Battery,'',41,False);
end; // TTrippLiteUSBPowerMonitor.Update_UPS_Battery

procedure TTrippLiteSerialPowerMonitor.ParseRatings(RatingsString : ShortString);
var
  UPSRatings : TUPSRatings;
  strRatingsArray : Array[0..16] of ShortString;
  i : LongInt;
  j : LongInt;
  strData : ShortString;
  strTemp : ShortString;
  StartCopy : LongInt;
begin
  FillChar(UPSRatings,SizeOf(UPSRatings),#0);
  StartCopy := 8;
  strData := RatingsString + ';';
  for i := Low(strRatingsArray) to High(strRatingsArray) do
  begin
    strTemp := '';
    for j := StartCopy to Length(strData) do
    begin
      if (strData[j] = ';') or (j = Length(strData)) then
      begin
        strTemp := Copy(strData,StartCopy,(j - StartCopy));
        StartCopy := (j + 1);
        strRatingsArray[i] := strTemp;
        Break;
      end; // If
    end; // For j
  end; // For i
  with UPSRatings do
  begin
    RatedInputVoltage       := StrToFloat(strRatingsArray[0]);
    RatedInputFrequencey    := StrToFloat(strRatingsArray[1]) / 10;
    RatedOutputVoltage      := StrToFloat(strRatingsArray[2]);
    RatedOutputFrequencey   := StrToFloat(strRatingsArray[3]) / 10;
    RatedVA                 := StrToFloat(strRatingsArray[4]);
    RatedOutputPower        := StrToFloat(strRatingsArray[5]);
    LowTxVoltagePoint       := StrToFloat(strRatingsArray[7]);
    HighTxVoltagePoint      := StrToFloat(strRatingsArray[8]);
    LowTxVoltageUpperBound  := StrToFloat(strRatingsArray[9]);
    LowTxVoltageLowerBound  := StrToFloat(strRatingsArray[10]);
    HighTxVoltageUpperBound := StrToFloat(strRatingsArray[11]);
    HighTxVoltageLowerBound := StrToFloat(strRatingsArray[12]);
    UPSType                 := StrToInt(strRatingsArray[13]);
    RatedBatteryVoltage     := StrToFloat(strRatingsArray[14]);
    LowTxFrequencyPoint     := StrToFloat(strRatingsArray[15]) / 10;
    HighTxFrequencyPoint    := StrToFloat(strRatingsArray[16]) / 10;
  end; // With
  DoSendUPSRatings(UPSRatings);
end; // TTrippLiteUSBPowerMonitor.ParseRatings

procedure TTrippLiteSerialPowerMonitor.ParseInputStatus(InputString : ShortString);
var
  UPSInputStatus : TUPSInputStatus;
  strInputStatusArray : Array[0..2] of ShortString;
  i : LongInt;
  j : LongInt;
  strData : ShortString;
  strTemp : ShortString;
  StartCopy : LongInt;
begin
  FillChar(UPSInputStatus,SizeOf(UPSInputStatus),#0);
  StartCopy := 8;
  strData := InputString + ';';
  for i := Low(strInputStatusArray) to High(strInputStatusArray) do
  begin
    strTemp := '';
    for j := StartCopy to Length(strData) do
    begin
      if (strData[j] = ';') or (j = Length(strData)) then
      begin
        strTemp := Copy(strData,StartCopy,(j - StartCopy));
        StartCopy := (j + 1);
        strInputStatusArray[i] := strTemp;
        Break;
      end; // If
    end; // For j
  end; // For i
  with UPSInputStatus do
  begin
    InputLineCount := StrToInt(strInputStatusArray[0]);
    InputFrequency := StrToFloat(strInputStatusArray[1]) / 10;
    InputVoltage   := StrToFloat(strInputStatusArray[2]) / 10;
  end; // with
  DoSendUPSInputStatus(UPSInputStatus);
end; // TTrippLiteUSBPowerMonitor.ParseInputStatus

procedure TTrippLiteSerialPowerMonitor.ParseOutputStatus(OutputString : ShortString);
var
  UPSOutputStatus : TUPSOutputStatus;
  strOutputStatusArray : Array[0..6] of ShortString;
  i : LongInt;
  j : LongInt;
  strData : ShortString;
  strTemp : ShortString;
  StartCopy : LongInt;
begin
  FillChar(UPSOutputStatus,SizeOf(UPSOutputStatus),#0);
  StartCopy := 8;
  strData := OutputString + ';';
  for i := Low(strOutputStatusArray) to High(strOutputStatusArray) do
  begin
    strTemp := '';
    for j := StartCopy to Length(strData) do
    begin
      if (strData[j] = ';') or (j = Length(strData)) then
      begin
        strTemp := Copy(strData,StartCopy,(j - StartCopy));
        StartCopy := (j + 1);
        strOutputStatusArray[i] := strTemp;
        Break;
      end; // If
    end; // If
  end; // For i
  with UPSOutputStatus do
  begin
    OutputSource      := StrToInt(strOutputStatusArray[0]);
    OutputFrequency   := StrToFloat(strOutputStatusArray[1]) / 10;
    OutputLineCount   := StrToInt(strOutputStatusArray[2]);
    OutputVoltage     := StrToFloat(strOutputStatusArray[3]) / 10;
    OutputCurrent     := StrToFloat(strOutputStatusArray[4]) / 10;
    OutputPower       := StrToFloat(strOutputStatusArray[5]);
    OutputLoadPercent := StrToFloat(strOutputStatusArray[6]);
  end; // With
  DoSendUPSOutputStatus(UPSOutputStatus);
end; // TTrippLiteUSBPowerMonitor.ParseOutputStatus

procedure TTrippLiteSerialPowerMonitor.ParseBatteryStatus(BatteryString : ShortString);
var
  UPSBatteryStatus : TUPSBatteryStatus;
  strBatteryStatusArray : Array[0..9] of ShortString;
  i : LongInt;
  j : LongInt;
  strData : ShortString;
  strTemp : ShortString;
  StartCopy : LongInt;
begin
  FillChar(UPSBatteryStatus,SizeOf(UPSBatteryStatus),#0);
  StartCopy := 8;
  strData := BatteryString + ';';
  for i := Low(strBatteryStatusArray) to High(strBatteryStatusArray) do
  begin
    strTemp := '';
    for j := StartCopy to Length(strData) do
    begin
      if (strData[j] = ';') or (j = Length(strData)) then
      begin
        strTemp := Copy(strData,StartCopy,(j - StartCopy));
        StartCopy := (j + 1);
        strBatteryStatusArray[i] := strTemp;
        Break;
      end; // If
    end; // If
  end; // For i
  with  UPSBatteryStatus do
  begin
    BatteryCondition           := StrToInt(strBatteryStatusArray[0]);
    BatteryStatus              := StrToInt(strBatteryStatusArray[1]);
    BatteryCharge              := StrToInt(strBatteryStatusArray[2]);
    SecondsOnBattery           := StrToFloat(strBatteryStatusArray[3]);
    EstimatedMinutesRemaining  := StrToInt(strBatteryStatusArray[4]);
    EstimatedPercentChargeUsed := StrToInt(strBatteryStatusArray[5]);
    BatteryVoltage             := StrToInt(strBatteryStatusArray[6]) / 10;
    TemperatureCelsius         := StrToFloat(strBatteryStatusArray[8]);
    BatteryLevelPercent        := StrToInt(strBatteryStatusArray[9]);
  end; // With
  DoSendUPSBatteryStatus(UPSBatteryStatus);
end; // TTrippLiteSerialPowerMonitor.ParseBatteryStatus

function TTrippLiteSerialPowerMonitor.NextCommandToSend : TTLCmds;
var
  CMD : TTLCmds;
  TmpRslt : TTLCmds;
begin
  TmpRslt := Upd_NONE;
  for CMD := Upd_Ratings to Upd_Battery do
  begin
    if FPollStatus[CMD] and (FSentCommand < CMD) then
    begin
      TmpRslt := CMD;
      Break;
    end; // If
  end; // For CMD
  if (TmpRslt = Upd_None) then
  begin
    FSentCommand := Upd_NONE;
    for CMD := Upd_Ratings to Upd_Battery do
    begin
      if FPollStatus[CMD] and (FSentCommand < CMD) then
      begin
        TmpRslt := CMD;
        Break;
      end; // If
    end; // For CMD
  end; // If
  Result := TmpRslt;
end; // TTrippLiteSerialPowerMonitor.NextCommandToSend

procedure TTrippLiteSerialPowerMonitor.SetComNumber(Value : LongInt);
begin
  FComNumber := Value;
  if Not (csDesigning in ComponentState) then
  begin
    if Assigned(FSerialPort) then
    begin
      FtmrSendCommand.Enabled := False;
      try
        if FSerialPort.Open then
          FSerialPort.Open := False;
        FSerialPort.ComNumber := FComNumber;
      except
        On EBadID do
        begin
          if Assigned(FOnSerialPortError) then
            FOnSerialPortError(Self,'Invalid COM port number.');
        end;
      end; // Try
      FtmrSendCommand.Enabled := FEnabled;
    end; // If
  end; // If
end; // TTrippLiteUSBPowerMonitor.SetComNumber;

procedure TTrippLiteSerialPowerMonitor.SetSerialPollingInterval(Value : LongInt);
begin
  FSerialPollingInterval := Value;
  if Assigned(FtmrSendCommand) then
    FtmrSendCommand.Interval := FSerialPollingInterval;
end; // TTrippLiteUSBPowerMonitor.SetSerialPollingInterval

procedure TTrippLiteSerialPowerMonitor.SetCommsTimeOutPeriod(Value : LongInt);
var
  Temp : LongInt;
begin
  FCommsTimeOutPeriod := Value;
  if Not (csDesigning in ComponentState) then
  begin
    FtmrCommsWatchDog.Interval := FCommsTimeOutPeriod + 2000{ms};
    Temp := Round(0.0182{ticks per ms} * FCommsTimeOutPeriod);
    if (Temp < 1) then
      Temp := 1;
    FSerialPortPacket.TimeOut := Temp;
  end; // If
end; // TTrippLiteUSBPowerMonitor.SetCommsTimerOutPeriod

procedure TTrippLiteSerialPowerMonitor.SetEnabled(Value : Boolean);
begin
  inherited SetEnabled(Value);
  if Not (csDesigning in ComponentState) then
  begin
    TmrPowerStatus.Enabled := Value and Not FUseSerialComms;
    if (Value and FUseSerialComms) then
    begin
      FtmrSendCommand.Interval := FSerialPollingInterval;
      FtmrSendCommand.Enabled := InitializeComPort;
      if TestComms then
        FtmrSendCommand.Enabled := True
      else
      begin
        if Assigned(FOnSerialPortError) then
          FOnSerialPortError(Self,'Communications Test Failed.');
      end; // If
    end
    else
      FtmrSendCommand.Enabled := False;
  end; // If
end; // TTrippLiteSerialPowerMonitor.SetEnabled

function TTrippLiteSerialPowerMonitor.GetCommsPassed : Boolean;
begin
  Result := TestComms;
end; // TTrippLiteSerialPowerMonitor.GetComssPassed

procedure TTrippLiteSerialPowerMonitor.SetSerialPort(SerialPort : TApdComPort);
begin
  FSerialPort := SerialPort;
end; // TTrippLiteSerialPowerMonitor.SetSerialPort

procedure TTrippLiteSerialPowerMonitor.SetBaudRate(Value : LongInt);
begin
  FBaudRate := Value;
  if Not (csDesigning in ComponentState) then
  begin
    if Assigned(FSerialPort) then
      FSerialPort.Baud := FBaudRate;
  end; // If
end; // TTrippLiteUSBPowerMonitor.SetBaudRate

procedure TTrippLiteSerialPowerMonitor.SetParity(Value : TParity);
begin
  FParity := Value;
  if Not (csDesigning in ComponentState) then
  begin
    if Assigned(FSerialPort) then
      FSerialPort.Parity := FParity;
  end; // If
end; // TTrippLiteUSBPowerMonitor.SetParity

procedure TTrippLiteSerialPowerMonitor.SetStopBits(Value : LongInt);
begin
  FStopBits := Value;
  if Not (csDesigning in ComponentState) then
  begin
    if Assigned(FSerialPort) then
      FSerialPort.StopBits := FStopBits;
  end; // If
end; // TTrippLiteUSBPowerMonitor.SetStopBits

procedure TTrippLiteSerialPowerMonitor.SetDataBits(Value : LongInt);
begin
  FDataBits := Value;
  if Not (csDesigning in ComponentState) then
  begin
    if Assigned(FSerialPort) then
      FSerialPort.DataBits := FDataBits;
  end; // If
end; // TTrippLiteUSBPowerMonitor.SetDataBits

function TTrippLiteSerialPowerMonitor.LookUpUPSOutputSource(OutputSource : LongInt) : ShortString;
begin
  case OutputSource of
    0 : Result := 'Normal';
    1 : Result := 'Battery';
    2 : Result := 'Bypass(Reserve)';
    3 : Result := 'Reducing';
    4 : Result := 'Boosting';
    5 : Result := 'Manual Bypass';
    6 : Result := 'Other';
    7 : Result := 'None';
  end; // Case
end; // TTrippLiteUSBPowerMonitor.LookUpUPSOutputSource

function TTrippLiteSerialPowerMonitor.LookUpUPSBatteryCharge(BatteryCharge : LongInt) : ShortString;
begin
  case BatteryCharge of
    0 : Result := 'Floating';
    1 : Result := 'Charging';
    2 : Result := 'Resting';
    3 : Result := 'Discharging';
  end; // Case
end; // TTrippLitePowerMontior.LookUpUPSBatteryCharge

function TTrippLiteSerialPowerMonitor.LookUpUPSBatteryStatus(BatteryStatus : LongInt) : ShortString;
begin
  case BatteryStatus of
    0 : Result := 'OK';
    1 : Result := 'Low';
    2 : Result := 'Depleted';
  end; // Case
end; // TTrippLitePowerMontior.LookUpUPSBatteryStatus

function TTrippLiteSerialPowerMonitor.LookUpUPSBatteryCondition(BatteryCondition : LongInt) : ShortString;
begin
  case BatteryCondition of
    0 : Result := 'Good';
    1 : Result := 'Weak';
    2 : Result := 'Replace';
  end; // Case
end; // TTrippLiteUSBPowerMonitor.LookUpUPSBatteryCondition

function TTrippLiteSerialPowerMonitor.LookUpUPSType(UPSType : LongInt) : ShortString;
begin
  case UPSType of
    0 : Result := 'On-Line';
    1 : Result := 'Off-Line';
    2 : Result := 'Line-Interactive';
    3 : Result := '3 Phase';
    4 : Result := 'Others';
  end; // Case
end; // TTrippLiteUSBPowerMonitor.LookUpUPSType

constructor TTrippLiteUSBPowerMonitor.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FCurrACCode := 255;
  FCurrBattCode := 100;
  FCurrBattPercentCode :=150;
  FCurrBattLifeCode := -1;
  FCurrBattFullLifeCode := -1;
  FBatteryState := -1;
  FTimerTrigger := 10000;
  FVersion := '1.5.1';
  FEnabled := False;
  TmrPowerStatus := Nil;
  with FPowerState do
  begin
     BatteryFlag := '';
     BatteryLifePercent := 100;
     ACLineStatus := 'UPS Monitoring is OFF!!';
     BatteryLifeTime := '';
     BatteryFullLifeTime := '';
     BatteryFlagCode := 1;
     BatteryLifePercentCode := 100;
     ACLineStatusCode := 1;
     BatteryLifeTimeCode := -1;
     BatteryFullLifeTimeCode := -1;
  end; // with
  if not (csDesigning in ComponentState) then
  begin
     TmrPowerStatus := TTimer.Create(nil);
     TmrPowerStatus.Enabled := False;
     TmrPowerStatus.OnTimer := MyTimerEvent;
     TmrPowerStatus.Interval := FTimerTrigger;
  end; // If
end; // TTrippLiteUSBPowerMonitor.Create

destructor TTrippLiteUSBPowerMonitor.Destroy;
begin
  if Assigned(TmrPowerStatus) then
  begin
     TmrPowerStatus.Enabled := False;
     TmrPowerStatus.Free;
  end; // IF
  TmrPowerStatus := nil;
  inherited Destroy;
end; // TTrippLiteUSBPowerMonitor.Destroy

procedure TTrippLiteUSBPowerMonitor.MyTimerEvent;
var
   FCurrentPowerStates : TSystemPowerStatus;

  Procedure GetPowerState;
  begin
    GetSystemPowerStatus(FCurrentPowerStates);
    FPowerState.BatteryFlag := GetBatteryState( FCurrentPowerStates.BatteryFlag );
    FPowerState.BatteryLifePercent := GetBatteryLifePercent( FCurrentPowerStates.BatteryLifePercent );
    FPowerState.ACLineStatus := GetACLineStatus( FCurrentPowerStates.ACLineStatus );
    FPowerState.BatteryLifeTime := GetBatteryLifeTime( FCurrentPowerStates.BatteryLifeTime );
    FPowerState.BatteryFullLifeTime := GetBatteryFullLifeTime( FCurrentPowerStates.BatteryFullLifeTime );
    FPowerState.BatteryFlagCode := FCurrentPowerStates.BatteryFlag;
    FPowerState.BatteryLifePercentCode := FCurrentPowerStates.BatteryLifePercent;
    FPowerState.ACLineStatusCode := FCurrentPowerStates.ACLineStatus;
    FPowerState.BatteryLifeTimeCode := FCurrentPowerStates.BatteryLifeTime;
    FPowerState.BatteryFullLifeTimeCode := FCurrentPowerStates.BatteryFullLifeTime;
  end; // Get Power State

  Procedure FireEvents;
  begin
    if FCurrACCode <> FPowerState.ACLineStatusCode then
    begin
       if assigned(FOnACStatus) then
         FOnACStatus(Self, FPowerState.ACLineStatus, FCurrentPowerStates.ACLineStatus);
    end; // IF
    if FCurrBattCode <> FPowerState.BatteryFlagCode then
    begin
       if assigned(FOnBattStatus) then
         FOnBattStatus(self,FPowerState.BatteryFlag,FCurrentPowerStates.BatteryFlag);
    end; // IF
    if FCurrBattPercentCode <> FPowerState.BatteryLifePercentCode then
    begin
       if assigned(FOnBattLifePercent) then
         FOnBattLifePercent(self,FPowerState.BatteryLifePercent,FCurrentPowerStates.BatteryLifePercent);
    end; // IF
    if FCurrBattLifeCode <> FPowerState.BatteryLifeTimeCode then
    begin
       if assigned(FOnBattLifeTime) then
         FOnBattLifeTime(self,FPowerState.BatteryLifeTime,FCurrentPowerStates.BatteryLifeTime);
    end; // IF
    if FCurrBattFullLifeCode <> FPowerState.BatteryFullLifeTimeCode then
    begin
       if assigned(FOnBattFullLifeTime) then
         FOnBattFullLifeTime(self,FPowerState.BatteryFullLifeTime,FCurrentPowerStates.BatteryFullLifeTime);
    end; // IF
    if FCurrBattPercentCode < FWarnBatteryLevel then
    begin
       If assigned(FOnLowBatteryWarning) then
         FOnLowBatteryWarning(self,FPowerState.BatteryLifeTime,FCurrentPowerStates.BatteryLifePercent);
    end; // IF
  end; // Fire Events

begin
  if assigned(TmrPowerStatus) then
    TmrPowerStatus.Enabled := False;
  GetPowerState;
  FireEvents;
  if assigned(FTimeEvent) then
    FTimeEvent(Self);
  if FCurrBattFullLifeCode <> FPowerState.BatteryFullLifeTimeCode then
     FCurrBAttFullLifeCode := FPowerState.BatteryFullLifeTimeCode;
  if FCurrBattLifeCode <> FPowerState.BatteryLifeTimeCode then
     FCurrBAttLifeCode := FPowerState.BatteryLifeTimeCode;
  if FCurrBattPercentCode <> FPowerState.BatteryLifePercentCode then
     FCurrBattPercentCode := FPowerState.BatteryLifePercentCode;
  if FCurrBattCode <> FPowerState.BatteryFlagCode then
     FCurrBattCode := FPowerState.BatteryFlagCode;
  if FCurrACCode <> FPowerState.ACLineStatusCode then
     FCurrACCode := FPowerState.ACLineStatusCode;
  if (FEnabled <> False) and assigned(TmrPowerStatus) then
     TmrPowerStatus.Enabled := True;
end; // TTrippLiteUSBPowerMonitor.MyTimerEvent

Procedure TTrippLiteUSBPowerMonitor.SetVersion(Value : ShortString);
begin
  // Do nothing....
end; // TPowerMonitor.SetVersion

procedure TTrippLiteUSBPowerMonitor.Initialize;
begin
  with FPowerState do
  begin
    BatteryFlag := '';
    BatteryFlagCode := -1;
    BatteryLifeTime := '';
    BatteryLifeTimeCode := -1;
    BatteryLifePercent := 0;
    BatteryLifePercentCode := -1;
    BatteryFullLifeTime := '';
    BatteryFullLifeTimeCode := 0;
    ACLineStatus := '';
    ACLineStatusCode := -1;
  end; //with
  FCurrACCode := 255;
  FCurrBattCode := 100;
  FCurrBattPercentCode := 150;
  FCurrBattLifeCode := 255;
  FCurrBattFullLifeCode := 255;
  if Not FEnabled then
  begin
    if Assigned(FOnACStatus) then
      FOnACStatus(Self,'UPS Monitoring OFF', 1);
    if Assigned(FOnBattStatus) then
      FOnBattStatus(Self,'UPS Monitoring OFF', 1);
    if Assigned(FOnBattLifePercent) then
      FOnBattLifePercent(Self,100,0);
    if Assigned(FOnBattLifeTime) then
      FOnBattLifeTime(Self,'0',0);
    if Assigned(FOnBattFullLifeTime) then
      FOnBattFullLifeTime(Self,'0',0);
    if Assigned(FOnLowBatteryWarning) then
      FOnLowBatteryWarning(Self,'UPS Monitoring OFF', -1);
  end; // If
end; // TTrippLiteUSBPowerMonitor.Initialize

procedure TTrippLiteUSBPowerMonitor.SetEnabled( EnableMe : Boolean );
begin
  FEnabled := EnableMe;
  if Not (csDesigning in ComponentState) then
  begin
    Initialize;
    TmrPowerStatus.Enabled := FEnabled;
  end; // If
end; // TTrippLiteUSBPowerMonitor.SetEnabled

Function TTrippLiteUSBPowerMonitor.GetBatteryFullLifeTime( BattFullLifeTime : LongInt ): ShortString;
begin
   Result := IntToStr(BattFullLifeTime);
end; //  TTrippLiteUSBPowerMonitor.GetBatteryFullLifeTime;

Function TTrippLiteUSBPowerMonitor.GetBatteryLifeTime( BattLifeTime : LongInt ) : ShortString;
begin
   Result := IntToStr(BattLifeTime);
end; //  TTrippLiteUSBPowerMonitor.GetBatteryLifeTime

Function TTrippLiteUSBPowerMonitor.GetBatteryLifePercent( BattLifePercent : Byte ) : LongInt;
var
   V : LongInt;
begin
   case BattLifePercent of
      0..100 : V := BattLifePercent;
   else
      V := -1; // Unknow Battery Level
   end; // CASE
   Result := V;
end; // TTrippLiteUSBPowerMonitor.GetBatteryLifePercent;

Function TTrippLiteUSBPowerMonitor.GetBatteryState( BattValue : Byte ) : ShortString;
var
   V : ShortString;
begin
   case BattValue of
      0 :  begin
             // Do Nothing
           end; // 0
      1 :  V := 'Battery Level is HIGH';
      2 :  V := 'Battery Level is LOW';
      4 :  V := 'Battery Level is CRITICAL';
      8,9 :  V := 'Battery is CHARGING';
      100 : V := 'UPS Monitoring OFF';
      128 : V := 'NO SYSTEM BATTERY';
      255 : V := 'BATTERY STATUS IS UNKNOWN';
   else
      V := 'BATTERY STATE UNRECOGNIZED'
   end; // CASE
   Result := V;
end; // TTrippLiteUSBPowerMonitor.GetBatteryState

Function TTrippLiteUSBPowerMonitor.GetACLineStatus( ACValue : Byte ) : ShortString;
var
   V : ShortString;
begin
   case ACValue of
      0 : V := 'AC Power is OFFLINE';
      1 : V := 'AC Power is ONLINE';
      255 : V := 'AC POWER SATUS IS UNKNOWN';
   else
      V := 'UNKNOWN STATUS INDICATOR';
   end; // CASE
   Result := V;
end; // TTrippLiteUSBPowerMonitor.GetACLineStatus

procedure TTrippLiteUSBPowerMonitor.SetWarnBatteryLevel( WarnLevel : LongInt );
begin
   if WarnLevel > 0 then
     FWarnBatteryLevel := WarnLevel;
end; // TTrippLiteUSBPowerMonitor.SetWarnBatteryLevel

procedure TTrippLiteUSBPowerMonitor.SetTimerInterval( Interval : LongInt );
begin
   if Interval > 0 then
      FTimerTrigger := Interval;
   if assigned(TmrPowerStatus) then
      TmrPowerStatus.Interval := FTimerTrigger;
end; // TTrippLiteUSBPowerMonitor.SetTimerInterval

end.
