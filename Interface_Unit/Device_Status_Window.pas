unit Device_Status_Window;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, ComCtrls, ovcbase, ovcnbk, extctrls, TMSIStrFuncs{,
  RackCtls}, ovcmeter, ovcclock;

const
  ProgressIdicators : Array[0..3] of String[5] = ('...|','.../','...-','...\');

type
  TDeviceTab = class(TComponent)
  private
    FMemo : TMemo;
    FTabPage : TOvcTabPage;
    FTimer : TTimer;
    FProgressNum : Byte;
    FTimeOutValue : LongInt;
    FAccumTimeOut : LongInt;
    procedure TimerOnTimer(Sender : TObject);
  protected
    procedure AddDeviceMessage(Msg : String; ShowProgress : Boolean; TimeOut : LongInt);
    procedure SetTabPage(Tab : TOvcTabPage);
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    property TabPage : TOvcTabPage read FTabPage write SetTabPage;
  end; // TDeviceTab

  TfrmDeviceStatus = class(TForm)
    MainMenu1: TMainMenu;
    Exit1: TMenuItem;
    NBDevices: TOvcNotebook;
    StatusBar1: TStatusBar;
    OvcController1: TOvcController;
    Label1: TLabel;
    MtrCommands: TOvcMeter;
    Label2: TLabel;
    Label3: TLabel;
    MtrResponses: TOvcMeter;
    tmrActiveDeviceScan: TTimer;
    lblActiveDeviceSearchTime: TLabel;
    procedure Exit1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure SetFormShow(Value : Boolean);
    procedure SetActiveDeviceSearchTime(Value : LongInt);
    function GetActiveDeviceSearchEnabled : Boolean;
    procedure SetActiveDeviceSearchEnabled(Value : Boolean);
    procedure tmrActiveDeviceScanTimer(Sender: TObject);
  private
    { Private declarations }
    PageRef : Array[1..254] of TDeviceTab;
    FShowForm : Boolean;
    FActiveDevices : Byte;
    FCommandsSent : LongInt;
    FResponsesRecieved : LongInt;
    FTimeOuts : LongInt;
    FActiveDeviceSearchTime : LongInt;
    FAccumActiveDeviceSearchTime : LongInt;
    function GetNoteBookPage(DeviceAddress : Byte) : TDeviceTab;
    function AddNoteBookPage(DeviceAddress : Byte) : TDeviceTab;
    procedure SetTop(Value : LongInt);
    function GetTop : LongInt;
    procedure SetLeft(Value : LongInt);
    function GetLeft : LongInt;
  public
    { Public declarations }
    procedure NewDevice;
    procedure RemoveDevice(Address : Byte);
    procedure CommandSent;
    procedure ResponseRecieved;
    procedure TimeOut;
    procedure AddMessage(DeviceAddress : Byte; Msg : String; ShowProgress : Boolean; TimeOut : LongInt);
    property ShowForm : Boolean read FShowForm write SetFormShow;
    property ActiveDeviceSearchTime : LongInt read FActiveDeviceSearchTime write SetActiveDeviceSearchTime;
    property ActiveDeviceSearchEnabled : Boolean read GetActiveDeviceSearchEnabled write SetActiveDeviceSearchEnabled;
    property Top;{ : LongInt read GetTop write SetTop;}
    property Left;{ : LongInt read GetLeft write SetLeft;}
  end;

var
  frmDeviceStatus: TfrmDeviceStatus;

implementation

{$R *.DFM}

constructor TDeviceTab.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FTimer := TTimer.Create(Self);
  FProgressNum := 0;
  FAccumTimeOut := 0;
  FTimeOutValue := 250;
  with FTimer do
  begin
    Enabled := False;
    Interval := 250;
    OnTimer := TimerOnTimer;
  end; // With
end; // TDeviceTab.Create

destructor TDeviceTab.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end; // TDeviceTab.TabDestroy

procedure TDeviceTab.AddDeviceMessage(Msg : String; ShowProgress : Boolean; TimeOut : LongInt);
var
  TmpStr : String;
  ElipsePos : LongInt;
begin
  FTimer.Enabled := ShowProgress;
  if FTimer.Enabled then
  begin
    FAccumTimeOut := 0;
    FTimeOutValue := TimeOut;
  end; // If
  if (FMemo.Lines.Count > 0) then
  begin
    TmpStr := FMemo.Lines.Strings[(FMemo.Lines.Count - 1)];
    ElipsePos := MatchString(TmpStr,'...',1,Length(TmpStr),True,True);
    if (ElipsePos > 0) then
    begin
      TmpStr := Copy(TmpStr,1,(ElipsePos - 1));
      FMemo.Lines.Strings[(FMemo.Lines.Count - 1)] := TmpStr;
    end; // If
  end; // If
  FMemo.Lines.Add(format('[%s] %s',[DateTimeToStr(Now),Msg]));
end; // TDeviceTab.AddDeviceMessage

procedure TDeviceTab.SetTabPage(Tab : TOvcTabPage);
begin
  if Not Assigned(FMemo) and (Tab <> Nil) then
  begin
    FTabPage := Tab;
    FMemo := TMemo.Create(FTabPage);
    FTimer.Enabled := True;
    with FMemo do
    begin
      Parent := FTabPage;
      Left := 0;
      Top := 0;
      Width := 504;
      Height := 307;
      Align := alClient;
      ReadOnly := True;
      TabOrder := 0;
      ScrollBars := ssVertical;
    end; // With
  end; // If
end; // TDeviceTab.SetTabPage

procedure TDeviceTab.TimerOnTimer(Sender : TObject);
var
  TmpStr : String;
  StrIndex : LongInt;
  ElipsePos : LongInt;
  TimeOutInSec : Single;
begin
  if (FMemo.Lines.Count > 0) then
  begin
    FAccumTimeOut := FAccumTimeOut + FTimer.Interval;
    TimeOutInSec := (FTimeOutValue - FAccumTimeOut) / 1000{ms};
    StrIndex := (FMemo.Lines.Count - 1);
    TmpStr := FMemo.Lines.Strings[StrIndex];
    ElipsePos := MatchString(TmpStr,'...',1,Length(TmpStr),True,True);
    if (ELipsePos = 0) then
      TmpStr := FMemo.Lines.Strings[StrIndex] + format('%s (TimeOut in %0.2f)',[ProgressIdicators[FProgressNum],TimeOutInSec])
    else
    begin
      TmpStr := Copy(TmpStr,1,(ElipsePos - 1));
      TmpStr := TmpStr + format('%s (TimeOut in %0.2f)',[ProgressIdicators[FProgressNum],TimeOutInSec]);
    end; // If
    FMemo.Lines.Strings[StrIndex] := TmpStr;
    Inc(FProgressNum);
    if (FProgressNum > High(ProgressIdicators)) then
      FProgressNum := Low(ProgressIdicators);
  end; // If
end; // TDeviceTab.TimerOnTimer

procedure TfrmDeviceStatus.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmDeviceStatus.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

function TfrmDeviceStatus.GetNoteBookPage(DeviceAddress : Byte) : TDeviceTab;
begin
  if (PageRef[DeviceAddress] <> Nil) then
    Result := PageRef[DeviceAddress]
  else
    Result := AddNoteBookPage(DeviceAddress);
end; // TfrmDeviceStatus.GetNoteBookPage

procedure TfrmDeviceStatus.AddMessage(DeviceAddress : Byte; Msg : String; ShowProgress : Boolean; TimeOut : LongInt);
var
  DeviceTab : TDeviceTab;
begin
  DeviceTab := GetNoteBookPage(DeviceAddress);
  DeviceTab.AddDeviceMessage(Trim(Msg), ShowProgress, TimeOut);
end; // TfrmDeviceStatus.AddMessage

function TfrmDeviceStatus.AddNoteBookPage(DeviceAddress : Byte) : TDeviceTab;
begin
  Result := Nil;
  if (PageRef[DeviceAddress] = Nil) then
  begin
    PageRef[DeviceAddress] := TDeviceTab.Create(NBDevices);
    PageRef[DeviceAddress].TabPage := (NBDevices.PageCollection.Add as TOvcTabPage);
    PageRef[DeviceAddress].TabPage.Caption := format('@%0.3d',[DeviceAddress]);
    NBDevices.PageIndex := PageRef[DeviceAddress].TabPage.Index;
    Result := PageRef[DeviceAddress];
  end; // If
end; // TfrmDeviceStatus.AddNoteBookPage

procedure TfrmDeviceStatus.SetTop(Value : LongInt);
begin
  frmDeviceStatus.Top := Value;
end; // TfrmDeviceStatus.SetTop

function TfrmDeviceStatus.GetTop : LongInt;
begin
  Result := frmDeviceStatus.Top
end; // TfrmDeviceStatus.GetTop

procedure TfrmDeviceStatus.SetLeft(Value : LongInt);
begin
  frmDeviceStatus.Left := Value;
end; // TfrmDeviceStatus.SetLeft

function TfrmDeviceStatus.GetLeft : LongInt;
begin
  Result := frmDeviceStatus.Left;
end; // TfrmDeviceStatus.GetLeft

procedure TfrmDeviceStatus.NewDevice;
begin
  if (FActiveDevices < High(FActiveDevices)) then
   Inc(FActiveDevices)
  else
    FActiveDevices := 1;
  StatusBar1.Panels[0].Text := format('Active Device(s): %d',[FActiveDevices]);
end; // TfrmDeviceStatus.NewDevice

procedure TfrmDeviceStatus.RemoveDevice(Address : Byte);
begin
  Dec(FActiveDevices);
  if Assigned(PageRef[Address]) then
  begin
    NBDevices.DeletePage(PageRef[Address].TabPage.Index);
    PageRef[Address].Free;
    PageRef[Address] := Nil;
  end; // If
  StatusBar1.Panels[0].Text := format('Active Device(s): %d',[FActiveDevices]);
end; // TfrmDeviceStatus.RemoveDevice

procedure TfrmDeviceStatus.CommandSent;
begin
  if (FCommandsSent < High(FCommandsSent)) then
    Inc(FCommandsSent)
  else
    FCommandsSent := 1;
  StatusBar1.Panels[1].Text := format('Command(s) Sent: %d',[FCommandsSent]);
end; // TfrmDeviceStatus.CommandSent

procedure TfrmDeviceStatus.ResponseRecieved;
begin
  if (FResponsesRecieved < High(FResponsesRecieved)) then
    Inc(FResponsesRecieved)
  else
    FResponsesRecieved := 1;
  StatusBar1.Panels[2].Text := format('Response(s) Recieved: %d',[FResponsesRecieved]);
  MtrCommands.Percent := Trunc(((FCommandsSent / (FCommandsSent + FResponsesRecieved))) * 100);
  MtrResponses.Percent := Trunc(((FResponsesRecieved / (FCommandsSent + FResponsesRecieved))) * 100);
end; // TfrmDeviceStatus.Responses

procedure TfrmDeviceStatus.TimeOut;
begin
  if (FTimeOuts < High(FTimeOuts)) then
    Inc(FTimeOuts)
  else
    FTimeOuts := 0;
  StatusBar1.Panels[3].Text := format('Timout(s): %d',[FTimeOuts]);
end; // TfrmDeviceStatus.TimeOut


procedure TfrmDeviceStatus.FormCreate(Sender: TObject);
begin
  FShowForm := False;
  FActiveDevices := 0;
  FCommandsSent := 0;
  FResponsesRecieved := 0;
  FTimeOuts := 0;
end;

procedure TfrmDeviceStatus.SetFormShow(Value : Boolean);
begin
  FShowForm := Value;
  Self.Visible := FShowForm;
end; // TfrmDeviceStatus.SetFormShow

procedure TfrmDeviceStatus.SetActiveDeviceSearchTime(Value : LongInt);
begin
  FActiveDeviceSearchTime := Value;
end; // TfrmDeviceStatus.SetActiveDeviceSearchTime

function TfrmDeviceStatus.GetActiveDeviceSearchEnabled : Boolean;
begin
  Result := tmrActiveDeviceScan.Enabled
end; // TfrmDeviceStatus.GetActiveDeviceSearchEnabled

procedure TfrmDeviceStatus.SetActiveDeviceSearchEnabled(Value : Boolean);
begin
  if Value then
    FAccumActiveDeviceSearchTime := 0
  else
    lblActiveDeviceSearchTime.Caption := 'Active Device Search Finished';
  tmrActiveDeviceScan.Enabled := Value;
end; // TfrmDeviceStatus.SetActiveDeviceSearchEnabled

procedure TfrmDeviceStatus.tmrActiveDeviceScanTimer(Sender: TObject);
begin
  FAccumActiveDeviceSearchTime := FAccumActiveDeviceSearchTime + tmrActiveDeviceScan.Interval;
  if (FAccumActiveDeviceSearchTime <= FActiveDeviceSearchTime) then
    lblActiveDeviceSearchTime.Caption := format('Active Device Search Time Remaining; %0.3fsec of %0.3fsec',[(FAccumActiveDeviceSearchTime / 1000), (FActiveDeviceSearchTime / 1000)])
  else
  begin
    lblActiveDeviceSearchTime.Caption := 'Active Device Search Finished';
    tmrActiveDeviceScan.Enabled := False;
  end; // If
end;

end.
