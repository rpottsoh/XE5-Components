unit PCB;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OoMisc, AdPort, AdPacket,ExtCtrls;

const
   GL = 33;
type
  TPacketMode =(Get_EMPTY,Get_Freq,Get_Gain,Get_OK,Get_Faults); //Get_Faults get OV's too

  TFaultArray = array[1..32] of boolean;

  tFaultEvent = procedure( Sender : TObject; OverVoltage, InputFault : TFaultArray ) of Object;


  TPCB = class(TComponent)
  private
    { Private declarations }
    FComPort : TApdComPort;
    FDataPacket : TApdDataPacket;
    FAutoOpen : boolean;
    FComNum   : integer;
    FOpen   : boolean;
    FFreq     : array[1..32] of single;
    FGain     : array[1..32] of single;
    FOV       : TFaultArray;
    FFault    : TFaultArray;
    FPacketMode : TPacketMode;
    procedure Check_For_Fault(const Value : string);
    function GetGain(index : integer): single;
    procedure SetGain(index:integer; value : single);
    function GetFreq(index : integer): integer;
    procedure SetFreq(index : integer; value : integer);
    procedure FDataPacketStringPacket(Sender: TObject; Data: ANSIString);
    procedure Packet_Mode(Value:TPacketMode);
    procedure SetOpen(value:boolean);
    procedure SetAutoOpen(value:Boolean);
    procedure SetComNumber(Value:integer);
    procedure SetAllGains(Value:single);
    procedure SetAllFrequencies(Value:integer);
    procedure EnableFilters(Enable : boolean);
    procedure SetRawCommand(const Value:string);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;
    procedure Self_Test(Value:integer);
    property Gain[index : integer]: single read GetGain write SetGain;
    property Frequency[index : integer]: integer read GetFreq write SetFreq;
    property AllGains : single write SetAllGains;
    property AllFrequencies :integer write SetAllFrequencies;
    property FiltersEnabled : boolean write EnableFilters;
    function InputFaults(var Values : TFaultArray): Boolean;
    function OverVoltages(var Values : TFaultArray): Boolean;
    property RawCommand : string write SetRawCommand;
  published
    { Published declarations }
    property AutoOpen : boolean read FAutoOpen write SetAutoOpen default false;
    property Open : boolean read FOpen write SetOpen default false;
    property ComNumber : integer read FComNum write SetComNumber default 1;
    property PacketMode : TPacketMode read FPacketMode;
  end;

implementation

var
  err_out : boolean;
  HaveInfo : boolean;
  GainString : string;
  FreqString : string;
  OKString   : string;
  OKReceived : boolean;
  CheckCount : integer;
  Err_Code : integer;
  FaultCOunt : integer;
  OVCount    : integer;

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

constructor TPCB.create;
begin
  inherited create(AOwner);
  CheckCount := 0;
  FaultCount := 0;
  OVCount    := 0;
  FAutoOpen := false;
  FOpen   := false;
  FComNum := 1;
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
  fillchar(FGain,sizeof(Fgain), #0);
  fillchar(FFreq,sizeof(FFreq), #0);
  if not (csDesigning in ComponentState) then
  begin
    with FComport do
    begin
      autoopen := FAutoOpen;
      comnumber := FComNum;
      baud := 9600;
      HWFlowOptions := [hwfUseDTR, hwfUseRTS];
      open := FOpen;
    end;
    FDataPacket.IncludeStrings := true;
    FDataPacket.ComPort := FComport;
    FDataPacket.StartString := '?:';
    FDataPacket.EndString := ^m^j;
    FDataPacket.EndCond := [ecString];
    FDataPacket.Enabled := true;
    Packet_mode(Get_empty);
  end;
end;

destructor TPCB.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    FDataPacket.free;
    FComport.Open := false;
    delay(1000);
    application.processmessages;
    FComport.Free;
  end;
  inherited Destroy;
end;

function TPCB.GetGain;
var TempIndex : integer;
    RackNum   : integer;
    ChanNum   : integer;
    SString   : string;
    SleepCount : integer;
    StrGain : string;
    FloatGain : single;
    loop      : integer;
begin
  if index in [1..32] then
  begin
    SleepCount := 0;
    Packet_Mode(Get_Gain);
    tempindex := index - 1;
    RackNum := (tempindex div 16) + 1;
    ChanNum := (tempindex mod 16) + 1;
    SString := format('%d:getg c%d', [RackNum, ChanNum]);
    SString := SString + ^m^j;
    HaveInfo := false;
    if assigned(FComport) then
    begin
      FComport.PutString(SString);
      repeat
        delay(500);
        application.processmessages;
        inc(SleepCount);
        err_out := SleepCount > 15;
      until HaveInfo or err_out;
      packet_mode(Get_empty);
      if not err_out then
      begin
        StrGain := copy(GainString,pos(' ',GainString)+1,length(GainString));
        for loop := 1 to length(strgain) do
          if strgain[loop] = #13 then
            strgain[loop] := ' '
          else
          if strgain[loop] = #10 then
            strgain[loop] := ' ';
        strgain := trim(strgain);
        FloatGain := strtofloat(StrGain);
      end
      else
      begin
        MessageDlg('ERROR:  No Data Received when trying to'+#13+#10+
                   '        Get Gain',mtError,[mbOK],0);
        FloatGain := -1;
      end;
    end
    else
    begin
      FloatGain := 1;
    end;
    FGain[index] := FloatGain;
    result := FloatGain;
  end
  else
    result := -1;
end;

procedure TPCB.SetGain;
var SString : string;
    tempindex : integer;
    RackNum   : integer;
    ChanNum   : integer;
    GainVal   : string;
    WaitLoop  : integer;
begin
  if index in [1..32] then
   if value <> FGain[index] then
   begin
     if (Value < 1.0) or (Value > 200.0) then
       exit;
     Packet_mode(Get_OK);
     GainVal := floattostrf(value,fffixed,7,1);
     tempindex := index-1;
     RackNum := (TempIndex div 16) + 1;
     ChanNum := (TempIndex mod 16) + 1;
     SString := format('%d:setg c%d a%s', [RackNum,ChanNum,trim(GainVal)]);
     SString := SString + ^m^j;
     if assigned(FComport) then
     begin
       waitloop := 0;
       OkReceived := false;
       FComPort.PutString(SString);
       repeat
         delay(100);
         application.processmessages;
         inc(waitloop);
       until OKReceived or (waitloop = 10);
       Packet_mode(Get_empty);
       if (Err_Code > 9) then
         MessageDlg('Error From PCB' +#13#10+
                     OkString, mterror, [mbok], 0)
       else
         if WaitLoop = 10 then
           MessageDlg('No confirmation response when setting gain on'+#13+#10+
                      'PCB.',mtError,[mbOK],0);
     end;
   end;
end;

function TPCB.GetFreq;
var SString   : string;
    SleepCount : integer;
    StrFreq : string;
    IntFreq : integer;
    loop    : integer;
begin
  if index in [1..2] then
  begin
    SleepCount := 0;
    Packet_Mode(Get_Freq);
    SString := format('%d:getf c1', [index]);
    SString := SString + ^m^j;
    HaveInfo := false;
    if assigned(FComport) then
    begin
      FComport.PutString(SString);
      repeat
        delay(500);
        application.processmessages;
        inc(SleepCount);
        err_out := SleepCount > 15;
      until HaveInfo or err_out;
      packet_mode(Get_Empty);
      if not err_out then
      begin
        StrFreq := '';
        for loop := 1 to 5 do
        begin
          if FreqString[loop+10] = ' ' then
            break
          else
            StrFreq := StrFreq + FreqString[loop+10];
        end;
        IntFreq := strtoint(StrFreq);
      end
      else
      begin
        MessageDlg('ERROR:  No Data Received when trying to'+#13+#10+
                   '        Get Frequency',mtError,[mbOK],0);
        IntFreq := -1;
      end;
    end
    else
    begin
      IntFreq := 1;
    end;
    for loop := 1 to 16 do
      case index of
        1 : FFreq[loop] := IntFreq;
        2 : FFreq[loop+16] := IntFreq;
      end;//case
    result := IntFreq;
  end
  else
    result := -1;
end;

procedure TPCB.SetFreq;
var SString : string;
    WaitLoop  : integer;
begin
  if index in [1..2] then
   if value <> FGain[index] then
   begin
     Packet_mode(Get_OK);
     if (Value < 2) or (Value > 23000) then
       exit;
     SString := format('%d:setf gl f%d', [index,Value]);
     SString := SString + ^m^j;
     if assigned(FComport) then
     begin
       waitloop := 0;
       OkReceived := false;
       FComPort.PutString(SString);
       repeat
         delay(100);
         inc(waitloop);
       until OKReceived or (waitloop = 10);
       Packet_mode(Get_empty);
       if (Err_Code > 9) then
         MessageDlg('Error From PCB' +#13#10+
                     OkString, mterror, [mbok], 0)
       else
         if WaitLoop = 10 then
           MessageDlg('No confirmation response when setting Frequency on'+#13+#10+
                      'PCB.',mtError,[mbOK],0);
     end;
   end;
end;

procedure TPCB.Self_Test(value:integer);
var SString : string;
    SleepCount : integer;
begin
  if value in [1,2] then
  begin
    Packet_Mode(Get_OK);
    HaveInfo := false;
    SString := format('%d:led1 c1', [Value]);
    SString := SString + ^m^j;
    if assigned(FComport) then
    begin
      FComport.PutString(SString);
      SleepCount := 0;
      repeat
        delay(500);
        application.processmessages;
        inc(SleepCount);
        err_out := SleepCount > 15;
      until HaveInfo or err_out;
      packet_mode(Get_empty);
      if err_out then
        MessageDlg('ERROR:  OK Not Received when trying to'+#13+#10+
                   '        perform Self-Test.',mtError,[mbOK],0);
    end;
  end;
end;

procedure TPCB.Check_For_Fault(const Value:string);
var WorkValue : string;
    RackNum   : integer;
    FaultType : integer;  // 1=Fault 2=Over Voltage
    DataString : string;
    loop       : integer;
begin
  if CheckCount = 4 then
  begin
    FaultCount := 0;
    OVCount    := 0;
    CheckCount := 0;
  end;
  inc(CheckCount);
  WorkValue := Value;
  RackNum := strtoint(copy(WorkValue,1,1));
  if uppercase(trim(copy(WorkValue,pos(':',WorkValue)+1,2))) = 'IF' then
    FaultType := 1
  else
  if uppercase(trim(copy(WorkValue,pos(':',WorkValue)+1,2))) = 'OV' then
    FaultType := 2
  else
    FaultType := 0;
  if FaultType = 0 then
  begin
    MessageDlg('Unknown Response from PCB.' + #13#10 +
                WorkValue, mterror,[mbok],0);
    dec(CheckCount);
    exit;
  end;
  DataString := '';
  case FaultType of
    1 : begin
          for loop := 1 to 8 do
            DataString := DataString + WorkValue[loop+12];
          for loop := 1 to 8 do
            DataString := DataString + WorkValue[loop+29];
          for loop := 1 to 16 do
          begin
            case RackNum of
             1 : FFault[loop] := DataString[loop] = '1';
             2 : FFault[loop+16] := DataString[loop] = '1';
            end; //case
          end;
        end;
    2 : begin
          for loop := 1 to 8 do
            DataString := DataString + WorkValue[loop+12];
          for loop := 1 to 8 do
            DataString := DataString + WorkValue[loop+29];
          for loop := 1 to 16 do
          begin
            case RackNum of
             1 : FOV[loop] := DataString[loop] = '1';
             2 : FOV[loop+16] := DataString[loop] = '1';
            end; //case
          end;
        end;
  end; //case
end;

procedure TPCB.FDataPacketStringPacket(Sender: TObject; Data: ANSIString);
var Err_CodeStr : string;
    loop        : integer;
begin
   HaveInfo := false;
   case FPacketMode of
     Get_Freq   : FreqString := data;
     Get_Gain   : GainString := data;
     Get_OK     : begin
                   OKString := data;
                   Err_CodeStr := '';
                   for loop := 1 to 3 do
                   begin
                     if OkString[loop+7] <> ' ' then
                       Err_CodeStr := Err_CodeStr + OKString[loop+7]
                     else
                       break;
                   end;
                   err_code := strtoint(Err_codeStr);
                   OKReceived := err_code >= 9;
                  end;
     Get_EMPTY  : showmessage(data);
     Get_Faults : Check_For_Fault(Data);
   end; //case
   HaveInfo := true;
end;

procedure TPCB.Packet_Mode(Value:TPacketMode);
begin
  if (FPacketMode = Get_EMPTY) or (value = Get_Empty) then
  begin
    FPacketMode := Value;
    exit;
  end
  else
  while FPacketMode <> Get_Empty do
    delay(200);
  Fpacketmode := value;
end;

procedure TPCB.SetOpen(value:boolean);
begin
  if Value <> FOpen then
  begin
    FOpen := Value;
    if not (csDesigning in ComponentState) then
    begin
      FComport.Open := FOpen;
      if FOpen then
      begin
      (* for initial setup after return from PCB
         step through in debugger allowing reset to flash after first
         and then break out.  Change the second statement to U=2 and
         hook the RS-232 directly into that unit.  Then, put all cabling
         back.
        packet_mode(get_empty);
        FComport.putstring('0:L=1'+^m^j);
        application.processmessages;
        packet_mode(get_empty);
        FComport.putstring('0:X=1'+^m^j);   (**)
        (* rem the rest of this if setting up first time back from PCB  (**)
        packet_mode(get_ok);
        FComport.putstring('2:led1 c1'+^m^j);
        delay(5000);
        FComport.putstring('1:led1 c1'+^m^j);
        delay(6000);
        packet_mode(get_empty);  (**)
      end;
    end;
  end;
end;

procedure TPCB.SetAutoOpen(value:Boolean);
begin
  if Value <> FAutoOpen then
  begin
    FAutoOpen := Value;
    if not (csDesigning in ComponentState) then
      FComport.AutoOpen := FAutoOpen;
  end;
end;

procedure TPCB.SetComNumber(Value:integer);
begin
  if (value <> FComNum) and (Value > 0) then
  begin
    FComNum := Value;
    if not (csDesigning in ComponentState) then
      FComport.ComNumber := FComNum;
  end;
end;

procedure TPCB.SetAllGains(Value:single);
var SString1 : string;
    SString2 : string;
    GainVal   : string;
    WaitLoop1,
    waitloop2  : integer;
begin
  if (Value < 0.1) or (Value > 200.0) then
    exit;
  Packet_mode(Get_OK);
  GainVal := floattostrf(value,fffixed,7,1);
  SString1 := format('1:setg gl a%s', [trim(GainVal)]);
  SString1 := SString1 + ^m^j;
  SString2 := format('2:setg gl a%s', [trim(GainVal)]);
  SString2 := SString2 + ^m^j;
  if assigned(FComport) then
  begin
    waitloop1 := 0;
    waitloop2 := 0;
    OkReceived := false;
    FComPort.PutString(SString1);
    repeat
      delay(200);
      application.processmessages;
      inc(waitloop1);
    until OKReceived or (waitloop1 = 10);
    if Waitloop1 < 10 then
    begin
      OkReceived := false;
      FComPort.PutString(SString2);
      repeat
        delay(200);
        application.processmessages;
        inc(waitloop2);
      until OKReceived or (waitloop2 = 10);
    end;
    Packet_mode(Get_empty);
    if (Err_Code > 9) then
      MessageDlg('Error From PCB' +#13#10+
                  OkString, mterror, [mbok], 0)
    else
      if (WaitLoop1 = 10) or (Waitloop2 = 10) then
        MessageDlg('No confirmation response when setting gain on'+#13+#10+
                   'PCB.',mtError,[mbOK],0);
  end;
end;

procedure TPCB.SetAllFrequencies(Value:integer);
var SString1 : string;
    SString2 : string;
    WaitLoop1,
    waitloop2  : integer;
begin
  if (Value < 2) or (Value > 23000) then
    exit;
  Packet_mode(Get_OK);
  SString1 := format('1:setf c1 f%d', [Value]);
  SString1 := SString1 + ^m^j;
  SString2 := format('2:setf c1 f%d', [Value]);
  SString2 := SString2 + ^m^j;
  if assigned(FComport) then
  begin

    waitloop1 := 0;
    waitloop2 := 0;
    OkReceived := false;
    FComPort.PutString(SString1);
    repeat
      delay(200);
      application.processmessages;
      inc(waitloop1);
    until OKReceived or (waitloop1 = 10);
    if Waitloop1 < 10 then
    begin
      OkReceived := false;
      FComPort.PutString(SString2);
      repeat
        delay(200);
        application.processmessages;
        inc(waitloop2);
      until OKReceived or (waitloop2 = 10);
    end;
    Packet_mode(Get_empty);
    if (Err_Code > 9) then
      MessageDlg('Error From PCB' +#13#10+
                  OkString, mterror, [mbok], 0)
    else
      if (WaitLoop1 = 10) or (Waitloop2 = 10) then
        MessageDlg('No confirmation response when setting Frequency on'+#13+#10+
                   'PCB.',mtError,[mbOK],0);
  end;
end;

// this routine must be run once after a recalibration of PCB Amps to reset the
// system to have filters enabled
procedure TPCB.EnableFilters( Enable : boolean) ;
var SString1 : string;
    SString2 : string;
    WaitLoop1,
    waitloop2  : integer;
begin
  if Enable then
    SString1 := '1:X=1'
  else
    SString1 := '1:X=0';
  SString1 := SString1 + ^m^j;
  if Enable then
    SString1 := '2:X=1'
  else
    SString1 := '2:X=0';
  SString2 := SString2 + ^m^j;
  if assigned(FComport) then
  begin
    Packet_mode(Get_Empty);
    FComPort.PutString(SString1);
    delay(1000);
    Packet_mode(Get_Empty);
    FComPort.PutString(SString2);
    delay(200);
  end;
end;

function TPCB.InputFaults(var Values : TFaultArray): Boolean;
var sstring : string;
    loop    : integer;
begin
  result := false;
  packet_mode({get_empty{}Get_Faults{});
  SString := '2:f?';
  SString := SString + ^m^j;
  haveinfo := false;
  FComport.PutString(SString);
  repeat
    delay(200);
  until HaveInfo;
  SString := '1:f?';
  SString := SString + ^m^j;
  haveinfo := false;
  Fcomport.PutString(SString);
  repeat
    delay(200);
  until HaveInfo;
  packet_mode(get_empty);
  for loop := 1 to 32 do
  begin
    result := FFault[loop];
    if Result then
      break;
  end;
  Values := FFault;
end;

function TPCB.OverVoltages(var Values : TFaultArray): Boolean;
var SString : string;
    loop    : integer;
begin
  result := false;
  Packet_mode(Get_Faults);
  SString := '2:o?' + ^m^j;
  haveinfo := false;
  FComport.PutString(SString);
  repeat
    delay(200);
  until HaveInfo;
  SString := '1:o?' + ^m^j;
  haveinfo := false;
  FComport.PutString(SString);
  repeat
    delay(200);
  until HaveInfo;
  Packet_Mode(Get_EMPTY);
  for loop := 1 to 32 do
  begin
    result := FOV[loop];
    if result then
      break;
  end;
  Values := FOV;
end;

procedure TPCB.SetRawCommand(const Value:string);
var SString :string;
begin
  if FComport.open then
  begin
    packet_mode(Get_Empty);
    SString := Value;
    SString := SString + ^m^j;
    FComport.PutString(SString);
  end;
end;

end.
