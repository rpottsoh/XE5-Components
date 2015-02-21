// ************************************************************************** //
//                               Created By Daniel Muncy                      //
//                               For TTM Controller Nigeria                   //
//                               Date: 11/21/2006                             //
//                               Updated : 5/21/2007                          //
//      This Components monitors the system power states and fires the        //
//      appropriate event to notify the program.                              //
//                                                                            //
//                                                                            //
// ************************************************************************** //

unit PowerMonitorRev2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls;

type
  TBatteryState = record
     BatteryFlag : String;
     BatteryLifePercent : Integer;
     ACLineStatus : String;
     BatteryLifeTime : String;
     BatteryFullLifeTime : String;
     BatteryFlagCode : integer;
     BatteryLifePercentCode : integer;
     ACLineStatusCode : integer;
     BatteryLifeTimeCode : LongInt;
     BatteryFullLifeTimeCode : LongInt;
  end; // TBatteryState
  TTimeEvent = procedure( Sender : TObject ) of object; // Event for update of everything
  TACStatus = procedure( Sender : TObject; strState: String; IntCode : integer ) of object; // Event that fires when the AC status changes.
  TBattStatus = procedure( Sender : TObject; strState: String; IntCode : integer ) of object; // Event that fires when the Battery status changes.
  TBattLifePercent = procedure( Sender : TObject; State: integer; IntCode : integer ) of object; // Event that fires when the Battery Life Percent changes.
  TBattLifeTime = procedure( Sender : TObject; strState: String; IntCode : integer ) of object; // Event that fires when the Battery Life Time changes.
  TBattFullLifeTime = procedure( Sender : TObject; strState: String; IntCode : integer ) of object; // Event that fires when the Battery Life Full Time changes.
  TLowBatteryWarn = procedure( Sender : TObject; strState: String; IntCode : integer ) Of Object; // Event that fires when the battery gets below a certin percent.
  TPowerMonitor = class(TComponent)
  private
     { Private declarations }
     FACStatus : TACStatus; // AC Line
     FBattStatus : TBattStatus; // Battery
     FBattLifePercent : TBattLifePercent; // Battery Percent
     FBattLifeTime : TBattLifeTime; // Battery Life Time in seconds
     FBattFullLifeTime : TBattFullLifeTime; // Battery Full Life Time
     FCurrACCode : Byte; // AC Line
     FCurrBattCode : Byte; // Battery
     FCurrBattPercentCode : Byte; // Battery Percent
     FCurrBattLifeCode : LongInt; // Battery Life Time in seconds
     FCurrBattFullLifeCode : LongInt; // Battery Full Life Time
     FLowBatteryWarning : TLowBatteryWarn; // Battery Low Warning
     FWarnBatteryLevel : Integer;
     FTimerTrigger : integer;
     FTimeEvent : TTimeEvent;
     FEnabled : Boolean;
     TmrPowerStatus : TTimer;
     FPowerState : TBatteryState;
     FBattStatusStr : String;
     FVersion : String;
     procedure MyTimerEvent( Sender : TObject);
  protected
    { Protected declarations }
    procedure Initialize;
    procedure SetTimerInterval( Interval : Integer );
    procedure SetWarnBatteryLevel( WarnLevel : Integer );
    Function GetACLineStatus( ACValue : Byte ) : String;
    Function GetBatteryState( BattValue : Byte ) : String;
    Function GetBatteryLifePercent( BattLifePercent : Byte ) : Integer;
    Function GetBatteryLifeTime( BattLifeTime : integer ): String;
    Function GetBatteryFullLifeTime( BattFullLifeTime : integer ) : String;
    procedure SetEnabled( EnableMe : Boolean );
    procedure SetVersion(Value : String);
  public
    { Public declarations }
     constructor Create(AOwner : TComponent); override;
     destructor Destroy; override;
     Property ACLineStatus : string read FPowerState.ACLineStatus;
     Property BatteryState : String read FPowerState.BatteryFlag;
     Property BatteryLifeAsPercent : integer read FPowerState.BatteryLifePercent;
     Property BatteryLifeTime : string read FPowerState.BatteryLifeTime;
     Property BatteryFullLifeTime: string read FPowerState.BatteryFullLifeTime;
     Property CurrentACLineStatus : Byte read FCurrACCode;
     Property CurrentBatteryLifePercent : Byte read FCurrBattPercentCode;
     Property CurrentBatteryState : String read FBattStatusStr;
  published
    { Published declarations }
     Property Version : String read FVersion write SetVersion;
     Property PollingInterval : integer read FTimerTrigger write SetTimerInterval default 10000;
     Property BatteryWaringLevel : integer read FWarnBatteryLevel write SetWarnBatteryLevel default 10;
     Property OnTimerUpdate : TTimeEvent read FTimeEvent write FTimeEvent;  // Property for Event
     Property OnACStatusChange : TACStatus read FACStatus write FACStatus;  // Property for Event
     Property OnBatteryStateChange : TBattStatus read FBattStatus write FBattStatus;  // Property for Event
     Property OnBatteryLifePercentChange : TBattLifePercent read FBattLifePercent write FBattLifePercent; // Property for Event
     Property OnBatteryLifeTimeChange : TBattLifeTime read FBattLifeTime write FBattLifeTime; // Property for Event
     Property OnBatteryFullLifeTimeChange : TBattFullLifeTime read FBattFullLifeTime write FBattFullLifeTime; // Property for Event
     Property OnLowBattery : TLowBatteryWarn read FLowBatteryWarning write FLowBatteryWarning; // Property for Event
     Property Enabled : Boolean read FEnabled write SetEnabled default False;
  end;

implementation

const
   ACLine = 0;
   BatteryState = 1;
   BatteryPercent = 2;
   BatteryLifeTime = 3;
   BatteryFullLifeTime = 4;

constructor TPowerMonitor.Create;
begin
  inherited create(AOwner);
  FTimerTrigger := 10000;
  FEnabled := False;
  TmrPowerStatus := nil;
  FCurrACCode := 255;
  FCurrBattCode := 100;
  FCurrBattPercentCode :=150;
  FCurrBattLifeCode := -1;
  FCurrBattFullLifeCode := -1;
  FVersion := '1.2.0';
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
  end; //with
  if not (csDesigning in ComponentState) then
  begin
     TmrPowerStatus := TTimer.Create(nil);
     TmrPowerStatus.Enabled := FEnabled;
     TmrPowerStatus.OnTimer := MyTimerEvent;
     TmrPowerStatus.Interval := FTimerTrigger;
  end; // IF
end; // TPowerMonitor.Create

destructor TPowerMonitor.Destroy;
begin
   if assigned(TmrPowerStatus) then
   begin
      TmrPowerStatus.Enabled := False;
      TmrPowerStatus.Free; // Destroy Timer that was created in the on create
   end; // IF
   TmrPowerStatus := nil;
   inherited destroy;
end; // TPowerMonitor.Destroy

procedure TPowerMonitor.MyTimerEvent;
var
   FCurrentPowerStates : TSystemPowerStatus;

  Procedure GetPowerState;
  begin
    GetSystemPowerStatus(FCurrentPowerStates); // Retrives the current power settings from windows.
    FPowerState.BatteryFlag := GetBatteryState( FCurrentPowerStates.BatteryFlag ); // The Function returns a string with the current status of the battery
    FPowerState.BatteryLifePercent := GetBatteryLifePercent( FCurrentPowerStates.BatteryLifePercent ); // The Function returns an integer with the current status of the battery life as a percent
    FPowerState.ACLineStatus := GetACLineStatus( FCurrentPowerStates.ACLineStatus ); // The Function returns a string with the current status of the AC line
    FPowerState.BatteryLifeTime := GetBatteryLifeTime( FCurrentPowerStates.BatteryLifeTime ); // The Function returns a string with the current status of the battery life time in seconds
    FPowerState.BatteryFullLifeTime := GetBatteryFullLifeTime( FCurrentPowerStates.BatteryFullLifeTime ); // The Function returns a string with the current status of the battery full life time in seconds
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
       if assigned(FACStatus) then
         FACStatus(Self, FPowerState.ACLineStatus, FCurrentPowerStates.ACLineStatus); // Fire AC Line Status Change Event
    end; // IF
    if FCurrBattCode <> FPowerState.BatteryFlagCode then
    begin
       if assigned(FBattStatus) then
         FBattStatus(self,FPowerState.BatteryFlag,FCurrentPowerStates.BatteryFlag); // Fire Battery Status Change Event
    end; // IF
    if FCurrBattPercentCode <> FPowerState.BatteryLifePercentCode then
    begin
       if assigned(FBattLifePercent) then
         FBattLifePercent(self,FPowerState.BatteryLifePercent,FCurrentPowerStates.BatteryLifePercent); // Fire Battery Percent Change Event
    end; // IF
    if FCurrBattLifeCode <> FPowerState.BatteryLifeTimeCode then
    begin
       if assigned(FBattLifeTime) then
         FBattLifeTime(self,FPowerState.BatteryLifeTime,FCurrentPowerStates.BatteryLifeTime); // Fire Battery Life Change Event
    end; // IF
    if FCurrBattFullLifeCode <> FPowerState.BatteryFullLifeTimeCode then
    begin
       if assigned(FBattFullLifeTime) then
         FBattFullLifeTime(self,FPowerState.BatteryFullLifeTime,FCurrentPowerStates.BatteryFullLifeTime); // Fire Battery Full Life Change Event
    end; // IF
    if FCurrBattPercentCode < FWarnBatteryLevel then
    begin
       If assigned(FLowBatteryWarning) then
         FLowBatteryWarning(self,FPowerState.BatteryLifeTime,FCurrentPowerStates.BatteryLifePercent); // Fire low battey warning
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
end; // TPowerMonitor.MyTimerEvent

procedure TPowerMonitor.SetEnabled( EnableMe : Boolean );
begin
   FEnabled := EnableMe;
   Initialize;
   if assigned(TmrPowerStatus) then
      TmrPowerStatus.Enabled := EnableMe;
end; // TPowerMonitor.SetEnabled

Function TPowerMonitor.GetBatteryFullLifeTime( BattFullLifeTime : integer ): String;
begin
// Returns the battery full life time in seconds as a string.
   Result := IntToStr(BattFullLifeTime);
end; //  TPowerMonitor.GetBatteryFullLifeTime;

Function TPowerMonitor.GetBatteryLifeTime( BattLifeTime : integer ) : String;
begin
// Returns the battery full life time in seconds as a string.
   Result := IntToStr(BattLifeTime);
end; //  TPowerMonitor.GetBatteryLifeTime

Function TPowerMonitor.GetBatteryLifePercent( BattLifePercent : Byte ) : Integer;
var
   V : Integer;
begin
// Returns the percentage of battery life left as an integer.
   case BattLifePercent of
      0..100 : V := BattLifePercent;
   else
      V := -1; // Unknow Battery Level
   end; // CASE
   Result := V;
end; // TPowerMonitor.GetBatteryLifePercent;

Function TPowerMonitor.GetBatteryState( BattValue : Byte ) : String;
var
   V : String;
begin
// Returns a string stating the current battery condition based on the byte code passed into it.
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
end; // TPowerMonitor.GetBatteryState

Function TPowerMonitor.GetACLineStatus( ACValue : Byte ) : String;
var
   V : String;
begin
// Returns a string stating the current AC line state based on the byte code passed into it.
   case ACValue of
      0 : V := 'AC Power is OFFLINE';
      1 : V := 'AC Power is ONLINE';
      255 : V := 'AC POWER SATUS IS UNKNOWN';
   else
      V := 'UNKNOWN STATUS INDICATOR';
   end; // CASE
   Result := V;
end; // TPowerMonitor.GetACLineStatus

procedure TPowerMonitor.SetWarnBatteryLevel( WarnLevel : integer );
begin
   if WarnLevel > 0 then
     FWarnBatteryLevel := WarnLevel;
end; // TPowerMonitor.SetWarnBatteryLevel

procedure TPowerMonitor.SetTimerInterval( Interval : integer );
begin
   if Interval > 0 then
      FTimerTrigger := Interval;
   if assigned(TmrPowerStatus) then
      TmrPowerStatus.Interval := FTimerTrigger;
end; // TPowerMonitor.SetTimerInterval

procedure TPowerMonitor.Initialize;
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
    if Assigned(FACStatus) then
      FACStatus(Self,'UPS Monitoring OFF', 1);
    if Assigned(FBattStatus) then
      FBattStatus(Self,'UPS Monitoring OFF', 1);
    if Assigned(FBattLifePercent) then
      FBattLifePercent(Self,100,0);
    if Assigned(FBattLifeTime) then
      FBattLifeTime(Self,'0',0);
    if Assigned(FBattFullLifeTime) then
      FBattFullLifeTime(Self,'0',0);
    if Assigned(FLowBatteryWarning) then
      FLowBatteryWarning(Self,'UPS Monitoring OFF', -1);
  end; // If
end; // TPowerMonitor.Initialize

Procedure TPowerMonitor.SetVersion(Value : String);
begin
  // Do nothing....
end; // TPowerMonitor.SetVersion

end.
