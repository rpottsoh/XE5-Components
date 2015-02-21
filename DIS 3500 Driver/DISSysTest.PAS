unit DISSysTest;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdPort, AdWnPort, AdWUtil, OoMisc, OvcBase, OvcEF,
  OvcPB, OvcPF, ExtCtrls, DioCtrl, Menus, DISDriver, DISChannel, Pesgvcl,
  AdStatLt, ComCtrls;

const
  AcqBlockSize = 512;
  MaxBoxes = 1;
type
//  tResponseType = (rtNone, rtByte, rtWord, rtString);
//  tMeasuredData = (mdRaw,mdPosCal,mdNegCal);
//  tAcqTime = ( atPre, atPost );
//  tTrigUse      = (tuUse,tuDoNotUse);
//  tTrig = record
//     SwitchUse : array[1..2] of boolean;
//     CascadeUse : boolean;
//     Level      : array[1..3] of smallint;
//     LevelChan  : array[1..3] of smallint;
//  end;
//  tStatus = record
//     SampRate : integer;
//     PreDataSamps : integer;
//     Busy,
//     TriggerOccurred,
//     PowerFailAfterTriggerOccurred : boolean;
//  end;
//  tAvgCal = record
//     Zero,
//     PosCal,
//     NegCal : array[tAcqTime] of smallint;
//  end;
//  tDISDataBlock = array[0..AcqBlockSize-1] of smallint; // -2048 to 2047 for each
//  TDasType = (OtherDas,KyowaDAS,MicroStar,EMEDas);
  TfrmDISSysTest = class(TForm)
    Panel1: TPanel;
    btnConnect: TButton;
    Label1: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    btnSendToDIS: TButton;
    fldSend: TOvcPictureField;
    OvcController1: TOvcController;
    grpbxStatus: TGroupBox;
    fldStatusFlag: TOvcPictureField;
    Label4: TLabel;
    Label5: TLabel;
    fldStatusBytes: TOvcPictureField;
    Label6: TLabel;
    fldBytesReceived: TOvcPictureField;
    memoResponseData: TMemo;
    fldAddress: TOvcPictureField;
    Button1: TButton;
    btnTrigSwitchUse: TButton;
    tmrTimeOut: TTimer;
    btnEnableTrig: TButton;
    btnStatus: TButton;
    btnAbort: TButton;
    btnStartAcq: TButton;
    Button3: TButton;
    btnClear: TButton;
    btnGetChanRange: TButton;
    btnGetAvgCal: TButton;
    btnSetLevelUse: TButton;
    btnStopMonitor: TButton;
    btnStartMon: TButton;
    btnBalance: TButton;
    l1: TDioLed;
    btndownload: TButton;
    btnErase: TButton;
    menuMain: TMainMenu;
    menuDIS: TMenuItem;
    menuIPAddress: TMenuItem;
    menuROMVer: TMenuItem;
    menuModChk: TMenuItem;
    menuMemChk: TMenuItem;
    ExitDISSysTest1: TMenuItem;
    menuSetup: TMenuItem;
    menuSetMemo: TMenuItem;
    SamplingRate1: TMenuItem;
    Filtering1: TMenuItem;
    menuTriggers: TMenuItem;
    Label7: TLabel;
    fldErrorStr: TOvcPictureField;
    menuSetIPAddress: TMenuItem;
    menuGetMemo: TMenuItem;
    Label9: TLabel;
    menuSetTriggerMode: TMenuItem;
    menuGetTriggerMode: TMenuItem;
    On1: TMenuItem;
    Off1: TMenuItem;
    Label11: TLabel;
    SetSamplingRate1: TMenuItem;
    GetSamplingRate1: TMenuItem;
    N1: TMenuItem;
    menuSwTr1: TMenuItem;
    menuSwTrOn1: TMenuItem;
    menuSwTrStat1: TMenuItem;
    menuSwTr2: TMenuItem;
    menuSwTrOn2: TMenuItem;
    menuSwTrStat2: TMenuItem;
    menuCaTr: TMenuItem;
    menuCaTrOn: TMenuItem;
    menuCaTrStat: TMenuItem;
    menuLvTr1: TMenuItem;
    menuLvTrOn1: TMenuItem;
    menuLvTrStat1: TMenuItem;
    menuLvTr2: TMenuItem;
    menuLvTrOn2: TMenuItem;
    menuLvTrStat2: TMenuItem;
    menuLvTr3: TMenuItem;
    menuLvTrOn3: TMenuItem;
    menuLvTrStat3: TMenuItem;
    IPAddress1: TMenuItem;
    Memo1: TMenuItem;
    TriggerMode1: TMenuItem;
    N3: TMenuItem;
    N5: TMenuItem;
    EnableTrigger1: TMenuItem;
    EnableTrigger2: TMenuItem;
    DataSize1: TMenuItem;
    SetPreTriggerSamples1: TMenuItem;
    GetPreTriggerSamples1: TMenuItem;
    N9: TMenuItem;
    ClearMemory1: TMenuItem;
    GetTriggerPoint1: TMenuItem;
    menuAcquire: TMenuItem;
    Start1: TMenuItem;
    Stop1: TMenuItem;
    Status2: TMenuItem;
    N10: TMenuItem;
    menuDownload: TMenuItem;
    N4: TMenuItem;
    Gain1: TMenuItem;
    SetGain1: TMenuItem;
    GetGain1: TMenuItem;
    N7: TMenuItem;
    SensorType1: TMenuItem;
    SetSensorType1: TMenuItem;
    GetSensorType1: TMenuItem;
    GainCheck1: TMenuItem;
    ExcitationCheck1: TMenuItem;
    DACReferenceCheck1: TMenuItem;
    Batteries1: TMenuItem;
    menuCheck: TMenuItem;
    Balance1: TMenuItem;
    Start3: TMenuItem;
    Abort2: TMenuItem;
    Status1: TMenuItem;
    N8: TMenuItem;
    N12: TMenuItem;
    REal1: TMenuItem;
    N14: TMenuItem;
    AirbagTimer1: TMenuItem;
    btnAirbagTimerOn: TMenuItem;
    CurrentLevel1: TMenuItem;
    Delay1: TMenuItem;
    SetLevel1: TMenuItem;
    Status3: TMenuItem;
    SetDelay1: TMenuItem;
    Status4: TMenuItem;
    SquibResistance1: TMenuItem;
    Start4: TMenuItem;
    Status5: TMenuItem;
    menuInhibitSquibFire: TMenuItem;
    TriggerStatus1: TMenuItem;
    SafetyLockStatus1: TMenuItem;
    ChargeStatus1: TMenuItem;
    SetupChansStart1: TMenuItem;
    ReadChanData1: TMenuItem;
    Stop2: TMenuItem;
    menuEStop: TMenuItem;
    grpboxAltInputs: TGroupBox;
    Label10: TLabel;
    Nu: TLabel;
    Label8: TLabel;
    fldSlotInput: TOvcPictureField;
    fldNumericInput: TOvcPictureField;
    fldStringInput: TOvcPictureField;
    menuGetData: TMenuItem;
    btnAirbagTimerOff: TMenuItem;
    btnATStatus: TMenuItem;
    GetTriggerSource1: TMenuItem;
    ShuntEmulation2: TMenuItem;
    Remainder1: TMenuItem;
    StartDischarge1: TMenuItem;
    Status6: TMenuItem;
    ResetBQ20101: TMenuItem;
    GetBQ20101: TMenuItem;
    RestoreLog1: TMenuItem;
    GetLastLogNumber1: TMenuItem;
    Start2: TMenuItem;
    Abort1: TMenuItem;
    ShuntCalibration1: TMenuItem;
    Plus1: TMenuItem;
    Minus1: TMenuItem;
    PretestZeroStore1: TMenuItem;
    N6: TMenuItem;
    ShuntCalibration2: TMenuItem;
    PosttestPositive1: TMenuItem;
    PosttestNegative1: TMenuItem;
    PosttestZero1: TMenuItem;
    Graph1: PESGraph;
    Dis3500Drv: TDis3500Drv;
    Button2: TButton;
    tmrMonitor: TTimer;
    lblADval: TLabel;
    lblADVal2: TLabel;
    lblADVal3: TLabel;
    lblADVal4: TLabel;
    pnlTrigStat: TPanel;
    Label12: TLabel;
    ledTriggered: TApdStatusLight;
    tmrTriggerCheck: TTimer;
    Label13: TLabel;
    fldStartPt: TOvcPictureField;
    btnShunt: TButton;
    Label14: TLabel;
    fldDlPts: TOvcPictureField;
    Label15: TLabel;
    fldTrgCtr: TOvcPictureField;
    menuSafety: TMenuItem;
    GetSquibFireResult1: TMenuItem;
    N11: TMenuItem;
    SoftwareBreak1: TMenuItem;
    SquibSafetyPreTest1: TMenuItem;
    ChargeStatusnotcharged1: TMenuItem;
    LockPlugStatusplugin1: TMenuItem;
    SquibSafetyReadyforTesting1: TMenuItem;
    ChargeStatuscharged1: TMenuItem;
    LockPlugStatusplugout1: TMenuItem;
    N2: TMenuItem;
    N13: TMenuItem;
    StopSquibFire1: TMenuItem;
    lblErrStr: TLabel;
    AllChannels1: TMenuItem;
    SingleChannel1: TMenuItem;
    lblMemClear: TLabel;
    N15: TMenuItem;
    TestMeasurement1: TMenuItem;
    pbGetData: TProgressBar;
    lblTotalPackets: TLabel;
    lblPacketsReceived: TLabel;
    Timer1: TTimer;
    Label16: TLabel;
    procedure btnConnectClick(Sender: TObject);
//    procedure ApdWinsockPort1WsConnect(Sender: TObject);
//    procedure ApdWinsockPort1TriggerAvail(CP: TObject; Count: Word);
//    procedure ApdWinsockPort1WsError(Sender: TObject; ErrCode: Integer);
//    procedure ApdWinsockPort1WsDisconnect(Sender: TObject);
    procedure btnSendToDISClick(Sender: TObject);
//    procedure SetResponseBlockSize( DISStr : string );
//    procedure ProcessResponseBlock( Count : word );
//    function SetResponseType( DISStr : string ) : boolean;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnTrigSwitchUseClick(Sender: TObject);
    procedure tmrTimeOutTimer(Sender: TObject);
    procedure btnEnableTrigClick(Sender: TObject);
    procedure btnStatusClick(Sender: TObject);
    procedure btnAbortClick(Sender: TObject);
    procedure btnStartAcqClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnGetChanRangeClick(Sender: TObject);
    procedure btnGetAvgCalClick(Sender: TObject);
    procedure btnSetLevelUseClick(Sender: TObject);
    procedure btnStartMonClick(Sender: TObject);
    procedure btnStopMonitorClick(Sender: TObject);
    procedure btnBalanceClick(Sender: TObject);
    procedure btndownloadClick(Sender: TObject);
    procedure btnEraseClick(Sender: TObject);
    procedure menuROMVerClick(Sender: TObject);
    procedure menuIPAddressClick(Sender: TObject);
    procedure menuSetIPAddressClick(Sender: TObject);
    procedure ExitDISSysTest1Click(Sender: TObject);
    procedure menuMemChkClick(Sender: TObject);
    procedure menuSetMemoClick(Sender: TObject);
    procedure menuGetMemoClick(Sender: TObject);
    procedure DisplayStatus;
    procedure menuSetTriggerModeClick(Sender: TObject);
    procedure menuGetTriggerModeClick(Sender: TObject);
    procedure btnLPFFilterClick(Sender: TObject);
    procedure menuMod4Click(Sender: TObject);
    function GetNumericVal( Caption, Instruct : string; var value : integer ): boolean;
    function GetFloatVal( Caption, Instruct : string; var value : double ): boolean;
    function GetChannelVal( Caption, Instruct : string; var value : integer ): boolean;
    function GetSensorVal( Caption, Instruct : string; var value : integer ) : boolean;
    function GetMultiVal( Caption, Instruct : string; var value : TMultiChan ) : boolean;
    procedure menuModChkClick(Sender: TObject);
    procedure SetSamplingRate1Click(Sender: TObject);
    procedure GetSamplingRate1Click(Sender: TObject);
    procedure SetPreTriggerSamples1Click(Sender: TObject);
    procedure GetPreTriggerSamples1Click(Sender: TObject);
    procedure menuEStopClick(Sender: TObject);
    procedure menuSwTrOn1Click(Sender: TObject);
    procedure menuSwTrStat1Click(Sender: TObject);
    procedure menuSwTrOn2Click(Sender: TObject);
    procedure menuSwTrStat2Click(Sender: TObject);
    procedure menuCaTrOnClick(Sender: TObject);
    procedure menuCaTrStatClick(Sender: TObject);
    procedure menuLvTrOn1Click(Sender: TObject);
    procedure menuLvTrOn2Click(Sender: TObject);
    procedure menuLvTrOn3Click(Sender: TObject);
    procedure menuLvTrStat1Click(Sender: TObject);
    procedure menuLvTrStat2Click(Sender: TObject);
    procedure menuLvTrStat3Click(Sender: TObject);
    procedure EnableTrigger2Click(Sender: TObject);
    procedure SetGain1Click(Sender: TObject);
    procedure GetGain1Click(Sender: TObject);
    procedure SetSensorType1Click(Sender: TObject);
    procedure GetSensorType1Click(Sender: TObject);
    procedure ClearMemory1Click(Sender: TObject);
    procedure Stop2Click(Sender: TObject);
    procedure SetupChansStart1Click(Sender: TObject);
    procedure ReadChanData1Click(Sender: TObject);
    procedure Balance1Click(Sender: TObject);
    procedure menuGetDataClick(Sender: TObject);
    procedure btnAirbagTimerClick(Sender: TObject);
    procedure btnATStatusClick(Sender: TObject);
    procedure SetLevel1Click(Sender: TObject);
    procedure Status3Click(Sender: TObject);
    procedure SetDelay1Click(Sender: TObject);
    procedure Status4Click(Sender: TObject);
    procedure GainCheck1Click(Sender: TObject);
    procedure ExcitationCheck1Click(Sender: TObject);
    procedure Start3Click(Sender: TObject);
    procedure Abort2Click(Sender: TObject);
    procedure GetTriggerSource1Click(Sender: TObject);
    procedure Stop1Click(Sender: TObject);
    procedure Start1Click(Sender: TObject);
    procedure DACReferenceCheck1Click(Sender: TObject);
    procedure Start2Click(Sender: TObject);
    procedure Abort1Click(Sender: TObject);
    procedure Status1Click(Sender: TObject);
    procedure Status2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure tmrMonitorTimer(Sender: TObject);
    procedure tmrTriggerCheckTimer(Sender: TObject);
    procedure ChargeStatus1Click(Sender: TObject);
    procedure SafetyLockStatus1Click(Sender: TObject);
    procedure menuInhibitSquibFireClick(Sender: TObject);
    procedure TriggerStatus1Click(Sender: TObject);
    procedure Status5Click(Sender: TObject);
    procedure Start4Click(Sender: TObject);
    procedure GetTriggerPoint1Click(Sender: TObject);
    procedure GetSquibFireResult1Click(Sender: TObject);
    procedure SoftwareBreak1Click(Sender: TObject);
    procedure AllChannels1Click(Sender: TObject);
    procedure TestMeasurement1Click(Sender: TObject);
    procedure Dis3500DrvGetDataStatus(sender: TObject; Chan,
      PacketsRequested, PacketsReceived, PointsReceived, PointsRequested: Integer);
    procedure Timer1Timer(Sender: TObject);
  private
    TempBlock,
    ResponseBlock     : array[0..16383] of byte;
    ResponseBlockSize : integer;
//    ResponseType      : tResponseType;
    LastTriggerCount  : integer;
    DISDataBlock : tDISDataBlock;
    DataStr : string;
    TimeOut : boolean;
    PointCount : array[1..4] of LongInt;
    GraphCleared : array[1..4] of boolean;
    InGetDataEvent : boolean;
    count201 : integer;
    OkToRestart : boolean;
    QuitMon : boolean;
    function InitializeMenuStates : boolean;
    { Private declarations }
  public
    { Public declarations }
    DISStatus    : word;
    DISOpened    : boolean;
    TriggerProcessed  : boolean;
//    function SendToDIS( DISStr : string ) : boolean;
//    procedure ToggleConnect;
  end;

  var
    frmDISSysTest: TfrmDISSysTest;
    progpath : string;

//   procedure GetData(      Chan : integer;
//                        StartPos : integer;
//                        Block : word;
//                    var Data : tDISDataBlock );

//    function ConnectToDAS(const DasNum : integer; const DT : TDasType;
//      const IpAddr : string):integer;
    function BalanceChannels(Box : word) : byte;
    function DisconnectFromDAS(const DasNum : integer): integer;
    function DISOpen : boolean;
    function DISClose : boolean;
    function ClearFlashMemory( Box : word; Channel : word ) : byte;
//    function GetChannelData( Box : word; Chan      : word;
//                                              StartPos  : integer;
//                                              Count     : integer;
//                                          var Data      : tDISDataBlock) : byte;

//    function GetTriggerSetting( Box : word; var Trig : tTrig ) : byte;
    function SetSwitchTriggerUse( Box : word; Trg1Use, Trg2Use : tTrigUse ) : byte;
    function SetCascadeTriggerUse( Box : word) : byte;
    function SetLevelTriggerUse( Box : word) : byte;
//    function ReadStatus( Box : word; var Status : tStatus ) : byte;
    function EnableTrigger( Box : word ) : byte;
    function AbortAcquire( Box : word ) : byte;
    function StartAcquire( Box : word ) : byte;
    function TriggerCheck( Box : word ) : byte;
    function GetChanRange(  Box : word; Chan  : word; var Range : word ) : byte;

//    function GetChanAvgCal(  Box : word;    Chan  : word; var AvgCal : tAvgCal) : byte;
    procedure Create_DIS_Client;
    procedure Destroy_DIS_Client;
    Function CalcRangeValue( XdcrFS_mVperV, XdcrFS_EU, DesRange_EU : double;
                              var ActRange_EU : double  ) : word;
    Function SetRealTimeMonitorChans( Box : word;
                                  Chan1, Chan2, Chan3, Chan4 : byte;
                                  DataKind : tMeasuredData ) : byte;
    Function ReadRealTimeMonitorData( Box : word;
                                  var Ch1Data : smallint;
                                  var Ch2Data : smallint;
                                  var Ch3Data : smallint;
                                  var Ch4Data : smallint  ) : byte;
    Function QuitRealTimeMonitor( Box : word ) : byte;

implementation
uses
Pegrpapi;
{$R *.DFM}
var
  DISChan : TDISChannel;
  MonitorOpen : array[1..MaxBoxes] of boolean;
  QuitMon : boolean;
  tempstr : string;
  AutoMonitor, AutoTriggerCheck : boolean;
  AvgCount : integer;
  Sum, Sum2, Sum3, Sum4 : double;
  TrigCount : integer;

procedure delay(msec:longint);
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

//function ConnectToDAS(const DasNum : integer; const DT : TDasType;
//    const IpAddr : string):integer;
//begin
//  Result := 5;
//  frmDISSysTest.fldAddress.AsString := IpAddr;
//  if DISOpen then
//    Result := 0;;
//end;

function DisconnectFromDAS(const DasNum : integer): integer;
begin
  Result := 1;  // not success;
  if DISClose then
    Result := 0;
end;

procedure Create_DIS_Client;
begin
  if not assigned(frmDISSysTest) then
    frmDISSysTest := tfrmDISSysTest.Create(nil);
end;
 
procedure Destroy_DIS_Client;
begin
  if assigned(frmDISSysTest) then
  begin
    if frmDISSysTest.Visible then
      frmDISSysTest.close;
    frmDISSysTest.free;
    frmDISSysTest := nil;
  end;
end;

//------------------------------[CalcRangeValue]--------------------------------
// Returns the correct Range to send to channel (microstrain)
// Also, returns the Actual Range in EU
// NOTE:  Neither XdcrFS_mVperV nor XdcrFS_EU can be zero or a divide by
//        zero will result!
//------------------------------------------------------------------------------
Function CalcRangeValue( XdcrFS_mVperV, XdcrFS_EU, DesRange_EU : double;
                         var ActRange_EU : double  ) : word;
var
  TempRange     : double;
  RangeMultiple : integer;
  CalcRange     : integer;
begin
  TempRange := (((XdcrFS_mVperV*DesRange_EU))/XdcrFS_EU)*500{microstrain/mV/V};
  RangeMultiple := (trunc(TempRange) DIV 100) + 1;
  if RangeMultiple < 2 then
    RangeMultiple := 2;
  if RangeMultiple > 100 then
    RangeMultiple := 100;
  CalcRange := RangeMultiple * 100;
  ActRange_EU := (CalcRange * XdcrFS_EU) / (XdcrFS_mVperV * 500);
  Result := CalcRange;
end;

//procedure TfrmDISSysTest.ToggleConnect;
//  {Connect button click - attempts to connect}
//begin
//  ApdWinsockPort1.wsAddress := fldAddress.AsString;
//  ApdWinsockPort1.Open := not(ApdWinsockPort1.Open);
//  if ApdWinsockPort1.Open then
//  begin
//    Label1.Caption := 'Attempting to connect';
//    fldStatusFlag.AsString := '';
//    fldBytesReceived.AsString := '';
//    fldStatusBytes.AsString := '';
//    memoResponseData.Clear;
//    fldAddress.enabled := FALSE;
//  end
//  else
//  begin
//    DISOpened := FALSE;
//    fldAddress.enabled := TRUE;
//  end;
//end;

//------------------------------------------------------------------------------
// sets the trigger and various other "checked" menu states according to what
// exists in the box so next click on these menu items will reflect properly
//------------------------------------------------------------------------------
function TfrmDISSysTest.InitializeMenuStates : boolean;
var
  Use : ttriguse;
  dumChan : integer;
  dumVal : smallint;
begin
  Result := False;
  if Dis3500Drv.GetTriggerSW1( Use ) then
  begin
    if Use = tuUse then
      menuSwTrOn1.Checked := TRUE
    else
      menuSwTrOn1.Checked := FALSE;
  end
  else
    exit;
//  if Dis3500Drv.GetTriggerSW2( Use ) then       hardware problem with SW2
//  begin
//    if Use = tuUse then
//      menuSwTrOn2.Checked := TRUE
//    else
//      menuSwTrOn2.Checked := FALSE;
//  end
//  else
//    exit;
  if Dis3500Drv.GetTriggerCascade( Use ) then
  begin
    if Use = tuUse then
      menuCaTrOn.Checked := TRUE
    else
      menuCaTrOn.Checked := FALSE;
  end
  else
    exit;
  if Dis3500Drv.GetTriggerLevel1( Use, dumChan, dumVal ) then
  begin
    if Use = tuUse then
      menuLvTrOn1.Checked := TRUE
    else
      menuLvTrOn1.Checked := FALSE;
  end
  else
    exit;
  if Dis3500Drv.GetTriggerLevel2( Use, dumChan, dumVal ) then
  begin
    if Use = tuUse then
      menuLvTrOn2.Checked := TRUE
    else
      menuLvTrOn2.Checked := FALSE;
  end
  else
    exit;
  if Dis3500Drv.GetTriggerLevel3( Use, dumChan, dumVal ) then
  begin
    if Use = tuUse then
      menuLvTrOn3.Checked := TRUE
    else
      menuLvTrOn3.Checked := FALSE;
  end
  else
    exit;
  if Dis3500Drv.SetInhibitSquibState( uOn ) then
    menuInhibitSquibFire.Checked := TRUE; 
  Result := True;
end;

procedure TfrmDISSysTest.btnConnectClick(Sender: TObject);
  {Connect button click - attempts to connect}
begin
  if NOT(Dis3500Drv.ConnectedToDIS) then
  begin
    Dis3500Drv.Address := fldAddress.AsString;
    if Dis3500Drv.ConnectToDIS then
    begin
      Label1.Caption := 'Connected';
      btnConnect.Caption := 'Disconnect';
      lblErrStr.visible := false;
      fldStatusFlag.AsString := '';
      fldBytesReceived.AsString := '';
      fldStatusBytes.AsString := '';
      memoResponseData.Clear;
      fldAddress.enabled := FALSE;
      menuDIS.Enabled := TRUE;
      menuSafety.Enabled := TRUE;
      menuSetup.Enabled := TRUE;
      menuDownload.Enabled := TRUE;
      menuAcquire.Enabled := TRUE;
      menuCheck.Enabled := TRUE;
      delay(50);
      if NOT(InitializeMenuStates) then
        MessageDlg('Error reading initial trigger statuses from the DIS-3500A', mtError, [mbOK], 0);;
      DisplayStatus;
    end
    else
    begin
      lblErrStr.caption := Dis3500Drv.ErrorStr;
      lblErrStr.visible := true;
    end;
  end
  else
  begin
    if Dis3500Drv.DisconnectFromDIS then
    begin
      Label1.Caption := 'Disconnected';
      btnConnect.Caption := 'Connect';
      fldAddress.enabled := TRUE;
      menuSafety.Enabled := FALSE;
      menuDIS.Enabled := FALSE;
      menuSetup.Enabled := FALSE;
      menuDownload.Enabled := FALSE;
      menuAcquire.Enabled := FALSE;
      menuCheck.Enabled := FALSE;
    end;
  end;
end;

//procedure TfrmDISSysTest.ApdWinsockPort1WsConnect(Sender: TObject);
//  {Event OnWsConnect -change Button1 after connected}
//begin
////  DISOpened := TRUE;
////  Label1.Caption := 'Connected';
////  btnConnect.Caption := 'Disconnect';
//// next is example how to write to Server
//// ApdWinsockPort1.Output := 'Hello from Client';
//end;

//procedure TfrmDISSysTest.ProcessResponseBlock( Count : word );
//var StatusFlag : word;
//    ResponseSizeBack : word;
//    i : word;
//    MemoStr : string;
//    TempWord : smallint;
//begin
//  StatusFlag := ResponseBlock[0] shl 8 + ResponseBlock[1];
//  DISStatus := StatusFlag;
//  fldStatusFlag.AsString := IntToStr(StatusFlag);
//  fldBytesReceived.AsString := IntToStr(Count);
//  ResponseSizeBack := ResponseBlock[2] shl 8 + ResponseBlock[3];
//  fldStatusBytes.AsString := IntToStr(ResponseSizeBack);
//  memoResponseData.Clear;
//  case ResponseType of
//    rtByte : begin
//               MemoStr := format('%2x', [ResponseBlock[16]]);
//               for i := 1 to (ResponseSizeBack-1) do
//                 MemoStr :=  MemoStr + #13#10+ format('%2x', [ResponseBlock[i+16]]);
//               memoResponseData.lines[0] := MemoStr;
//             end;
//    rtWord : begin
//               TempWord := smallint(((ResponseBlock[16] shl 8 + ResponseBlock[17]) AND $0FFF) shl 4) DIV 16;
//               MemoStr := IntToStr(TempWord);
//               DISDataBlock[0] := TempWord;
//               for i := 1 to ((ResponseSizeBack DIV 2)-1) do
//               begin
//                 TempWord := smallint(((ResponseBlock[i*2+16] shl 8 + ResponseBlock[i*2+17]) AND $0FFF) shl 4) DIV 16;
//                 DISDataBlock[i] := TempWord;
//                 MemoStr :=  MemoStr + #13#10+ inttostr(TempWord);
//               end;
//               memoResponseData.lines[0] := MemoStr;
//             end;
//    rtString : begin
//                 MemoStr := '';
//                 for i := 0 to (ResponseSizeBack-1) do
//                   MemoStr := MemoStr + chr(ResponseBlock[i+16]);
//                 memoResponseData.lines[0] := MemoStr;
//                 DataStr := MemoStr;
//               end;
//    rtNone : begin
//               memoResponseData.lines[0] := 'N/A';
//             end;
//  end;
//end;

//procedure TfrmDISSysTest.ApdWinsockPort1TriggerAvail(CP: TObject; Count: Word);
//  {Event OnTriggerAvail}
//var
//  I : Word;
//  BeginVal, EndVal : integer;
//begin
//  BeginVal := LastTriggerCount + 1;
//  EndVal   := LastTriggerCount + Count;
//  for I := BeginVal to EndVal do
//    ResponseBlock[i-1] := byte(ApdWinsockPort1.GetChar);
//
//  if (EndVal >= ResponseBlockSize) AND (ResponseBlockSize <> 0) AND
//      NOT(TriggerProcessed) then
//  begin
//    ProcessResponseBlock( ResponseBlockSize );
//    TriggerProcessed := TRUE;
//  end;
//  LastTriggerCount := EndVal;
//end;
//
//procedure TfrmDISSysTest.ApdWinsockPort1WsError(Sender: TObject; ErrCode: Integer);
//  {Event WsError - display error in Label3}
//begin
//  Label1.Caption := 'Error...';
//  Label3.Caption := 'Code: ' + IntToStr(ErrCode);
//end;
//
//procedure TfrmDISSysTest.ApdWinsockPort1WsDisconnect(Sender: TObject);
//  {Event WsDisconnect - Change Button1 back}
//begin
//  Label1.Caption := '';
//  Label2.Caption := '';
//  btnConnect.Caption := 'Connect';
//end;

//procedure TfrmDISSysTest.SetResponseBlockSize( DISStr : string );
//begin
//  ResponseBlockSize := 256; // most commands
//  if (pos('RED ', DISStr) = 1)
//  then
//    ResponseBlockSize := 8192 // 5016  // RED can go bigger, but I limit it to this.  --meh
//  else if (pos('MST', DISStr) = 1)
//  then
//    ResponseBlockSize := 32
//  else if (pos('CLFL', DISStr) = 1) OR
//     ((pos('STA', DISStr) = 1) AND (pos('STA1',DISStr) = 0)) // make sure not STA1 because it is 256
//  then
//    ResponseBlockSize := 0;  // this is don't care situation
//end;
//
//function TfrmDISSysTest.SetResponseType( DISStr : string ) : boolean;
//begin
//  Result := TRUE;
//  if (pos('MCR', DISStr) = 1) OR
//     (pos('GET-ROM-VERSION', DISStr) = 1) OR
//     (pos('IPGET', DISStr) = 1) OR
//     (pos('STFL', DISStr) = 1) OR
//     (pos('CHR ', DISStr) = 1) OR
//     (pos('LD ', DISStr) = 1) OR
//     (pos('TRR', DISStr) = 1) OR
//     (pos('BSR', DISStr) = 1) OR
//     (pos('BLR ', DISStr) = 1)
//     then
//    ResponseType := rtString
//  else if (DISStr = 'MCK') OR
//     (pos('CHS', DISStr) = 1) OR
//     (pos('CLFL', DISStr) = 1) OR
//     (pos('CHE ', DISStr) = 1) OR
//     (pos('TRG1 ', DISStr) = 1) OR
//     (pos('TRG2 ', DISStr) = 1) OR
//     (pos('TRG3 ', DISStr) = 1) OR
//     (pos('TRE', DISStr) = 1) OR
//     (pos('STP', DISStr) = 1) OR
//     (pos('STA', DISStr) = 1) OR   // use for STA1, also
//     (pos('ZER B', DISStr) = 1) OR
//     (pos('ZER A', DISStr) = 1) OR
//     (pos('+CA A', DISStr) = 1) OR
//     (pos('-CA A', DISStr) = 1) OR
//     (pos('+CA B', DISStr) = 1) OR
//     (pos('-CA B', DISStr) = 1) OR
//     (pos('RNGS ', DISStr) = 1) OR
//     (pos('MODS ', DISStr) = 1) OR
//     (pos('PTR ', DISStr) = 1) OR
//     (pos('SPL ', DISStr) = 1) OR
//     (pos('BLS ', DISStr) = 1) OR
//     (pos('BAL', DISStr) = 1) OR
//     (pos('MONX ', DISStr) = 1) OR
//     (pos('EXT', DISStr) = 1)
//     then
//    ResponseType := rtNone
//  else if (pos('IPGET', DISStr) = 1) OR
//    (pos('IPSET', DISStr) = 1) OR
//    (pos('BIR', DISStr) = 1) OR
//    (pos('BTS', DISStr) = 1) OR
//    (pos('BTR', DISStr) = 1) OR
//    (pos('SV ', DISStr) = 1) OR
//    (pos('STS', DISStr) = 1) OR
//    (pos('TRS', DISStr) = 1) OR
//    (pos('MODR ', DISStr) = 1) OR
//    (pos('STS3', DISStr) = 1)
//    then
//    ResponseType := rtByte
//  else if (pos('RED ', DISStr) = 1) OR
//     (pos('TMS ', DISStr) = 1) OR
//     (pos('MST', DISStr) = 1) OR
//     (pos('RNGR ', DISStr) = 1) OR
//     (pos('CRD ', DISStr) = 1)
//    then
//    ResponseType := rtWord
//
//  else
//    Result := FALSE;
//end;
//
////------------------------------------------------------------------------------
//// Returns FALSE if asking for a command that isn't supported
////------------------------------------------------------------------------------
//function TfrmDISSysTest.SendToDIS( DISStr : string ) : boolean;
//begin
//  Result := TRUE;
//  if SetResponseType( DISStr ) then
//  begin
//    fldStatusFlag.AsString := '';
//    fldBytesReceived.AsString := '';
//    fldStatusBytes.AsString := '';
//    memoResponseData.Clear;
//    TriggerProcessed := FALSE;
//    LastTriggerCount := 0;
//    SetResponseBlockSize( DISStr );
//
//    ApdWinsockPort1.Output := DISStr+#0;
//  end
//  else
//    Result := FALSE;
//end;
//
procedure TfrmDISSysTest.btnSendToDISClick(Sender: TObject);
//var
//  DISStr : string;
begin
//  DISStr := fldSend.AsString;
//  if SetResponseType( DISStr ) then
//  begin
//    fldStatusFlag.AsString := '';
//    fldBytesReceived.AsString := '';
//    fldStatusBytes.AsString := '';
//    memoResponseData.Clear;
//    TriggerProcessed := FALSE;
//    LastTriggerCount := 0;
//    SetResponseBlockSize( DISStr );
//    ApdWinsockPort1.Output := DISStr+#0;
//  end
//  else
//    MessageDlg('Command '+DISStr+ ' not supported.', mtError, [mbOK], 0);
end;

procedure TfrmDISSysTest.FormCreate(Sender: TObject);
begin
//  APDWinsockPort1.wsTelnet := FALSE;
  fldAddress.AsString := '192.168.0.200';
//  DISOpened := FALSE;
      menuDIS.Enabled := FALSE;
      menuSafety.Enabled := FALSE;
      menuSetup.Enabled := FALSE;
      menuDownload.Enabled := FALSE;
      menuAcquire.Enabled := FALSE;
      menuCheck.Enabled := FALSE;
  fillchar(GraphCleared, sizeof(GraphCleared),#0);

end;

procedure TfrmDISSysTest.Button1Click(Sender: TObject);
//var Trig : tTrig;
//    Box : word;
begin
//  GetTriggerSetting( Box, Trig );
end;

function DISOpen : boolean;
begin
//  with frmDISSysTest do
//  begin
//    if NOT(DISOpened) then
//    begin
//      ToggleConnect;
//      repeat
//        application.processmessages;
//      until DISOpened;
//    end;
//  end;
end;

function DISClose : boolean;
begin
//  with frmDISSysTest do
//  begin
//    if (DISOpened) then
//    begin
//      ToggleConnect;
//      repeat
//        application.processmessages;  // need a timeout here
//      until NOT(DISOpened);
//    end;
//  end;
end;

//function GetTriggerSetting( Box : word; var Trig : tTrig ) : byte;
//var  LocTimeOut : boolean;
//begin
//  with frmDISSysTest do
//  begin
//    Result := 0;
//    fldSend.AsString := 'TRR';
//    btnSendToDISClick(btnSendToDIS);
//    tmrTimeOut.Enabled := TRUE;
//    TimeOut := FALSE;
//    repeat
//      application.processmessages;
//    until TriggerProcessed OR TimeOut;
//    tmrTimeOut.Enabled := FALSE;
//    if TimeOut then
//      LocTimeOut := TRUE
//    else
//    begin
//      LocTimeOut := FALSE;
//      with Trig do
//      begin
//        SwitchUse[1]  :=  copy(DataStr,1,1) = '1';
//        SwitchUse[2]  :=  copy(DataStr,3,1) = '1';
//        CascadeUse :=  copy(DataStr,5,1) = '1';
//      end;
//      Result := DISStatus;
//    end;
//    if LocTimeOut then
//      Result := 201;
//  end;
//end;

function GetChanRange(     Box : word;
                          Chan : word;
                       var Range : word ) : byte;
var
  LocTimeOut : boolean;
begin
  with frmDISSysTest do
  begin
    Result := 0;
    fldSend.AsString := format('RNGR %d,%d', [Chan,Chan]);
    btnSendToDISClick(btnSendToDIS);
    tmrTimeOut.Enabled := TRUE;
    TimeOut := FALSE;
    repeat
      application.processmessages;
    until TriggerProcessed OR TimeOut;
    tmrTimeOut.Enabled := FALSE;
    if TimeOut then
      LocTimeOut := TRUE
    else
    begin
      LocTimeOut := FALSE;
      Range := DISDataBlock[0];
      Result := DISStatus;
    end;
    if LocTimeOut then
      Result := 201;

  end;
end;

//function GetChanAvgCal(     Box  : word;
//                            Chan  : word;
//                       var AvgCal : tAvgCal) : byte;
//var LocTimeOut : boolean;
//begin
//  with frmDISSysTest do
//  begin
//    Result := 0;
//    fldSend.AsString := format('CRD %d', [Chan]);
//    btnSendToDISClick(btnSendToDIS);
//    tmrTimeOut.Enabled := TRUE;
//    TimeOut := FALSE;
//    repeat
//      application.processmessages;
//    until TriggerProcessed OR TimeOut;
//    tmrTimeOut.Enabled := FALSE;
//    if TimeOut then
//      LocTimeOut := TRUE
//    else
//    begin
//      LocTimeOut := FALSE;
//      AvgCal.Zero[atPre] := DISDataBlock[0];
//      AvgCal.Zero[atPost] := DISDataBlock[1];
//      AvgCal.PosCal[atPre] := DISDataBlock[2];
//      AvgCal.PosCal[atPost] := DISDataBlock[3];
//      AvgCal.NegCal[atPre] := DISDataBlock[4];
//      AvgCal.NegCal[atPost] := DISDataBlock[5];
//      Result := DISStatus;
//    end;
//    if LocTimeOut then
//      Result := 201;
//  end;
//end;

//function ReadStatus( Box : word;
//                     var Status : tStatus ) : byte;
//var
//  LocTimeOut : boolean;
//  StatByte : byte;
//begin
//  with frmDISSysTest do
//  begin
//    Result := 0;
//    fldSend.AsString := 'STS';
//    btnSendToDISClick(btnSendToDIS);
//    tmrTimeOut.Enabled := TRUE;
//    TimeOut := FALSE;
//    repeat
//      application.processmessages;
//    until TriggerProcessed OR TimeOut;
//    tmrTimeOut.Enabled := FALSE;
//    if TimeOut then
//      LocTimeOut := TRUE
//    else
//    begin
//      LocTimeOut := FALSE;
//      with Status do
//      begin
//        StatByte := ResponseBlock[16];
//        case StatByte of
//          0: SampRate := 500;
//          1: SampRate := 1000;
//          2: SampRate := 2000;
//          3: SampRate := 16000;
//          4: SampRate := 5000;
//          5: SampRate := 10000;
//          6: SampRate := 20000;
//          7: SampRate := 100;
//          8: SampRate := 200;
//        end;
//        StatByte := ResponseBlock[17];
//        PreDataSamps := StatByte * 512;
//        StatByte := ResponseBlock[18];
//        Busy  := boolean(StatByte AND $01);
//        TriggerOccurred := boolean(StatByte AND $02);
//        PowerFailAfterTriggerOccurred := boolean(StatByte AND $08);
//      end;
//      Result := DISStatus;
//    end;
//    if LocTimeOut then
//      Result := 201;
//  end;
//end;

function ReadROMVersion( Box : word; var Version : string ) : byte;
var
  LocTimeOut : boolean;
begin
  with frmDISSysTest do
  begin
    Result := 0;
    fldSend.AsString := '';
    btnSendToDISClick(btnSendToDIS);
    tmrTimeOut.Enabled := TRUE;
    TimeOut := FALSE;
    repeat
      application.processmessages;
    until TriggerProcessed OR TimeOut;
    tmrTimeOut.Enabled := FALSE;
    if TimeOut then
      LocTimeOut := TRUE
    else
    begin
      LocTimeOut := FALSE;
      Version := DataStr;
      Result := DISStatus;
    end;
    if LocTimeOut then
      Result := 201;
  end;
end;

function SetSwitchTriggerUse( Box : word; Trg1Use, Trg2Use : tTrigUse ) : byte;
var
  TrigUseStr : string;
    LocTimeOut : boolean;
  TestTrg1, TestTrg2 : tTrigUse;
  Trg1Char, Trg2Char : char;
begin
  with frmDISSysTest do
  begin
    Result := 0;
    Trg1Char := 'N';
    if Trg1Use = tuUse then
      Trg1Char := 'Y';
    Trg2Char := 'N';
    if Trg2Use = tuUse then
      Trg2Char := 'Y';
    fldSend.AsString := format( 'TRG1 %s,%s', [Trg1Char,Trg2Char]);
    btnSendToDISClick(btnSendToDIS);
    tmrTimeOut.Enabled := TRUE;
    TimeOut := FALSE;
    repeat
      application.processmessages;
    until TriggerProcessed OR TimeOut;
    tmrTimeOut.Enabled := FALSE;
    if TimeOut then
      LocTimeOut := TRUE
    else
    begin
      LocTimeOut := FALSE;
      Result := DISStatus;
    end;
    if LocTimeOut then
      Result := 201;
  end;
end;

function EnableTrigger( Box : word ) : byte;
var
  TrigUseStr : string;
  LocTimeOut : boolean;
begin
  with frmDISSysTest do
  begin
    Result := 0;
    fldSend.AsString := 'TRE';
    btnSendToDISClick(btnSendToDIS);
    tmrTimeOut.Enabled := TRUE;
    TimeOut := FALSE;
    repeat
      application.processmessages;
    until TriggerProcessed OR TimeOut;
    tmrTimeOut.Enabled := FALSE;
    if TimeOut then
      LocTimeOut := TRUE
    else
    begin
      LocTimeOut := FALSE;
      Result := DISStatus;
    end;
    if LocTimeOut then
      Result := 201;
  end;
end;

function StartAcquire( Box : word) : byte;
var
  LocTimeOut : boolean;

begin
  with frmDISSysTest do
  begin
    Result := 0;
    fldSend.AsString := 'STA';
    btnSendToDISClick(btnSendToDIS);
  end;
end;

function SetCascadeTriggerUse( Box : word) : byte;
var
  LocTimeOut : boolean;

begin
  with frmDISSysTest do
  begin
    Result := 0;
    fldSend.AsString := 'TRG2 N';
    btnSendToDISClick(btnSendToDIS);
    tmrTimeOut.Enabled := TRUE;
    TimeOut := FALSE;
    repeat
      application.processmessages;
    until TriggerProcessed OR TimeOut;
    tmrTimeOut.Enabled := FALSE;
    if TimeOut then
      LocTimeOut := TRUE
    else
    begin
      LocTimeOut := FALSE;
      Result := DISStatus;
    end;
    if LocTimeOut then
      Result := 201;
  end;
end;

function SetLevelTriggerUse( Box : word) : byte;
var
  LocTimeOut : boolean;

begin
  with frmDISSysTest do
  begin
    Result := 0;
    fldSend.AsString := 'TRG3 999,100,999,100,999,100';
    btnSendToDISClick(btnSendToDIS);
    tmrTimeOut.Enabled := TRUE;
    TimeOut := FALSE;
    repeat
      application.processmessages;
    until TriggerProcessed OR TimeOut;
    tmrTimeOut.Enabled := FALSE;
    if TimeOut then
      LocTimeOut := TRUE
    else
    begin
      LocTimeOut := FALSE;
      Result := DISStatus;
    end;
    if LocTimeOut then
      Result := 201;
  end;
end;

function TriggerCheck( Box : word) : byte;
var
  LocTimeOut : boolean;

begin
  with frmDISSysTest do
  begin
    Result := 0;
    fldSend.AsString := 'STA1';
    btnSendToDISClick(btnSendToDIS);
    tmrTimeOut.Enabled := TRUE;
    TimeOut := FALSE;
    repeat
      application.processmessages;
    until TriggerProcessed OR TimeOut;
    tmrTimeOut.Enabled := FALSE;
    if TimeOut then
      LocTimeOut := TRUE
    else
    begin
      LocTimeOut := FALSE;
      Result := DISStatus;
    end;
    if LocTimeOut then
      Result := 201;
  end;
end;

function BalanceChannels( Box : word) : byte;
var
  LocTimeOut : boolean;

begin
  with frmDISSysTest do
  begin
    Result := 0;
    fldSend.AsString := 'BAL';
    btnSendToDISClick(btnSendToDIS);
    tmrTimeOut.Enabled := TRUE;
    TimeOut := FALSE;
    repeat
      application.processmessages;
    until TriggerProcessed OR TimeOut;
    tmrTimeOut.Enabled := FALSE;
    if TimeOut then
      LocTimeOut := TRUE
    else
    begin
      LocTimeOut := FALSE;
      Result := DISStatus;
    end;
    if LocTimeOut then
      Result := 201;
  end;
end;

function AbortAcquire( Box : word ) : byte;
var  LocTimeOut : boolean;
begin
  with frmDISSysTest do
  begin
    Result := 0;
    fldSend.AsString := 'STP';
    btnSendToDISClick(btnSendToDIS);
    tmrTimeOut.Enabled := TRUE;
    TimeOut := FALSE;
    repeat
      application.processmessages;
    until TriggerProcessed OR TimeOut;
    tmrTimeOut.Enabled := FALSE;
    if TimeOut then
      LocTimeOut := TRUE
    else
    begin
      LocTimeOut := FALSE;
      Result := DISStatus;
    end;
    if LocTimeOut then
      Result := 201;

  end;
end;


function ClearFlashMemory( Box : word; Channel : word ) : byte;
var LocTimeOut : boolean;
begin
  with frmDISSysTest do
  begin
    Result := 0;
    fldSend.AsString := format( 'CLFL %d',[Channel]);
    btnSendToDISClick(btnSendToDIS);
    delay(500);
    repeat
      fldSend.AsString := format( 'STFL %d,%d',[Channel,Channel]);
      btnSendToDISClick(btnSendToDIS);
      tmrTimeOut.Enabled := FALSE;
      TimeOut := FALSE;
      repeat
        application.processmessages;
      until TriggerProcessed OR TimeOut;
      tmrTimeOut.Enabled := FALSE;
      if TimeOut then
        LocTimeOut := TRUE
      else
      begin
        LocTimeOut := FALSE;
        Result := DISStatus;
      end;
      if LocTimeOut then
      begin
        Result := 201;
        exit;
      end;
    until (Result <> 0) OR (DataStr = '0');
  end;
end;

procedure TfrmDISSysTest.btnTrigSwitchUseClick(Sender: TObject);
//var Trig : tTrig;
//    Box : word;
begin
//  SetSwitchTriggerUse( Box, tuUse, tuUse );
end;

//function GetChannelData( Box : word; Chan      : word;
//                                              StartPos  : integer;
//                                              Count     : integer;
//                                          var Data      : tDISDataBlock ) : byte;
//var  LocTimeOut : boolean;
//begin
//  with frmDISSysTest do
//  begin
//    Result := 0;
//    fldSend.AsString := format('RED %d,1,%d,%d',[Chan,StartPos,Count]);;
//    btnSendToDISClick(btnSendToDIS);
//    tmrTimeOut.Enabled := FALSE;
//    TimeOut := FALSE;
//    repeat
//      application.processmessages;
//    until TriggerProcessed OR TimeOut;
//    tmrTimeOut.Enabled := FALSE;
//    if TimeOut then
//      LocTimeOut := TRUE
//    else
//    begin
//      LocTimeOut := FALSE;
//      Data := DISDataBlock;
//      Result := DISStatus;
//    end;
//    if LocTimeOut then
//      Result := 201;
//  end;
//end;

//-------------------------[SetRealTimeMonitorChans]----------------------------
// Error Codes:
//    0 -- no error
// 1-18 -- Kyowa Status error--check Status byte codes
//  101 -- Winsock Port or Packet not assigned
//  102 -- a channel is out of range
//  103 -- Monitor already open for box.  Must be closed via QuitRealTimeMonitor
//  201 -- TimeOut encountered after command sent
//------------------------------------------------------------------------------
Function SetRealTimeMonitorChans( Box : word;
                                  Chan1, Chan2, Chan3, Chan4 : byte;
                                  DataKind : tMeasuredData ) : byte;
var
  SendString : string;
  res : byte;
  LocTimeOut : boolean;
begin
//  Result := WinsAssigned( Box );
  Result := 0;
  if (Chan1 = 0) OR
     (Chan2 = 0) OR
     (Chan3 = 0) OR
     (Chan4 = 0) then
    Result := 102;
  if MonitorOpen[Box] then
    Result := 103;
  if (Result <> 0) then
    exit;
  with frmDISSysTest do
  begin
    SendString := format( 'MONX %.2d,%.2d,%.2d,%.2d,%.2d', [Chan1,Chan2,Chan3,Chan4,ord(DataKind)+1]);
    fldSend.AsString := SendString;
    btnSendToDISClick(btnSendToDIS);
    tmrTimeOut.Enabled := TRUE;
    TimeOut := FALSE;
    repeat
      application.processmessages;
    until TriggerProcessed OR TimeOut;
    tmrTimeOut.Enabled := FALSE;
    if TimeOut then
      LocTimeOut := TRUE
    else
    begin
      LocTimeOut := FALSE;
      Result := DISStatus;
    end;
    if LocTimeOut then
      Result := 201;
  end;
  if (Result = 0) then
    MonitorOpen[Box] := TRUE;
end;
//-------------------------[ReadRealTimeMonitorData]----------------------------
// Error Codes:
//    0 -- no error
// 1-18 -- Kyowa Status error--check Status byte codes
//  101 -- Winsock Port or Packet not assigned
//  102 -- Monitor not opened for box with call to SetRealTimeMonitorChans
//  201 -- TimeOut encountered after command sent
//------------------------------------------------------------------------------
Function ReadRealTimeMonitorData( Box : word;
                                  var Ch1Data : smallint;
                                  var Ch2Data : smallint;
                                  var Ch3Data : smallint;
                                  var Ch4Data : smallint  ) : byte;
var
  SendString : string;
  i          : byte;
  LocTimeOut : boolean;
begin
//  Result := WinsAssigned( Box );
  Result := 0;
  if NOT(MonitorOpen[Box]) then
    Result := 102;
  if (Result <> 0) then
    exit;
  with frmDISSysTest do
  begin
    fldSend.AsString := 'MST';
    btnSendToDISClick(btnSendToDIS);
    tmrTimeOut.Enabled := TRUE;
    TimeOut := FALSE;
    repeat
      application.processmessages;
    until TriggerProcessed OR TimeOut;
    tmrTimeOut.Enabled := FALSE;
    if TimeOut then
      LocTimeOut := TRUE
    else
    begin
      LocTimeOut := FALSE;
      Result := DISStatus;
      l1.lit := not l1.lit;
    end;
    if LocTimeOut then
      Result := 201;
    if Result <> 0 then
    begin
      Ch1Data := 0;
      Ch2Data := 0;
      Ch3Data := 0;
      Ch4Data := 0;
      exit;
    end;
    Ch1Data := DISDataBlock[0];
    Ch2Data := DISDataBlock[1];
    Ch3Data := DISDataBlock[2];
    Ch4Data := DISDataBlock[3];
  end;
end;

//---------------------------[QuitRealTimeMonitor]------------------------------
// Error Codes:
//    0 -- no error
// 1-18 -- Kyowa Status error--check Status byte codes
//  101 -- Winsock Port or Packet not assigned
//  102 -- Monitor not open for box.  Must be opened via SetRealTimeMonitorChans
//  201 -- TimeOut encountered after command sent
//------------------------------------------------------------------------------
Function QuitRealTimeMonitor( Box : word ) : byte;
var
  SendString : string;
  LocTimeOut : boolean;
begin
//  Result := WinsAssigned( Box );
  Result := 0;
  if NOT(MonitorOpen[Box]) then
    Result := 102;
  if (Result <> 0) then
    exit;
  SendString := 'EXT';
  with frmDISSysTest do
  begin
    fldSend.AsString := SendString;
    btnSendToDISClick(btnSendToDIS);
    tmrTimeOut.Enabled := TRUE;
    TimeOut := FALSE;
    repeat
      application.processmessages;
    until TriggerProcessed OR TimeOut;
    tmrTimeOut.Enabled := FALSE;
    if TimeOut then
      LocTimeOut := TRUE
    else
    begin
      LocTimeOut := FALSE;
      Result := DISStatus;
    end;
    if LocTimeOut then
      Result := 201;
  end;
  if (Result = 0) then
    MonitorOpen[Box] := FALSE;
end;

procedure TfrmDISSysTest.tmrTimeOutTimer(Sender: TObject);
begin
  TimeOut := TRUE;
  (Sender As TTimer).Enabled := FALSE;
end;

procedure TfrmDISSysTest.btnEnableTrigClick(Sender: TObject);
var Box : word;
begin
  EnableTrigger( Box );
end;

procedure TfrmDISSysTest.btnStatusClick(Sender: TObject);
//var Box : word;
//    Status : tStatus;
begin
//  ReadStatus( Box, Status );
end;

procedure TfrmDISSysTest.btnAbortClick(Sender: TObject);
var Box : word;
begin
  AbortAcquire( Box );
end;

procedure TfrmDISSysTest.btnStartAcqClick(Sender: TObject);
var Box : word;
begin
  StartAcquire(Box  );
end;

procedure TfrmDISSysTest.Button3Click(Sender: TObject);
var Box : word;
begin
  TriggerCheck(Box );
end;

procedure TfrmDISSysTest.btnClearClick(Sender: TObject);
var Box : word;
begin
  TriggerCheck( Box );
  AbortAcquire( Box );
end;

procedure TfrmDISSysTest.btnGetChanRangeClick(Sender: TObject);
var Chan : word;
    Range : word;
    Box : word;
begin
  GetChanRange( Box, 1, Range );
end;

procedure TfrmDISSysTest.btnGetAvgCalClick(Sender: TObject);
//var Chan : word;
//    AvgCal : tAvgCal;
//    Box : word;
begin
//  GetChanAvgCal( Box, 1, AvgCal );
end;

procedure TfrmDISSysTest.btnSetLevelUseClick(Sender: TObject);
var
  Box : word;
begin
  SetLevelTriggerUse( Box );
end;

procedure TfrmDISSysTest.btnStartMonClick(Sender: TObject);
var
  Ch1Dat, Ch2Dat, Ch3Dat, Ch4Dat : smallint;
begin
  btnStartMon.Enabled := FALSE;
  SetRealTimeMonitorChans( 1, 1,2,3,33, mdRaw );
  QuitMon := FALSE;
  while NOT(QuitMon) do
  begin
    ReadRealTimeMonitorData( 1, Ch1Dat, Ch2Dat, Ch3Dat, Ch4Dat);
    application.processmessages;
  end;
  QuitRealTimeMonitor( 1 );
  btnStartMon.Enabled := TRUE;
end;

procedure TfrmDISSysTest.btnStopMonitorClick(Sender: TObject);
begin
  QuitMon := TRUE;
end;

procedure TfrmDISSysTest.btnBalanceClick(Sender: TObject);
begin
  BalanceChannels( 1 );
end;

procedure TfrmDISSysTest.btndownloadClick(Sender: TObject);
//var startpos,block : integer;
//   Data : tDISDataBlock;
begin
//  for block := 0 to 255 do
//  begin
//    StartPos := block * AcqBlockSize;
//    GetChannelData( 1, 1, StartPos, AcqBlockSize, Data );
//  end;
end;

procedure TfrmDISSysTest.btnEraseClick(Sender: TObject);
var i : word;
begin
  for i := 1 to 33 do
    ClearFlashMemory(1,i);
end;

procedure TfrmDISSysTest.DisplayStatus;
begin
  fldStatusFlag.AsString := inttostr(Dis3500Drv.ErrorCode);
  fldErrorStr.AsString := Dis3500Drv.ErrorStr;
  fldBytesReceived.AsString := inttostr(Dis3500Drv.BytesReceived);
end;

procedure TfrmDISSysTest.menuROMVerClick(Sender: TObject);
begin
  if Dis3500Drv.GetROMVersion( tempStr ) then
  begin
    DisplayStatus;
    MessageDlg('ROM Version is '+ Trim(tempStr), mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuIPAddressClick(Sender: TObject);
begin
  if Dis3500Drv.GetIPAddress( tempStr ) then
  begin
    DisplayStatus;
    MessageDlg('IP Address is '+ Trim(tempStr), mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuSetIPAddressClick(Sender: TObject);
begin
  if Dis3500Drv.SetIPAddress( fldStringInput.AsString ) then
  begin
    DisplayStatus;
    MessageDlg('Box must be turned off and reset to address '+fldStringInput.AsString, mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.ExitDISSysTest1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmDISSysTest.menuMemChkClick(Sender: TObject);
var  MemHealth : TDisMemHealthArray;
     tempstr : string;
     i : integer;
begin
  if Dis3500Drv.GetAllChannelsMemoryHealth( MemHealth ) then
  begin
    DisplayStatus;
    tempstr := '';
    for i := 1 to 32 do
    begin
      tempstr := tempstr + inttostr(i) + ' ';
      case MemHealth[i] of
        mhGood         : tempstr := tempstr + 'Good';
        mhNotGood      : tempstr := tempstr + 'Not Good';
        mhUndetermined : tempstr := tempstr + 'Undetermined';
        mhNonExisting  : tempstr := tempstr + 'Non Existing';
      end;
      if i <> 32 then
        tempstr := tempstr + ','+#13#10;
    end;
    MessageDlg('Channel Memory Status'+ #13#10 + tempstr
                , mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuSetMemoClick(Sender: TObject);
begin
// below new method never implemented
//  if Dis3500Drv.SetMemo( fldSlotInput.AsInteger, fldNumericInput.AsInteger, fldStringInput.AsString ) then
  if Dis3500Drv.SetMemo( fldNumericInput.AsInteger, fldStringInput.AsString ) then
  begin
    DisplayStatus;
    MessageDlg('Memo Set', mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuGetMemoClick(Sender: TObject);
var tempstr : string;
begin
// below method never implemented by Kyowa
//  if Dis3500Drv.GetMemo( fldSlotInput.AsInteger, fldNumericInput.AsInteger, tempstr ) then
  if Dis3500Drv.GetMemo( fldNumericInput.AsInteger, tempstr ) then
  begin
    DisplayStatus;
    MessageDlg('Slot '+inttostr(fldSlotInput.AsInteger)+ ' Memo '+inttostr(fldNumericInput.AsInteger)+':'+ #13#10 + tempstr
                , mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuSetTriggerModeClick(Sender: TObject);
var
  value : integer;
begin
  if GetChannelVal('Please Choose a Trigger Mode','1 or 2', value ) then
  begin
    if Dis3500Drv.SetTriggerMode( value ) then
    begin
      DisplayStatus;
      MessageDlg('Trigger Mode Set', mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuGetTriggerModeClick(Sender: TObject);
var mode : integer;
begin
  if Dis3500Drv.GetTriggerMode( mode ) then
  begin
    DisplayStatus;
    MessageDlg('Trigger Mode is '+inttostr(mode), mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

function TfrmDISSysTest.GetChannelVal( Caption, Instruct : string; var value : integer ) : boolean;
begin
  result := TRUE;
  DISChan := TDISChannel.Create(Nil);
  DISChan.Caption := Caption;
  DISChan.Instruction := Instruct;
  DISChan.InputType := itChannel;
  if DISChan.Execute then
    value := round(DISChan.AsInteger)
  else
    result := FALSE;
  DISChan.Free;
  DISChan := Nil;
end;

function TfrmDISSysTest.GetSensorVal( Caption, Instruct : string; var value : integer ) : boolean;
begin
  result := TRUE;
  DISChan := TDISChannel.Create(Nil);
  DISChan.Caption := Caption;
  DISChan.Instruction := Instruct;
  DISChan.InputType := itSensor;
  if DISChan.Execute then
    value := round(DISChan.AsInteger)
  else
    result := FALSE;
  DISChan.Free;
  DISChan := Nil;
end;

function TfrmDISSysTest.GetNumericVal( Caption, Instruct : string; var value : integer ) : boolean;
begin
  result := TRUE;
  DISChan := TDISChannel.Create(Nil);
  DISChan.Caption := Caption;
  DISChan.Instruction := Instruct;
  DISChan.InputType := itNumeric;
  if DISChan.Execute then
    value := round(DISChan.AsInteger)
  else
    result := FALSE;
  DISChan.Free;
  DISChan := Nil;
end;

function TfrmDISSysTest.GetFloatVal( Caption, Instruct : string; var value : double ) : boolean;
begin
  result := TRUE;
  DISChan := TDISChannel.Create(Nil);
  DISChan.Caption := Caption;
  DISChan.Instruction := Instruct;
  DISChan.InputType := itFloat;
  if DISChan.Execute then
    value := DISChan.AsFloat
  else
    result := FALSE;
  DISChan.Free;
  DISChan := Nil;
end;

function TfrmDISSysTest.GetMultiVal( Caption, Instruct : string; var value : TMultiChan ) : boolean;
begin
  result := TRUE;
  DISChan := TDISChannel.Create(Nil);
  DISChan.Caption := Caption;
  DISChan.Instruction := Instruct;
  DISChan.InputType := itMultiChan;
  if DISChan.Execute then
    value := DISChan.AsMultiChan
  else
    result := FALSE;
  DISChan.Free;
  DISChan := Nil;
end;

procedure TfrmDISSysTest.btnLPFFilterClick(Sender: TObject);
var chanRes : integer;
    chanUse : tUse;
begin
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
  if (Sender As TMenuItem).Caption = 'On' then
    chanUse := uOn
  else
    chanUse := uOff;
  if Dis3500Drv.SetLowPassFilterUse( chanRes, chanUse ) then
  begin
    DisplayStatus;
    MessageDlg('Low Pass Filter turned '+(Sender As TMenuItem).Caption+ ' for channel '+inttostr(chanRes)+'.', mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
DisplayStatus;
end;

procedure TfrmDISSysTest.menuMod4Click(Sender: TObject);
var
  ModStat : TModuleStatus;
  tempstr : string;
  slot : integer;
  code : integer;
begin
  val((Sender as TMenuItem).Caption,slot,code);
  if Dis3500Drv.GetModuleInformation( slot, ModStat ) then
  begin
    DisplayStatus;
    case ModStat of
      msUnmounted : tempstr := 'Unmounted';
      msSigCond   : tempstr := 'Signal Conditioner';
      msDigIn     : tempstr := 'Digital Input';
      msAirbagTimer : tempstr := 'AirbagTimer';
    end;
    MessageDlg('Slot '+(Sender as TMenuItem).Caption+' is '+tempstr+'.', mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuModChkClick(Sender: TObject);
var
  ModStat : TModuleStatus;
  tempstr : string;
  slot : integer;
  code : integer;
begin
  if GetChannelVal('Please choose slot','1 through number of slots',slot) then
  begin
  if Dis3500Drv.GetModuleInformation( slot, ModStat ) then
  begin
    DisplayStatus;
    case ModStat of
      msUnmounted : tempstr := 'Unmounted';
      msSigCond   : tempstr := 'Signal Conditioner';
      msDigIn     : tempstr := 'Digital Input';
      msAirbagTimer : tempstr := 'AirbagTimer';
    end;
    MessageDlg('Slot '+inttostr(slot)+' is '+tempstr+'.', mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;
end;

procedure TfrmDISSysTest.SetSamplingRate1Click(Sender: TObject);
var samp : integer;
begin
  if GetNumericVal('Please choose sampling rate for box','100,200,500,1000,2000,5000,10000,20000,50000,100000',samp) then
  begin
    if Dis3500Drv.SetSampRate( samp ) then
    begin
      DisplayStatus;
      MessageDlg('Sample Rate of '+inttostr(samp)+' was set.', mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;
end;

procedure TfrmDISSysTest.GetSamplingRate1Click(Sender: TObject);
var rate : integer;
begin
  if Dis3500Drv.GetSampRate( rate ) then
  begin
    DisplayStatus;
    MessageDlg('Sample Rate is '+inttostr(rate), mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.SetPreTriggerSamples1Click(Sender: TObject);
var value : integer;
begin
  if GetNumericVal('Please choose number of pre-trigger data points','Number divisible by 512',value) then
  begin
    if Dis3500Drv.SetNumPreData( value ) then
    begin
      DisplayStatus;
      MessageDlg('Pre-trigger points of '+inttostr(value)+' was set.', mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;

end;

procedure TfrmDISSysTest.GetPreTriggerSamples1Click(Sender: TObject);
var value : integer;
begin
  if Dis3500Drv.GetNumPreData( value ) then
  begin
    DisplayStatus;
    MessageDlg('Number of pre-trigger samples are set to '+inttostr(value), mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.menuEStopClick(Sender: TObject);
begin
  if Dis3500Drv.StopSquibFire then
  begin
    DisplayStatus;
    MessageDlg('Squib Firing Stopped.', mtInformation, [mbOK], 0 );
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuSwTrOn1Click(Sender: TObject);
var
  bRes : boolean;
begin
  if (Sender As TMenuItem).Checked then
    bRes := Dis3500Drv.SetTriggerSW1( tuDoNotUse )
  else
    bRes := Dis3500Drv.SetTriggerSW1( tuUse );
  if bRes then
  begin
    (Sender As TMenuItem).Checked := NOT (Sender As TMenuItem).Checked;
    DisplayStatus;
    if (Sender As TMenuItem).Checked then
      MessageDlg('Trigger SW1 will be used when enabled', mtInformation, [mbOK], 0)
    else
      MessageDlg('Trigger SW1 will not be used', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuSwTrStat1Click(Sender: TObject);
var Use : ttrigUse;
begin
  if Dis3500Drv.GetTriggerSW1( Use ) then
  begin
    DisplayStatus;
    if (Use = tuUse) then
      MessageDlg('Trigger SW1 will be used when enabled', mtInformation, [mbOK], 0)
    else
      MessageDlg('Trigger SW1 will not be used', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuSwTrOn2Click(Sender: TObject);
var
  bRes : boolean;
begin
  if (Sender As TMenuItem).Checked then
    bRes := Dis3500Drv.SetTriggerSW2( tuDoNotUse )
  else
    bRes := Dis3500Drv.SetTriggerSW2( tuUse );
  if bRes then
  begin
    (Sender As TMenuItem).Checked := NOT (Sender As TMenuItem).Checked;
    DisplayStatus;
    if (Sender As TMenuItem).Checked then
      MessageDlg('Trigger SW2 will be used when enabled', mtInformation, [mbOK], 0)
    else
      MessageDlg('Trigger SW2 will not be used', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.menuSwTrStat2Click(Sender: TObject);
var Use : ttrigUse;
begin
  if Dis3500Drv.GetTriggerSW2( Use ) then
  begin
    DisplayStatus;
    if (Use = tuUse) then
      MessageDlg('Trigger SW2 will be used when enabled', mtInformation, [mbOK], 0)
    else
      MessageDlg('Trigger SW2 will not be used', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.menuCaTrOnClick(Sender: TObject);
var
  bRes : boolean;
begin
  if (Sender As TMenuItem).Checked then
    bRes := Dis3500Drv.SetTriggerCascade( tuDoNotUse )
  else
    bRes := Dis3500Drv.SetTriggerCascade( tuUse );
  if bRes then
  begin
    (Sender As TMenuItem).Checked := NOT (Sender As TMenuItem).Checked;
    DisplayStatus;
    if (Sender As TMenuItem).Checked then
      MessageDlg('Trigger CASCADE will be used when enabled', mtInformation, [mbOK], 0)
    else
      MessageDlg('Trigger CASCADE will not be used', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.menuCaTrStatClick(Sender: TObject);
var Use : ttrigUse;
begin
  if Dis3500Drv.GetTriggerCascade( Use ) then
  begin
    DisplayStatus;
    if (Use = tuUse) then
      MessageDlg('Trigger CASCADE will be used when enabled', mtInformation, [mbOK], 0)
    else
      MessageDlg('Trigger CASCADE will not be used', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.menuLvTrOn1Click(Sender: TObject);
var value : integer;
    chanRes : integer;
    bRes : boolean;
begin
  chanRes := 0;
  value := 0;
  if (Sender As TMenuItem).Checked then
    bRes := Dis3500Drv.SetTriggerLevel1( tuDoNotUse, chanRes, value )
  else
  begin
    if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
    begin
      if GetNumericVal('Please choose level of trigger in AD counts','0-32767',value) then
        bRes := Dis3500Drv.SetTriggerLevel1( tuUse, chanRes, value )
      else
        exit;
    end
    else
      exit;
  end;
  if bRes then
  begin
    (Sender As TMenuItem).Checked := NOT (Sender As TMenuItem).Checked;
    DisplayStatus;
    if (Sender As TMenuItem).Checked then
      MessageDlg('Trigger Level1 will be used when enabled', mtInformation, [mbOK], 0)
    else
      MessageDlg('Trigger Level1 will not be used', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuLvTrOn2Click(Sender: TObject);
var value : integer;
    chanRes : integer;
    bRes : boolean;
begin
  chanRes := 0;
  value := 0;
  if (Sender As TMenuItem).Checked then
    bRes := Dis3500Drv.SetTriggerLevel2( tuDoNotUse, chanRes, value )
  else
  begin
    if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
    begin
      if GetNumericVal('Please choose level of trigger in AD counts','0-32767',value) then
        bRes := Dis3500Drv.SetTriggerLevel2( tuUse, chanRes, value )
      else
        exit;
    end
    else
      exit;
  end;
  if bRes then
  begin
    (Sender As TMenuItem).Checked := NOT (Sender As TMenuItem).Checked;
    DisplayStatus;
    if (Sender As TMenuItem).Checked then
      MessageDlg('Trigger Level2 will be used when enabled', mtInformation, [mbOK], 0)
    else
      MessageDlg('Trigger Level2 will not be used', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.menuLvTrOn3Click(Sender: TObject);
var value : integer;
    chanRes : integer;
    bRes : boolean;
begin
  chanRes := 0;
  value := 0;
  if (Sender As TMenuItem).Checked then
    bRes := Dis3500Drv.SetTriggerLevel3( tuDoNotUse, chanRes, value )
  else
  begin
    if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
    begin
      if GetNumericVal('Please choose level of trigger in AD counts','0-32767',value) then
        bRes := Dis3500Drv.SetTriggerLevel3( tuUse, chanRes, value )
      else
        exit;
    end
    else
      exit;
  end;
  if bRes then
  begin
    (Sender As TMenuItem).Checked := NOT (Sender As TMenuItem).Checked;
    DisplayStatus;
    if (Sender As TMenuItem).Checked then
      MessageDlg('Trigger Level3 will be used when enabled', mtInformation, [mbOK], 0)
    else
      MessageDlg('Trigger Level3 will not be used', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.menuLvTrStat1Click(Sender: TObject);
var Use : ttrigUse;
    chan: integer;
    Level : smallint;
begin
  if Dis3500Drv.GetTriggerLevel1( Use, chan, Level ) then
  begin
    DisplayStatus;
    if (Use = tuUse) then
      MessageDlg('Trigger Level 1 will be used when enabled'+#13#10+
                 'Settings: Channel '+inttostr(chan)+', AD Level '+inttostr(Level)+#13#10+
                 '(AD Level may be slightly lower than value set)', mtInformation, [mbOK], 0)
    else
      MessageDlg('Trigger Level 1 will not be used', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuLvTrStat2Click(Sender: TObject);
var Use : ttrigUse;
    chan: integer;
    Level : smallint;
begin
  if Dis3500Drv.GetTriggerLevel2( Use, chan, Level ) then
  begin
    DisplayStatus;
    if (Use = tuUse) then
      MessageDlg('Trigger Level 2 will be used when enabled'+#13#10+
                 'Settings: Channel '+inttostr(chan)+', AD Level '+inttostr(Level)+#13#10+
                 '(AD Level may be slightly lower than value set)', mtInformation, [mbOK], 0)
    else
      MessageDlg('Trigger Level 2 will not be used', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.menuLvTrStat3Click(Sender: TObject);
var Use : ttrigUse;
    chan: integer;
    Level : smallint;
begin
  if Dis3500Drv.GetTriggerLevel3( Use, chan, Level ) then
  begin
    DisplayStatus;
    if (Use = tuUse) then
      MessageDlg('Trigger Level 3 will be used when enabled'+#13#10+
                 'Settings: Channel '+inttostr(chan)+', AD Level '+inttostr(Level)+#13#10+
                 '(AD Level may be slightly lower than value set)', mtInformation, [mbOK], 0)
    else
      MessageDlg('Trigger Level 3 will not be used', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.EnableTrigger2Click(Sender: TObject);
begin
  if Dis3500Drv.SetTriggerToEnable then
  begin
    DisplayStatus;
    MessageDlg('Trigger has been ENABLED.', mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.SetGain1Click(Sender: TObject);
var value : double;
    chanRes : integer;
    bRes : boolean;
begin
  chanRes := 0;
  value := 0;
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
    if GetFloatVal('Please choose gain','0.1,0.2,...1,2,...100,200,300,2000',value) then
      bRes := Dis3500Drv.SetChannelGain( chanRes, value )
    else
      exit;
  end
  else
    exit;
  if bRes then
  begin
    DisplayStatus;
    MessageDlg('Gain was Set for channel.', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.GetGain1Click(Sender: TObject);
var chanRes : integer;
    Gain : single;
    MsgStr : string;
begin
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
    if Dis3500Drv.GetChannelGain( chanRes, Gain ) then
    begin
      DisplayStatus;
      MsgStr := format('The Gain on channel %d is %5.1f',[chanRes,Gain]);
      MessageDlg(MsgStr, mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;
end;

procedure TfrmDISSysTest.SetSensorType1Click(Sender: TObject);
var value : integer;
    chanRes : integer;
    bRes : boolean;
begin
  chanRes := 0;
  value := 0;
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
    if GetSensorVal('Please choose a Sensor Type','',value) then
      bRes := Dis3500Drv.SetChannelSensorTypeAndAutoBalanceUse( chanRes, tSensorType(value) )
    else
      exit;
  end
  else
    exit;
  if bRes then
  begin
    DisplayStatus;
    MessageDlg('Sensor Type was Set for channel.', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.GetSensorType1Click(Sender: TObject);
var chanRes : integer;
    Gain : double;
    SensType : tSensorType;
    MsgStr, SensStr : string;
begin
  if GetChannelVal('Please Choose a Channel','', chanRes ) then
  begin
    if Dis3500Drv.GetChannelSensorTypeAndAutoBalanceUse( chanRes, SensType ) then
    begin
      case SensType of
        stStrainFB_AB : SensStr := 'Full Bridge Strain Gage with Autobalance';
        stStrainHB_AB : SensStr := 'Half Bridge Strain Gage with Autobalance';
        stVoltage_AB : SensStr := 'Voltage with Autobalance';
        stStrainFB : SensStr := 'Full Bridge Strain Gage WITHOUT Autobalance';
        stStrainHB : SensStr := 'Half Bridge Strain Gage WITHOUT Autobalance';
        stVoltage: SensStr := 'Voltage WITHOUT Autobalance';
      end;
      DisplayStatus;
      MsgStr := format('The Sensor Type on channel %d is ',[chanRes]) + SensStr + '.';
      MessageDlg(MsgStr, mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;
end;

procedure TfrmDISSysTest.ClearMemory1Click(Sender: TObject);
var chanRes : integer;
begin
  chanRes := 0;
  if NOT (GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes )) then
    exit;
  if Dis3500Drv.ClearChannelMemory( chanRes ) then
  begin
    DisplayStatus;
    MessageDlg('Channel Memory '+ inttostr(chanRes) + ' cleared.', mtInformation, [mbOK], 0 );
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.Stop2Click(Sender: TObject);
var
  chanRes : TMultiChan;
begin
    if Dis3500Drv.StopRealTimeMonitor then
    begin
      DisplayStatus;
      AutoMonitor := FALSE;
      MessageDlg('Monitor Stopped.', mtInformation, [mbOK], 0);
      Graph1.Visible := false;
      PointCount[1] := 0;
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.SetupChansStart1Click(Sender: TObject);
var
  ChanRes : TMultiChan;
  DlgResult : word;
begin
  if GetMultiVal('Please Choose up to 4 Channels','any channel mounted in the box', chanRes ) then
  begin
    if Dis3500Drv.SetRealTimeMonitorChans( chanRes[1], chanRes[2], chanRes[3], chanRes[4], mdRaw ) then
    begin
      DisplayStatus;
      Graph1.Visible := true;
      DlgResult := MessageDlg('Monitor Started.  Autorun?', mtInformation, [mbYes, mbNo], 0);
      if DlgResult = mrYes then
      begin
        AutoMonitor := TRUE;
        label16.tag := 0;
        tmrMonitor.Enabled := TRUE;
        Sum := 0;
        Sum2 := 0;
        Sum3 := 0;
        Sum4 := 0;
        AvgCount := 0;
        if not GraphCleared[1] then
        begin
          GraphCleared[1] := true;
          graph1.XData[0,-1] := 0;
          graph1.YData[0,-1] := 0;
          graph1.PEactions := sgReinitAndReset;
        end;
      end;
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;

end;

procedure TfrmDISSysTest.ReadChanData1Click(Sender: TObject);
var
  ch1Data,
  ch2Data,
  ch3Data,
  ch4Data : smallint;
    New_Y,
    New_X    : single;
begin
    if Dis3500Drv.GetRealTimeMonitorData(ch1Data, ch2Data, ch3Data, ch4Data) then
    begin
      DisplayStatus;
      MessageDlg(format('Channel Data Back: %d, %d, %d, %d',[ch1Data, ch2Data, ch3Data, ch4Data]) , mtInformation, [mbOK], 0);
        GraphCleared[1] := false;
        inc(PointCount[1]);
//        CNFChanNum := cnftocfg1.BoxChannelNum[strtoint(cbBoxNumber.Text),ChanNum];
//        if CNFChanNum <> 0 then
//        begin
//          graph.YAxisLabel := cnftocfg1.units[cnfchannum];
//        end
//        else
          New_Y := ch1Data;
        New_X := PointCount[1];
        if New_X > 0 then
        begin
          PEvset(graph1.hObject,PEP_faAPPENDYDATA, @New_Y, 1);
          PEvset(graph1.hObject,PEP_faAPPENDXDATA, @New_X, 1);
          graph1.PEnarg1 := 0;
          graph1.PEnarg2 := 0;
          graph1.PEactions := sgReinitAndReset;
//          l1.lit := not l1.lit;
        end;
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.Balance1Click(Sender: TObject);
begin
  if Dis3500Drv.StartBalance then
  begin
    DisplayStatus;
    MessageDlg('Auto-Balance Started.', mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.menuGetDataClick(Sender: TObject);
var Data : TMemoryStream; //TDisDataBlock;
   chan,
   start,
   count, i,j : integer;
   Packets : integer;//byte;
   tf : textfile;
   filename : string;
   DataPoint : smallint;
begin
  chan := 9;
  start := fldStartPt.AsInteger;
  count := fldDlPts.AsInteger;
  pbGetData.Max := Count;
  pbGetData.Position := 0;
//  for j := 1 to 100 do
 // begin
    if Dis3500Drv.GetChannelData( chan, start, count, Data, Packets ) then
    begin
      DisplayStatus;
      if assigned(Data) then
      begin
        Data.Position := 0;
        filename := format('%sdataset.csv',[progpath]);
        assignfile(tf, filename);
//        if fileexists(filename) then
//          append(tf)
//        else
          rewrite(tf);
//        for i := 0 to (count-1) do
//          writeln(tf, Data[i]);
        while Data.Position < Data.Size do
        begin
          Data.Read(DataPoint,sizeof(DataPoint));
          writeln(tf, DataPoint);
        end;
        closefile(tf);
      end;
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
      delay(10);
    inc(start,count);
//  end;
  MessageDlg('Download Complete', mtInformation, [mbOK], 0);

  DisplayStatus;
  if assigned(Data) then
  begin
    Data.Clear;
    Data.free;
  end;
  Data := nil;
end;

procedure TfrmDISSysTest.btnAirbagTimerClick(Sender: TObject);
var
  chanRes : integer;
  chanUse : tUse;
begin
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
  if (Sender As TMenuItem).Caption = 'On' then
    chanUse := uOn
  else
    chanUse := uOff;
  if Dis3500Drv.SetSquibUse( chanRes, chanUse ) then
  begin
    DisplayStatus;
    MessageDlg('Airbag Timer turned '+(Sender As TMenuItem).Caption+ ' for channel '+inttostr(chanRes)+'.', mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
DisplayStatus;

end;

procedure TfrmDISSysTest.btnATStatusClick(Sender: TObject);
var chanRes : integer;
    ChanUse : tUse;
    MsgStr : string;
begin
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
    if Dis3500Drv.GetSquibUse( chanRes, ChanUse ) then
    begin
      DisplayStatus;
      case ChanUse of
        uOn  : tempstr := 'On';
        uOff : tempstr := 'Off';
      end;
      MsgStr := format('The Airbag Timer on channel %d is %s',[chanRes,tempstr]);
      MessageDlg(MsgStr, mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;

end;

procedure TfrmDISSysTest.SetLevel1Click(Sender: TObject);
var value : double;
    chanRes : integer;
    bRes : boolean;
begin
  chanRes := 0;
  value := 0;
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
    if GetFloatVal('Please choose a current level in Amps','0.1,0.2,...5.0',value) then
      bRes := Dis3500Drv.SetSquibAmplitude( chanRes, value )
    else
      exit;
  end
  else
    exit;
  if bRes then
  begin
    DisplayStatus;
    MessageDlg('Squib Current was Set for channel.', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.Status3Click(Sender: TObject);
var chanRes : integer;
    Current : single;
    MsgStr : string;
begin
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
    if Dis3500Drv.GetSquibAmplitudeSetting( chanRes, Current ) then
    begin
      DisplayStatus;
      MsgStr := format('The Squib Current Setting on channel %d is %5.1f',[chanRes,Current]);
      MessageDlg(MsgStr, mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;

end;

procedure TfrmDISSysTest.SetDelay1Click(Sender: TObject);
var value : double;
    chanRes : integer;
    bRes : boolean;
begin
  chanRes := 0;
  value := 0;
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
    if GetFloatVal('Please choose a delay time in seconds','0.0001,0.0002,...99.000',value) then
      bRes := Dis3500Drv.SetSquibDelay( chanRes, value )
    else
      exit;
  end
  else
    exit;
  if bRes then
  begin
    DisplayStatus;
    MessageDlg('Squib Current was Set for channel.', mtInformation, [mbOK], 0)
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.Status4Click(Sender: TObject);
var chanRes : integer;
    Seconds : double;
    MsgStr : string;
begin
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
    if Dis3500Drv.GetSquibDelaySetting( chanRes, Seconds ) then
    begin
      DisplayStatus;
      MsgStr := format('The Squib Delay Setting on channel %d is %6.1f',[chanRes,Seconds]);
      MessageDlg(MsgStr, mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;

end;

procedure TfrmDISSysTest.GainCheck1Click(Sender: TObject);
var chanRes : integer;
    Deviation : single;
begin
  chanRes := 0;
  if NOT (GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes )) then
    exit;
  if Dis3500Drv.CheckGain( chanRes, Deviation ) then
  begin
    DisplayStatus;
    MessageDlg(format('Channel %d deviation = %4.2f%%', [chanRes, Deviation]), mtInformation, [mbOK], 0 );
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.ExcitationCheck1Click(Sender: TObject);
var chanRes : integer;
    Excitation : single;
begin
  chanRes := 0;
  if NOT (GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes )) then
    exit;
  if Dis3500Drv.CheckExcitation( chanRes, Excitation ) then
  begin
    DisplayStatus;
    MessageDlg(format('Channel %d excitation = %4.2fV', [chanRes, Excitation]), mtInformation, [mbOK], 0 );
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.Start3Click(Sender: TObject);
var DlgResult : word;
begin
  if NOT( Dis3500Drv.SetTriggerToEnable ) then
  begin
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
    exit;
  end;
  DisplayStatus;

  if Dis3500Drv.StartTriggerCheck then
  begin
    DisplayStatus;
    DlgResult := MessageDlg('Trigger Enabled and Checking Started.  Autorun?', mtInformation, [mbYes, mbNo], 0);
    if DlgResult = mrYes then
    begin
      TrigCount := 0;
      AutoTriggerCheck := TRUE;
      tmrTriggerCheck.Enabled := TRUE;
      pnlTrigStat.Visible := TRUE;
    end;
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.Abort2Click(Sender: TObject);
begin
  if Dis3500Drv.StopTriggerCheck then
  begin
    DisplayStatus;
    MessageDlg('Trigger Check Stopped.', mtInformation, [mbOK], 0 );
    pnlTrigStat.Visible := FALSE;
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.GetTriggerSource1Click(Sender: TObject);
var Source : ttriggers;
begin
  if Dis3500Drv.GetTriggerSource( Source ) then
  begin
    DisplayStatus;
    if (Source = trNone) then
      MessageDlg('Trigger Source was None (Reset).', mtInformation, [mbOK], 0)
    else if (Source = trSw1) then
      MessageDlg('Trigger Source was SW1.', mtInformation, [mbOK], 0)
    else if (Source = trSw2) then
      MessageDlg('Trigger Source was SW2.', mtInformation, [mbOK], 0)
    else if (Source = trCascade) then
      MessageDlg('Trigger Source was CASCADE.', mtInformation, [mbOK], 0)
    else if (Source = trLevel1) then
      MessageDlg('Trigger Source was LEVEL1.', mtInformation, [mbOK], 0)
    else if (Source = trLevel2) then
      MessageDlg('Trigger Source was LEVEL2.', mtInformation, [mbOK], 0)
    else if (Source = trLevel3) then
      MessageDlg('Trigger Source was LEVEL3.', mtInformation, [mbOK], 0)
    else
      MessageDlg('Invalid return from Trigger Source function.' , mtError, [mbOK], 0)   ;
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.Stop1Click(Sender: TObject);
begin
  if Dis3500Drv.StopMeasAcquire then
  begin
    DisplayStatus;
    MessageDlg('Measurement Acquisition Stopped.', mtInformation, [mbOK], 0 );
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.Start1Click(Sender: TObject);
begin
  if Dis3500Drv.StartMeasAcquire then
  begin
    DisplayStatus;
    MessageDlg('Measurement Acquisition Started--Lock Pin should be removed if firing Squibs.', mtInformation, [mbOK], 0 );
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.DACReferenceCheck1Click(Sender: TObject);
var chanRes : integer;
    RefInput : single;
begin
  chanRes := 0;
  if NOT (GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes )) then
    exit;
  if Dis3500Drv.CheckReferenceInput( chanRes, RefInput ) then
  begin
    DisplayStatus;
    MessageDlg(format('Channel %d Reference Input = %4.2fV', [chanRes, RefInput]), mtInformation, [mbOK], 0 );
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;


end;

procedure TfrmDISSysTest.Start2Click(Sender: TObject);
var chanRes : integer;
    Deviation : single;
begin
  chanRes := 0;
  if NOT (GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes )) then
    exit;
  if Dis3500Drv.CheckShuntEmulation( chanRes, Deviation ) then
  begin
    DisplayStatus;
    MessageDlg(format('Channel %d deviation = %4.2f%%', [chanRes, Deviation]), mtInformation, [mbOK], 0 );
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.Abort1Click(Sender: TObject);
begin
  Dis3500Drv.InterruptShuntEmu := TRUE;
end;

procedure TfrmDISSysTest.Status1Click(Sender: TObject);
var Occurred : boolean;
    MsgStr : string;
begin
  if Dis3500Drv.GetTriggerStatus( Occurred ) then
  begin
    DisplayStatus;
    case Occurred of
      TRUE  : tempstr := 'occurred';
      FALSE : tempstr := 'did not occur';
    end;

    MessageDlg('The trigger '+tempstr+'.', mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.Status2Click(Sender: TObject);
var Status : tMeasStatus;
    MsgStr : string;
begin
  tempstr := 'Acquire Status: ';
  if Dis3500Drv.GetMeasAcquireStatus( Status ) then
  begin
    DisplayStatus;
    if Status.Measuring then
      tempstr := tempstr + 'MEASURING ';
    if Status.TriggerOccurred then
      tempstr := tempstr + 'TRIGGERED ';
    if Status.PwrFailAfterTrigger then
      tempstr := tempstr + 'POWER FAIL ';
    if Status.SW2TriggerOccurred then
      tempstr := tempstr + 'SW2 TRIG';

    MessageDlg(tempstr, mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.FormShow(Sender: TObject);
begin
    with Graph1 do
    begin
      PrepareImages := true;
      SubSets := 1;
      Points := 100;
      SubSetLineTypes[0] := PELT_MEDIUMSOLID;
      SubsetColors[0] := clLime;
      AutoScaleData := false;
//      ManualScaleControlY := sgAutoScale;
//      ForceRightYAxis := true;
      XData[0,-1] := 0;
      YData[0,-1] := 0;
      NoRandomPointsToExport := true;
      FocalRect := True;
      AllowBar := false;
      AllowPopup := true;
      DeskColor := rgb(192,192,192);
      MainTitle := '';
      SubTitle := '';
      XaxisLabel := '';
      YAxisLabel := 'A/D';
      PEActions := sgReinitAndReset;
    end;
    AutoMonitor := FALSE;
end;

procedure TfrmDISSysTest.Button2Click(Sender: TObject);
begin
    if not GraphCleared[1] then
    begin
      GraphCleared[1] := true;
      graph1.XData[0,-1] := 0;
      graph1.YData[0,-1] := 0;
      graph1.PEactions := sgReinitAndReset;
    end;
end;

procedure TfrmDISSysTest.tmrMonitorTimer(Sender: TObject);
var
    New_Y,
    New_X    : single;
  ch1Data,
  ch2Data,
  ch3Data,
  ch4Data : smallint;
  count : integer;
begin
  tmrMonitor.Enabled := FALSE;
  if NOT AutoMonitor then
    exit;
    if Dis3500Drv.GetRealTimeMonitorData(ch1Data, ch2Data, ch3Data, ch4Data) then
    begin
      DisplayStatus;
      count := label16.tag;
      inc(count);
      label16.tag := count;
      label16.caption := format('%d',[count]);
      if (AvgCount = 20) then
      begin
        lblADval.Caption := inttostr(round(Sum / 20));
        lblADval2.Caption := inttostr(round(Sum2 / 20));
        lblADval3.Caption := inttostr(round(Sum3 / 20));
        lblADval4.Caption := inttostr(round(Sum4 / 20));
        AvgCount := 0;
        Sum := 0;
        Sum2 := 0;
        Sum3 := 0;
        Sum4 := 0;
      end
      else
      begin
        inc(AvgCount);
        Sum := Sum + ch1Data;
        Sum2 := Sum2 + ch2Data;
        Sum3 := Sum3 + ch3Data;
        Sum4 := Sum4 + ch4Data;
      end;

        GraphCleared[1] := false;
        inc(PointCount[1]);
//        CNFChanNum := cnftocfg1.BoxChannelNum[strtoint(cbBoxNumber.Text),ChanNum];
//        if CNFChanNum <> 0 then
//        begin
//          graph.YAxisLabel := cnftocfg1.units[cnfchannum];
//        end
//        else
          New_Y := (ch1data);
        New_X := PointCount[1];
        if New_X > 0 then
        begin
          PEvset(graph1.hObject,PEP_faAPPENDYDATA, @New_Y, 1);
          PEvset(graph1.hObject,PEP_faAPPENDXDATA, @New_X, 1);
          graph1.PEnarg1 := 0;
          graph1.PEnarg2 := 0;
          graph1.PEactions := sgReinitAndReset;
//          l1.lit := not l1.lit;
        end;
      end;
  tmrMonitor.Enabled := TRUE;
end;

procedure TfrmDISSysTest.tmrTriggerCheckTimer(Sender: TObject);
var Occurred : boolean;
begin
  tmrTriggerCheck.Enabled := FALSE;
  if NOT AutoTriggerCheck then
    exit;
  if Dis3500Drv.GetTriggerStatus( Occurred ) then
  begin
    DisplayStatus;
    if Occurred then
    begin
      ledTriggered.lit := TRUE;
      exit;
    end
    else
      ledTriggered.lit := FALSE;
  end
  else{ if (Dis3500Drv.ErrorCode <> 20) AND (Dis3500Drv.ErrorCode <> 21) then  }
  begin
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
    AutoTriggerCheck := FALSE;
    DisplayStatus;
    exit;
  end;
  DisplayStatus;
  inc(TrigCount);
  fldTrgCtr.AsInteger := TrigCount;
  tmrTriggerCheck.Enabled := TRUE;
end;

procedure TfrmDISSysTest.ChargeStatus1Click(Sender: TObject);
var chanRes : integer;
    ChargeStatus : tChargeStatus;
    MsgStr  : string;
begin
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
    if Dis3500Drv.GetChargeStatus( chanRes, ChargeStatus ) then
    begin
      DisplayStatus;
      case ChargeStatus of
        csCharged             : tempstr := 'Charged';
        csChargeIncomplete    : tempstr := 'Charge Incomplete';
        csMeasurementStarted : tempstr := 'Cannot be determined--Measurement has started';
      end;
      MsgStr := format('The Airbag Timer on channel %d is %s',[chanRes,tempstr]);
      MessageDlg(MsgStr, mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;
end;

procedure TfrmDISSysTest.SafetyLockStatus1Click(Sender: TObject);
var chanRes : integer;
    LockPinStatus : tLockPinStatus;
    MsgStr  : string;
begin
  if Dis3500Drv.GetLockPinStatus( LockPinStatus ) then
  begin
    DisplayStatus;
    case LockPinStatus of
      lsEngagedSafe       : tempstr := 'Engaged/Safe System';
      lsNotEngagedNotSafe : tempstr := 'Not Engaged/Not Safe System ';
    end;
    MsgStr := format('The Lock Plug is in the %s state.',[tempstr]);
    MessageDlg(MsgStr, mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.menuInhibitSquibFireClick(Sender: TObject);
var bRes : boolean;
begin
  bRes := Dis3500Drv.SetInhibitSquibState( uOn );
  if bRes then
  begin
    (Sender As TMenuItem).Checked := TRUE;
    DisplayStatus;
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.TriggerStatus1Click(Sender: TObject);
var bRes : boolean;
begin
  bRes := Dis3500Drv.SetInhibitSquibState( uOff );
  if bRes then
  begin
    menuInhibitSquibFire.Checked := FALSE;
    DisplayStatus;
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.Status5Click(Sender: TObject);
var chanRes : integer;
    Resist : single;
    MsgStr : string;
begin
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
    if Dis3500Drv.GetSquibResistance( chanRes, Resist ) then
    begin
      DisplayStatus;
      MsgStr := format('The Squib Resistance on channel %d is %5.1f',[chanRes,Resist]);
      MessageDlg(MsgStr, mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;
end;

procedure TfrmDISSysTest.Start4Click(Sender: TObject);
var chanRes : integer;
    Resist : single;
    MsgStr : string;
begin
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
    if Dis3500Drv.StartSquibResistanceCheck( chanRes ) then
    begin
      DisplayStatus;
      MsgStr := format('The Squib Resistance Check on channel %d was started',[chanRes]);
      MessageDlg(MsgStr, mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;

end;

procedure TfrmDISSysTest.GetTriggerPoint1Click(Sender: TObject);
var value : integer;
begin
  if Dis3500Drv.GetTriggerMode2PointOfTrigger( value ) then
  begin
    DisplayStatus;
    MessageDlg('The Mode 2 Point of Trigger is '+inttostr(value), mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;
end;

procedure TfrmDISSysTest.GetSquibFireResult1Click(Sender: TObject);
var chanRes : integer;
    SquibFireResult : tSquibFireResult;
    MsgStr  : string;
begin
  if GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes ) then
  begin
    if Dis3500Drv.GetSquibFireResult( chanRes, SquibFireResult ) then
    begin
      DisplayStatus;
      case SquibFireResult of
        sfrFired              : tempstr := 'Fired';
        sfrNotFired           : tempstr := 'Not Fired';
      end;
      MsgStr := format('The Squib Fire Result for %d is %s',[chanRes,tempstr]);
      MessageDlg(MsgStr, mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;
end;

procedure TfrmDISSysTest.SoftwareBreak1Click(Sender: TObject);
begin
//  DIS3500Drv.InterruptProcess := TRUE;
  DIS3500Drv.InterruptProcess;
end;

procedure TfrmDISSysTest.AllChannels1Click(Sender: TObject);
var chan : integer;
    FinishedOK : boolean;
begin
  FinishedOK := true;
  for chan := 1 to 32 do
  begin
    if Dis3500Drv.ClearChannelMemory(Chan) then
    begin
      DisplayStatus;
      lblMemClear.Caption := format('Memory Cleared on Channel: %d',[Chan]);
    end
    else
    begin
      FinishedOK := false;
      MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
      MessageDlg('Memory Clearing Aborted', mtInformation, [mbok],0);
      break;
    end;
  end;
  DisplayStatus;
  if FinishedOK then
    lblMemClear.Caption := 'Memory Cleared on All Channels';
//  chanRes := 0;
//  if NOT (GetChannelVal('Please Choose a Channel','any channel mounted in the box', chanRes )) then
//    exit;
//  if Dis3500Drv.ClearChannelMemory( chanRes ) then
//  begin
//    DisplayStatus;
//    MessageDlg('Channel Memory '+ inttostr(chanRes) + ' cleared.', mtInformation, [mbOK], 0 );
//  end
//  else
//    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
//  DisplayStatus;
//
end;

// This command ONLY works with Analog Module Channels!!!!
//  Will NOT work with Airbag Timer Module channels or Digital Input Module channels!!!!!
procedure TfrmDISSysTest.TestMeasurement1Click(Sender: TObject);
var
  ChansToMeasure : TChansToMeasure;
  Measurements   : TChansMeasured;
  i : integer;
  msgstr : string;
begin
  if timer1.Tag = 0 then
  begin
    Label16.Tag := 0;
    timer1.tag := 1;
  end
  else
    timer1.tag := 0;
  timer1.enabled := timer1.tag = 1;
  exit;

  fillchar(ChansToMeasure, sizeof(ChansToMeasure), #0);
  for i := 1 to 16 do
    ChansToMeasure[i] := true;
  if Dis3500Drv.GetTestMeasurement(ChansToMeasure, Measurements) then
  begin
    DisplayStatus;
    msgstr := '';
    for i := 1 to 32 do
      msgstr := msgstr + format('%d. %d'+#13#10,[i, Measurements[i]]);
    showmessage(msgstr);
  end
  else
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  DisplayStatus;

end;

procedure TfrmDISSysTest.Dis3500DrvGetDataStatus(sender: TObject; Chan,
  PacketsRequested, PacketsReceived, PointsReceived, PointsRequested: Integer);
begin
  pbGetData.Position := PointsReceived;
  lblTotalPackets.caption := format('Total Packets: %d',[PacketsRequested]);
  lblPacketsReceived.caption := format('Packets Received: %d',[PacketsReceived]);
end;

procedure TfrmDISSysTest.Timer1Timer(Sender: TObject);
var
  ChansToMeasure : TChansToMeasure;
  Measurements   : TChansMeasured;
  i : integer;
  msgstr : string;
  count : integer;
  tempstr : string;
begin
  timer1.Enabled := false;
  fillchar(ChansToMeasure, sizeof(ChansToMeasure), #0);
  for i := 1 to 16 do
    ChansToMeasure[i] := true;
  if Dis3500Drv.GetTestMeasurement(ChansToMeasure, Measurements) then
  begin
    DisplayStatus;
    count := label16.Tag;
    inc(count);
    label16.tag := count;
    label16.caption := format('%d',[count]);
    if count mod 100 = 0 then
    begin
      if not Dis3500Drv.GetRomVersion(tempstr) then
      begin
        timer1.Tag := 0;
        MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
      end;
    end;
  end
  else
  begin
    timer1.Tag := 0;
    MessageDlg(Dis3500Drv.ErrorStr, mtError, [mbOK], 0);
  end;
  DisplayStatus;
  timer1.Enabled := timer1.Tag = 1;
end;

initialization
  frmDISSysTest := nil;
  progpath := ExtractFilepath(ParamStr(0));
  if progpath[length(progpath)] <> '\' then
    ProgPath := progpath + '\';
  fillchar( MonitorOpen, sizeof(MonitorOpen), ord(FALSE) );
  Create_DIS_Client;

finalization
  Destroy_DIS_Client;

end.
