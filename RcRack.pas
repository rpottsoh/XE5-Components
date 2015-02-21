unit RCRack;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OoMisc, AdPort, AdPacket,ExtCtrls;

type
  TPacketMode =(Get_Empty,Get_Models,Get_Connect,Get_AutoSetup{includes Autozero},
                Get_RD,Get_WR,Get_ShuntCalAll,Get_Copy,Get_VOut);

  tResponseStrings = array[1..32] of shortstring;
  tVoltageReadingEvent = procedure( sender : TObject; Chan : integer; Overloaded : boolean; Volts : double ) of object;
  tCopyCompleteEvent = procedure( sender : TObject; CompletedOK : boolean ) of object;
  tErrorEvent = procedure( sender : TObject; ErrCode : integer; ErrMsg : string ) of object;
  tShuntCalEvent = procedure( sender : TObject; ShuntCalState : boolean ) of object;
  tZeroChannelEvent = procedure( Sender : TObject; Chan : integer; Success : boolean ) of Object;
  tModelReadEvent = procedure( Sender : TObject; Slot : integer; ModelNum : integer; Success : boolean) of object;
  tConnectEvent = procedure( Sender : TObject; Connected : boolean ) of Object;

  TGains = array[1..14] of double;
const
  M4322Gains : TGains = (1.018,  //41
                         2.01,   //42
                         3.028,  //43
                         4.026,  //44
                         5.038,  //45
                         6.036,  //46
                         7.054,  //47
                         20.0,   //41
                         40.0,   //42
                         60.0,   //43
                         80.0,   //44
                         100.0,  //45
                         120.0,  //46
                         140.0); //47
  M4078Gains : TGains = (8.775,  //41
                         17.62,  //42
                         26.39,  //43
                         35.28,  //44
                         44.05,  //45
                         52.89,  //46
                         61.67,  //47
                         146.0,  //41
                         292.0,  //42
                         438.0,  //43
                         584.0,  //44
                         730.0,  //45
                         876.0,  //46
                         1022.0);//47


type

  TRcRack = class(TComponent{TCustomControl})
  private
    { Private declarations }
    FOnVoltageReading : tVoltageReadingEvent;
    FOnCopy  : tCopyCompleteEvent;
    FOnError : tErrorEvent;
    FOnShuntCal : tShuntCalEvent;
    FOnDisconnect : TNotifyEvent;
    FOnConnect    : tConnectEvent;
    FOnZeroChannel : tZeroChannelEvent;
    FOnModelRead   : tModelReadEvent;
//    Bitmap        : tbitmap;
    FComPort : TApdComPort;
    FDataPacket : TApdDataPacket;
    FAutoOpen : boolean;
    FComNum   : integer;
    FOpen   : boolean;
    FPacketMode : TPacketMode;
    FStringSent : string;
    FModels     : array[1..32] of integer;
    FModelIndex : integer;
    FStopProcedure : boolean;
    FModelRead : boolean;
    FwrOK      : boolean;
    FwrkResult : string;
    FConnect_OK : boolean;
    FAutoSetup  : integer;
    FShuntCal   : boolean;
    FShuntCalChan   : boolean;
    FCalModeChanged : boolean;
    FChanToSetup : integer;
    FCopyComplete : boolean;
    FVoltageReading : double;
    FOverloaded : boolean;
    FChannelBeingRead : integer;
    FtmrTimeOut       : TTimer;
    FAutoSetupResponses : tResponseStrings;
    procedure SetOpen(value:boolean);
    procedure SetAutoOpen(value:Boolean);
    procedure SetComNumber(Value:integer);
    procedure Packet_Mode(Value:TPacketMode);
    procedure Send_String(DataString: AnsiString);
    function GetGain(index : integer):double;
    procedure FDataPacketStringPacket(Sender: TObject; Data: AnsiString);
    function GetModelType(Index : integer):integer;
    function GetOpen:boolean;
    procedure SetShuntCal(value:boolean);
  protected
    { Protected declarations }
//    procedure paint; override;
    procedure FtmrTimeOutTimer(Sender: TObject);
  public
    { Public declarations }
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;
    function ConnectToRack:boolean;
    function DisconnectFromRack:boolean;
    function SetGain(Chan : integer; GainValue : double; Excitation : single):boolean;
    property StringSent : string read FStringSent;
    property StopProcedure : boolean write FStopProcedure;
    property Gain[ index : integer] : double read GetGain;
    Property ModelType[ index : integer] : integer read GetModelType;
    property Open : boolean read GetOpen write SetOpen default false;
//    function Zero_Channel(Chan : integer):boolean;
    procedure Zero_Channel(Chan : integer);
    property ShuntCal : boolean read FShuntCal write SetShuntCal default false;
    function CopyChannel(Chan : integer):boolean;
    Function Voltage_Reading(Chan : integer; WaitForReading : boolean; var Overloaded:boolean):double;
//    procedure Get_Model_Types;
    procedure Get_Model_In_Slot(const SlotNum : integer);
    function Get_Chan_AutoSetup_Result(index : integer):string;
    procedure Clear_Chan_AutoSetup_Results;
  published
    { Published declarations }
    property AutoOpen : boolean read FAutoOpen write SetAutoOpen default false;
    property ComNumber : integer read FComNum write SetComNumber default 1;
    property OnConnect : tConnectEvent read FOnConnect write FOnConnect;
    property OnZeroChannel :  tZeroChannelEvent read FOnZeroChannel write FOnZeroChannel;
    property OnModelRead : tModelReadEvent read FOnModelRead write FOnModelRead;
    property OnError : tErrorEvent read FOnError write FOnError;
    property OnShuntCal : tShuntCalEvent read FOnShuntCal write FOnShuntCal;
    property OnCopy : tCopyCompleteEvent read FOnCopy write FOnCopy;
    property OnVoltageReading : tVoltageReadingEvent read FOnVoltageReading write FOnVoltageReading;
    property OnDisconnect : TNotifyEvent read FOnDisconnect write FOnDisconnect;
  end;

  function Normalize_Gains(SensorType : string;Chan : integer; DesiredGain:double):double;
  function Rack_Number(AdChan : integer):integer;
  function Rack_Slot(AdChan : integer):integer;
  function Rack_Channel(ADChan : integer):integer;

implementation

procedure delay(msec:longint);
var   StartTime : TdateTime;
      delaylength : real;
begin
  starttime := now;
  delaylength := msec / 86400000 {(1000 * 60 * 60 * 24)};
  repeat
    application.processmessages;
  until now-starttime > delaylength;
end;

function Normalize_Gains(SensorType : string; Chan : integer; DesiredGain:double):double;
var i : integer;
    tmpGain : extended;
    inttmpGain : longint;
begin
  if Chan > 128 then
  begin
    result := DesiredGain;
    exit;
  end;

  if (uppercase(trim(SensorType)) = 'FO') or
     (Uppercase(trim(SensorType)) = 'PR') or
     (Uppercase(trim(SensorType)) = 'MO') or
     (Uppercase(trim(SensorType)) = 'AA') or
     (Uppercase(trim(SensorType)) = 'AC') then
  begin  //4078 Model Type
    if DesiredGain > M4078Gains[14] then
    begin
      result := M4078Gains[14];
      exit;
    end
    else
    if DesiredGain < M4078Gains[1] then
    begin
      result := M4078Gains[1];
      exit;
    end;

    DesiredGain := round(DesiredGain * 1000)/1000;
    if DesiredGain < M4078Gains[1] then
      result := M4078Gains[1]
    else
    for i := 14 downto 1 do
      if DesiredGain >= M4078Gains[i] then
      begin
        result := M4078Gains[i];
        break;
      end;
  end
  else
  begin  //4322 Model Type
    if DesiredGain > M4322Gains[14] then
    begin
      result := M4322Gains[14];
      exit;
    end
    else
    if DesiredGain < M4322Gains[1] then
    begin
      result := M4322Gains[1];
      exit;
    end;
    DesiredGain := round(DesiredGain * 1000)/1000;
    if DesiredGain < M4322Gains[1] then
      result := M4322Gains[1]
    else
    for i := 14 downto 1 do
      if DesiredGain >= M4322Gains[i] then
      begin
        result := M4322Gains[i];
        break;
      end;
  end;
end;

function Rack_Number(AdChan : integer):integer;
begin
  case AdChan of
   1..128 : result := ((AdChan - 1) div 32) + 1;
  else
    result := -1;
  end; //case
end;

function Rack_Slot(AdChan : integer):integer;
var RackChan : integer;
begin
  case AdChan of
   1..128 : begin
              RackChan := ((AdChan - 1) mod 32) + 1;
              result := ((RackChan - 1) div 2) + 1;
            end;
  else
    result := -1;
  end; //case
end;

function Rack_Channel(ADChan : integer):integer;
begin
  case AdChan of
   1..128 : result := ((AdChan - 1) mod 32) + 1;
  else
    result := -1;
  end; //case
end;

constructor TRcRack.create( AOwner : TComponent);
begin
  inherited Create(AOwner);
  fillchar(FAutoSetupResponses, sizeof(FAutoSetupResponses), #0);
  FAutoOpen := false;
  FOpen   := false;
  FComNum := 1;
  FModelIndex := 0;
  FShuntCal := false;
  FShuntCalChan := false;
  FStopProcedure := false;
  fillchar(FModels, sizeof(FModels), #0);
  FtmrTimeOut := TTimer.Create(Self);
  with FtmrTimeOut do
  begin
    Interval := 30000;
    Enabled := False;
    OnTimer := FtmrTimeOutTimer;
  end;
  if not (csDesigning in ComponentState) then
  begin
    FComport := TApdComport.Create(nil);
    FDataPacket := TApdDataPacket.create(nil);
    FDataPacket.OnStringPacket := FDataPacketStringPacket;
  end
  else
  begin
    FComport := nil;
    FDataPacket := nil;
  end;
  if not (csDesigning in ComponentState) then
  begin
    with FComport do
    begin
      autoopen := FAutoOpen;
      comnumber := FComNum;
      baud := 9600;
      open := FOpen;
    end;
    FDataPacket.IncludeStrings := true;
    FDataPacket.ComPort := FComport;
    FDataPacket.StartCond := scAnyData;
    FDataPacket.EndCond := [ecString];
    FDataPacket.EndString := '>';
    FDataPacket.Enabled := true;
    Packet_mode(Get_empty);
  end;
//  Bitmap := tbitmap.create;
//  Bitmap.LoadFromResourceName(HInstance, 'RCBITMAP');
//  width := Bitmap.Width;
//  height := Bitmap.Height;
//  if not (csDesigning in ComponentState) then
//    visible := false;{}
(**)
end;

destructor TRcRack.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    FtmrTimeOut.enabled := false;
    FtmrTimeOut.free;
    FtmrTimeOut := nil;
    FDataPacket.free;
    FComport.Open := false;
//    delay(1000);
    application.processmessages;
    FComport.Free;
//    Bitmap.free;
//    Bitmap := nil;
  end;(**)
  inherited Destroy;
end;

procedure TRcRack.SetComNumber(Value:integer);
begin
  if (value <> FComNum) and (Value > 0) then
  begin
    FComNum := Value;
    if not (csDesigning in ComponentState) then
      FComport.ComNumber := FComNum;
  end;
end;

function TRcRack.GetOpen:boolean;
begin
  result := FComport.Open;
end;

function TRcRack.DisconnectFromRack:boolean;
var TimeCount : integer;
    TimeOut   : boolean;
begin
  FOpen := false;
  result := false;
  if not FOpen then
  begin
    packet_mode(Get_Empty);
    Send_String('exit');
    delay(1000);
  end;
  FComport.Open := FOpen;
  result := true;
end;


function TRcRack.ConnectToRack:boolean;
var TimeCount : integer;
    TimeOut   : boolean;
begin
  FOpen := true;
  FComport.Open := FOpen;
  result := false;
  if FOpen then
  begin
    TimeCount := 0;
    TimeOut := false;
    FConnect_OK := false;
    packet_mode(Get_Connect);
    Send_String('rc4000');
    repeat
      delay(100);
      inc(TimeCount);
      TimeOut := TimeCount = 100{10 Seconds};
    until TimeOut or FConnect_OK;
    packet_mode(get_empty);
    if TimeOut and not FConnect_OK and assigned(FOnError) then
      FOnError(Self,36,format('Timeout while try to connect to rack %d',[self.tag]));
    result := FConnect_OK;
  end;
end;

procedure TRcRack.SetOpen(value:boolean);
var TimeCount : integer;
    TimeOut   : boolean;
begin
  if Value <> FOpen then
  begin
    FOpen := Value;
    if not (csDesigning in ComponentState) then
    begin
      if not Value then
      begin
        packet_mode(Get_Empty);
        Send_String('exit');
        delay(1000);
      end;
      FComport.Open := FOpen;
      if FOpen then
      begin
        TimeCount := 0;
        TimeOut := false;
        FConnect_OK := false;
        packet_mode(Get_Connect);
        Send_String('rc4000');
        FtmrTimeOut.Enabled := true;
      end
      else
        if assigned(FOnDisconnect) then
          FOnDisconnect(self);
    end;
  end;
end;

//old SetOpen Procedure
//procedure TRcRack.SetOpen(value:boolean);
//var TimeCount : integer;
//    TimeOut   : boolean;
//begin
//  if Value <> FOpen then
//  begin
//    FOpen := Value;
//    if not (csDesigning in ComponentState) then
//    begin
//      if not Value then
//      begin
//        packet_mode(Get_Empty);
//        Send_String('exit');
//        delay(1000);
//      end;
//      FComport.Open := FOpen;
//      if FOpen then
//      begin
//        TimeCount := 0;
//        TimeOut := false;
//        FConnect_OK := false;
//        packet_mode(Get_Connect);
//        Send_String('rc4000');
//        repeat
//          delay(100);
//          inc(TimeCount);
//          TimeOut := TimeCount = 100{10 Seconds};
//        until TimeOut or FConnect_OK;
//        packet_mode(get_empty);
//        if FConnect_OK and not Timeout then
//          Get_Model_Types;
//        if TimeOut and not FConnect_OK and assigned(FOnError) then
//          FOnError(Self,36,format('Timeout while trying to connect to rack %d',[self.tag]));
//        if Assigned( FOnConnect ) then
//        begin
//          FOnConnect( Self, FConnect_OK );
//        end;
//      end
//      else
//        if assigned(FOnDisconnect) then
//          FOnDisconnect(self);
//    end;
//  end;
//end;

procedure TRcRack.Send_String(DataString : AnsiString);
var i : integer;
    DataChar : AnsiChar;
begin
  DataString := DataString + ^m;
  FStringSent := DataString;
  {$ifdef TMSI232Debug}
  delay(300); // for debug only remove for Hyundai
  {$endif}
  for i := 1 to length(DataString) do
  begin
    DataChar := DataString[i];
    FComPort.PutChar(DataChar);
    delay(30);
  end;
end;

procedure TRcRack.SetAutoOpen(value:Boolean);
begin
  if Value <> FAutoOpen then
  begin
    FAutoOpen := Value;
    if not (csDesigning in ComponentState) then
      FComport.AutoOpen := FAutoOpen;
  end;
end;

function TRcRack.GetGain(index : integer):double;
var DataStr : string;
    GainModeStr : string;
    GainStr     : string;
    slot     : integer;
    CardRegister : integer;
    ModelNum     : integer;
    LowGain      : boolean;
begin
  result := 1.0;
  if (index in [1..32]) then
  begin
    if FModels[index] = 0 then
      exit;
    Packet_Mode(Get_RD);
    if odd(index) then
      CardRegister := 40
    else
      CardRegister := 41;
    Slot := ((index - 1) div 2) + 1;
    DataStr := format('rd %d %d',[slot, CardRegister]);
    FwrkResult := '';
    Send_String(DataStr);
    repeat
      application.processmessages;
    until (FwrkResult <> '') or FStopProcedure;
    if FStopProcedure then
    begin
      Packet_mode(Get_Empty);
      exit;
    end;
    GainStr := FwrkResult;
    DataStr := format('rd %d %d',[slot, 42]);
    FwrkResult := '';
    Send_String(DataStr);
    repeat
      application.processmessages;
    until (FwrkResult <> '') or FStopProcedure;
    if FStopProcedure then
    begin
      Packet_mode(Get_Empty);
      exit;
    end;
    GainModeStr := FwrkResult;
    Packet_mode(Get_empty);
    if (GainModeStr = 'D'{low}) then
    begin
      LowGain := true;
      ModelNum := 4322
    end
    else
    if (GainModeStr = 'F'{Hi}) then
    begin
      LowGain := false;
      ModelNum := 4322;
    end
    else
    if (GainModeStr = '7'{low}) or
       (GainModeStr = '6'{low}) or
       (GainModeStr = '3'{low}) or
       (GainModeStr = '2'{low}) then
    begin
      LowGain := true;
      ModelNum := 4078;
    end
    else
    if (GainModeStr = 'C'{Hi}) or   //1100
       (GainModeStr = '5'{Hi}) or   //0101
       (GainModeStr = '0'{Hi}) or   //0000
       (GainModeStr = '4'{Hi}) then //0100
    begin
      LowGain := false;
      ModelNum := 4078;
    end
    else
      exit;  // Can't determine Model of board

    if GainStr = '41' then
    begin
      if LowGain and (ModelNum = 4078) then
        result := M4078Gains[1]
      else
      if not LowGain and (ModelNum = 4078) then
        result := M4078Gains[8]
      else
      if LowGain and (ModelNum = 4322) then
        result := M4322Gains[1]
      else
      if not LowGain and (ModelNum = 4322) then
        result := M4322Gains[8];
    end
    else
    if GainStr = '42' then
    begin
      if LowGain and (ModelNum = 4078) then
        result := M4078Gains[2]
      else
      if not LowGain and (ModelNum = 4078) then
        result := M4078Gains[9]
      else
      if LowGain and (ModelNum = 4322) then
        result := M4322Gains[2]
      else
      if not LowGain and (ModelNum = 4322) then
        result := M4322Gains[9];
    end
    else
    if GainStr = '43' then
    begin
      if LowGain and (ModelNum = 4078) then
        result := M4078Gains[3]
      else
      if not LowGain and (ModelNum = 4078) then
        result := M4078Gains[10]
      else
      if LowGain and (ModelNum = 4322) then
        result := M4322Gains[3]
      else
      if not LowGain and (ModelNum = 4322) then
        result := M4322Gains[10];
    end
    else
    if GainStr = '44' then
    begin
      if LowGain and (ModelNum = 4078) then
        result := M4078Gains[4]
      else
      if not LowGain and (ModelNum = 4078) then
        result := M4078Gains[11]
      else
      if LowGain and (ModelNum = 4322) then
        result := M4322Gains[4]
      else
      if not LowGain and (ModelNum = 4322) then
        result := M4322Gains[11];
    end
    else
    if GainStr = '45' then
    begin
      if LowGain and (ModelNum = 4078) then
        result := M4078Gains[5]
      else
      if not LowGain and (ModelNum = 4078) then
        result := M4078Gains[12]
      else
      if LowGain and (ModelNum = 4322) then
        result := M4322Gains[5]
      else
      if not LowGain and (ModelNum = 4322) then
        result := M4322Gains[12];
    end
    else
    if GainStr = '46' then
    begin
      if LowGain and (ModelNum = 4078) then
        result := M4078Gains[6]
      else
      if not LowGain and (ModelNum = 4078) then
        result := M4078Gains[13]
      else
      if LowGain and (ModelNum = 4322) then
        result := M4322Gains[6]
      else
      if not LowGain and (ModelNum = 4322) then
        result := M4322Gains[13];
    end
    else
    if GainStr = '47' then
    begin
      if LowGain and (ModelNum = 4078) then
        result := M4078Gains[7]
      else
      if not LowGain and (ModelNum = 4078) then
        result := M4078Gains[14]
      else
      if LowGain and (ModelNum = 4322) then
        result := M4322Gains[7]
      else
      if not LowGain and (ModelNum = 4322) then
        result := M4322Gains[14];
    end;
  end;
end;

Function TRcRack.SetGain(Chan : integer; GainValue : double; Excitation : single):boolean;
var gainval : integer;
    GainSelectStr : string;
    ChanRegister : string;
    SlotStr      : string;
    Slot         : integer;
    DataStr      : string;
    i            : integer;
    intExci      : integer;
begin
  result := true;
  intExci := round(Excitation);
  if intExci > 10 then
    intExci := 10;
  if intExci < 1 then
    intExci := 1;
  if not(chan in [1..32]) then
    exit;
  GainValue := round(Gainvalue * 1000)/1000;
  if FModels[chan] = 4322 then //This is a Potentiometer amp.
  begin
    if intExci = 1 then
      intExci := 5;  //default excitation for linear channels
    if Gainvalue < M4322Gains[8] then // Use Low Gain Range
    begin
      if intExci = 5 then
        GainSelectStr := 'D' // 5V Exci, 5V Ovld, Low Gain, Remote Sense
      else
        GainSelectStr := '5';// 10V Exci, 5V Ovld, Low Gain, Remote Sense
    end
    else        //else use Hi Gain Range
      if intExci = 5 then
        GainSelectStr := 'F'  // 5V Exci, 5V Ovld, Hi Gain, Remote Sense
      else //intExci = 10
        GainSelectStr := '7'; // 10V Exci, 5V Ovld, Hi Gain, Remote Sense

       // All Gainvals set Filter Select to 2.5 kHz
    if Gainvalue < M4322Gains[1] then
      GainVal := 41// Initialize to Lowest gain
    else
    for i := 14 downto 1 do
      if Gainvalue >= M4322Gains[i] then
      begin
        GainVal := 40 + (((i-1) mod 7) + 1);
        break;
      end;
  end // if Model is 4322
  else
  if FModels[Chan] = 4078 then //This is a strainguage amp.
  begin
    if intExci = 1 then
      intExci := 10;  //default excitation for bridge channels
    if Gainvalue < M4078Gains[8] then //Set 4078 card to low gain mode
    begin
      if intExci = 5 then
        GainSelectStr := 'F'
      else // intExci = 10
        GainSelectStr := '7' //Shunt Cal ChB = 100K, ChA = 100K, Exci = 10V, Ovld = 5V, Input Gain = low, Sense = Remote
    end
    else        // else set card to hi gain mode
      if intExci = 5 then
        GainSelectStr := 'D'
      else
        GainSelectStr := '5'; //Shunt Cal ChB = 100K, ChA = 100K, Exci = 10V, Ovld = 5V, Input Gain = hi, Sense = Remote

       // All Gainvals set Filter Select to 2.5 kHz
    if Gainvalue < M4078Gains[1] then
      GainVal := 41// Initialize to Lowest gain
    else
    for i := 14 downto 1 do
      if (Gainvalue >= M4078Gains[i]) then
      begin
        GainVal := 40 + (((i-1) mod 7) + 1);
        break;
      end;
  end // model = 4087
  else
    exit; //Unknown device or slot is empty
  if odd(Chan) then
    ChanRegister := '40'
  else
    ChanRegister := '41';
  Slot := ((chan - 1) div 2) + 1;
  DataStr := format('wr %d %s %d',[slot, ChanRegister, GainVal]);
  FwrOK := false;
  Packet_Mode(Get_WR);
  Send_String(DataStr); // Programming register 40 or 41 here
  repeat
    application.processmessages;
  until FwrOK or FStopProcedure;
  FwrOk := false;
  if FStopProcedure then
  begin
    Packet_mode(Get_Empty);
    result := false;
    exit;
  end;

  DataStr := format('wr %d %d %s',[slot, 42, GainSelectStr]);
  Send_String(DataStr); // Programming register 42 here
  repeat
    application.processmessages;
  until FwrOK or FStopProcedure;
  FwrOk := false;
  if FStopProcedure then
    result := false  // means SetGain had an error
  else
    result := true;  // means SetGain worked
  Packet_mode(Get_Empty)
end;

procedure TrcRack.Get_Model_In_Slot(const SlotNum : integer);
var Chan : integer;
    CommandStr : string;
begin
  if SlotNum in [1..16] then
  begin
    FModelIndex := (SlotNum * 2)-1; //This is the "A" channel of each slot.
    Packet_Mode(Get_Models);
    CommandStr := format('getmodel c%d',[FModelIndex]);
    Send_String(CommandStr);
    FtmrTimeOut.Enabled := true;
  end;
end;

function TRcRack.Get_Chan_AutoSetup_Result(index : integer):string;
begin
  result := 'Illegal Chan Number';
  if index in [1..32] then
    result := FAutoSetupResponses[index];
end;

procedure TRcRack.Clear_Chan_AutoSetup_Results;
begin
  fillchar(FAutoSetupResponses,sizeof(FAutoSetupResponses),#0);
end;

//procedure TRcRack.Get_Model_Types;
//var s : integer;
//    slot : integer;
//    TimeOut : boolean;
//    TimeCounter : integer;
//    GiveUp : boolean;
//    TryCount : integer;
//    CommandStr : string;
//begin
//  Packet_Mode(Get_Models);
//  FModelIndex := 0;
//  for s := 1 to 32 do
//    if odd(s) then
//    begin
//      FModelRead := false;
//      CommandStr := format('getmodel c%d',[s]);
//      Send_String(CommandStr);
//      TimeCounter := 0;
//      GiveUp := false;
//      TryCount := 0;
//      repeat
//        delay(100);
//        inc(TimeCounter);
//        timeout := TimeCounter >= 100; //10 seconds
//        if TimeOut then
//        begin
//          inc(trycount);
//          TimeCounter := 0;
//          Packet_mode(Get_empty);
//          DisconnectFromRack;
//          delay(500);
//          if ConnectToRack then
//            Send_String(CommandStr)
//          else
//            GiveUp := true;
//        end;
//      until FModelRead or FStopProcedure or GiveUp;
//      if GiveUp then
//      begin
//        Packet_mode(Get_empty);
//        if assigned(FOnError) then
//          FOnError(self,34,format('Rack %d is unresponsive.  Turn the power off and then'+#13#10+
//                                  'back on for rack module and then restart the software.',[tag]));
//        break;
//      end
//      else
//      if FStopProcedure then
//      begin
//        Packet_mode(Get_empty);
//      end
//      else
//      if FModelRead then
//        if assigned(FOnModelRead) then
//        begin
//          case s of
//             1 : slot := 1;
//             3 : slot := 2;
//             5 : slot := 3;
//             7 : slot := 4;
//             9 : slot := 5;
//            11 : slot := 6;
//            13 : slot := 7;
//            15 : slot := 8;
//            17 : slot := 9;
//            19 : slot := 10;
//            21 : slot := 11;
//            23 : slot := 12;
//            25 : slot := 13;
//            27 : slot := 14;
//            29 : slot := 15;
//            31 : slot := 16;
//          end; //case
//          FOnModelRead(self,slot);
//        end;
//      FModelRead := false;
//      if FStopProcedure then
//        break;
//    end;
//  Packet_mode(Get_Empty);
//end;

//In order for packet mode to change from one mode to another the packet mode
// must first be set to Get_EMPTY
procedure TRcRack.Packet_Mode(Value:TPacketMode);
begin
  FDataPacket.Enabled := true;
  if (FPacketMode = Get_EMPTY) or (value = Get_Empty) then
  begin
    FPacketMode := Value;
    FStopProcedure := false;
  end;
end;

procedure TRcRack.FDataPacketStringPacket(Sender: TObject; Data: AnsiString);
var Err_CodeStr : string;
    loop        : integer;
    workstr     : string;
    StrSent     : string;
    i           : integer;
begin
   delete(Data,1,length(FStringSent)+1); //Remove the Echo back of the command sent
   delete(Data,length(data)-2,length(data));// Remove ^m plus > at end of response
   case FPacketMode of
     Get_Connect   : begin
                       delete(Data,1,1);
                       FConnect_OK := false;
                       if uppercase(data) = 'BEGIN SESSION' then
                       begin
                         FtmrTimeOut.Enabled := false;
                         FConnect_OK := true;
                         Packet_mode(Get_Empty);
                       end;
                       if Assigned( FOnConnect ) then
                       begin
                         FOnConnect( Self, FConnect_OK );
                       end;
                     end;
     Get_Models    : begin
                       FtmrTimeOut.Enabled := false;
                       delete(data,1,7{length('Model=m')});
                       FModels[FModelIndex] := strtointdef(data,0);
                       inc(FModelIndex);
                       FModels[FModelIndex] := strtointdef(data,0);
                       FModelRead := true;
                       Packet_mode(Get_Empty);
                       if assigned(FOnModelRead) then
                         FOnModelRead(self,(FModelIndex div 2),FModels[FModelIndex], FmodelRead);
//                       inc(FModelIndex);
//                       delete(data,1,7{length('Model=m')});
//                       FModels[FModelIndex] := strtointdef(data,0);
//                       inc(FModelIndex);
//                       FModels[FModelIndex] := strtointdef(data,0);
//                       FModelRead := true;
                     end;
     Get_WR        : begin
                       StrSent := FStringSent;
                       delete(StrSent,length(StrSent),1);
                       FwrOK := uppercase(StrSent) = uppercase(data);
                     end;
     Get_RD        : begin
                       FwrkResult := '';
                       delete(data,1,3); //delete 'RD '
                       delete(data,1,pos(' ',data)); //delete slot and following space
                       delete(data,1,pos(' ',data)); //delete register and following space
                       // FwrkResult now equals result of RD
                       FwrkResult := data;
                     end;
     Get_AutoSetup : begin
                       Packet_mode(Get_Empty);
                       FAutoSetupResponses[FChanToSetup] := Data;
                       if pos('complete',data) <> 0 then
                          FAutoSetup := 1 {true}
                       else
                          FAutoSetup := 0;{false}
                       if assigned(FOnZeroChannel) then
                         FOnZeroChannel(Self, FChanToSetup, FautoSetup = 1);
                     end;
     Get_ShuntCalAll  : begin
                          FCalModeChanged := pos('complete',data) <> 0;
                        end;
     Get_Copy      : begin
                       FCopyComplete := pos('complete',data) <> 0;
                     end;
     Get_VOut      : begin
                       FOverLoaded := true;
                       FVoltageReading := 5.0;
                       if i <> 0 then
                       begin
                         delete(data,1,5);
                         i := pos('VDC',uppercase(data));
                         delete(Data,i,length(data));
                         if data = 'OVLD(+)' then
                         begin
                           FOverloaded := true;
                           FVoltageReading := 5.0;
                         end
                         else
                         if data = 'OVLD(-)' then
                         begin
                           FOverloaded := true;
                           FVoltageReading := -5.0;
                         end
                         else
                         begin
                           FVoltageReading := strtofloat(data);
                           FOverloaded := (FVoltageReading > 5.0) or (FVoltageReading < -5.0);
                         end;
                       end;
                       Packet_mode(get_empty);
                       if assigned(FOnVoltageReading) then
                         FOnVoltageReading(self,FChannelBeingRead,FOverloaded,FVoltageReading);
                     end;
     Get_EMPTY     : showmessage(data);
   end; //case
end;

Function TRCRack.Voltage_Reading(Chan : integer; WaitForReading : boolean; var OverLoaded : boolean):double;
var LOverloaded : boolean;
    LResult     : double;
    CommandStr : string;
begin
  if WaitForReading then
  begin
    LOverloaded := true;
    LResult := 5.0;
  end;
  if FPacketmode = get_empty then
    if chan in [1..32] then
    begin
      FChannelBeingRead := chan;
      CommandStr := format('getvout c%d',[chan]);
      packet_mode(get_vout);
      send_string(commandstr);
      if WaitForReading then
      begin
        repeat
          application.processmessages;
        until (FPacketMode = get_empty) or FStopProcedure;
        if FPacketMode <> get_empty then
          packet_mode(get_empty)
        else
        begin
          LResult := FVoltageReading;
          LOverloaded := FOverLoaded;
        end;
      end;
    end;
  OverLoaded := LOverloaded;
  result := LResult;
end;

{procedure TRcRack.paint;
begin
  if csDesigning in ComponentState then
  begin
    width := Bitmap.Width;
    height := Bitmap.Height;
    Canvas.Draw(0,0,BitMap);
  end
  else
   visible := false;
end;{}

function TRcRack.GetModelType(Index : integer):integer;
begin
  result := -1;
  if index in [1..32] then
    result := FModels[index];
end;

procedure TRcRack.SetShuntCal(value : boolean);
var CommandStr : string;
begin
  if value <> FShuntCal then
  begin
    if value then
      commandstr := 'calon all'
    else
      commandstr := 'caloff all';
    FCalModeChanged := false;
    Packet_Mode(Get_ShuntCalAll);
    send_string(commandstr);
    repeat
      application.processmessages;
    until FCalModeChanged or FStopProcedure;
    packet_mode(Get_empty);
    if FCalModeChanged then
    begin
      FShuntCal := value;
      if assigned(FOnShuntCal) then
        FOnShuntCal(self, FShuntCal);
    end
    else
    begin
      if assigned(FOnError) then
      begin
        if value then
          FOnError(self,45,'Shunt Cal Resisters failed to engage')
        else
          FOnError(self,46,'Shunt Cal Resisters failed to disengage');
      end;
    end;
  end
  else
  if assigned(FOnShuntCal) then
    FOnShuntCal(self, FShuntCal);
end;


function TrcRack.CopyChannel(Chan : integer):boolean;
var CommandStr : string;
begin
  result := true;
  if chan in [1..32] then
  begin
    if FModels[chan] <> 0 then
    begin
      FCopyComplete := false;
      CommandStr := format('copy c%d m%d',[Chan,FModels[chan]]);
      Packet_Mode(Get_Copy);
      Send_String(CommandStr);
      repeat
        application.processmessages;
      until FCopyComplete or FStopProcedure;
      Packet_mode(get_empty);
      result := FCopyComplete;
      if assigned(FOnCopy) then
        FOnCopy(self,FCopyComplete);
    end
    else
    begin
      result := false;
      if assigned(FOnError) then
        FOnError(self,201,format('No Model number present for channel %d in rack %d',[Chan,self.tag]));
    end;
  end;
end;

procedure TRcRack.FtmrTimeOutTimer(Sender: TObject);
begin
  FtmrTimeOut.enabled := false;
  case FPacketMode of
  Get_Connect   : begin
                    if Assigned( FOnConnect ) then
                    begin
                      FOnConnect( Self, false );
                    end;
                    if assigned(FOnError) then
                      FOnError(Self,36,format('Timeout while trying to connect to rack %d',[self.tag]));
                  end;
  Get_Models    : begin
                    if assigned(FOnModelRead) then
                      FOnModelRead(self,(FModelIndex div 2)+1,FModels[FModelIndex], false);
                    if assigned(FOnError) then
                      FOnError(self,34,format('Rack %d is unresponsive.  Turn the power off and then'+#13#10+
                                              'back on for rack module and then restart the software.',[tag]));
                  end;
  end; //case
  Packet_mode(Get_Empty);
end;

//function TRcRack.Zero_Channel(Chan : integer):boolean;
procedure TRcRack.Zero_Channel(Chan : integer);
var CommandStr : string;
begin
//  result := false;
  if chan in [1..32] then
  begin
    if FPacketMode <> Get_Empty then
    begin
      if assigned(FOnError) then
        FOnError(self, 200,'Packet Mode was not ''Get_Empty'' before attempting to perform Zero_Channel');
    end
    else
    begin
      FChanToSetup := chan;
      if FModels[chan] <> 0 then
      begin
        CommandStr := '';
        if FModels[chan] = 4322 then //Send Autozero command to M4322 channels
          CommandStr := format('Autozero c%d',[chan])
        else
        if FModels[chan] = 4078 then //Send Autosetup commane to M4078 channels
          CommandStr := format('Autosetup c%d',[chan]);
        if CommandStr <> '' then
        begin
          FAutoSetup := 2;
          packet_mode(Get_AutoSetup);
          Send_String(CommandStr);
  //        repeat
  //          application.processmessages;
  //        until (FAutoSetup <> 2) or FStopProcedure;
  //        result := FAutoSetup = 1;
        end;
      end
      else //Slot is empty, we need to pretend the command did somethings and trigger the event
        if assigned(FOnZeroChannel) then
          FOnZeroChannel(Self, FChanToSetup, true);
    end;
//    Packet_Mode(Get_Empty);
  end;
//  if assigned(FOnZeroChannel) then
//    FOnZeroChannel(Self, chan, result);
end;

end.
