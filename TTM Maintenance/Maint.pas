unit Maint;

interface

Uses
  Windows, Classes, StDate;

const
  MaintennaceTargetStr : Array[0..7] of String[14] = ('All','HPU','Drive 1','Drive 2','Load Station 1','Load Station 2','Load Station 3','Load Station 4');

type
  TMaintenanceTarget = (M_All,M_HPU,M_Drive1,M_Drive2,M_LS1,M_LS2,M_LS3,M_LS4); // Identifies the target for the maintenance item (record).

  TMaintenanceTargetSet = Set Of TMaintenanceTarget;

  TMaintenanceScheduleRecord = packed record
    MaintID                  : DWord; // Unique ID for Maintenace items
    MaintDescription         : ShortString; // Short description of the Maintenance item
    MaintInterval            : DWord; {Hours} // Regular maintenace interval
    MaintAcknowlagedAtHours  : DWord; {Hours} // When was this item acknowlaged
    MaintPerformedAtHours    : DWord; {Hours} // When was it last performed
    MaintTarget              : Byte; // Target for Maintenance Item    
    Filler                   : Array[0..126] of Byte;
  end; // TMaintenaceScheduleRec

  TMaintenanceLogRecord = packed record // Record for recording when a maintenace item has been acknowlaged.
    MaintID    : DWord;
    RecordType : Byte; // Acknowlagement(0) or Performed(1)
    Date       : TStDate;
    Time       : TStTime;
    AtHours    : DWord; // User was informed at this hour (run time).
    Who        : ShortString; // Who acknowlaged the reminder...
    Notes      : ShortString; // Information for how the item was performed...
    Target     : DWord; // Maintenance Target
    Filer      : Array[0..123] of Byte;
  end; // TMaintenanceRecord

  TMaintenanceScheduleTable = Array[0..99] of TMaintenanceScheduleRecord;
  TMaintenanceRequiredArray = Array[0..99] of Boolean;

  TMaintenanceLogRecords = Array[0..99999] of ^TMaintenanceLogRecord; // Pointer array to log file records...

  TOnMaintItemFound = procedure(Sender : TObject; MaintenanceItem : TMaintenanceScheduleRecord; Required : Boolean; HoursPastDue : DWord) of Object;

  TCheckMaintSchThread = class(TThread) // Thread tasked with scanning and returning any maintenance items that are due...
  private
    FOnMaintItemFound : TOnMaintItemFound;
    FMaintFileName : String;
    FNotifyOffsetHours : DWord; // Amount of time in hours to offset when checking to see if an item needs maintenace.  Example to warn 8 hours before an item is due sent this variable equal to 8.
  protected
    FMaintenanceRecord : TMaintenanceScheduleRecord; // Used inside of DoFoundMaintenanceRecord...
    FMaintRequired : Boolean; // If False then this is a warning...
    FHoursPast : DWord; // Hours past since maintenance interval...
    FCurrentHours : DWord;
    FFindAcknowlagedWarnings : Boolean;
    FMaintTarget : TMaintenanceTarget;
    FRecordCount : Byte;
    FMaintenanceSchTbl : TMaintenanceScheduleTable;
    procedure Execute; Override;
    procedure DoFindMaintenanceItems;
    procedure DoFindAcknowlagedWarnings;
    procedure DoFoundMaintenanceRecord;
  public
    constructor Create(CreateSuspended : Boolean; FileName : String; DefaultNotifyOffsetHours : DWord; FindAcknowlagedWarnings : Boolean);
    destructor Destroy; Override;
    property MaintFileName : String write FMaintFileName;
    property MaintTarget : TMaintenanceTarget read FMaintTarget write FMaintTarget;
    property CurrentHours : DWord write FCurrentHours;
    property MaintenanceRecordCount : Byte write FRecordCount;
    property MaintenanceScheduleTable : TMaintenanceScheduleTable write FMaintenanceSchTbl;
    property FindAcknowlagedWarings : Boolean write FFindAcknowlagedWarnings;
    property OnMaintenanceItemFound : TOnMaintItemFound read FOnMaintItemFound write FOnMaintItemFound;
  end; // TCheckMaintSchThread

function LoadMainenanceSchedule(FileName : String) : Boolean;
function UpdateMaintenanceSchedule(MaintenanceID : DWord; Target : Byte; Required : Boolean; CurrentHours : DWord; Var UpdateResult : String) : Boolean;
function AppendToMaintenanceLog(LogFileName : String; MaintenanceRecord : TMaintenanceLogRecord) : Boolean;
function LoadMaintenanceLogFile(FileName : String; Var MaintenanceRecords : TMaintenanceLogRecords; Var RecordCount : DWord) : Boolean;
function FreeMaintenanceLogFile(Var MaintenanceRecords : TMaintenanceLogRecords; RecordCount : DWord) : Boolean;
function ScanMaintenaceSchedule(FileName : String; Target : TMaintenanceTarget; MachineHours : DWord; NotifyOffsetHours : DWord;
                                FindAcknowlagedWarnings : Boolean; CallBack_MaintenaniceItemFound : TOnMaintItemFound; CallBack_ThreadTerminated : TNotifyEvent) : Boolean;
function GetLastMaintenanceError : String;

var
  MaintenanceScheduleFileName : String;
  MaintenanceLogFileName : String;

implementation

uses SysUtils;

type
  TEventHandler = class
  private
    FCheckMaintThreadCallBack : TNotifyEvent;
    FCheckMaintThreadItemFound : TOnMaintItemFound;
  public
    procedure CheckMaintThreadTerminated(Sender : TObject); // Used to set unit scope veraible CheckMaintScheduleThread to nil when thread terminates.
    procedure CheckMaintThreadItemFound(Sender : TObject; MaintenanceItem : TMaintenanceScheduleRecord; Required : Boolean; HoursPastDue : DWord); // Used to keep track of maintenance items so they may be recalled...
    property CheckMaintThreadCallBack : TNotifyEvent read FCheckMaintThreadCallBack write FCheckMaintThreadCallBack;
    property CheckMaintThreadItemFoundCallBack : TOnMaintItemFound read FCheckMaintThreadItemFound write FCheckMaintThreadItemFound;
  end; // TEventHandler


var
  MaintenanceScheduleData : TMemoryStream;
  MaintRecordCount : Byte;
  MaintenanceSchTbl : TMaintenanceScheduleTable;
  ScheduleLoaded : Boolean;
  CheckMaintScheduleThreads : Array[M_All..M_LS4] of TCheckMaintSchThread;
  EventHandler : TEventHandler;
  ErrorString : String;

function SaveMaintenanceSchedule : Boolean;
begin
  Result := False;
  if Assigned(MaintenanceScheduleData) then
  begin
    Result := True;
    try
      MaintenanceScheduleData.SaveToFile(MaintenanceScheduleFileName);
    except
      Result := False;
    end; // Try
  end; // If
end; // SaveMaintenanceSchedule

function LoadMainenanceSchedule(FileName : String) : Boolean;
var
  i : Byte;
begin
  Result := False;
  if Not ScheduleLoaded then
  begin
    if Assigned(MaintenanceScheduleData) then
    begin
      if FileExists(FileName) then
      begin
        MaintenanceScheduleFileName := FileName;
        Result := True;
        try
          MaintenanceScheduleData.Clear;
          MaintenanceScheduleData.LoadFromFile(FileName);
          MaintRecordCount := (MaintenanceScheduleData.Size div SizeOf(TMaintenanceScheduleRecord));
          for i := 0 to (MaintRecordCount - 1) do
            MaintenanceScheduleData.Read(MaintenanceSchTbl[i],SizeOf(MaintenanceSchTbl[i]));
          ScheduleLoaded := True;
        except
          ScheduleLoaded := False;
          ErrorString := 'Could not load file into stream.';
          Result := False;
        end; // Try
      end
      else
        ErrorString := format('File "%s" does not exist.',[FileName]);
    end; // If
  end
  else
    Result := True;
end; // LoadMainenanceSchedule

function UpdateMaintenanceSchedule(MaintenanceID : DWord; Target : Byte; Required : Boolean; CurrentHours : DWord; Var UpdateResult : String) : Boolean;
var
  i : Byte;
  RecordCount : Byte;
  MaintRecord : TMaintenanceScheduleRecord;
begin
  UpdateResult := '';
  Result := False;
  if Not ScheduleLoaded then
    ScheduleLoaded := LoadMainenanceSchedule(MaintenanceScheduleFileName);
  if ScheduleLoaded then
  begin
    MaintenanceScheduleData.Position := 0;
    if (MaintenanceScheduleData.Size mod SizeOf(TMaintenanceScheduleRecord) = 0) then
    begin
      RecordCount := (MaintenanceScheduleData.Size div SizeOf(TMaintenanceScheduleRecord));
      if (RecordCount > 0) then
      begin
        UpdateResult := format('Record ID (%d) not found.',[MaintenanceID]);
        for i := 0 to (RecordCount - 1) do
        begin
          MaintenanceScheduleData.Read(MaintRecord,SizeOf(TMaintenanceScheduleRecord));
          if (MaintRecord.MaintID = MaintenanceID) and (MaintRecord.MaintTarget = Target) then
          begin
            MaintenanceScheduleData.Position := (MaintenanceScheduleData.Position - SizeOf(TMaintenanceScheduleRecord));
            if Required then // If it is a required item then fill in the maintenance required field...
              MaintRecord.MaintPerformedAtHours := CurrentHours
            else
              MaintRecord.MaintAcknowlagedAtHours := CurrentHours;
            MaintenanceScheduleData.Write(MaintRecord,SizeOf(MaintRecord));
            MaintenanceSchTbl[i] := MaintRecord; // Update unit scope variable...            
            Result := SaveMaintenanceSchedule;
            if Not Result then
              UpdateResult := 'Failed to save updated Maintenance Schedule.';
            Break;
          end; // If
        end; // For i
      end; // If
    end
    else
      UpdateResult := 'Incorrect file type specified.';
  end
  else
    UpdateResult := 'Failed to load Maitenance Schedule file.';
end; // UpdateMaintenanceSchedule

function AppendToMaintenanceLog(LogFileName : String; MaintenanceRecord : TMaintenanceLogRecord) : Boolean;
var
  MaintenanceLog : File of TMaintenanceLogRecord;
begin
  Result := True;
  try
    MaintenanceLogFileName := LogFileName;
    if Not FileExists(MaintenanceLogFileName) then
    begin
      AssignFile(MaintenanceLog,MaintenanceLogFileName);
      Rewrite(MaintenanceLog);
    end
    else
    begin
      AssignFile(MaintenanceLog,MaintenanceLogFileName);
      Reset(MaintenanceLog);
      Seek(MaintenanceLog,FileSize(MaintenanceLog)); // Seek end of file
    end; // If
    if EOF(MaintenanceLog) then // Just a check to make sure we are at the end...can be removed later.
      Write(MaintenanceLog,MaintenanceRecord);
    CloseFile(MaintenanceLog);
  except
    Result := False;
    ErrorString := format('Could not append to maintenance log file. File "%s".',[LogFileName]);
    CloseFile(MaintenanceLog);
  end; // Try
end; // AppendToMaintenanceLog

function LoadMaintenanceLogFile(FileName : String; Var MaintenanceRecords : TMaintenanceLogRecords; Var RecordCount : DWord) : Boolean;
var
  MaintenanceLog : File Of TMaintenanceLogRecord;
  MaintenanceRecord : TMaintenanceLogRecord;
  i : DWord;
begin
  Result := False;
  if FileExists(FileName) then
  begin
    Result := True;
    FillChar(MaintenanceRecord,SizeOf(MaintenanceRecord),#0);
    try
      AssignFile(MaintenanceLog,FileName);
      Reset(MaintenanceLog);
      RecordCount := FileSize(MaintenanceLog);
      if (RecordCount > 0) then
      begin
        for i := 0 to (RecordCount - 1) do
        begin
          GetMem(MaintenanceRecords[i],SizeOf(TMaintenanceLogRecord));
          Read(MaintenanceLog,MaintenanceRecord);
          with MaintenanceRecord do
          begin
            MaintenanceRecords[i].MaintID    := MaintID;
            MaintenanceRecords[i].RecordType := RecordType;
            MaintenanceRecords[i].Date       := Date;
            MaintenanceRecords[i].Time       := Time;
            MaintenanceRecords[i].AtHours    := AtHours;
            MaintenanceRecords[i].Who        := Who;
            MaintenanceRecords[i].Notes      := Notes;
            MaintenanceRecords[i].Target     := Target;
          end; // With
        end; // For i
      end; // If
      CloseFile(MaintenanceLog);
    except
      Result := False;
    end; // Try
  end; // If
end; // LoadMaintenanceLogFile

function FreeMaintenanceLogFile(Var MaintenanceRecords : TMaintenanceLogRecords; RecordCount : DWord) : Boolean;
var
  i : DWord;
  RecNum : DWord;
begin
  Result := True;
  try
    if (RecordCount > 0) then
    begin
      for i := 0 to (RecordCount - 1) do
      begin
        RecNum := i;
        FreeMem(MaintenanceRecords[i],SizeOf(TMaintenanceLogRecord));
        if Assigned(MaintenanceRecords[i]) then
          MaintenanceRecords[i] := Nil;
      end; // For i
    end; // If
  except
    ErrorString := format('Error freeing maintenance record %d.',[RecNum]);
    Result := False;
  end; // Try
end; // FreeMaintenanceLogFile

function ScanMaintenaceSchedule(FileName : String; Target : TMaintenanceTarget; MachineHours : DWord; NotifyOffsetHours : DWord;
                                FindAcknowlagedWarnings : Boolean; CallBack_MaintenaniceItemFound : TOnMaintItemFound; CallBack_ThreadTerminated : TNotifyEvent) : Boolean;
begin
  Result := False;
  if Not Assigned(CheckMaintScheduleThreads[Target]) then
  begin
    try
      CheckMaintScheduleThreads[Target] := TCheckMaintSchThread.Create(True,FileName,NotifyOffsetHours,FindAcknowlagedWarnings);
      with CheckMaintScheduleThreads[Target] do
      begin
        FreeOnTerminate := True;
        CurrentHours := MachineHours;
        MaintTarget := Target;
        MaintenanceRecordCount := MaintRecordCount;
        MaintenanceScheduleTable := MaintenanceSchTbl;
        EventHandler.CheckMaintThreadItemFoundCallBack := CallBack_MaintenaniceItemFound;
        OnMaintenanceItemFound := EventHandler.CheckMaintThreadItemFound;
        EventHandler.CheckMaintThreadCallBack := CallBack_ThreadTerminated;
        OnTerminate := EventHandler.CheckMaintThreadTerminated;
        Start;
      end; // If
      Result := True;
    except
      ErrorString := format('Failed to create (%s) maintenance check thread.',[MaintennaceTargetStr[Ord(Target)]]);
      Result := False;
    end; // Try
  end
  else
    ErrorString := format('Thread (%s) already created and busy.',[MaintennaceTargetStr[Ord(Target)]]);
end; // ScanMaintenaceSchedule

function GetLastMaintenanceError : String;
begin
  Result := ErrorString;
end; // GetLastMaintenanceError

procedure TEventHandler.CheckMaintThreadTerminated(Sender : TObject);
var
  Target : TMaintenanceTarget;
begin
  Target := (Sender as TCheckMaintSchThread).MaintTarget;
  CheckMaintScheduleThreads[Target] := Nil;
  if Assigned(FCheckMaintThreadCallBack) then
    FCheckMaintThreadCallBack(Sender);
end; // TEventHandler.CheckMaintThreadTerminated

procedure TEventHandler.CheckMaintThreadItemFound(Sender : TObject; MaintenanceItem : TMaintenanceScheduleRecord; Required : Boolean; HoursPastDue : DWord);
begin
  if Assigned(FCheckMaintThreadItemFound) then
    FCheckMaintThreadItemFound(Sender,MaintenanceItem,Required,HoursPastDue);
end; // TEventHandler.CheckMaintThreadItemFound

constructor TCheckMaintSchThread.Create(CreateSuspended : Boolean; FileName : String; DefaultNotifyOffsetHours : DWord; FindAcknowlagedWarnings : Boolean);
begin
  inherited Create(CreateSuspended);
  FMaintFileName := FileName;
  FNotifyOffsetHours := DefaultNotifyOffsetHours;
  FFindAcknowlagedWarnings := FindAcknowlagedWarnings;
  FMaintTarget := M_HPU;
end; // TCheckMaintSchThread.Create

destructor TCheckMaintSchThread.Destroy;
begin
  inherited Destroy;
end; // TCheckMaintSchThread.Destory

procedure TCheckMaintSchThread.Execute;
begin
  if FFindAcknowlagedWarnings then
    DoFindAcknowlagedWarnings
  else
    DoFindMaintenanceItems;
end; // TCheckMaintSchThread.Execute

procedure TCheckMaintSchThread.DoFindMaintenanceItems;
var
  i : Byte;
  OffsetHours : DWord;
  ItemAlreadyAck : Boolean;
  ItemAlreadyPerf : Boolean;
begin
  if Assigned(FOnMaintItemFound) then
  begin
    if (FRecordCount > 0) then
    begin
      for i := 0 to (FRecordCount - 1) do
      begin
        FMaintenanceRecord := FMaintenanceSchTbl[i];
        FMaintRequired := False;
        ItemAlreadyAck := False;
        ItemAlreadyPerf := False;
        with FMaintenanceRecord do
        begin
          if (FNotifyOffsetHours < MaintInterval) then
            OffsetHours := FNotifyOffsetHours
          else // If the offset is equal to or larger than the Maintenance Interval then it doesn't make sense, make it zero.
            OffsetHours := 0;
          if (MaintTarget = Ord(M_All)) or (MaintTarget = Ord(FMaintTarget))then
          begin
            if (((FCurrentHours + OffsetHours) div MaintInterval) > 0) then
            begin
              if (MaintAcknowlagedAtHours > 0) then // Maintenance item already acknowlaged?
                ItemAlreadyAck := ((MaintAcknowlagedAtHours + MaintInterval) > FCurrentHours); // Check to see if this item has been acknowlaged already...
              if (MaintPerformedAtHours > 0) then  // Maintenance item already performed?
                ItemAlreadyPerf := ((MaintPerformedAtHours + MaintInterval) > FCurrentHours); // Check to see if this item has been perfomred already...
              FMaintRequired := (((FCurrentHours - MaintPerformedAtHours) div MaintInterval) > 0); // If past the FNotifyOffsetHours threshold then this is no longer a warning, it is a required maintenance item.
              if FMaintRequired then
                FHoursPast := FCurrentHours - (MaintInterval * (FCurrentHours div MaintInterval)) // Calculate hours past due...
              else
                FHoursPast := 0;
              if Not ItemAlreadyAck then
                Synchronize(DoFoundMaintenanceRecord)
              else
              begin
                if Not ItemAlreadyPerf and FMaintRequired then
                  Synchronize(DoFoundMaintenanceRecord);
              end; // If
            end; // If
          end; // If
        end; // With
      end; // For i
    end; // If
  end; // If
end; // TCheckMaintSchThread.DoFindMaintenanceItems

procedure TCheckMaintSchThread.DoFindAcknowlagedWarnings;
var
  i : Byte;
  OffsetHours : DWord;
  ItemAlreadyAck : Boolean;
begin
  if Assigned(FOnMaintItemFound) then
  begin
    if (FRecordCount > 0) then
    begin
      for i := 0 to (FRecordCount - 1) do
      begin
        FMaintenanceRecord := FMaintenanceSchTbl[i];
        FMaintRequired := False;
        ItemAlreadyAck := False;
        with FMaintenanceRecord do
        begin
          if (MaintTarget = Ord(FMaintTarget)) then
          begin
            if (FNotifyOffsetHours < MaintInterval) then
              OffsetHours := FNotifyOffsetHours
            else // If the offset is equal to or larger than the Maintenance Interval then it doesn't make sense, make it zero.
              OffsetHours := 0;
            if (((FCurrentHours + OffsetHours) div MaintInterval) > 0) then
            begin
              if (MaintAcknowlagedAtHours > 0) then // Maintenance item already acknowlaged?
                ItemAlreadyAck := ((MaintAcknowlagedAtHours + MaintInterval) > FCurrentHours); // Check to see if this item has been acknowlaged already...
              if ItemAlreadyAck then
                Synchronize(DoFoundMaintenanceRecord);
            end; // If
          end; // If
        end; // With
      end; // For i
    end; // If
  end; // If
end; // TCheckMaintSchThread.DoFindAcknowlagedWarnings

procedure TCheckMaintSchThread.DoFoundMaintenanceRecord;
begin
  if Assigned(FOnMaintItemFound) then
    FOnMaintItemFound(Self,FMaintenanceRecord,FMaintRequired,FHoursPast);
end; // TCheckMaintSchThread.DoFoundMaintenanceRecord

initialization
  MaintenanceScheduleData := TMemoryStream.Create;
  MaintenanceScheduleFileName := '';
  MaintenanceLogFileName := '';
  ScheduleLoaded := False;
  EventHandler := TEventHandler.Create;
  MaintRecordCount := 0;
  FillChar(MaintenanceSchTbl,SizeOf(MaintenanceSchTbl),#0);

finalization
  MaintenanceScheduleData.Free;
  EventHandler.Free;

end.
