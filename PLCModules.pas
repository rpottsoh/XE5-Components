////////////////////////////////////////////////////////////////////////////////
//                       Created By: Daniel Muncy                             //
//                             Date: 1/15/2010                                //
//                                                                            //
//                                                                            //
//    These Modules are designed to be used with the TCompactLogixPLC         //
//    component.  They are designed to make it easy to build a vitual PLC     //
//    to advance application development time.                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
unit PLCModules;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, stdctrls, DVM, DIOCtrl, ovclb, ovcbcklb, ovcbase,
  ovcef, ovcpb, ovcnf, CompactLogixComms;

type
  TOnNewAnalogInputData = procedure(Sender : TObject; Module : TAnalogInputModule) of Object;
  TOnNewProcessorData = procedure(Sender : TObject; Module : TProcessorModule) of Object;
  TOnNewDigitalInputData = procedure(Sender : TObject; Module : TDigitalInputModule) of Object;
  TOnNewAnalogOutputData = procedure(Sender : TObject; Module : TAnalogOutputModule) of Object;
  TOnNewDigitalOutputData = procedure(Sender : TObject; Module : TDigitalOutputModule) of Object;
  TOnNewRelayedDigitalOutputData = procedure(Sender : TObject; Module : TRelayedDigitalOutputModule) of Object;
  TOnNewVirtualDriveData = procedure(Sender : TObject; Module : TDriveModule) of Object;

  TModuleDrawType = (Draw_H,Draw_V);

  // 8 Channel Analog Input Module Types
  TAnalogChannel = record
                     Guage : TDVM;
                     LEDUR : TDioLED;
                     LEDOR : TDioLED;
                     Faulted : Boolean;
                     OverRange : Boolean;
                     UnderRange : Boolean;
                     MaxADRange : Integer;
                     MaxDCInputVolts : Integer;
  end; // TAnalogChannel (Size = 24)

  TIndicator = record
                 LED : TDioLED;
                 LEDLabel : TLabel;
  end; // TIndicator


  TDriveChannel = record
                    Guage : TDVM;
                    ADPerHertz : Single;                    
//                    ADPerHertz : Integer;
  end; // TDriveChannel (Size = 12)

  T8CHAnalogChannelArray = array[0..7] of TAnalogChannel;
  T8CHGuageArray = array[0..7] of TDVM;
  T8CHLableArray = array[0..15] of TLabel;
  T8CHLEDArray   = array[0..15] of TDioLED;
  T8CHInputFieldArray = array[0..7] of TOvcNumericField;
  T8CHButtonArray = array[0..7] of TButton;

//  TProcLEDArray = array[0..63] of TDioLED;
//  TProcLabelArray = array[0..63] of TLabel;

  TDigInLEDArray = array[0..15] of TDioLED;
  TDigInLabelArray = array[0..15] of TLabel;

  TDigOutLEDArray = array[0..15] of TDioLED;
  TDigOutLabelArray = array[0..15] of TLabel;

  TRelayedDigOutLEDArray = array[0..7] of TDioLED;
  TRelayedDigOutLabelArray = array[0..7] of TLabel;

  TDriveStatusLEDArray = array[0..15] of TDioLED;
  TDriveStatusLabelArray = array[0..15] of TLabel;
  TDriveLogicLEDArray = array[0..15] of TDioLED;
  TDriveLogicLabelArray = array[0..15] of TLabel;
  TDriveGuages = array[0..1] of TDVM;
  TDriveChannels = array[0..1] of TDriveChannel;

  TPulsedBits = Set of Byte;

  TVirtualPLCBackPlane = class;

  // Ancestor class for all modules --- will incorperate later...
  TCompactLogixBaseModule = class(TGroupBox)
    LEDConnected : TDioLED;
  private
    {Private Declarations}
    FControllerAssigned : TNotifyEvent;
    FParent : TWinControl;
    FPLCBackPlane : TVirtualPLCBackPlane;
    FPLCController : TCompactLogixPLC;
    FModulePosition : LongInt;
    FConnected : Boolean;
    FModuleDrawType : TModuleDrawType;
    procedure SetPLCController(Controller : TCompactLogixPLC);
    function GetPLCController : TCompactLogixPLC;
    procedure SetBackPlane(BackPlane : TVirtualPLCBackPlane);
    function GetBackPlane : TVirtualPLCBackPlane;
    procedure SetConnected(Value : Boolean);
    function GetConnected : Boolean;
    function GetWidth : LongInt;
    procedure SetWidth(Value : LongInt);
    function GeTCompactLogixBaseModuleCaption : String;
    procedure SeTCompactLogixBaseModuleCaption(Value : String);
    procedure SetHeight(Value : LongInt);
    function GetHeight : LongInt;
  protected
    {Protected Declarations}
  public
    {Public Declarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    property ParentModule : TWinControl read FParent;
    property BaseModuleWidth : LongInt read GetWidth write SetWidth;
    property BaseModuleHeight : LongInt read GetHeight write SetHeight;
    property BaseModuleCaption : String read GeTCompactLogixBaseModuleCaption write SeTCompactLogixBaseModuleCaption;
    property PLCController : TCompactLogixPLC read GetPLCController write SetPLCController;
    property BackPlane : TVirtualPLCBackPlane read GetBackPlane write SetBackPlane;
    property Connected : Boolean read GetConnected write SetConnected;
    property ModulePosition : LongInt read FModulePosition write FModulePosition default -1;
    property OnControllerAssigned : TNotifyEvent read FControllerAssigned write FControllerAssigned;
  end; // TCompactLogixBaseModule

  TCompactLogixVirtualDriveModule = class(TCompactLogixBaseModule)
    lblModuleNumber : TLabel;
    lblEntryStatus : TLabel;
    gbDriveStatus : TGroupBox;
    gbDriveLogic : TGroupBox;
    fldSetSpeed : TOvcNumericField;
    btnSetSpeed : TButton;
  private
    {Private Declarations}
    FOnNewVirtualDriveData : TOnNewVirtualDriveData;
    FDriveGuages : TDriveGuages;
    FCommandTag : String;
    FDriveStatusLabels : TStringList;
    FDriveLogicLabels : TStringList;
    FDriveStatusLEDArray : TDriveStatusLEDArray;
    FDriveStatusLabelArray : TDriveStatusLabelArray;
    FDriveLogicLEDArray : TDriveLogicLEDArray;
    FDriveLogicLabelArray : TDriveLogicLabelArray;
    FDriveChannels : TDriveChannels;
    FModuleError : Boolean;
    FInteractive : Boolean;
    procedure SetSpeed(Sender : TObject);
    procedure SetDriveStatusLabels(DriveStatusLabels : TStringList);
    procedure SetDriveLogicLabels(DriveLogicLabels : TStringList);
    procedure SetChannel(Index : Integer;Channel : TDriveChannel);
    function GetChannel(Index : Integer) : TDriveChannel;
    procedure SetInteractive(Value : Boolean);
  protected
    {Protected Declarations}
  public
    {Public Decalarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TDriveModule);
    property ModuleError : Boolean read FModuleError;
    property Channel[Index :integer] : TDriveChannel read GetChannel write SetChannel;
  published
    property ModulePosition;
    property Interactive : Boolean read FInteractive write SetInteractive;
    property SpeedCommandTag : String read FCommandTag write FCommandTag;
    property DriveStatusLabels : TStringList read FDriveStatusLabels write SetDriveStatusLabels;
    property DriveLogicLabels : TStringList read FDriveLogicLabels write SetDriveLogicLabels;
    property OnNewModuleData : TOnNewVirtualDriveData read FOnNewVirtualDriveData write FOnNewVirtualDriveData;
  end; // TCompactLogixVirtualDriveModule

  TCompactLogix8ChRelayedDigitalOutputModule = class(TCompactLogixBaseModule)
    lblModuleNumber : TLabel;
    LEDModuleError : TDioLED;
    lblModuleError : TLabel;
  private
    {Private Declarations}
    FOnNewRelayedDigitalOutputData : TOnNewRelayedDigitalOutputData;
    FRelayedDigOutLEDArray : TRelayedDigOutLEDArray;
    FRelayedDigOutLabelArray : TRelayedDigOutLabelArray;
    FModuleError : Boolean;
    FDigitalOutputLEDLabelWidth : LongInt;
    FLEDLabels : TStringList;
    procedure SetLEDLabels(LEDLabels : TStringList);
    function GetLEDLabels : TStringList;
    procedure SetDigitalOutputLEDLabelWidth(Value : LongInt);
    procedure SetModuleDrawType(Value : TModuleDrawType);
  protected
    {Protected Declartions}
    procedure BuildDigitalOutputLEDArrayHorizontal;
    procedure BuildDigitalOutputLEDArrayVertical;
    procedure ReSizeModuleDispaly;
  public
    {Public Declarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TRelayedDigitalOutputModule);
    property ModuleError : Boolean read FModuleError;
  published
    property ModulePosition;
    property LEDLabels : TStringList read GetLEDLabels write SetLEDLabels;
    property DigitalOutputLabelWidth : LongInt read FDigitalOutputLEDLabelWidth write SetDigitalOutputLEDLabelWidth;
    property ModuleOrientation : TModuleDrawType read FModuleDrawType write SetModuleDrawType;
    property OnNewModuleData : TOnNewRelayedDigitalOutputData read FOnNewRelayedDigitalOutputData write FOnNewRelayedDigitalOutputData;
  end; // TCompactLogix8ChRelayedDigitalOutputModule

  TCompactLogix8ChAnalogOuputModule = class(TCompactLogixBaseModule)
    LEDModuleError : TDioLED;
    lblModuleError : TLabel;
    lblModuleNumber : TLabel;
    btnZeroOutputs : TButton;
  private
    {Private Declarations}
    FOnNewAnalogOutputData : TOnNewAnalogOutputData;
    FAnalogChannels : T8CHAnalogChannelArray;
    FInputFieldArray : T8CHInputFieldArray;
    FDVMArray : T8CHGuageArray;
    FButtonArray : T8CHButtonArray;
    FLabelArray : T8CHLableArray;
    FLEDArray : T8CHLEDArray;
    FOutputTags : TStringList;
    FModuleError : Boolean;
    FInteractive : Boolean;
    procedure InputFieldClick(Sender : TObject);
    procedure ButtonClick(Sender : TObject);
    function GetChannel(Index : Integer) : TAnalogChannel;
    procedure SetChannel(Index : Integer; Value : TAnalogChannel);
    procedure SetOutputTags(OutputTags : TStringList);
    procedure SetInteractive(Value : Boolean);
  protected
    {Protected Declarations}
  public
    {Public Declarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TAnalogOutputModule);
    property ModuleError : Boolean read FModuleError;
    property Channel[Index :integer] : TAnalogChannel read GetChannel write SetChannel;
  published
    property ModulePosition;
    property Interactive : Boolean read FInteractive write SetInteractive;
    property OutputTags : TStringList read FOutputTags write SetOutputTags;
    property OnNewModuleData : TOnNewAnalogOutputData read FOnNewAnalogOutputData write FOnNewAnalogOutputData;
  end; // TCompactLogix8ChAnalogOuputModule

  TCompactLogix16ChDigitalOutputModule = class(TCompactLogixBaseModule)
    lblModuleNumber : TLabel;
    LEDModuleError : TDioLED;
    lblModuleError : TLabel;
  private
    {Private Declarations}
    FOnNewDigitalOutputData : TOnNewDigitalOutputData;
    FDigOutLEDArray : TDigOutLEDArray;
    FDigOutLabelArray : TDigOutLabelArray;
    FModuleError : Boolean;
    FDigitalOutputLEDLabelWidth : LongInt;
    FLEDLabels : TStringList;
    procedure SetLEDLabels(LEDLabels : TStringList);
    function GetLEDLabels : TStringList;
    procedure SetDigitalOutputLEDLabelWidth(Value : LongInt);
    procedure SetModuleDrawType(Value : TModuleDrawType);
  protected
    {Protected Declarations}
    procedure BuildDigitalOutputLEDArrayHorizontal;
    procedure BuildDigitalOutputLEDArrayVertical;
    procedure ReSizeModuleDispaly;
  public
    {Public Declarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TDigitalOutputModule);
    property ModuleError : Boolean read FModuleError;
  published
    property ModulePosition;
    property LEDLabels : TStringList read GetLEDLabels write SetLEDLabels;
    property DigitalOutputLabelWidth : LongInt read FDigitalOutputLEDLabelWidth write SetDigitalOutputLEDLabelWidth;
    property ModuleOrientation : TModuleDrawType read FModuleDrawType write SetModuleDrawType;
    property OnNewModuleData : TOnNewDigitalOutputData read FOnNewDigitalOutputData write FOnNewDigitalOutputData;
  end; // TCompactLogix16ChDigitalOutputModule

  TCompactLogix16ChDigitalInputModule = class(TCompactLogixBaseModule)
    lblModuleNumber : TLabel;
    LEDModuleError : TDioLED;
    lblModuleError : TLabel;
  private
    {Private Declarations}
    FOnNewDigitalInputData : TOnNewDigitalInputData;
    FDigInLEDArray : TDigInLEDArray;
    FDigInLabelArray : TDigInLabelArray;
    FModuleError : Boolean;
    FDigitalInputLEDLabelWidth : LongInt;
    FLEDLabels : TStringList;
    procedure SetLEDLabels(LEDLabels : TStringList);
    function GetLEDLabels : TStringList;
    procedure SetDigitalInputLEDLabelWidth(Value : LongInt);
    procedure SetModuleDrawType(Value : TModuleDrawType);
  protected
    {Protected Declarations}
    procedure BuildDigitalInputLEDArrayHorizontal;
    procedure BuildDigitalInputLEDArrayVertical;
    procedure ReSizeModuleDispaly;
  public
    {Public Declarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TDigitalInputModule);
    property ModuleError : Boolean read FModuleError;
  published
    property ModulePosition;
    property LEDLabels : TStringList read GetLEDLabels write SetLEDLabels;
    property DigitalInputLabelWidth : LongInt read FDigitalInputLEDLabelWidth write SetDigitalInputLEDLabelWidth;
    property ModuleOrientation : TModuleDrawType read FModuleDrawType write SetModuleDrawType;
    property OnNewModuleData : TOnNewDigitalInputData read FOnNewDigitalInputData write FOnNewDigitalInputData;
  end; // TCompactLogix16ChDigitalInputModule

  TCompactLogixProcessorModule = class(TCompactLogixBaseModule)
    LEDKeySwitchPosition : TDioLED;
    LEDProcessorMode : TDioLED;
    LEDPLCFault : TDioLED;
    LEDPLCBatteryOK : TDioLED;
    LEDPLCForcesActive : TDioLED;
    lblModuleNumber : TLabel;
    lblProcSerialNumber : TLabel;
    lblKeySWPos : TLabel;
    lblProcMode : TLabel;
    lblProcFault : TLabel;
    lblProcBattery : TLabel;
    lblProcForces : TLabel;
    gbRequestBits : TGroupBox;
    gbOutputBits : TGroupBox;
    clRequestBits : TOvcBasicCheckList;
    cbWatchDog : TCheckBox;
  private
    {Private Declarations}
    FOnNewProcessorData : TOnNewProcessorData;
    RequestBitLEDArray : Array[0..1,0..31] of TIndicator;
    FRequestBitLabels : TStringList;
    FPLCTags : TStringList;
    FPulsedBits : TPulsedBits;
    FModuleError : Boolean;
    FInteractive : Boolean;
    FBinaryElementCount : LongInt;
    FRequestLEDLabelWidth : LongInt;
    procedure SetLEDLabels(LEDLabels : TStringList);
    procedure SetPLCTags(PLCTags : TStringList);
    procedure RequestBitsClick(Sender : TObject);
    function GetLEDLabels : TStringList;
    procedure SetKeySwitchPosition(Position : Integer);
    procedure SetProcessorMode(Mode : Integer);
    procedure SetForcesActive(Installed : Boolean; Enabled : Boolean);
    procedure SetInteractive(Value : Boolean);
    procedure SetRequestLEDLabelWidth(Value : LongInt);
    procedure chWatchDogClick(Sender : TObject);
  protected
    {Protected Declarations}
    procedure BuildRequestBitLEDArray;
    procedure BuildRequestBitSelection;
    procedure ReSizeModuleDisplay;
    procedure ControllerAssigned(Sender : TObject);
  public
    {Public Declarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TProcessorModule);
    property ModuleError : Boolean read FModuleError;
    property PulsedBits : TPulsedBits read FPulsedBits write FPulsedBits;
  published
    property ModulePosition;
    property Interactive : Boolean read FInteractive write SetInteractive;
    property RequestLEDLabelWidth : LongInt read FRequestLEDLabelWidth write SetRequestLEDLabelWidth;
    property LEDLabels : TStringList read GetLEDLabels write SetLEDLabels;
    property PLCTags : TStringList read FPLCTags write SetPLCTags;
    property OnNewModuleData : TOnNewProcessorData read FOnNewProcessorData write FOnNewProcessorData;
  end; // TCompactLogixProcessorModule

  TPLCProcessorModule = TCompactLogixProcessorModule;

  TCompactLogix8ChAnalogInputModule = Class(TCompactLogixBaseModule)
    LEDAnlgInError: TDioLed;
    lblModuleError: TLabel;
    lblAnlgInModuleNum: TLabel;
  private
    {Private Declarations}
    FOnNewAnalogInputModuleData : TOnNewAnalogInputData;
    FDVMArray : T8CHGuageArray;
    FLabelArray : T8CHLableArray;
    FLEDArray : T8CHLEDArray;
    FAnalogChannels : T8CHAnalogChannelArray;
    FModuleError : Boolean;
    function GetChannel(Index : Integer) : TAnalogChannel;
    procedure SetChannel(Index : Integer; Value : TAnalogChannel);
  protected
    {Protected Declarations}
  public
    {Public Declarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TAnalogInputModule);
    property Channel[Index :integer] : TAnalogChannel read GetChannel write SetChannel;
  published
    property ModulePosition;
    property ModuleError : Boolean read FModuleError;
    property OnNewModuleData : TOnNewAnalogInputData read FOnNewAnalogInputModuleData write FOnNewAnalogInputModuleData;
  end; // TCompactLogix8ChAnalogInputModule

  TPLC8CHAnalogInputModule = TCompactLogix8ChAnalogInputModule;

  // PLC Back Plane Component
  TProcessorModuleArray = array[0..MaximumModules] of TCompactLogixProcessorModule;
  TAnalogInputModuleArray = array[0..MaximumModules] of TCompactLogix8ChAnalogInputModule;
  TAnalogOutputModuleArray = array[0..MaximumModules] of TCompactLogix8ChAnalogOuputModule;
  TDigitalInputModuleArray = array[0..MaximumModules] of TCompactLogix16ChDigitalInputModule;
  TDigitalOutputModuleArray = array[0..MaximumModules] of TCompactLogix16ChDigitalOutputModule;
  TRelayedDigitalOutputModuleArray = array[0..MaximumModules] of TCompactLogix8ChRelayedDigitalOutputModule;
  TVirtualDriveModuleArray = array[0..MaximumModules] of TCompactLogixVirtualDriveModule;
  // ---------------------------------------------------------------------------

  TVirtualPLCBackPlane = class(TComponent)
  private
    {Private Declarations}
    FOnNewModuleData : TSendModuleData;
    FPLCController : TCompactLogixPLC;
    FModulesInstalled : Integer;
    FProcModules : Integer;
    FAIModules : Integer;
    FAOModules : Integer;
    FDIModules : Integer;
    FDOModules : Integer;
    FRDOModules : Integer;
    FDrvModules : Integer;
    FProcessorModules : TProcessorModuleArray;
    FAnalogInputModules : TAnalogInputModuleArray;
    FAnalogOutputModules : TAnalogOutputModuleArray;
    FDigitalInputModules : TDigitalInputModuleArray;
    FDigitalOutputModules : TDigitalOutputModuleArray;
    FRelayedDigitalOutputModules : TRelayedDigitalOutputModuleArray;
    FPowerFlex700DriveModules : TVirtualDriveModuleArray;
    procedure SetPLCController(Controller : TCompactLogixPLC);
    function GetPLCController : TCompactLogixPLC;
  protected
    {Protected Declarations}
    procedure AssignControllerToModules;
  public
    {Public Declarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure AddModuleToBackPlane(Module : TCompactLogixBaseModule);
    procedure RemoveModuleFromBackPlane(Module : TCompactLogixBaseModule);
    procedure NewPLCData(Sender : TObject; Modules : TModuleArray; ModuleTypes : TModuleType; ModuleCount : Integer);
    property ModulesInstalled : Integer read FModulesInstalled;
    property OnNewModuleData : TSendModuleData read FOnNewModuleData write FOnNewModuleData;
  published
    property PLCController : TCompactLogixPLC read GetPLCController write SetPLCController;
  end; // TVirtualPLCBackPlane

//procedure Register;

implementation
{_R PLCModules.dcr}

//procedure Register;
//begin
//  RegisterComponents('Compact Logix Modules',[TVirtualPLCBackPlane,TCompactLogixVirtualDriveModule,TCompactLogix8ChRelayedDigitalOutputModule,
//                                    TCompactLogix16ChDigitalOutputModule,TCompactLogix8ChAnalogOuputModule,TCompactLogix16ChDigitalInputModule,
//                                    TCompactLogixProcessorModule,TCompactLogix8ChAnalogInputModule]);
//end; // Register

constructor TCompactLogixBaseModule.Create(AOwner : TComponent);
var
  lFont : TFont;
  lPen : TPen;
begin
  inherited Create(AOwner);
  if (AOwner is TWinControl) then
    Parent := (AOwner as TWinControl);
  FModulePosition := -1;
  FConnected := False;
  FModuleDrawType := Draw_H;
  if Assigned(Parent) and (csAcceptsControls in Parent.ControlStyle) then
  begin
    lFont := TFont.Create;
    with lFont do
    begin
      Color := clWhite;
      Name := 'MS Sans Serif';
      Size := 8;
      Style := [];
    end; // With
    lPen := TPen.Create;
    with lPen do
    begin
      Color := clBlack;
      Mode := pmCopy;
      Style := psSolid;
      Width := 1;
    end; // With
    Height := 252;
    Width := 698;
    Color := clBlue;
    Font := lFont;
    Caption := 'BASE MODULE CLASS';
    FParent := Self;
    LEDConnected := TDioLED.Create(Nil);
    with LEDConnected do
    begin
      Parent := FParent;
      Top := 8;
      Left := FParent.Width - 10;
      Height := 10;
      Width := 10;
      LitColor := clLime;
      Shape := stRoundRect;
    end; // With
  end; // If
  lFont.Free;
  lPen.Free;
end; // TCompactLogixBaseModule.Create

destructor TCompactLogixBaseModule.Destroy;
begin
  if Assigned(FPLCBackPlane) then
    FPLCBackPlane.RemoveModuleFromBackPlane(Self);
  inherited Destroy;
end; // TCompactLogixBaseModule.Destroy

procedure TCompactLogixBaseModule.SetPLCController(Controller : TCompactLogixPLC);
begin
  if (Controller <> Nil) then
  begin
    FPLCController := Controller;
    if Assigned(FControllerAssigned) then
      FControllerAssigned(Self);
  end; // If
end; // TCompactLogixBaseModule.SetPLCController

function TCompactLogixBaseModule.GetPLCController : TCompactLogixPLC;
begin
  if Assigned(FPLCController) then
    Result := FPLCController
  else
    Result := Nil;
end; // TCompactLogixBaseModule.GetPLCController

procedure TCompactLogixBaseModule.SetBackPlane(BackPlane : TVirtualPLCBackPlane);
begin
  if Assigned(BackPlane) then
  begin
    FPLCBackPlane := BackPlane;
    SetConnected(True);
  end; // If
end; // TCompactLogixBaseModule.SetBackPlane

function TCompactLogixBaseModule.GetBackPlane : TVirtualPLCBackPlane;
begin
  if Assigned(FPLCBackPlane) then
    Result := FPLCBackPlane
  else
    Result := Nil;
end; // TCompactLogixBaseModule.GetBackPlane

procedure TCompactLogixBaseModule.SetConnected(Value : Boolean);
begin
  FConnected := Value;
  LEDConnected.Lit := FConnected;
  if Not FConnected then
    FPLCBackPlane := Nil;
end; // TCompactLogixBaseModule.SetConnected

function TCompactLogixBaseModule.GetConnected : Boolean;
begin
  if Assigned(FPLCBackPlane) then
    FConnected := True
  else
    FConnected := False;
  Result := FConnected;
end; // TCompactLogixBaseModule.GetConnected

function TCompactLogixBaseModule.GetWidth : LongInt;
begin
  Result := ParentModule.Width;
end; // TCompactLogixBaseModule.GetWidth

procedure TCompactLogixBaseModule.SetWidth(Value : LongInt);
begin
  ParentModule.Width := Value;
  LEDConnected.Left := ParentModule.Width - LEDConnected.Width - 3;
end; // TCompactLogixBaseModule.SetWidth

procedure TCompactLogixBaseModule.SetHeight(Value : LongInt);
begin
  ParentModule.Height := Value;
end; // TCompactLogixBaseModule.SetHeight

function TCompactLogixBaseModule.GetHeight : LongInt;
begin
  Result := ParentModule.Height;
end; // TCompactLogixBaseModule.GetHeight

function TCompactLogixBaseModule.GeTCompactLogixBaseModuleCaption : String;
begin
  Result := Caption;
end; // TCompactLogixBaseModule.GeTCompactLogixBaseModuleCaption

procedure TCompactLogixBaseModule.SeTCompactLogixBaseModuleCaption(Value : String);
begin
  Caption := Value;
end; // TCompactLogixBaseModule.SeTCompactLogixBaseModuleCaption

function TCompactLogixVirtualDriveModule.GetChannel(Index : Integer) : TDriveChannel;
begin
  if (Index in [Low(FDriveChannels)..High(FDriveChannels)]) then
    Result := FDriveChannels[Index];
end; // TCompactLogixVirtualDriveModule.GetChannel

procedure TCompactLogixVirtualDriveModule.SetChannel(Index : Integer; Channel : TDriveChannel);
begin
  if (Index in [Low(FDriveChannels)..High(FDriveChannels)]) then
    FDriveChannels[Index] := Channel;
end; // TCompactLogixVirtualDriveModule.SetChannel

procedure TCompactLogixVirtualDriveModule.SetDriveLogicLabels(DriveLogicLabels : TStringList);
var
  i : Integer;
begin
  FDriveLogicLabels.Clear;
  for i := 0 to (DriveLogicLabels.Count - 1) do
  begin
    if (i > High(FDriveLogicLabelArray)) then
      Break;
    FDriveLogicLabels.Add(DriveLogicLabels.Strings[i]);
    FDriveLogicLabelArray[i].Caption := FDriveLogicLabels.Strings[i];
  end; // For i
end; // TCompactLogixVirtualDriveModule.SetDriveLogicLabels

procedure TCompactLogixVirtualDriveModule.SetDriveStatusLabels(DriveStatusLabels : TStringList);
var
  i : Integer;
begin
  FDriveStatusLabels.Clear;
  for i := 0 to (DriveStatusLabels.Count - 1) do
  begin
    if (i > High(FDriveStatusLabelArray)) then
      Break;
    FDriveStatusLabels.Add(DriveStatusLabels.Strings[i]);
    FDriveStatusLabelArray[i].Caption := FDriveStatusLabels.Strings[i];
  end; // For i
end; // TCompactLogixVirtualDriveModule.SetDriveStatusLabels

procedure TCompactLogixVirtualDriveModule.SetSpeed(Sender : TObject);
var
  SpeedVal : Integer;
begin
  if (FDriveChannels[0].ADPerHertz > 0) then
    SpeedVal := Trunc(fldSetSpeed.AsFloat * FDriveChannels[0].ADPerHertz)
  else
    SpeedVal := 0;
  if Assigned(FPLCController) and (FCommandTag <> '') then
    FPLCController.WriteToPLC(FCommandTag,1,SpeedVal);
end; // TCompactLogixVirtualDriveModule.SetSpeed

procedure TCompactLogixVirtualDriveModule.SetInteractive(Value : Boolean);
begin
  FInteractive := Value;
  fldSetSpeed.Enabled := FInteractive;
  btnSetSpeed.Enabled := FInteractive;
end; // TCompactLogixVirtualDriveModule.SetInteractive

procedure TCompactLogixVirtualDriveModule.NewModuleData(Sender : TObject; Module : TDriveModule);
var
  i : Integer;
begin
  with Module do
  begin
    if (ModuleNumber = FModulePosition) then
    begin
      LEDConnected.Lit := Not LEDConnected.Lit;
      BaseModuleCaption := ModuleString;
      lblModuleNumber.Caption := format('Module Number: %d',[ModuleNumber]);
      lblEntryStatus.Caption := format('Entry Status: %x',[ModuleEntryStatus]);
//      FModuleError := (ModuleEntryStatus <> 16897);
      FModuleError := ((ModuleEntryStatus AND $0F000) <> $4000);     // 16897);
      for i := 0 to High(FDriveStatusLEDArray) do
        FDriveStatusLEDArray[i].Lit := DriveStatus[i];
      for i := 0 to High(FDriveLogicLEDArray) do
        FDriveLogicLEDArray[i].Lit := DriveLogicResult[i];
      if (FDriveChannels[0].ADPerHertz > 0) then
        FDriveChannels[0].Guage.value := (CommandedFrequency / FDriveChannels[0].ADPerHertz)
      else
        FDriveChannels[0].Guage.value := 0;
      if (FDriveChannels[1].ADPerHertz > 0) then
        FDriveChannels[1].Guage.value := (OutputFrequency / FDriveChannels[1].ADPerHertz)
      else
        FDriveChannels[1].Guage.Value := 0;
    end; // If
    if Assigned(FOnNewVirtualDriveData) then
      FOnNewVirtualDriveData(Self,Module);
  end; // With
end; // TCompactLogixVirtualDriveModule.NewModuleData

destructor TCompactLogixVirtualDriveModule.Destroy;
begin
  inherited Destroy;
end; // TCompactLogixVirtualDriveModule.Destroy

constructor TCompactLogixVirtualDriveModule.Create(AOwner : TComponent);
var
  lFont : TFont;
  lPen : TPen;
  i : Integer;
  lRow : Integer;
  lColumn : Integer;
  lGuageFont : TFont;
begin
  inherited Create(AOwner);
  FModuleError := False;
  FInteractive := True;
  FDriveStatusLabels := TStringList.Create;
  FDriveLogicLabels := TStringList.Create;
  for i := 0 to 15 do
  begin
    FDriveStatusLabels.Add(format('Label %d',[i]));
    FDriveLogicLabels.Add(format('Label %d',[i]));
  end; // For i
  lFont := TFont.Create;
  with lFont do
  begin
    Color := clWhite;
    Name := 'MS Sans Serif';
    Size := 8;
    Style := [];
  end; // With
  lPen := TPen.Create;
  with lPen do
  begin
    Color := clBlack;
    Mode := pmCopy;
    Style := psSolid;
    Width := 1;
  end; // With
  lGuageFont := TFont.Create;
  with lGuageFont do
  begin
    Name := 'Arial';
    Color := clBlack;
    Size := 8;
  end; // With
  if (csAcceptsControls in ParentModule.ControlStyle) then
  begin
    BaseModuleHeight := 104;
    BaseModuleWidth := 710;
    Font := lFont;
    BaseModuleCaption := 'Power Flex 700 Drive Module';
    lblModuleNumber := TLabel.Create(Self);
    with lblModuleNumber do
    begin
      Parent := Self;
      Left := 8;
      Top := 11;
      Font.Name := 'MS Sans Serif';
      Font.Color := clWhite;
      Font.Size := 8;
      Height := 13;
      Width := 78;
      Caption := 'Module Number:';
      Transparent := True;
    end; // With
    lblEntryStatus := TLabel.Create(Self);
    with lblEntryStatus do
    begin
      Parent := Self;
      Left := 130;
      Top := 11;
      Font.Name := 'MS Sans Serif';
      Font.Color := clWhite;
      Font.Size := 8;
      Height := 13;
      Width := 60;
      Caption := 'Entry Status:';
      Transparent := True;
    end; // With
    gbDriveStatus := TGroupBox.Create(Self);
    with gbDriveStatus do
    begin
      Parent := Self;
      Top := 8;
      Left := 260;
      Height := 93;
      Width := 208;
      Color := clBlue;
      Font := lFont;
      Caption := 'Drive Status';
    end; // With
    gbDriveLogic := TGroupBox.Create(Self);
    with gbDriveLogic do
    begin
      Parent := Self;
      Top := 8;
      Left := 471;
      Height := 93;
      Width := 224;
      Color := clBlue;
      Font := lFont;
      Caption := 'Drive Logic';
    end; // With
    fldSetSpeed := TOvcNumericField.Create(Self);
    with fldSetSpeed do
    begin
      Parent := Self;
      Top := 78;
      Left := 61;
      Height := 19;
      Width := 65;
      DataType := nftSingle;
      PictureMask := '####.###';
      RangeHi := '1000';
      RangeLo := '-1000';
      AsFloat := 0;
      Font := lFont;
      Font.Color := clBlack;
      Font.Style := [fsBold];
    end; // With
    btnSetSpeed := TButton.Create(Self);
    with btnSetSpeed do
    begin
      Parent := Self;
      Top := 78;
      Left := 127;
      Height := 19;
      Width := 55;
      Font := lFont;
      Font.Color := clBlack;
      Caption := 'Set Speed';
      OnClick := SetSpeed;
    end; // With
    lRow := 0;
    lColumn := 0;
    for i := Low(FDriveGuages) to High(FDriveGuages) do
    begin
      FDriveGuages[i] := TDVM.create(Self);
      with FDriveGuages[i] do
      begin
        Parent := Self;
        Top := 26;
        case i of
          0 : begin
                Left := 5;
                Title := 'Command Frequency';
              end; // 0
          1 : begin
                Left := 130;
                Title := 'Command Readback';
              end; // 1
        end; // Case
        UnitsFont := lGuageFont;
        TitleFont := lGuageFont;
        font := lGuageFont;
        font.Style := [fsBold];
        font.Size := 10;
        Units := 'Hertz';
        Height := 51;
        Width := 124;
      end; // With
      FDriveChannels[i].Guage := FDriveGuages[i];
    end; // For i
    for i := Low(FDriveStatusLEDArray) to High(FDriveStatusLEDArray) do
    begin
      FDriveStatusLEDArray[i] := TDioLED.Create(gbDriveStatus);
      with FDriveStatusLEDArray[i] do
      begin
        Parent := gbDriveStatus;
        Height := 10;
        Width := 10;
        LitColor := clLime;
        UnlitColor := clBlack;
        if (i = 0) then
        begin
          Top := 13;
          Left := 4;
        end
        else
        begin
          Top := FDriveStatusLEDArray[0].Top + (lRow * 13);
          if (lColumn <> 2) then
            Left := FDriveStatusLEDArray[0].Left + (lColumn * 74)
          else
            Left := FDriveStatusLEDArray[0].Left + (lColumn * 65);
        end; // If
        Shape := stRoundRect;
      end; // With
      FDriveStatusLabelArray[i] := TLabel.Create(gbDriveStatus);
      with FDriveStatusLabelArray[i] do
      begin
        Parent := gbDriveStatus;
        if (i = 0) then
        begin
          Top := 11;
          Left := 16;
        end
        else
        begin
          Top := FDriveStatusLabelArray[0].Top + (lRow * 13);
          if (lColumn <> 2) then
            Left := FDriveStatusLabelArray[0].Left + (lColumn * 74)
          else
            Left := FDriveStatusLabelArray[0].Left + (lColumn * 65);
        end; // If
        Font := lFont;
        Font.Name := 'MS Sans';
        Caption := format('Label%d',[i]);
      end; // With
      FDriveLogicLEDArray[i] := TDioLED.Create(gbDriveLogic);
      with FDriveLogicLEDArray[i] do
      begin
        Parent := gbDriveLogic;
        Height := 10;
        Width := 10;
        LitColor := clLime;
        UnlitColor := clBlack;
        if (i = 0) then
        begin
          Top := 13;
          Left := 4;
        end
        else
        begin
          Top := FDriveLogicLEDArray[0].Top + (lRow * 13);
          Left := FDriveLogicLEDArray[0].Left + (lColumn * 75);
        end; // If
        Shape := stRoundRect;
      end; // With
      FDriveLogicLabelArray[i] := TLabel.Create(gbDriveLogic);
      with FDriveLogicLabelArray[i] do
      begin
        Parent := gbDriveLogic;
        if (i = 0) then
        begin
          Top := 11;
          Left := 16;
        end
        else
        begin
          Top := FDriveLogicLabelArray[0].Top + (lRow * 13);
          Left := FDriveLogicLabelArray[0].Left + (lColumn * 75);
        end; // If
        Font := lFont;
        Font.Name := 'MS Sans';
        Caption := format('Label%d',[i]);
      end; // With
      if (i > 0) and (lRow = 5) then
      begin
        inc(lColumn);
        lRow := 0;
      end
      else
      begin
        inc(lRow);
      end; // If
    end; // For i
  end; // If
end; // TCompactLogixVirtualDriveModule.Create

procedure TCompactLogix8ChRelayedDigitalOutputModule.SetModuleDrawType(Value : TModuleDrawType);
begin
  if (Value <> FModuleDrawType) then
  begin
    FModuleDrawType := Value;
    SetDigitalOutputLEDLabelWidth(FDigitalOutputLEDLabelWidth);
  end; // If
end; // TCompactLogix8ChRelayedDigitalOutputModule.SetModuleDrawType

procedure TCompactLogix8ChRelayedDigitalOutputModule.BuildDigitalOutputLEDArrayVertical;
var
  i : LongInt;
  lRow : LongInt;
begin
  lRow := 0;
  for i := Low(FRelayedDigOutLEDArray) to High(FRelayedDigOutLEDArray) do
  begin
    if Not Assigned(FRelayedDigOutLEDArray[i]) then
      FRelayedDigOutLEDArray[i] := TDioLED.Create(Nil);
    with FRelayedDigOutLEDArray[i] do
    begin
      Parent := ParentModule;
      Top := 55 + (12 * lRow);
      Left := 5;
      Height := 10;
      Width := 10;
      Shape := stRoundRect;
      LitColor := clLime;
    end; // With
    if Not Assigned(FRelayedDigOutLabelArray[i]) then
      FRelayedDigOutLabelArray[i] := TLabel.Create(Nil);
    with FRelayedDigOutLabelArray[i] do
    begin
      Parent := ParentModule;
      Top := 55 + (12 * lRow);
      Left := 15;
      Font.Name := 'Terminal';
      Font.Size := 6;
      Font.Color := clWhite;
      Caption := FLEDLabels.Strings[i];
      Transparent := True;
      Height := 13;
      Width := FDigitalOutputLEDLabelWidth;
    end; // With
    inc(lRow);
  end; // For i
  ReSizeModuleDispaly;
end; // TCompactLogix8ChRelayedDigitalOutputModule.BuildDigitalOutputLEDArrayVertical

procedure TCompactLogix8ChRelayedDigitalOutputModule.SetDigitalOutputLEDLabelWidth(Value : LongInt);
begin
  FDigitalOutputLEDLabelWidth := Value;
  case FModuleDrawType of
    Draw_H : BuildDigitalOutputLEDArrayHorizontal;
    Draw_V : BuildDigitalOutputLEDArrayVertical
  end; // Case
end; // TCompactLogix8ChRelayedDigitalOutputModule.SetDigitalInputLEDLabelWidth

procedure TCompactLogix8ChRelayedDigitalOutputModule.BuildDigitalOutputLEDArrayHorizontal;
var
  i : LongInt;
  lRow : LongInt;
  lColumn : LongInt;
begin
  lRow := 0;
  lColumn := 0;
  for i := Low(FRelayedDigOutLEDArray) to High(FRelayedDigOutLEDArray) do
  begin
    if Not Assigned(FRelayedDigOutLEDArray[i]) then
      FRelayedDigOutLEDArray[i] := TDioLED.Create(Nil);
    with FRelayedDigOutLEDArray[i] do
    begin
      Parent := ParentModule;
      Top := 16 + (12 * lRow);
      Left := (LEDModuleError.Left + LEDModuleError.Width + 3) + (FDigitalOutputLEDLabelWidth * lColumn);
      Height := 10;
      Width := 10;
      Shape := stRoundRect;
      LitColor := clLime;
    end; // With
    if Not Assigned(FRelayedDigOutLabelArray[i]) then
      FRelayedDigOutLabelArray[i] := TLabel.Create(Nil);
    with FRelayedDigOutLabelArray[i] do
    begin
      Parent := ParentModule;
      Top := 17 + (12 * lRow);
      Left := (LEDModuleError.Left + LEDModuleError.Width + 3 + 12) + (FDigitalOutputLEDLabelWidth * lColumn);
      Font.Name := 'Terminal';
      Font.Size := 6;
      Font.Color := clWhite;
      Caption := FLEDLabels.Strings[i];
      Transparent := True;
      Height := 13;
      Width := FDigitalOutputLEDLabelWidth;
    end; // With
    inc(lRow);
    if (lRow > 3) then
    begin
      inc(lColumn);
      lRow := 0;
    end; // If
  end; // For i
  ReSizeModuleDispaly;
end; // TCompactLogix8ChRelayedDigitalOutputModule.BuildDigitalOutputLEDArrayHorizontal

procedure TCompactLogix8ChRelayedDigitalOutputModule.ReSizeModuleDispaly;
var
  TempVar : LongInt;
begin
  case FModuleDrawType of
    Draw_H : begin
               BaseModuleHeight := 70;
               BaseModuleWidth := FRelayedDigOutLabelArray[7].Left + FRelayedDigOutLabelArray[7].Width + 2;
             end; // If
    Draw_V : begin
               TempVar := FRelayedDigOutLabelArray[7].Left + FRelayedDigOutLabelArray[7].Width + 2;
               if (TempVar > (LEDModuleError.Left + LEDModuleError.Width)) then
                 BaseModuleWidth := FRelayedDigOutLabelArray[7].Left + FRelayedDigOutLabelArray[7].Width + 2
               else
                 BaseModuleWidth := LEDModuleError.Left + LEDModuleError.Width + 95;
               BaseModuleHeight := FRelayedDigOutLabelArray[7].Top + FRelayedDigOutLabelArray[7].Height + 2;
             end; // Draw_V
  end; // Case
end; // TCompactLogix8ChRelayedDigitalOutputModule.ReSizeModuleDisplay

procedure TCompactLogix8ChRelayedDigitalOutputModule.NewModuleData(Sender : TObject; Module : TRelayedDigitalOutputModule);
var
  i : Integer;
  lModuleFault : Boolean;
begin
  lModuleFault := False;
  with Module do
  begin
    if (ModuleNumber = FModulePosition) then
    begin
      LEDConnected.Lit := Not LEDConnected.Lit;
      BaseModuleCaption := ModuleString;
      lblModuleNumber.Caption := format('Module Number: %d',[ModuleNumber]);
      for i := 0 to High(FRelayedDigOutLEDArray) do
      begin
        FRelayedDigOutLEDArray[i].Lit := RelayedOutputData[i];
        lModuleFault := lModuleFault or Fault[i] or Fault[i + 1];
      end; // For i
      FModuleError := lModuleFault;
      LEDModuleError.Lit := FModuleError;
    end; // If
    if Assigned(FOnNewRelayedDigitalOutputData) then
      FOnNewRelayedDigitalOutputData(Self,Module);
  end; // With
end; // TCompactLogix8ChRelayedDigitalOutputModule.NewModuleData

function TCompactLogix8ChRelayedDigitalOutputModule.GetLEDLabels : TStringList;
begin
  Result := FLEDLabels;
end; // TCompactLogix8ChRelayedDigitalOutputModule.GetLEDLabels

procedure TCompactLogix8ChRelayedDigitalOutputModule.SetLEDLabels(LEDLabels : TStringList);
var
  i : Integer;
begin
  FLEDLabels.Clear;
  for i := 0 to (LEDLabels.Count - 1) do
  begin
    if (i > High(FRelayedDigOutLabelArray)) then
      Break;
    FLEDLabels.Add(LEDLabels.Strings[i]);
    FRelayedDigOutLabelArray[i].Caption := FLEDLabels.Strings[i];
  end; // For i
end; // TCompactLogix8ChRelayedDigitalOutputModule.SetLEDLabels

destructor TCompactLogix8ChRelayedDigitalOutputModule.Destroy;
begin
  FLEDLabels.Free;
  inherited Destroy;
end; // TCompactLogix8ChRelayedDigitalOutputModule.Destroy

constructor TCompactLogix8ChRelayedDigitalOutputModule.Create(AOwner : TComponent);
var
  lFont : TFont;
  lPen : TPen;
  i : Integer;
  lRow : Integer;
  lColumn : Integer;
begin
  inherited Create(AOwner);
  FDigitalOutputLEDLabelWidth := 75;
  FModuleError := False;
  FLEDLabels := TStringList.Create;
  for i := Low(FRelayedDigOutLabelArray) to High(FRelayedDigOutLabelArray) do
    FLEDLabels.Add(format('Label %d',[i]));
  lFont := TFont.Create;
  with lFont do
  begin
    Color := clWhite;
    Name := 'MS Sans Serif';
    Size := 8;
    Style := [];
  end; // With
  lPen := TPen.Create;
  with lPen do
  begin
    Color := clBlack;
    Mode := pmCopy;
    Style := psSolid;
    Width := 1;
  end; // With
  if (csAcceptsControls in ParentModule.ControlStyle) then
  begin
    BaseModuleHeight := 53;
    BaseModuleWidth := 815;
    Font := lFont;
    BaseModuleCaption := '8 Channel Relayed Digital Output Module';
    LEDModuleError := TDioLed.Create(Self);
    with LEDModuleError do
    begin
      Parent := Self;
      Left := 8;
      Top := 25;
      LitColor := clRed;
      UnlitColor := clBlack;
      Height := 25;
      Width := 121;
      Pen.Color := clSilver;
      Pen.Mode := pmCopy;
      Pen.Style := psSolid;
      Pen.Width := 1;
      Shape := stRoundRect;
    end; // With
    lblModuleError := TLabel.Create(Self);
    with lblModuleError do
    begin
      Parent := Self;
      Left := 36;
      Top := 30;
      Font.Color := $00282828;
      Font.Size := 8;
      Height := 13;
      Width := 60;
      Caption := 'Module Error';
      Transparent := True;
    end; // With
    lblModuleNumber := TLabel.Create(Self);
    with lblModuleNumber do
    begin
      Parent := Self;
      Left := 8;
      Top := 11;
      Font.Name := 'MS Sans Serif';
      Font.Color := clWhite;
      Font.Size := 8;
      Height := 13;
      Width := 78;
      Caption := 'Module Number:';
      Transparent := True;
    end; // With
    SetDigitalOutputLEDLabelWidth(FDigitalOutputLEDLabelWidth);
  end; // If
end; // TCompactLogix8ChRelayedDigitalOutputModule.Create

procedure TCompactLogix16ChDigitalOutputModule.BuildDigitalOutputLEDArrayVertical;
var
  i : LongInt;
  lRow : LongInt;
begin
  lRow := 0;
  for i := Low(FDigOutLEDArray) to High(FDigOutLEDArray) do
  begin
    if Not Assigned(FDigOutLEDArray[i]) then
      FDigOutLEDArray[i] := TDioLED.Create(Nil);
    with FDigOutLEDArray[i] do
    begin
      Parent := ParentModule;
      Top := 55 + (12 * lRow);
      Left := 5;
      Height := 10;
      Width := 10;
      Shape := stRoundRect;
      LitColor := clLime;
    end; // With
    if Not Assigned(FDigOutLabelArray[i]) then
      FDigOutLabelArray[i] := TLabel.Create(Nil);
    with FDigOutLabelArray[i] do
    begin
      Parent := ParentModule;
      Top := 55 + (12 * lRow);
      Left := 15;
      Font.Name := 'Terminal';
      Font.Size := 6;
      Font.Color := clWhite;
      Caption := FLEDLabels.Strings[i];
      Transparent := True;
      Height := 13;
      Width := FDigitalOutputLEDLabelWidth;
    end; // With
    inc(lRow);
  end; // For i
  ReSizeModuleDispaly;
end; // TCompactLogix16ChDigitalOutputModule.BuildDigitalOutputLEDArrayVertical

procedure TCompactLogix16ChDigitalOutputModule.SetModuleDrawType(Value : TModuleDrawType);
begin
  if (FModuleDrawType <> Value) then
  begin
    FModuleDrawType := Value;
    SetDigitalOutputLEDLabelWidth(FDigitalOutputLEDLabelWidth);
  end; // If
end; // TCompactLogix16ChDigitalOutputModule.SetModuleDrawType

procedure TCompactLogix16ChDigitalOutputModule.SetDigitalOutputLEDLabelWidth(Value : LongInt);
begin
  FDigitalOutputLEDLabelWidth := Value;
  case FModuleDrawType of
    Draw_H : BuildDigitalOutputLEDArrayHorizontal;
    Draw_V : BuildDigitalOutputLEDArrayVertical;
  end; // Case
end; // TCompactLogix16ChDigitalOutputModule.SetDigitalInputLEDLabelWidth

procedure TCompactLogix16ChDigitalOutputModule.BuildDigitalOutputLEDArrayHorizontal;
var
  i : LongInt;
  lRow : LongInt;
  lColumn : LongInt;
begin
  lRow := 0;
  lColumn := 0;
  for i := Low(FDigOutLEDArray) to High(FDigOutLEDArray) do
  begin
    if Not Assigned(FDigOutLEDArray[i]) then
      FDigOutLEDArray[i] := TDioLED.Create(Nil);
    with FDigOutLEDArray[i] do
    begin
      Parent := ParentModule;
      Top := 16 + (12 * lRow);
      Left := (LEDModuleError.Left + LEDModuleError.Width + 3) + (FDigitalOutputLEDLabelWidth * lColumn);
      Height := 10;
      Width := 10;
      Shape := stRoundRect;
      LitColor := clLime;
    end; // With
    if Not Assigned(FDigOutLabelArray[i]) then
      FDigOutLabelArray[i] := TLabel.Create(Nil);
    with FDigOutLabelArray[i] do
    begin
      Parent := ParentModule;
      Top := 17 + (12 * lRow);
      Left := (LEDModuleError.Left + LEDModuleError.Width + 3 + 12) + (FDigitalOutputLEDLabelWidth * lColumn);
      Font.Name := 'Terminal';
      Font.Size := 6;
      Font.Color := clWhite;
      Caption := FLEDLabels.Strings[i];
      Transparent := True;
      Height := 13;
      Width := FDigitalOutputLEDLabelWidth;
    end; // With
    inc(lRow);
    if (lRow > 3) then
    begin
      inc(lColumn);
      lRow := 0;
    end; // If
  end; // For i
  ReSizeModuleDispaly;
end; // TCompactLogix16ChDigitalOutputModule.BuildDigitalOutputLEDArrayHorizontal

procedure TCompactLogix16ChDigitalOutputModule.ReSizeModuleDispaly;
var
  TempVar : LongInt;
begin
  case FModuleDrawType of
    Draw_H : begin
               BaseModuleHeight := 70;
               BaseModuleWidth := FDigOutLabelArray[15].Left + FDigOutLabelArray[15].Width + 2;
             end; // If
    Draw_V : begin
               TempVar := FDigOutLabelArray[15].Left + FDigOutLabelArray[15].Width + 2;
               if (TempVar > (LEDModuleError.Left + LEDModuleError.Width)) then
                 BaseModuleWidth := FDigOutLabelArray[15].Left + FDigOutLabelArray[15].Width + 2
               else
                 BaseModuleWidth := LEDModuleError.Left + LEDModuleError.Width + 95;
               BaseModuleHeight := FDigOutLabelArray[15].Top + FDigOutLabelArray[15].Height + 2;
             end; // Draw_V
  end; // Case
end; // TCompactLogix16ChDigitalOutputModule.ReSizeModuleDisplay

procedure TCompactLogix16ChDigitalOutputModule.NewModuleData(Sender : TObject; Module : TDigitalOutputModule);
var
  i : Integer;
  lModuleFault : Boolean;
begin
  lModuleFault := False;
  with Module do
  begin
    if (ModuleNumber = FModulePosition) then
    begin
      LEDConnected.Lit := Not LEDConnected.Lit;
      BaseModuleCaption := ModuleString;
      lblModuleNumber.Caption := format('Module Number: %d',[ModuleNumber]);
      for i := 0 to High(FDigOutLEDArray) do
      begin
        FDigOutLEDArray[i].Lit := OutputData[i];
        lModuleFault := lModuleFault or Fault[i] or Fault[i + 1];
      end; // For i
      FModuleError := lModuleFault;
      LEDModuleError.Lit := FModuleError;
    end; // If
    if Assigned(FOnNewDigitalOutputData) then
      FOnNewDigitalOutputData(Self,Module);
  end; // With
end; // TCompactLogix16ChDigitalOutputModule.NewModuleData

function TCompactLogix16ChDigitalOutputModule.GetLEDLabels : TStringList;
begin
  Result := FLEDLabels;
end; // TCompactLogix16ChDigitalOutputModule.GetLEDLabels

procedure  TCompactLogix16ChDigitalOutputModule.SetLEDLabels(LEDLabels : TStringList);
var
  i : Integer;
begin
  FLEDLabels.Clear;
  for i := 0 to (LEDLabels.Count - 1) do
  begin
    if (i > High(FDigOutLabelArray)) then
      Break;
    FLEDLabels.Add(LEDLabels.Strings[i]);
    FDigOutLabelArray[i].Caption := FLEDLabels.Strings[i];
  end; // For i
end; // TCompactLogix16ChDigitalOutputModule.SetLEDLabels

destructor TCompactLogix16ChDigitalOutputModule.Destroy;
begin
  FLEDLabels.Free;
  inherited Destroy;
end; // TCompactLogix16ChDigitalOutputModule.Destroy

constructor TCompactLogix16ChDigitalOutputModule.Create(AOwner : TComponent);
var
  lFont : TFont;
  lPen : TPen;
  i : LongInt;
begin
  inherited Create(AOwner);
  FDigitalOutputLEDLabelWidth := 75;
  FModuleError := False;
  FLEDLabels := TStringList.Create;
  for i := Low(FDigOutLabelArray) to High(FDigOutLabelArray) do
    FLEDLabels.Add(format('Label %d',[i]));
  lFont := TFont.Create;
  with lFont do
  begin
    Color := clWhite;
    Name := 'MS Sans Serif';
    Size := 8;
    Style := [];
  end; // With
  lPen := TPen.Create;
  with lPen do
  begin
    Color := clBlack;
    Mode := pmCopy;
    Style := psSolid;
    Width := 1;
  end; // With
  if (csAcceptsControls in ParentModule.ControlStyle) then
  begin
    BaseModuleHeight := 53;
    BaseModuleWidth := 815;
    Font := lFont;
    BaseModuleCaption := '16 Channel Digital Output Module';
    LEDModuleError := TDioLed.Create(Self);
    with LEDModuleError do
    begin
      Parent := Self;
      Left := 8;
      Top := 25;
      LitColor := clRed;
      UnlitColor := clBlack;
      Height := 25;
      Width := 121;
      Pen.Color := clSilver;
      Pen.Mode := pmCopy;
      Pen.Style := psSolid;
      Pen.Width := 1;
      Shape := stRoundRect;
    end; // With
    lblModuleError := TLabel.Create(Self);
    with lblModuleError do
    begin
      Parent := Self;
      Left := 36;
      Top := 30;
      Font.Color := $00282828;
      Font.Size := 8;
      Height := 13;
      Width := 60;
      Caption := 'Module Error';
      Transparent := True;
    end; // With
    lblModuleNumber := TLabel.Create(Self);
    with lblModuleNumber do
    begin
      Parent := Self;
      Left := 8;
      Top := 11;
      Font.Name := 'MS Sans Serif';
      Font.Color := clWhite;
      Font.Size := 8;
      Height := 13;
      Width := 78;
      Caption := 'Module Number:';
      Transparent := True;
    end; // With
    SetDigitalOutputLEDLabelWidth(FDigitalOutputLEDLabelWidth);
  end; // If
end; // TCompactLogix16ChDigitalOutputModule.Create

procedure TCompactLogix8ChAnalogOuputModule.SetChannel(Index : Integer; Value : TAnalogChannel);
begin
  if (Index in [Low(FAnalogChannels)..High(FAnalogChannels)]) then
    FAnalogChannels[Index] := Value;
end; // TCustomPLCAnalogOutputMoudle.SetChannel

function TCompactLogix8ChAnalogOuputModule.GetChannel(Index : Integer) : TAnalogChannel;
begin
  if (Index in [Low(FAnalogChannels)..High(FAnalogChannels)]) then
    Result := FAnalogChannels[Index];
end; // TCustomPLCFAnalogOutputModule.GetChannel

procedure TCompactLogix8ChAnalogOuputModule.ButtonClick(Sender : TObject);
var
  myTag : Integer;
  Value : Integer;
begin
  myTag := (Sender as TButton).Tag;
  if (FAnalogChannels[myTag].MaxDCInputVolts > 0) then
    Value := Trunc((FInputFieldArray[myTag].AsFloat / FAnalogChannels[myTag].MaxDCInputVolts) * FAnalogChannels[myTag].MaxADRange)
  else
    Value := 0;
  if Assigned(FPLCController) and (myTag <= (FOutputTags.Count - 1)) then
    FPLCController.WriteToPLC(FOutputTags.Strings[myTag], 1, Value);
end; // TCompactLogix8ChAnalogOuputModule.ButtonClick

procedure TCompactLogix8ChAnalogOuputModule.InputFieldClick(Sender : TObject);
var
  i : Integer;
begin
  for i := 0 to 7 do
  begin
    FInputFieldArray[i].AsFloat := 0;
    FButtonArray[i].Click;
  end; // For i
end; // TCompactLogix8ChAnalogOuputModule.InputFieldClick

procedure TCompactLogix8ChAnalogOuputModule.SetOutputTags(OutputTags : TStringList);
var
  i : Integer;
begin
  FOutputTags.Clear;
  for i := 0 to (OutputTags.Count - 1) do
    FOutputTags.Add(OutputTags.Strings[i]);
end; // TCompactLogix8ChAnalogOuputModule.SetOutputTags

procedure TCompactLogix8ChAnalogOuputModule.SetInteractive(Value : Boolean);
var
  i : LongInt;
begin
  FInteractive := Value;
  btnZeroOutputs.Enabled := FInteractive;
  for i := Low(FInputFieldArray) to High(FInputFieldArray) do
    FInputFieldArray[i].Enabled := FInteractive;
  for i := Low(FButtonArray) to High(FButtonArray) do
    FButtonArray[i].Enabled := FInteractive;
end; // TCompactLogix8ChAnalogOuputModule.SetInteractive

procedure TCompactLogix8ChAnalogOuputModule.NewModuleData(Sender : TObject; Module : TAnalogOutputModule);
var
  i : Integer;
  lModuleFault : Boolean;
begin
  lModuleFault := False;
  with Module do
  begin
    if (ModuleNumber = FModulePosition) then
    begin
      LEDConnected.Lit := Not LEDConnected.Lit;
      BaseModuleCaption := ModuleString;
      lblModuleNumber.Caption := format('Module Number: %d',[ModuleNumber]);
      for i := Low(FAnalogChannels) to High(FAnalogChannels) do
      begin
        if (FAnalogChannels[i].MaxADRange > 0) then
          FAnalogChannels[i].Guage.value := (OutputData[i] / FAnalogChannels[i].MaxADRange) * FAnalogChannels[i].MaxDCInputVolts
        else
          FAnalogChannels[i].Guage.value := 0;
        FAnalogChannels[i].OverRange := OverRange[i];
        FAnalogChannels[i].UnderRange := UnderRange[i];
        FAnalogChannels[i].LEDUR.Lit := UnderRange[i];
        FAnalogChannels[i].LEDOR.Lit := OverRange[i];
        FAnalogChannels[i].Faulted := OverRange[i] or UnderRange[i] or HighAlarm[i] or LowAlarm[i];
        lModuleFault := lModuleFault or FAnalogChannels[i].Faulted;
      end; // For i
      FModuleError := lModuleFault;
      LEDModuleError.Lit := lModuleFault;
      if Assigned(FOnNewAnalogOutputData) then
        FOnNewAnalogOutputData(Self,Module);
    end; // If
  end; // With
end; // TCompactLogix8ChAnalogOuputModule.NewModuleData

destructor TCompactLogix8ChAnalogOuputModule.Destroy;
begin
  FOutputTags.Free;
  inherited Destroy;
end; // TCompactLogix8ChAnalogOuputModule.Destory

constructor TCompactLogix8ChAnalogOuputModule.Create(AOwner : TComponent);
var
  lFont : TFont;
  lPen : TPen;
  i : Integer;
  lGuageFont : TFont;
  myCount : Integer;
begin
  inherited Create(AOwner);
  FModuleError := False;
  FInteractive := True;
  if (csAcceptsControls in ParentModule.ControlStyle) then
  begin
    lGuageFont := TFont.Create;
    with lGuageFont do
    begin
      Name := 'Arial';
      Color := clBlack;
      Size := 8;
    end; // With
    lFont := TFont.Create;
    with lFont do
    begin
      Color := clWhite;
      Name := 'MS Sans Serif';
      Size := 8;
      Style := [];
    end; // With
    lPen := TPen.Create;
    with lPen do
    begin
      Color := clBlack;
      Mode := pmCopy;
      Style := psSolid;
      Width := 1;
    end; // With
    BaseModuleHeight := 158;
    BaseModuleWidth := 675;
    Font := lFont;
    BaseModuleCaption := '8 Channel Analog Output';
    LEDModuleError := TDioLED.Create(Self);
    with LEDModuleError do
    begin
      Parent := Self;
      Left := 8;
      Top := 130;
      LitColor := clRed;
      UnlitColor := clBlack;
      Height := 25;
      Width := 121;
      Pen.Color := clSilver;
      Pen.Mode := pmCopy;
      Pen.Style := psSolid;
      Pen.Width := 1;
      Shape := stRoundRect;
    end; // With
    lblModuleError := TLabel.Create(Self);
    with lblModuleError do
    begin
      Parent := Self;
      Left := 36;
      Top := 135;
      Font.Color := $00282828;
      Font.Size := 8;
      Height := 13;
      Width := 60;
      Caption := 'Module Error';
      Transparent := True;
    end; // With
    lblModuleNumber := TLabel.Create(Self);
    with lblModuleNumber do
    begin
      Parent := Self;
      Left := 8;
      Top := 20;
      Font.Name := 'MS Sans Serif';
      Font.Color := clWhite;
      Font.Size := 8;
      Height := 13;
      Width := 78;
      Caption := 'Module Number:';
      Transparent := True;
    end; // With
    btnZeroOutputs := TButton.Create(Self);
    with btnZeroOutputs do
    begin
      Parent := Self;
      Top := 36;
      Left := 8;
      Height := 25;
      Width := 121;
      Font.Name := 'MS Sans Serif';
      Font.Color := clBlack;
      Font.Size := 8;
      Caption := 'Zero Module Outputs';
      OnClick := InputFieldClick;
    end; // With
    FOutputTags := TStringList.Create;
    myCount := 0;
    for i := 0 to 7 do
    begin
      FDVMArray[i] := TDVM.create(Self);
      with FDVMArray[i] do
      begin
        Parent := Self;
        if (i = 0) then // Top Left Guage
        begin
          Top := 16;
          Left := 157;
        end; // If
        if (i = 4) then // Bottom Left Guage
        begin
          Top := 86;
          Left := 157;
        end; // If
        if (i < 4) then
        begin
          Top := FDVMArray[0].Top;
          Left := FDVMArray[0].Left + (i * 125);
        end
        else
        begin
          Top := FDVMArray[4].Top;
          Left := FDVMArray[4].Left + ((i - 4) * 125);
        end; // If
        Height := 47;
        Width := 125;
        font.Size := 10;
        font.Name := 'Arial';
        font.Style := [fsBold];
        font.Color := clBlack;
        UnitsFont := lGuageFont;
        TitleFont := lGuageFont;
        Units := 'Volts';
        Title := format('Channel %d',[i]);
      end; // With
      FInputFieldArray[i] := TOVCNumericField.Create(Self);
      with FInputFieldArray[i] do
      begin
        Parent := Self;
        if (i = 0) then
        begin
          Top := 64;
          Left := 157;
        end; // If
        if (i = 4) then
        begin
          Top := 134;
          Left := 157;
        end; // If
        if (i < 4) then
        begin
          Top := FInputFieldArray[0].Top;
          Left := FInputFieldArray[0].Left + (i * 125);
        end
        else
        begin
          Top := FInputFieldArray[4].Top;
          Left := FInputFieldArray[0].Left + ((i - 4) * 125)
        end; // If
        Height := 21;
        Width := 67;
        DataType := nftSingle;
        PictureMask := '##.###';
        RangeHi := '10';
        RangeLo := '-10';
        AsFloat := 0;
        Font := lFont;
        Font.Color := clBlack;
        Font.Style := [fsBold];
      end; // With
      FButtonArray[i] := TButton.Create(Self);
      with FButtonArray[i] do
      begin
        Parent := Self;
        if (i = 0) then
        begin
          Top := 64;
          Left := 225;
        end; // If
        if (i = 4) then
        begin
          Top := 134;
          Left := 225;
        end; // If
        if (i < 4) then
        begin
          Top := FButtonArray[0].Top;
          Left := FButtonArray[0].Left + (i * 125);
        end
        else
        begin
          Top := FButtonArray[4].Top;
          Left := FButtonArray[4].Left + ((i - 4) * 125);
        end; // If
        Height := 21;
        Width := 56;
        Font := lFont;
        Tag := i;
        Caption := format('Set Chan%d',[i]);
        OnClick := ButtonClick;
      end; // With
      FLabelArray[myCount] := TLabel.Create(FDVMArray[i]);
      with FLabelArray[myCount] do // Under Range Label
      begin
        Parent := FDVMArray[i];
        Top := 16;
        Left := 18;
        Font := lFont;
        Font.Color := clBlack;
        Caption := 'UR';
      end; // With
      FLabelArray[myCount + 1] := TLabel.Create(FDVMArray[i]);
      with FLabelArray[myCount + 1] do // Over Range Label
      begin
        Parent := FDVMArray[i];
        Top := 16;
        Left := 91;
        Font := lFont;
        Font.Color := clBlack;
        Caption := 'OR';
      end; // With
      FLEDArray[myCount] := TDioLED.Create(FDVMArray[i]);
      with FLEDArray[myCount] do // Under Range LED
      begin
        Parent := FDVMArray[i];
        Top := 16;
        Left := 5;
        Shape := stRoundRect;
      end; // With
      FLEDArray[myCount + 1] := TDioLED.Create(FDVMArray[i]);
      with FLEDArray[myCount + 1] do  // Over Range LED
      begin
        Parent := FDVMArray[i];
        Top := 16;
        Left := 107;
        Shape := stRoundRect;
      end; // With
      with FAnalogChannels[i] do
      begin
        Guage := FDVMArray[i];
        LEDUR := FLEDArray[myCount];
        LEDOR := FLEDarray[myCount + 1];
        Faulted := False;
        OverRange := False;
        UnderRange := False;
        MaxADRange := 0;
        MaxDCInputVolts := 0;
      end; // With
      myCount := myCount + 2;
    end; // For i
  end; // If
end; // TCompactLogix8ChAnalogOuputModule.Create

procedure TCompactLogix16ChDigitalInputModule.BuildDigitalInputLEDArrayVertical;
var
  i : LongInt;
  lRow : LongInt;
begin
  lRow := 0;
  for i := Low(FDigInLEDArray) to High(FDigInLEDArray) do
  begin
    if Not Assigned(FDigInLEDArray[i]) then
      FDigInLEDArray[i] := TDioLED.Create(Nil);
    with FDigInLEDArray[i] do
    begin
      Parent := ParentModule;
      Top := 55 + (12 * lRow);
      Left := 5;
      Height := 10;
      Width := 10;
      Shape := stRoundRect;
      LitColor := clLime;
    end; // With
    if Not Assigned(FDigInLabelArray[i]) then
      FDigInLabelArray[i] := TLabel.Create(Nil);
    with FDigInLabelArray[i] do
    begin
      Parent := ParentModule;
      Top := 55 + (12 * lRow);
      Left := 15;
      Font.Name := 'Terminal';
      Font.Size := 6;
      Font.Color := clWhite;
      Caption := FLEDLabels.Strings[i];
      Transparent := True;
      Height := 13;
      Width := FDigitalInputLEDLabelWidth;
    end; // With
    inc(lRow);
  end; // For i
  ReSizeModuleDispaly;
end; // TCompactLogix16ChDigitalInputModule.BuildDigitalInputLEDArrayHorizontal


procedure TCompactLogix16ChDigitalInputModule.SetModuleDrawType(Value : TModuleDrawType);
begin
  if (FModuleDrawType <> Value) then
  begin
    FModuleDrawType := Value;
    SetDigitalInputLEDLabelWidth(FDigitalInputLEDLabelWidth);
  end; // If
end; // TCompactLogix16ChDigitalInputModule.SetModuleDrawType

function TCompactLogix16ChDigitalInputModule.GetLEDLabels : TStringList;
begin
  Result := FLEDLabels;
end; // TCompactLogix16ChDigitalInputModule.GetLEDLabels

procedure TCompactLogix16ChDigitalInputModule.SetLEDLabels(LEDLabels : TStringList);
var
  i : Integer;
begin
  FLEDLabels.Clear;
  for i := 0 to (LEDLabels.Count - 1) do
  begin
    if (i > High(FDigInLabelArray)) then
      Break;
    FLEDLabels.Add(LEDLabels.Strings[i]);
    FDigInLabelArray[i].Caption := FLEDLabels.Strings[i];
  end; // For i
end; // TCompactLogix16ChDigitalInputModule.SetLEDLabels

destructor TCompactLogix16ChDigitalInputModule.Destroy;
begin
  FLEDLabels.Free;
  inherited Destroy;
end; // TCompactLogix16ChDigitalInputModule.Destroy

constructor TCompactLogix16ChDigitalInputModule.Create(AOwner : TComponent);
var
  lFont : TFont;
  lPen : TPen;
  i : LongInt;
begin
  inherited Create(AOwner);
  FModuleError := False;
  FDigitalInputLEDLabelWidth := 75;
  FLEDLabels := TStringList.Create;
  for i := Low(FDigInLabelArray) to High(FDigInLabelArray) do
    FLEDLabels.Add(format('Label %d',[i]));
  lFont := TFont.Create;
  with lFont do
  begin
    Color := clWhite;
    Name := 'MS Sans Serif';
    Size := 8;
    Style := [];
  end; // With
  lPen := TPen.Create;
  with lPen do
  begin
    Color := clBlack;
    Mode := pmCopy;
    Style := psSolid;
    Width := 1;
  end; // With
  if (csAcceptsControls in ParentModule.ControlStyle) then
  begin
    BaseModuleHeight := 53;
    BaseModuleWidth := 815;
    Font := lFont;
    BaseModuleCaption := '16 Channel Digital Input Module';
    LEDModuleError := TDioLed.Create(Self);
    with LEDModuleError do
    begin
      Parent := Self;
      Left := 8;
      Top := 25;
      LitColor := clRed;
      UnlitColor := clBlack;
      Height := 25;
      Width := 121;
      Pen.Color := clSilver;
      Pen.Mode := pmCopy;
      Pen.Style := psSolid;
      Pen.Width := 1;
      Shape := stRoundRect;
    end; // With
    lblModuleError := TLabel.Create(Self);
    with lblModuleError do
    begin
      Parent := Self;
      Left := 36;
      Top := 30;
      Font.Color := $00282828;
      Font.Size := 8;
      Height := 13;
      Width := 60;
      Caption := 'Module Error';
      Transparent := True;
    end; // With
    lblModuleNumber := TLabel.Create(Self);
    with lblModuleNumber do
    begin
      Parent := Self;
      Left := 8;
      Top := 11;
      Font.Name := 'MS Sans Serif';
      Font.Color := clWhite;
      Font.Size := 8;
      Height := 13;
      Width := 78;
      Caption := 'Module Number:';
      Transparent := True;
    end; // With
    SetDigitalInputLEDLabelWidth(FDigitalInputLEDLabelWidth);
  end; // If
end; // TCompactLogix16ChDigitalInputModule.Create

procedure TCompactLogix16ChDigitalInputModule.SetDigitalInputLEDLabelWidth(Value : LongInt);
begin
  FDigitalInputLEDLabelWidth := Value;
  case FModuleDrawType of
    Draw_H : BuildDigitalInputLEDArrayHorizontal;
    Draw_V : BuildDigitalInputLEDArrayVertical;
  end; // Case
end; // TCompactLogix16ChDigitalInputModule.SetDigitalInputLEDLabelWidth

procedure TCompactLogix16ChDigitalInputModule.BuildDigitalInputLEDArrayHorizontal;
var
  i : LongInt;
  lRow : LongInt;
  lColumn : LongInt;
begin
  lRow := 0;
  lColumn := 0;
  for i := Low(FDigInLEDArray) to High(FDigInLEDArray) do
  begin
    if Not Assigned(FDigInLEDArray[i]) then
      FDigInLEDArray[i] := TDioLED.Create(Nil);
    with FDigInLEDArray[i] do
    begin
      Parent := ParentModule;
      Top := 16 + (12 * lRow);
      Left := (LEDModuleError.Left + LEDModuleError.Width + 3) + (FDigitalInputLEDLabelWidth * lColumn);
      Height := 10;
      Width := 10;
      Shape := stRoundRect;
      LitColor := clLime;
    end; // With
    if Not Assigned(FDigInLabelArray[i]) then
      FDigInLabelArray[i] := TLabel.Create(Nil);
    with FDigInLabelArray[i] do
    begin
      Parent := ParentModule;
      Top := 17 + (12 * lRow);
      Left := (LEDModuleError.Left + LEDModuleError.Width + 3 + 12) + (FDigitalInputLEDLabelWidth * lColumn);
      Font.Name := 'Terminal';
      Font.Size := 6;
      Font.Color := clWhite;
      Caption := FLEDLabels.Strings[i];
      Transparent := True;
      Height := 13;
      Width := FDigitalInputLEDLabelWidth;
    end; // With
    inc(lRow);
    if (lRow > 3) then
    begin
      inc(lColumn);
      lRow := 0;
    end; // If
  end; // For i
  ReSizeModuleDispaly;
end; // TCompactLogix16ChDigitalInputModule.BuildDigitalInputLEDArrayHorizontal

procedure TCompactLogix16ChDigitalInputModule.ReSizeModuleDispaly;
var
  TempVar : LongInt;
begin
  case FModuleDrawType of
    Draw_H : begin
               BaseModuleHeight := 70;
               BaseModuleWidth := FDigInLabelArray[15].Left + FDigInLabelArray[15].Width + 2;
             end; // If
    Draw_V : begin
               TempVar := FDigInLabelArray[15].Left + FDigInLabelArray[15].Width + 2;
               if (TempVar > (LEDModuleError.Left + LEDModuleError.Width)) then
                 BaseModuleWidth := FDigInLabelArray[15].Left + FDigInLabelArray[15].Width + 2
               else
                 BaseModuleWidth := LEDModuleError.Left + LEDModuleError.Width + 95;
               BaseModuleHeight := FDigInLabelArray[15].Top + FDigInLabelArray[15].Left + 2;
             end; // Draw_V
  end; // Case
end; // TCompactLogix16ChDigitalInputModule.ReSizeModuleDisplay

procedure TCompactLogix16ChDigitalInputModule.NewModuleData(Sender : TObject; Module : TDigitalInputModule);
var
  i : Integer;
  lModuleFault : Boolean;
begin
  lModuleFault := False;
  with Module do
  begin
    if (ModuleNumber = FModulePosition) then
    begin
      LEDConnected.Lit := Not LEDConnected.Lit;
      BaseModuleCaption := ModuleString;
      lblModuleNumber.Caption := format('Module Number: %d',[ModuleNumber]);
      for i := 0 to High(FDigInLEDArray) do
      begin
        FDigInLEDArray[i].Lit := InputData[i];
        lModuleFault := lModuleFault or Fault[i] or Fault[i + 1];
      end; // For i
      FModuleError := lModuleFault;
      LEDModuleError.Lit := FModuleError;
      if Assigned(FOnNewDigitalInputData) then
        FOnNewDigitalInputData(Self,Module);
    end; // If
  end; // With
end; // TCompactLogix16ChDigitalInputModule.NewModuleData;

procedure TVirtualPLCBackPlane.NewPLCData(Sender : TObject; Modules : TModuleArray; ModuleTypes : TModuleType; ModuleCount : Integer);
var
  i : Integer;
  j : Integer;
  lAnalogInputModule : TAnalogInputModule;
  lAnalogOutputModule : TAnalogOutputModule;
  lDigitalInputModule : TDigitalInputModule;
  lDigitalOutputModule : TDigitalOutputModule;
  lRelayedDigitalOutputModule : TRelayedDigitalOutputModule;
  lDriveModule : TDriveModule;
  lProcessorModule : TProcessorModule;
begin
  for i := 0 to (ModuleCount - 1) do
  begin
    case ModuleTypes[i] of
      0 : begin
            lAnalogInputModule := Modules[i] as TAnalogInputModule;
            for j := 0 to FAIModules do
            begin
              if (lAnalogInputModule.ModuleNumber = FAnalogInputModules[j].ModulePosition) then
                FAnalogInputModules[j].NewModuleData(Self,lAnalogInputModule);
            end; // For j
          end; // 0
      1 : begin
            lAnalogOutputModule := Modules[i] as TAnalogOutputModule;
            for j := 0 to FAOModules do
            begin
              if (lAnalogOutputModule.ModuleNumber = FAnalogOutputModules[j].ModulePosition) then
                FAnalogOutputModules[j].NewModuleData(Self,lAnalogOutputModule);
            end; // For j
          end; // 0
      2 : begin
            lDigitalInputModule := Modules[i] as TDigitalInputModule;
            for j := 0 to FDIModules do
            begin
              if (lDigitalInputModule.ModuleNumber = FDigitalInputModules[j].ModulePosition) then
                FDigitalInputModules[j].NewModuleData(Self,lDigitalInputModule);
            end; // For j
          end; // 0
      3 : begin
            lDigitalOutputModule := Modules[i] as TDigitalOutputModule;
            for j := 0 to FDOModules do
            begin
              if (lDigitalOutputModule.ModuleNumber = FDigitalOutputModules[j].ModulePosition) then
                FDigitalOutputModules[j].NewModuleData(Self,lDigitalOutputModule);
            end; // For j
          end; // 0
      4 : begin
            lRelayedDigitalOutputModule := Modules[i] as TRelayedDigitalOutputModule;
            for j := 0 to FRDOModules do
            begin
              if (lRelayedDigitalOutputModule.ModuleNumber = FRelayedDigitalOutputModules[j].ModulePosition) then
                FRelayedDigitalOutputModules[j].NewModuleData(Self,lRelayedDigitalOutputModule);
            end; // For j
          end; // 0
      5 : begin
            lDriveModule := Modules[i] as TDriveModule;
            for j := 0 to FDrvModules do
            begin
              if (lDriveModule.ModuleNumber = FPowerFlex700DriveModules[j].ModulePosition) then
                FPowerFlex700DriveModules[j].NewModuleData(Self,lDriveModule);
            end; // For j
          end; // 0
      6 : begin
            lProcessorModule := Modules[i] as TProcessorModule;
            for j := 0 to FProcModules do
            begin
              if (lProcessorModule.ModuleNumber = FProcessorModules[j].ModulePosition) then
                FProcessorModules[j].NewModuleData(Self,lProcessorModule);
            end; // For j
          end; // 0
    end; // Case;
  end; // For i
end; // TVirtualPLCBackPlane.NewPLCData

procedure TVirtualPLCBackPlane.RemoveModuleFromBackPlane(Module : TCompactLogixBaseModule);
var
  i : Integer;
  j : Integer;
  TempProcessorModules : TProcessorModuleArray;
  TempAnalogInputModules : TAnalogInputModuleArray;
  TempAnalogOutputModules : TAnalogOutputModuleArray;
  TempDigitalInputModules : TDigitalInputModuleArray;
  TempDigitalOutputModules : TDigitalOutputModuleArray;
  TempRelayedDigitalOutputModules : TRelayedDigitalOutputModuleArray;
  TempPowerFlex700DriveModules : TVirtualDriveModuleArray;
begin
  if (Module is TCompactLogix8ChAnalogInputModule) then
  begin
    for i := 0 to FAIModules do
    begin
      TempAnalogInputModules := FAnalogInputModules;
      if (Module as TCompactLogix8ChAnalogInputModule).ModulePosition = TempAnalogInputModules[i].ModulePosition then
      begin
        TempAnalogInputModules[i].Connected := False;
        TempAnalogInputModules[i] := Nil;
        for j := i to (FAIModules - 1) do
        begin
          TempAnalogInputModules[j] := TempAnalogInputModules[j + 1];
          TempAnalogInputModules[j + 1] := Nil;
        end; // for j
        FAnalogInputModules := TempAnalogInputModules;
        dec(FAIModules);
        Break;
      end // If
    end; // For i
  end; // If
  if (Module is TCompactLogixProcessorModule) then
  begin
    for i := 0 to FProcModules do
    begin
      TempProcessorModules := FProcessorModules;
      if (Module as TCompactLogixProcessorModule).ModulePosition = TempProcessorModules[i].ModulePosition then
      begin
        TempProcessorModules[i].Connected := False;
        TempProcessorModules[i] := Nil;
        for j := i to FProcModules do
        begin
          TempProcessorModules[j] := TempProcessorModules[j + 1];
          TempProcessorModules[j + 1] := Nil;
        end; // for j
        FProcessorModules := TempProcessorModules;
        dec(FProcModules);
        Break;
      end // If
    end; // For i
  end; // If
  if (Module is TCompactLogix16ChDigitalInputModule) then
  begin
    for i := 0 to FDIModules do
    begin
      TempDigitalInputModules := FDigitalInputModules;
      if (Module as TCompactLogix16ChDigitalInputModule).ModulePosition = TempDigitalInputModules[i].ModulePosition then
      begin
        TempDigitalInputModules[i].Connected := False;
        TempDigitalInputModules[i] := Nil;
        for j := i to (FDIModules - 1) do
        begin
          TempDigitalInputModules[j] := TempDigitalInputModules[j + 1];
          TempDigitalInputModules[j + 1] := Nil;
        end; // for j
        FDigitalInputModules := TempDigitalInputModules;
        dec(FDIModules);
        Break;
      end // If
    end; // For i
  end; // If
  if (Module is TCompactLogix8ChAnalogOuputModule) then
  begin
    for i := 0 to FAOModules do
    begin
      TempAnalogOutPutModules := FAnalogOutputModules;
      if (Module as TCompactLogix8ChAnalogOuputModule).ModulePosition = TempAnalogOutputModules[i].ModulePosition then
      begin
        TempAnalogOutputModules[i].Connected := False;
        TempAnalogOutputModules[i] := Nil;
        for j := i to (FAOModules - 1) do
        begin
          TempAnalogOutputModules[j] := TempAnalogOutputModules[j + 1];
          TempAnalogOutputModules[j + 1] := Nil;
        end; // for j
        FAnalogOutputModules := TempAnalogOutputModules;
        dec(FAOModules);
        Break;
      end // If
    end; // For i
  end; // If
  if (Module is TCompactLogix16ChDigitalOutputModule) then
  begin
    for i := 0 to FDOModules do
    begin
      TempDigitalOutputModules := FDigitalOutputModules;
      if (Module as TCompactLogix16ChDigitalOutputModule).ModulePosition = TempDigitalOutputModules[i].ModulePosition then
      begin
        TempDigitalOutputModules[i].Connected := False;
        TempDigitalOutputModules[i] := Nil;
        for j := i to (FDOModules - 1) do
        begin
          TempDigitalOutputModules[j] := TempDigitalOutputModules[j + 1];
          TempDigitalOutputModules[j + 1] := Nil;
        end; // for j
        FDigitalOutputModules := TempDigitalOutputModules;
        dec(FDOModules);
        Break;
      end // If
    end; // For i
  end; // If
  if (Module is TCompactLogix8ChRelayedDigitalOutputModule) then
  begin
    for i := 0 to FRDOModules do
    begin
      TempRelayedDigitalOutputModules := FRelayedDigitalOutputModules;
      if (Module as TCompactLogix8ChRelayedDigitalOutputModule).ModulePosition = TempRelayedDigitalOutputModules[i].ModulePosition then
      begin
        TempRelayedDigitalOutputModules[i].Connected := False;
        TempRelayedDigitalOutputModules[i] := Nil;
        for j := i to (FRDOModules - 1) do
        begin
          TempRelayedDigitalOutputModules[j] := TempRelayedDigitalOutputModules[j + 1];
          TempRelayedDigitalOutputModules[j + 1] := Nil;
        end; // for j
        FRelayedDigitalOutputModules := TempRelayedDigitalOutputModules;
        dec(FRDOModules);
        Break;
      end // If
    end; // For i
  end; // If
  if (Module is TCompactLogixVirtualDriveModule) then
  begin
    for i := 0 to FDrvModules do
    begin
      TempPowerFlex700DriveModules := FPowerFlex700DriveModules;
      if (Module as TCompactLogixVirtualDriveModule).ModulePosition = TempPowerFlex700DriveModules[i].ModulePosition then
      begin
        TempPowerFlex700DriveModules[i].Connected := False;
        TempPowerFlex700DriveModules[i] := Nil;
        for j := i to (FDrvModules - 1) do
        begin
          TempPowerFlex700DriveModules[j] := TempPowerFlex700DriveModules[j + 1];
          TempPowerFlex700DriveModules[j + 1] := Nil;
        end; // for j
        FPowerFlex700DriveModules := TempPowerFlex700DriveModules;
        dec(FDrvModules);
        Break;
      end // If
    end; // For i
  end; // If
  FModulesInstalled := (FAIModules + 1) + (FProcModules + 1) + (FDIModules + 1) + (FAOModules + 1) + (FDOModules + 1) + (FRDOModules + 1) + (FDrvModules + 1);
end; // TVirtualPLCBackPlane.RemoveModuleFromBackPlane

procedure TVirtualPLCBackPlane.AddModuleToBackPlane(Module : TCompactLogixBaseModule);
begin
  if (Module is TCompactLogix8ChAnalogInputModule) then
  begin
    inc(FAIModules);
    FAnalogInputModules[FAIModules] := Module as TCompactLogix8ChAnalogInputModule;
    FAnalogInputModules[FAIModules].BackPlane := Self;
    FAnalogInputModules[FAIModules].Connected := True;
  end; // If
  if (Module is TCompactLogixProcessorModule) then
  begin
    inc(FProcModules);
    FProcessorModules[FProcModules] := Module as TCompactLogixProcessorModule;
    FProcessorModules[FProcModules].BackPlane := Self;
    FProcessorModules[FProcModules].PLCController := FPLCController;
  end; // If
  if (Module is TCompactLogix16ChDigitalInputModule) then
  begin
    inc(FDIModules);
    FDigitalInputModules[FDIModules] := Module as TCompactLogix16ChDigitalInputModule;
    FDigitalInputModules[FDIModules].BackPlane := Self;
    FDigitalInputModules[FDIModules].Connected := True;
  end; // If
  if (Module is TCompactLogix8ChAnalogOuputModule) then
  begin
    inc(FAOModules);
    FAnalogOutputModules[FAOModules] := Module as TCompactLogix8ChAnalogOuputModule;
    FAnalogOutputModules[FAOModules].BackPlane := Self;
    FAnalogOutputModules[FAOModules].Connected := True;
  end; // If
  if (Module is TCompactLogix16ChDigitalOutputModule) then
  begin
    inc(FDOModules);
    FDigitalOutputModules[FDOModules] := Module as TCompactLogix16ChDigitalOutputModule;
    FDigitalOutputModules[FDOModules].BackPlane := Self;
    FDigitalOutputModules[FDOModules].Connected := True;
  end; // If
  if (Module is TCompactLogix8ChRelayedDigitalOutputModule) then
  begin
    inc(FRDOModules);
    FRelayedDigitalOutputModules[FRDOModules] := Module as TCompactLogix8ChRelayedDigitalOutputModule;
    FRelayedDigitalOutputModules[FRDOModules].BackPlane := Self;
    FRelayedDigitalOutputModules[FRDOModules].Connected := True;
  end; // If
  if (Module is TCompactLogixVirtualDriveModule) then
  begin
    inc(FDrvModules);
    FPowerFlex700DriveModules[FDrvModules] := Module as TCompactLogixVirtualDriveModule;
    FPowerFlex700DriveModules[FDrvModules].BackPlane := Self;
    FPowerFlex700DriveModules[FDrvModules].Connected := True;
  end; // If
  FModulesInstalled := (FAIModules + 1) + (FProcModules + 1) + (FDIModules + 1) + (FAOModules + 1) + (FDOModules + 1) + (FRDOModules + 1) + (FDrvModules + 1);
end; // TVirtualPLCBackPlane.AddModuleToBackPlane

function TVirtualPLCBackPlane.GetPLCController : TCompactLogixPLC;
begin
  if Assigned(FPLCController) then
    Result := FPLCController
  else
    Result := Nil;
end; // TVirtualPLCBackPlane.GetPLCController

procedure TVirtualPLCBackPlane.SetPLCController(Controller : TCompactLogixPLC);
begin
  if (Controller <> Nil) then
  begin
    FPLCController := Controller;
    AssignControllerToModules;
    FPLCController.OnNewModuleData := NewPLCData;
  end; // If
end; // TVirtualPLCBackPlane.SetPLCController

destructor TVirtualPLCBackPlane.Destroy;
begin
  inherited Destroy;
end; // TVirtualPLCBackPlane.Destroy

constructor TVirtualPLCBackPlane.Create(AOwner : TComponent);
var
  i : Integer;
begin
  inherited Create(AOwner);
  FPLCController := Nil;
  FModulesInstalled := 0;
  FProcModules := -1;
  FAIModules := -1;
  FAOModules := -1;
  FDIModules := -1;
  FDOModules := -1;
  FRDOModules := -1;
  FDrvModules := -1;
  for i := 0 to MaximumModules do
  begin
    FProcessorModules[i] := Nil;
    FAnalogInputModules[i] := Nil;
    FAnalogInputModules[i] := Nil;                               
    FAnalogOutputModules[i] := Nil;
    FDigitalInputModules[i] := Nil;
    FDigitalOutputModules[i] := Nil;
    FRelayedDigitalOutputModules[i] := Nil;
    FPowerFlex700DriveModules[i] := Nil;
  end; // For i
end; // TVirtualPLCBackPlane.Create

procedure TVirtualPLCBackPlane.AssignControllerToModules;
var
  i : LongInt;
begin
  for i := Low(FProcessorModules) to High(FProcessorModules) do
  begin
    if Assigned(FProcessorModules[i]) then
      FProcessorModules[i].OnControllerAssigned(Self);
  end; // For i
  for i := Low(FAnalogInputModules) to High(FAnalogInputModules) do
  begin
    if Assigned(FAnalogInputModules[i]) then
      FAnalogInputModules[i].OnControllerAssigned(Self);
  end; // For i
  for i := Low(FAnalogOutputModules) to High(FAnalogOutputModules) do 
  begin
    if Assigned(FAnalogOutputModules[i]) then
      FAnalogOutputModules[i].OnControllerAssigned(Self);
  end; // For i
  for i := Low(FDigitalInputModules) to High(FDigitalInputModules) do
  begin
    if Assigned(FDigitalInputModules[i]) then
      FDigitalInputModules[i].OnControllerAssigned(Self);
  end; // For i
  for i := Low(FDigitalOutputModules) to High(FDigitalOutputModules) do
  begin
    if Assigned(FDigitalOutputModules[i]) then
      FDigitalOutputModules[i].OnControllerAssigned(Self);
  end; // For i
  for i := Low(FRelayedDigitalOutputModules) to High(FRelayedDigitalOutputModules) do
  begin
    if Assigned(FRelayedDigitalOutputModules[i]) then
      FRelayedDigitalOutputModules[i].OnControllerAssigned(Self);
  end; // For i
end; // TMicroLogixVirtualBackPlane.AssignControllerToModules

procedure TCompactLogixProcessorModule.RequestBitsClick(Sender: TObject);
begin
  if Not FPLCController.Enabled then
  begin
    clRequestBits.Selected[clRequestBits.ItemIndex] := False;
    Exit;
  end; // If
  if (FPLCTags.Strings[clRequestBits.ItemIndex] <> '') and (UpperCase(FPLCTags.Strings[clRequestBits.ItemIndex]) <> '[SKIP]') then
    FPLCController.WriteToPLC(Trim(FPLCTags.Strings[clRequestBits.ItemIndex]), 1, ord(clRequestBits.Selected[clRequestBits.ItemIndex]));
  if (clRequestBits.ItemIndex in FPulsedBits) and (clRequestBits.Selected[clRequestBits.ItemIndex]) then // Pulsed Bits
  begin
    FPLCController.WriteToPLC(Trim(FPLCTags.Strings[clRequestBits.ItemIndex]), 1, 0);
    clRequestBits.Selected[clRequestBits.ItemIndex] := False;
  end; // If
end; // TCompactLogixProcessorModule.RequestBitsClick

procedure TCompactLogixProcessorModule.SetKeySwitchPosition(Position : Integer);
begin
  case Position of
    1 : LEDKeySwitchPosition.LitColor := clLime;
    2 : LEDKeySwitchPosition.LitColor := clBlue;
    3 : LEDKeySwitchPosition.LitColor := clPurple;
  end; // Case
  LEDKeySwitchPosition.Lit := True;
end; // TCompactLogixProcessorModule.SetKeySwitchPosition;

procedure TCompactLogixProcessorModule.SetProcessorMode(Mode : Integer);
begin
  case Mode of
    6 : LEDProcessorMode.LitColor := clLime;
    7 : LEDProcessorMode.LitColor := clBlue;
  end; // Case
  LEDProcessorMode.Lit := True;
end; // TCompactLogixProcessorModule.SetProcessorMode

procedure TCompactLogixProcessorModule.SetForcesActive(Installed : Boolean; Enabled : Boolean);
begin
  if Installed and Enabled then
    LEDPLCForcesActive.LitColor := clRed
  else
    LEDPLCForcesActive.LitColor := clYellow;
  LEDPLCForcesActive.Lit := Installed or Enabled;
end; // TCompactLogixProcessorModule.SetForcesActive

procedure TCompactLogixProcessorModule.BuildRequestBitLEDArray;
var
  i : LongInt;
  j : LongInt;
  lRow : LongInt;
  lMaxRows : LongInt;
  lColumn : LongInt;
  lLEDCount : LongInt;
  lBinarySize : LongInt;
  lLabelNum : LongInt;
begin
  lRow := 0;
  lColumn := 0;
  lLabelNum := 0;
//  if Assigned(FPLCController) then
//    lBinarySize := FPLCController.BinarySize
//  else
    lBinarySize := {FBinaryElementCount}2;
  lLEDCount := (lBinarySize) * (High(RequestBitLEDArray[High(RequestBitLEDArray)]) + 1);
  lMaxRows := lLEDCount div 6;
  if ((13 + (lMaxRows + 1) * 13) < 54) then
    gbRequestBits.Height := 54
  else
    gbRequestBits.Height := (13 + (lMaxRows + 1) * 13);
  for i := Low(RequestBitLEDArray) to High(RequestBitLEDArray) do
  begin
    for j := Low(RequestBitLEDArray[i]) to High(RequestBitLEDArray[i]) do
    begin
      if (i < lBinarySize) then
      begin
        if Not Assigned(RequestBitLEDArray[i,j].LED) then
          RequestBitLEDArray[i,j].LED := TDioLED.Create(Nil);
        with RequestBitLEDArray[i,j].LED do
        begin
          Parent := gbRequestBits;
          Top := 15 + (12 * lRow);
          Left := 10 + (FRequestLEDLabelWidth * lColumn);
          Height := 10;
          Width := 10;
          Shape := stRoundRect;
          LitColor := clLime;
        end; // With
        if Not Assigned(RequestBitLEDArray[i,j].LEDLabel) then
          RequestBitLEDArray[i,j].LEDLabel := TLabel.Create(Nil);
        with RequestBitLEDArray[i,j].LEDLabel do
        begin
          Parent := gbRequestBits;
          Top := 17 + (12 * lRow);
          Left := 22 + (FRequestLEDLabelWidth * lColumn);
          Font.Name := 'Terminal';
          Font.Size := 6;
          Font.Color := clWhite;
          if (lLabelNum < FRequestBitLabels.Count) then
            Caption := format('%s',[FRequestBitLabels.Strings[lLabelNum]])
          else
            Caption := format('Label %d',[lLabelNum]);
          Transparent := True;
          Height := 13;
          Width := FRequestLEDLabelWidth;
        end; // With
        inc(lRow);
        if (lRow > lMaxRows) then
        begin
          inc(lColumn);
          lRow := 0;
        end; // If
        Inc(lLabelNum);
        if (lLabelNum = lLEDCount) then
          gbRequestBits.Width := RequestBitLEDArray[i,j].LEDLabel.Left + RequestBitLEDArray[i,j].LEDLabel.Width
      end
      else
      begin
        if Assigned(RequestBitLEDArray[i,j].LED) then
        begin
          RequestBitLEDArray[i,j].LED.Free;
          RequestbitLEDArray[i,j].LED := Nil;
        end; // If
        if Assigned(RequestBitLEDArray[i,j].LEDLabel) then
        begin
          RequestBitLEDArray[i,j].LEDLabel.Free;
          RequestBitLEDArray[i,j].LEDLabel := Nil;
        end; // If
      end; // If
    end; // For j
  end; // For j
  BuildRequestBitSelection;
end; // TCompactLogixProcessorModule.BuildRequestBitLEDArray

procedure TCompactLogixProcessorModule.BuildRequestBitSelection;
var
  i : LongInt;
  j : LongInt;
begin
  if Not Assigned(clRequestBits) then
    clRequestBits := TOvcBasicCheckList.Create(Nil);
  with clRequestBits do
  begin
    Parent := gbOutputBits;
    Height := 224;
    BoldX := True;
    BoxClickOnly := False;
    BoxFrameColor := clBlack;
    CheckXColor := clRed;
    WantDblClicks := False;
    Align := alClient;
    BorderStyle := bsNone;
    Color := clGray;
    Columns := 5;
    Ctl3D := False;
    ExtendedSelect := False;
    Font.Charset := ANSI_CHARSET;
    Font.Color := clWindowText;
    Font.Height := -11;
    Font.Name := 'Terminal';
    Font.Size := 7;
    Font.Style := [];
    IntegralHeight := True;
    ItemHeight := 16;
    MultiSelect := True;
    ParentCtl3D := False;
    ParentFont := False;
    OnClick := RequestBitsClick;
    Items := FRequestBitLabels;
  end; // With
  if gbOutputBits.Visible then
  begin
    gbOutputBits.Height := gbRequestBits.Height + 30;
    gbOutputBits.Width := gbRequestBits.Width;
  end; // If
end; // TCompactLogixProcessorModule.BuildRequestBitSelection

procedure TCompactLogixProcessorModule.ReSizeModuleDisplay;
var
  MaxWidth : LongInt;
begin
  if FInteractive then
    gbRequestBits.Top := gbOutputBits.Top + gbOutputBits.Height + 1
  else
    gbRequestBits.Top := gbOutputBits.Top;
  MaxWidth := gbOutputBits.Left + gbOutputBits.Width;
  if (gbRequestBits.Left + gbRequestBits.Width > MaxWidth) then
    MaxWidth := gbRequestBits.Left + gbRequestBits.Width;
  BaseModuleHeight := gbRequestBits.Top + gbRequestBits.Height + 3;
  BaseModuleWidth := MaxWidth + 3;
end; // TCompactLogixProcessorModule.ReSizeModuleDisplay

procedure TCompactLogixProcessorModule.ControllerAssigned(Sender : TObject);
begin
  BuildRequestBitLEDArray;
  ReSizeModuleDisplay;
end; // TCompactLogixProcessorModule.ControllerAssigned

procedure TCompactLogixProcessorModule.SetInteractive(Value : Boolean);
begin
  FInteractive := Value;
  gbOutputBits.Visible := FInteractive;
  ResizeModuleDisplay;
end; // TCompactLogixProcessorModule.SetInteractive

procedure TCompactLogixProcessorModule.SetRequestLEDLabelWidth(Value : LongInt);
begin
  FRequestLEDLabelWidth := Value;
  BuildRequestBitLEDArray;
  ReSizeModuleDisplay;
end; // TCompactLogixProcessorModule.SetRequestLEDLabelWidth

procedure TCompactLogixProcessorModule.NewModuleData(Sender : TObject; Module : TProcessorModule);
var
  i : Integer;
  j : Integer;
begin
  if Module.ModuleNumber = FModulePosition then
  begin
    with Module do
    begin
      LEDConnected.Lit := Not LEDConnected.Lit;
      BaseModuleCaption := ModuleString;
      lblModuleNumber.Caption := format('Module Number: %d',[ModuleNumber]);
      lblProcSerialNumber.Caption := format('Serial Number : %x',[Trunc(ProcessorSerialNumber)]);
      SetKeySwitchPosition(KeySwitchPosition);
      SetProcessorMode(ProcessorMode);
      SetForcesActive(ForcesInstalled,ForcesEnabled);
      LEDPLCBatteryOK.Lit := BatteryOk;
      LEDPLCFault.Lit := MinorFault > 0;
      FModuleError := LEDPLCFault.Lit;
      for i := Low(RequestBitLEDArray) to High(RequestBitLEDArray) do
      begin
        for j := Low(RequestBitLEDArray[i]) to High(RequestBitLEDArray[i]) do
          RequestBitLEDArray[i,j].LED.Lit := Request_Bits_Status[i,j];
      end; // For i
    end; // With
    if Assigned(FOnNewProcessorData) then
      FOnNewProcessorData(Self,Module);
  end; // If
end; // TCompactLogixProcessorModule.NewModuleData;

procedure TCompactLogixProcessorModule.SetPLCTags(PLCTags : TStringList);
var
  i : Integer;
begin
  FPLCTags.Clear;
  for i := 0 to (PLCTags.Count - 1) do
    FPLCTags.Add(PLCTags.Strings[i]);
end; // TCompactLogixProcessorModule.SetPLCTags

function TCompactLogixProcessorModule.GetLEDLabels : TStringList;
begin
  Result := FRequestBitLabels;
end; // TCompactLogix16ChDigitalInputModule.GetLEDLabels

procedure TCompactLogixProcessorModule.SetLEDLabels(LEDLabels : TStringList);
var
  i : Integer;
  TempLabel : TLabel;
begin
  FRequestBitLabels.Clear;
  for i := 0 to (LEDLabels.Count - 1) do
  begin
    FRequestBitLabels.Add(LEDLabels.Strings[i]);
    TempLabel := RequestBitLEDArray[(i div 32),(i- ((i div 32) * 32))].LEDLabel;
    if Assigned(TempLabel) then
      TempLabel.Caption := FRequestBitLabels.Strings[i];
  end; // For i
  clRequestBits.Items := FRequestBitLabels;
end; // TCompactLogixProcessorModule.SetLEDLabels

constructor TCompactLogixProcessorModule.Create(AOwner : TComponent);
var
  i : Integer;
  lFont : TFont;
  lPen : TPen;
  lRow : Integer;
  lColumn : Integer;
begin
  inherited Create(AOwner);
  FillChar(FPulsedBits,SizeOf(FPulsedBits),#0);
  FModuleError := False;
  FBinaryElementCount := 1;
  FInteractive := True;
  FRequestLEDLabelWidth := 111;
  FRequestBitLabels := TStringList.Create;
  for i := 0 to 63 do
    FRequestBitLabels.Add(format('Label %d',[i]));
  FPLCTags := TStringList.Create;
  lFont := TFont.Create;
  with lFont do
  begin
    Color := clWhite;
    Name := 'MS Sans Serif';
    Size := 8;
    Style := [];
  end; // With
  if (csAcceptsControls in ParentModule.ControlStyle) then
  begin
    OnControllerAssigned := ControllerAssigned;
    Height := 347;
    Width := 817;
    Color := clBlue;
    Font := lFont;
    BaseModuleCaption := 'Processor Module';
    lPen := TPen.Create;
    with lPen do
    begin
      Color := clBlack;
      Mode := pmCopy;
      Style := psSolid;
      Width := 1;
    end; // With
    lblModuleNumber := TLabel.Create(Self);
    with lblModuleNumber do
    begin
      Parent := Self;
      Top := 12;
      Left := 8;
      Height := 13;
      Width := 81;
      AutoSize := True;
      Transparent := True;
      Font := lFont;
      Caption := 'Module Number:';
    end; // With
    lblProcSerialNumber := TLabel.Create(Self);
    with lblProcSerialNumber do
    begin
      Parent := Self;
      Top := 24;
      Left := 8;
      Height := 13;
      Width := 119;
      AutoSize := True;
      Transparent := True;
      Font := lFont;
      Caption := 'Serial Number:';
    end; // With
    lblKeySWPos := TLabel.Create(Self);
    LEDKeySwitchPosition := TDioLed.Create(Self);
    with LEDKeySwitchPosition do
    begin
      Parent := Self;
      Top := 11;
      Left := 211;
      Height := 26;
      Width := 72;
      Pen := lPen;
      LitColor := clLime;
      UnlitColor := clBlack;
      Shape := stRoundRect;
    end; // With
    LEDProcessorMode := TDioLED.Create(Self);
    with LEDProcessorMode do
    begin
      Parent := Self;
      Top := 11;
      Left := 284;
      Height := 26;
      Width := 72;
      Pen := lPen;
      LitColor := clLime;
      UnlitColor := clBlack;
      Shape := stRoundRect
    end; // With
    LEDPLCFault := TDioLED.Create(Self);
    with LEDPLCFault do
    begin
      Parent := Self;
      Top := 11;
      Left := 357;
      Height := 26;
      Width := 72;
      Pen := lPen;
      LitColor := clRed;
      UnlitColor := clBlack;
      Shape := stRoundRect
    end; // With
    LEDPLCBatteryOK := TDioLED.Create(Self);
    with LEDPLCBatteryOK do
    begin
      Parent := Self;
      Top := 11;
      Left := 430;
      Height := 26;
      Width := 72;
      Pen := lPen;
      LitColor := clLime;
      UnlitColor := clBlack;
      Shape := stRoundRect
    end; // With
    LEDPLCForcesActive := TDioLED.Create(Self);
    with LEDPLCForcesActive do
    begin
      Parent := Self;
      Top := 11;
      Left := 503;
      Height := 26;
      Width := 72;
      Pen := lPen;
      LitColor := clRed;
      UnlitColor := clBlack;
      Shape := stRoundRect
    end; // With
    cbWatchDog := TCheckBox.Create(Self);
    with cbWatchDog do
    begin
      Parent := Self;
      Top := 18;
      Left := 578;
      Height := 13;
      Width := 110;
      Caption := 'Enable Watchdog';
      Font := lFont;
      OnClick := chWatchDogClick;
    end; // With
    with lblKeySWPos do
    begin
      Parent := Self;
      Top := 18;
      Left := 213;
      Height := 13;
      Width := 68;
      Caption := 'Key SW Pos';
      AutoSize := True;
      Transparent := True;
      Font := lFont;
      Font.Color := $00282828;
      Font.Style := [fsBold];
    end; // With
    lblProcMode := TLabel.Create(Self);
    with lblProcMode do
    begin
      Parent := Self;
      Top := 11;
      Left := 294;
      Height := 26;
      Width := 58;
      Caption := 'PLC Proc Mode';
      Alignment := taCenter;
      Transparent := True;
      WordWrap := True;
      Font := lFont;
      Font.Color := $00282828;
      Font.Style := [fsBold];
      AutoSize := True;
    end; // With
    lblProcFault := TLabel.Create(Self);
    with lblProcFault do
    begin
      Parent := Self;
      Top := 18;
      Left := 366;
      Height := 13;
      Width := 56;
      Caption := 'PLC Fault';
      Transparent := True;
      Font := lFont;
      Font.Color := $00282828;
      Font.Style := [fsBold];
      AutoSize := True;
    end; // With
    lblProcBattery := TLabel.Create(Self);
    with lblProcBattery do
    begin
      Parent := Self;
      Top := 11;
      Left := 432;
      Height := 26;
      Width := 100;
      Caption := 'PLC Battery OK';
      Alignment := taCenter;
      Transparent := True;
      WordWrap := True;
      Font := lFont;
      Font.Color := $00282828;
      Font.Style := [fsBold];
      AutoSize := True;
    end; // With
    lblProcForces := TLabel.Create(Self);
    with lblProcForces do
    begin
      Parent := Self;
      Top := 11;
      Left := 505;
      Height := 26;
      Width := 66;
      Caption := 'PLC Forces Active';
      Alignment := taCenter;
      Transparent := True;
      WordWrap := True;
      Font := lFont;
      Font.Color := $00282828;
      Font.Style := [fsBold];
      AutoSize := True;
    end; // With
    gbOutputBits := TGroupBox.Create(Self);
    with gbOutputBits do
    begin
      Parent := Self;
      Top := 38;
      Left := 3;
      Height := 150;
      Width := 811;
      Color := clGray;
      Font := lFont;
      Caption := 'Request PLC Output Change:';
    end; // With
    gbRequestBits := TGroupBox.Create(Self);
    with gbRequestBits do
    begin
      Parent := Self;
      Top := gbOutputBits.Top;
      Left := gbOutputBits.Left;
      Height := 150;
      Width := 804;
      Color := clBlue;
      Font := lFont;
      Caption := 'Request Bits:';
    end; // With
    clRequestBits := TOvcBasicCheckList.Create(gbOutputBits);
    with clRequestBits do
    begin
      Parent := gbOutputBits;
      Left := 1;
      Top := 15;
      Width := 150;
      Height := 224;
      BoldX := True;
      BoxClickOnly := False;
      BoxFrameColor := clBlack;
      CheckXColor := clRed;
      WantDblClicks := False;
      Align := alClient;
      BorderStyle := bsNone;
      Color := clGray;
      Columns := 5;
      Ctl3D := False;
      ExtendedSelect := False;
      Font.Charset := ANSI_CHARSET;
      Font.Color := clWindowText;
      Font.Height := -11;
      Font.Name := 'Terminal';
      Font.Size := 7;
      Font.Style := [];
      IntegralHeight := True;
      ItemHeight := 16;
      MultiSelect := True;
      ParentCtl3D := False;
      ParentFont := False;
      OnClick := RequestBitsClick;
    end; // With
//    BuildRequestBitLEDArray;
    ReSizeModuleDisplay;
  end; // If
end; // TCompactLogixProcessorModule.Create

procedure TCompactLogixProcessorModule.chWatchDogClick(Sender : TObject);
begin
  if Assigned(FPLCController) then
    FPLCController.EnableWatchDog := cbWatchDog.Checked
  else
    cbWatchDog.Checked := False;
end; // TCompactLogixProcessorModule.chWatchDogClick

destructor TCompactLogixProcessorModule.Destroy;
begin
  FRequestBitLabels.Free;
  FPLCTags.Free;
  inherited Destroy;
end; // TCompactLogixProcessorModule.Destroy

procedure TCompactLogix8ChAnalogInputModule.SetChannel(Index : Integer; Value : TAnalogChannel);
begin
  if (Index in [Low(FAnalogChannels)..High(FAnalogChannels)]) then
    FAnalogChannels[Index] := Value;
end; // TCustomPLCAIMoudle.SetChannel

function TCompactLogix8ChAnalogInputModule.GetChannel(Index : Integer) : TAnalogChannel;
begin
  if (Index in [Low(FAnalogChannels)..High(FAnalogChannels)]) then
    Result := FAnalogChannels[Index];
end; // TCompactLogix8ChAnalogInputModule.GetChannel

procedure TCompactLogix8ChAnalogInputModule.NewModuleData(Sender : TObject; Module : TAnalogInputModule);
var
  i : Integer;
  lModuleFault : Boolean;
begin
  lModuleFault := False;
  with Module do
  begin
    if ModuleNumber = FModulePosition then
    begin
      LEDConnected.Lit := Not LEDConnected.Lit;
      BaseModuleCaption := ModuleString;
      lblAnlgInModuleNum.Caption := format('Module Number: %d',[ModuleNumber]);
      for i := 0 to 7 do
      begin
        if (FAnalogChannels[i].MaxADRange > 0) then
          FAnalogChannels[i].Guage.value := (InputData[i] / FAnalogChannels[i].MaxADRange) * FAnalogChannels[i].MaxDCInputVolts
        else
          FAnalogChannels[i].Guage.Value := 0;
        FAnalogChannels[i].OverRange := OverRange[i];
        FAnalogChannels[i].UnderRange := UnderRange[i];
        FAnalogChannels[i].LEDOR.Lit := OverRange[i];
        FAnalogChannels[i].LEDUR.Lit := UnderRange[i];
        FAnalogChannels[i].Faulted := OverRange[i] or UnderRange[i] or HighAlarm[i] or LowAlarm[i];
        lModuleFault := lModuleFault or FAnalogChannels[i].Faulted;
      end; // For i
      FModuleError := lModuleFault;
      LEDAnlgInError.Lit := FModuleError;
      if Assigned(FOnNewAnalogInputModuleData) then
        FOnNewAnalogInputModuleData(Self,Module);
    end; // If
  end; // With
end; // TCompactLogix8ChAnalogInputModule.NewModuleData

destructor TCompactLogix8ChAnalogInputModule.Destroy;
begin
  inherited Destroy;
end; // TCompactLogix8ChAnalogInputModule.Destroy

constructor TCompactLogix8ChAnalogInputModule.Create(AOwner : TComponent);
var
  i : Integer;
  lGuageFont : TFont;
  llblFont : TFont;
  myCount : Integer;
begin
  inherited Create(AOwner);
  myCount := 0;
  FModuleError := False;
  if (csAcceptsControls in ParentModule.ControlStyle) then
  begin
    BaseModuleHeight := 114;
    BaseModuleWidth := 775;
    BaseModuleCaption := '8 Channel Analog Input Module';
    Font.Color := clWhite;
    Font.Name := 'MS Sans Serif';
    lGuageFont := TFont.Create;
    with lGuageFont do
    begin
      Name := 'Arial';
      Color := clBlack;
      Size := 8;
    end; // With
    llblFont := TFont.Create;
    with llblFont do
    begin
      Name := 'Arial';
      Color := clBlack;
      Size := 8;
    end; // With
    LEDAnlgInError := TDioLed.Create(Self);
    with LEDAnlgInError do
    begin
      Parent := Self;
      Left := 8;
      Top := 33;
      LitColor := clRed;
      UnlitColor := clBlack;
      Height := 25;
      Width := 121;
      Pen.Color := clSilver;
      Pen.Mode := pmCopy;
      Pen.Style := psSolid;
      Pen.Width := 1;
      Shape := stRoundRect;
    end; // With
    lblModuleError := TLabel.Create(Self);
    with lblModuleError do
    begin
      Parent := Self;
      Left := 36;
      Top := 38;
      Font.Color := $00282828;
      Font.Size := 8;
      Height := 13;
      Width := 60;
      Caption := 'Module Error';
      Transparent := True;
    end; // With
    lblAnlgInModuleNum := TLabel.Create(Self);
    with lblAnlgInModuleNum do
    begin
      Parent := Self;
      Left := 8;
      Top := 20;
      Font.Name := 'MS Sans Serif';
      Font.Color := clWhite;
      Font.Size := 8;
      Height := 13;
      Width := 78;
      Caption := 'Module Number:';
      Transparent := True;
    end; // With
    for i := 0 to 7 do
    begin
      FDVMArray[i] := TDVM.create(Self);
      FLabelArray[myCount] := TLabel.Create(FDVMArray[i]);
      with FLabelArray[myCount] do // Under Range Label
      begin
        Parent := FDVMArray[i];
        Top := 16;
        Left := 20;
        Font := llblFont;
        Caption := 'UR';
      end; // With
      FLabelArray[myCount + 1] := TLabel.Create(FDVMArray[i]);
      with FLabelArray[myCount + 1] do // Over Range Label
      begin
        Parent := FDVMArray[i];
        Top := 16;
        Left := 91;
        Font := llblFont;
        Caption := 'OR';
      end; // With
      FLEDArray[myCount] := TDioLED.Create(FDVMArray[i]);
      with FLEDArray[myCount] do // Under Range LED
      begin
        Parent := FDVMArray[i];
        Top := 16;
        Left := 5;
        Shape := stRoundRect;
      end; // With
      FLEDArray[myCount + 1] := TDioLED.Create(FDVMArray[i]);
      with FLEDArray[myCount + 1] do  // Over Range LED
      begin
        Parent := FDVMArray[i];
        Top := 16;
        Left := 107;
        Shape := stRoundRect;
      end; // With
      with FAnalogChannels[i] do
      begin
        Guage := FDVMArray[i];
        Guage.Parent := Self;
        LEDUR := FLEDArray[myCount];
        LEDOR := FLEDArray[myCount + 1];
        if (i = 0) then // Anchor DVM 1st row
        begin
          Guage.Top := 16;
          Guage.Left := 134;
        end
        else
        begin
          if (i = 5) then // Anchor DVM 2nd row
          begin
            Guage.Top := 64;
            Guage.Left := 259;
          end
          else
          begin
            if (i < 5) then
            begin
              Guage.Top := FDVMArray[0].Top;
              Guage.Left := FDVMArray[0].Left + (i * 125);
            end
            else
            begin
              Guage.Top := FDVMArray[i - 1].Top;
              Guage.Left := FDVMArray[i - 1].Left + 125;
            end; // If
          end; // If
        end; // If
        Guage.Title := format('Channel %d',[i]);
        Guage.font := lGuageFont;
        Guage.font.Size := 10;
        Guage.font.Style := [fsBold];
        Guage.TitleFont := lGuageFont;
        Guage.UnitsFont := lGuageFont;
        Guage.Height := 47;
        Guage.Width := 125;
        Faulted := False;
        OverRange := False;
        UnderRange := False;
      end; // With
      myCount := myCount + 2;
    end; // For i
  end; // If
end; // TCompactLogix8ChAnalogInputModule.Create

end.
