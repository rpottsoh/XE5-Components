{$DEFINE TMicroLogixPLC} // Define this is you are using TMicroLogixPLC instead of TPLCMonitor
unit MicroLogixPLCModules;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, stdctrls, DVM, DIOCtrl, ovclb, ovcbcklb, ovcbase,
  ovcef, ovcpb, ovcnf,
  {$IFNDEF TMicroLogixPLC}
  PLCMonitor;
  {$ELSE}
  MicroLogixComms;
  {$ENDIF}

  type
  TOnNewAnalogInputData = procedure(Sender : TObject; Module : TAnalogInputModule) of Object;
  TOnNewRTDAnalogInputData = procedure(Sender : TObject; Module : TRTDAnalogInputModule) of Object;
  TOnNewProcessorData = procedure(Sender : TObject; Module : TPLCMainModule) of Object;
  TOnNewDigitalInputData = procedure(Sender : TObject; Module : TDigitalInputModule) of Object;
  TOnNewAnalogOutputData = procedure(Sender : TObject; Module : TAnalogOutputModule) of Object;
  TOnNewDigitalOutputData = procedure(Sender : TObject; Module : TDigitalOutputModule) of Object;
  TOnNewRelayedDigitalOutputData = procedure(Sender : TObject; Module : TRelayedDigitalOutputModule) of Object;

  TAnalogChannel = record
                     Guage : TDVM;
                     LEDUR : TDioLED;
                     LEDOR : TDioLED;
                     Faulted : Boolean;
                     OverRange : Boolean;
                     UnderRange : Boolean;
                     AtoDRange : SmallInt;
                     Scale : Double;
  end; // TAnalogChannel (Size = 24)

  TRTDAnalogChannel = record
                        Guage       : TDVM;
                        LEDUROR     : TDioLED;   // Under-range or Over-range LED
                        LEDOC       : TDioLED;   // Open Circuit LED
                        LabelUROR   : TLabel;    // Label that defines LED as Under-range, Over-range or blank (initial condition)
                        Faulted     : Boolean;   // Channel faulted status
                        OverRange   : Boolean;   // Over-range status
                        UnderRange  : Boolean;   // Under-range status
                        OpenCircuit : Boolean;   // Open circuit status
                        AtoDRange   : SmallInt;
                        Scale       : Double;
  end; // TRTDAnalogChannel (Size = 30)

  TAnalogInputChannel = record
                          AnalogChannel : TAnalogChannel;
  end; // TAnalogInputChannel

  TRTDAnalogInputChannel = record
                          RTDAnalogChannel : TRTDAnalogChannel;
  end; // TRTDAnalogInputChannel

  TAnalogOutputChannel = record
                           AnalogChannel : TAnalogChannel;
                           InputField : TOvcNumericField;
                           InputButton : TButton;
  end; // TAnalogOutputChannel

  TIndicator = record
                 LED : TDioLED;
                 LEDLabel : TLabel;
  end; // TIndicator

  TMicroLogixVirtualBackPlane = class;
  TPulsedBits = Set of Byte;

  TBaseModule = class(TGroupBox)
    LEDConnected : TDioLED;
  private
    {Private Declarations}
    FControllerAssigned : TNotifyEvent;
    FParent : TWinControl;
    FPLCBackPlane : TMicroLogixVirtualBackPlane;
    {$IFNDEF TMicroLogixPLC}
    FPLCController : TPLCMonitor;
    {$ELSE}
    FPLCController : TMicroLogixPLC;
    {$ENDIF}
    FModulePosition : LongInt;
    FConnected : Boolean;
    {$IFNDEF TMicroLogixPLC}
    procedure SetPLCController(Controller : TPLCMonitor);
    function GetPLCController : TPLCMonitor;
    {$ELSE}
    procedure SetPLCController(Controller : TMicroLogixPLC);
    function GetPLCController : TMicroLogixPLC;
    {$ENDIF}
    procedure SetBackPlane(BackPlane : TMicroLogixVirtualBackPlane);
    function GetBackPlane : TMicroLogixVirtualBackPlane;
    procedure SetConnected(Value : Boolean);
    function GetConnected : Boolean;
    function GetWidth : LongInt;
    procedure SetWidth(Value : LongInt);
    function GetBaseModuleCaption : String;
    procedure SetBaseModuleCaption(Value : String);
  protected
    {Protected Declarations}
  public
    {Public Declarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    property ParentModule : TWinControl read FParent;
    property BaseModuleWidth : LongInt read GetWidth write SetWidth;
    property BaseModuleCaption : String read GetBaseModuleCaption write SetBaseModuleCaption;
    {$IFNDEF TMicroLogixPLC}
    property PLCController : TPLCMonitor read GetPLCController write SetPLCController;
    {$ELSE}
    property PLCController : TMicroLogixPLC read GetPLCController write SetPLCController;
    {$ENDIF}
    property BackPlane : TMicroLogixVirtualBackPlane read GetBackPlane write SetBackPlane;
    property Connected : Boolean read GetConnected write SetConnected;
    property ModulePosition : LongInt read FModulePosition write FModulePosition default -1;
    property OnControllerAssigned : TNotifyEvent read FControllerAssigned write FControllerAssigned;
  end; // TBaseModule

  TMicroLogixProcessor = class(TBaseModule)
    lblModulePosition : TLabel;
    lblErrorCode : TLabel;
    LEDProcessorMode : TDioLED;
    lblProcessorMode : TLabel;
    {$IFDEF TMicroLogixPLC}
    LEDKeySwithMode : TDioLED;
    lblKeySwitchMode : TLabel;
    {$ENDIF}
    LEDForcedIO : TDioLED;
    lblForcedIO : TLabel;
    LEDControlRegisterError : TDioLED;
    lblControlRegisterError : TLabel;
    LEDBatteryOK : TDioLED;
    lblBatteryOK : TLabel;
    gbRequestBits : TGroupBox;
    gbDigitalInputs : TGroupBox;
    gbDigitalOutputs : TGroupBox;
    gbOutputBits : TGroupBox;
    clRequestBits : TOvcBasicCheckList;
    chbWatchDog : TCheckBox;
  private
    FOnNewModuleData : TOnNewProcessorData;
    RequestBitLEDArray : Array[0..9,0..15] of TIndicator;
    DigitalInputLEDArray : Array[0..1,0..15] of TIndicator;
    DigitalOutputLEDArray : Array[0..1,0..15] of TIndicator;
    AnalogInputDVMArray : Array[0..3] of TAnalogInputChannel;
    AnalogOutputDVMArray : Array[0..1] of TAnalogOutputChannel;
    FPulsedBits : TPulsedBits;
    FInteractive : Boolean;
    FBinaryElementCount : LongInt;
    FRequestLEDLabelWidth : LongInt;
    FDigitalInputLEDLabelWidth : LongInt;
    FDigitalOutputLEDLabelWidth : LongInt;
    procedure InputFieldClick(Sender : TObject);
    procedure ButtonClick(Sender : TObject);
    procedure RequestBitsClick(Sender : TObject);
    procedure chbWatchDogClick(Sender : TObject);
    function GetAnalogInputChannel(Channel : LongInt) : TAnalogInputChannel;
    procedure SetAnalogInputChannel(Channel : LongInt; NewConfig : TAnalogInputChannel);
    function GetAnalogOutputChannel(Channel : LongInt) : TAnalogOutputChannel;
    procedure SetAnalogOutputChannel(Channel : LongInt; NewConfig : TAnalogOutputChannel);
    function GetRequestBitCaption(WordNumber, BitNumber : LongInt) : String;
    procedure SetRequestBitCaption(WordNumber,BitNumber : LongInt; Caption : String);
    function GetDigitalInputBitCaption(WordNumber, BitNumber : LongInt) : String;
    procedure SetDigitalInputBitCaption(WordNumber,BitNumber : LongInt; Caption : String);
    function GetDigitalOutputBitCaption(WordNumber, BitNumber : LongInt) : String;
    procedure SetDigitalOutputBitCaption(WordNumber,BitNumber : LongInt; Caption : String);
    procedure SetInteractive(Value : Boolean);
    procedure SetBinaryElementCount(Value : LongInt);
    procedure SetRequestLEDLabelWidth(Value : LongInt);
    procedure SetDigitalInputLEDLabelWidth(Value : LongInt);
    procedure SetDigitalOutputLEDLabelWidth(Value : LongInt);
    {Private Declarations}
  protected
    {Protected Declarations}
    procedure BuildRequestBitLEDArray;
    procedure BuildDigitalInputLEDArray;
    procedure BuildDigitalOutputLEDArray;
    procedure BuildAnalogInputArray;
    procedure BuildAnalogOutputArray;
    procedure BuildRequestBitSelection;
    procedure ReSizeModuleDisplay;
    procedure ControllerAssigned(Sender : TObject);
  public
    {Public Declarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TPLCMainModule);
    property PulsedBits : TPulsedBits read FPulsedBits write FPulsedBits;
    property RequestBitCaptions[WordNumber, BitNumber : LongInt] : String read GetRequestBitCaption write SetRequestBitCaption;
    property DigitalInputCaptions[WordNumber, BitNumber : LongInt] : String read GetDigitalInputBitCaption write SetDigitalInputBitCaption;
    property DigitalOutputCaptions[WordNumber, BitNumber : LongInt] : String read GetDigitalOutputBitCaption write SetDigitalOutputBitCaption;
    property ConfigAnalogInput[Channel : LongInt] : TAnalogInputChannel read GetAnalogInputChannel write SetAnalogInputChannel;
    property ConfigAnalogOutput[Channel : LongInt] : TAnalogOutputChannel read GetAnalogOutputChannel write SetAnalogOutputChannel;
  published
    {Published Declarations}
    property ModulePosition;
    property Interactive : Boolean read FInteractive write SetInteractive;
    property BinaryElementCount : LongInt read FBinaryElementCount write SetBinaryElementCount;
    property RequestLEDLabelWidth : LongInt read FRequestLEDLabelWidth write SetRequestLEDLabelWidth;
    property DigitalInputLEDLabelWidth : LongInt read FDigitalInputLEDLabelWidth write SetDigitalInputLEDLabelWidth;
    property DigitalOutputLEDLabelWidth : LongInt read FDigitalOutputLEDLabelWidth write SetDigitalOUtputLEDLabelWidth;
    property OnNewModuleData : TOnNewProcessorData read FOnNewModuleData write FOnNewModuleData;
  end; // TMicrologixProcessor

  TMicroLogix16CHDigitalInputModule = class(TBaseModule)
  private
    {Private Declairations}
    FOnNewModuleData : TOnNewDigitalInputData;
    DigitalInputLEDArray : Array[0..15] of TIndicator;
    FDigitalInputLEDLabelWidth : LongInt;
    function GetInputBitCaption(BitNumber : LongInt) : String;
    procedure SetInputBitCaption(BitNumber : LongInt; Caption : String);
    procedure SetDigitalInputLEDLabelWidth(Value : LongInt);
  protected
    {Protected Declairations}
    procedure BuildDigitalInputLEDArray;
    procedure ReSizeModuleDispaly;
  public
    {Public Declairations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TDigitalInputModule);
    property DigitalInputCaptions[BitNumber : LongInt] : String read GetInputBitCaption write SetInputBitCaption;
  published
    {Published Declarations}
    property ModulePosition;
    property DigitalInputLabelWidth : LongInt read FDigitalInputLEDLabelWidth write SetDigitalInputLEDLabelWidth;
    property OnNewModuleData : TOnNewDigitalInputData read FOnNewModuleData write FOnNewModuleData;
  end; // TMicroLogix16CHDigitalInputModule

  TMicroLogix16CHDigitalOutputModule = class(TBaseModule)
  private
    {Private Declairations}
    FOnNewModuleData : TOnNewDigitalOutputData;
    DigitalOutputLEDArray : Array[0..15] of TIndicator;
    FDigitalOutputLEDLabelWidth : LongInt;
    function GetOutputBitCaption(BitNumber : LongInt) : String;
    procedure SetOutputBitCaption(BitNumber : LongInt; Caption : String);
    procedure SetDigitalOutputLEDLabelWidth(Value : LongInt);
  protected
    {Protected Declairations}
    procedure BuildDigitalOutputLEDArray;
    procedure ReSizeModuleDispaly;
  public
    {Public Declairations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TDigitalOutputModule);
    property DigitalOutputCaptions[BitNumber : LongInt] : String read GetOutputBitCaption write SetOutputBitCaption;
  published
    {Published Declarations}
    property ModulePosition;
    property DigitalOutputLabelWidth : LongInt read FDigitalOutputLEDLabelWidth write SetDigitalOutputLEDLabelWidth;
    property OnNewModuleData : TOnNewDigitalOutputData read FOnNewModuleData write FOnNewModuleData;
  end; // TMicroLogix16CHDigitalInputModule

  TMicroLogix8CHRelayedDigitalOutputModule = class(TBaseModule)
  private
    {Private Declairations}
    FOnNewModuleData : TOnNewRelayedDigitalOutputData;
    DigitalOutputLEDArray : Array[0..7] of TIndicator;
    FRelayedDigitalOutputLEDLabelWidth : LongInt;
    function GetOutputBitCaption(BitNumber : LongInt) : String;
    procedure SetOutputBitCaption(BitNumber : LongInt; Caption : String);
    procedure SetRelayedDigitalOutputLEDLabelWidth(Value : LongInt);
  protected
    {Protected Declairations}
    procedure BuildRelayedDigitalOutputLEDArray;
    procedure ReSizeModuleDisplay;
  public
    {Public Declairations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TRelayedDigitalOutputModule);
    property DigitalOutputCaptions[BitNumber : LongInt] : String read GetOutputBitCaption write SetOutputBitCaption;
  published
    {Published Declarations}
    property ModulePosition;
    property RelayedDigitalOutputLabelWidth : LongInt read FRelayedDigitalOutputLEDLabelWidth write SetRelayedDigitalOutputLEDLabelWidth;
    property OnNewModuleData : TOnNewRelayedDigitalOutputData read FOnNewModuleData write FOnNewModuleData;
  end; // TMicroLogix8CHRelayedDigitalOutputModule

  TMicroLogix4CHAnalogInputModule = class(TBaseModule)
  private
    {Private Declairations}
    FOnNewModuleData : TOnNewAnalogInputData;
    LEDModuleError : TDioLED;
    lblModuleError : TLabel;
    AnalogInputDVMArray : Array[0..3] of TAnalogInputChannel;
  protected
    {Protected Declairations}
    procedure ReSizeModuleDisplay;
    function GetAnalogInputChannel(Channel : LongInt) : TAnalogInputChannel;
    procedure SetAnalogInputChannel(Channel : LongInt; NewConfig : TAnalogInputChannel);
  public
    {Public Declairations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TAnalogInputModule);
    property ConfigAnalogInput[Channel : LongInt] : TAnalogInputChannel read GetAnalogInputChannel write SetAnalogInputChannel;
  published
    {Published Declarations}
    property ModulePosition;
    property OnNewModuleData : TOnNewAnalogInputData read FOnNewModuleData write FOnNewModuleData;
  end; // TMicroLogix4CHAnalogInputModule

  TMicroLogix4CHRTDAnalogInputModule = class(TBaseModule)
  private
    {Private Declairations}
    FOnNewModuleData : TOnNewRTDAnalogInputData;
    LEDModuleError : TDioLED;
    lblModuleError : TLabel;
    RTDAnalogInputDVMArray : Array[0..3] of TRTDAnalogInputChannel;
  protected
    {Protected Declairations}
    procedure ReSizeModuleDisplay;
    function GetRTDAnalogInputChannel(Channel : LongInt) : TRTDAnalogInputChannel;
    procedure SetRTDAnalogInputChannel(Channel : LongInt; NewConfig : TRTDAnalogInputChannel);
  public
    {Public Declairations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TRTDAnalogInputModule);
    property ConfigRTDAnalogInput[Channel : LongInt] : TRTDAnalogInputChannel read GetRTDAnalogInputChannel write SetRTDAnalogInputChannel;
  published
    {Published Declarations}
    property ModulePosition;
    property OnNewModuleData : TOnNewRTDAnalogInputData read FOnNewModuleData write FOnNewModuleData;
  end; // TMicroLogix4CHRTDAnalogInputModule

  TMicroLogix4CHAnalogOutputModule = class(TBaseModule)
  private
    {Private Declairations}
    FOnNewModuleData : TOnNewAnalogOutputData;
    LEDModuleError : TDioLED;
    lblModuleError : TLabel;
    AnalogOutputDVMArray : Array[0..3] of TAnalogOutputChannel;
    procedure InputFieldClick(Sender : TObject);
    procedure ButtonClick(Sender : TObject);
  protected
    {Protected Declairations}
    procedure ReSizeModuleDisplay;
    function GetAnalogOutputChannel(Channel : LongInt) : TAnalogOutputChannel;
    procedure SetAnalogOutputChannel(Channel : LongInt; NewConfig : TAnalogOutputChannel);
    procedure SetCmdOutputWords(Channel : LongInt; WordNum : LongInt);
    function GetCmdOutputWords(Channel : LongInt) : LongInt;
  public
    {Public}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure NewModuleData(Sender : TObject; Module : TAnalogOutputModule);
    property ConfigAnalogOutput[Channel : LongInt] : TAnalogOutputChannel read GetAnalogOutputChannel write SetAnalogOutputChannel;
    property CommandWords[Channel : LongInt] : LongInt read GetCmdOutputWords write SetCmdOutputWords;
  published
    {Published Declarations}
    property ModulePosition;
    property OnNewModuleData : TOnNewAnalogOutputData read FOnNewModuleData write FOnNewModuleData;
  end; // TMicroLogix4CHAnalogOutputModule


  // PLC Back Plane Component
  TProcessorModuleArray = array[0..MaximumModules] of TMicroLogixProcessor;
  TAnalogInputModuleArray = array[0..MaximumModules] of TMicroLogix4CHAnalogInputModule;
  TRTDAnalogInputModuleArray = array[0..MaximumModules] of TMicroLogix4CHRTDAnalogInputModule;
  TAnalogOutputModuleArray = array[0..MaximumModules] of TMicroLogix4CHAnalogOutputModule;
  TDigitalInputModuleArray = array[0..MaximumModules] of TMicroLogix16CHDigitalInputModule;
  TDigitalOutputModuleArray = array[0..MaximumModules] of TMicroLogix16CHDigitalOutputModule;
  TRelayedDigitalOutputModuleArray = array[0..MaximumModules] of TMicroLogix8CHRelayedDigitalOutputModule;
  // ---------------------------------------------------------------------------

  TMicroLogixVirtualBackPlane = class(TComponent)
  private
    {Private Declarations}
    FOnNewModuleData : TSendModuleData;
    {$IFNDEF TMicroLogixPLC}
    FPLCController : TPLCMonitor;
    {$ELSE}
    FPLCController : TMicroLogixPLC;
    {$ENDIF}
    FModulesInstalled : Integer;
    FProcModules : Integer;
    FAIModules : Integer;
    FRTDAIModules : Integer;
    FAOModules : Integer;
    FDIModules : Integer;
    FDOModules : Integer;
    FRDOModules : Integer;
    FProcessorModules : TProcessorModuleArray;
    FAnalogInputModules : TAnalogInputModuleArray;
    FRTDAnalogInputModules : TRTDAnalogInputModuleArray;
    FAnalogOutputModules : TAnalogOutputModuleArray;
    FDigitalInputModules : TDigitalInputModuleArray;
    FDigitalOutputModules : TDigitalOutputModuleArray;
    FRelayedDigitalOutputModules : TRelayedDigitalOutputModuleArray;
    {$IFNDEF TMicroLogixPLC}
    procedure SetPLCController(Controller : TPLCMonitor);
    function GetPLCController : TPLCMonitor;
    {$ELSE}
    procedure SetPLCController(Controller : TMicroLogixPLC);
    function GetPLCController : TMicroLogixPLC;
    {$ENDIF}
  protected
    {Protected Declarations}
    procedure AssignControllerToModules;
    procedure NewPLCData(Sender : TObject; Modules : TModuleArray; ModuleTypes : TModuleType; ModuleCount : Integer);
  public
    {Public Declarations}
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure AddModuleToBackPlane(Module : TObject);
    procedure RemoveModuleFromBackPlane(Module : TObject);
    property OnNewModuleData : TSendModuleData read FOnNewModuleData write FOnNewModuleData;
    property ModulesInstalled : Integer read FModulesInstalled;
  published
    {Published Declarations}
    {$IFNDEF TMicroLogixPLC}
    property PLCController : TPLCMonitor read GetPLCController write SetPLCController;
    {$ELSE}
    property PLCController : TMicroLogixPLC read GetPLCController write SetPLCController;
    {$ENDIF}
  end; // TMicroLogixVirtualBackPlane

//procedure Register;

implementation
{_R MicroLogixPLCModules.dcr}

//procedure Register;
//begin
//  RegisterComponents('Micro Logix Modules',[TMicroLogixProcessor, TMicroLogix16CHDigitalInputModule, TMicroLogix16CHDigitalOutputModule,
//                                            TMicroLogix8CHRelayedDigitalOutputModule, TMicroLogix4CHAnalogInputModule, TMicroLogix4ChAnalogOutputModule,
//                                            TMicroLogixVirtualBackPlane]);
//end; // Register

constructor TBaseModule.Create(AOwner : TComponent);
var
  lFont : TFont;
  lPen : TPen;
begin
  inherited Create(AOwner);
  if (AOwner is TWinControl) then
    Parent := (AOwner as TWinControl);
  FModulePosition := -1;
  FConnected := False;
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
end; // TBaseModule.Create

destructor TBaseModule.Destroy;
begin
  if Assigned(FPLCBackPlane) then
    FPLCBackPlane.RemoveModuleFromBackPlane(Self);
  inherited Destroy;
end; // TBaseModule.Destroy

{$IFNDEF TMicroLogixPLC}
procedure TBaseModule.SetPLCController(Controller : TPLCMonitor);
{$ELSE}
procedure TBaseModule.SetPLCController(Controller : TMicroLogixPLC);
{$ENDIF}
begin
  if (Controller <> Nil) then
  begin
    FPLCController := Controller;
    if Assigned(FControllerAssigned) then
      FControllerAssigned(Self);
  end; // If
end; // TBaseModule.SetPLCController

{$IFNDEF TMicroLogixPLC}
function TBaseModule.GetPLCController : TPLCMonitor;
{$ELSE}
function TBaseModule.GetPLCController : TMicroLogixPLC;
{$ENDIF}
begin
  if Assigned(FPLCController) then
    Result := FPLCController
  else
    Result := Nil;
end; // TBaseModule.GetPLCController

procedure TBaseModule.SetBackPlane(BackPlane : TMicroLogixVirtualBackPlane);
begin
  if Assigned(BackPlane) then
  begin
    FPLCBackPlane := BackPlane;
    SetConnected(True);
  end; // If
end; // TBaseModule.SetBackPlane

function TBaseModule.GetBackPlane : TMicroLogixVirtualBackPlane;
begin
  if Assigned(FPLCBackPlane) then
    Result := FPLCBackPlane
  else
    Result := Nil;
end; // TBaseModule.GetBackPlane

procedure TBaseModule.SetConnected(Value : Boolean);
begin
  FConnected := Value;
  LEDConnected.Lit := FConnected;
  if Not FConnected then
    FPLCBackPlane := Nil;
end; // TBaseModule.SetConnected

function TBaseModule.GetConnected : Boolean;
begin
  if Assigned(FPLCBackPlane) then
    FConnected := True
  else
    FConnected := False;
  Result := FConnected;
end; // TBaseModule.GetConnected

function TBaseModule.GetWidth : LongInt;
begin
  Result := ParentModule.Width;
end; // TBaseModule.GetWidth

procedure TBaseModule.SetWidth(Value : LongInt);
begin
  ParentModule.Width := Value;
  LEDConnected.Left := ParentModule.Width - LEDConnected.Width - 3;
end; // TBaseModule.SetWidth

function TBaseModule.GetBaseModuleCaption : String;
begin
  Result := Caption;
end; // TBaseModule.GetBaseModuleCaption

procedure TBaseModule.SetBaseModuleCaption(Value : String);
begin
  Caption := Value;
end; // TBaseModule.SetBaseModuleCaption

procedure TMicroLogixVirtualBackPlane.NewPLCData(Sender : TObject; Modules : TModuleArray; ModuleTypes : TModuleType; ModuleCount : Integer);
var
  i : Integer;
  j : Integer;
  lAnalogInputModule : TAnalogInputModule;
  lRTDAnalogInputModule : TRTDAnalogInputModule;
  lAnalogOutputModule : TAnalogOutputModule;
  lDigitalInputModule : TDigitalInputModule;
  lDigitalOutputModule : TDigitalOutputModule;
  lRelayedDigitalOutputModule : TRelayedDigitalOutputModule;
  lProcessorModule : TPLCMainModule;
begin
  for i := 0 to (ModuleCount - 1) do
  begin
    if (Modules[i] is TAnalogInputModule) then
    begin
      lAnalogInputModule := Modules[i] as TAnalogInputModule;
      for j := 0 to (FAIModules - 1) do
      begin
        if (lAnalogInputModule.ModuleNumber = FAnalogInputModules[j].ModulePosition) then
          FAnalogInputModules[j].NewModuleData(Self,lAnalogInputModule);
      end; // For j
    end; // If
    if (Modules[i] is TRTDAnalogInputModule) then
    begin
      lRTDAnalogInputModule := Modules[i] as TRTDAnalogInputModule;
      for j := 0 to (FRTDAIModules - 1) do
      begin
        if (lRTDAnalogInputModule.ModuleNumber = FRTDAnalogInputModules[j].ModulePosition) then
          FRTDAnalogInputModules[j].NewModuleData(Self,lRTDAnalogInputModule);
      end; // For j
    end; // If
    if (Modules[i] is TAnalogOutputModule) then
    begin
      lAnalogOutputModule := Modules[i] as TAnalogOutputModule;
      for j := 0 to (FAOModules - 1) do
      begin
        if (lAnalogOutputModule.ModuleNumber = FAnalogOutputModules[j].ModulePosition) then
          FAnalogOutputModules[j].NewModuleData(Self,lAnalogOutputModule);
      end; // For j
    end; // If
    if (Modules[i] is TDigitalInputModule) then
    begin
      lDigitalInputModule := Modules[i] as TDigitalInputModule;
      for j := 0 to (FDIModules - 1) do
      begin
        if (lDigitalInputModule.ModuleNumber = FDigitalInputModules[j].ModulePosition) then
          FDigitalInputModules[j].NewModuleData(Self,lDigitalInputModule);
      end; // For j
    end; // If
    if (Modules[i] is TDigitalOutputModule) then
    begin
      lDigitalOutputModule := Modules[i] as TDigitalOutputModule;
      for j := 0 to (FDOModules - 1) do
      begin
        if (lDigitalOutputModule.ModuleNumber = FDigitalOutputModules[j].ModulePosition) then
          FDigitalOutputModules[j].NewModuleData(Self,lDigitalOutputModule);
      end; // For j
    end; // If
    if (Modules[i] is TRelayedDigitalOutputModule) then
    begin
      lRelayedDigitalOutputModule := Modules[i] as TRelayedDigitalOutputModule;
      for j := 0 to (FRDOModules - 1) do
      begin
        if (lRelayedDigitalOutputModule.ModuleNumber = FRelayedDigitalOutputModules[j].ModulePosition) then
          FRelayedDigitalOutputModules[j].NewModuleData(Self,lRelayedDigitalOutputModule);
      end; // For j
    end; // If
    if (Modules[i] is TPLCMainModule) then
    begin
      lProcessorModule := Modules[i] as TPLCMainModule;
      for j := 0 to (FProcModules - 1) do
      begin
        if Assigned(FProcessorModules[j]) then
        begin
          if (lProcessorModule.ModuleNumber = FProcessorModules[j].ModulePosition) then
            FProcessorModules[j].NewModuleData(Self,lProcessorModule);
        end; // If
      end; // For j
    end; // If
  end; // For i
end; // TMicroLogixVirtualBackPlane.NewPLCData

procedure TMicroLogixVirtualBackPlane.RemoveModuleFromBackPlane(Module : TObject);
var
  i : Integer;
  j : Integer;
  TempProcessorModules : TProcessorModuleArray;
  TempAnalogInputModules : TAnalogInputModuleArray;
  TempRTDAnalogInputModules : TRTDAnalogInputModuleArray;
  TempAnalogOutputModules : TAnalogOutputModuleArray;
  TempDigitalInputModules : TDigitalInputModuleArray;
  TempDigitalOutputModules : TDigitalOutputModuleArray;
  TempRelayedDigitalOutputModules : TRelayedDigitalOutputModuleArray;
begin
  if (Module is TMicroLogix4CHAnalogInputModule) then
  begin
    for i := 0 to FAIModules do
    begin
      TempAnalogInputModules := FAnalogInputModules;
      if (Module as TMicroLogix4CHAnalogInputModule).ModulePosition = TempAnalogInputModules[i].ModulePosition then
      begin
        TempAnalogInputModules[i].Connected := False;
        TempAnalogInputModules[i] := Nil;
        for j := i to FAIModules do
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
  if (Module is TMicroLogix4CHRTDAnalogInputModule) then
  begin
    for i := 0 to FRTDAIModules do
    begin
      TempRTDAnalogInputModules := FRTDAnalogInputModules;
      if (Module as TMicroLogix4CHRTDAnalogInputModule).ModulePosition = TempRTDAnalogInputModules[i].ModulePosition then
      begin
        TempRTDAnalogInputModules[i].Connected := False;
        TempRTDAnalogInputModules[i] := Nil;
        for j := i to FRTDAIModules do
        begin
          TempRTDAnalogInputModules[j] := TempRTDAnalogInputModules[j + 1];
          TempRTDAnalogInputModules[j + 1] := Nil;
        end; // for j
        FRTDAnalogInputModules := TempRTDAnalogInputModules;
        dec(FRTDAIModules);
        Break;
      end // If
    end; // For i
  end; // If
  if (Module is TMicroLogixProcessor) then
  begin
    for i := 0 to FProcModules do
    begin
      TempProcessorModules := FProcessorModules;
      if (Module as TMicroLogixProcessor).ModulePosition = TempProcessorModules[i].ModulePosition then
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
  if (Module is TMicroLogix16CHDigitalInputModule) then
  begin
    for i := 0 to FDIModules do
    begin
      TempDigitalInputModules := FDigitalInputModules;
      if (Module as TMicroLogix16CHDigitalInputModule).ModulePosition = TempDigitalInputModules[i].ModulePosition then
      begin
        TempDigitalInputModules[i].Connected := False;
        TempDigitalInputModules[i] := Nil;
        for j := i to FDIModules do
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
  if (Module is TMicroLogix4ChAnalogOutputModule) then
  begin
    for i := 0 to FAOModules do
    begin
      TempAnalogOutPutModules := FAnalogOutputModules;
      if (Module as TMicroLogix4ChAnalogOutputModule).ModulePosition = TempAnalogOutputModules[i].ModulePosition then
      begin
        TempAnalogOutputModules[i].Connected := False;
        TempAnalogOutputModules[i] := Nil;
        for j := i to FAOModules do
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
  if (Module is TMicroLogix16CHDigitalOutputModule) then
  begin
    for i := 0 to FDOModules do
    begin
      TempDigitalOutputModules := FDigitalOutputModules;
      if (Module as TMicroLogix16CHDigitalOutputModule).ModulePosition = TempDigitalOutputModules[i].ModulePosition then
      begin
        TempDigitalOutputModules[i].Connected := False;
        TempDigitalOutputModules[i] := Nil;
        for j := i to FDOModules do
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
  if (Module is TMicroLogix8CHRelayedDigitalOutputModule) then
  begin
    for i := 0 to FRDOModules do
    begin
      TempRelayedDigitalOutputModules := FRelayedDigitalOutputModules;
      if (Module as TMicroLogix8CHRelayedDigitalOutputModule).ModulePosition = TempRelayedDigitalOutputModules[i].ModulePosition then
      begin
        TempRelayedDigitalOutputModules[i].Connected := False;
        TempRelayedDigitalOutputModules[i] := Nil;
        for j := i to FRDOModules do
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
  FModulesInstalled := FAIModules + FProcModules + FDIModules + FAOModules + FDOModules + FRDOModules;
end; // TMicroLogixVirtualBackPlane.RemoveModuleFromBackPlane

procedure TMicroLogixVirtualBackPlane.AddModuleToBackPlane(Module : TObject);
begin
  if (Module is TMicroLogix4CHAnalogInputModule) then
  begin
    FAnalogInputModules[FAIModules] := Module as TMicroLogix4ChAnalogInputModule;
    FAnalogInputModules[FAIModules].BackPlane := Self;
    FAnalogInputModules[FAIModules].PLCController := FPLCController;
    inc(FAIModules);
  end; // If
  if (Module is TMicroLogix4CHRTDAnalogInputModule) then
  begin
    FRTDAnalogInputModules[FRTDAIModules] := Module as TMicroLogix4ChRTDAnalogInputModule;
    FRTDAnalogInputModules[FRTDAIModules].BackPlane := Self;
    FRTDAnalogInputModules[FRTDAIModules].PLCController := FPLCController;
    inc(FRTDAIModules);
  end; // If
  if (Module is TMicroLogixProcessor) then
  begin
    FProcessorModules[FProcModules] := Module as TMicroLogixProcessor;
    FProcessorModules[FProcModules].BackPlane := Self;
    FProcessorModules[FProcModules].PLCController := FPLCController;
    inc(FProcModules);
  end; // If
  if (Module is TMicroLogix16CHDigitalInputModule) then
  begin
    FDigitalInputModules[FDIModules] := Module as TMicroLogix16CHDigitalInputModule;
    FDigitalInputModules[FDIModules].BackPlane := Self;
    FDigitalInputModules[FDIModules].PLCController := FPLCController;
    inc(FDIModules);
  end; // If
  if (Module is TMicroLogix4ChAnalogOutputModule) then
  begin
    FAnalogOutputModules[FAOModules] := Module as TMicroLogix4ChAnalogOutputModule;
    FAnalogOutputModules[FAOModules].BackPlane := Self;
    FAnalogOutputModules[FAOModules].PLCController := FPLCController;
    inc(FAOModules);
  end; // If
  if (Module is TMicroLogix16CHDigitalOutputModule) then
  begin
    FDigitalOutputModules[FDOModules] := Module as TMicroLogix16CHDigitalOutputModule;
    FDigitalOutputModules[FDOModules].BackPlane := Self;
    FDigitalOutputModules[FDOModules].PLCController := FPLCController;
    inc(FDOModules);
  end; // If
  if (Module is TMicroLogix8CHRelayedDigitalOutputModule) then
  begin
    FRelayedDigitalOutputModules[FRDOModules] := Module as TMicroLogix8CHRelayedDigitalOutputModule;
    FRelayedDigitalOutputModules[FRDOModules].BackPlane := Self;
    FRelayedDigitalOutputModules[FRDOModules].PLCController := FPLCController;
    inc(FRDOModules);
  end; // If
  FModulesInstalled := FAIModules + FRTDAIModules + FProcModules + FDIModules + FAOModules + FDOModules + FRDOModules;
end; // TMicroLogixVirtualBackPlane.AddModuleToBackPlane

{$IFNDEF TMicroLogixPLC}
function TMicroLogixVirtualBackPlane.GetPLCController : TPLCMonitor;
{$ELSE}
function TMicroLogixVirtualBackPlane.GetPLCController : TMicroLogixPLC;
{$ENDIF}
begin
  if Assigned(FPLCController) then
    Result := FPLCController
  else
    Result := Nil;
end; // TMicroLogixVirtualBackPlane.GetPLCController

procedure TMicroLogixVirtualBackPlane.AssignControllerToModules;
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
  for i := Low(FRTDAnalogInputModules) to High(FRTDAnalogInputModules) do
  begin
    if Assigned(FRTDAnalogInputModules[i]) then
      FRTDAnalogInputModules[i].OnControllerAssigned(Self);
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

{$IFNDEF TMicroLogixPLC}
procedure TMicroLogixVirtualBackPlane.SetPLCController(Controller : TPLCMonitor);
{$ELSE}
procedure TMicroLogixVirtualBackPlane.SetPLCController(Controller : TMicroLogixPLC);
{$ENDIF}
begin
  if (Controller <> Nil) then
  begin
    FPLCController := Controller;
    AssignControllerToModules;
    FPLCController.OnNewModuleData := NewPLCData;
  end; // If
end; // TMicroLogixVirtualBackPlane.SetPLCController

destructor TMicroLogixVirtualBackPlane.Destroy;
begin
  FPLCController := Nil;
  inherited Destroy;
end; // TMicroLogixVirtualBackPlane.Destroy

constructor TMicroLogixVirtualBackPlane.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FPLCController := Nil;
  FModulesInstalled := 0;
  FProcModules := 0;
  FAIModules := 0;
  FRTDAIModules := 0;
  FAOModules := 0;
  FDIModules := 0;
  FDOModules := 0;
  FRDOModules := 0;
end; // TMicroLogixVirtualBackPlane.Create

constructor TMicrologixProcessor.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FModulePosition := 0;
  FBinaryElementCount := 1;
  FInteractive := False;
  FRequestLEDLabelWidth := 50;
  FDigitalInputLEDLabelWidth := 50;
  FDigitalOutputLEDLabelWidth := 50;
  if (csAcceptsControls in ParentModule.ControlStyle) then
  begin
    FillChar(FPulsedBits,SizeOf(FPulsedBits),#0);
    BaseModuleCaption := 'Processor Module';
    OnControllerAssigned := ControllerAssigned;
    lblModulePosition := TLabel.Create(Nil);
    with lblModulePosition do
    begin
      Parent := ParentModule;
      Top := 12;
      Left := 3;
      Height := 13;
      Width := 45;
      Font.Color := clWhite;
      Font.Style := [];
      AutoSize := True;
      Caption := format('Module Position: %d',[ModulePosition]);
    end; // With
    lblErrorCode := TLabel.Create(Nil);
    with lblErrorCode do
    begin
      Parent := ParentModule;
      Top := 26;
      Left := 3;
      Height := 13;
      Width := 45;
      Font.Color := clWhite;
      Font.Style := [];
      AutoSize := True;
      Caption := 'Fault code: x0';
    end; // With
    {$IFDEF TMicroLogixPLC}
    LEDKeySwithMode := TDioLED.Create(Nil);
    with LEDKeySwithMode do
    begin
      Parent := ParentModule;
      Top := 12;
      Left := 179;
      Height := 30;
      Width := 70;
      Shape := stRoundRect;
      LitColor := clRed;
      Lit := True;
    end; // With
    lblKeySwitchMode := TLabel.Create(Nil);
    with lblKeySwitchMode do
    begin
      Parent := ParentModule;
      Top := 14;
      Left := 184;
      Font.Color := $001E1E1E;
      Font.Style := [fsBold];
      Transparent := True;
      alignment := taCenter;
      WordWrap := True;
      Caption := 'Key Switch Pos.';
      Height := 30;
      Width := 60;
    end; // with
    {$ENDIF}
    LEDProcessorMode := TDioLED.Create(Nil);
    with LEDProcessorMode do
    begin
      Parent := ParentModule;
      Top := 12;
      Left := 250;
      Height := 30;
      Width := 70;
      Shape := stRoundRect;
      LitColor := clSilver;
      Lit := True;
    end; // With
    lblProcessorMode := TLabel.Create(Nil);
    with lblProcessorMode do
    begin
      Parent := ParentModule;
      Top := 14;
      Left := 255;
      Font.Color := $001E1E1E;
      Font.Style := [fsBold];
      Transparent := True;
      Alignment := taCenter;
      WordWrap := True;
      Caption := 'PLC Proc. Mode';
      Height := 30;
      Width := 60;
    end; // With
    LEDForcedIO := TDioLED.Create(Nil);
    with LEDForcedIO do
    begin
      Parent := ParentModule;
      Top := 12;
      Left := 321;
      Height := 30;
      Width := 70;
      Shape := stRoundRect;
      LitColor := clRed;
    end; // With
    lblForcedIO := TLabel.Create(Nil);
    with lblForcedIO do
    begin
      Parent := ParentModule;
      Top := 20;
      Left := 326;
      Font.Color := $001E1E1E;
      Font.Style := [fsBold];
      Transparent := True;
      Alignment := taCenter;
      WordWrap := True;
      Caption := 'Forced IO';
      Height := 30;
      Width := 60;
    end; // With
    LEDControlRegisterError := TDioLED.Create(Nil);
    with LEDControlRegisterError do
    begin
      Parent := ParentModule;
      Top := 12;
      Left := 392;
      Height := 30;
      Width := 70;
      Shape := stRoundRect;
      LitColor := clRed;
    end; // With
    lblControlRegisterError := TLabel.Create(Nil);
    with lblControlRegisterError do
    begin
      Parent := ParentModule;
      Top := 13;
      Left := 396;
      Font.Color := $001E1E1E;
      Font.Style := [fsBold];
      Transparent := True;
      Alignment := taCenter;
      WordWrap := True;
      Caption := 'Cntrl Reg. Error';
      Height := 30;
      Width := 60;
    end; // With
    LEDBatteryOK := TDioLED.Create(Nil);
    with LEDBatteryOK do
    begin
      Parent := ParentModule;
      Top := 12;
      Left := 463;
      Height := 30;
      Width := 70;
      Shape := stRoundRect;
      LitColor := clLime;
      UnlitColor := clRed;
    end; // With
    lblBatteryOK := TLabel.Create(Nil);
    with lblBatteryOK do
    begin
      Parent := ParentModule;
      Top := 13;
      Left := 468;
      Font.Color := $001E1E1E;
      Font.Style := [fsBold];
      Transparent := True;
      Alignment := taCenter;
      WordWrap := True;
      Caption := 'Battery OK';
      Height := 30;
      Width := 60;
    end; // With
    chbWatchDog := TCheckBox.Create(Nil);
    with chbWatchDog do
    begin
      Parent := ParentModule;
      Top := 13;
      Left := 550;
      Font.Color := $001E1E1E;
      Font.Style := [fsBold];
      Caption := 'Enable WatchDog';
      Height := 30;
      Width := 125;
      OnClick := chbWatchDogClick;
    end; // With
    gbOutputBits := TGroupBox.Create(Nil);
    with gbOutputBits do
    begin
      Parent := ParentModule;
      Top := 43;
      Left := 3;
      Height := 90;
      Width := BaseModuleWidth - 2;
      Color := clGray;
      Height := 90;
      Width := (BaseModuleWidth - 6);
      Caption := 'Request PLC Output Change:';
    end; // With
    gbRequestBits := TGroupBox.Create(Nil);
    with gbRequestBits do
    begin
      Parent := ParentModule;
      Left := 2;
      Top := gbOutputBits.Top + gbOutputBits.Height + 2;
      Width := (BaseModuleWidth + 5);
      Height := 90;
      Color := clBlue;
      Caption := 'Request Bits';
    end; // With
//    BuildRequestBitLEDArray;
    gbDigitalInputs := TGroupBox.Create(Nil);
    with gbDigitalInputs do
    begin
      Parent := ParentModule;
      Top := gbRequestBits.Top + gbRequestBits.Height + 2;
      Left := 2;
      Height := 90;
      Width := (BaseModuleWidth - 5);
      Color := clBlue;
      Caption := 'Digital Inputs';
    end; // With
//    BuildDigitalInputLEDArray;
    gbDigitalOutputs := TGroupBox.Create(Nil);
    with gbDigitalOutputs do
    begin
      Parent := ParentModule;
      Top := gbDigitalInputs.Top + gbDigitalInputs.Height + 1;
      Left := 2;
      Height := 90;
      Width := (BaseModuleWidth - 5);
      Color := clBlue;
      Caption := 'Digital Outputs';
    end; // With
    BuildRequestBitLEDArray;
    BuildDigitalInputLEDArray;
    BuildDigitalOutputLEDArray;
    BuildAnalogInputArray;
    BuildAnalogOutputArray;
    ReSizeModuleDisplay;
  end; // If
end; // TMicrologixProcessor.Create

destructor TMicrologixProcessor.Destroy;
begin
  inherited Destroy;
end; // TMicrologixProcessor.Destory

procedure TMicrologixProcessor.BuildRequestBitLEDArray;
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
  if Assigned(FPLCController) then
    lBinarySize := FPLCController.BinarySize
  else
    lBinarySize := FBinaryElementCount;
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
end; // TMicrologixProcessor.BuildRequestBitLEDArray

procedure TMicrologixProcessor.BuildDigitalInputLEDArray;
var
  i : LongInt;
  j : LongInt;
  lRow : LongInt;
  lColumn : LongInt;
begin
  lRow := 0;
  lColumn := 0;
  for i := Low(DigitalInputLEDArray) to High(DigitalInputLEDArray) do
  begin
    for j := Low(DigitalInputLEDArray[i]) to High(DigitalInputLEDArray[i]) do
    begin
      if Not Assigned(DigitalInputLEDArray[i,j].LED) then
        DigitalInputLEDArray[i,j].LED := TDioLED.Create(Nil);
      with DigitalInputLEDArray[i,j].LED do
      begin
        Parent := gbDigitalInputs;
        Top := 15 + (12 * lRow);
        Left := 10 + (FDigitalInputLEDLabelWidth * lColumn);
        Height := 10;
        Width := 10;
        Shape := stRoundRect;
        LitColor := clLime;
      end; // With
      if Not Assigned(DigitalInputLEDArray[i,j].LEDLabel) then
        DigitalInputLEDArray[i,j].LEDLabel := TLabel.Create(Nil);
      with DigitalInputLEDArray[i,j].LEDLabel do
      begin
        Parent := gbDigitalInputs;
        Top := 17 + (12 * lRow);
        Left := 22 + (FDigitalInputLEDLabelWidth * lColumn);
        Font.Name := 'Terminal';
        Font.Size := 6;
        Font.Color := clWhite;
        Caption := format('Label %d',[(i + 1) * (j + 1)]);
        Transparent := True;
        Height := 13;
        Width := FDigitalInputLEDLabelWidth;
      end; // With
      inc(lRow);
      if (lRow > 5) then
      begin
        inc(lColumn);
        lRow := 0;
      end; // If
    end; // For j
  end; // For i
  gbDigitalInputs.Width := DigitalInputLEDArray[1,15].LEDLabel.Left + DigitalInputLEDArray[1,15].LEDLabel.Width;
end; // TMicrologixProcessor.BuildDigitalInputLEDArray

procedure TMicrologixProcessor.BuildDigitalOutputLEDArray;
var
  i : LongInt;
  j : LongInt;
  lRow : LongInt;
  lColumn : LongInt;
begin
  lRow := 0;
  lColumn := 0;
  for i := Low(DigitalOutputLEDArray) to High(DigitalOutputLEDArray) do
  begin
    for j := Low(DigitalOutputLEDArray[i]) to High(DigitalOutputLEDArray[i]) do
    begin
      if Not Assigned(DigitalOutputLEDArray[i,j].LED) then
        DigitalOutputLEDArray[i,j].LED := TDioLED.Create(Nil);
      with DigitalOutputLEDArray[i,j].LED do
      begin
        Parent := gbDigitalOutputs;
        Top := 15 + (12 * lRow);
        Left := 10 + (FDigitalOutputLEDLabelWidth * lColumn);
        Height := 10;
        Width := 10;
        Shape := stRoundRect;
        LitColor := clLime;
      end; // With
      if Not Assigned(DigitalOutputLEDArray[i,j].LEDLabel) then
        DigitalOutputLEDArray[i,j].LEDLabel := TLabel.Create(Nil);
      with DigitalOutputLEDArray[i,j].LEDLabel do
      begin
        Parent := gbDigitalOutputs;
        Top := 17 + (12 * lRow);
        Left := 22 + (FDigitalOutputLEDLabelWidth * lColumn);
        Font.Name := 'Terminal';
        Font.Size := 6;
        Font.Color := clWhite;
        Caption := format('Label %d',[(i + 1) * (j + 1)]);
        Transparent := True;
        Height := 13;
        Width := FDigitalOutputLEDLabelWidth;
      end; // With
      inc(lRow);
      if (lRow > 5) then
      begin
        inc(lColumn);
        lRow := 0;
      end; // If
    end; // For j
  end; // For i
  gbDigitalOutputs.Width := DigitalOutputLEDArray[1,15].LEDLabel.Left + DigitalOutputLEDArray[1,15].LEDLabel.Width;
  ReSizeModuleDisplay;
end; // TMicrologixProcessor.BuildDigitalOutputLEDArray

procedure TMicrologixProcessor.BuildAnalogInputArray;
var
  i : LongInt;
  lRow : LongInt;
  lColumn : LongInt;
  MyLabel : TLabel;
begin
//  BaseModuleWidth := BaseModuleWidth + 256;
  lRow := 0;
  lColumn := 0;
  for i := Low(AnalogInputDVMArray) to High(AnalogInputDVMArray) do
  begin
    if Not Assigned(AnalogInputDVMArray[i].AnalogChannel.Guage) then
      AnalogInputDVMArray[i].AnalogChannel.Guage := TDVM.Create(Nil);
    with AnalogInputDVMArray[i].AnalogChannel.Guage do
    begin
      Parent := ParentModule;
      Top := 48 + (lRow * 59);
      if FInteractive then
        Left := 2 + gbOutputBits.Left + gbOutputBits.Width + (lColumn * 102)
      else
        Left := 2 + gbRequestBits.Left + gbRequestBits.Width + (lColumn * 102);
      Height := 58;
      Width := 100;
      Font.Color := clBlack;
      Font.Size := 20;
      Font.Name := 'Arial';
      Font.Style := [];
      TitleFont.Color := clWindowText;
      TitleFont.Size :=8;
      TitleFont.Name := 'Arial';
      TitleFont.Style := [];
      UnitsFont.Color := clWindowText;
      UnitsFont.Size := 8;
      UnitsFont.Name := 'Arial';
      UnitsFont.Style := [];
      Title := format('Analog Input %d',[i]);
    end; // With
    if Not Assigned(AnalogInputDVMArray[i].AnalogChannel.LEDUR) then
    begin
      AnalogInputDVMArray[i].AnalogChannel.LEDUR := TDioLED.Create(Nil);
      with AnalogInputDVMArray[i].AnalogChannel.LEDUR do
      begin
        Parent := AnalogInputDVMArray[i].AnalogChannel.Guage;
        Top := 39;
        Left := 5;
        Height := 13;
        Width := 13;
        Shape := stRoundRect;
        LitColor := clRed;
      end; // With
      AnalogInputDVMArray[i].AnalogChannel.LEDOR := TDioLED.Create(Nil);
      with AnalogInputDVMArray[i].AnalogChannel.LEDOR do
      begin
        Parent := AnalogInputDVMArray[i].AnalogChannel.Guage;
        Top := 39;
        Left := 81;
        Height := 13;
        Width := 13;
        Shape := stRoundRect;
        LitColor := clRed;
      end; // With
      MyLabel := TLabel.Create(Nil); // UR Label
      with MyLabel do
      begin
        Parent := AnalogInputDVMArray[i].AnalogChannel.Guage;
        Top := 39;
        Left := 20;
        Font.Color := clBlack;
        Font.Name := 'Arial';
        Font.Size := 8;
        Font.Style := [];
        Caption := 'UR';
        Height := 14;
        Width := 14;
      end; // With
      MyLabel := TLabel.Create(Nil); // OR Label
      with MyLabel do
      begin
        Parent := AnalogInputDVMArray[i].AnalogChannel.Guage;
        Top := 39;
        Left := 65;
        Font.Color := clBlack;
        Font.Name := 'Arial';
        Font.Size := 8;
        Font.Style := [];
        Caption := 'OR';
        Height := 14;
        Width := 14;
      end; // With
    end; // If
    inc(lColumn);
    if (lColumn > 1) then
    begin
      lColumn := 0;
      inc(lRow);
    end; // If
  end; // For i
  BaseModuleWidth := AnalogInputDVMArray[3].AnalogChannel.Guage.Left + AnalogInputDVMArray[3].AnalogChannel.Guage.Width + 3;
end; // TMicrologixProcessor.BuildAnalogInputArray

procedure TMicrologixProcessor.BuildAnalogOutputArray;
var
  i : LongInt;
  lRow : LongInt;
  lColumn : LongInt;
begin
  lRow := 0;
  lColumn := 0;
  for i := Low(AnalogOutputDVMArray) to High(AnalogOutputDVMArray) do
  begin
    if Not Assigned(AnalogOutputDVMArray[i].AnalogChannel.Guage) then
      AnalogOutputDVMArray[i].AnalogChannel.Guage := TDVM.create(Nil);
    with AnalogOutputDVMArray[i].AnalogChannel.Guage do
    begin
      Parent := ParentModule;
      Top := 166 + (lRow * 59);
      if FInteractive then
        Left := 2 + gbOutputBits.Left + gbOutputBits.Width + (lColumn * 102)
      else
        Left := 2 + gbRequestBits.Left + gbRequestBits.Width + (lColumn * 102);
      Height := 58;
      Width := 100;
      Font.Color := clBlack;
      Font.Size := 20;
      Font.Name := 'Arial';
      Font.Style := [];
      TitleFont.Color := clWindowText;
      TitleFont.Size :=8;
      TitleFont.Name := 'Arial';
      TitleFont.Style := [];
      UnitsFont.Color := clWindowText;
      UnitsFont.Size := 8;
      UnitsFont.Name := 'Arial';
      UnitsFont.Style := [];
      Title := format('Analog Output %d',[i]);
    end; // With
    if Not Assigned(AnalogOutputDVMArray[i].InputField) then
      AnalogOutputDVMArray[i].InputField := TOvcNumericField.Create(Nil);
    with AnalogOutputDVMArray[i].InputField do
    begin
      Parent := ParentModule;
      Top := AnalogOutputDVMArray[i].AnalogChannel.Guage.Top + AnalogOutputDVMArray[i].AnalogChannel.Guage.Height + 1;
      Left := AnalogOutputDVMArray[i].AnalogChannel.Guage.Left;
      Height := 21;
      Width := 50;
      Font.Color := clBlack;
      DataType := nftSingle;
      PictureMask := '##.###';
      OnClick := InputFieldClick;
      Tag := (i + 4);
    end; // With
    if Not Assigned(AnalogOutputDVMArray[i].InputButton) then
      AnalogOutputDVMArray[i].InputButton := TButton.Create(Nil);
    with AnalogOutputDVMArray[i].InputButton do
    begin
      Parent := ParentModule;
      Top := AnalogOutputDVMArray[i].AnalogChannel.Guage.Top + AnalogOutputDVMArray[i].AnalogChannel.Guage.Height + 1;
      Left := AnalogOutputDVMArray[i].InputField.Left + AnalogOutputDVMArray[i].InputField.Width + 1;
      Height := 21;
      Width := 50;
      Font.Color := clBlack;
      Tag := i;
      Caption := format('Chan%d',[i]);
      OnClick := ButtonClick;
    end; // With
    inc(lColumn);
    if (lColumn > 1) then
    begin
      lColumn := 0;
      inc(lRow);
    end; // If
  end; // For i
end; // TMicrologixProcessor.BuildAnalogOutputArray

procedure TMicrologixProcessor.InputFieldClick(Sender : TObject);
begin
  (Sender as TOvcNumericField).SelectAll;
end; // TProcesorModule.InputFieldClick

procedure TMicrologixProcessor.ButtonClick(Sender : TObject);
var
  myTag : Integer;
  Value : Integer;
begin
  myTag := (Sender as TButton).Tag;
  if Assigned(FPLCController) then
  begin
    Value := Trunc((AnalogOutputDVMArray[myTag].InputField.AsFloat / 10) * FPLCController.EmbededIOResolution);
    FPLCController.WriteWordToPLC('O',(myTag + 4),1,Value);
  end; // If
end; // TMicrologixProcessor.ButtonClick

procedure TMicrologixProcessor.ControllerAssigned(Sender : TObject);
begin
  BuildRequestBitLEDArray;
  ReSizeModuleDisplay;
end; // TMicrologixProcessor.ControllerAssigned

procedure TMicrologixProcessor.BuildRequestBitSelection;
var
  i : LongInt;
  j : LongInt;
begin
  if Not Assigned(clRequestBits) then
    clRequestBits := TOvcBasicCheckList.Create(Nil);
  gbOutputBits.Visible := False;
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
    Items.Clear;
    for i := Low(RequestBitLEDArray) to High(RequestBitLEDArray) do
    begin
      for j := Low(RequestBitLEDArray[i]) to High(RequestBitLEDArray[i]) do
      begin
        if Assigned(RequestBitLEDArray[i,j].LEDLabel) then
          Items.Add(RequestBitLEDArray[i,j].LEDLabel.Caption);
      end; // For j
    end; // For i
  end; // With
  gbOutputBits.Visible := FInteractive;
  if gbOutputBits.Visible then
  begin
    gbOutputBits.Height := gbRequestBits.Height + 30;
    gbOutputBits.Width := gbRequestBits.Width;
  end; // If
end; // TMicrologixProcessor.BuildRequestBitSelection

procedure TMicrologixProcessor.ReSizeModuleDisplay;
var
  MaxWidth : LongInt;
begin
  if FInteractive then
    gbRequestBits.Top := gbOutputBits.Top + gbOutputBits.Height + 1
  else
    gbRequestBits.Top := gbOutputBits.Top;
  gbDigitalInputs.Top := gbRequestBits.Top + gbRequestBits.Height + 1;
  gbDigitalOutputs.Top := gbDigitalInputs.Top + gbDigitalInputs.Height + 1;
  ParentModule.Height := gbDigitalOutputs.Top + gbDigitalOutputs.Height + 2;
  BuildAnalogInputArray;
  BuildAnalogOutputArray;
  MaxWidth := gbOutputBits.Left + gbOutputBits.Width;
  if (gbRequestBits.Left + gbRequestBits.Width > MaxWidth) then
    MaxWidth := gbRequestBits.Left + gbRequestBits.Width;
  if (gbDigitalInputs.Left + gbDigitalInputs.Width > MaxWidth) then
    MaxWidth := gbDigitalInputs.Left + gbDigitalInputs.Width;
  if (gbDigitalOutputs.Left + gbDigitalOutputs.Width > MaxWidth) then
    MaxWidth := gbDigitalOutputs.Left + gbDigitalOutputs.Width;
  if (AnalogInputDVMArray[3].AnalogChannel.Guage.Left + AnalogInputDVMArray[3].AnalogChannel.Guage.Width > MaxWidth) then
    MaxWidth := AnalogInputDVMArray[3].AnalogChannel.Guage.Left + AnalogInputDVMArray[3].AnalogChannel.Guage.Width;
  BaseModuleWidth := MaxWidth + 3;
end; // TMicrologixProcessor.ReSizeModuleDisplay

procedure TMicrologixProcessor.RequestBitsClick(Sender: TObject);
begin
  if AssigneD(FPLCController) and Not (csDesigning in ComponentState) then
  begin
    if Not FPLCController.Enabled then
    begin
      clRequestBits.Selected[clRequestBits.ItemIndex] := False;
      Exit;
    end; // If
    FPLCController.WriteBitToPLC('B3',(clRequestBits.ItemIndex div 16),(clRequestBits.ItemIndex - ((clRequestBits.ItemIndex div 16) * 16)), 1, clRequestBits.Selected[clRequestBits.ItemIndex]);
    if (clRequestBits.ItemIndex in FPulsedBits) and (clRequestBits.Selected[clRequestBits.ItemIndex]) then // Pulsed Bits
    begin
      FPLCController.WriteBitToPLC('B3',(clRequestBits.ItemIndex div 16),(clRequestBits.ItemIndex - ((clRequestBits.ItemIndex div 16) * 16)), 1, False);
      clRequestBits.Selected[clRequestBits.ItemIndex] := False;
    end; // If
  end; // If
end; // TCustomPLCProcessorModule.RequestBitsClick

procedure TMicrologixProcessor.chbWatchDogClick(Sender : TObject);
begin
  if Assigned(FPLCController) then
    FPLCController.EnableWatchDog := chbWatchDog.Checked;
end; // TMicrologixProcessor.chbWatchDogClick


procedure TMicrologixProcessor.NewModuleData(Sender : TObject; Module : TPLCMainModule);
var
  i : LongInt;
  j : LongInt;
begin
  if (Module <> Nil) then
  begin
    LEDConnected.Lit := Not LEDConnected.Lit;
    with Module do
    begin
      if (ModuleNumber = FModulePosition) then
      begin
        ModuleError := MajorErrorCode > 0;
        lblModulePosition.Caption := format('Module Position : %d',[ModuleNumber]);
        lblErrorCode.Caption := format('Fault code: x%x',[MajorErrorCode]);
        case ProcessorMode of
          0  : LEDProcessorMode.LitColor := clSilver;
          1  : LEDProcessorMode.LitColor := clAqua;
          6  : LEDProcessorMode.LitColor := clGreen;
          7  : LEDProcessorMode.LitColor := $000080FF;
          8  : LEDProcessorMode.LitColor := clAqua;
          17 : LEDProcessorMode.LitColor := clAqua;
          30 : LEDProcessorMode.LitColor := clLime;
        end; // Case
        {$IFDEF TMicroLogixPLC}
        case KeySwitchPosition of
          1 : LEDKeySwithMode.LitColor := clLime;
          2 : LEDKeySwithMode.LitColor := clYellow;
          3 : LEDKeySwithMode.LitColor := clPurple;
        end; // Case
        {$ENDIF}
        LEDForcedIO.Lit := ForcedIO;
        LEDControlRegisterError.Lit := ControlRegisterError;
        LEDBatteryOK.Lit := BatteryOK;
        for i := 0 to 9 do
        begin
          for j := Low(RequestBitLEDArray[i]) to High(RequestBitLEDArray[i]) do
          begin
            if Assigned(RequestBitLEDArray[i,j].LED) then
              RequestBitLEDArray[i,j].LED.Lit := Request_Bits_Status[i][j]
            else
              Break;
          end; // For j
        end; // For i
        for i := Low(DigitalInputLEDArray) to High(DigitalInputLEDArray) do
        begin
          for j := Low(DigitalInputLEDArray[i]) to High(DigitalInputLEDArray[i]) do
          begin
            if Assigned(DigitalInputLEDArray[i,j].LED) then
              DigitalInputLEDArray[i,j].LED.Lit := DigitalInputData[i][j]
            else
              Break;
          end; // For j
        end; // For i
        for i := Low(DigitalOutputLEDArray) to High(DigitalOutputLEDArray) do
        begin
          for j := Low(DigitalOutputLEDArray[i]) to High(DigitalOutputLEDArray[i]) do
          begin
            if Assigned(DigitalOutputLEDArray[i,j].LED) then
              DigitalOutputLEDArray[i,j].LED.Lit := DigitalOutputData[i][j]
            else
              Break;
          end; // For j
        end; // For i
        for i := Low(AnalogInputDVMArray) to High(AnalogInputDVMArray) do
        begin
          if Assigned(FPLCController) then
            AnalogInputDVMArray[i].AnalogChannel.Guage.value := (AnalogInputData[i] / FPLCController.EmbededIOResolution) * AnalogInputDVMArray[i].AnalogChannel.Scale
          else
            AnalogInputDVMArray[i].AnalogChannel.Guage.value := (AnalogInputData[i] / 4096{Assume this Value}) * AnalogInputDVMArray[i].AnalogChannel.Scale;
        end; // For i
        for i := Low(AnalogOutputDVMArray) to High(AnalogOutputDVMArray) do
        begin
          if Assigned(FPLCController) then
            AnalogOutputDVMArray[i].AnalogChannel.Guage.value := (AnalogOutputData[i] / FPLCController.EmbededIOResolution) * AnalogOutputDVMArray[i].AnalogChannel.Scale
          else
            AnalogOutputDVMArray[i].AnalogChannel.Guage.value := (AnalogOutputData[i] / 4096{Assume this Value}) * AnalogOutputDVMArray[i].AnalogChannel.Scale;
        end; // For i
      end; // If
    end; // With
    if Assigned(FOnNewModuleData) then
      FOnNewModuleData(Self,Module);
  end; // If
end; // TMicrologixProcessor.NewModuleData

function TMicrologixProcessor.GetAnalogInputChannel(Channel : LongInt) : TAnalogInputChannel;
begin
  if (Channel in [Low(AnalogInputDVMArray)..High(AnalogInputDVMArray)]) then
    Result := AnalogInputDVMArray[Channel];
end; // TMicrologixProcessor.GetAnalogInputChannel

procedure TMicrologixProcessor.SetAnalogInputChannel(Channel : LongInt; NewConfig : TAnalogInputChannel);
begin
  if (Channel in [Low(AnalogInputDVMArray)..High(AnalogInputDVMArray)]) then
    AnalogInputDVMArray[Channel] := NewConfig;
end; // TMicroLogixProcessor.SetAnalogInputChannel

function TMicrologixProcessor.GetAnalogOutputChannel(Channel : LongInt) : TAnalogOutputChannel;
begin
  if (Channel in [Low(AnalogOutputDVMArray)..High(AnalogOutputDVMArray)]) then
    Result := AnalogOutputDVMArray[Channel];
end; // TMicroLogixProcessor.GetAnalogOutputChannel

procedure TMicrologixProcessor.SetAnalogOutputChannel(Channel : LongInt; NewConfig : TAnalogOutputChannel);
begin
  if (Channel in [Low(AnalogOutputDVMArray)..High(AnalogOutputDVMArray)]) then
    AnalogOutputDVMArray[Channel] := NewConfig;
end; // TMicroLogicProcessor.SetAnalogOutputChannel

function TMicrologixProcessor.GetRequestBitCaption(WordNumber, BitNumber : LongInt) : String;
begin
  if (WordNumber in [Low(RequestBitLEDArray)..High(RequestBitLEDArray)]) then
  begin
    if (BitNumber in [Low(RequestBitLEDArray[WordNumber])..High(RequestBitLEDArray[WordNumber])]) then
    begin
      if Assigned(RequestBitLEDArray[WordNumber,BitNumber].LEDLabel) then
        Result := RequestBitLEDArray[WordNumber,BitNumber].LEDLabel.Caption;
    end; // If
  end; // If
end; // TMicrologixProcessor.GetRequestBitCaption

procedure TMicroLogixProcessor.SetRequestBitCaption(WordNumber,BitNumber : LongInt; Caption : String);
var
  LabelPos : LongInt;
begin
  if (WordNumber in [Low(RequestBitLEDArray)..High(RequestBitLEDArray)]) then
  begin
    if (BitNumber in [Low(RequestBitLEDArray[WordNumber])..High(RequestBitLEDArray[WordNumber])]) then
    begin
      if Assigned(RequestBitLEDArray[WordNumber,BitNumber].LEDLabel) then
      begin
        LabelPos := (16 * WordNumber) + BitNumber;
        RequestBitLEDArray[WordNumber,BitNumber].LEDLabel.Caption := Caption;
        clRequestBits.Items[LabelPos] := Caption;
      end; // If
    end; // If
  end; // If
end; // TMicroLogixProcessor.SetRequestBitCaption

function TMicroLogixProcessor.GetDigitalInputBitCaption(WordNumber, BitNumber : LongInt) : String;
begin
  if (WordNumber in [Low(DigitalInputLEDArray)..High(DigitalInputLEDArray)]) then
  begin
    if (BitNumber in [Low(DigitalInputLEDArray[WordNumber])..High(DigitalInputLEDArray[WordNumber])]) then
    begin
      if Assigned(DigitalInputLEDArray[WordNumber,BitNumber].LEDLabel) then
        Result := DigitalInputLEDArray[WordNumber,BitNumber].LEDLabel.Caption;
    end; // If
  end; // If
end; // TMicroLogixProcessor.GetDigitalInputBitCaption

procedure TMicroLogixProcessor.SetDigitalInputBitCaption(WordNumber,BitNumber : LongInt; Caption : String);
begin
  if (WordNumber in [Low(DigitalInputLEDArray)..High(DigitalInputLEDArray)]) then
  begin
    if (BitNumber in [Low(DigitalInputLEDArray[WordNumber])..High(DigitalInputLEDArray[WordNumber])]) then
    begin
      if Assigned(DigitalInputLEDArray[WordNumber,BitNumber].LEDLabel) then
        DigitalInputLEDArray[WordNumber,BitNumber].LEDLabel.Caption := Caption;
    end; // If
  end; // If
end; // TMicroLogixProcessor.SetDigitalInputBitCaption

function TMicroLogixProcessor.GetDigitalOutputBitCaption(WordNumber, BitNumber : LongInt) : String;
begin
  if (WordNumber in [Low(DigitalOutputLEDArray)..High(DigitalOutputLEDArray)]) then
  begin
    if (BitNumber in [Low(DigitalOutputLEDArray[WordNumber])..High(DigitalOutputLEDArray[WordNumber])]) then
    begin
      if Assigned(DigitalOutputLEDArray[WordNumber,BitNumber].LEDLabel) then
        Result := DigitalOutputLEDArray[WordNumber,BitNumber].LEDLabel.Caption;
    end; // If
  end; // If
end; // TMicroLogixProcessor.GetDigitalOutputBitCaption

procedure TMicroLogixProcessor.SetDigitalOutputBitCaption(WordNumber,BitNumber : LongInt; Caption : String);
begin
  if (WordNumber in [Low(DigitalOutputLEDArray)..High(DigitalOutputLEDArray)]) then
  begin
    if (BitNumber in [Low(DigitalOutputLEDArray[WordNumber])..High(DigitalOutputLEDArray[WordNumber])]) then
    begin
      if Assigned(DigitalOutputLEDArray[WordNumber,BitNumber].LEDLabel) then
        DigitalOutputLEDArray[WordNumber,BitNumber].LEDLabel.Caption := Caption;
    end; // If
  end; // If
end; // TMicroLogixProcessor.SetDigitalOutputBitCaption

procedure TMicroLogixProcessor.SetInteractive(Value : Boolean);
begin
  FInteractive := Value;
  chbWatchDog.Enabled := FInteractive;
  AnalogOutputDVMArray[0].InputField.Enabled := FInteractive;
  AnalogOutputDVMArray[0].InputButton.Enabled := FInteractive;
  AnalogOutputDVMArray[1].InputField.Enabled := FInteractive;
  AnalogOutputDVMArray[1].InputButton.Enabled := FInteractive;
  BuildRequestBitSelection;
  ResizeModuleDisplay;
end; // TMicroLogixProcessor.SetInteractive

procedure TMicroLogixProcessor.SetBinaryElementCount(Value : LongInt);
begin
  FBinaryElementCount := Value;
  BuildRequestBitLEDArray;
//  if FInteractive then
//    BuildRequestBitSelection;
  ReSizeModuleDisplay;
end; // TMicroLogixProcessor.SetBinaryElementCount

procedure TMicroLogixProcessor.SetRequestLEDLabelWidth(Value : LongInt);
begin
  FRequestLEDLabelWidth := Value;
  BuildRequestBitLEDArray;
  ReSizeModuleDisplay;
end; // TMicroLogixProcessor.SetRequestLEDLabelWidth

procedure TMicroLogixProcessor.SetDigitalInputLEDLabelWidth(Value : LongInt);
begin
  FDigitalInputLEDLabelWidth := Value;
  BuildDigitalInputLEDArray;
  ReSizeModuleDisplay;
end; // TMicroLogixProcessor.SetDigitalInputLEDLabelWidth

procedure TMicroLogixProcessor.SetDigitalOutputLEDLabelWidth(Value : LongInt);
begin
  FDigitalOutputLEDLabelWidth := Value;
  BuildDigitalOutputLEDArray;
  ReSizeModuleDisplay;
end; // TMicroLogixProcessor.SetDigitalOutputLEDLabelWidth

constructor TMicroLogix16CHDigitalInputModule.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  BaseModuleCaption := '16CH Digital Input Module';
  FDigitalInputLEDLabelWidth := 50;
  BuildDigitalInputLEDArray;
  ReSizeModuleDispaly;
end; // TMicroLogix16CHDigitalInputModule.Create

destructor TMicroLogix16CHDigitalInputModule.Destroy;
begin
  inherited Destroy;
end; // TMicroLogix16CHDigitalInputModule.Destroy


function TMicroLogix16CHDigitalInputModule.GetInputBitCaption(BitNumber : LongInt) : String;
begin
  if (BitNumber in [Low(DigitalInputLEDArray)..High(DigitalInputLEDArray)]) then
  begin
    if Assigned(DigitalInputLEDArray[BitNumber].LEDLabel) then
    begin
      Result := DigitalInputLEDArray[BitNumber].LEDLabel.Caption;
    end; // if
  end; // If
end; // TMicroLogix16CHDigitalInputModule.GetInputBitCaption

procedure TMicroLogix16CHDigitalInputModule.SetInputBitCaption(BitNumber : LongInt; Caption : String);
begin
  if (BitNumber in [Low(DigitalInputLEDArray)..High(DigitalInputLEDArray)]) then
  begin
    if Assigned(DigitalInputLEDArray[BitNumber].LEDLabel) then
    begin
      DigitalInputLEDArray[BitNumber].LEDLabel.Caption := Caption;
    end; // if
  end; // If
end; // TMicroLogix16CHDigitalInputModule.SetInputBitCaption

procedure TMicroLogix16CHDigitalInputModule.SetDigitalInputLEDLabelWidth(Value : LongInt);
begin
  FDigitalInputLEDLabelWidth := Value;
  BuildDigitalInputLEDArray;
end; // TMicroLogix16CHDigitalInputModule.SetDigitalInputLEDLabelWidth

procedure TMicroLogix16CHDigitalInputModule.NewModuleData(Sender : TObject; Module : TDigitalInputModule);
var
  i : LongInt;
begin
  if (Module <> Nil) then
  begin
    LEDConnected.Lit := Not LEDConnected.Lit;
    with Module do
    begin
      if (Module.ModuleNumber = FModulePosition) then
      begin
        for i := Low(DigitalInputData) to High(DigitalInputData) do
        begin
          if Assigned(DigitalInputLEDArray[i].LED) then
            DigitalInputLEDArray[i].LED.Lit := DigitalInputData[i];
        end; // For i
      end; // If
    end; // With
    if Assigned(FOnNewModuleData) then
      FOnNewModuleData(Self,Module);
  end; // If
end; // TMicroLogix16CHDigitalInputModule.NewModuleData

constructor TMicroLogix16CHDigitalOutputModule.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  BaseModuleCaption := '16CH Digital Output Module';
  FDigitalOutputLEDLabelWidth := 50;
  BuildDigitalOutputLEDArray;
end; // TMicroLogix16CHDigitalOutputModule.Create

destructor TMicroLogix16CHDigitalOutputModule.Destroy;
begin
  inherited Destroy;
end; // TMicroLogix16CHDigitalOutputModule.Destroy

procedure TMicroLogix16CHDigitalInputModule.ReSizeModuleDispaly;
begin
  ParentModule.Height := 70;
  BaseModuleWidth := DigitalInputLEDArray[15].LEDLabel.Left + DigitalInputLEDArray[15].LEDLabel.Width + 2;
end; // TMicroLogix16CHDigitalInputModule.ReSizeModuleDisplay

procedure TMicroLogix16CHDigitalInputModule.BuildDigitalInputLEDArray;
var
  i : LongInt;
  lRow : LongInt;
  lColumn : LongInt;
begin
  lRow := 0;
  lColumn := 0;
  for i := Low(DigitalInputLEDArray) to High(DigitalInputLEDArray) do
  begin
    if Not Assigned(DigitalInputLEDArray[i].LED) then
      DigitalInputLEDArray[i].LED := TDioLED.Create(Nil);
    with DigitalInputLEDArray[i].LED do
    begin
      Parent := ParentModule;
      Top := 16 + (12 * lRow);
      Left := 10 + (FDigitalInputLEDLabelWidth * lColumn);
      Height := 10;
      Width := 10;
      Shape := stRoundRect;
      LitColor := clLime;
    end; // With
    if Not Assigned(DigitalInputLEDArray[i].LEDLabel) then
      DigitalInputLEDArray[i].LEDLabel := TLabel.Create(Nil);
    with DigitalInputLEDArray[i].LEDLabel do
    begin
      Parent := ParentModule;
      Top := 17 + (12 * lRow);
      Left := 22 + (FDigitalInputLEDLabelWidth * lColumn);
      Font.Name := 'Terminal';
      Font.Size := 6;
      Font.Color := clWhite;
      Caption := format('Label %d',[i]);
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
end; // TMicroLogix16CHDigitalOutputModule.BuildDigitalInputLEDArray

function TMicroLogix16CHDigitalOutputModule.GetOutputBitCaption(BitNumber : LongInt) : String;
begin
  if (BitNumber in [Low(DigitalOutputLEDArray)..High(DigitalOutputLEDArray)]) then
  begin
    if Assigned(DigitalOutputLEDArray[BitNumber].LEDLabel) then
    begin
      Result := DigitalOutputLEDArray[BitNumber].LEDLabel.Caption;
    end; // if
  end; // If
end; // TMicroLogix16CHDigitalOutputModule.GetOutputBitCaption

procedure TMicroLogix16CHDigitalOutputModule.SetOutputBitCaption(BitNumber : LongInt; Caption : String);
begin
  if (BitNumber in [Low(DigitalOutputLEDArray)..High(DigitalOutputLEDArray)]) then
  begin
    if Assigned(DigitalOutputLEDArray[BitNumber].LEDLabel) then
    begin
      DigitalOutputLEDArray[BitNumber].LEDLabel.Caption := Caption;
    end; // if
  end; // If
end; // TMicroLogix16CHDigitalOutputModule.SetOutputBitCaption

procedure TMicroLogix16CHDigitalOutputModule.SetDigitalOutputLEDLabelWidth(Value : LongInt);
begin
  FDigitalOutputLEDLabelWidth := Value;
  BuildDigitalOutputLEDArray;
end; // TMicroLogix16CHDigitalOutputModule.SetDigitalOutputLEDLabelWidth

procedure TMicroLogix16CHDigitalOutputModule.BuildDigitalOutputLEDArray;
var
  i : LongInt;
  lRow : LongInt;
  lColumn : LongInt;
begin
  lRow := 0;
  lColumn := 0;
  for i := Low(DigitalOutputLEDArray) to High(DigitalOutputLEDArray) do
  begin
    if Not Assigned(DigitalOutputLEDArray[i].LED) then
      DigitalOutputLEDArray[i].LED := TDioLED.Create(Nil);
    with DigitalOutputLEDArray[i].LED do
    begin
      Parent := ParentModule;
      Top := 16 + (12 * lRow);
      Left := 10 + (FDigitalOutputLEDLabelWidth * lColumn);
      Height := 10;
      Width := 10;
      Shape := stRoundRect;
      LitColor := clLime;
    end; // With
    if Not Assigned(DigitalOutputLEDArray[i].LEDLabel) then
      DigitalOutputLEDArray[i].LEDLabel := TLabel.Create(Nil);
    with DigitalOutputLEDArray[i].LEDLabel do
    begin
      Parent := ParentModule;
      Top := 17 + (12 * lRow);
      Left := 22 + (FDigitalOutputLEDLabelWidth * lColumn);
      Font.Name := 'Terminal';
      Font.Size := 6;
      Font.Color := clWhite;
      Caption := format('Label %d',[i]);
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
end; // TMicroLogix16CHDigitalOutputModule.BuildDigitalOutputLEDArray

procedure TMicroLogix16CHDigitalOutputModule.NewModuleData(Sender : TObject; Module : TDigitalOutputModule);
var
  i : LongInt;
begin
  if (Module <> Nil) then
  begin
    LEDConnected.Lit := Not LEDConnected.Lit;
    with Module do
    begin
      if (Module.ModuleNumber = FModulePosition) then
      begin
        for i := Low(DigitalOutputData) to High(DigitalOutputData) do
        begin
          if Assigned(DigitalOutputLEDArray[i].LED) then
            DigitalOutputLEDArray[i].LED.Lit := DigitalOutputData[i];
        end; // For i
      end; // If
    end; // With
    if Assigned(FOnNewModuleData) then
      FOnNewModuleData(Self,Module);
  end; // If
end; // TMicroLogix16CHDigitalOutputModule.NewModuleData

procedure TMicroLogix16CHDigitalOutputModule.ReSizeModuleDispaly;
begin
  ParentModule.Height := 70;
  BaseModuleWidth := DigitalOutputLEDArray[15].LEDLabel.Left + DigitalOutputLEDArray[15].LEDLabel.Width + 2;
end; // TMicroLogix16CHDigitalOutputModule.ReSizeModuleDisplay

constructor TMicroLogix8CHRelayedDigitalOutputModule.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  BaseModuleCaption := '8CH Relayed Digital Output Module';
  FRelayedDigitalOutputLEDLabelWidth := 50;
end; // TMicroLogix8CHRelayedDigitalOutputModule.Create

function TMicroLogix8CHRelayedDigitalOutputModule.GetOutputBitCaption(BitNumber : LongInt) : String;
begin
  if (BitNumber in [Low(DigitalOutputLEDArray)..High(DigitalOutputLEDArray)]) then
  begin
    if Assigned(DigitalOutputLEDArray[BitNumber].LEDLabel) then
    begin
      Result := DigitalOutputLEDArray[BitNumber].LEDLabel.Caption;
    end; // if
  end; // If
end; // TMicroLogix8CHRelayedDigitalOutputModule.GetOutputBitCaption

procedure TMicroLogix8CHRelayedDigitalOutputModule.SetOutputBitCaption(BitNumber : LongInt; Caption : String);
begin
  if (BitNumber in [Low(DigitalOutputLEDArray)..High(DigitalOutputLEDArray)]) then
  begin
    if Assigned(DigitalOutputLEDArray[BitNumber].LEDLabel) then
    begin
      DigitalOutputLEDArray[BitNumber].LEDLabel.Caption := Caption;
    end; // if
  end; // If
end; // TMicroLogix8CHRelayedDigitalOutputModule.SetOutputBitCaption

procedure TMicroLogix8CHRelayedDigitalOutputModule.SetRelayedDigitalOutputLEDLabelWidth(Value : LongInt);
begin
  FRelayedDigitalOutputLEDLabelWidth := Value;
  BuildRelayedDigitalOutputLEDArray;
  ReSizeModuleDisplay;
end; // TMicroLogix8CHRelayedDigitalOutputModule.SetRelayedDigitaloutputLEDLabelWidth

procedure TMicroLogix8CHRelayedDigitalOutputModule.BuildRelayedDigitalOutputLEDArray;
var
  i : LongInt;
  lRow : LongInt;
  lColumn : LongInt;
begin
  lRow := 0;
  lColumn := 0;
  for i := Low(DigitalOutputLEDArray) to High(DigitalOutputLEDArray) do
  begin
    if Not Assigned(DigitalOutputLEDArray[i].LED) then
      DigitalOutputLEDArray[i].LED := TDioLED.Create(Nil);
    with DigitalOutputLEDArray[i].LED do
    begin
      Parent := ParentModule;
      Top := 16 + (12 * lRow);
      Left := 10 + (FRelayedDigitalOutputLEDLabelWidth * lColumn);
      Height := 10;
      Width := 10;
      Shape := stRoundRect;
      LitColor := clLime;
    end; // With
    if Not Assigned(DigitalOutputLEDArray[i].LEDLabel) then
      DigitalOutputLEDArray[i].LEDLabel := TLabel.Create(Nil);
    with DigitalOutputLEDArray[i].LEDLabel do
    begin
      Parent := ParentModule;
      Top := 17 + (12 * lRow);
      Left := 22 + (FRelayedDigitalOutputLEDLabelWidth * lColumn);
      Font.Name := 'Terminal';
      Font.Size := 6;
      Font.Color := clWhite;
      Caption := format('Label %d',[i]);
      Transparent := True;
      Height := 13;
      Width := FRelayedDigitalOutputLEDLabelWidth;
    end; // With
    inc(lRow);
    if (lRow > 2) then
    begin
      inc(lColumn);
      lRow := 0;
    end; // If
  end; // For i
  ReSizeModuleDisplay;
end; // TMicroLogix8CHRelayedDigitalOutputModule.BuildRelayedDigitalOutputLEDArray

procedure TMicroLogix8CHRelayedDigitalOutputModule.NewModuleData(Sender : TObject; Module : TRelayedDigitalOutputModule);
var
  i : LongInt;
begin
  if (Module <> Nil) then
  begin
    LEDConnected.Lit := Not LEDConnected.Lit;
    with Module do
    begin
      if (Module.ModuleNumber = FModulePosition) then
      begin
        for i := Low(RelayedDigitalOutputData) to High(RelayedDigitalOutputData) do
        begin
          if Assigned(DigitalOutputLEDArray[i].LED) then
            DigitalOutputLEDArray[i].LED.Lit := RelayedDigitalOutputData[i];
        end; // For i
      end; // If
    end; // With
    if Assigned(FOnNewModuleData) then
      FOnNewModuleData(Self,Module);
  end; // If
end; // TMicroLogix8CHRelayedDigitalOutputModule.NewModuleData

destructor TMicroLogix8CHRelayedDigitalOutputModule.Destroy;
begin
  inherited Destroy;
end; // TMicroLogix8CHRelayedDigitalOutputModule.Destory

procedure TMicroLogix8CHRelayedDigitalOutputModule.ReSizeModuleDisplay;
begin
  BaseModuleWidth := DigitalOutputLEDArray[High(DigitalOutputLEDArray)].LEDLabel.Left + DigitalOutputLEDArray[High(DigitalOutputLEDArray)].LEDLabel.Width + 2;
  ParentModule.Height := 55;
end; // TMicroLogix8CHRelayedDigitalOutputModule.ReSizeModuleDisplay

constructor TMicroLogix4CHAnalogInputModule.Create(AOwner : TComponent);
var
  i : LongInt;
  lColumn : LongInt;
  MyLabel : TLabel;
begin
  inherited Create(AOwner);
  BaseModuleCaption := '4CH Analog Input Module';
  LEDModuleError := TDioLED.Create(Nil);
  with LEDModuleError do
  begin
    Parent := ParentModule;
    Top := 35;
    Left := 3;
    Height := 30;
    Width := 70;
    Shape := stRoundRect;
    LitColor := clRed;
    Lit := False;
  end; // With
  lblModuleError := TLabel.Create(Nil);
  with lblModuleError do
  begin
    Parent := ParentModule;
    Top := 37;
    Left := 4;
    Font.Color := $001E1E1E;
    Font.Style := [fsBold];
    Transparent := True;
    Alignment := taCenter;
    WordWrap := True;
    Caption := 'Module Error';
    Height := 30;
    Width := 60;
  end; // With
  lColumn := 0;
  for i := Low(AnalogInputDVMArray) to High(AnalogInputDVMArray) do
  begin
    AnalogInputDVMArray[i].AnalogChannel.Guage := TDVM.create(Nil);
    with AnalogInputDVMArray[i].AnalogChannel.Guage do
    begin
      Parent := ParentModule;
      Top := 20;
      Left := 75 + (lColumn * 127);
      Height := 58;
      Width := 125;
      Font.Color := clBlack;
      Font.Size := 20;
      Font.Name := 'Arial';
      Font.Style := [];
      TitleFont.Color := clWindowText;
      TitleFont.Size :=8;
      TitleFont.Name := 'Arial';
      TitleFont.Style := [];
      UnitsFont.Color := clWindowText;
      UnitsFont.Size := 8;
      UnitsFont.Name := 'Arial';
      UnitsFont.Style := [];
      Title := format('Analog Input %d',[i]);
    end; // With
    AnalogInputDVMArray[i].AnalogChannel.LEDUR := TDioLED.Create(Nil);
    with AnalogInputDVMArray[i].AnalogChannel.LEDUR do
    begin
      Parent := AnalogInputDVMArray[i].AnalogChannel.Guage;
      Top := 39;
      Left := 5;
      Height := 13;
      Width := 13;
      Shape := stRoundRect;
      LitColor := clRed;
    end; // With
    AnalogInputDVMArray[i].AnalogChannel.LEDOR := TDioLED.Create(Nil);
    with AnalogInputDVMArray[i].AnalogChannel.LEDOR do
    begin
      Parent := AnalogInputDVMArray[i].AnalogChannel.Guage;
      Top := 39;
      Left := 107;
      Height := 13;
      Width := 13;
      Shape := stRoundRect;
      LitColor := clRed;
    end; // With
    MyLabel := TLabel.Create(Nil); // UR Label
    with MyLabel do
    begin
      Parent := AnalogInputDVMArray[i].AnalogChannel.Guage;
      Top := 39;
      Left := 20;
      Font.Color := clBlack;
      Font.Name := 'Arial';
      Font.Size := 8;
      Font.Style := [];
      Caption := 'UR';
      Height := 14;
      Width := 14;
    end; // With
    MyLabel := TLabel.Create(Nil); // OR Label
    with MyLabel do
    begin
      Parent := AnalogInputDVMArray[i].AnalogChannel.Guage;
      Top := 39;
//      Left := 92;
      Left := 90;
      Font.Color := clBlack;
      Font.Name := 'Arial';
      Font.Size := 8;
      Font.Style := [];
      Caption := 'OR';
      Height := 14;
      Width := 14;
    end; // With
    inc(lColumn);
  end; // For i
  ReSizeModuleDisplay;
end; // TMicroLogix4CHAnalogInputModule.Create

destructor TMicroLogix4CHAnalogInputModule.Destroy;
begin
  inherited Destroy;
end; // TMicroLogix4CHAnalogInputModule.Destroy

function TMicroLogix4CHAnalogInputModule.GetAnalogInputChannel(Channel : LongInt) : TAnalogInputChannel;
begin
  if (Channel in [Low(AnalogInputDVMArray)..High(AnalogInputDVMArray)]) then
    Result := AnalogInputDVMArray[Channel];
end; // TMicrologixProcessor.GetAnalogInputChannel

procedure TMicroLogix4CHAnalogInputModule.SetAnalogInputChannel(Channel : LongInt; NewConfig : TAnalogInputChannel);
begin
  if (Channel in [Low(AnalogInputDVMArray)..High(AnalogInputDVMArray)]) then
    AnalogInputDVMArray[Channel] := NewConfig;
end; // TMicroLogixProcessor.SetAnalogInputChannel

procedure TMicroLogix4CHAnalogInputModule.NewModuleData(Sender : TObject; Module : TAnalogInputModule);
var
  i : LongInt;
  lModuleError : Boolean;
begin
  if (Module <> Nil) then
  begin
    LEDConnected.Lit := Not LEDConnected.Lit;
    lModuleError := False;
    with Module do
    begin
      if (ModuleNumber = FModulePosition) then
      begin
        for i := Low(AnalogInputDVMArray) to High(AnalogInputDVMArray) do
        begin
          if (AnalogInputDVMArray[i].AnalogChannel.AtoDRange = 0) then
            AnalogInputDVMArray[i].AnalogChannel.Guage.value := 0
          else
            AnalogInputDVMArray[i].AnalogChannel.Guage.value := (ChannelDataValue[i] / AnalogInputDVMArray[i].AnalogChannel.AtoDRange) * AnalogInputDVMArray[i].AnalogChannel.Scale;
          AnalogInputDVMArray[i].AnalogChannel.LEDUR.Lit := ChannelUnderRangeFlag[i];
          AnalogInputDVMArray[i].AnalogChannel.LEDOR.Lit := ChannelOverRangeFlag[i];
          lModuleError := lModuleError or (ChannelUnderRangeFlag[i] or ChannelOverRangeFlag[i] or ChannelStatus[i]);
        end; // For i
      end; // If
    end; // With
    LEDModuleError.Lit := lModuleError;
    if Assigned(FOnNewModuleData) then
      FOnNewModuleData(Self,Module);
  end; // If
end; // TMicroLogix4CHAnalogInputModule.NewModuleData

procedure TMicroLogix4CHAnalogInputModule.ReSizeModuleDisplay;
begin
  BaseModuleWidth := AnalogInputDVMArray[3].AnalogChannel.Guage.Left + AnalogInputDVMArray[3].AnalogChannel.Guage.Width + 5;
  ParentModule.Height := AnalogInputDVMArray[3].AnalogChannel.Guage.Top + AnalogInputDVMArray[3].AnalogChannel.Guage.Height + 5
end; // TMicroLogix4CHAnalogInputModule.ReSizeModuleDisplay

constructor TMicroLogix4CHRTDAnalogInputModule.Create(AOwner : TComponent);
var
  i : LongInt;
  lColumn : LongInt;
  MyLabel : TLabel;
begin
  inherited Create(AOwner);
  BaseModuleCaption := '4CH RTD Analog Input Module';
  LEDModuleError := TDioLED.Create(Nil);
  with LEDModuleError do
  begin
    Parent := ParentModule;
    Top := 35;
    Left := 3;
    Height := 30;
    Width := 70;
    Shape := stRoundRect;
    LitColor := clRed;
    Lit := False;
  end; // With
  lblModuleError := TLabel.Create(Nil);
  with lblModuleError do
  begin
    Parent := ParentModule;
    Top := 37;
    Left := 4;
    Font.Color := $001E1E1E;
    Font.Style := [fsBold];
    Transparent := True;
    Alignment := taCenter;
    WordWrap := True;
    Caption := 'Module Error';
    Height := 30;
    Width := 60;
  end; // With
  lColumn := 0;
  for i := Low(RTDAnalogInputDVMArray) to High(RTDAnalogInputDVMArray) do
  begin
    RTDAnalogInputDVMArray[i].RTDAnalogChannel.Guage := TDVM.create(Nil);
    with RTDAnalogInputDVMArray[i].RTDAnalogChannel.Guage do
    begin
      Parent := ParentModule;
      Top := 20;
      Left := 75 + (lColumn * 127);
      Height := 58;
      Width := 125;
      Font.Color := clBlack;
      Font.Size := 20;
      Font.Name := 'Arial';
      Font.Style := [];
      TitleFont.Color := clWindowText;
      TitleFont.Size :=8;
      TitleFont.Name := 'Arial';
      TitleFont.Style := [];
      UnitsFont.Color := clWindowText;
      UnitsFont.Size := 8;
      UnitsFont.Name := 'Arial';
      UnitsFont.Style := [];
      Title := format('Analog Input %d',[i]);
    end; // With
    RTDAnalogInputDVMArray[i].RTDAnalogChannel.LEDUROR := TDioLED.Create(Nil);
    with RTDAnalogInputDVMArray[i].RTDAnalogChannel.LEDUROR do
    begin
      Parent := RTDAnalogInputDVMArray[i].RTDAnalogChannel.Guage;
      Top := 39;
      Left := 5;
      Height := 13;
      Width := 13;
      Shape := stRoundRect;
      LitColor := clRed;
    end; // With
    RTDAnalogInputDVMArray[i].RTDAnalogChannel.LEDOC := TDioLED.Create(Nil);
    with RTDAnalogInputDVMArray[i].RTDAnalogChannel.LEDOC do
    begin
      Parent := RTDAnalogInputDVMArray[i].RTDAnalogChannel.Guage;
      Top := 39;
      Left := 107;
      Height := 13;
      Width := 13;
      Shape := stRoundRect;
      LitColor := clRed;
    end; // With
    RTDAnalogInputDVMArray[i].RTDAnalogChannel.LabelUROR := TLabel.Create(Nil); // UROR Label
    with RTDAnalogInputDVMArray[i].RTDAnalogChannel.LabelUROR do
    begin
      Parent := RTDAnalogInputDVMArray[i].RTDAnalogChannel.Guage;
      Top := 39;
      Left := 20;
      Font.Color := clBlack;
      Font.Name := 'Arial';
      Font.Size := 8;
      Font.Style := [];
      Caption := '';       // Initialize caption to '' (blank)
      Height := 14;
      Width := 14;
    end; // With
    MyLabel := TLabel.Create(Nil); // OC Label
    with MyLabel do
    begin
      Parent := RTDAnalogInputDVMArray[i].RTDAnalogChannel.Guage;
      Top := 39;
//      Left := 92;
      Left := 90;
      Font.Color := clBlack;
      Font.Name := 'Arial';
      Font.Size := 8;
      Font.Style := [];
      Caption := 'OC';
      Height := 14;
      Width := 14;
    end; // With
    inc(lColumn);
  end; // For i
  ReSizeModuleDisplay;
end; // TMicroLogix4CHRTDAnalogInputModule.Create

destructor TMicroLogix4CHRTDAnalogInputModule.Destroy;
begin
  inherited Destroy;
end; // TMicroLogix4CHRTDAnalogInputModule.Destroy

function TMicroLogix4CHRTDAnalogInputModule.GetRTDAnalogInputChannel(Channel : LongInt) : TRTDAnalogInputChannel;
begin
  if (Channel in [Low(RTDAnalogInputDVMArray)..High(RTDAnalogInputDVMArray)]) then
    Result := RTDAnalogInputDVMArray[Channel];
end; // TMicrologix4CHRTDAnalogInputModule.GetRTDAnalogInputChannel

procedure TMicroLogix4CHRTDAnalogInputModule.SetRTDAnalogInputChannel(Channel : LongInt; NewConfig : TRTDAnalogInputChannel);
begin
  if (Channel in [Low(RTDAnalogInputDVMArray)..High(RTDAnalogInputDVMArray)]) then
    RTDAnalogInputDVMArray[Channel] := NewConfig;
end; // TMicroLogix4CHRTDAnalogInputModule.SetAnalogInputChannel

procedure TMicroLogix4CHRTDAnalogInputModule.NewModuleData(Sender : TObject; Module : TRTDAnalogInputModule);
var
  i : LongInt;
  lModuleError : Boolean;
begin
  if (Module <> Nil) then
  begin
    LEDConnected.Lit := Not LEDConnected.Lit;
    lModuleError := False;
    with Module do
    begin
      if (ModuleNumber = FModulePosition) then
      begin
        for i := Low(RTDAnalogInputDVMArray) to High(RTDAnalogInputDVMArray) do
        begin
          if (RTDAnalogInputDVMArray[i].RTDAnalogChannel.AtoDRange = 0) then
            RTDAnalogInputDVMArray[i].RTDAnalogChannel.Guage.value := 0
          else
            RTDAnalogInputDVMArray[i].RTDAnalogChannel.Guage.value := (ChannelDataValue[i] / RTDAnalogInputDVMArray[i].RTDAnalogChannel.AtoDRange) * RTDAnalogInputDVMArray[i].RTDAnalogChannel.Scale;
          // Set the Under-range / Over-range LED if either one is lit
          if ChannelOverRangeFlag[i] then
          begin
            RTDAnalogInputDVMArray[i].RTDAnalogChannel.LEDUROR.Lit := ChannelOverRangeFlag[i];
            RTDAnalogInputDVMArray[i].RTDAnalogChannel.LabelUROR.Caption := 'OR';
          end
          else if ChannelUnderRangeFlag[i] then
          begin
            RTDAnalogInputDVMArray[i].RTDAnalogChannel.LEDUROR.Lit := ChannelUnderRangeFlag[i];
            RTDAnalogInputDVMArray[i].RTDAnalogChannel.LabelUROR.Caption := 'UR';
          end
          else
          begin
            RTDAnalogInputDVMArray[i].RTDAnalogChannel.LEDUROR.Lit := False;
          end;
          RTDAnalogInputDVMArray[i].RTDAnalogChannel.LEDOC.Lit := ChannelOpenCircuitFlag[i];
          lModuleError := lModuleError or (ChannelUnderRangeFlag[i] or ChannelOverRangeFlag[i] or ChannelStatus[i]);
        end; // For i
      end; // If
    end; // With
    LEDModuleError.Lit := lModuleError;
    if Assigned(FOnNewModuleData) then
      FOnNewModuleData(Self,Module);
  end; // If
end; // TMicroLogix4CHRTDAnalogInputModule.NewModuleData

procedure TMicroLogix4CHRTDAnalogInputModule.ReSizeModuleDisplay;
begin
  BaseModuleWidth := RTDAnalogInputDVMArray[3].RTDAnalogChannel.Guage.Left + RTDAnalogInputDVMArray[3].RTDAnalogChannel.Guage.Width + 5;
  ParentModule.Height := RTDAnalogInputDVMArray[3].RTDAnalogChannel.Guage.Top + RTDAnalogInputDVMArray[3].RTDAnalogChannel.Guage.Height + 5
end; // TMicroLogix4CHRTDAnalogInputModule.ReSizeModuleDisplay

constructor TMicroLogix4CHAnalogOutputModule.Create(AOwner : TComponent);
var
  i : LongInt;
  lColumn : LongInt;
  MyLabel : TLabel;
begin
  inherited Create(AOwner);
  BaseModuleCaption := '4CH Analog Output';
  LEDModuleError := TDioLED.Create(Nil);
  with LEDModuleError do
  begin
    Parent := ParentModule;
    Top := 35;
    Left := 3;
    Height := 30;
    Width := 70;
    Shape := stRoundRect;
    LitColor := clRed;
    Lit := False;
  end; // With
  lblModuleError := TLabel.Create(Nil);
  with lblModuleError do
  begin
    Parent := ParentModule;
    Top := 37;
    Left := 4;
    Font.Color := $001E1E1E;
    Font.Style := [fsBold];
    Transparent := True;
    Alignment := taCenter;
    WordWrap := True;
    Caption := 'Module Error';
    Height := 30;
    Width := 60;
  end; // With
  lColumn := 0;
  for i := Low(AnalogOutputDVMArray) to High(AnalogOutputDVMArray) do
  begin
    AnalogOutputDVMArray[i].AnalogChannel.Guage := TDVM.create(Nil);
    with AnalogOutputDVMArray[i].AnalogChannel.Guage do
    begin
      Parent := ParentModule;
      Top := 20;
      Left := 75 + (lColumn * 127);
      Height := 58;
      Width := 125;
      Font.Color := clBlack;
      Font.Size := 20;
      Font.Name := 'Arial';
      Font.Style := [];
      TitleFont.Color := clWindowText;
      TitleFont.Size :=8;
      TitleFont.Name := 'Arial';
      TitleFont.Style := [];
      UnitsFont.Color := clWindowText;
      UnitsFont.Size := 8;
      UnitsFont.Name := 'Arial';
      UnitsFont.Style := [];
      Title := format('Analog Output %d',[i]);
    end; // With
    AnalogOutputDVMArray[i].AnalogChannel.LEDUR := TDioLED.Create(Nil);
    with AnalogOutputDVMArray[i].AnalogChannel.LEDUR do
    begin
      Parent := AnalogOutputDVMArray[i].AnalogChannel.Guage;
      Top := 39;
      Left := 5;
      Height := 13;
      Width := 13;
      Shape := stRoundRect;
      LitColor := clRed;
    end; // With
    AnalogOutputDVMArray[i].AnalogChannel.LEDOR := TDioLED.Create(Nil);
    with AnalogOutputDVMArray[i].AnalogChannel.LEDOR do
    begin
      Parent := AnalogOutputDVMArray[i].AnalogChannel.Guage;
      Top := 39;
      Left := 107;
      Height := 13;
      Width := 13;
      Shape := stRoundRect;
      LitColor := clRed;
    end; // With
    MyLabel := TLabel.Create(Nil); // OR Label
    with MyLabel do
    begin
      Parent := AnalogOutputDVMArray[i].AnalogChannel.Guage;
      Top := 39;
      Left := 20;
      Font.Color := clBlack;
      Font.Name := 'Arial';
      Font.Size := 8;
      Font.Style := [];
      Caption := 'UR';
      Height := 14;
      Width := 14;
    end; // With
    MyLabel := TLabel.Create(Nil); // OR Label
    with MyLabel do
    begin
      Parent := AnalogOutputDVMArray[i].AnalogChannel.Guage;
      Top := 39;
      Left := 92;
      Font.Color := clBlack;
      Font.Name := 'Arial';
      Font.Size := 8;
      Font.Style := [];
      Caption := 'OR';
      Height := 14;
      Width := 14;
    end; // With
    AnalogOutputDVMArray[i].InputField := TOvcNumericField.Create(Nil);
    with AnalogOutputDVMArray[i].InputField do
    begin
      Parent := ParentModule;
      Top := AnalogOutputDVMArray[i].AnalogChannel.Guage.Top + AnalogOutputDVMArray[i].AnalogChannel.Guage.Height + 1;
      Left := AnalogOutputDVMArray[i].AnalogChannel.Guage.Left;
      Height := 21;
      Width := 67;
      Font.Color := clBlack;
      DataType := nftSingle;
      PictureMask := '##.###';
      OnClick := InputFieldClick;
      Tag := 0;
    end; // With
    AnalogOutputDVMArray[i].InputButton := TButton.Create(Nil);
    with AnalogOutputDVMArray[i].InputButton do
    begin
      Parent := ParentModule;
      Top := AnalogOutputDVMArray[i].AnalogChannel.Guage.Top + AnalogOutputDVMArray[i].AnalogChannel.Guage.Height + 1;
      Left := AnalogOutputDVMArray[i].InputField.Left + AnalogOutputDVMArray[i].InputField.Width + 1;
      Height := 21;
      Width := 56;
      Font.Color := clBlack;
      Tag := i;
      Caption := format('Chan%d',[i]);
      OnClick := ButtonClick;
    end; // With
    inc(lColumn);
  end; // For i
  ReSizeModuleDisplay;
end; // TMicroLogix4CHAnalogOutputModule.Create

destructor TMicroLogix4CHAnalogOutputModule.Destroy;
begin
  inherited Destroy;
end; // TMicroLogix4CHAnalogOutputModule.Destroy

procedure TMicroLogix4CHAnalogOutputModule.InputFieldClick(Sender : TObject);
begin
  (Sender as TOvcNumericField).SelectAll;
end; // TMicroLogix4CHAnalogOutputModule.InputFieldClick

procedure TMicroLogix4CHAnalogOutputModule.ButtonClick(Sender : TObject);
var
  myTag : Integer;
  CmdWord : Integer;
  Value : Integer;
begin
  myTag := (Sender as TButton).Tag;
  if (myTag in [0..3]) then
  begin
    CmdWord := AnalogOutputDVMArray[myTag].InputField.Tag;
    if Assigned(FPLCController) then
    begin
      Value := Trunc((AnalogOutputDVMArray[myTag].InputField.AsFloat / AnalogOutputDVMArray[myTag].AnalogChannel.Scale) * FPLCController.ExpandedIOResolution);
      FPLCController.WriteWordToPLC('O',CmdWord,1,Value);
    end; // If
  end; // If
end; // TMicroLogix4CHAnalogOutputModule.ButtonClick

function TMicroLogix4CHAnalogOutputModule.GetAnalogOutputChannel(Channel : LongInt) : TAnalogOutputChannel;
begin
  if (Channel in [Low(AnalogOutputDVMArray)..High(AnalogOutputDVMArray)]) then
    Result := AnalogOutputDVMArray[Channel];
end; // TMicroLogix4CHAnalogOutputModule.GetAnalogOutputChannel

procedure TMicroLogix4CHAnalogOutputModule.SetAnalogOutputChannel(Channel : LongInt; NewConfig : TAnalogOutputChannel);
begin
  if (Channel in [Low(AnalogOutputDVMArray)..High(AnalogOutputDVMArray)]) then
    AnalogOutputDVMArray[Channel] := NewConfig;
end; // TMicroLogix4CHAnalogOutputModule.SetAnalogOutputChannel

procedure TMicroLogix4CHAnalogOutputModule.SetCmdOutputWords(Channel : LongInt; WordNum : LongInt);
begin
  if (Channel in [0..3]) then
  begin
    AnalogOutputDVMArray[Channel].InputField.Tag := WordNum;
  end; // If
end; // TMicroLogix4CHAnalogOutputModule.SetCmdOutputWords

function TMicroLogix4CHAnalogOutputModule.GetCmdOutputWords(Channel : LongInt) : LongInt;
begin
  if (Channel in [0..3]) then
    Result := AnalogOutputDVMArray[Channel].InputField.Tag
  else
    Result := -1;
end; // TMicroLogix4CHAnalogOutputModule.GetCmdOutputWords

procedure TMicroLogix4CHAnalogOutputModule.NewModuleData(Sender : TObject; Module : TAnalogOutputModule);
var
  i : LongInt;
  lModuleError : Boolean;
begin
  if (Module <> Nil) then
  begin
    LEDConnected.Lit := Not LEDConnected.Lit;
    lModuleError := False;
    with Module do
    begin
      if (ModuleNumber = FModulePosition) then
      begin
        for i := Low(AnalogOutputDVMArray) to High(AnalogOutputDVMArray) do
        begin
          if (AnalogOutputDVMArray[i].AnalogChannel.AtoDRange = 0) then
            AnalogOutputDVMArray[i].AnalogChannel.Guage.value := 0
          else
            AnalogOutputDVMArray[i].AnalogChannel.Guage.value := (ChannelDataValue[i] / AnalogOutputDVMArray[i].AnalogChannel.AtoDRange) * AnalogOutputDVMArray[i].AnalogChannel.Scale;
          AnalogOutputDVMArray[i].AnalogChannel.LEDUR.Lit := ChannelUnderRangeFlag[i];
          AnalogOutputDVMArray[i].AnalogChannel.LEDOR.Lit := ChannelOverRangeFlag[i];
          lModuleError := lModuleError or (ChannelUnderRangeFlag[i] or ChannelOverRangeFlag[i] or ChannelStatus[i]);
        end; // For i
      end; // If
    end; // With
    LEDModuleError.Lit := lModuleError;
    if Assigned(FOnNewModuleData) then
      FOnNewModuleData(Self,Module);
  end; // If
end; // TMicroLogix4CHAnalogOutputModule.NewModuleData

procedure TMicroLogix4CHAnalogOutputModule.ReSizeModuleDisplay;
begin
  BaseModuleWidth := AnalogOutputDVMArray[3].AnalogChannel.Guage.Left + AnalogOutputDVMArray[3].AnalogChannel.Guage.Width + 5;
  ParentModule.Height := AnalogOutputDVMArray[3].AnalogChannel.Guage.Top + AnalogOutputDVMArray[3].AnalogChannel.Guage.Height + 25;
end; // TMicroLogix4CHAnalogOutputModule.ReSizeModuleDisplay

end.

