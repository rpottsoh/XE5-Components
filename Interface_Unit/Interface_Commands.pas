////////////////////////////////////////////////////////////////////////////////
//                       Created By: Daniel Muncy                             //
//                       Copywrite: TMSI, all rights reserved                 //
//                       Created: 7/01/2011                                   //
//                                                                            //
//   This component allows for communications and setup of an interface       //
//   model 9840.                                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
unit Interface_Commands;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  AdPacket, OoMisc, AdPort, ExtCtrls, TMSIDataTypes, TMSIStrFuncs, Device_Status_Window;

// Command Format
// Example command: @123XYZ#<CR>
// @    => Initiates the command
// 123  => Address of Unit, must be three digits (Ex. 001,026) upto 254.  Address 255 causes all units to respond
// XYZ  => Command code
// #    => If the command requires a number it must be followed by a # symbol.  Numbers less then 1 should be preceded by a 0 (zero).
// <CR> => Signifies end of command.  Must be sent.

// Response Format
// Example response: @ 123 [Response]<CR><EOT>

const
  Inf_Baud : Array[0..6] of SmallInt = (300,600,1200,2400,4800,9600,19200);
  Inf_Address : Set of Byte = [1..254]; // 255 is reserved for broadcast
  Inf_Run_Commands : Array[0..11] of String[2] = ('H','?','FV','FS','FA','F1','F2','V','P','R','X','T');
  Inf_Setup_Commands : Array[0..48] of String[4] = ('UV','UA','UL','AV','AS','S','SV','SS','SD','ST','CC','CB','CE','CV','CMV6','CMVM','CMVV','CMVT','CM','CMP','CT',
                                                          'CTP','CS','CI','L','L','LE','L%dR','OV','OP','OI','ON','OD','OU','OZ','OA','OB','OL','OT','OE','DV','DF','DD',
                                                          'DP','DC','D2','DT','DW1','DW2');
  Inf_Item_Numbers : Array[0..23] of String[2] = ('00','01','02','03','04','05','09','10','13','14','15','16',
                                                  '17','18','19','20','21','22','23','24','25','50','51','52');
  Inf_Str_Item_Numbers : Array[0..23] of String[10] = ('Load A','LPeak A','LValley A','Load B','LPeak B','LValley B','Pos','Vel','Limits','Grs A','Grs B','Load A+B',
                                                       'Torque','TPeak A','TValley A','Gross A','Torque B','TPeak B','TValley B','Gross B','Torque A+B','Cell AB','Peak AB','Valley AB');
  Inf_Item_Units : Array[0..18] of String[2] = ('00','01','02','03','04','05','06','07','08','09','00','01','02','03','00','01','02','00','01');
  Inf_Item_Eng_Units : Array[0..18] of String[5] = ('Lb','kg','N','PSI','MPa','Klb','kN','t','mVv','g','LbI','NM','OzI','TmVv','In','Cm','%','IperM','CperM');
  Inf_Line_Options : Array[0..3] of String[1] = ('B','L','D','T');
  Max_Devices = 255;

  Inf_Cell_Type : Array[0..1] of Byte = (0,1);
  Inf_Channels : Array[0..1] of Char = ('A','B');
  Inf_Num_Cal_Points : Array[0..1] of Byte = (2,5);
  Inf_Opperators : Array[0..1] of String[1] = ('>','<');

type
  TInf_Command = String[25];
  TInf_Command_Result = String;
  TInf_Address = Byte;
  TInf_Command_String = String[18];
  TDevice_Mode = (Dev_Run,Setup_UserDataEntry,Setup_AnlgOut,Setup_SenSelct,Setup_Cal,Setup_Limits,Setup_SysOptions,Setup_DispOptions);
  TInf_Baud = (B300,B600,B1200,B2400,B4800,B9600,B19200);
  TInf_Run_Mode_Cmd = (H,Q{?},FV,FS,FA,F1,F2,V,P,R,X,T);
  TInf_Setup_Mode_Cmd = (UV,UA,UL,AV,A_S,S,SV,SS,SD,ST,CC,CB,CE,CV,CMV6,CMVM,CMVV,CMVT,CM,CMP,CT,CTP,
                         CS,CI,LiV,LiS,LE,LiR,OV,OP,OI,O_N,OD,OU,OZ,OA,OB,OL,OT,OE,DV,DF,DD,DP,DC,D2,DT,DW1,DW2);
  // Front Panel options
  TItem_Numbers = (Load_A,LPeak_A,LValley_A,Load_B,LPeak_B,LValley_B,Pos,Vel,Limits,Grs_A,Grs_B,LCh_APLUSB,
                   Torque_A,TPeak_A,TValley_A,Gross_A,Torque_B,TPeak_B,TValley_B,Gross_B,TCh_APLUSB,Cell_AB,Peak_AB,Valley_AB);
  TItem_Units = (U_LB,U_kg,U_N,U_PSI,U_MPa,U_Klb,U_kN,U_t,U_mVv,U_g,U_LbI,U_NM,U_OzI,U_T_mVv,U_In,U_Cm,U_Percent,U_IperM,U_CperM); // Load, Peak, and Valley
  TValue_Repeat = (Rpt_Off,Rpt_1,Rpt_Indefinite);
  TPrint_Repeat = (Prt_Off,Prt_1,Prt_Every_3Secs,Ptr_Printer);
  // Calibration Options
  TCell_Type =(Load,Torque);
  TCell_SN = String[8];
  TCell_Date = String[6];
  TCell_Excitation = (E_5V,E_10V);
  TCell_Units = String[4];
  TInf_Channels = (Ch_A,Ch_B,Ch_Unused);
  TInf_Num_Cal_Points = (C2,C5);
  TInf_Limit_Numbers = (L1,L2,L3,L4);
  TInf_Opperators = (Op_GraterThan,Op_LessThan);
  TInf_Pntr_OpCode = (PB4800,PB9600,PB19K,PB57K,PB230K);
  TFilterTypes = (I,II);
  TFilterLevels = (Lvl1,Lvl2,Lvl3,Lvl4,Lvl5);
  TPrecision = (P0,P1,P2,P3,P4,P5);
  TInf_CountBy = (CB1,CB2,CB5,CB10,CB20);
  TInf_Line_Options = (L_Blank,L_LimitStatus,L_AnotherDisplay,L_Text);

  TDevice_Command = class(TObject)
  private
    FCommand : TInf_Command;
    FAutoActive : Boolean;
    FResponseExpected : Boolean;
    FDelayNextCommandFor : DWord;
  public
    constructor Create(AOwner : TComponent);
    property Command : TInf_Command read FCommand write FCommand;
    property AutoActive : Boolean read FAutoActive write FAutoActive;
    property ExpectResponse : Boolean read FResponseExpected write FResponseExpected;
    property DelayNextCommandFor : DWord read FDelayNextCommandFor write FDelayNextCommandFor;
  end; // TDevice_Command

  TDevice_CommandRec = packed record
    DeviceCommand : TInf_Command;
    AutoActive : Boolean;
    ExpectResponse : Boolean;
    DelayNextCommandFor : DWord;
  end; // TDevice_CommandRec

  TDevice_InfoRec = packed record
    Model : ShortString;
    Version : ShortString;
    SerialNumber : ShortString;
    Options : ShortString;
  end; // TDevice_InfoRec

  TDevice_System_OptionsRec = packed record
    Printer_Baud_Rate        : TInf_Pntr_OpCode;
    Auto_Identify            : Boolean;
    Auto_Identify_Annuciator : Boolean;
    TEDS_ON                  : Boolean;
    Auto_Tare_ON             : Boolean;
    Auto_Zero_Channel_A_ON   : Boolean;
    Auto_Zero_Channel_B_ON   : Boolean;
    Com_Address             : TInf_Address;
    Com_Baud_Rate            : TInf_Baud;
    Com_Line_Feed_ON         : Boolean;
    Retain_Tare_ON           : Boolean;
    Freeze_Display_ON        : Boolean;
    RS232_EOT_ON             : Boolean;
  end; // TDevice_System_OptionsRec

  TDevice_Display_OptionsRec = packed record
    Filter_Type          : TFilterTypes;
    Filter_Level         : Byte;
    Filter_Window_A_ON   : Boolean;
    Filter_Window_B_ON   : Boolean;
    Channel_A_Precision  : TPrecision;
    Channel_B_Precision  : TPrecision;
    Channel_A_Counts_By  : TInf_CountBy;
    Channel_B_Counts_By  : TInf_CountBy;
    Second_Line          : TInf_Line_Options;
    Posisition_Precision : TPrecision;
  end; // TDevice_Display_OptionsRec

  TDevice_SensorData = packed record
    Channel         : TInf_Channels;
    SerialNumber    : TCell_SN;
    MaxLoad         : Double;
    SensimVPerV     : Array[1..5] of Double;
    Excitation      : TCell_Excitation;
    LastCalibration : String[8];
    Shunt           : Double;
  end; // TDevice_SensorData

//  TDevice_Stored_SensorData = Array[0..5] of TDevice_SensorData;

  TInterfaceUnit_Device = Class;

  TDevice_State = (Idle,CommandReady,ListeningForResponse,CommandCompleted);

  // Device Events
  TGenericDeviceEvent = procedure(Sender : TObject; Device : TInterfaceUnit_Device) of Object;
  TDeviceTimeOut = TGenericDeviceEvent;
  TDeviceError = TGenericDeviceEvent;
  TDeviceResponse = TGenericDeviceEvent;
  TDeviceIdentify = TGenericDeviceEvent;
  TDeviceSystemOptions = TGenericDeviceEvent;
  TDeviceDisplayOptions = TGenericDeviceEvent;
  TDeviceSensorData = procedure(Sender : TObject; Device : TInterfaceUnit_Device; Channel : TInf_Channels) of Object;
  TDeviceStateChange = TGenericDeviceEvent;

  TInterfaceListenDevice = class(TComponent)
  private
    FOnCheckFinished : TNotifyEvent;
    FSerialPort : TApdComPort;
    FSerialPortPacket : TApdDataPacket;
    FDeviceList : TStringList;
    FTmrBroadCastTimeOut : TTimer;
    FEnabled : Boolean;
  protected
    procedure SetEnabled(Value : Boolean);
    procedure SetComPort(Port : TApdComPort);
    function GetBroadCastTimeOut : LongInt;
    procedure SetBroadCastTimeOut(Value : LongInt);
    function GetActiveDevices : TStringList;
    procedure SerialPortBroadCastPacket(Sender: TObject; Data: Pointer;
      Size: Integer);
    procedure SerialPortBroadCastPacketTimeOut(Sender: TObject);
    procedure TmrBroadCastTimeOut(Sender : TObject);
    function Parse_Address_From_Response(Response : String) : TInf_Address;
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    property Enabled : Boolean read FEnabled write SetEnabled;
    property ComPort : TApdComPort write SetComPort;
    property BroadCastTimeOut : LongInt read GetBroadCastTimeOut write SetBroadCastTimeOut;
    property ActiveDevices : TStringList read GetActiveDevices;
    property OnActiveDeviceScanFinished : TNotifyEvent read FOnCheckFinished write FOnCheckFinished;
  end; // TInterfaceListenDevice

  TInterfaceUnit_Device = class(TComponent)
  private
    FOnDeviceTimeOut : TDeviceTimeOut;
    FOnDeviceResponse : TDeviceResponse;
    FOnDeviceIndentify : TDeviceIdentify;
    FOnDeviceSystemOptions : TDeviceSystemOptions;
    FOnDeviceDisplayOptions : TDeviceDisplayOptions;
    FOnDeviceSensorData : TDeviceSensorData;
    FOnDeviceStateChange : TDeviceStateChange;
    FDeviceState : TDevice_State;
    FComPort : TApdComPort;
    FAddress : TInf_Address;
    FLastCommand : TInf_Command;
    FDataReturned : TInf_Command_Result;
    FDeviceSerialPortPacket : TApdDataPacket;
    FDeviceTimedOut : Boolean;
    FCommandList : TStringList;
    FTmrTimeOutFailSafe : TTimer;
    FAutoActive : Boolean;
    FResponseExpected : Boolean;
    FDeviceInfo : TDevice_InfoRec;
    FSystemOptions : TDevice_System_OptionsRec;
    FDisplayOptions : TDevice_Display_OptionsRec;
    FSensorData : Array[Ch_A..Ch_B] of TDevice_SensorData;
    FLastResponseRecieved : DWord;
    FDelayBeforeNextCommand : DWord;
  protected
    procedure SetComPort(Value : TApdComPort);
    procedure SetTimeOut(Value : LongInt);
    procedure SetAddress(Value : TInf_Address);
    function GetTimeOut : LongInt;
    function GetDeviceActive : Boolean;
    procedure SetDeviceActive(Value : Boolean);
    procedure SetCommand(Value : TDevice_CommandRec);
    function GetCommand : TDevice_CommandRec;
    function GetDeviceAutoActive : Boolean;
    function GetExpectResposnse : Boolean;
    function GetSensorData(Channel : TInf_Channels) : TDevice_SensorData;
    procedure Parse_Response;
    procedure Purge_CommandList;
    procedure Device_State(NewState : TDevice_State);
    procedure DeviceSerialPortPacket(Sender: TObject; Data: Pointer;
      Size: Integer);
    procedure DeviceSerialPortPacketTimeOut(Sender: TObject);
    procedure TimeOutFailSafeTimer(Sender : TObject);
    procedure DoParseDeviceIdentity(Response : String);
    procedure DoParseDeviceSystemOptions(Response : String);
    procedure DoParseDeviceDisplayOptions(Response : String);
    procedure DoParseDeviceSensorData(Response : String; Channel : TInf_Channels);
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    // Device Descriptions
    property DeviceInfo : TDevice_InfoRec read FDeviceInfo;
    property SystemOptions : TDevice_System_OptionsRec read FSystemOptions;
    property DisplayOptions : TDevice_Display_OptionsRec read FDisplayOptions;
    property SensorData[Channel : TInf_Channels] : TDevice_SensorData read GetSensorData;
    // Device Settings
    property ComPort : TApdComPort read FComPort write SetComPort;
    property Address : TInf_Address read FAddress write SetAddress;

    property Active : Boolean read GetDeviceActive write SetDeviceActive;
    property AutoActive : Boolean read GetDeviceAutoActive{ write SetDeviceAutoActive};
    property ExpectResponse : Boolean read GetExpectResposnse;
    property State : TDevice_State read FDeviceState;
    property CommsTimeOut : LongInt read GetTimeOut write SetTimeOut;
    property Command : TDevice_CommandRec read GetCommand write SetCommand;
    property LastCommand : TInf_Command read FLastCommand;
    property DataReturned : TInf_Command_Result read FDataReturned{ write SetDataReturned};
    property LastCommandSentAt : DWord read FLastResponseRecieved;
    property DelayBeforeNextCommand : DWord read FDelayBeforeNextCommand;

    property OnDeviceTimeOut : TDeviceTimeOut read FOnDeviceTimeOut write FOnDeviceTimeOut;
    property OnDeviceResponse : TDeviceResponse read FOnDeviceResponse write FOnDeviceResponse;
    property OnDeviceIdenify : TDeviceIdentify read FOnDeviceIndentify write FOnDeviceIndentify;
    property OnDevieSystemOptions : TDeviceSystemOptions read FOnDeviceSystemOptions write FOnDeviceSystemOptions;
    property OnDeviceDisplayOptions : TDeviceDisplayOptions read FOnDeviceDisplayOptions write FOnDeviceDisplayOptions;
    property OnDeviceSensorData : TDeviceSensorData read FOnDeviceSensorData write FOnDeviceSensorData;
    property OnDeviceStateChange : TDeviceStateChange read FOnDeviceStateChange write FOnDeviceStateChange;
  end; // TInterfaceUnit_Device

  TDevices = Array[1..Max_Devices] of TInterfaceUnit_Device; // Holds address and state of each active device.

  // Interface Events
  TGenericInterfaceEvent = procedure(Sender : TObject; DeviceAddress : TInf_Address) of Object;
  TInterfaceDeviceTimeOut = TGenericInterfaceEvent;
  TInterfaceError = procedure(Sender : TObject; DeviceAddress : TInf_Address; ErrorMsg : String) of Object;
  TInterfaceDeviceResponse = procedure(Sender : TObject; DeviceAddress : TInf_Address; CompletedCommand : TInf_Command_String; Response : TInf_Command_Result) of Object;
  TInterfaceNewDevice = procedure(Sender : TObject; DeviceAddress : TInf_Address; DeviceInfo : TDevice_InfoRec) of Object;
  TInterfaceNewSystemOptions = procedure (Sender : TObject; DeviceAddres : TInf_Address; SystemOptions : TDevice_System_OptionsRec) of Object;
  TInterfaceNewDisplayOptions = procedure(Sender : TObject; DeviceAddress : TInf_Address; DisplayOptions : TDevice_Display_OptionsRec) of Object;
  TInterfaceNewSensorData = procedure(Sender : TObject; DeviceAddress :TInf_Address; Channel : TInf_Channels; SensorData : TDevice_SensorData) of Object;
  TInterfaceDeviceRemoved = TGenericInterfaceEvent;
  TInterfaceDeviceStateChange = procedure(Sender : TObject; DeviceAddress : TInf_Address; State : TDevice_State) of Object;

  TInterfaceUnit_Interface = class(TComponent)
  private
  {Private declarations}
    FOnInteraceIdentifyDeviceTimeOut : TNotifyEvent;
    FOnInterfaceTimeOut : TInterfaceDeviceTimeOut;
    FOnInterfaceResponse : TInterfaceDeviceResponse;
    FOnInterfaceError : TInterfaceError;
    FOnInterfaceNewDevice : TInterfaceNewDevice;
    FOnInterfaceNewSystemOptions : TInterfaceNewSystemOptions;
    FOnInterfaceNewDisplayOptions : TInterfaceNewDisplayOptions;
    FOnInterfacenewSensorData : TInterfaceNewSensorData;
    FOnInterfaceDeviceRemoved : TInterfaceDeviceRemoved;
    FOnInterfaceDeviceStateChange : TInterfaceDeviceStateChange;
    frmDeviceStatus : TfrmDeviceStatus;
    FSerialPort1: TApdComPort;
    FSerialComNumber : Word;
    FSerialBaudRate : TInf_Baud;
    FDevice : TDevices;
    FEnabled : Boolean;
    FTmrSendNextCommand : TTimer;
    FDeviceCommandReadyStack : TStringList;
    FActiveDeviceList : TStringList;
    FPurgeCommandsWhenDisabled : Boolean;
    FShowActivityWindow : Boolean;
    FVersion : ShortString;
    FListeningDevice : TInterfaceListenDevice;
    FIdentifyDeviceTimeOut : LongInt;
    FPrettyPrint : Boolean;
    DebugTXT : TStringList;
    FDefaultCommandTimeOut : DWord;
    procedure TmrSendNextCommand(Sender : TObject);
  protected
  {Protected declarations}
    procedure DoCommandScriptError(CommandNum : LongInt);
    procedure SetEnabled(Value : Boolean);
    function GetActiveDeviceCount : LongInt;
    procedure SetShowActivityWindow(Value : Boolean);
    procedure SetVersion(Value : ShortString);
    function GetVersion : ShortString;
    function GetIdentifyDeviceTimeOut : LongInt;
    procedure SetIdentifyDeviceTimeOut(Value : LongInt);
    function GetDeviceExists(Address : TInf_Address) : Boolean;
    procedure SetDeviceStatusWindowTop(Value : LongInt);
    function GetDeviceStatusWindowTop : LongInt;
    procedure SetDeviceStatusWindowLeft(Value : LongInt);
    function GetDeviceStatusWindowLeft : LongInt;
    // Unility routines
    procedure Delay(WaitTimeMs : LongInt);
    function InitializeComPort : Boolean;
    procedure CloseComPort;
    procedure PurgeWatingCommands;
    procedure Send_CMD(Var Device : TInterfaceUnit_Device);
    function DeviceWaitingToSend : TInterfaceUnit_Device;
    procedure Get_Device(Address : TInf_Address; Var Device : TInterfaceUnit_Device);
    procedure Add_RunCMD_From_Script(Address : TInf_Address; Command : TInf_Run_Mode_Cmd;
              Param1,Param2,Param3,Param4,Param5,Param6,Param7,Param8,Param9,Param10,Param11,Param12 : Integer; Param13 : String);
    procedure Add_SetupCMD_From_Script(Address : TInf_Address; Command : TInf_Setup_Mode_Cmd;
              Param1,Param2,Param3,Param4,Param6,Param7,Param8,Param9,Param10,Param11,Param12,Param13,Param14,Param15 : Integer; Param5,Param16,Param17 : String);
    // Base procedure for sending Run Mode commands
    procedure Send_Run_Mode_Command(Address : TInf_Address; Var CommandRec : TDevice_CommandRec);
    function Gen_Run_Mode_Command(Address : TInf_Address; Command : TInf_Run_Mode_CMD; Optional_String : TInf_Command_String) : ShortString;
    procedure Send_Setup_Mode_Command(Address : TInf_Address; Var CommandRec : TDevice_CommandRec);
    function Gen_Setup_Mode_Command(Address : TInf_Address; Command : TInf_Setup_Mode_Cmd; Optional_String : TInf_Command_String) : ShortString;
    // Device Events
    procedure DeviceTimeOut(Sender : TObject; Device : TInterfaceUnit_Device);
    procedure DeviceResponse(Sender : TObject; Device : TInterfaceUnit_Device);
    procedure DeviceIdentify(Sender : TObject; Device : TInterfaceUnit_Device);
    procedure DeviceSystemOptions(Sender : TObject; Device : TInterfaceUnit_Device);
    procedure DeviceDisplayOptions(Sender : TObject; Device: TInterfaceUnit_Device);
    procedure DeviceSensorData(Sender : TObject; Device : TInterfaceUnit_Device; Channel : TInf_Channels);
    procedure DeviceStateChange(Sender : TObject; Device : TInterfaceUnit_Device);
    procedure ActiveDeviceScanFinsished(Sender : TObject);
  public
  {Public declarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure Load_Command_Script(FileName : String);
    function Device_Add(NewAddress : TInf_Address; TimeOutPeriod : LongInt; Identify : Boolean) : TInterfaceUnit_Device;
    procedure Device_Remove(Address : TInf_Address);
    // Device Run Commands
    procedure Device_Identify(Address : TInf_Address);
    procedure Device_Hello(Address : TInf_Address);
    procedure Device_QuestionMark(Address : TInf_Address);
    procedure Device_Front_Panel_View(Address : TInf_Address);
    procedure Device_Front_Panel_Set(Address : TInf_Address; Item : TItem_Numbers; Item_Unit : TItem_Units);
    procedure Device_Front_Panel_Alternate(Address : TInf_Address);
    procedure Device_Front_Panel_Pointer(Address : TInf_Address; Line : Byte);
    procedure Device_Value(Address : TInf_Address; Item_Number : TItem_Numbers; Item_Unit : TItem_Units; RepeatOption : TValue_Repeat);
    procedure Device_Print(Address : TInf_Address; RepeatOption : TPrint_Repeat);
    procedure Device_Reset(Address : TInf_Address; TareA : Boolean; PeakA : Boolean; ValleyA : Boolean;
      TareB : Boolean; PeakB : Boolean; ValleyB : Boolean; Item_Number : TItem_Numbers);
    procedure Device_Freeze_Display(Address : TInf_Address; FreezeDispay : Boolean);
    procedure Device_Display_Text(Address : TInf_Address; TextToDisplay : TInf_Command_String);
    // Device Setup Command Routines
    procedure Device_User_Data_View(Address : TInf_Address);
    procedure Device_User_Data_Area(Address : TInf_Address; Channel : TInf_Channels; NewArea : Single);
    procedure Device_User_Data_Length(Address : TInf_Address; NewLength : Single);
    procedure Device_Analog_Output_View(Address : TInf_Address);
    procedure Device_Analog_Output_Set(Address : TInf_Address; Item_Number : TItem_Numbers; Item_Unit : TItem_Units; FullScale : Single; ZeroScale : Single);
    procedure Device_Sensor_View_Channel(Address : TInf_Address; Channel : TInf_Channels);
    procedure Device_Sensor_View(Address : TInf_Address);
    procedure Device_Sensor_Select(Address : TInf_Address; Channel : TInf_Channels; SerialNumber : TCell_SN);
    procedure Device_Sensor_Delete(Address : TInf_Address; SerialNumber : TCell_SN);
    procedure Device_Sensor_ViewTEDS(Address : TInf_Address; Channel : TInf_Channels);
    procedure Device_Calibration_Begin(Address : TInf_Address; Cell_Type : TCell_Type;
      Channel : TInf_Channels; Cell_SN : TCell_SN; CalDate : TCell_Date; Excitation : TCell_Excitation;
      Units : TCell_Units; Rated_Load : Single);
    procedure Device_Calibration_Escape(Address : TInf_Address);
    procedure Device_Calibration_Check(Address : TInf_Address; Channel : TInf_Channels);
    procedure Device_Calibrate_By_mVPerV_1pt(Address : TInf_Address; mVPerV : Single);
    procedure Device_Calibrate_By_mVPerV_6pt(Address : TInf_Address);
    procedure Device_Calibrate_mVPerV_Mass(Address : TInf_Address; PointNum : Byte; Value : Single);
    procedure Device_Calibrate_mVPerV_Volt(Address : TInf_Address; PointNum : Byte; Value : Single);
    procedure Device_Calibrate_mVPerV_Torque(Address: TInf_Address; PointNum : Byte; Value : Single);
    procedure Device_Calibrate_By_Masses(Address : TInf_Address; NumPoints : TInf_Num_Cal_Points);
    procedure Device_Calibrate_By_Masses_Point(Address : TInf_Address; PointNum : Byte; Value : Single);
    procedure Device_Calibrate_By_Torque(Address : TInf_Address; NumPoints : TInf_Num_Cal_Points);
    procedure Device_Calibrate_By_Torque_Point(Address : TInf_Address; PointNum : Byte; Value : Single);
    procedure Device_Calibrate_By_Shunt(Address : TInf_Address; ShuntValue : Single);
    procedure Device_Calibrate_CountsPerInch_View(Address : TInf_Address);
    procedure Device_Calibrate_CountsPerInch_Set(Address : TInf_Address; NewCountsPerInch : LongInt);
    procedure Device_Limit_View(Address : TInf_Address; LimitNumber : TInf_Limit_Numbers);
    procedure Device_Limit_Define(Address :  TInf_Address; LimitNumber : TInf_Limit_Numbers; NormalPosition : Boolean;
      LimitEnabled : Boolean; Item_Number : TItem_Numbers; Item_Unit : TItem_Units);
    procedure Device_Limit_SetPoint(Address : TInf_Address; LimitNumber : TInf_Limit_Numbers; SetPoint : Single);
    procedure Device_Limit_Latching(Address : TInf_Address; LimitNumber : TInf_Limit_Numbers; Opperator : TInf_Opperators; Latching : Boolean);
    procedure Device_Limit_Reset_Level(Address : TInf_Address; LimitNumber : TInf_Limit_Numbers; SetPoint : Single);
    procedure Device_Limit_Escape(Address : TInf_Address);
    procedure Device_Limit_Reset(Address : TInf_Address; LimitNumber : TInf_Limit_Numbers);
    procedure Device_Option_View(Address : TInf_Address);
    procedure Device_Option_Printer(Address : TInf_Address; PrinterOpCode : TInf_Pntr_OpCode);
    procedure Device_Option_Auto_Identify(Address : TInf_Address; AutoIdentifyON : Boolean);
    procedure Device_Option_Auto_Identify_Annuciator(Address : TInf_Address; AnnuciatorON : Boolean);
    procedure Device_Option_TEDS(Address : TInf_Address; TEDSEnabled : Boolean);
    procedure Device_Option_Auto_Tare(Address : TInf_Address; AutoTareON : Boolean);
    procedure Device_Option_Auto_Zeroing(Address : TInf_Address; AutoZeroON : Boolean);
    procedure Device_Option_Com_Address(Address : TInf_Address; NewAddress : TInf_Address);
    procedure Device_Option_Com_BaudRate(Address : TInf_Address; NewBaud : TInf_Baud);
    procedure Device_Option_Com_LineFeed(Address : TInf_Address; LineFeedON : Boolean);
    procedure Device_Option_Retain_Tare(Address : TInf_Address; RetainTareON : Boolean);
    procedure Device_Option_EndOfTransmision(Address : TInf_Address; EOT_ON : Boolean);
    procedure Device_Display_View(Address : TInf_Address);
    procedure Device_Display_Filter(Address : TInf_Address; FilterType : TFilterTypes; FilterLevel : TFilterLevels);
    procedure Device_Display_Decimal(Address : TInf_Address; Channel : TInf_Channels; Precision : TPrecision);
    procedure Device_Display_Position_Decimal(Address : TInf_Address; Precision : TPrecision);
    procedure Device_Display_Count_By(Address : TInf_Address; Channel : TInf_Channels; CountBy : TInf_CountBy);
    procedure Device_Display_Second_Line(Address : TInf_Address; Channel : TInf_Channels; LineOption : TInf_Line_Options);
    procedure Device_Display_Second_Line_Text(Address : TInf_Address; DisplayText : TInf_Command_String);
    procedure Device_Display_FilterWindow(Address : TInf_Address; Channel : TInf_Channels; FilterEnabled : Boolean);
    procedure Device_Display_FitlerWidnow_Set(Address : TInf_Address; Channel : TInf_Channels; Window_Unit : TItem_Units; Window_Value : Single);
    property DeviceExists[Address : TInf_Address] : Boolean read GetDeviceExists;
  published
  {Published declarations}
    property Version : ShortString read GetVersion write SetVersion;
    property Enabled : Boolean read FEnabled write SetEnabled;
    property DisablePurgeCommands : Boolean read FPurgeCommandsWhenDisabled write FPurgeCommandsWhenDisabled;
    property ActiveDeviceCount : LongInt read GetActiveDeviceCount;
    property ShowActivityWindow : Boolean read FShowActivityWindow write SetShowActivityWindow;
    property ComPort : Word read FSerialComNumber write FSerialComNumber;
    property BaudRate : TInf_Baud read FSerialBaudRate write FSerialBaudRate;
    property IdentifyActiveDevicePeriod : LongInt read GetIdentifyDeviceTimeOut write SetIdentifyDeviceTimeOut;
    property PrettyPrint : Boolean read FPrettyPrint write FPrettyPrint;
    property DefaultCommandTimeOut : DWord read FDefaultCommandTimeOut write FDefaultCommandTimeOut;
    property DeviceActivityWindowTop : LongInt read GetDeviceStatusWindowTop write SetDeviceStatusWindowTop;
    property DeviceActivityWindowLeft : LongInt read GetDeviceStatusWindowLeft write SetDeviceStatusWindowLeft;

    property OnInterfaceIdentifyActiveDevicesFinished : TNotifyEvent read FOnInteraceIdentifyDeviceTimeOut write FOnInteraceIdentifyDeviceTimeOut;
    property OnInterfaceTimeOut : TInterfaceDeviceTimeOut read FOnInterfaceTimeOut write FOnInterfaceTimeOut;
    property OnInterfaceResponse : TInterfaceDeviceResponse read FOnInterfaceResponse write FOnInterfaceResponse;
    property OnInterfaceError : TInterfaceError read FOnInterfaceError write FOnInterfaceError;
    property OnInterfaceNewDevice : TInterfaceNewDevice read FOnInterfaceNewDevice write FOnInterfaceNewDevice;
    property OnInterfaceNewSystemOptions : TInterfaceNewSystemOptions read FOnInterfaceNewSystemOptions write FOnInterfaceNewSystemOptions;
    property OnInterfaceNewDisplayOptions : TInterfaceNewDisplayOptions read FOnInterfaceNewDisplayOptions write FOnInterfaceNewDisplayOptions;
    property OnInterfaceNewSensorData : TInterfaceNewSensorData read FOnInterfacenewSensorData write FOnInterfacenewSensorData;
    property OnInterfaceDeviceRemoved : TInterfaceDeviceRemoved read FOnInterfaceDeviceRemoved write FOnInterfaceDeviceRemoved;
    property OnInterfaceDeviceStateChange : TInterfaceDeviceStateChange read FOnInterfaceDeviceStateChange write FOnInterfaceDeviceStateChange;
  end; // TInterfaceUit_Interface

function Device_Convert_Address(StrAddress : ShortString; Var Address : TInf_Address) : Boolean;
function Parse_Device_Model(Var Response : String) : ShortString;
function Parse_Device_Version(Var Response : String) : ShortString;
function Parse_Device_Serial_Num(Var Response : String) : ShortString;
function Parse_Device_Options(Var Response : String) : ShortString;

procedure Register;

implementation
{_R Interface_Commands.dcr}

Uses AdExcept, StRegINI;

 procedure Register;
 begin
   RegisterComponents('TMSI',[TInterfaceUnit_Interface]);
 end; // Register

function Device_Convert_Address(StrAddress : ShortString; Var Address : TInf_Address) : Boolean;
var
  TmpAddress : SmallInt;
begin
  Result := True;
  try
    TmpAddress := StrToInt(StrAddress);
    if (TmpAddress > 0) and (TmpAddress < (Max_Devices - 1)) then // Address 0 is never used, and Address 255 is reserved for broadcasting.
      Address := TmpAddress
    else
      Result := False;
  except
    Result := False;
  end; // If
end; // TInterfaceUnit_Interface.Device_Convert_Address

function Parse_Device_Model(Var Response : String) : ShortString;
var
  Pos1 : LongInt;
  Pos2 : LongInt;
begin
  Pos1 := MatchString(Response,' ',1,1,False,True);
  Pos2 := MatchString(Response,' ',2,1,False,True);
  Result := Copy(Response,(Pos1 + 1),(Pos2 - Pos1) - 1);
end; // Parse_Device_Model

function Parse_Device_Version(Var Response : String) : ShortString;
var
  Pos1 : LongInt;
  Pos2 : LongInt;
begin
  Pos1 := MatchString(Response,' ',3,1,False,True);
  Pos2 := MatchString(Response,' ',4,1,False,True);
  Result := Copy(Response,(Pos1 + 1),(Pos2 - Pos1) - 1);
end; // Parse_Device_Version

function Parse_Device_Serial_Num(Var Response : String) : ShortString;
var
  Pos1 : LongInt;
  Pos2 : LongInt;
begin
  Pos1 := MatchString(Response,' ',7,1,False,True);
  Pos2 := MatchString(Response,' ',8,1,False,True);
  Result := Copy(Response,(Pos1 + 1),(Pos2 - Pos1) - 1);
end; // Parse_Device_Serial_Num

function Parse_Device_Options(Var Response : String) : ShortString;
var
  Pos1 : LongInt;
  Pos2 : LongInt;
begin
  Pos1 := MatchString(Response,' ',10,1,False,True);
  Pos2 := Length(Response) - 1;
  Result := Copy(Response,(Pos1 + 1),(Pos2 - Pos1) - 1);
end; // Parse_Device_Options

constructor TDevice_Command.Create(AOwner : TComponent);
begin
  inherited Create;
  FCommand := '';
  FAutoActive := False;
  FResponseExpected := True;
  FDelayNextCommandFor := 200{ms};
end; // TDevice_Command.Create

constructor TInterfaceListenDevice.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FEnabled := False;
  FSerialPort := Nil;
  FSerialPortPacket := TApdDataPacket.Create(Self);
  with FSerialPortPacket do
  begin
    Enabled := False;
    AutoEnable := False;
    ComPort := FSerialPort;
    StartCond := scString;
    StartString := '##'; //
    EndCond := [ecString];
    EndString := #13;
    TimeOut := 182;
    IgnoreCase := True;
    OnPacket := SerialPortBroadCastPacket;
    OnTimeout := SerialPortBroadCastPacketTimeOut;
  end; // With
  FDeviceList := TStringList.Create;
  FTmrBroadCastTimeOut := TTimer.Create(Self);
  with FTmrBroadCastTimeOut do
  begin
    Enabled := False;
    Interval := 5000;
    OnTimer := TmrBroadCastTimeOut;
  end; // With
end; // TInterfaceListenDevice.Create

destructor TInterfaceListenDevice.Destroy;
begin
  FDeviceList.Free;
  FSerialPortPacket.Free;
  inherited Destroy;
end; // TInterfaceListenDevice.Destroy

procedure TInterfaceListenDevice.SetEnabled(Value : Boolean);
begin
  FEnabled := Value;
  FSerialPortPacket.Enabled := FEnabled;
  FSerialPortPacket.AutoEnable := FEnabled;
  FTmrBroadCastTimeOut.Enabled := FEnabled;
end; // TInterfaceListenDevice.SetEnabled

procedure TInterfaceListenDevice.SetComPort(Port : TApdComPort);
begin
  FSerialPort := Port;
  FSerialPortPacket.ComPort := FSerialPort;
end; // TInterfaceListenDevice.SetComPort

function TInterfaceListenDevice.GetBroadCastTimeOut : LongInt;
begin
  Result := FTmrBroadCastTimeOut.Interval;
end; // TInterfaceListenDevice.GetBroadCastTimeOut

procedure TInterfaceListenDevice.SetBroadCastTimeOut(Value : LongInt);
begin
  FTmrBroadCastTimeOut.Interval := Value;
end; // TInterfaceListenDevice.SetBroadCastTimeOut

function TInterfaceListenDevice.GetActiveDevices : TStringList;
var
  i : LongInt;
begin
  Result := TStringList.Create;
  Result.Clear;
  for i := 0 to (FDeviceList.Count - 1) do
    Result.Add(FDeviceList.Strings[i]);
end; // TInterfaceListenDevice.GetActiveDevices

procedure TInterfaceListenDevice.SerialPortBroadCastPacket(Sender: TObject; Data: Pointer;
  Size: Integer);
var
  i : LongInt;
  DataChar : Array[0..1023] of ANSIChar;
  TmpStr : String;
  DeviceAddress : TInf_Address;
  DeviceIndex : LongInt;
begin
  TmpStr := '';
  FillChar(DataChar,SizeOf(DataChar),#0);
  StrLCopy(PAnsiChar(DataChar[0]),Data,SizeOf(DataChar));
  DataChar[Size] := #0;
  for i := 0 to (Size - 1) do
    TmpStr := TmpStr + DataChar[i];
  DeviceAddress := Parse_Address_From_Response(TmpStr);
  if (DeviceAddress in [1..254]) then
  begin
    DeviceIndex := FDeviceList.IndexOf(IntToStr(DeviceAddress));
    if (DeviceIndex = -1) then
      FDeviceList.Add(IntToStr(DeviceAddress));
  end; // If
end; // TInterfaceListenDevice.SerialPortBroadCastPacket

procedure TInterfaceListenDevice.SerialPortBroadCastPacketTimeOut(Sender: TObject);
begin
  FEnabled := False;
  FSerialPortPacket.Enabled := FEnabled;
  FSerialPortPacket.AutoEnable := FEnabled;
  if Assigned(FOnCheckFinished) then
    FOnCheckFinished(Self);
end; // TInterfaceListenDevice.SerialPortBroadCastPacketTimeOut

procedure TInterfaceListenDevice.TmrBroadCastTimeOut(Sender : TObject);
begin
  FTmrBroadCastTimeOut.Enabled := False;
  SerialPortBroadCastPacketTimeOut(FTmrBroadCastTimeOut);
end; // TInterfaceListenDevice.TmrBroadCastTimeOut

function TInterfaceListenDevice.Parse_Address_From_Response(Response : String) : TInf_Address;
var
  StartPos : LongInt;
  EndPos : LongInt;
  TmpStr : ShortString;
begin
  StartPos := MatchString(Response,' ',1,1,False,False);
  EndPos := MatchString(Response,' ',2,1,False,False);
  TmpStr := Copy(Response,(StartPos + 1),((EndPos - 1) - StartPos));
  if Not Device_Convert_Address(TmpStr,Result) then
    Result := 255;
end; // TInterfaceUnit_Interface.Parse_Address_From_Response

constructor TInterfaceUnit_Device.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FAddress := 0;
  FDeviceState := Idle;
  FLastCommand := '';
  FDataReturned := '';
  FDeviceTimedOut := False;
  FAutoActive := False;
  FResponseExpected := True;
  FLastResponseRecieved := 0;
  FDelayBeforeNextCommand := 100{ms};
  FillChar(FDeviceInfo,SizeOf(FDeviceInfo),#0);
  FillChar(FSystemOptions,SizeOf(FSystemOptions),#0);
  FillChar(FDisplayOptions,SizeOf(FDisplayOptions),#0);;
  FillChar(FSensorData,SizeOf(FSensorData),#0);
  FCommandList := TStringList.Create;
  FTmrTimeOutFailSafe := TTimer.Create(Self);
  with FTmrTimeOutFailSafe do
  begin
    Enabled := False;
    Interval := 10500;
    OnTimer := TimeOutFailSafeTimer;
  end; // With
  FDeviceSerialPortPacket := TApdDataPacket.Create(Self);
  with FDeviceSerialPortPacket do
  begin
    Enabled := False;
    AutoEnable := False;
    ComPort := FComPort;
    StartCond := scString;
    StartString := '@';
    EndCond := [ecString];
    EndString := #4;
    TimeOut := 182;
    IgnoreCase := True;
    OnPacket := DeviceSerialPortPacket;
    OnTimeout := DeviceSerialPortPacketTimeOut;
  end; // With
end; // TInterfaceUnit_Device.Create

destructor TInterfaceUnit_Device.Destroy;
begin
  FTmrTimeOutFailSafe.Free;
  Purge_CommandList;
  FCommandList.Free;
  FDeviceSerialPortPacket.Free;
  inherited Destroy;
end; // TInterfaceUnit_Device.Destroy

procedure TInterfaceUnit_Device.SetComPort(Value : TApdComPort);
begin
  if Assigned(Value) then
  begin
    FComPort := Value;
    FDeviceSerialPortPacket.ComPort := FComPort;
  end; // If
end; // TInterfaceUnit_Device.SetComPort

procedure TInterfaceUnit_Device.SetTimeOut(Value : LongInt);
var
  TmpInt : LongInt;
begin
  TmpInt := Trunc(0.0182 * Value);
  FTmrTimeOutFailSafe.Interval := Value + 500{ms};
  FDeviceSerialPortPacket.TimeOut := TmpInt;
end; // TInterfaceUnit_Device.SetTimeOut

procedure TInterfaceUnit_Device.SetAddress(Value : TInf_Address);
begin
  FAddress := Value;
  FDeviceSerialPortPacket.StartString := format('@ %0.3d',[FAddress]);
end; // TInterfaceUnit_Device.SetAddress

function TInterfaceUnit_Device.GetTimeOut : LongInt;
begin
  Result := Trunc(FDeviceSerialPortPacket.TimeOut / 0.0182);
end; // TInterfaceUnit_Device.GetTimeOut

function TInterfaceUnit_Device.GetDeviceActive : Boolean;
begin
  Result := FDeviceSerialPortPacket.Enabled;
end; // TInterfaceUnit_Device.GetDeviceActive

procedure TInterfaceUnit_Device.SetDeviceActive(Value : Boolean);
begin
  if (FDeviceSerialPortPacket.Enabled <> Value) then
    FDeviceSerialPortPacket.Enabled := Value;
end; // TInterfaceUnit_Device.SetDeviceActive

function TInterfaceUnit_Device.GetDeviceAutoActive : Boolean;
var
  Command_Packet : TDevice_Command;
begin
  if (FCommandList.Count > 0) then
  begin
    Command_Packet := (FCommandList.Objects[0] as TDevice_Command);
    Result := Command_Packet.AutoActive;
  end
  else
    Result := False;
end; // TInterfaceUnit_Device.GetDeviceAutoActive

function TInterfaceUnit_Device.GetExpectResposnse : Boolean;
var
  Command_Packet : TDevice_Command;
begin
  if (FCommandList.Count > 0) then
  begin
    Command_Packet := (FCommandList.Objects[0] as TDevice_Command);
    Result := Command_Packet.ExpectResponse;
  end
  else
    Result := True;
end; // TInterfaceUnit_Device.GetExpectResponse

function TInterfaceUnit_Device.GetSensorData(Channel : TInf_Channels) : TDevice_SensorData;
begin
  Result := FSensorData[Channel];
end; // TInterfaceUnit_Device.GetSensorData

procedure TInterfaceUnit_Device.SetCommand(Value : TDevice_CommandRec);
var
  Command_Packet : TDevice_Command;
begin
  FDataReturned := '';
  Command_Packet := TDevice_Command.Create(Self);
  with Command_Packet do
  begin
    Command := Value.DeviceCommand;
    AutoActive := Value.AutoActive;
    ExpectResponse := Value.ExpectResponse;
    DelayNextCommandFor := Value.DelayNextCommandFor;
  end; // With
  FCommandList.AddObject(Command_Packet.Command,Command_Packet);
  Device_State(CommandReady);
end; // TInterfaceUnit_Device.SetCommand

function TInterfaceUnit_Device.GetCommand : TDevice_CommandRec;
var
  Command_Packet : TDevice_Command;
begin
  FillChar(Result,SizeOf(Result),#0);
  if (FCommandList.Count > 0) then
  begin
    Command_Packet := (FCommandList.Objects[0] as TDevice_Command);
    FLastCommand := Command_Packet.Command;
    FResponseExpected := Command_Packet.ExpectResponse;
    FAutoActive := Command_Packet.AutoActive;
    FDelayBeforeNextCommand := Command_Packet.DelayNextCommandFor;
    if FAutoActive and FDeviceSerialPortPacket.AutoEnable then
    begin
      if (FCommandList.Count > 1) then
        Device_State(CommandReady)
      else
        Device_State(Idle);
    end
    else
    begin
      if FResponseExpected then
        Device_State(ListeningForResponse);
    end; // If
    if Assigned(FComPort) then
    begin
      FTmrTimeOutFailSafe.Enabled := FResponseExpected;
      FDeviceSerialPortPacket.Enabled := True;
      FDeviceSerialPortPacket.AutoEnable := FAutoActive;
      if FDeviceSerialPortPacket.AutoEnable then
        FDeviceSerialPortPacket.EndString := #13
      else
        FDeviceSerialPortPacket.EndString := #4;
    end; // If
    FCommandList.Delete(0);
    Command_Packet.Free;
    with Result do
    begin
      DeviceCommand := FLastCommand;
      AutoActive := FAutoActive;
      ExpectResponse := FResponseExpected;
    end; // With
  end;
end; // TInterfaceUnit_Device.GetCommand

procedure TInterfaceUnit_Device.Parse_Response;
var
  SpacePos : LongInt;
  StrAddress : String[3];
  Address : TInf_Address;
begin
  SpacePos := MatchString(FDataReturned,' ',1,1,False,True);
  StrAddress := Copy(FDataReturned,(SpacePos + 1),(MatchString(FDataReturned,' ',2,1,False,True) - SpacePos));
  if Device_Convert_Address(StrAddress,Address) then
  begin
    if (Address = FAddress) then
    begin
      FTmrTimeOutFailSafe.Enabled := False;
      FDataReturned := Copy(FDataReturned,((SpacePos + 1) + Length(StrAddress) + 1),(Length(FDataReturned) - (SpacePos + 1)));
      if (FLastCommand = format('@%0.3dH' + #13,[FAddress])) then
        DoParseDeviceIdentity(FDataReturned);
      if (FLastCommand = format('@%0.3dOV' + #13,[FAddress])) then
        DoParseDeviceSystemOptions(FDataReturned);
      if (FLastCommand = format('@%0.3dDV' + #13,[FAddress])) then
        DoParseDeviceDisplayOptions(FDataReturned);
      if (FLastCommand = format('@%0.3dSA' + #13,[FAddress])) then
        DoParseDeviceSensorData(FDataReturned,Ch_A);
      if (FLastCommand = format('@%0.3dSB' + #13,[FAddress])) then
        DoParseDeviceSensorData(FDataReturned,Ch_B);
      Device_State(CommandCompleted);
      if Assigned(FOnDeviceResponse) then
        FOnDeviceResponse(Self,Self);
      FLastResponseRecieved := GetTickCount;
      if (FCommandList.Count > 0) then
        Device_State(CommandReady)
      else
        Device_State(Idle);
    end; // If
  end; // If
end; // TInterfaceUnit_Device.Parse_Response

procedure TInterfaceUnit_Device.Purge_CommandList;
var
  i : LongInt;
  Command_Packet : TDevice_Command;
begin
  Device_State(Idle);
  for i := 0 to (FCommandList.Count - 1) do
  begin
    Command_Packet := (FCommandList.Objects[0] as TDevice_Command);
    Command_Packet.Free;
    FCommandList.Delete(0);
  end; // For i
  FCommandList.Clear;
end; // TInterfaceUnit_Device.Purge_CommandList

procedure TInterfaceUnit_Device.Device_State(NewState : TDevice_State);
begin
  FDeviceState := NewState;
  if Assigned(FOnDeviceStateChange) then
    FOnDeviceStateChange(Self,Self);
end; // TInterfaceUnit_Device.Device_State

procedure TInterfaceUnit_Device.DoParseDeviceIdentity(Response : String);
begin
  FillChar(FDeviceInfo,SizeOf(FDeviceInfo),30);
  FDeviceInfo.Model := Parse_Device_Model(Response);
  FDeviceInfo.Version := Parse_Device_Version(Response);
  FDeviceInfo.SerialNumber := Parse_Device_Serial_Num(Response);
  FDeviceInfo.Options := Parse_Device_Options(Response);
  if Assigned(FOnDeviceIndentify) then
    FOnDeviceIndentify(Self,Self);
end; // TInterfaceUnit_Device.DoParseDeviceIdentity

procedure TInterfaceUnit_Device.DoParseDeviceSystemOptions(Response : String);
var
  TmpStr : ShortString;
  StartPos : LongInt;
  EndPos : LongInt;
  EndItem : LongInt;
begin
  FillChar(FSystemOptions,SizeOf(FSystemOptions),#0); // Reset options...
  Response := UpperCase(Response);
  // Printer Baud Rate
  StartPos := MatchString(Response,'PRINTER BAUD RATE',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,(StartPos + 1),((EndPos - 2) - StartPos));
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    if (TmpStr = '230.4k') then
      FSystemOptions.Printer_Baud_Rate := PB230K;
    if (TmpStr = '57.6k') then
      FSystemOptions.Printer_Baud_Rate := PB57K;
    if (TmpStr = '19.2k') then
      FSystemOptions.Printer_Baud_Rate := PB19K;
    if (TmpStr = '9600') then
      FSystemOptions.Printer_Baud_Rate := PB9600;
    if (TmpStr = '4800') then
      FSystemOptions.Printer_Baud_Rate := PB4800;
  end; // If
  // Auto_Identify
  StartPos := MatchString(Response,'AUTO IDENTIFY',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    FSystemOptions.Auto_Identify := (TmpStr = 'ON');
  end; // If
  // Auto_Identify_Annuciator
  StartPos := MatchString(Response,'AUTO IDENTIFY ANNUNCIATOR',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    FSystemOptions.Auto_Identify_Annuciator := (TmpStr = 'ON');
  end; // If
//  // TEDS
  StartPos := MatchString(Response,'TEDS',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    FSystemOptions.TEDS_ON := (TmpStr = 'on');
  end; // If
  // Auto_Tare
  StartPos := MatchString(Response,'AUTO TARE',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    FSystemOptions.Auto_Tare_ON := (TmpStr = 'ON');
  end; // If
  // Auto_Zero_Channel_A
  StartPos := MatchString(Response,'AUTO ZERO CHANNEL A',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    FSystemOptions.Auto_Zero_Channel_A_ON := (TmpStr = 'ON');
  end; // If
  // Auto_Zero_Channel_B
  StartPos := MatchString(Response,'AUTO ZERO CHANNEL B',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    FSystemOptions.Auto_Zero_Channel_B_ON := (TmpStr = 'ON');
  end; // If
  // Comm_Address
  StartPos := MatchString(Response,'COM ADDRESS',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    Device_Convert_Address(TmpStr,FSystemOptions.Com_Address);
  end; // If
  // Comm_Baud_Rate
  StartPos := MatchString(Response,'COM BAUD RATE',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos) - 1);
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    if (TmpStr = '300') then
      FSystemOptions.Com_Baud_Rate := B300;
    if (TmpStr = '600') then
      FSystemOptions.Com_Baud_Rate := B600;
    if (TmpStr = '1200') then
      FSystemOptions.Com_Baud_Rate := B1200;
    if (TmpStr = '2400') then
      FSystemOptions.Com_Baud_Rate := B2400;
    if (TmpStr = '4800') then
      FSystemOptions.Com_Baud_Rate := B4800;
    if (TmpStr = '9600') then
      FSystemOptions.Com_Baud_Rate := B9600;
    if (TmpStr = '19.2k') then
      FSystemOptions.Com_Baud_Rate := B19200;
  end; // If
  // Comm_Line_Feed
  StartPos := MatchString(Response,'COM LINE FEED',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    FSystemOptions.Com_Line_Feed_ON := (TmpStr = 'ON');
  end; // If
  // Retain_Tare_ON
  StartPos := MatchString(Response,'RETAIN TARE',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    FSystemOptions.Retain_Tare_ON := (TmpStr = 'ON');
  end; // If
  // Freeze_Display
  StartPos := MatchString(Response,'FREEZE DISPLAY',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    FSystemOptions.Freeze_Display_ON := (TmpStr = 'on');
  end; // If
  // RS232_ETO_ON
  StartPos := MatchString(Response,'RS232',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    EndItem := Length(TmpStr);
    StartPos := MatchString(TmpStr,' ',1,EndItem,True,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    FSystemOptions.RS232_EOT_ON := (TmpStr = 'ON');
  end; // If
  if Assigned(FOnDeviceSystemOptions) then
    FOnDeviceSystemOptions(Self,Self);
end; // TInterfaceUnit_Device.DoParseDeviceSystemOptions

procedure TInterfaceUnit_Device.DoParseDeviceDisplayOptions(Response : String);
var
  TmpStr : ShortString;
  Str1 : ShortString;
  StartPos : LongInt;
  EndPos : LongInt;
  EndItem : LongInt;
begin
  FillChar(FDisplayOptions,SizeOf(FDisplayOptions),#0);
  Response := UpperCase(Response);
  // Filter Type
  StartPos := MatchString(Response,'FILTER IS TYPE',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    StartPos := MatchString(TmpStr,' ',3,1,False,False);
    EndPos := MatchString(TmpStr,' ',4,1,False,False);
    Str1 := Copy(TmpStr,(StartPos + 1),((EndPos - 1) - StartPos));
    if (Str1 = 'I') then
      FDisplayOptions.Filter_Type := I;
    if (Str1 = 'II') then
      FDisplayOptions.Filter_Type := II;
    StartPos := MatchString(TmpStr,' ',5,1,False,False);
    EndPos := Length(TmpStr);
    Str1 := Copy(TmpStr,(StartPos + 1),(EndPos - StartPos));
    FDisplayOptions.Filter_Level := StrToInt(Str1);
  end; // If
  // Filter Window A
  StartPos := MatchString(Response,'FILTER WINDOW A',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,((EndPos - 1) - StartPos));
    StartPos := MatchString(TmpStr,' ',1,Length(TmpStr),True,False);
    EndItem := Length(TmpStr);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    FDisplayOptions.Filter_Window_A_ON := (TmpStr = 'ON');
  end; // If
  // Filter Window B
  StartPos := MatchString(Response,'FILTER WINDOW B',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,((EndPos - 1) - StartPos));
    StartPos := MatchString(TmpStr,' ',1,Length(TmpStr),True,False);
    EndItem := Length(TmpStr);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    FDisplayOptions.Filter_Window_B_ON := (TmpStr = 'ON');
  end; // If
  // Channel A Precision
  StartPos := MatchString(Response,'CHANNEL A SHOWS',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,((EndPos - 1) - StartPos));
    StartPos := MatchString(TmpStr,' ',3,1,False,False);
    EndItem := MatchString(TmpStr,' ',4,1,False,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),((EndItem - 1) - StartPos));
    case StrToInt(TmpStr) of
      0 : FDisplayOptions.Channel_A_Precision := P0;
      1 : FDisplayOptions.Channel_A_Precision := P1;
      2 : FDisplayOptions.Channel_A_Precision := P2;
      3 : FDisplayOptions.Channel_A_Precision := P3;
      4 : FDisplayOptions.Channel_A_Precision := P4;
      5 : FDisplayOptions.Channel_A_Precision := P5;
    end; // Case
  end; // If
  // Channel B Precision
  StartPos := MatchString(Response,'CHANNEL B SHOWS',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,((EndPos - 1) - StartPos));
    StartPos := MatchString(TmpStr,' ',3,1,False,False);
    EndItem := MatchString(TmpStr,' ',4,1,False,False);
    TmpStr := Copy(TmpStr,(StartPos + 1),((EndItem - 1) - StartPos));
    case StrToInt(TmpStr) of
      0 : FDisplayOptions.Channel_A_Precision := P0;
      1 : FDisplayOptions.Channel_A_Precision := P1;
      2 : FDisplayOptions.Channel_A_Precision := P2;
      3 : FDisplayOptions.Channel_A_Precision := P3;
      4 : FDisplayOptions.Channel_A_Precision := P4;
      5 : FDisplayOptions.Channel_A_Precision := P5;
    end; // Case
  end; // If
  // Channel A Counts By
  StartPos := MatchString(Response,'CHANNEL A COUNTS BY',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    StartPos := MatchString(TmpStr,' ',1,Length(TmpStr),True,False);
    EndItem := Length(TmpStr);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    case StrToInt(TmpStr) of
      1  : FDisplayOptions.Channel_A_Counts_By := CB1;
      2  : FDisplayOptions.Channel_A_Counts_By := CB2;
      5  : FDisplayOptions.Channel_A_Counts_By := CB5;
      10 : FDisplayOptions.Channel_A_Counts_By := CB10;
      20 : FDisplayOptions.Channel_A_Counts_By := CB20;
    end; // Case
  end; // If
  // Channel B Counts By
  StartPos := MatchString(Response,'CHANNEL B COUNTS BY',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    StartPos := MatchString(TmpStr,' ',1,Length(TmpStr),True,False);
    EndItem := Length(TmpStr);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    case StrToInt(TmpStr) of
      1  : FDisplayOptions.Channel_B_Counts_By := CB1;
      2  : FDisplayOptions.Channel_B_Counts_By := CB2;
      5  : FDisplayOptions.Channel_B_Counts_By := CB5;
      10 : FDisplayOptions.Channel_b_Counts_By := CB10;
      20 : FDisplayOptions.Channel_B_Counts_By := CB20;
    end; // Case
  end; // If
  // Second line shows
  StartPos := MatchString(Response,'SECOND LINE SHOWS',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    StartPos := MatchString(TmpStr,' ',3,1,False,False);
    EndItem := Length(TmpStr);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    TmpStr := UpperCase(TmpStr);
    if (TmpStr = 'BLANK') then
      FDisplayOptions.Second_Line := L_Blank;
    if (TmpStr = 'LIMIT') then
      FDisplayOptions.Second_Line := L_LimitStatus;
    if (TmpStr = 'SECOND DISPLAY') then
      FDisplayOptions.Second_Line := L_AnotherDisplay;
    if (TmpStr = 'TEXT MESSAGE') then
      FDisplayOptions.Second_Line := L_Text;
  end; // If
  // Position Precision
  StartPos := MatchString(Response,'POSITION SHOWS',1,1,False,False);
  if (StartPos > 0) then
  begin
    EndPos := MatchString(Response,#13,1,StartPos,False,False);
    TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
    StartPos := MatchString(TmpStr,' ',1,Length(TmpStr),True,False);
    EndItem := Length(TmpStr);
    TmpStr := Copy(TmpStr,(StartPos + 1),(EndItem - (StartPos - 1)));
    case StrToInt(TmpStr) of
      0 : FDisplayOptions.Posisition_Precision := P0;
      1 : FDisplayOptions.Posisition_Precision := P1;
      2 : FDisplayOptions.Posisition_Precision := P2;
      3 : FDisplayOptions.Posisition_Precision := P3;
      4 : FDisplayOptions.Posisition_Precision := P4;
      5 : FDisplayOptions.Posisition_Precision := P5;
    end; // Case
  end; // If
  if Assigned(FOnDeviceDisplayOptions) then
    FOnDeviceDisplayOptions(Self,Self);
end; // TInterfaceUnit_Device.DoParseDeviceDisplayOptions

procedure TInterfaceUnit_Device.DoParseDeviceSensorData(Response : String; Channel : TInf_Channels);
var
  TmpStr : ShortString;
  StartPos : LongInt;
  EndPos : LongInt;
  StartItem : LongInt;
  EndItem : LongInt;
  CommaCount : Word;
begin
  FillChar(FSensorData[Channel],SizeOf(FSensorData[Channel]),#0);
  EndPos := 1;
  Response := UpperCase(Response);
  CommaCount := OccuranceNo(Response,',',False);
  if (CommaCount > 0) then
  begin
    StartPos := MatchString(Response,' ',15,1,False,False);
    // Serial Number
    if (StartPos > 0) then
    begin
      EndPos := MatchString(Response,',',1,StartPos,False,False);
      TmpStr := Copy(Response,StartPos,(EndPos - StartPos));
      FSensorData[Channel].SerialNumber := Trim(TmpStr);
    end; // If
    // Rated Load
    StartPos := MatchString(Response,' ',1,EndPos,False,False);
    if (StartPos > 0) then
    begin
      EndPos := MatchString(Response,',',1,StartPos,False,False);
      TmpStr := Trim(Copy(Response,(StartPos + 1),((EndPos - 1) - StartPos)));
      EndItem := MatchString(TmpStr,' ',1,1,False,False);
      TmpStr := Copy(TmpStr,1,(EndItem - 1));
      FSensorData[Channel].MaxLoad := StrToFloat(TmpStr);
    end; // If
    // mV per Volt sensitivity #1
    StartPos := MatchString(Response,' ',1,EndPos,False,False);
    if (StartPos > 0) then
    begin
      EndPos := MatchString(Response,',',1,StartPos,False,False);
      TmpStr := Trim(Copy(Response,(StartPos + 1),((EndPos - 1) - StartPos)));
      EndItem := MatchString(TmpStr,' ',1,1,False,False);
      TmpStr := Copy(TmpStr,1,(EndItem - 1));
      FSensorData[Channel].SensimVPerV[1] := StrToFloat(TmpStr);
    end; // If
    if (CommaCount > 5) then
    begin
      // mV per Volt sensitivity #2
      StartPos := MatchString(Response,' ',1,EndPos,False,False);
      if (StartPos > 0) then
      begin
        EndPos := MatchString(Response,',',1,StartPos,False,False);
        TmpStr := Trim(Copy(Response,(StartPos + 1),((EndPos - 1) - StartPos)));
        EndItem := MatchString(TmpStr,' ',1,1,False,False);
        TmpStr := Copy(TmpStr,1,(EndItem - 1));
        FSensorData[Channel].SensimVPerV[2] := StrToFloat(TmpStr);
      end; // If
      // mV per Volt sensitivity #3
      StartPos := MatchString(Response,' ',1,EndPos,False,False);
      if (StartPos > 0) then
      begin
        EndPos := MatchString(Response,',',1,StartPos,False,False);
        TmpStr := Trim(Copy(Response,(StartPos + 1),((EndPos - 1) - StartPos)));
        EndItem := MatchString(TmpStr,' ',1,1,False,False);
        TmpStr := Copy(TmpStr,1,(EndItem - 1));
        FSensorData[Channel].SensimVPerV[3] := StrToFloat(TmpStr);
      end; // If
      // mV per Volt sensitivity #4
      StartPos := MatchString(Response,' ',1,EndPos,False,False);
      if (StartPos > 0) then
      begin
        EndPos := MatchString(Response,',',1,StartPos,False,False);
        TmpStr := Trim(Copy(Response,(StartPos + 1),((EndPos - 1) - StartPos)));
        EndItem := MatchString(TmpStr,' ',1,1,False,False);
        TmpStr := Copy(TmpStr,1,(EndItem - 1));
        FSensorData[Channel].SensimVPerV[4] := StrToFloat(TmpStr);
      end; // If
      // mV per Volt sensitivity #5
      StartPos := MatchString(Response,' ',1,EndPos,False,False);
      if (StartPos > 0) then
      begin
        EndPos := MatchString(Response,',',1,StartPos,False,False);
        TmpStr := Trim(Copy(Response,(StartPos + 1),((EndPos - 1) - StartPos)));
        EndItem := MatchString(TmpStr,' ',1,1,False,False);
        TmpStr := Copy(TmpStr,1,(EndItem - 1));
        FSensorData[Channel].SensimVPerV[5] := StrToFloat(TmpStr);
      end; // If
    end; // If
    // Excitation
    StartPos := MatchString(Response,' ',1,EndPos,False,False);
    if (StartPos > 0) then
    begin
      EndPos := MatchString(Response,',',1,StartPos,False,False);
      TmpStr := Trim(Copy(Response,(StartPos + 1),((EndPos - 1) - StartPos)));
      EndItem := MatchString(TmpStr,' ',1,1,False,False);
      TmpStr := Copy(TmpStr,1,(EndItem - 1));
      if (TmpStr = '5.00') then
        FSensorData[Channel].Excitation := E_5V
      else
        FSensorData[Channel].Excitation := E_10V;
    end; // If
    // Last Calibrated
    StartPos := MatchString(Response,' ',1,EndPos,False,False);
    if (StartPos > 0) then
    begin
      EndPos := MatchString(Response,',',1,StartPos,False,False);
      TmpStr := Trim(Copy(Response,(StartPos + 1),((EndPos - 1) - StartPos)));
      StartItem := MatchString(TmpStr,' ',2,1,False,False);
      TmpStr := Copy(TmpStr,(StartItem + 1),(Length(TmpStr) - StartItem));
      FSensorData[Channel].LastCalibration := TmpStr;
    end; // If
    // Shut value
    StartPos := MatchString(Response,' ',1,EndPos,False,False);
    if (StartPos > 0) then
    begin
      EndPos := Length(Response);
      TmpStr := Trim(Copy(Response,(StartPos + 1),((EndPos - 1) - StartPos)));
      EndItem := MatchString(TmpStr,' ',1,1,False,False);
      TmpStr := Copy(TmpStr,1,(EndItem - 1));
      FSensorData[Channel].Shunt := StrToFloat(TmpStr);
    end; // If
    if Assigned(FOnDeviceSensorData) then
      FOnDeviceSensorData(Self,Self,Channel);
  end; // If
end; // TInterfaceUnit_Device.DoParseDeviceSensorData

procedure TInterfaceUnit_Device.DeviceSerialPortPacket(Sender: TObject; Data: Pointer;
  Size: Integer);
var
  i : LongInt;
  DataChar : Array[0..4095] of ANSIChar;
begin
  FDataReturned := '';
  FillChar(DataChar,SizeOf(DataChar),#0);
  StrCopy(PANSIChar(@DataChar[0]),Data);
  DataChar[Size] := #0;
  for i := 0 to (Size - 1) do
    FDataReturned := FDataReturned + DataChar[i];
  Parse_Response;
end; // TInterfaceUnit_Device.DeviceSerialPortPacket

procedure TInterfaceUnit_Device.DeviceSerialPortPacketTimeOut(Sender: TObject);
begin
  if FResponseExpected then
  begin
    if (Sender is TApdDataPacket) then
      FTmrTimeOutFailSafe.Enabled := False;
    FAutoActive := False;
    Purge_CommandList;
    if Assigned(FOnDeviceTimeOut) then
      FOnDeviceTimeOut(Self,Self);
  end; // If
end; // TInterfaceUnit_Device.DeviceSerialPortPacket

procedure TInterfaceUnit_Device.TimeOutFailSafeTimer(Sender : TObject);
begin
  FTmrTimeOutFailSafe.Enabled := False;
  DeviceSerialPortPacketTimeOut(Self);
end; // TInterfaceUnit_Device.TimeOutFailSafeTimer

constructor TInterfaceUnit_Interface.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FSerialComNumber := 0;
  FSerialBaudRate := B9600;
  FillChar(FDevice,SizeOf(FDevice),#0);
  FEnabled := False;
  FPurgeCommandsWhenDisabled := True;
  FShowActivityWindow := False;
  FVersion := '1.0.0';
  FIdentifyDeviceTimeOut := 5000;
  FPrettyPrint := False;
  FDefaultCommandTimeOut := 10000{ms};
  if Not (csDesigning in ComponentState) then
  begin
    frmDeviceStatus := TfrmDeviceStatus.Create(Self);
    FSerialPort1 := TApdComPort.Create(Self);
    with FSerialPort1 do
    begin
      Open := False;
      InSize := 8192;
      ComNumber := FSerialComNumber;
      Baud := Inf_Baud[Ord(FSerialBaudRate)];
      DataBits := 8;
      Parity := pNone;
      StopBits := 1;
      SWFlowOptions := swfNone;
      AutoOpen := True;
    end; // With
    FListeningDevice := TInterfaceListenDevice.Create(Self);
    with FListeningDevice do
    begin
      BroadCastTimeOut := FIdentifyDeviceTimeOut;
      ComPort := FSerialPort1;
      OnActiveDeviceScanFinished := ActiveDeviceScanFinsished;
    end; // With
    FTmrSendNextCommand := TTimer.Create(Self);
    with FTmrSendNextCommand do
    begin
      Enabled := False;
      Interval := 100;
      OnTimer := TmrSendNextCommand;
    end; // With
    FDeviceCommandReadyStack := TStringList.Create;
    FActiveDeviceList := TStringList.Create;
    DebugTXT := TStringList.Create;
    FDevice[255] := TInterfaceUnit_Device.Create(Self);
    with FDevice[255] do // Setup Default Device.  This is the broadcast device.
    begin
      OnDeviceTimeOut := DeviceTimeOut;
      OnDeviceResponse := DeviceResponse;
      Address := 255;
      ComPort := Nil;
    end; // With
    FActiveDeviceList.AddObject(IntToStr(FDevice[255].Address),FDevice[255]);
  end; // If
end; // TInterfaceUnit_Interface.Create

destructor TInterfaceUnit_Interface.Destroy;
var
  i : LongInt;
begin
  if Not (csDesigning in ComponentState) then
  begin
    FTmrSendNextCommand.Enabled := False;
    FTmrSendNextCommand.Free;
    FActiveDeviceList.Free;
    for i := Low(FDevice) to High(FDevice) do
    begin
      if (FDevice[i] <> Nil) then
      begin
        FDevice[i].Free;
        FDevice[i] := Nil;
      end; // If
    end; // For i
    FDeviceCommandReadyStack.Free;
    if (FSerialPort1.OutBuffUsed > 0) then
      FSerialPort1.FlushOutBuffer;
    if (FSerialPort1.InBuffUsed > 0) then
      FSerialPort1.FlushInBuffer;
    FSerialPort1.Open := False;
    FSerialPort1.Free;
    frmDeviceStatus.Free;
    FListeningDevice.Free;
    DebugTXT.SaveToFile(format('%sCommandDebugLog.txt',[ExtractFilePath(ParamStr(0))]));
  end; // If
  inherited Destroy;
end; // TInterfaceUnit_Interface.Destroy

procedure TInterfaceUnit_Interface.Device_Remove(Address : TInf_Address);
var
  DeviceIndex : LongInt;
begin
  if Assigned(FDevice[Address]) then
  begin
    DeviceIndex := FActiveDeviceList.IndexOf(IntToStr(Address));
    if (DeviceIndex > -1) then
      FActiveDeviceList.Delete(DeviceIndex);
    FDevice[Address].Free;
    FDevice[Address] := Nil;
  frmDeviceStatus.RemoveDevice(Address);
  if Assigned(FOnInterfaceDeviceRemoved) then
    FOnInterfaceDeviceRemoved(Self,Address);
  end; // If
end; // TInterfaceUnit_Interface.Device_Remove

function TInterfaceUnit_Interface.DeviceWaitingToSend : TInterfaceUnit_Device;
var
  i : LongInt;
  Device_Address : TInf_Address;
  CommandNum : LongInt;
  CurrTime : DWord;
  WaitTime : DWord;
begin
  Result := Nil;
  if (FDeviceCommandReadyStack.Count > 0) then
  begin
    CommandNum := 0;
    for i := 0 to (FDeviceCommandReadyStack.Count - 1) do
    begin
      Device_Address := StrToInt(FDeviceCommandReadyStack.Strings[CommandNum]);
      if Assigned(FDevice[Device_Address]) then
      begin
        CurrTime := GetTickCount;
        WaitTime := (FDevice[Device_Address].LastCommandSentAt + FDevice[Device_Address].DelayBeforeNextCommand);
        if (FDevice[Device_Address].State = CommandReady) and (CurrTime > WaitTime) then
        begin
          FDeviceCommandReadyStack.Delete(CommandNum);
          Result := FDevice[Device_Address];
          Break;
        end; // If
      end
      else
      begin
        FDeviceCommandReadyStack.Delete(CommandNum);
        Dec(CommandNum);
      end; // If
      Inc(CommandNum);
    end; // For i
  end; // If
end; // TInterfaceUnit_Interface.DeviceWaitingToSend

procedure TInterfaceUnit_Interface.TmrSendNextCommand(Sender : TObject);
var
  Device : TInterfaceUnit_Device;
begin
  FTmrSendNextCommand.Enabled := False;
  Device := DeviceWaitingToSend;
  if Assigned(Device) then
    Send_CMD(Device);
  FTmrSendNextCommand.Enabled := FEnabled;
end; // TInterfaceUnit_Interface.TmrSendNextCommand

procedure TInterfaceUnit_Interface.Delay(WaitTimeMS : LongInt);
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
end; // TInterfaceUnit_Interface.Delay

procedure TInterfaceUnit_Interface.DoCommandScriptError(CommandNum : LongInt);
begin
  if Assigned(FOnInterfaceError) then
    FOnInterfaceError(Self,0,format('Error: Command Number %d has an invalid parameter.',[CommandNum]));
end; // TInterfaceUnit_Interface.DoCommandScriptError

procedure TInterfaceUnit_Interface.SetEnabled(Value : Boolean);
var
  ComPortOpen : Boolean;
begin
  ComPortOpen := False;
  if Not (csDesigning in ComponentState) then
  begin
    if Value then
    begin
      ComPortOpen := InitializeComPort;
      FTmrSendNextCommand.Enabled := (FIdentifyDeviceTimeOut = 0);
    end
    else
    begin
      if FPurgeCommandsWhenDisabled then
        PurgeWatingCommands;
      CloseComPort;
    end; // If
    FListeningDevice.Enabled := ComPortOpen and (Value <> FEnabled) and (Value = True) and (FIdentifyDeviceTimeOut > 0);
    frmDeviceStatus.ActiveDeviceSearchEnabled := FListeningDevice.Enabled;
  end; // If
  FEnabled := Value;  
end; // TInterfaceUnit_Interface.SetEnabled

function TInterfaceUnit_Interface.GetActiveDeviceCount : LongInt;
begin
  if Not (csDesigning in ComponentState) then
    Result := FActiveDeviceList.Count
  else
    Result := 0;
end; // TInterfaceUnit_Interface.GetActiveDeviceCount

procedure TInterfaceUnit_Interface.SetShowActivityWindow(Value : Boolean);
begin
  FShowActivityWindow := Value;
  if Assigned(frmDeviceStatus) then
    frmDeviceStatus.ShowForm := FShowActivityWindow;
end; // TInterfaceUnit_Interface.SetShowActivityWindow

procedure TInterfaceUnit_Interface.SetVersion(Value : ShortString);
begin
// Do nothing...
end; // TInterfaceUnit_Interface.SetVersion

function TInterfaceUnit_Interface.GetVersion : ShortString;
begin
  Result := FVersion;
end; // TInterfaceUnit_Interface.GetVersion

function TInterfaceUnit_Interface.GetIdentifyDeviceTimeOut : LongInt;
begin
  if Assigned(FListeningDevice) then
    Result := FListeningDevice.BroadCastTimeOut
  else
    Result := FIdentifyDeviceTimeOut;
end; // TInterfaceUnit_Interface.GetIdentifyDeviceTimeOut

procedure TInterfaceUnit_Interface.SetIdentifyDeviceTimeOut(Value : LongInt);
begin
  FIdentifyDeviceTimeOut := Value;
  if Assigned(FListeningDevice) then
  begin
    frmDeviceStatus.ActiveDeviceSearchTime := FIdentifyDeviceTimeOut;
    FListeningDevice.BroadCastTimeOut := FIdentifyDeviceTimeOut;
  end; // If
end; // TInterfaceUnit_Interface.SetIdentifyDeviceTimeOut

function TInterfaceUnit_Interface.GetDeviceExists(Address : TInf_Address) : Boolean;
begin
  Result := (FDevice[Address] <> Nil);
end; // TInterfaceUnit_Interface.GetDeviceExists

procedure TInterfaceUnit_Interface.SetDeviceStatusWindowTop(Value : LongInt);
begin
  if Assigned(frmDeviceStatus) then
    frmDeviceStatus.Top := Value;
end; // TInterfaceUnit_Interface.SetDeviceStatusWindowTop

function TInterfaceUnit_Interface.GetDeviceStatusWindowTop : LongInt;
begin
  if Assigned(frmDeviceStatus) then
    Result := frmDeviceStatus.Top
  else
    Result := 0;
end; // TInterfaceUnit_Interface.GetDeviceStatusWindowTop

procedure TInterfaceUnit_Interface.SetDeviceStatusWindowLeft(Value : LongInt);
begin
  if Assigned(frmDeviceStatus) then
    frmDeviceStatus.Left := Value;
end; // TInterfaceUnit_Interface.SetDeviceStatusWindowLeft

function TInterfaceUnit_Interface.GetDeviceStatusWindowLeft : LongInt;
begin
  if Assigned(frmDeviceStatus) then
    Result := frmDeviceStatus.Left
  else
    Result := 0;
end; // TInterfaceUnit_Interface.GetDeviceStatusWindowLeft

function TInterfaceUnit_Interface.InitializeComPort : Boolean;
begin
  Result := True;
  if Not (csDesigning in ComponentState) then
  begin
    try
      with FSerialPort1 do
      begin
        ComNumber := FSerialComNumber;
        Baud := Inf_Baud[Ord(FSerialBaudRate)];
        DataBits := 8;
        StopBits := 1;
        Parity := pNone;
        SWFlowOptions := swfNone;
        Open := True;
        FlushInBuffer;
        FlushOutBuffer;
      end; // With
    except
      On EOpenComm do
      begin
        Result := False;
      end; // If
    end; // Try
  end; // If
end; // TInterfaceUnit_Interface.InitializeComPort

procedure TInterfaceUnit_Interface.CloseComPort;
begin
  if Not (csDesigning in ComponentState) then
    FSerialPort1.Open := False;
end; // TInterfaceUnit_Interface.CloseComPort

procedure TInterfaceUnit_Interface.PurgeWatingCommands;
var
  i : LongInt;
  Device : TInterfaceUnit_Device;
begin
  FDeviceCommandReadyStack.Clear;
  for i := 0 to (FActiveDeviceList.Count - 1) do
  begin
    Device := FActiveDeviceList.Objects[i] as TInterfaceUnit_Device;
    Device.Purge_CommandList;
  end; // For i
end; // TInterfaceUnit_Interface.PurgeWatingCommands

procedure TInterfaceUnit_Interface.Send_CMD(Var Device : TInterfaceUnit_Device);
var
  Command : TInf_Command;
  CommandRec : TDevice_CommandRec;
begin
  if Not (csDesigning in ComponentState) then
  begin
    FillChar(CommandRec,SizeOf(CommandRec),#0);
    if (FSerialPort1.OutBuffFree > Length(Command)) then
    begin
      CommandRec := Device.Command;
      Command := CommandRec.DeviceCommand;
      if (Command <> '') then
      begin
        FSerialPort1.PutString(Command);
        frmDeviceStatus.CommandSent;
        frmDeviceStatus.AddMessage(Device.Address,format('>> Command Sent: [%s]',[Command]),CommandRec.ExpectResponse,Device.CommsTimeOut);
      end; // If
    end; // If
  end; // If
end; // TInterfaceUnit_Interface.Send_CMD

procedure TInterfaceUnit_Interface.Get_Device(Address : TInf_Address; Var Device : TInterfaceUnit_Device);
begin
  if (FDevice[Address] <> Nil) then
    Device := FDevice[Address]
  else
    Device := Device_Add(Address,FDefaultCommandTimeOut,True);
end; // TInterfaceUnit_Interface.Get_Device

procedure TInterfaceUnit_Interface.Send_Run_Mode_Command(Address : TInf_Address; Var CommandRec : TDevice_CommandRec);
var
  Device : TInterfaceUnit_Device;
begin
  Get_Device(Address,Device);
  Device.Command := CommandRec;
  if Device.Active then
    Device.Active := False; // Disable Seral Port Packet...
end; // TInterfaceUnit_Interface.Send_Run_Mode_Command

function TInterfaceUnit_Interface.Gen_Run_Mode_Command(Address : TInf_Address; Command : TInf_Run_Mode_CMD; Optional_String : TInf_Command_String) : ShortString;
begin
  Result := format('@%0.3d%s%s' + #13,[Address,Inf_Run_Commands[Ord(Command)],Optional_String]);
end; // TInterfaceUnit_Interface.Gen_Run_Mode_Command;

function TInterfaceUnit_Interface.Gen_Setup_Mode_Command(Address : TInf_Address; Command : TInf_Setup_Mode_Cmd; Optional_String : TInf_Command_String) : ShortString;
begin
  Result := format('@%0.3d%s%s' + #13,[Address,Inf_Setup_Commands[Ord(Command)],Optional_String]);
  DebugTXT.Add(Result);
end; // TInterfaceUnit_Interface.Gen_Setup_Mode_Command

procedure TInterfaceUnit_Interface.Send_Setup_Mode_Command(Address : TInf_Address; Var CommandRec : TDevice_CommandRec);
var
  Device : TInterfaceUnit_Device;
begin
  Get_Device(Address,Device);
  Device.Command := CommandRec;
  if Device.Active then
    Device.Active := False;
end; // TInterfaceUnit_Interface.Send_Setup_Mode_Command

procedure TInterfaceUnit_Interface.Add_RunCMD_From_Script(Address : TInf_Address; Command : TInf_Run_Mode_Cmd;
          Param1,Param2,Param3,Param4,Param5,Param6,Param7,Param8,Param9,Param10,Param11,Param12 : Integer; Param13 : String);
begin
  case Command of
    H     : Device_Hello(Address);
    Q     : Device_QuestionMark(Address);
    FV    : Device_Front_Panel_View(Address);
    FS    : Device_Front_Panel_Set(Address,TItem_Numbers(Param1),TItem_Units(Param2));
    FA    : Device_Front_Panel_Alternate(Address);
    F1,F2 : Device_Front_Panel_Pointer(Address,Param11);
    V     : Device_Value(Address,TItem_Numbers(Param1),TItem_Units(Param2),TValue_Repeat(Param3));
    P     : Device_Print(Address,TPrint_Repeat(Param4));
    R     : Device_Reset(Address,(Param5 = 1),(Param6 = 1),(Param7 = 1),(Param8 = 1),(Param9 = 1),(Param10 = 1),TItem_Numbers(Param1));
    X     : Device_Freeze_Display(Address,(Param12 = 1));
    T     : Device_Display_Text(Address,Param13);
  end; // Case
end; // TInterfaceUnit_Interface.Add_RunCMD_From_Script

procedure TInterfaceUnit_Interface.Add_SetupCMD_From_Script(Address : TInf_Address; Command : TInf_Setup_Mode_Cmd;
          Param1,Param2,Param3,Param4,Param6,Param7,Param8,Param9,Param10,Param11,Param12,Param13,Param14,Param15 : Integer; Param5,Param16,Param17 : String);
begin
  case Command of
    UV   : Device_User_Data_View(Address);
    UA   : Device_User_Data_Area(Address, TInf_Channels(Param1),StrToFloat(Param16));
    UL   : Device_User_Data_Length(Address,StrToFloat(Param16));
    AV   : Device_Analog_Output_View(Address);
    A_S  : Device_Analog_Output_Set(Address, TItem_Numbers(Param2), TItem_Units(Param3),StrToFloat(Param16),StrToFloat(Param17));
    S    : Device_Sensor_View_Channel(Address, TInf_Channels(Param1));
    SV   : Device_Sensor_View(Address);
    SS   : Device_Sensor_Select(Address, TInf_Channels(Param1),Param16);
    SD   : Device_Sensor_Delete(Address, Param16);
    ST   : Device_Sensor_ViewTEDS(Address, TInf_Channels(Param1));
    CC   : Device_Calibration_Check(Address,TInf_Channels(Param1));
    CB   : Device_Calibration_Begin(Address, TCell_Type(Param4), TInf_Channels(Param1), Param16, Param5, TCell_Excitation(Param6), Inf_Item_Eng_Units[Param3], StrToFloat(Param17));
    CE   : Device_Calibration_Escape(Address);
    CV   : Device_Calibrate_By_mVPerV_1pt(Address, StrToFloat(Param16));
    CMV6 : Device_Calibrate_By_mVPerV_6pt(Address);
    CMVM : Device_Calibrate_mVPerV_Mass(Address, StrToInt(Param16), StrToFloat(Param17));
    CMVV : Device_Calibrate_mVPerV_Volt(Address, StrToInt(Param16), StrToFloat(Param17));
    CMVT : Device_Calibrate_mVPerV_Torque(Address, StrToInt(Param16), StrToFloat(Param17));
    CM   : Device_Calibrate_By_Masses(Address, TInf_Num_Cal_Points(Param10));
    CMP  : Device_Calibrate_By_Masses_Point(Address, StrToInt(Param16), StrToFloat(Param17));
    CT   : Device_Calibrate_By_Torque(Address, TInf_Num_Cal_Points(Param10));
    CTP  : Device_Calibrate_By_Torque_Point(Address, StrToInt(Param16),StrToFloat(Param17));
    CS   : Device_Calibrate_By_Shunt(Address, StrToInt(Param16));
    OV   : Device_Option_View(Address);
    OP   : Device_Option_Printer(Address, TInf_Pntr_OpCode(Param12));
    OI   : Device_Option_Auto_Identify(Address, (Param15 = 1));
    O_N  : Device_Option_Auto_Identify_Annuciator(Address, (Param15 = 1));
    OD   : Device_Option_TEDS(Address, (Param15 = 1));
    OU   : Device_Option_Auto_Tare(Address, (Param15 = 1));
    OZ   : Device_Option_Auto_Zeroing(Address, (Param15 = 1));
    OA   : Device_Option_Com_Address(Address, StrToInt(Param16));
    OB   : Device_Option_Com_BaudRate(Address, TInf_Baud(Param7));
    OL   : Device_Option_Com_LineFeed(Address, (Param15 = 1));
    OT   : Device_Option_Retain_Tare(Address, (Param15 = 1));
    OE   : Device_Option_EndOfTransmision(Address, (Param15 = 1));
    DV   : Device_Display_View(Address);
    DF   : Device_Display_Filter(Address, TFilterTypes(Param8), TFilterLevels(Param9));
    DD   : Device_Display_Decimal(Address, TInf_Channels(Param1), TPrecision(Param11));
    DP   : Device_Display_Position_Decimal(Address, TPrecision(Param11));
    DC   : Device_Display_Count_By(Address, TInf_Channels(Param1), TInf_CountBy(Param13));
    D2   : Device_Display_Second_Line(Address, TInf_Channels(Param1), TInf_Line_Options(Param14));
    DT   : Device_Display_Second_Line_Text(Address, Param16);
    DW1  : Device_Display_FilterWindow(Address, TInf_Channels(Param1), (Param15 = 1));
    DW2  : Device_Display_FitlerWidnow_Set(Address, TInf_Channels(Param1), TItem_Units(Param2), StrToFloat(Param16));
  end; // Case
end; // TInterfaceUnit_Interface.Add_SetupCMD_FromScript

procedure TInterfaceUnit_Interface.Load_Command_Script(FileName : String);
var
  i : LongInt;
  CommandCount : LongInt;
  CommandType : integer;//Byte;
  RunCommand : TInf_Run_Mode_Cmd;
  SetupCommand : TInf_Setup_Mode_Cmd;
  INIFile : TStRegINI;
  lTmpStr : string;
begin
  if FileExists(FileName) then
  begin
    INIFile := TStRegIni.Create(FileName,True);
    with INIFile do
    begin
      CurSubKey := 'Control';
      CommandCount := ReadInteger('CommandCount',0);
      if (CommandCount > 0) then
      begin
        for i := 1 to CommandCount do
        begin
          try
            CurSubKey := IntToStr(i);
            lTmpStr := ReadString('CommandType','-1');
            CommandType := StrToInt(lTmpStr);
//            CommandType := ReadInteger('CommandType',-1);
            case CommandType of
              0 : begin // Run Mode
                    RunCommand := TInf_Run_Mode_Cmd(ReadInteger('Command',0));
                    Add_RunCMD_From_Script(ReadInteger('Address',0),RunCommand,ReadInteger('Param1',0),ReadInteger('Param2',0),
                                           ReadInteger('Param3',0),ReadInteger('Param4',0),ReadInteger('Param5',0),ReadInteger('Param6',0),
                                           ReadInteger('Param7',0),ReadInteger('Param8',0),ReadInteger('Param9',0),ReadInteger('Param10',0),
                                           ReadInteger('Param11',0),ReadInteger('Param12',0),ReadString('Param13',''));
                  end; // Run Mode
              1 : begin // Setup Mode
                    SetupCommand := TInf_Setup_Mode_Cmd(ReadInteger('Command',0));
                    Add_SetupCMD_From_Script(ReadInteger('Address',0),SetupCommand,ReadInteger('Param1',0),ReadInteger('Param2',0),
                                             ReadInteger('Param3',0),ReadInteger('Param4',0),ReadInteger('Param6',0),
                                             ReadInteger('Param7',0),ReadInteger('Param8',0),ReadInteger('Param9',0),ReadInteger('Param10',0),
                                             ReadInteger('Param11',0),ReadInteger('Param12',0),ReadInteger('Param13',0),ReadInteger('Param14',0),
                                             ReadInteger('Param15',0),ReadString('Param5',''),ReadString('Param16',''),ReadString('Param17',''));
                  end; // Setup Mode
            end; // Case
          except
            DoCommandScriptError(i);
            Continue;
          end; // Try
        end; // For i
      end; // If
    end; // With
    INIFile.Free;
  end; // If
end; // TInterfaceUnit_Interface.Load_Command_Script

function TInterfaceUnit_Interface.Device_Add(NewAddress : TInf_Address; TimeOutPeriod : LongInt; Identify : Boolean) : TInterfaceUnit_Device;
begin
  if (FDevice[NewAddress] = Nil) and (NewAddress > 0) and (NewAddress < 255) then
  begin
    FDevice[NewAddress] := TInterfaceUnit_Device.Create(Self);
    with FDevice[NewAddress] do
    begin
      Address := NewAddress;
      ComPort := FSerialPort1;
      CommsTimeOut := TimeOutPeriod;
      OnDeviceTimeOut := DeviceTimeOut;
      OnDeviceResponse := DeviceResponse;
      OnDeviceIdenify := DeviceIdentify;
      OnDevieSystemOptions := DeviceSystemOptions;
      OnDeviceDisplayOptions := DeviceDisplayOptions;
      OnDeviceSensorData := DeviceSensorData;
      OnDeviceStateChange := DeviceStateChange;
    end; // With
    if Identify then
      Device_Hello(NewAddress);
//      Device_Identify(NewAddress);
  frmDeviceStatus.NewDevice;
  end; // If
  Result := FDevice[NewAddress];
end; // TInterfaceUnit_Interface.Device_Add

procedure TInterfaceUnit_Interface.DeviceTimeOut(Sender : TObject; Device : TInterfaceUnit_Device);
var
  i : LongInt;
begin
  frmDeviceStatus.TimeOut;
  frmDeviceStatus.AddMessage(Device.Address,format('<< Command [%s] Timmed Out',[Device.LastCommand]),False,Device.CommsTimeOut);
  for i := (FDeviceCommandReadyStack.Count - 1) downto 0 do
  begin // Purge Commands for this device.
    if (FDeviceCommandReadyStack.Strings[i] = IntToStr(Device.Address)) then
      FDeviceCommandReadyStack.Delete(i);
  end; // For i
  if FEnabled and Assigned(FOnInterfaceTimeOut) then
    FOnInterfaceTimeOut(Self,Device.Address);
  if (Device.DeviceInfo.Model = '') and (Device.DeviceInfo.Version = '') and (Device.DeviceInfo.SerialNumber = '') and (Device.DeviceInfo.Options = '') then // Remove invalid device.
    Device_Remove(Device.Address);
end; // TInterfaceUnit_Interface.DeviceTimeOut

procedure TInterfaceUnit_Interface.DeviceResponse(Sender : TObject; Device : TInterfaceUnit_Device);
var
  i : LongInt;
  Tmp : LongInt;
  SPos : LongInt;
  EPos : LongInt;
  DataStr : String;
  TmpResponse : String;
begin
  frmDeviceStatus.ResponseRecieved;
  if FPrettyPrint then
  begin
    DataStr := ReplaceString(Device.DataReturned,format('@ %0.3d',[Device.Address]),'',1,0,True);
    Tmp := OccuranceNo(DataStr,#13,True);
  end
  else
    Tmp := 1;
  if (Tmp > 1) then
  begin
    for i := 1 to (Tmp + 1) do
    begin
      if (i = 1) then
      begin
        SPos := 1;
        EPos := MatchString(DataStr,#13,i,1,False,True);
      end
      else
      begin
        if (i <> (Tmp + 1)) then
        begin
          SPos := MatchString(DataStr,#13,(i - 1),1,False,True);
          EPos := MatchString(DataStr,#13,i,1,False,True);
        end
        else
        begin
          SPos := MatchString(DataStr,#13,(i - 1),1,False,True);
          EPos := Length(DataStr);
        end; // If
      end; // If
      TmpResponse := Trim(Copy(DataStr,SPos,(EPos - SPos)));
      if (TmpResponse <> '') then
        frmDeviceStatus.AddMessage(Device.Address,format('<< Response Recieved from Command [%s]; %s',[Device.LastCommand, TmpResponse]),False,Device.CommsTimeOut);
    end; // For i
  end
  else
    frmDeviceStatus.AddMessage(Device.Address,format('<< Response Recieved from Command [%s]; %s',[Device.LastCommand, Device.DataReturned]),False,Device.CommsTimeOut);
  if FEnabled and Assigned(FOnInterfaceResponse) then
    FOnInterfaceResponse(Self,Device.Address,Device.LastCommand,Device.DataReturned);
end; // TInterfaceUnit_Interface.DeviceResponse

procedure TInterfaceUnit_Interface.DeviceIdentify(Sender : TObject; Device : TInterfaceUnit_Device);
var
  DeviceIndex : LongInt;
begin
  DeviceIndex := FActiveDeviceList.IndexOf(IntToStr(Device.Address));
  if (DeviceIndex = -1) then
  begin
    FActiveDeviceList.AddObject(IntToStr(Device.Address),Device);
    frmDeviceStatus.AddMessage(Device.Address,format('>> Device Identified; %s',
                                                     [Device.DataReturned]),False,Device.CommsTimeOut);
  end; // If
  if FEnabled and Assigned(FOnInterfaceNewDevice) then
    FOnInterfaceNewDevice(Self,Device.Address,Device.DeviceInfo{,Device.SystemOptions,Device.DisplayOptions,Device.SensorData[Ch_A],Device.SensorData[Ch_B]});
end; // TInterfaceUnit_Interface.DeviceIdentify

procedure TInterfaceUnit_Interface.DeviceSystemOptions(Sender : TObject; Device : TInterfaceUnit_Device);
begin
  if Assigned(FOnInterfaceNewSystemOptions) then
    FOnInterfaceNewSystemOptions(Self,Device.Address,Device.SystemOptions);
end; // TInterfaceUnit_Interface.DeviceSystemOptions

procedure TInterfaceUnit_Interface.DeviceDisplayOptions(Sender : TObject; Device: TInterfaceUnit_Device);
begin
  if Assigned(FOnInterfaceNewDisplayOptions) then
    FOnInterfaceNewDisplayOptions(Self,Device.Address,Device.DisplayOptions);
end; // TInterfaceUnit_Interface.DeviceDisplayOptions

procedure TInterfaceUnit_Interface.DeviceSensorData(Sender : TObject; Device : TInterfaceUnit_Device; Channel : TInf_Channels);
begin
  if Assigned(FOnInterfaceNewSensorData) then
    FOnInterfacenewSensorData(Self,Device.Address,Channel,Device.SensorData[Channel]);
end; // TInterfaceUnit_Interface.DeviceSensorData

procedure TInterfaceUnit_Interface.DeviceStateChange(Sender : TObject; Device : TInterfaceUnit_Device);
var
  TmpStr : ShortString;
begin
  case Device.State of
    Idle                 : TmpStr := 'Idle';
    CommandReady         : TmpStr := 'Command Ready';
    ListeningForResponse : TmpStr := 'Listening For Response';
    CommandCompleted     : TmpStr := 'Command Completed';
  end; // Case
  frmDeviceStatus.AddMessage(Device.Address,format('>> State Changed to: [%s]',[TmpStr]),False,Device.CommsTimeOut);
  if (Device.State = CommandReady) then
    FDeviceCommandReadyStack.Add(IntToStr(Device.Address));
  if Assigned(FOnInterfaceDeviceStateChange) then
    FOnInterfaceDeviceStateChange(Self,Device.Address,Device.State);
end; // TInterfaceUnit_Interface.DeviceStateChange

procedure TInterfaceUnit_Interface.ActiveDeviceScanFinsished(Sender : TObject);
var
  i : LongInt;
  ActiveDeviceList : TStringList;
  DeviceAddress : TInf_Address;
begin
  ActiveDeviceList := FListeningDevice.ActiveDevices;
  for i := 0 to (ActiveDeviceList.Count - 1) do
  begin
    DeviceAddress := StrToInt(ActiveDeviceList.Strings[i]);
    Device_Add(DeviceAddress,FDefaultCommandTimeOut,False);
    Device_Value(DeviceAddress,Load_A,U_LB,Rpt_Off);
    Device_Print(DeviceAddress,Prt_Off);
    Device_Identify(DeviceAddress);
  end; // For i
  FTmrSendNextCommand.Enabled := FEnabled;
  frmDeviceStatus.ActiveDeviceSearchEnabled := False;
  if Assigned(FOnInteraceIdentifyDeviceTimeOut) then
    FOnInteraceIdentifyDeviceTimeOut(Self);
end; // TInterfaceUnit_Interface.ActiveDeviceScanFinsished

procedure TInterfaceUnit_Interface.Device_Identify(Address : TInf_Address);
begin
  Device_Hello(Address);
  Device_Option_View(Address); // Get system option info too...
  Device_Display_View(Address); // Get display option info too...
  Device_Sensor_View_Channel(Address,Ch_A); // Get Sensor Data for Channel A...
  Device_Sensor_View_Channel(Address,Ch_B); // Get Sensor Data for Channel B...
end; // TInterfaceUnit_Interface.Device_Indentify

procedure TInterfaceUnit_Interface.Device_Hello(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Run_Mode_Command(Address,H,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Run_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Hello

procedure TInterfaceUnit_Interface.Device_QuestionMark(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Run_Mode_Command(Address,Q,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Run_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_QeustionMark

procedure TInterfaceUnit_Interface.Device_Front_Panel_View(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Run_Mode_Command(Address,FV,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Run_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Front_Panel_View

procedure TInterfaceUnit_Interface.Device_Front_Panel_Set(Address : TInf_Address; Item : TItem_Numbers; Item_Unit : TItem_Units);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Run_Mode_Command(Address,FS,format('%s%s',[Inf_Item_Numbers[Ord(Item)],Inf_Item_Units[Ord(Item_Unit)]]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Run_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Front_Panel_Set

procedure TInterfaceUnit_Interface.Device_Front_Panel_Alternate(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Run_Mode_Command(Address,FA,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Run_Mode_Command(address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Front_Panel_Alternate

procedure TInterfaceUnit_Interface.Device_Front_Panel_Pointer(Address : TInf_Address; Line : Byte);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  case Line of
    1 : CommandRec.DeviceCommand := Gen_Run_Mode_Command(Address,F1,'');
    2 : CommandRec.DeviceCommand := Gen_Run_Mode_Command(Address,F2,'');
  end; // case
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Run_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Front_Panel_Pointer

procedure TInterfaceUnit_Interface.Device_Value(Address : TInf_Address; Item_Number : TItem_Numbers; Item_Unit : TItem_Units; RepeatOption : TValue_Repeat);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.ExpectResponse := Not (RepeatOption = Rpt_Off);
  CommandRec.AutoActive := (RepeatOption = Rpt_Indefinite);
  CommandRec.DeviceCommand := Gen_Run_Mode_Command(Address,V,format('%s%s%d',[Inf_Item_Numbers[Ord(Item_Number)],Inf_Item_Units[Ord(Item_Unit)],Ord(RepeatOption)]));
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Run_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Value

procedure TInterfaceUnit_Interface.Device_Print(Address : TInf_Address; RepeatOption : TPrint_Repeat);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Run_Mode_Command(Address,P,format('%d',[Ord(RepeatOption)]));
  CommandRec.ExpectResponse := Not (RepeatOption = Prt_Off);
  CommandRec.AutoActive := (RepeatOption = Prt_Every_3Secs);
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Run_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Print

procedure TInterfaceUnit_Interface.Device_Reset(Address : TInf_Address; TareA : Boolean; PeakA : Boolean; ValleyA : Boolean;
  TareB : Boolean; PeakB : Boolean; ValleyB : Boolean; Item_Number : TItem_Numbers);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Run_Mode_Command(Address,R,format('%d%d%d%d%d%d%s',[Ord(TareA),Ord(PeakA),Ord(ValleyA),Ord(TareB),Ord(PeakB),Ord(ValleyB),Inf_Item_Numbers[Ord(Item_Number)]]));
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Run_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Reset

procedure TInterfaceUnit_Interface.Device_Freeze_Display(Address : TInf_Address; FreezeDispay : Boolean);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Run_Mode_Command(Address,X,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Run_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Freeze_Display

procedure TInterfaceUnit_Interface.Device_Display_Text(Address : TInf_Address; TextToDisplay : TInf_Command_String);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Run_Mode_Command(Address,T,TextToDisplay);
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Run_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Display_Text

procedure TInterfaceUnit_Interface.Device_User_Data_View(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,UV,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_User_Data_View

procedure TInterfaceUnit_Interface.Device_User_Data_Area(Address : TInf_Address; Channel : TInf_Channels; NewArea : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,UA,format('%s%0.4f#',[Inf_Channels[Ord(Channel)],NewArea]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_User_Data_Area

procedure TInterfaceUnit_Interface.Device_Analog_Output_View(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,AV,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Analog_Output_View

procedure TInterfaceUnit_Interface.Device_Analog_Output_Set(Address : TInf_Address; Item_Number : TItem_Numbers; Item_Unit : TItem_Units; FullScale : Single; ZeroScale : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,A_S,format('%s%s%0.1f#%0.1f#',[Inf_Item_Numbers[Ord(Item_Number)],Inf_Item_Units[Ord(Item_Unit)],FullScale,ZeroScale]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Analog_Output_Set

procedure TInterfaceUnit_Interface.Device_Sensor_View_Channel(Address : TInf_Address; Channel : TInf_Channels);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,S,format('%s',[Inf_Channels[Ord(Channel)]]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Sensor_View_Channel

procedure TInterfaceUnit_Interface.Device_Sensor_View(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,SV,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Sensor_View

procedure TInterfaceUnit_Interface.Device_Sensor_Select(Address : TInf_Address; Channel : TInf_Channels; SerialNumber : TCell_SN);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,SS,format('%s%s#',[Inf_Channels[Ord(Channel)],Trim(SerialNumber)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 3000{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Sensor_Select

procedure TInterfaceUnit_Interface.Device_Sensor_Delete(Address : TInf_Address; SerialNumber : TCell_SN);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,SD,format('%d#',[SerialNumber]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Sensor_Delete

procedure TInterfaceUnit_Interface.Device_Sensor_ViewTEDS(Address : TInf_Address; Channel : TInf_Channels);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,ST,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Sensor_ViewTEDS

procedure TInterfaceUnit_Interface.Device_User_Data_Length(Address : TInf_Address; NewLength : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,UL,format('%0.4f#',[NewLength]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_User_Data_Length

procedure TInterfaceUnit_Interface.Device_Calibration_Check(Address : TInf_Address; Channel : TInf_Channels);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CC,Inf_Channels[Ord(Channel)]);
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibration_Check

procedure TInterfaceUnit_Interface.Device_Calibrate_By_mVPerV_1pt(Address : TInf_Address; mVPerV : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CV,format('%0.4f#',[mVPerV]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibrate_By_mVPerV_1pt

procedure TInterfaceUnit_Interface.Device_Calibration_Escape(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CE,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibration_Escape

procedure TInterfaceUnit_Interface.Device_Calibration_Begin(Address : TInf_Address; Cell_Type : TCell_Type;
      Channel : TInf_Channels; Cell_SN : TCell_SN; CalDate : TCell_Date; Excitation : TCell_Excitation;
      Units : TCell_Units; Rated_Load : Single);
var
  TmpExitation : Byte;
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  if (Excitation = E_5V) then
    TmpExitation := 0{5V}
  else
    TmpExitation := 100{10v};
  CommandRec.ExpectResponse := True;
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CB,format('1%d%s%s#',[Ord(Cell_Type),Inf_Channels[Ord(Channel)],Cell_SN]));
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CB,format('2 %s',[CalDate]));
  Send_Setup_Mode_Command(Address,CommandRec);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CB,format('3 %0.3d %s',[TmpExitation,Units]));
  Send_Setup_Mode_Command(Address,CommandRec);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CB,format('4 %0.1f#',[Rated_Load]));
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibration_Begin

procedure TInterfaceUnit_Interface.Device_Calibrate_By_mVPerV_6pt(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CMV6,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibrate_By_mVPerV_6pt

procedure TInterfaceUnit_Interface.Device_Calibrate_mVPerV_Volt(Address : TInf_Address; PointNum : Byte; Value : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CMVV,format('%d%5.5f#',[PointNum,Value]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  if (PointNum < 7) then
    Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibrate_mVPerV_Volt

procedure TInterfaceUnit_Interface.Device_Calibrate_mVPerV_Mass(Address : TInf_Address; PointNum : Byte; Value : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CMVM,format('%d%5.5f#',[PointNum,Value]));
  CommandRec.ExpectResponse := True;
  if (PointNum > 0) then
    CommandRec.DelayNextCommandFor := 100{ms}
  else
    CommandRec.DelayNextCommandFor := 12000{ms};
  if (PointNum < 7) then
    Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibrate_mVPerV_Mass

procedure TInterfaceUnit_Interface.Device_Calibrate_mVPerV_Torque(Address: TInf_Address; PointNum : Byte; Value : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CMVT,format('%d%5.5f#',[PointNum,Value]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibreate_mVPerV_Torque

procedure TInterfaceUnit_Interface.Device_Calibrate_By_Masses(Address : TInf_Address; NumPoints : TInf_Num_Cal_Points);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CM,format('%d',[Inf_Num_Cal_Points[Ord(NumPoints)]]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibrate_By_Masses

procedure TInterfaceUnit_Interface.Device_Calibrate_By_Masses_Point(Address : TInf_Address; PointNum : Byte; Value : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CMP,format('%d%5.5f#',[PointNum,Value]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibrate_By_Masses_Point

procedure TInterfaceUnit_Interface.Device_Calibrate_By_Torque(Address : TInf_Address; NumPoints : TInf_Num_Cal_Points);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CT,format('%d',[Inf_Num_Cal_Points[Ord(NumPoints)]]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibrate_By_Torque

procedure TInterfaceUnit_Interface.Device_Calibrate_By_Torque_Point(Address : TInf_Address; PointNum : Byte; Value : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CTP,format('%d%5.5f#',[PointNum,Value]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibrate_By_Torque_Point

procedure TInterfaceUnit_Interface.Device_Calibrate_By_Shunt(Address : TInf_Address; ShuntValue : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CS,format('%0.2f#',[ShuntValue]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibrate_By_Shunt

procedure TInterfaceUnit_Interface.Device_Calibrate_CountsPerInch_View(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CI,'V');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibrate_CountsPerInch_View

procedure TInterfaceUnit_Interface.Device_Calibrate_CountsPerInch_Set(Address : TInf_Address; NewCountsPerInch : LongInt);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,CI,format('S%d#',[NewCountsPerInch]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Calibrate_CountsPerInch_Set

procedure TInterfaceUnit_Interface.Device_Limit_View(Address : TInf_Address; LimitNumber : TInf_Limit_Numbers);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,LiV,format('%dV',[Ord(LimitNumber) + 1]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Limit_View

procedure TInterfaceUnit_Interface.Device_Limit_Define(Address :  TInf_Address; LimitNumber : TInf_Limit_Numbers; NormalPosition : Boolean;
  LimitEnabled : Boolean; Item_Number : TItem_Numbers; Item_Unit : TItem_Units);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,LiS,format('%dSA %d%d%s%s',[(Ord(LimitNumber) + 1),Ord(NormalPosition),Ord(LimitEnabled),Inf_Item_Numbers[Ord(Item_Number)],Inf_Item_Units[Ord(Item_Unit)]]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Limit_Defince

procedure TInterfaceUnit_Interface.Device_Limit_SetPoint(Address : TInf_Address; LimitNumber : TInf_Limit_Numbers; SetPoint : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,LiS,format('%dSB %0.2f#',[(Ord(LimitNumber) + 1),SetPoint]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Limit_SetPoint

procedure TInterfaceUnit_Interface.Device_Limit_Latching(Address : TInf_Address; LimitNumber : TInf_Limit_Numbers; Opperator : TInf_Opperators; Latching : Boolean);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,LiS,format('%dSC %s%d',[(Ord(LimitNumber) + 1),Inf_Opperators[Ord(Opperator)],Ord(Latching)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Limit_Latching

procedure TInterfaceUnit_Interface.Device_Limit_Reset_Level(Address : TInf_Address; LimitNumber : TInf_Limit_Numbers; SetPoint : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,LiS,format('%dSD %0.1f#',[(Ord(LimitNumber) + 1),SetPoint]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Limit_Reset_Level

procedure TInterfaceUnit_Interface.Device_Limit_Escape(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,LE,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Limit_Escape

procedure TInterfaceUnit_Interface.Device_Limit_Reset(Address : TInf_Address; LimitNumber : TInf_Limit_Numbers);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,LiR,format('%dR',[(Ord(LimitNumber) + 1)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Limit_Reset

procedure TInterfaceUnit_Interface.Device_Option_View(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,OV,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Option_View

procedure TInterfaceUnit_Interface.Device_Option_Printer(Address : TInf_Address; PrinterOpCode : TInf_Pntr_OpCode);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,OP,format('%d',[(Ord(PrinterOpCode) + 4)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Option_Printer

procedure TInterfaceUnit_Interface.Device_Option_Auto_Identify(Address : TInf_Address; AutoIdentifyON : Boolean);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,OI,format('%d',[Ord(AutoIdentifyOn)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Option_Auto_Identify

procedure TInterfaceUnit_Interface.Device_Option_Auto_Identify_Annuciator(Address : TInf_Address; AnnuciatorON : Boolean);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,O_N,format('%d',[Ord(AnnuciatorOn)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Option_Auto_Identify_Annuciator

procedure TInterfaceUnit_Interface.Device_Option_TEDS(Address : TInf_Address; TEDSEnabled : Boolean);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,OD,format('%d',[Ord(TEDSEnabled)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Option_TEDS

procedure TInterfaceUnit_Interface.Device_Option_Auto_Tare(Address : TInf_Address; AutoTareON : Boolean);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,OU,format('%d',[Ord(AutoTareOn)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Option_Auto_Tare

procedure TInterfaceUnit_Interface.Device_Option_Auto_Zeroing(Address : TInf_Address; AutoZeroON : Boolean);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,OZ,format('%d',[Ord(AutoZeroON)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Option_Auto_Zeroing

procedure TInterfaceUnit_Interface.Device_Option_Com_Address(Address : TInf_Address; NewAddress : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,OA,format('%d#',[NewAddress]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Option_Com_Address

procedure TInterfaceUnit_Interface.Device_Option_Com_BaudRate(Address : TInf_Address; NewBaud : TInf_Baud);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,OB,format('%d#',[Ord(NewBaud)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Option_Com_BaudRate

procedure TInterfaceUnit_Interface.Device_Option_Com_LineFeed(Address : TInf_Address; LineFeedON : Boolean);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,OL,format('%d',[Ord(LineFeedON)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Option_Com_LineFeed

procedure TInterfaceUnit_Interface.Device_Option_Retain_Tare(Address : TInf_Address; RetainTareON : Boolean);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,OT,format('%d',[Ord(RetainTareOn)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Option_Retain_Tare

procedure TInterfaceUnit_Interface.Device_Option_EndOfTransmision(Address : TInf_Address; EOT_ON : Boolean);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,OE,format('%d',[Ord(EOT_ON)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Option_EndOfTransmision

procedure TInterfaceUnit_Interface.Device_Display_View(Address : TInf_Address);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,DV,'');
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Display_View

procedure TInterfaceUnit_Interface.Device_Display_Filter(Address : TInf_Address; FilterType : TFilterTypes; FilterLevel : TFilterLevels);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,DF,format('%d%d',[Ord(FilterType),Ord(FilterLevel)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Display_Filter

procedure TInterfaceUnit_Interface.Device_Display_Decimal(Address : TInf_Address; Channel : TInf_Channels; Precision : TPrecision);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,DD,format('%s%d',[Inf_Channels[Ord(Channel)],Ord(Precision)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Display_Decimal

procedure TInterfaceUnit_Interface.Device_Display_Position_Decimal(Address : TInf_Address; Precision : TPrecision);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,DP,format('%d',[Ord(Precision)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Display_Position_Decimal

procedure TInterfaceUnit_Interface.Device_Display_Count_By(Address : TInf_Address; Channel : TInf_Channels; CountBy : TInf_CountBy);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,DC,format('%s%d',[Inf_Channels[Ord(Channel)],Ord(CountBy)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Display_Count_By

procedure TInterfaceUnit_Interface.Device_Display_Second_Line(Address : TInf_Address; Channel : TInf_Channels; LineOption : TInf_Line_Options);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,D2,format('%s',[Inf_Line_Options[Ord(LineOption)],Inf_Channels[Ord(Channel)]]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Display_Second_Line

procedure TInterfaceUnit_Interface.Device_Display_Second_Line_Text(Address : TInf_Address; DisplayText : TInf_Command_String);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,DT,DisplayText);
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Display_Second_Line_Text

procedure TInterfaceUnit_Interface.Device_Display_FilterWindow(Address : TInf_Address; Channel : TInf_Channels; FilterEnabled : Boolean);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,DW1,format('%s%d',[Inf_Channels[Ord(Channel)],Ord(FilterEnabled)]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Display_FilterWindow

procedure TInterfaceUnit_Interface.Device_Display_FitlerWidnow_Set(Address : TInf_Address; Channel : TInf_Channels; Window_Unit : TItem_Units; Window_Value : Single);
var
  CommandRec : TDevice_CommandRec;
begin
  FillChar(CommandRec,SizeOf(CommandRec),#0);
  CommandRec.DeviceCommand := Gen_Setup_Mode_Command(Address,DW2,format('%3.4f',[Window_Value]));
  CommandRec.ExpectResponse := True;
  CommandRec.DelayNextCommandFor := 100{ms};
  Send_Setup_Mode_Command(Address,CommandRec);
end; // TInterfaceUnit_Interface.Device_Display_FilterWindow_Set

end.
