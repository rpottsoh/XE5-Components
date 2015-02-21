unit Sensotec_Commands;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  AdPacket, OoMisc, AdPort, ExtCtrls, TMSIDataTypes;

const
  SysUnits : Array[0..4] of String = ('LBS','KG','N','PSI','UNKN');
  SysBaudRate : Array[0..5] of Integer = (9600,4800,2400,1200,600,300);
  SystemFucntionCommands : Array[0..2] of String = ('F0','FI','FL');
  SystemWriteCommands    : Array[0..9] of String = ('W1','W2','W4','W9','WA','WB','WC','WI','WL','WS');
  SystemReadCommands     : Array[0..6] of String = ('R9','RA','RB','RC','RL','RR','RS');

  StrainGuageFunctionCommands : Array[0..4] of String = ('F1','F2','F3','F5','FE');
  StrainGuageWriteCommands    : Array[0..10] of String = ('W5','W6','W7','W8','WK','WM','WN','WO','WP','WQ','WU');
  StrainGuageReadCommands     : Array[0..10] of String = ('R5','R6','R7','R8','RK','RM','RN','RO','RP','RQ','RU');

type
// Example command format #0002W21.2^
// #   => Wake unit(s), Units go into "Recieve Mode"
// 00  => Unit Address
// 02  => 2 Charactor channel command
// W2  => 2 Charactor command Code
// 1.2 => Optional information field needed by commands that write data to the unit. Information field can include upto 15 ASCII charators.
// ^   => Represents  the carriage return, end of command

  TSysUnits = (LBS,KG,N,PSI,UNKN);
  TSysBaudRate = (B9600,B4800,B2400,B1200,B600,B300);
  TSysEnumFunctionCommands = (F0,FI,FL);
  TSysEnumWriteCommands   = (W1,W2,W4,W9,WA,WB,WC,WI,WL,WS);
  TSysEnumReadCommands    = (R9,RA,RB,RC,RL,RR,RS);
  TSys_Channels = Byte;

  TSGEnumFunctionCommands = (F1,F2,F3,F5,FE);
  TSGEnumWriteCommands    = (W5,W6,W7,W8,WK,WM,WN,WO,WP,WQ,WU);
  TSGEnumReadCommands     = (R5,R6,R7,R8,RK,RM,RN,RO,RP,RQ,RU);
  TSG_LoadPt = (Pt1,Mid,Pt2);

  TCmd_Result = (OK,Error,NA,FloatData,ASCIIData,TimedOut);
  TCmd_Status = (CommandSent,CommandError,InvalidCommand,TimeOut,CommandCompleted);
  TUnitAddress = String[2];
  TOptional_Write = String[15];
  TOptional_Read = TOptional_Write;

  TContinousTransmitData = procedure(Sender : TObject; New_Data : ShortString) of Object;
  TCommandFailed = procedure(Sender : TObject; ErrorMsg : String; Reason : TCmd_Status) of Object;

  TSensotec_Interface = class(TComponent)
  private
    { Private declarations }
    FSerialPort1: TApdComPort;
    FSerialPortPacket1: TApdDataPacket;
    FOnNewContinousTransmitData : TContinousTransmitData;
    FOnCommandFailed : TCommandFailed;
    FPacketTimeOut : Boolean;
    FPacketData : ShortString;
    FUnitComNumber : LongInt;
    FUnitBaudRate : TSysBaudRate;
    FUnitAddress : String;
    FUnitLineFeed : Boolean;
    FUnitContinuousTransmit : Boolean;
    FUnitTare : Boolean;
    FUnitClearTare : Boolean;
    FSysUnits : TSysUnits;
    FUnitSGChannel : TSys_Channels;
    FUnitConnected : Boolean;
    FUnitDisconnected : Boolean;
    function Send_Sys_Func_Cmd(UnitAddress : TUnitAddress; CommandCode : TSysEnumFunctionCommands;
      WCommand : TOptional_Write; Var CommandResult : TCmd_Result; Var RecievedData : ShortString) : TCmd_Status;
    function Send_Sys_Write_Cmd(UnitAddress : TUnitAddress; CommandCode : TSysEnumWriteCommands;
      WCommand : TOptional_Write; Var CommandResult : TCmd_Result; Var RecievedData : ShortString) : TCmd_Status;
    function Send_Sys_Read_Cmd(UnitAddress : TUnitAddress; CommandCode : TSysEnumReadCommands;
      Var CommandResult : TCmd_Result; Var RecievedData : ShortString) : TCmd_Status;
    function Send_SG_Func_Cmd(UnitAddress : TUnitAddress; Channel : TSys_Channels; CommandCode : TSGEnumFunctionCommands;
      WCommand : TOptional_Write; Var CommandResult : TCmd_Result; Var RecievedData : ShortString) : TCmd_Status;
    function Send_SG_Write_Cmd(UnitAddress : TUnitAddress; Channel : TSys_Channels; CommandCode : TSGEnumWriteCommands;
      WCommand : TOptional_Write; Var CommandResult : TCmd_Result; Var RecievedData : ShortString) : TCmd_Status;
    function Send_SG_Read_Cmd(UnitAddress : TUnitAddress; Channel : TSys_Channels; CommandCode : TSGEnumReadCommands;
      RCommand : TOptional_Read; Var CommandResult : TCmd_Result; Var RecievedData : ShortString) : TCmd_Status;
    procedure SerialPortPacket1Packet(Sender: TObject; Data: Pointer;
      Size: Integer);
    procedure SerialPortPacket_ContinousTransmit(Sender: TObject; Data: Pointer;
      Size: Integer);
    procedure SerialPortPacket1Timeout(Sender: TObject);
    // Component Utility procedures/functions
    function PadChannel(NumToPad : LongInt) : String;
    procedure Delay(WaitTimeMs : LongInt);
    function IsNumeric(Value : String) : Boolean;
    function RemoveUnitsFromStr(Value : String) : String;
    function Screen_Packet(Value : String) : TCmd_Result;
    function InitializeComPort : Boolean;
    procedure CloseComPort;
    function Send_Cmd(UnitCommand : String; Var DataStr : ShortString) : TCmd_Result;
    function Packet_ContinuousTransfer(Unit_Address : String) : Boolean;
    function Packet_NormalTransfer(Unit_Address : String) : Boolean;
    // Communications Setup
    procedure PortNumber(ComPort : LongInt);
    procedure BaudRate(Baud : LongInt);
    // System Commands
    function Unit_Contact(ComPort : LongInt; Baud : LongInt; Unit_Address : TUnitAddress) : Boolean;
    function Unit_Disconnect(Unit_Address : TUnitAddress) : Boolean;
    function Unit_BaudRate(Unit_Address : TUnitAddress; BaudRate : TSysBaudRate) : Boolean;
    function Unit_LineFeed(Unit_Address : TUnitAddress; LN_On : Boolean) : Boolean;
    function Unit_ChangeAddress(Curr_Address, New_Address : TUnitAddress) : Boolean;
    function Unit_GetDisplayValueFloat(Unit_Address : TUnitAddress; ReturnUnits : TSysUnits) : Double;
    function Unit_GetDisplayValueString(Unit_Address : TUnitAddress) : String;
    function Unit_SWRevision(Unit_Address : TUnitAddress) : String;
    function Unit_DisplayText(Unit_Address : TUnitAddress; TextToDisplay : ShortString) : Boolean;
    function Unit_ContinuousTransmit(Unit_Address : TUnitAddress; CT_On : Boolean; Unit_CT_Active : Boolean) : Boolean;
    function Unit_AlreadyTransmitting(Unit_Address : TUnitAddress) : Boolean;
    // Channel Commnads
    function Unit_Tare(Unit_Address : TUnitAddress; ChannelToTare : TSys_Channels) : Boolean;
    function Unit_ClearTare(Unit_Address : TUnitAddress; ChannelToClear : TSys_Channels) : Boolean;
    function Unit_ShuntCal(Unit_Address : TUnitAddress; ChannelToShunt : TSys_Channels) : Double;
    function Unit_GetEngineeringUnits(Unit_Address : TUnitAddress; Channel : TSys_Channels; Var EngUnits : TSysUnits) : Boolean;
    function Unit_SetEngineeringUnits(Unit_Address : TUnitAddress; Channel : TSys_Channels; EngUnits : TSysUnits) : Boolean;
    function Unit_GetTransducerSN(Unit_Address : TUnitAddress; Channel : TSys_Channels; Var SN : ShortString) : Boolean;
    function Unit_SetEUFullScale(Unit_Address : TUnitAddress; Channel : TSys_Channels; FSValue : Double) : Boolean;
    function Unit_GetEUFullScale(Unit_Address : TUnitAddress; Channel : TSys_Channels; Var FSValue : Double) : Boolean;
    function Unit_SetMvPerVoltFullScale(Unit_Address : TUnitAddress; Channel : TSys_Channels; FSValue : Double) : Boolean;
    function Unit_GetMvPerVoltFullScale(Unit_Address : TUnitAddress; Channel : TSys_Channels; Var FSValue : Double) : Boolean;
    function Unit_SetKnownLoadCal(Unit_Address : TUnitAddress; Channel : TSys_Channels; LoadPoint : TSG_LoadPt; CalValue : LongInt) : Boolean;
    function Unit_GetKnownLoadCal(Unit_Address : TUnitAddress; Channel : TSys_Channels; LoadPoint : TSG_LoadPt; Var CalValue : LongInt) : Boolean;
    // Component
    procedure SetUnitConnect(Value : Boolean);
    procedure SetUnitDisconnect(Value : Boolean);
    procedure SetComNumber(Value : LongInt);
    procedure SetBaudRate(Value : TSysBaudRate);
    procedure SetUnitAddress(Value : String);
    procedure SetLineFeed(Value : Boolean);
    procedure SetUnitText(Value : String);
    function GetUnitDispText : String;
    function GetUnitDispFloat : Double;
    function GetUnitSWRevision : String;
    procedure SetUnitContinuousTransmit(Value : Boolean);
    procedure SetUnitTare(Value : Boolean);
    procedure SetUnitClearTare(Value : Boolean);
    function GetUnitShuntCal : Double;
    procedure SetUnitSGChannel(Value : TSys_Channels);
    procedure SetUnitEngUnits(Value : TSysUnits);
    function GetUnitEngUnits : TSysUnits;
    function GetUnitTransducerSN : ShortString;
    procedure SetUnitEUFullScale(Value : Double);
    function GetUnitEUFullScale : Double;
    procedure SetUnitmVPerVolt(Value : Double);
    function GetUnitmVPerVolt : Double;
    procedure SetUnitKnownLoadCal(LoadPoint : TSG_LoadPt; Value : LongInt);
    function GetUnitKnownLoadCal(LoadPoint : TSG_LoadPt) : LongInt;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    property UnitDisplayText : String write SetUnitText;
    property UnitReadText : String read GetUnitDispText;
    property UnitReadFloat : Double read GetUnitDispFloat;
    property UnitSWRevisition : String read GetUnitSWRevision;
    property UnitTare : Boolean read FUnitTare write SetUnitTare;
    property UnitClearTare : Boolean read FUnitClearTare write SetUnitClearTare;
    property UnitShuntCal  : Double read GetUnitShuntCal;
    property UnitReadUnits : TSysUnits read GetUnitEngUnits write SetUnitEngUnits;
    property UnitTransducerSN : ShortString read GetUnitTransducerSN;
    property UnitEUFullScale : Double read GetUnitEUFullScale write SetUnitEUFullScale;
    property UnitmVPerVoltFullScale : Double read GetUnitmVPerVolt write SetUnitmVPerVolt;
    property UnitKnownLoadCal[LoadPoint : TSG_LoadPt] : LongInt read GetUnitKnownLoadCal write SetUnitKnownLoadCal;
  published
    property UnitConnect : Boolean read FUnitConnected write SetUnitConnect;
    property UnitDisconect : Boolean read FUnitDisconnected write SetUnitDisconnect;
    property UnitComNumber : LongInt read FUnitComNumber write SetComNumber;
    property UnitBaudRate : TSysBaudRate read FUnitBaudRate write SetBaudRate;
    property UnitAddress : String read FUnitAddress write SetUnitAddress;
    property UnitLineFeed : Boolean read FUnitLineFeed write SetLineFeed;
    property UnitContinuousTransmit : Boolean read FUnitContinuousTransmit write SetUnitContinuousTransmit;
    property UnitSGChannel : TSys_Channels read FUnitSGChannel write SetUnitSGChannel;

    property OnNewContinousTransmitData : TContinousTransmitData read FOnNewContinousTransmitData write FOnNewContinousTransmitData;
    property OnCommandFailed : TCommandFailed read FOnCommandFailed write FOnCommandFailed;
  end;

  procedure Register;

implementation
{_R Sensotec_Commands.dcr}

Uses AdExcept;

 procedure Register;
 begin
   RegisterComponents('TMSI',[TSensotec_Interface]);
 end; // Register

constructor TSensotec_Interface.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FUnitComNumber := 1;
  FUnitBaudRate := B9600;
  FUnitLineFeed := False;
  FUnitAddress := '00';
  FUnitContinuousTransmit := False;
  FUnitTare := False;
  FUnitClearTare := False;
  FSysUnits := UNKN;
  FUnitSGChannel := 1;
  FUnitConnected := False;
  FUnitDisconnected := True;
  FPacketData := '';
  if Not (csDesigning in ComponentState) then
  begin
    FSerialPort1 := TApdComPort.Create(Self);
    with FSerialPort1 do
    begin
      Open := False;
      ComNumber := FUnitComNumber;
      Baud := SysBaudRate[Ord(FUnitBaudRate)];
      AutoOpen := True;
    end; // With
    FSerialPortPacket1 := TApdDataPacket.Create(Self);
    with FSerialPortPacket1 do
    begin
      Enabled := False;
      AutoEnable := False;
      ComPort := FSerialPort1;
      StartCond := scAnyData;
      EndCond := [ecString];
      EndString := #13;
      TimeOut := 182;
      OnPacket := SerialPortPacket1Packet;
      OnTimeout := SerialPortPacket1Timeout;
    end; // With
  end; // If
end; // TSensotec_Interface.Create

destructor TSensotec_Interface.Destroy;
begin
  if Not (csDesigning in ComponentState) then
  begin
    FSerialPort1.Open := False;
    FSerialPort1.Free;
    FSerialPortPacket1.Free;
  end; // If
  inherited Destroy;
end; // TSensotec_Interface.Destroy

procedure TSensotec_Interface.Delay(WaitTimeMS : LongInt);
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
end; // TSensotec_Interface.Delay

function TSensotec_Interface.IsNumeric(Value : String) : Boolean;
var
  i : LongInt;
  j : LongInt;
  CharOK : Boolean;
  ValueOK : Boolean;
  Expo : LongInt;
  Dot : LongInt;
  Dash : LongInt;
begin
  ValueOK := Length(Value) > 0;
  for i := 1 to Length(Value) do
  begin
    CharOK := True;
    for j := 0 to 9 do
    begin
      if (Value[i] <> IntToStr(j)) then
      begin
        if (Value[i] = 'E') or (Value[i] = '.') or (Value[i] = '-') then
        begin
        if (Value[i] = 'E') then
          Inc(Expo);
        if (Value[i] = '.') then
          Inc(Dot);
        if (Value[i] = '-') then
          Inc(Dash);
        end
        else
        begin
          CharOK := False;
        end; // If
      end
      else
      begin
        CharOK := True;
        Break;
      end; // If
    end; // for j
    ValueOK := ValueOK and CharOK;
    if Not ValueOK then
      Break;
  end; // for i
  Result := ValueOK;
end; // TSensotec_Interface.IsNumeric

function TSensotec_Interface.RemoveUnitsFromStr(Value : String) : String;
var
  i : LongInt;
  UnitPos : LongInt;
begin
  for i := Low(SysUnits) to High(SysUnits) do
  begin
    UnitPos := Pos(SysUnits[i],Value);
    if (UnitPos > 0) then
    begin
      Result := Trim(Copy(Value,1,(UnitPos - 1)));
      Break;
    end; // If
  end; // For i
  if (Result = '') then
    Result := Value;
end; // TSensotec_Interface.RemoveUnitsFromStr

function TSensotec_Interface.Screen_Packet(Value : String) : TCmd_Result;
var
  TempStr : String;
begin
  if (Value = 'OK') then
  begin
    Result := OK;
    Exit;
  end; // If
  if (Value = 'ERROR') then
  begin
    Result := Error;
    Exit;
  end; // If
  if (Value = 'N/A') then
  begin
    Result := NA;
    Exit;
  end; // If
  TempStr := RemoveUnitsFromStr(Value);
  if IsNumeric(TempStr) then
    Result := FloatData
  else
    Result := ASCIIData;
end; // TSensotec_Interface.Screen_Packet

function TSensotec_Interface.Unit_AlreadyTransmitting(Unit_Address : TUnitAddress) : Boolean;
var
  Wait_Start : LongInt;
  WaitTimeOut : Boolean;
begin
  FPacketData := '';
  FSerialPortPacket1.Enabled := True;
  FSerialPortPacket1.AutoEnable := True;
  FSerialPortPacket1.OnPacket := SerialPortPacket_ContinousTransmit;
  Wait_Start := GetTickCount;
  repeat
    WaitTimeOut := ((GetTickCount - Wait_Start) >= 100);
    Delay(50);
  until (FPacketData <> '') or WaitTimeOut;
  FSerialPortPacket1.Enabled := (FPacketData <> '');
  FSerialPortPacket1.AutoEnable := (FPacketData <> '');
  if FSerialPortPacket1.AutoEnable then
    FSerialPortPacket1.OnPacket := SerialPortPacket_ContinousTransmit
  else
    FSerialPortPacket1.OnPacket := SerialPortPacket1Packet;
  Result := (FPacketData <> '');
end; // TSensotec_Interface.Unit_AllreadyTransmitting

function TSensotec_Interface.PadChannel(NumToPad : LongInt) : String;
begin
  if (NumToPad > 9) then
    Result := IntToStr(NumToPad)
  else
    Result := '0' + IntToStr(NumToPad);
end; // TSensotec_Interface.PadChannel

procedure TSensotec_Interface.SerialPortPacket1Packet(Sender: TObject;
  Data: Pointer; Size: Integer);
var
  CharArray :  PChar;
  i : LongInt;
begin
  CharArray := Data;
  FPacketData := CharArray; 
  for i := (Size - 1) to Length(FPacketData) do
    FPacketData[i] := #0;
  FPacketData := Trim(FPacketData);
end;

procedure TSensotec_Interface.SerialPortPacket_ContinousTransmit(Sender: TObject; Data: Pointer;
  Size: Integer);
var
  CharArray :  PChar;
  i : LongInt;
begin
  CharArray := Data;
  FPacketData := CharArray;
  for i := (Size - 1) to Length(FPacketData) do
    FPacketData[i] := #0;
  FPacketData := Trim(FPacketData);
  if Screen_Packet(FPacketData) in [OK,Error,NA] then
  begin
    FSerialPortPacket1.AutoEnable := False;
  end
  else
  begin
    if Assigned(FOnNewContinousTransmitData) then
      FOnNewContinousTransmitData(Self,FPacketData);
  end; // If
end;

procedure TSensotec_Interface.SerialPortPacket1Timeout(Sender: TObject);
begin
  FPacketTimeOut := True;
end;

procedure TSensotec_Interface.PortNumber(ComPort : LongInt);
begin
  if Not (csDesigning in ComponentState) then
    FSerialPort1.ComNumber := ComPort;
end; // TSensotec_Interface.PortNumber

procedure TSensotec_Interface.BaudRate(Baud : LongInt);
begin
  if Not (csDesigning in ComponentState) then
    FSerialPort1.Baud := Baud;
end; // TSensotec_Interface.BaudRate

function TSensotec_Interface.InitializeComPort : Boolean;
begin
  Result := True;
  if Not (csDesigning in ComponentState) then
  begin
    try
      with FSerialPort1 do
      begin
        Baud := SysBaudRate[Ord(FUnitBaudRate)];
        DataBits := 8;
        StopBits := 1;
        Parity := pNone;
        SWFlowOptions := swfNone;
        Open := True;
      end; // With
      FSerialPortPacket1.ComPort := FSerialPort1;
    except
      On EOpenComm do
      begin
        Result := False;
      end; // If
    end; // Try
  end; // If
end; // TSensotec_Interface.InitializeComPort

procedure TSensotec_Interface.CloseComPort;
begin
  if Not (csDesigning in ComponentState) then
    FSerialPort1.Open := False;
end; // TSensotec_Interface.CloseComPort

function TSensotec_Interface.Send_Cmd(UnitCommand : String; Var DataStr : ShortString) : TCmd_Result;
var
  Packet_AutoEnable : Boolean; // If a command is sent while a continous transfer is active the packet component will
                               // turn off so the function can return.
begin
  if Not (csDesigning in ComponentState) then
  begin
    FPacketTimeOut := False;
    FPacketData := '';
    DataStr := '';
    if (FSerialPort1.OutBuffFree > Length(UnitCommand)) then
    begin
      FSerialPortPacket1.Enabled := True;
      Packet_AutoEnable := FSerialPortPacket1.AutoEnable;
      FSerialPort1.PutString(UnitCommand);
      repeat
        Delay(1);
      until (Not FSerialPortPacket1.Enabled and Not FSerialPortPacket1.AutoEnable) or FPacketTimeOut;
      FSerialPortPacket1.AutoEnable := Packet_AutoEnable;
      if FPacketTimeOut then
      begin // Command Failed
        Result := TimedOut;
      end
      else
      begin // Command Succeded
        Result := Screen_Packet(FPacketData);
        DataStr := FPacketData;
      end; // If
    end
    else
    begin
      Result := Error;
    end; // If
  end
  else
    Result := Error;
end; // TSensotec_Interface.Send_Cmd

function TSensotec_Interface.Send_Sys_Func_Cmd(UnitAddress : TUnitAddress; CommandCode : TSysEnumFunctionCommands;
      WCommand : TOptional_Write; Var CommandResult : TCmd_Result; Var RecievedData : ShortString) : TCmd_Status;
Var
  Command : String;
begin
  Result := CommandSent;
  if (CommandCode in [Low(CommandCode)..High(CommandCode)]) then
  begin
    Command := '#' + UnitAddress + SystemFucntionCommands[Ord(CommandCode)] + WCommand + #13;
    CommandResult := Send_Cmd(Command,RecievedData);
    Case CommandResult of
      OK,NA,FloatData,ASCIIData  : Result := CommandCompleted;
      Error                      : Result := CommandError;
      TimedOut                   : Result := TimeOut;
    end; // Case
  end
  else
  begin
    Result := InvalidCommand
  end; // If
end; // TSensotec_Interface.Send_Sys_Func_Cmd

function TSensotec_Interface.Send_Sys_Write_Cmd(UnitAddress : TUnitAddress; CommandCode : TSysEnumWriteCommands;
      WCommand : TOptional_Write; Var CommandResult : TCmd_Result; Var RecievedData : ShortString) : TCmd_Status;
var
  Command : String;
begin
  Result := CommandSent;
  if (CommandCode in [Low(CommandCode)..High(CommandCode)]) then
  begin
    Command := '#' + UnitAddress + SystemWriteCommands[Ord(CommandCode)] + WCommand + #13;
    CommandResult := Send_Cmd(Command,RecievedData);
    Case CommandResult of
      OK,NA                     : Result := CommandCompleted;
      Error,FloatData,ASCIIData : Result := CommandError;
      TimedOut                  : Result := TimeOut;
    end; // Case
  end
  else
  begin
    Result := InvalidCommand
  end; // If
end; // TSensotec_Interface.Send_Sys_Write_Cmd

function TSensotec_Interface.Send_Sys_Read_Cmd(UnitAddress : TUnitAddress; CommandCode : TSysEnumReadCommands;
      Var CommandResult : TCmd_Result; Var RecievedData : ShortString) : TCmd_Status;
var
  Command : String;
begin
  Result := CommandSent;
  if (CommandCode in [Low(CommandCode)..High(CommandCode)]) then
  begin
    Command := '#' + UnitAddress + SystemReadCommands[Ord(CommandCode)] + #13;
    CommandResult := Send_Cmd(Command,RecievedData);
    Case CommandResult of
      OK,NA,FloatData,ASCIIData  : Result := CommandCompleted;
      Error                      : Result := CommandError;
      TimedOut                   : Result := TimeOut;
    end; // Case
  end
  else
  begin
    Result := InvalidCommand
  end; // If
end; // TSensotec_Interface.Send_Sys_Read_Cmd

function TSensotec_Interface.Send_SG_Func_Cmd(UnitAddress : TUnitAddress; Channel : TSys_Channels; CommandCode : TSGEnumFunctionCommands;
      WCommand : TOptional_Write; Var CommandResult : TCmd_Result; Var RecievedData : ShortString) : TCmd_Status;
var
  Command : String;
  lChannel : String;
begin
  Result := CommandSent;
  if (CommandCode in [Low(CommandCode)..High(CommandCode)]) then
  begin
    if (Channel > 0) then
      lChannel := PadChannel(Channel)
    else
      lChannel := '';
    Command := '#' + UnitAddress + lChannel + StrainGuageFunctionCommands[Ord(CommandCode)] + WCommand + #13;
    CommandResult := Send_Cmd(Command,RecievedData);
    Case CommandResult of
      OK,NA,FloatData,ASCIIData  : Result := CommandCompleted;
      Error                      : Result := CommandError;
      TimedOut                   : Result := TimeOut;
    end; // Case
  end
  else
  begin
    Result := InvalidCommand
  end; // If
end; // TSensotec_Interface.Send_SG_Func_Cmd

function TSensotec_Interface.Send_SG_Write_Cmd(UnitAddress : TUnitAddress; Channel : TSys_Channels; CommandCode : TSGEnumWriteCommands;
      WCommand : TOptional_Write; Var CommandResult : TCmd_Result; Var RecievedData : ShortString) : TCmd_Status;
var
  Command : String;
  lChannel : String;
begin
  Result := CommandSent;
  if (CommandCode in [Low(CommandCode)..High(CommandCode)]) then
  begin
    if (Channel > 0) then
      lChannel := PadChannel(Channel)
    else
      lChannel := '';
    Command := '#' + UnitAddress + lChannel + StrainGuageWriteCommands[Ord(CommandCode)] + WCommand + #13;
    CommandResult := Send_Cmd(Command,RecievedData);
    Case CommandResult of
      OK,NA,FloatData,ASCIIData  : Result := CommandCompleted;
      Error                      : Result := CommandError;
      TimedOut                   : Result := TimeOut;
    end; // Case
  end
  else
  begin
    Result := InvalidCommand
  end; // If
end; // TSensotec_Interface..Send_SG_Write_Cmd

function TSensotec_Interface.Send_SG_Read_Cmd(UnitAddress : TUnitAddress; Channel : TSys_Channels; CommandCode : TSGEnumReadCommands;
      RCommand : TOptional_Read; Var CommandResult : TCmd_Result; Var RecievedData : ShortString) : TCmd_Status;
var
  Command : String;
begin
  Result := CommandSent;
  if (CommandCode in [Low(CommandCode)..High(CommandCode)]) then
  begin
    Command := '#' + UnitAddress + PadChannel(Channel) + StrainGuageReadCommands[Ord(CommandCode)] + RCommand + #13;
    CommandResult := Send_Cmd(Command,RecievedData);
    Case CommandResult of
      OK,NA,FloatData,ASCIIData  : Result := CommandCompleted;
      Error                      : Result := CommandError;
      TimedOut                   : Result := TimeOut;
    end; // Case
  end
  else
  begin
    Result := InvalidCommand
  end; // If
end; // TSensotec_Interface.Send_SG_Read_Cmd

function TSensotec_Interface.Unit_Contact(ComPort : LongInt; Baud : LongInt; Unit_Address : TUnitAddress) : Boolean;
var
  OKForNextCmd : Boolean;
  SysBaud : TSysBaudRate;
  Unit_Transmitting : Boolean;
begin
  Result := False;
  Case Baud of
    300  : SysBaud := B300;
    600  : SysBaud := B600;
    1200 : SysBaud := B1200;
    2400 : SysBaud := B2400;
    4800 : SysBaud := B4800;
    9600 : SysBaud := B9600;
  else
    SysBaud := B9600;
  end; // Case
  PortNumber(ComPort);
  if InitializeComPort then
  begin
    Unit_Transmitting := Unit_AlreadyTransmitting(Unit_Address);
    OKForNextCmd := Unit_ContinuousTransmit(Unit_Address,False,Unit_Transmitting);
    if OKForNextCmd then
      OKForNextCmd := Unit_LineFeed(Unit_Address,True);
    if OKForNextCmd then
    begin
      if Unit_BaudRate(Unit_Address,SysBaud) then
      begin
        OKForNextCmd := True;
        BaudRate(Baud);
        Delay(500);
      end; // If
    end; // If
    if OKForNextCmd then
      OKForNextCmd := Unit_DisplayText(Unit_Address,'TMSI SW Connected');
    Result := OKForNextCmd;
  end; // If
end; //  TSensotec_Interface.Unit_Contact

function TSensotec_Interface.Unit_Disconnect(Unit_Address : TUnitAddress) : Boolean;
var
  CmdSuccess : Boolean;
begin
  if FSerialPortPacket1.AutoEnable then
  begin
    Result := Unit_ContinuousTransmit(Unit_Address,False,False) and Unit_DisplayText(Unit_Address,'Goodbye');
  end
  else
  begin
    Result := Unit_DisplayText(Unit_Address,'Goodbye');
  end; // If
  if Result then
    CloseComPort;
end; // TSensotec_Interface.Unit_Disconnect

function TSensotec_Interface.Unit_BaudRate(Unit_Address : TUnitAddress; BaudRate : TSysBaudRate) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_Sys_Write_Cmd(Unit_Address,W1, IntToStr(Ord(BaudRate)), CmdResult,Cmd_Dump);
  if (Func_Result = CommandCompleted) then
  begin
    Result := True
  end
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to set Unit[%s] Baud Rate.',[Unit_Address]),Func_Result);
  end; // if
end; // TSensotec_Interface.Unit_BaudRate

function TSensotec_Interface.Unit_LineFeed(Unit_Address : TUnitAddress; LN_On : Boolean) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_Sys_Write_Cmd(Unit_Address,W2, IntToStr(Ord(LN_ON)), CmdResult,Cmd_Dump);
  if (Func_Result = CommandCompleted) then
  begin
    FSerialPortPacket1.EndString := #10#13;
    Result := True
  end
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to set Unit[%s] Line Feed.',[Unit_Address]),Func_Result);
  end; // if
end; // TSensotec_Interface.Unit_LineFeed

function TSensotec_Interface.Unit_ChangeAddress(Curr_Address, New_Address : TUnitAddress) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_Sys_Write_Cmd(Curr_Address,W2, New_Address, CmdResult,Cmd_Dump);
  if (Func_Result = CommandCompleted) then
  begin
    Result := True
  end
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to change Unit[%s] Address to %s.',[Curr_Address,New_Address]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_ChangeAddress

function TSensotec_Interface.Unit_GetDisplayValueFloat(Unit_Address : TUnitAddress; ReturnUnits : TSysUnits) : Double;
var
  CmdResult : TCmd_Result;
  Cmd_Data : ShortString;
  TempStr : String;
  Func_Result : TCmd_Status;
begin
  Result := 0;
  Func_Result := Send_Sys_Func_Cmd(Unit_Address,F0, '', CmdResult,Cmd_Data);
  if (Func_Result = CommandCompleted) then
  begin
    Case CmdResult of
      OK,Error,NA,ASCIIData : Result := 0.0;
      FloatData : begin
                    TempStr := RemoveUnitsFromStr(Cmd_Data);
                    case ReturnUnits of
                      LBS : Result := StrToFloat(TempStr);
                      KG  : Result := StrToFloat(TempStr) * siLoadKG;
                      N   : Result := StrToFloat(TempStr) * siLoad;
                    else
                      Result := StrToFloat(TempStr); // Assume Unit is reading LBS
                    end; // Case
                  end; // FloatData
    end; // Case
  end
  else
  begin
    Result := 0;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to get Unit[%s] Display as Float.',[Unit_Address]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_GetDisplayValueFloat

function TSensotec_Interface.Unit_GetDisplayValueString(Unit_Address : TUnitAddress) : String;
var
  CmdResult : TCmd_Result;
  Cmd_Data : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_Sys_Func_Cmd(Unit_Address,F0, '', CmdResult,Cmd_Data);
  if (Func_Result = CommandCompleted) then
  begin
    Case CmdResult of
      OK,Error,NA          : Result := '';
      ASCIIData, FloatData : Result := Cmd_Data;
    end; // Case
  end
  else
  begin
    Result := '';
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to get Unit[%s] Display as String.',[Unit_Address]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_GetDisplayValueFloat

function TSensotec_Interface.Unit_SWRevision(Unit_Address : TUnitAddress) : String;
var
  CmdResult : TCmd_Result;
  Cmd_Data : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_Sys_Read_Cmd(Unit_Address,RR,CmdResult,Cmd_Data);
  if (Func_Result = CommandCompleted) then
  begin
    Case CmdResult of
      OK,Error,NA,FloatData : Result := '';
      ASCIIData             : Result := Cmd_Data;
    end; // Case
  end
  else
  begin
    Result := '';
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to get Unit[%s] Software Revision.',[Unit_Address]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_SWRevision

function TSensotec_Interface.Unit_DisplayText(Unit_Address : TUnitAddress; TextToDisplay : ShortString) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Data : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_Sys_Func_Cmd(Unit_Address, FI, TextToDisplay, CmdResult, Cmd_Data);
  if (Func_Result = CommandCompleted) then
  begin
    Result := True;
  end
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to set Unit[%s] Text to display.',[Unit_Address]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_DisplayText

function TSensotec_Interface.Unit_Tare(Unit_Address : TUnitAddress; ChannelToTare : TSys_Channels) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  if (ChannelToTare > 99) then
    ChannelToTare := 99;
  Func_Result := Send_SG_Func_Cmd(Unit_Address, ChannelToTare, F1, '', CmdResult, Cmd_Dump);
  if (Func_Result = CommandCompleted) then
  begin
    Result := True
  end
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to Tare Unit[%s]; Channel[%d].',[Unit_Address,ChannelToTare]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_Tare

function TSensotec_Interface.Unit_ClearTare(Unit_Address : TUnitAddress; ChannelToClear : TSys_Channels) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  if (ChannelToClear > 99) then
    ChannelToClear := 99;
  Func_Result := Send_SG_Func_Cmd(Unit_Address, ChannelToClear, F2, '', CmdResult, Cmd_Dump);
  if (Func_Result = CommandCompleted) then
  begin
    Result := True;
  end
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to Clear Tare from Unit[%s]; Channel[%d].',[Unit_Address,ChannelToClear]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_ClearTare;

function TSensotec_Interface.Unit_ShuntCal(Unit_Address : TUnitAddress; ChannelToShunt : TSys_Channels) : Double;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  if (ChannelToShunt > 99) then
    ChannelToShunt := 99;
  Func_Result := Send_SG_Func_Cmd(Unit_Address, ChannelToShunt, F5, '', CmdResult, Cmd_Dump);
  if (Func_Result = CommandCompleted) then
  begin
    Result := StrToFloat(Cmd_Dump);
  end
  else
  begin
    Result := 0.0;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to apply Shunt Cal to Unit[%s]; Channel %d.',[Unit_Address,ChannelToShunt]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_ShuntCal

function TSensotec_Interface.Packet_ContinuousTransfer(Unit_Address : String) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_Sys_Write_Cmd(Unit_Address,WI,'1',cmdResult,Cmd_Dump);
  Result := (Func_Result = CommandCompleted);
  if Result then
  begin
    FSerialPortPacket1.Enabled := True;
    FSerialPortPacket1.AutoEnable := True;
    FSerialPortPacket1.OnPacket := SerialPortPacket_ContinousTransmit;
  end
  else
  begin
//    FSerialPortPacket1.OnPacket := SerialPortPacket1Packet;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to START Continuous Transfer from Unit[%s].',[Unit_Address]),Func_Result);
  end; // If
end; // TSensotec_Interface.Packet_ContinuousTransfer

function TSensotec_Interface.Packet_NormalTransfer(Unit_Address : String) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_Sys_Write_Cmd(Unit_Address,WI,'0',cmdResult,Cmd_Dump);
  Result := (Func_Result = CommandCompleted);
  if Result then
  begin
    FSerialPortPacket1.Enabled := False;
    FSerialPortPacket1.AutoEnable := False;
    FSerialPortPacket1.OnPacket := SerialPortPacket1Packet;
  end
  else
  begin
//    FSerialPortPacket1.OnPacket := SerialPortPacket1Packet;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to STOP Continuous Transfer from Unit[%s].',[Unit_Address]),Func_Result);
  end; // If
end; // TSensotec_Interface.Packet_NormalTransfer

function TSensotec_Interface.Unit_ContinuousTransmit(Unit_Address : TUnitAddress; CT_On : Boolean; Unit_CT_Active : Boolean) : Boolean;
begin
  if Not Unit_CT_Active then
  begin
    if CT_On then
      Result := Packet_ContinuousTransfer(Unit_Address)
    else
      Result := Packet_NormalTransfer(Unit_Address);
  end
  else
  begin
    if CT_On then
      Result := True // Unit is already performing requested action.
    else
      Result := Packet_NormalTransfer(Unit_Address);
  end; // If
end; // TSensotec_Interface.Unit_ContinuousTransmit

function TSensotec_Interface.Unit_GetEngineeringUnits(Unit_Address : TUnitAddress; Channel : TSys_Channels; Var EngUnits : TSysUnits) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
  i : LongInt;
  EU_Found : Boolean;
begin
  EU_Found := False;
  Func_Result := Send_SG_Read_Cmd(Unit_Address,Channel,R6,'',CmdResult,Cmd_Dump);
  if (Func_Result = CommandCompleted) then
  begin
    Result := True;
    Cmd_Dump := Trim(Cmd_Dump);
    for i := Low(SysUnits) to High(SysUnits) do
    begin
      if (Cmd_Dump = SysUnits[i]) then
      begin
        EngUnits := TSysUnits(i);
        EU_Found := True;
        Break;
      end; // If
    end; // For i
    if Not EU_Found then
      EngUnits := UNKN;
  end
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to get Units[%s]; Channel %d; configured engineering units.',[Unit_Address,Channel]),Func_Result);
  end; // if
end; // TSensotec_Interface.Unit_GetEngineeringUnits

function TSensotec_Interface.Unit_SetEngineeringUnits(Unit_Address : TUnitAddress; Channel : TSys_Channels; EngUnits : TSysUnits) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_SG_Write_Cmd(Unit_Address,Channel,W6,SysUnits[Ord(EngUnits)],CmdResult,Cmd_Dump);
  if (Func_Result = CommandCompleted) then
    Result := True
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to set Units[%s]; Channel %d; engineering units to %s.',[Unit_Address,Channel,SysUnits[Ord(EngUnits)]]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_SetEnginerringUnits

function TSensotec_Interface.Unit_GetTransducerSN(Unit_Address : TUnitAddress; Channel : TSys_Channels; Var SN : ShortString) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_SG_Func_Cmd(Unit_Address,Channel,FE,'',CmdResult,Cmd_Dump);
  if (Func_Result = CommandCompleted) then
  begin
    SN := Cmd_Dump;
    Result := True;
  end
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to get Units[%s]; Channel %d; attached transducer serial number.',[Unit_Address,Channel]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_GetTransducerSN

function TSensotec_Interface.Unit_SetEUFullScale(Unit_Address : TUnitAddress; Channel : TSys_Channels; FSValue : Double) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_SG_Write_Cmd(Unit_Address,Channel,W5,FloatToStr(FSValue),CmdResult,Cmd_Dump);
  if (Func_Result = CommandCompleted) then
    Result := True
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to set Units[%s]; Channel %d; EU Full Scale.',[Unit_Address,Channel]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_SetEUFullScale

function TSensotec_Interface.Unit_GetEUFullScale(Unit_Address : TUnitAddress; Channel : TSys_Channels; Var FSValue : Double) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_SG_Read_Cmd(Unit_Address,Channel,R5,'',CmdResult,Cmd_Dump);
  if (Func_Result = CommandCompleted) then
  begin
    FSValue := StrToFloat(Cmd_Dump);
    Result := True;
  end
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to get Units[%s]; Channel %d; EU Full Scale.',[Unit_Address,Channel]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_GetEUFullScale

function TSensotec_Interface.Unit_SetMvPerVoltFullScale(Unit_Address : TUnitAddress; Channel : TSys_Channels; FSValue : Double) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_SG_Write_Cmd(Unit_Address,Channel,W7,FloatToStr(FSValue),CmdResult,Cmd_Dump);
  if (Func_Result = CommandCompleted) then
    Result := True
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to get Units[%s]; Channel %d; mV/V Full Scale.',[Unit_Address,Channel]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_SetMvPerVoltFullScale

function TSensotec_Interface.Unit_GetMvPerVoltFullScale(Unit_Address : TUnitAddress; Channel : TSys_Channels; Var FSValue : Double) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_SG_Read_Cmd(Unit_Address,Channel,R7,'',CmdResult,Cmd_Dump);
  if (Func_Result = CommandCompleted) then
  begin
    FSValue := StrToFloat(Cmd_Dump);
    Result := True;
  end
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to get Units[%s]; Channel %d; mV/V Full Scale.',[Unit_Address,Channel]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_GetMvPerVoltFullScale

function TSensotec_Interface.Unit_SetKnownLoadCal(Unit_Address : TUnitAddress; Channel : TSys_Channels; LoadPoint : TSG_LoadPt; CalValue : LongInt) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_SG_Write_Cmd(Unit_Address,Channel,WK,format('%s%d',[PadChannel((Ord(LoadPoint) + 1)),CalValue]),CmdResult,Cmd_Dump);
  if (Func_Result = CommandCompleted) then
    Result := False
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to set Units[%s]; Channel %d; Load Point %d = %d.',[Unit_Address,Channel,(Ord(LoadPoint) + 1), CalValue]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_SetKnownLoadCal

function TSensotec_Interface.Unit_GetKnownLoadCal(Unit_Address : TUnitAddress; Channel : TSys_Channels; LoadPoint : TSG_LoadPt; Var CalValue : LongInt) : Boolean;
var
  CmdResult : TCmd_Result;
  Cmd_Dump : ShortString;
  Func_Result : TCmd_Status;
begin
  Func_Result := Send_SG_Read_Cmd(Unit_Address,Channel,RK,PadChannel(Ord(LoadPoint) + 1),CmdResult,Cmd_Dump);
  if (Func_Result = CommandCompleted) then
  begin
    Result := True;
    CalValue := Trunc(StrToFloat(Cmd_Dump));
  end
  else
  begin
    Result := False;
    if Assigned(FOnCommandFailed) then
      FOnCommandFailed(Self,format('Failed to get Units[%s]; Channel %d; Load Point %d.',[Unit_Address,Channel,(Ord(LoadPoint) + 1)]),Func_Result);
  end; // If
end; // TSensotec_Interface.Unit_GetKnownLoadCal

procedure TSensotec_Interface.SetUnitConnect(Value : Boolean);
begin
  if Not (csDesigning in ComponentState) then
  begin
    if Value then
      FUnitConnected := Unit_Contact(FUnitComNumber,SysBaudRate[Ord(FUnitBaudRate)],FUnitAddress);
  end
  else
  begin
    FUnitConnected := Value;
    FUnitDisconnected := Not FUnitConnected;
  end; // If
end; // TSensotec_Interface.SetUnitConnect

procedure TSensotec_Interface.SetUnitDisconnect(Value : Boolean);
begin
  if Not (csDesigning in ComponentState) then
  begin
    if Value and FUnitConnected then
    begin
      if Unit_AlreadyTransmitting(FUnitAddress) then
        Unit_ContinuousTransmit(FUnitAddress,False,True);
      FUnitDisconnected := Unit_Disconnect(FUnitAddress);
    end; // If
  end
  else
  begin
    FUnitDisconnected := Value;
    FUnitConnected := Not FUnitDisconnected;
  end; // If
end; // TSensotec_Interface.SetUnitDisconnect

procedure TSensotec_Interface.SetComNumber(Value : LongInt);
begin
  FUnitComNumber := Value;
  PortNumber(FUnitComNumber);
end; // TSensotec_Interface.SetComNumber

procedure TSensotec_Interface.SetBaudRate(Value : TSysBaudRate);
begin
  if Not (csDesigning in ComponentState) then
  begin
    if FUnitConnected then
    begin
      if Unit_BaudRate(FUnitAddress,Value) then
      begin
        FUnitBaudRate := Value;
        BaudRate(SysBaudRate[Ord(FUnitBaudRate)]);
      end; // If
    end
    else
      BaudRate(SysBaudRate[Ord(FUnitBaudRate)]);
  end
  else
    FUnitBaudRate := Value;
end; // TSensotec_Interface.SetBaudRate

procedure TSensotec_Interface.SetUnitAddress(Value : String);
begin
  FUnitAddress := Value;
end; // TSensotec_Interface.SetUnitAddress

procedure TSensotec_Interface.SetLineFeed(Value : Boolean);
begin
  if FUnitConnected and Not (csDesigning in ComponentState) then
  begin
    FUnitLineFeed := Unit_LineFeed(FUnitAddress,Value)
  end
  else
    FUnitLineFeed := Value;
end; // TSensotec_Interface.SetLineFeed

procedure TSensotec_Interface.SetUnitText(Value : String);
begin
  Unit_DisplayText(FUnitAddress,Value);
end; // TSensotec_Interface.SetUnitText

function TSensotec_Interface.GetUnitDispText : String;
begin
  Result := Unit_GetDisplayValueString(FUnitAddress);
end; // TSensotec_Interface.GetUnitDispText

function TSensotec_Interface.GetUnitDispFloat : Double;
begin
  Result := Unit_GetDisplayValueFloat(FUnitAddress,FSysUnits);
end; // TSensotec_Interface.GetUnitDispFloat

function TSensotec_Interface.GetUnitSWRevision : String;
begin
  Result := Unit_SWRevision(FUnitAddress);
end; // TSensotec_Interface.GetUnitSWRevision

procedure TSensotec_Interface.SetUnitContinuousTransmit(Value : Boolean);
begin
  if FUnitConnected and Not (csDesigning in ComponentState) then
  begin
    FUnitContinuousTransmit := Unit_ContinuousTransmit(FUnitAddress,Value,Unit_AlreadyTransmitting(FUnitAddress));
  end
  else
    FUnitContinuousTransmit := Value;
end; // TSensotec_Interface.SetUnitContinuousTransmit

procedure TSensotec_Interface.SetUnitTare(Value : Boolean);
begin
  FUnitTare := Unit_Tare(FUnitAddress,FUnitSGChannel);
end; // TSensotec_Interface.SetUnitTare

procedure TSensotec_Interface.SetUnitClearTare(Value : Boolean);
begin
  FUnitClearTare := Unit_ClearTare(FUnitAddress,FUnitSGChannel);
end; // TSensotec_Interface.SetUnitClearTare

function TSensotec_Interface.GetUnitShuntCal : Double;
begin
  Result := Unit_ShuntCal(FUnitAddress,FUnitSGChannel);
end; // TSensotec_Interface.GetUnitShuntCal

procedure TSensotec_Interface.SetUnitSGChannel(Value : TSys_Channels);
begin
  if (Value > 0) then
    FUnitSGChannel := Value;
end; // TSensotec_Interface.SetUnitSGChannel

procedure TSensotec_Interface.SetUnitEngUnits(Value : TSysUnits);
begin
  if (FSysUnits <> Value) and Unit_SetEngineeringUnits(FUnitAddress,FUnitSGChannel,Value) then
    FSysUnits := Value;
end; // TSensotec_Interface.SetUnitEngUnits

function TSensotec_Interface.GetUnitEngUnits : TSysUnits;
var
  Tmp_Units : TSysUnits;
begin
  Result := LBS;
  if Unit_GetEngineeringUnits(FUnitAddress,FUnitSGChannel,Tmp_Units) then
  begin
    FSysUnits := Tmp_Units;
    Result := FSysUnits;
  end; // If
end; // TSensotec_Interface.GetUnitEngUnits

function TSensotec_Interface.GetUnitTransducerSN : ShortString;
var
  Tmp_Rst : ShortString;
begin
  if Unit_GetTransducerSN(FUnitAddress,FUnitSGChannel,Tmp_Rst) then
    Result := Tmp_Rst
  else
    Result := '';
end; // TSensotec_Interface.GetUnitTransducerSN

procedure TSensotec_Interface.SetUnitEUFullScale(Value : Double);
begin
  Unit_SetEUFullScale(FUnitAddress,FUnitSGChannel,Value);
end; // TSensotec_Interface.SetUnitEUFullScale

function TSensotec_Interface.GetUnitEUFullScale : Double;
var
  Tmp_Dbl : Double;
begin
  if Unit_GetEUFullScale(FUnitAddress,FUnitSGChannel,Tmp_Dbl) then
    Result := Tmp_Dbl
  else
    Result := 0;
end; // TSensotec_Interface.GetUnitEUFullScale

procedure TSensotec_Interface.SetUnitmVPerVolt(Value : Double);
begin
  Unit_SetMvPerVoltFullScale(FUnitAddress,FUnitSGChannel,Value);
end; // TSensotec_Interface.SetUnitmVPerVolt

function TSensotec_Interface.GetUnitmVPerVolt : Double;
var
  Tmp_Int : Double;
begin
  if Unit_GetMvPerVoltFullScale(FUnitAddress,FUnitSGChannel,Tmp_Int) then
    Result := Tmp_Int
  else
    Result := 0;
end; // TSensotec_Interface.GetUnitmVPerVolt

procedure TSensotec_Interface.SetUnitKnownLoadCal(LoadPoint : TSG_LoadPt; Value : LongInt);
begin
  Unit_SetKnownLoadCal(FUnitAddress,FUnitSGChannel,LoadPoint,Value);
end; // TSensotec_Interface.SetUnitKnownLoadCal

function TSensotec_Interface.GetUnitKnownLoadCal(LoadPoint : TSG_LoadPt) : LongInt;
var
  Tmp_Lng : LongInt;
begin
  if Unit_GetKnownLoadCal(FUnitAddress,FUnitSGChannel,LoadPoint,Tmp_Lng) then
    Result := Tmp_Lng
  else
    Result := 0;
end; // TSensotec_Interface.GetUnitKnownLoadCal

end.
