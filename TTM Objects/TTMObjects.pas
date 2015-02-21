unit TTMObjects;

interface

uses
   Windows, SysUtils, Classes, DVM;

const
  INVALID_INDEX : SmallInt = -1;

type
  TSetPointControlType = (SPC_Base,SPC_Load,SPC_Position,SPC_Slip,SPC_Camber,SPC_Drive,SPC_Inflation);
  TCalculationMethod = (Calc_Linear,Calc_Polynomial,Calc_Power);
  TSpeedMeasurementMethod = (M_Normal,M_Samples);
  TCalFactorNum = (CF1{1st Degree},CF2{2nd Degree},CF3{3rd Degree});

  TCalFactorArray = Array[CF1..CF3] of Double;
  TDescription = Array[0..24] of Char;

  TPIDConfiguration = packed record
    P  : LongInt;
    I  : LongInt;
    D  : LongInt;
    CN : LongInt;
    CP : LongInt;
    Filler : Array[0..255] of Byte;
  end; // TPIDConfiguration

  TChannelConfig = packed record
    Description       : TDescription;       // Channel Description
    CalcMethod        : TCalculationMethod; // Linear or Polynomial
    AtoDRange_Hi      : SmallInt;           // Max AD Range
    AtoDRange_Lo      : SmallInt;           // Min AD Range
    Scale             : Double;             // (Volts, mA, etc...)
    CalUnits          : TUnits;             // Channel Calibration Units as defined in Unit "DVM"
    DisplayUnits      : TUnits;             // Channel Display Units...
    CalFactor         : TCalFactorArray;    // Channel Cal Factors...
    CalOffset         : Double;             // Channel Offset...
    ChannelZero       : Double;             // Tear reading for channel...
    UseCalOffset      : Boolean;            // Determins if the input uses the "CalOffset" or "ChannelZero" when computing the EU value for display.
    Guage             : TDVM;               // Guage for display of Channel
    Filler : Array[0..255] of Byte;
  end; // TConfigureInputChannel

  TSPControlConfiguration = packed record
    InputConfig       : TChannelConfig;
    OutputConfig      : TChannelConfig;
    PIDConfig         : TPIDConfiguration;
    RequiresOutputCal : Boolean;
  end; // TSPControlConfiguration

  // Storage record used when recalling saved channel data from file.
  TChannelRecord = packed record
    ChanID        : DWord;
    InputOnly     : Boolean; // If Input only, Output and PID configuration will be ignored.
    Filler        : Array[0..255] of Byte;
    Configuration : TSPControlConfiguration;
  end; // TChannelRecord

//  TDeltaSampleConfiguration = packed record
//    SamplesPerSecond       : DWord; // DAP Code samples per second
//    RoadWheelRevsPerPeriod : DWord;
//    RWConstant             : Single; // 5 = 67" drum
//  end; // TDeltaSampleConfiguration

//  TDriveConfiguration = packed record
//    SpeedMeasurementType : TSpeedMeasurementMethod;
//    NormalConfig         : TSPControlConfiguration;
//    DeltaSampleConfig    : TDeltaSampleConfiguration;
//  end; // TDriveConfiguration

//  TOnNewSetPoint = procedure(Sender : TObject; SPCNumber : Byte; SetPointControlType : TSetPointControlType; NewSetPoint : SmallInt) of Object;
//  TOnNewPIDValues = procedure(Sender : TObject; SPCNumber : Byte; SetPointControlType : TSetPointControlType; PIDConfig : TPIDConfiguration) of Object;

  TInputChannel = class(TComponent)
  private
    FIntRawInput      : Double;
    FScaledInputValue : Double;
    FEUInputValue     : Double;
    FInputConfig      : TChannelConfig;
  protected
    // Functions and Procedures...
    function GetInputChanDescription : String;
    function GetInputCalFactor(Index : TCalFactorNum) : Double;
    procedure SetInputCalFactor(Index : TCalFactorNum; Value : Double);
    function GetInputCalOffset : Double;
    procedure SetInputCalOffset(Value : Double);
    function GetInputCalUnits : TUnits;
    function GetInputDisplayUnits : TUnits;
    procedure SetInputCalUnits(Value : TUnits);
    procedure SetInputDisplayUnits(Value : TUnits);
    function GetInputScale : Double;
    procedure SetInputScale(Value : Double);
    function GetInputGuage : TDVM;
    procedure SetInputGuage(Value : TDVM);
    function GetInputChannelZero : Double;
    procedure SetInputChannelZero(Value : Double);
    function GetHiADRange : SmallInt;
    procedure SetHiADRange(Value : SmallInt);
    function GetLoADRange : SmallInt;
    procedure SetLoADRange(Value : SmallInt);
    procedure SetRawInput(Value : Double);
    function GetCalcType : TCalculationMethod;
    procedure SetCalcType(Value : TCalculationMethod);
    function GetUseCalOffset : Boolean;
    procedure SetUseCalOffset(Value : Boolean);
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    // Utilty Functions and Procedures...
    procedure Config_InputChannel(Var ChannelConfig : TChannelConfig);
    function Read_InputConfig : TChannelConfig;
    // Properties...
    property Input_ChanDescription : String read GetInputChanDescription;       // Description for the Input Channel...
    property Input_CalFactor[Index : TCalFactorNum] : Double read GetInputCalFactor write SetInputCalFactor; // Cal Factors computed during calibration...
    property Input_CalOffset : Double read GetInputCalOffset write SetInputCalOffset; // Offset computed during calibration...
    property Input_CalUnits : TUnits read GetInputCalUnits write SetInputCalUnits; // Units that are used to calibrate Input...
    property Input_DisplayUnits : TUnits read GetInputDisplayUnits write SetInputDisplayUnits; // Units to apply to associated guage...
    property Input_Scale : Double read GetInputScale write SetInputScale;                           // Volts, mA, ect...
    property Input_Guage : TDVM read GetInputGuage write SetInputGuage;         // Guage to associate with Input...
    property Input_ChannelZero : Double read GetInputChannelZero write SetInputChannelZero; // Zero (Tare) for Input...
    property AtoDRange_Hi : SmallInt read GetHiADRange write SetHiADRange;                         // High AtoD Range used to compute "Value_ScaledInput"...
    property AtoDRange_Lo : SmallInt read GetLoADRange write SetLoADRange;                         // Low AtoD Range, used for bounds checking...
    property RawAtoD_Input : Double read FIntRawInput write SetRawInput;        // Is of type Double to allow for use and creation of derived channels...
    property Value_ScaledInput : Double read FScaledInputValue;                 // Raw AtoD * Scale Factor
    property Value_EUofInput : Double read FEUInputValue;                       // Scale Factor with Cal Factors applied...
    property CalculationMethod : TCalculationMethod read GetCalcType write SetCalcType;           // Method used to compute "Value_EUofInput"
    property UseCalOffset : Boolean read GetUseCalOffset write SetUseCalOffset;                       // Use either the channels' zero or the calibrated offset...
  end; // TInputChannel

  TOutputChannel = class(TComponent)
  private
    FOutputConfig : TChannelConfig;
    FPIDConfig    : TPIDConfiguration;
    FScaledOutput : Double;
    FIntOutput    : LongInt;
  protected
    // Property Functions and Procedures...
    function GetOutputCalFactor(Index : TCalFactorNum) : Double;
    procedure SetOutputCalFactor(Index : TCalFactorNum; Value : Double);
    function GetOutputCalOffset : Double;
    procedure SetOutputCalOffset(Value : Double);
    function GetOutputCalUnits : TUnits;
    procedure SetOutputCalUnits(Value : TUnits);
    function GetOutputScale : Double;
    procedure SetOutputScale(Value : Double);
    function GetOutputChannelZero : Double;
    procedure SetOutputChannelZero(Value : Double);
    function GetHiADRange : SmallInt;
    procedure SetHiADRange(Value : SmallInt);
    function GetLoADRange : SmallInt;
    procedure SetLoADRange(Value : SmallInt);
    function GetCalcType : TCalculationMethod;
    procedure SetCalcType(Value : TCalculationMethod);
    function GetUseCalOffset : Boolean;
    procedure SetUseCalOffset(Value : Boolean);
    function GetPIDPValue : SmallInt;
    procedure SetPIDPValue(Value : SmallInt);
    function GetPIDIValue : SmallInt;
    procedure SetPIDIValue(Value : SmallInt);
    function GetPIDDValue : SmallInt;
    procedure SetPIDDValue(Value : SmallInt);
    function GetPIDCNValue : SmallInt;
    procedure SetPIDCNValue(Value : SmallInt);
    function GetPIDCPValue : SmallInt;
    procedure SetPIDCPValue(Value : SmallInt);
    // Utilty Functions and procedures
    function ComputeADOutput(EUValue : Double) : SmallInt;
    function ComputeLinearResult(EUValue : Double) : SmallInt;
    function ComputePloynomialResult(EUValue : Double) : Smallint; // This function is called when dealing with a plynomial calculation method. EUValue Must have any offsets subtracted before usig!
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    procedure ConfigureOutputChannel(Var ChannelConfig : TChannelConfig; Var PIDConfig : TPIDConfiguration);
    function Read_OutputConfig : TChannelConfig;
    procedure ConfigurePID(Var PIDConfig : TPIDConfiguration);
    function Read_PIDConfig : TPIDConfiguration;
    // Output properties...
    property Output_CalFactor[Index : TCalFactorNum] : Double read GetOutputCalFactor write SetOutputCalFactor;
    property Output_CalOffset : Double read GetOutputCalOffset write SetOutputCalOffset;
    property Output_CalUnits : TUnits read GetOutputCalUnits write SetOutputCalUnits;
    property Output_Scale : Double read GetOutputScale write SetOutputScale;
    property Output_ChannelZero : Double read GetOutputChannelZero write SetOutputChannelZero;
    property AtoDRange_Hi : SmallInt read GetHiADRange write SetHiADRange;
    property AtoDRange_Lo : SmallInt read GetLoADRange write SetLoADRange;
    property Value_ScaledOutput : Double read FScaledOutput;
    property Value_IntOutput : LongInt read FIntOutput;
    property CalculationMethod : TCalculationMethod read GetCalcType write SetCalcType;
    property UseCalOffset : Boolean read GetUseCalOffset write SetUseCalOffset;
    // PID properties...
    property PID_P  : SmallInt read GetPIDPValue write SetPIDPValue;
    property PID_I  : SmallInt read GetPIDIValue write SetPIDIValue;
    property PID_D  : SmallInt read GetPIDDValue write SetPIDDValue;
    property PID_CN : SmallInt read GetPIDCNValue write SetPIDCNValue;
    property PID_CP : SmallInt read GetPIDCPValue write SetPIDCPValue;
  end; // TOutputChannel

  TInputChannelManager = class(TComponent)
  private
      FInputChannels : TStringList;
  protected
    function InputChannelExists(Index : LongInt; Var InputChannel : TInputChannel) : Boolean;
    function GetInputCalFactor(Index : LongInt; CFIndex : TCalFactorNum) : Double;
    procedure SetInputCalFactor(Index : LongInt; CFIndex : TCalFactorNum; Value : Double);
    function GetInputCalOffset(Index : LongInt) : Double;
    procedure SetInputCalOffset(Index : LongInt; Value : Double);
    function GetInputCalUnits(Index : LongInt) : TUnits;
    procedure SetInputCalUnits(Index : LongInt; Value : TUnits);
    function GetInputDisplayUnits(Index : LongInt) : TUnits;
    procedure SetInputDisplayUnits(Index : LongInt; Value : TUnits);
    function GetInputScale(Index : LongInt) : Double;
    procedure SetInputScale(Index : LongInt; Value : Double);
    procedure SetInputGuage(Index : LongInt; Value : TDVM);
    function GetInputChannelZero(Index : LongInt) : Double;
    procedure SetChannelZero(Index : LongInt; Value : Double);
    function GetHiADRange(Index : LongInt) : SmallInt;
    procedure SetHiADRange(Index : LongInt; Value : SmallInt);
    function GetLoADRange(Index : LongInt) : SmallInt;
    procedure SetLoADRange(Index : LongInt; Value : SmallInt);
    function GetRawInput(Index : LongInt) : Double;
    procedure SetRawInput(Index : LongInt; Value : Double);
    function GetScaledInputValue(Index : LongInt) : Double;
    function GetEUInputValue(Index : LongInt) : Double;
    function GetCalcType(Index : LongInt) : TCalculationMethod;
    procedure SetCalcType(Index : LongInt; Value : TCalculationMethod);
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    // Utility functions and procedures...
    function AddInputChannel(Var Config : TChannelConfig) : LongInt;
    function RemoveInputChannel(Index : DWord) : Boolean;
    function GetInputChannel(Index : LongInt) : TInputChannel;
    function InputChannelCount : DWord;
    // Properties...
    property Input_CalFactor[Index : LongInt; CFIndex : TCalFactorNum] : Double read GetInputCalFactor write SetInputCalFactor;
    property Input_CalOffset[Index : LongInt] : Double read GetInputCalOffset write SetInputCalOffset;
    property Input_CalUnits[Index : LongInt] : TUnits read GetInputCalUnits write SetInputCalUnits;
    property Input_DisplayUnits[Index : LongInt] : TUnits read GetInputDisplayUnits write SetInputDisplayUnits;
    property Input_Scale[Index : LongInt] : Double read GetInputScale write SetInputScale;
    property Input_Guage[Index : LongInt] : TDVM write SetInputGuage;
    property Input_ChannelZero[Index : LongInt] : Double read GetInputChannelZero write SetChannelZero;
    property AtoDRange_Hi[Index : LongInt] : SmallInt read GetHiADRange write SetHiADRange;
    property AtoDRange_Lo[Index : LongInt] : SmallInt read GetLoADRange write SetLoADRange;
    property RawAtoD_Input[Index : LongInt] : Double read GetRawInput write SetRawInput;
    property Value_ScaledInput[Index : LongInt] : Double read GetScaledInputValue;
    property Value_EUofInput[Index : LongInt] : Double read GetEUInputValue;
    property CalculationMethod[Index : LongInt] : TCalculationMethod read GetCalcType write SetCalcType;
  end; // TInputManager

  TBaseSetPointControl = class(TComponent)
  private
//    FOnNewSetPoint       : TOnNewSetPoint;
//    FOnNewPIDValues      : TOnNewPIDValues;
    FSetPointControlType : TSetPointControlType;
    FSPCNumber           : Byte;
    FChannelConfig       : TSPControlConfiguration;
    FEUSetPoint          : Double;
    FIntSetPoint         : SmallInt;
    FInputChannel        : TInputChannel;
    FOutputChannel       : TOutputChannel;
    FScaledOutput        : Double; // Value_ScaledOutput is the result of (Offset Corrected Set Point / Cal Factor)
    FReqeustedEUSpValue  : Double;
    FEnabled             : Boolean;
    FRequiresOutputCal   : Boolean;
  protected
    // Base Functions and Procedures...
    procedure ConfigureSPChannel(Var ChannelConfig : TSPControlConfiguration); Virtual;
    function ComputeNewSetPoint(SPValue : Double) : SmallInt; Virtual;
    // Functions and Procedures called by properties...
    procedure SetRequiresOutputCal(Value : Boolean);
    procedure SetNewSetPoint(Value : Double);
    function GetRawInput : Double;
    procedure SetRawInput(Value : Double); Virtual;
    function GetInputCalFactor(Index : TCalFactorNum) : Double;
    procedure SetInputCalFactor(Index : TCalFactorNum; Value : Double);
    function GetInputChanDescription : String;
    function GetInputCalOffset : Double;
    procedure SetInputCalOffset(Value : Double);
    function GetInputCalUnits : TUnits;
    function GetInputDisplayUnits : TUnits;    
    function GetInputScale : Double;
    function GetInputHiAtoDRange : SmallInt;
    function GetInputLoAtoDRange : SmallInt;
    function GetInputChannelZero : Double;
    procedure SetInputChannelZero(Value : Double);
    function GetInputGuage : TDVM;
    procedure SetInputGuage(Value : TDVM);
    function GetInputUseCalOffset : Boolean;
    function GetInputEUValue : Double;
    function GetOutputCalFactor(Index : TCalFactorNum) : Double;
    procedure SetOutputCalFactor(Index : TCalFactorNum; Value : Double);
    function GetOutputCalOffset : Double;
    procedure SetOutputCalOffset(Value : Double);
    function GetOutputCalUnits : TUnits;
    function GetOutputScale : Double;
    function GetOutputChannelZero : Double;
    procedure SetOutputChannelZero(Value : Double);
    function GetOutputHiAtoDRange : SmallInt;
    function GetOutputLoAtoDRange : SmallInt;
    function GetRawAtoDOutput : SmallInt;
    function GetScaledInput : Double;
    function GetInputCalculationMethod : TCalculationMethod;
    function GetOutputCalculationMethod : TCalculationMethod;
    procedure SetOutputCalculationMethod(Value : TCalculationMethod);
    function GetPIDPValue : SmallInt;
    procedure SetPIDPValue(Value : SmallInt);
    function GetPIDIValue : SmallInt;
    procedure SetPIDIValue(Value : SmallInt);
    function GetPIDDValue : SmallInt;
    procedure SetPIDDValue(Value : SmallInt);
    function GetPIDCNValue : SmallInt;
    procedure SetPIDCNValue(Value : SmallInt);
    function GetPIDCPValue : SmallInt;
    procedure SetPIDCPValue(Value : SmallInt);
    // Referance properties...
    property EUSetPoint : Double read FEUSetPoint;
    property IntSetPoint : SmallInt read FIntSetPoint;
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    // Referance properties and functions...
    function Get_SPConfig : TSPControlConfiguration;
    function Get_InputChannel : TInputChannel;
    function Get_OutputChannel : TOutputChannel;
    property Enabled : Boolean read FEnabled write FEnabled;
    property RequiresOutputCal : Boolean read FRequiresOutputCal write SetRequiresOutputCal;
    property SPC_Type : TSetPointControlType read FSetPointControlType;
    property SPC_Number : Byte read FSPCNumber write FSPCNumber;
    // Input properties...
    property Input_ChanDescription : String read GetInputChanDescription;
    property Input_CalFactor[Index : TCalFactorNum] : Double read GetInputCalFactor write SetInputCalFactor;
    property Input_CalOffset : Double read GetInputCalOffset write SetInputCalOffset;
    property Input_CalUnits : TUnits read GetInputCalUnits;
    property Input_DisplayUnits : TUnits read GetInputDisplayUnits;
    property Input_Scale : Double read GetInputScale;
    property Input_HiAtoDRange : SmallInt read GetInputHiAtoDRange;
    property Input_LoAtoDRange : SmallInt read GetInputLoAtoDRange;
    property Input_ChannelZero : Double read GetInputChannelZero write SetInputChannelZero;
    property Input_Guage : TDVM read GetInputGuage write SetInputGuage;
    property Input_UseCalOffset : Boolean read GetInputUseCalOffset;
    property RawAtoD_Input : Double read GetRawInput write SetRawInput;
    property Value_EUofInput : Double read GetInputEUValue;
    property Value_ScaledInput : Double read GetScaledInput;
    property InputCalculationMethod : TCalculationMethod read GetInputCalculationMethod{ write SetInputCalculationMethod};
    // Output properties...
    property Output_CalFactor[Index : TCalFactorNum] : Double read GetOutputCalFactor write SetOutputCalFactor;
    property Output_CalOffset : Double read GetOutputCalOffset write SetOutputCalOffset;
    property Output_CalUnits : TUnits read GetOutputCalUnits;
    property Output_Scale : Double read GetOutputScale;
    property Output_ChannelZero : Double read GetOutputChannelZero write SetOutputChannelZero;
    property Output_HiAtoDRange : SmallInt read GetOutputHiAtoDRange;
    property Output_LoAtoDRange : SmallInt read GetOutputLoAtoDRange;
    property RawAtoDOutput : SmallInt read GetRawAtoDOutput;
    property Value_ScaledOutput : Double read FScaledOutput;
    property OutputCalculationMethod : TCalculationMethod read GetOutputCalculationMethod write SetOutputCalculationMethod;
    // PID properties...
    property PID_P  : SmallInt read GetPIDPValue write SetPIDPValue;
    property PID_I  : SmallInt read GetPIDIValue write SetPIDIValue;
    property PID_D  : SmallInt read GetPIDDValue write SetPIDDValue;
    property PID_CN : SmallInt read GetPIDCNValue write SetPIDCNValue;
    property PID_CP : SmallInt read GetPIDCPValue write SetPIDCPValue;
    // SetPoint properties...
    property NewSetPoint : Double write SetNewSetPoint;
    property Value_IntSetPoint : SmallInt read FIntSetPoint;
    property Requested_EUSetPoint : Double read FReqeustedEUSpValue;
    // Events...
//    property OnNewSetPoint : TOnNewSetPoint read FOnNewSetPoint write FOnNewSetPoint;
//    property OnNewPIDValues : TOnNewPIDValues read FOnNewPIDValues write FOnNewPIDValues;
  end; // TBaseSetPointControl

  TLoad_SetPointControl = class(TBaseSetPointControl)
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
  end; // TLoad_SetPointControl

  TSlip_SetPointControl = class(TBaseSetPointControl)
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
  end; // TSlip_SetPointControl

  TCamber_SetPointControl = class(TBaseSetPointControl)
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
  end; // TCamber_SetPointControl

  TInflation_SetPointControl = class(TBaseSetPointControl)
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
  end; // TInflation_SetPointControl

  TPosition_SetPointControl = class(TBaseSetPointControl)
  private
    FErrorAngle : Double;
    // Spindle offset compensation...many intended for camber angle correction...
    FCorrectionFactor   : Double;
    FSpindleoffset   : Double;
    FPivotToWheelCenter : Double;
    FUncorrectedPz      : Double;
    // ...
    FDeflection : Double;
    FTireOD : Double; // Used to determin deflection...
  protected
    function ComputeNewSetPoint(SPValue : Double) : SmallInt; Override;
    procedure SetRawInput(Value : Double); Override;
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;

    property ErrorAngle : Double read FErrorAngle write FErrorAngle;
    property CorrectionFactor : Double read FCorrectionFactor;
    property PivotToWheelCenter : Double read FPivotToWheelCenter write FPivotToWheelCenter;
    property UncorrectedPz : Double read FUncorrectedPz;
    property SpindleOffset : Double read FSpindleoffset write FSpindleoffset;
    property TireOD : Double read FTireOD write FTireOD;
    property Deflection : Double read FDeflection;
  end; // TPosition_SetPointControl

//  TDrive_SetPointControl = class(TBaseSetPointControl)
//  private
//    FSampleMethod : TSpeedMeasurementMethod;
//    FDriveConfig : TDriveConfiguration;
//  protected
//    procedure SetRawInput(Value : Double); Override;
//  public
//    constructor Create(AOwner : TComponent); Override;
//    destructor Destroy; Override;
//    procedure ConfigureDriveChannel(Var ChannelConfig : TDriveConfiguration);
//
//    property  SampleMethod : TSpeedMeasurementMethod read FSampleMethod write FSampleMethod;
//  end; // TDriveControl

  TDrive_SetPointControl = class(TBaseSetPointControl)
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
  end; // TDriveControl


  TSetPointControlManager = class(TComponent)
  private
//    FOnSPCNewSetPoint : TOnNewSetPoint;
//    FOnSPCNewPIDValues : TOnNewPIDValues;
    FSetPointControls : TStringList; // List to contain all setpoint controls...
    function GetSetPointControl(Index : LongInt) : TBaseSetPointControl;
    // Input
    function GetSPCInputChanDescription(Index : DWord) : String;
    function GetSPCInputCalFactor(Index : DWord; CFNum : TCalFactorNum) : Double;
    procedure SetSPCInputCalFactor(Index : DWord; CFNum : TCalFactorNum; Value : Double);
    function GetSPCInputCalOffset(Index : DWord) : Double;
    procedure SetSPCInputCalOffset(Index : DWord; Value : Double);
    function GetSPCInputCalUnits(Index : DWord) : TUnits;
    function GetSPCInputDisplayUnits(Index : DWord) : TUnits;
    function GetSPCInputScale(Index : DWord) : Double;
    function GetSPCInputGuage(Index : DWord) : TDVM;
    procedure SetSPCInputGuage(Index : DWord; Value : TDVM);
    function GetSPCChannelZero(Index : DWord) : Double;
    procedure SetSPCChannelZero(Index : DWord; Value : Double);
    function GetSPCInputHiADRange(Index : DWord) : SmallInt;
    function GetSPCInputLoADRange(Index : Dword) : SmallInt;
    function GetSPCScaledInput(Index : DWord) : Double;
    function GetSPCEUofInput(Index : DWord) : Double;
    function GetSPCCalcType(Index : DWord) : TCalculationMethod;
    function GetSPCUseCalOffset(Index : DWord) : Boolean;
    // Output
    function GetSPCIntSetPoint(Index : DWord) : SmallInt;
    function GetSPCEUSetPoint(Index : DWord) : Double;
    function GetSPCOutputCalFactor(Index : DWord; CFNum : TCalFactorNum) : Double;
    procedure SetSPCOutputCalFactor(Index : DWord; CFNum : TCalFactorNum; Value : Double);
    function GetSPCOutputCalOffset(Index : DWord) : Double;
    procedure SetSPCOutputCalOffset(Index : DWord; Value : Double);
    function GetSPCOutputCalUnits(Index : DWord) : TUnits;
    function GetSPCOutputScale(Index : DWord) : Double;
    function GetSPCOutputChannelZero(Index : DWord) : Double;
    procedure SetSPCOutputChannelZero(Index : DWord; Value : Double);
    function GetSPCOutputHiADRange(Index : DWord) : SmallInt;
    function GetSPCOutputLoADRange(Index : DWord) : SmallInt;
    function GetSPCRawAtoDInput(Index : DWord) : Double;
    procedure SetSPCRawAtoDInput(Index : DWord; Value : Double);
    function GetSPCCurrentEUSetPoint(Index : DWord) : Double;
    procedure SetSPCNewSetPoint(Index : DWord; Value : Double);
    function GetSPCScaledOutput(Index : DWord) : Double;
    function GetSPCPID_PValue(Index : DWord) : SmallInt;
    procedure SetSPCPID_PValue(Index : DWord; Value : SmallInt);
    function GetSPCPID_IValue(Index : DWord) : SmallInt;
    procedure SetSPCPID_IValue(Index : DWord; Value : SmallInt);
    function GetSPCPID_DValue(Index : DWord) : SmallInt;
    procedure SetPSCPID_DValue(Index : DWord; Value : SmallInt);
    function GetSPCPID_CNValue(Index : DWord) : SmallInt;
    procedure SetSPCPID_CNValue(Index : DWord; Value : SmallInt);
    function GetSPCPID_CPValue(Index : DWord) : SmallInt;
    procedure SetSPCPID_CPValue(Index : DWord; Value : SmallInt);
    function GetRequiresOutputCal(Index : DWord) : Boolean;
    procedure SetRequriesOutputCal(Index : DWord; Value : Boolean);
    function GetSPCEnabled(Index : DWord) : Boolean;
    procedure SetSPCEnabled(Index :DWord; Value : Boolean);
  protected
    function SPControlType(SPControl : TBaseSetPointControl) : TSetPointControlType;
//    procedure SPCNewSetPoint(Sender : TObject; SPCNumber : Byte; SetPointControlType : TSetPointControlType; NewSetPoint : SmallInt);
//    procedure SPCNewPIDValues(Sender : TObject; SPCNumber : Byte; SetPointControlType : TSetPointControlType; PIDConfig : TPIDConfiguration);
    function SPControlExists(Index : LongInt; Var SPControl : TBaseSetPointControl) : Boolean;
  public
    constructor Create(AOwner : TComponent); Override;
    destructor Destroy; Override;
    function AddSetPointControl(SetPointControlType : TSetPointControlType) : LongInt;
    function RemoveSetPointControl(Index : DWord) : Boolean;
    function SetPointControlCount : DWord;
    function ConfigureSPControl(Index : DWord; ChannelConfig : Pointer; RecSize : DWord) : Boolean;
    function Get_SPCInputChannel(Index : DWord) : TInputChannel;
    function Get_SPCOutputChannel(Index : DWord) : TOutputChannel;

    property Enabled[Index : DWord] : Boolean read GetSPCEnabled write SetSPCEnabled;
    property FindSetPointControl[Index : LongInt] : TBaseSetPointControl read GetSetPointControl;
    // Input
    property Input_ChanDescription[Index : DWord] : String read GetSPCInputChanDescription;
    property Input_CalFactor[Index : DWord; CFNum : TCalFactorNum] : Double read GetSPCInputCalFactor write SetSPCInputCalFactor;
    property Input_CalOffset[Index : DWord] : Double read GetSPCInputCalOffset write SetSPCInputCalOffset;
    property Input_CalUnits[Index : DWord] : TUnits read GetSPCInputCalUnits;
    property Input_DisplayUnits[Index : DWord] : TUnits read GetSPCInputDisplayUnits;
    property Input_Scale[Index : DWord] : Double read GetSPCInputScale;
    property Input_Guage[Index : DWord] : TDVM write SetSPCInputGuage;
    property Input_ChannelZero[Index : DWord] : Double read GetSPCChannelZero write SetSPCChannelZero;
    property Input_AtoDRange_Hi[Index : DWord] : SmallInt read GetSPCInputHiADRange;
    property Input_AtoDRange_Lo[Index : DWord] : SmallInt read GetSPCInputLoADRange;
    property RawAtoD_Input[Index : DWord] : Double read GetSPCRawAtoDInput write SetSPCRawAtoDInput;
    property Value_ScaledInput[Index : DWord] : Double read GetSPCScaledInput;
    property Value_EUofInput[Index : DWord] : Double read GetSPCEUofInput;
    property Input_CalculationMethod[Index : DWord] : TCalculationMethod read GetSPCCalcType;
    property Input_UseCalOffset[Index : DWord] : Boolean read GetSPCUseCalOffset;
    // Output
    property IntSetPoint[Index : DWord] : SmallInt read GetSPCIntSetPoint;
    property EUSetPoint[Index : DWord] : Double read GetSPCEUSetPoint;
    property Output_CalFactor[Index : DWord; CFNum : TCalFactorNum] : Double read GetSPCOutputCalFactor write SetSPCOutputCalFactor;
    property Output_CalOffset[Index : DWord] : Double read GetSPCOutputCalOffset write SetSPCOutputCalOffset;
    property Output_CalUnits[Index : DWord] : TUnits read GetSPCOutputCalUnits;
    property Output_Scale[Index : DWord] : Double read GetSPCOutputScale;
    property Output_ChannelZero[Index : DWord] : Double read GetSPCOutputChannelZero write SetSPCOutputChannelZero;
    property Output_AtoDRange_Hi[Index : DWord] : SmallInt read GetSPCOutputHiADRange;
    property Output_AtoDRange_Lo[Index : DWord] : SmallInt read GetSPCOutputLoADRange;
    property Requested_EUSetPoint[Index : DWord] : Double read GetSPCCurrentEUSetPoint;
    property NewSetPoint[Index : DWord] : Double write SetSPCNewSetPoint;
    property Value_ScaledOutput[Index : DWord] : Double read GetSPCScaledOutput;
    // PID
    property PID_P[Index : DWord]  : SmallInt read GetSPCPID_PValue write SetSPCPID_PValue;
    property PID_I[Index : DWord]  : SmallInt read GetSPCPID_IValue write SetSPCPID_IValue;
    property PID_D[Index : DWord]  : SmallInt read GetSPCPID_DValue write SetPSCPID_DValue;
    property PID_CN[Index : DWord] : SmallInt read GetSPCPID_CNValue write SetSPCPID_CNValue;
    property PID_CP[Index : DWord] : SmallInt read GetSPCPID_CPValue write SetSPCPID_CPValue;
    // Calibration
    property RequiresOutputCal[Index : DWord] : Boolean read GetRequiresOutputCal write SetRequriesOutputCal;
    // Events...
//    property OnNewSetPoint : TOnNewSetPoint read FOnSPCNewSetPoint write FOnSPCNewSetPoint;
//    property OnNewPIDValues : TOnNewPIDValues read FOnSPCNewPIDValues write FOnSPCNewPIDValues;
  end; // TSetPointControlManager

implementation

uses RootsEqu, Math, Dialogs;

constructor TInputChannel.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FillChar(FInputConfig,SizeOf(FInputConfig),#0);
  with FInputConfig do
  begin
    CalFactor[CF1]    := 1;
    AtoDRange_Hi      := High(SmallInt);
    AtoDRange_Lo      := Low(SmallInt);
    Scale             := 5{V};
    CalUnits          := uCustom;
    DisplayUnits      := uCustom;
    UseCalOffset      := True;
  end; // With
  FIntRawInput  := 0;
  FScaledInputValue  := 0;
  FEUInputValue := 0;
end; // TInputChannel.Create

destructor TInputChannel.Destroy;
begin
  inherited Destroy;
end; // TInputChannel.Destroy

procedure TInputChannel.SetRawInput(Value : Double);
begin
  FIntRawInput := Value;
  case FInputConfig.CalcMethod of
    Calc_Linear     : begin
                        FScaledInputValue := ((FIntRawInput / FInputConfig.AtoDRange_Hi) * FInputConfig.Scale);
                        if FInputConfig.UseCalOffset then
                          FEUInputValue := (FScaledInputValue * FInputConfig.CalFactor[CF1] + FInputConfig.CalOffset)
                        else
                          FEUInputValue := (FScaledInputValue * FInputConfig.CalFactor[CF1] - FInputConfig.ChannelZero);
                      end; // Calc_Linear
    Calc_Polynomial : begin
                        // Empty for now...
                      end; // Calc_Polynomial
    Calc_Power      : begin
                          if (Value <> 0) then
                            FScaledInputValue := Power(((FIntRawInput / FInputConfig.AtoDRange_Hi) * FInputConfig.Scale){Base},FInputConfig.CalFactor[CF2]{Power})
                          else
                            FScaledInputValue := 0;
                        if FInputConfig.UseCalOffset then
                          FEUInputValue := ((FInputConfig.CalFactor[CF1] * FScaledInputValue) + FInputConfig.CalOffset)
                        else
                          FEUInputValue := ((FInputConfig.CalFactor[CF1] * FScaledInputValue) - FInputConfig.ChannelZero);
                      end; // Calc_Power
  end; // Case
end; // TInputChannel.SetRawInput

function TInputChannel.GetCalcType : TCalculationMethod;
begin
  Result := FInputConfig.CalcMethod;
end; // TInputChannel.GetCalcType

procedure TInputChannel.SetCalcType(Value : TCalculationMethod);
begin
  FInputConfig.CalcMethod := Value;
end; // TInputChannel.SetCalcType

function TInputChannel.GetUseCalOffset : Boolean;
begin
  Result := FInputConfig.UseCalOffset;
end; // TInputChannel.GetUseCalOffset

procedure TInputChannel.SetUseCalOffset(Value : Boolean);
begin
  FInputConfig.UseCalOffset := Value;
end; // TInputChannel.SetUseCalOffset

function TInputChannel.GetInputChanDescription : String;
begin
  Result := String(FInputConfig.Description);
end; // TInputChannel.GetInputChanDescription

function TInputChannel.GetInputCalFactor(Index : TCalFactorNum) : Double;
begin
  Result := FInputConfig.CalFactor[Index];
end; // TInputChannel.GetInputCalFactor

procedure TInputChannel.SetInputCalFactor(Index : TCalFactorNum; Value : Double);
begin
  FInputConfig.CalFactor[Index] := Value;
end; // TInputChannel.SetInputCalFactor

function TInputChannel.GetInputCalOffset : Double;
begin
  Result := FInputConfig.CalOffset;
end; // TInputChannel.GetInputCalOffset

procedure TInputChannel.SetInputCalOffset(Value : Double);
begin
  FInputConfig.CalOffset := Value;
end; // TInputChannel.SetInputCalOffset

function TInputChannel.GetInputCalUnits : TUnits;
begin
  Result := FInputConfig.CalUnits;
end; // TInputChannel.GetInputCalUnits

procedure TInputChannel.SetInputCalUnits(Value : TUnits);
begin
  FInputConfig.CalUnits := Value;
end; // TInputChannel.SetInputCalUnits

function TInputChannel.GetInputDisplayUnits : TUnits;
begin
  Result := FInputConfig.DisplayUnits;
end; // TInputChannel.GetInputDisplayUnits

procedure TInputChannel.SetInputDisplayUnits(Value : TUnits);
begin
  FInputConfig.DisplayUnits := Value;
end; // TInputChannel.SetInputDisplayUnits

function TInputChannel.GetInputScale : Double;
begin
  Result := FInputConfig.Scale;
end; // TInputChannel.GetInputScale

procedure TInputChannel.SetInputScale(Value : Double);
begin
  FInputConfig.Scale := Value;
end; // TInputChannel.SetInputScale

function TInputChannel.GetInputGuage : TDVM;
begin
  Result := FInputConfig.Guage;
end; // TInputChannel.GetInputGuage

procedure TInputChannel.SetInputGuage(Value : TDVM);
begin
  FInputConfig.Guage := Value;
  if Assigned(FInputConfig.Guage) then
  begin
    with FInputConfig.Guage do
    begin
      ValueUnits   := FInputConfig.CalUnits;
      DisplayUnits := FInputConfig.DisplayUnits;
      Title        := FInputConfig.Description;
//      MeterOn      := True;
    end; // With
  end; // If
end; // TInputChannel.SetInputGuage

function TInputChannel.GetInputChannelZero : Double;
begin
  Result := FInputConfig.ChannelZero;
end; // TInputChannel.GetInputChannelZero

procedure TInputChannel.SetInputChannelZero(Value : Double);
begin
  FInputConfig.ChannelZero := Value;
end; // TInputChannel.SetInputChannelZero

function TInputChannel.GetHiADRange : SmallInt;
begin
  Result := FInputConfig.AtoDRange_Hi;
end; // TInputChannel.GetHiADRange

procedure TInputChannel.SetHiADRange(Value : SmallInt);
begin
  FInputConfig.AtoDRange_Hi := Value;
end; // TInputChannel.SetHiADRange

function TInputChannel.GetLoADRange : SmallInt;
begin
  Result := FInputConfig.AtoDRange_Lo;
end; // TInputChannel.GetLoADRange

procedure TInputChannel.SetLoADRange(Value : SmallInt);
begin
  FInputConfig.AtoDRange_Lo := Value;
end; // TInputChannel.SetLoADRange

procedure TInputChannel.Config_InputChannel(Var ChannelConfig : TChannelConfig);
begin
  FInputConfig := ChannelConfig;
  SetInputGuage(FInputConfig.Guage);
end; // TInputChannel.Config_InputChannel

function TInputChannel.Read_InputConfig : TChannelConfig;
begin
  Result := FInputConfig;
end; // TInputChannel.Read_InputConfig

constructor TOutputChannel.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FillChar(FOutputConfig,SizeOf(FOutputConfig),#0);
  FillChar(FPIDConfig,SizeOf(FPIDConfig),#0);
  with FOutputConfig do
  begin
    CalFactor[CF1] := 1;
    AtoDRange_Hi := High(SmallInt);
    AtoDRange_Lo := Low(SmallInt);
    Scale := 10{V};
    CalUnits := uCustom;
  end; // With
  FScaledOutput := 0;
  FIntOutput := 0;
end; // TOutputChannel.Create

destructor TOutputChannel.Destroy;
begin
  inherited Destroy;
end; // TOutputChannel.Destroy

function TOutputChannel.GetOutputCalFactor(Index : TCalFactorNum) : Double;
begin
  Result := FOutputConfig.CalFactor[Index];
end; // TOutputChannel.GetOutputCalFactor

procedure TOutputChannel.SetOutputCalFactor(Index : TCalFactorNum; Value : Double);
begin
  FOutputConfig.CalFactor[Index] := Value;
end; // TOutputChannel.SetOutputCalFactor

function TOutputChannel.GetOutputCalOffset : Double;
begin
  Result := FOutputConfig.CalOffset;
end; // TOutputChannel.GetOutputCalOffset

procedure TOutputChannel.SetOutputCalOffset(Value : Double);
begin
  FOutputConfig.CalOffset := Value;
end; // TOutputChannel.SetOutputCalOffset

function TOutputChannel.GetOutputCalUnits : TUnits;
begin
  Result := FOutputConfig.CalUnits;
end; // TOutputChannel.GetOutputCalUnits

procedure TOutputChannel.SetOutputCalUnits(Value : TUnits);
begin
  FOutputConfig.CalUnits := Value;
end; // TOutputChannel.SetOutputCalUnits

function TOutputChannel.GetOutputScale : Double;
begin
  Result := FOutputConfig.Scale;
end; // TOutputChannel.GetOutputScale

procedure TOutputChannel.SetOutputScale(Value : Double);
begin
  FOutputConfig.Scale := Value;
end; // TOutputChannel.SetOutputScale

function TOutputChannel.GetOutputChannelZero : Double;
begin
  Result := FOutputConfig.ChannelZero;
end; // TOutputChannel.GetOutputChannelZero

procedure TOutputChannel.SetOutputChannelZero(Value : Double);
begin
  FOutputConfig.ChannelZero := Value;
end; // TOutputChannel.SetOutputChannelZero

function TOutputChannel.GetHiADRange : SmallInt;
begin
  Result := FOutputConfig.AtoDRange_Hi;
end; // TOutputChannel.GetHiADRange

procedure TOutputChannel.SetHiADRange(Value : SmallInt);
begin
  FOutputConfig.AtoDRange_Hi := Value;
end; // TOutputChannel.SetHiADRange

function TOutputChannel.GetLoADRange : SmallInt;
begin
  Result := FOutputConfig.AtoDRange_Lo;
end; // TOutputChannel.GetLoADRange

procedure TOutputChannel.SetLoADRange(Value : SmallInt);
begin
  FOutputConfig.AtoDRange_Lo := Value;
end; // TOutputChannel.SetLoADRange

function TOutputChannel.GetCalcType : TCalculationMethod;
begin
  Result := FOutputConfig.CalcMethod;
end; // TInputChannel.GetCalcType

procedure TOutputChannel.SetCalcType(Value : TCalculationMethod);
begin
  FOutputConfig.CalcMethod := Value;
end; // TOutputChannel.SetCalcType

function TOutputChannel.GetUseCalOffset : Boolean;
begin
  Result := FOutputConfig.UseCalOffset;
end; // TOutputChannel.GetUseCalOffset

procedure TOutputChannel.SetUseCalOffset(Value : Boolean);
begin
  FOutputConfig.UseCalOffset := True;
end; // TOutputChannel.SetUseCalOffset

function TOutputChannel.GetPIDPValue : SmallInt;
begin
  Result := FPIDConfig.P;
end; // TOutputChannel.GetPIDPValue

procedure TOutputChannel.SetPIDPValue(Value : SmallInt);
begin
  FPIDConfig.P := Value;
end; // TOutputChannel.SetPIDPValue

function TOutputChannel.GetPIDIValue : SmallInt;
begin
  Result := FPIDConfig.I;
end; // TOutputChannel.GetPIDIValue

procedure TOutputChannel.SetPIDIValue(Value : SmallInt);
begin
  FPIDConfig.I := Value;
end; // TOutputChannel.SetPIDValue

function TOutputChannel.GetPIDDValue : SmallInt;
begin
  Result := FPIDConfig.D;
end; // TOutputChannel.GetPIDDValue

procedure TOutputChannel.SetPIDDValue(Value : SmallInt);
begin
  FPIDConfig.D := Value;
end; // TOutputChannel.SetPIDDValue

function TOutputChannel.GetPIDCNValue : SmallInt;
begin
  Result := FPIDConfig.CN;
end; // TOutputChannel.GetPIDCNValue

procedure TOutputChannel.SetPIDCNValue(Value : SmallInt);
begin
  FPIDConfig.CN := Value;
end; // TOutputChannel.SetPIDCNValue

function TOutputChannel.GetPIDCPValue : SmallInt;
begin
  Result := FPIDConfig.CP;
end; // TOutputChannel.GetPIDCPValue

procedure TOutputChannel.SetPIDCPValue(Value : SmallInt);
begin
  FPIDConfig.CP := Value;
end; // TOutputChannel.SetPIDCPValue

function TOutputChannel.ComputeADOutput(EUValue : Double) : SmallInt;
begin
  case FOutputConfig.CalcMethod of
    Calc_Linear     : FIntOutput := ComputeLinearResult(EUValue);
    Calc_Polynomial : FIntOutput := ComputePloynomialResult(EUValue);
  end; // Case
  Result := FIntOutput;
end; // TOutputChannel.ComputeADOutput

function TOutputChannel.ComputeLinearResult(EUValue : Double) : SmallInt;
var
  SP_Corrected : Double;
  SP : SmallInt;
begin
  if FOutputConfig.UseCalOffset then
    SP_Corrected := (EUValue - FOutputConfig.CalOffset) // Offset corrected setpoint...
  else
    SP_Corrected := (EUValue + FOutputConfig.ChannelZero);
  if (FOutputConfig.CalFactor[CF1] <> 0) then
    FScaledOutput := (SP_Corrected / FOutputConfig.CalFactor[CF1]) // Calculate required output value in Volts, mA, ect...
  else
    FScaledOutput := 0;
  SP := Trunc((FSCaledOutput * FOutputConfig.AtoDRange_Hi) / FOutputConfig.Scale); // Calculate new setpoint...
  if (SP > FOutputConfig.AtoDRange_Hi) then
    SP := FOutputConfig.AtoDRange_Hi;
  if (SP < FOutputConfig.AtoDRange_Lo) then
    SP := FOutputConfig.AtoDRange_Lo;
  Result := SP;
end; // TOutputChannel.ComputeLinearResult

function TOutputChannel.ComputePloynomialResult(EUValue : Double) : SmallInt;
var                                            {EUValue Must have any offsets subtracted before using!}
  InitialGuess : Double;
  Degree    : Integer;
  Poly      : TNCompVector;
  InitGuess : TNcomplex;
  Tol       : Double;
  MaxIter   : Integer;
  NumRoots  : Integer;
  Roots     : TNCompVector;
  yRoots    : TNCompVector;
  Iter      : TNIntVector;
  Error     : Byte;
  x         : Integer;
  ErrStr    : String;
  FoundRoot : Boolean;
begin
  Result := 0;
  with FOutputConfig do
  begin
    InitialGuess := (-Output_CalFactor[CF1] + SqRt(Sqr(Output_CalFactor[CF1]) - 4 * Output_CalFactor[CF2] * EUValue)) / (2 * Output_CalFactor[CF2]);
    // call Laguerre here to determine 1st Root to within a tolerance of 0.005 V in 100 tries
    // Input Parameters
    Degree    := 3;
    FillChar(Poly, SizeOf(Poly), #0);
    Poly[3].re := Output_CalFactor[CF3];
    Poly[2].re := Output_CalFactor[CF2];
    Poly[1].re := Output_CalFactor[CF1];
    Poly[0].re := EUValue;
  end; // With
  FillChar(InitGuess, SizeOf(InitGuess), #0);
  InitGuess.re := InitialGuess;
  Tol       := 0.005{V};
  MaxIter   := 100;
  // Output Parameters
  NumRoots  := 0;
  FillChar(Roots, SizeOf(Roots), #0);
  FillChar(yRoots, SizeOf(yRoots), #0);
  FillChar(Iter, SizeOf(Iter), #0);
  Error     := 0;
  Laguerre(Degree,Poly,InitGuess,Tol,MaxIter,NumRoots,Roots,yRoots,Iter,Error);
  if (Error = 0) then
  begin
    x := 1;
    FoundRoot := false;
    repeat
      if (Roots[x].re >= -FOutputConfig.Scale) and (Roots[x].re <= FOutputConfig.Scale) then
      begin
        FoundRoot := true;
        Result := Trunc((Roots[x].re * FOutputConfig.AtoDRange_Hi) / FOutputConfig.Scale); // Calculate setpoint new setpoint...;
      end
      else
        inc(x);
    until FoundRoot or (x = NumRoots);
  end
  else
  begin
    ErrStr := format('Laguerre Error Code %d, %d'+#13#10,[Error, MaxIter]);
    for x := 0 to 4 do
    begin
      if (x = 4) then
        ErrStr := ErrStr + format('Iteration = %d',[Iter[x]])
      else
        ErrStr := ErrStr + format('Iteration = %d'+#13#10,[Iter[x]]);
    end;
    MessageDlg(format('Error computing SetPoint. Error %s.',[ErrStr]), mtError, [mbOK], 0);
  end;
end; // TOutputChannel.ComputePolynomialResult

procedure TOutputChannel.ConfigureOutputChannel(Var ChannelConfig : TChannelConfig; Var PIDConfig : TPIDConfiguration);
begin
  FOutputConfig := ChannelConfig;
  FPIDConfig    := PIDConfig;
end; // TOutputChannel.ConfigureOutputChannel

function TOutputChannel.Read_OutputConfig : TChannelConfig;
begin
  Result := FOutputConfig;
end; // TOutputChannel.Read_OutputConfig

procedure TOutputChannel.ConfigurePID(Var PIDConfig : TPIDConfiguration);
begin
  FPIDConfig := PIDConfig;
end; // TOutputChannel.ConfigurePID

function TOutputChannel.Read_PIDConfig : TPIDConfiguration;
begin
  Result := FPIDConfig;
end; // TOutputChannel.Read_PIDConfig

constructor TInputChannelManager.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FInputChannels := TStringList.Create;
end;

destructor TInputChannelManager.Destroy;
var
  Chan : DWord;
begin
  if (FInputChannels.Count > 0) then
  begin
    for Chan := 0 to (FInputChannels.Count - 1) do
      RemoveInputChannel(Chan);  
  end; // If
  FInputChannels.Free;
  inherited Destroy
end;

function TInputChannelManager.AddInputChannel(Var Config : TChannelConfig) : LongInt;
var
  InputChannel : TInputChannel;
begin
  InputChannel := TInputChannel.Create(Nil);
  InputChannel.Config_InputChannel(Config);
  Result := FInputChannels.Count;
  FInputChannels.AddObject(IntToStr(Result),InputChannel);
end; // TInputChannelManager.AddInputChannel

function TInputChannelManager.RemoveInputChannel(Index : DWord) : Boolean;
var
  ActualIndex : DWord;
  InputChannel : TInputChannel;
begin
  ActualIndex := FInputChannels.IndexOf(IntToStr(Index));
  if (ActualIndex > INVALID_INDEX) then
  begin
    InputChannel := FInputChannels.Objects[ActualIndex] as TInputChannel;
    FInputChannels.Delete(ActualIndex);
    InputChannel.Free;
    Result := True;
  end
  else
    Result := False;  
end; // TInputChannelManager.RemoveInputChannel

function TInputChannelManager.GetInputChannel(Index : LongInt) : TInputChannel;
var
  Tmp : TInputChannel;
begin
  Result := Nil;
  if InputChannelExists(Index,Tmp) then
  begin
    if Assigned(Tmp) then
      Result := Tmp
  end; // If
end; // TInputChannelManager.GetInputChannel

function TInputChannelManager.InputChannelCount : DWord;
begin
  Result := FInputChannels.Count;
end; // TInputChannelManager.InputChannelCount

function TInputChannelManager.InputChannelExists(Index : LongInt; Var InputChannel : TInputChannel) : Boolean;
var
  ActualIndex : LongInt;
begin
  ActualIndex := FInputChannels.IndexOf(IntToStr(Index));
  Result := (ActualIndex > INVALID_INDEX);
  if Result then
    InputChannel := (FInputChannels.Objects[ActualIndex] as TInputChannel)
  else
    InputChannel := Nil;
end; // TInputChannelManager.InputChannelExists

function TInputChannelManager.GetInputCalFactor(Index : LongInt; CFIndex : TCalFactorNum) : Double;
var
  InputChannel : TInputChannel;
begin
  Result := 0;
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      Result := InputChannel.Input_CalFactor[CFIndex]
  end; // If
end; // TInputChannelManage.GetInputCalFactor

procedure TInputChannelManager.SetInputCalFactor(Index : LongInt; CFIndex : TCalFactorNum; Value : Double);
var
  InputChannel : TInputChannel;
begin
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      InputChannel.Input_CalFactor[CFIndex] := Value;
  end; // If
end; // TInputChannelManager.SetInputCalFactor

function TInputChannelManager.GetInputCalOffset(Index : LongInt) : Double;
var
  InputChannel : TInputChannel;
begin
  Result := 0;
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      Result := InputChannel.Input_CalOffset
  end; // If
end; // TInputChannelManager.GetInputCalOffset

procedure TInputChannelManager.SetInputCalOffset(Index : LongInt; Value : Double);
var
  InputChannel : TInputChannel;
begin
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      InputChannel.Input_CalOffset := Value;
  end; // If
end; // TInputChannelManager.SetInputCalOffset

function TInputChannelManager.GetInputCAlUnits(Index : LongInt) : TUnits;
var
  InputChannel : TInputChannel;
begin
  Result := uCustom;
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      Result := InputChannel.Input_CAlUnits
  end; // If
end; // TInputChannelManager.GetInputCalUnits

procedure TInputChannelManager.SetInputCalUnits(Index : LongInt; Value : TUnits);
var
  InputChannel : TInputChannel;
begin
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      InputChannel.Input_CalUnits := Value;
  end; // If
end; // TInputChannelManager.SetInputCalUnits

function TInputChannelManager.GetInputDisplayUnits(Index : LongInt) : TUnits;
var
  InputChannel : TInputChannel;
begin
  Result := uCustom;
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      Result := InputChannel.Input_DisplayUnits
  end; // If
end; // TInputChannelManager.GetInputDisplauUnits

procedure TInputChannelManager.SetInputDisplayUnits(Index : LongInt; Value : TUnits);
var
  InputChannel : TInputChannel;
begin
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      InputChannel.Input_DisplayUnits := Value;
  end; // If
end; // TInputChannelManager.SetInputDisplayUnits

function TInputChannelManager.GetInputScale(Index : LongInt) : Double;
var
  InputChannel : TInputChannel;
begin
  Result := 0;
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      Result := InputChannel.Input_Scale
  end; // If
end; // TInputChannelManager.GetInputScale

procedure TInputChannelManager.SetInputScale(Index : LongInt; Value : Double);
var
  InputChannel : TInputChannel;
begin
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      InputChannel.Input_Scale := Value;
  end; // If
end; // TInputChannelManager.SetInputScale

procedure TInputChannelManager.SetInputGuage(Index : LongInt; Value : TDVM);
var
  InputChannel : TInputChannel;
begin
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      InputChannel.Input_Guage := Value;
  end; // If
end; // InputChannelManager.SetInputGuage

function TInputChannelManager.GetInputChannelZero(Index : LongInt) : Double;
var
  InputChannel : TInputChannel;
begin
  Result := 0;
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      Result := InputChannel.Input_ChannelZero
  end; // If
end; // TInputChannelManager.GetInputChannelZero

procedure TInputChannelManager.SetChannelZero(Index : LongInt; Value : Double);
var
  InputChannel : TInputChannel;
begin
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      InputChannel.Input_ChannelZero := Value;
  end; // If
end; // TInputChannelManager.SetChannelZero

function TInputChannelManager.GetHiADRange(Index : LongInt) : SmallInt;
var
  InputChannel : TInputChannel;
begin
  Result := 0;
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      Result := InputChannel.AtoDRange_Hi
  end; // If
end; // TInputChannelManager.GetHiADRange

procedure TInputChannelManager.SetHiADRange(Index : LongInt; Value : SmallInt);
var
  InputChannel : TInputChannel;
begin
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      InputChannel.AtoDRange_Hi := Value;
  end; // If
end; // TInputChannelManager.SetHiADRange

function TInputChannelManager.GetLoADRange(Index : LongInt) : SmallInt;
var
  InputChannel : TInputChannel;
begin
  Result := 0;
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      Result := InputChannel.AtoDRange_Lo
  end; // If
end; // TInputChannelManager.GetLoADRange

procedure TInputChannelManager.SetLoADRange(Index : LongInt; Value : SmallInt);
var
  InputChannel : TInputChannel;
begin
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      InputChannel.AtoDRange_Lo := Value;
  end; // If
end; // TInputChannelManager.SetLoADRange

function TInputChannelManager.GetRawInput(Index : LongInt) : Double;
var
  InputChannel : TInputChannel;
begin
  Result := 0;
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      Result := InputChannel.RawAtoD_Input
  end; // If
end; // TInputChannelManager.GetRawInput

procedure TInputChannelManager.SetRawInput(Index : LongInt; Value : Double);
var
  InputChannel : TInputChannel;
begin
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      InputChannel.RawAtoD_Input := Value;
  end; // If
end; // TInputChannelManager.SetRawInput

function TInputChannelManager.GetScaledInputValue(Index : LongInt) : Double;var
  InputChannel : TInputChannel;
begin
  Result := 0;
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      Result := InputChannel.Value_ScaledInput
  end; // If
end; // TInputChannelManager.GetScaledInputValue

function TInputChannelManager.GetEUInputValue(Index : LongInt) : Double;
var
  InputChannel : TInputChannel;
begin
  Result := 0;
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      Result := InputChannel.Value_EUofInput
  end; // If
end; // TInputChannelManager.GetEUInputValue

function TInputChannelManager.GetCalcType(Index : LongInt) : TCalculationMethod;
var
  InputChannel : TInputChannel;
begin
  Result := Calc_Linear;
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      Result := InputChannel.CalculationMethod
  end; // If
end; // TInputChannelManager.GetCalcType

procedure TInputChannelManager.SetCalcType(Index : LongInt; Value : TCalculationMethod);
var
  InputChannel : TInputChannel;
begin
  if InputChannelExists(Index,InputChannel) then
  begin
    if Assigned(InputChannel) then
      InputChannel.CalculationMethod := Value
  end; // If
end; // TInputChannelManager.SetCalcType

constructor TBaseSetPointControl.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FSetPointControlType := SPC_Base;
  FSPCNumber          := 0;
  FEUSetPoint         := 0;
  FIntSetPoint        := 0;
  FScaledOutput       := 0;
  FReqeustedEUSpValue := 0;
  FEnabled            := False;
  FRequiresOutputCal  := False;
  FillChar(FChannelConfig,SizeOf(FChannelConfig),#0);
  FInputChannel := TInputChannel.Create(Self);
  FOutputChannel := TOutputChannel.Create(Self);
end; // TBaseSetPointControl.Create

destructor TBaseSetPointControl.Destroy;
begin
  FInputChannel.Free;
  FOutputChannel.Free;
  inherited Destroy;
end; // TBaseSetPointControl.Destroy

function TBaseSetPointControl.Get_SPConfig : TSPControlConfiguration;
begin
  FillChar(Result,SizeOf(Result),#0);
  Result.InputConfig       := FInputChannel.Read_InputConfig;
  Result.OutputConfig      := FOutputChannel.Read_OutputConfig;
  Result.RequiresOutputCal := Self.RequiresOutputCal;
end; // TBaseSetPointControl.Get_SPConfig

function TBaseSetPointControl.Get_InputChannel : TInputChannel;
begin
  Result := FInputChannel;
end; // TBaseSetPointControl.Get_InputChannel

function TBaseSetPointControl.Get_OutputChannel : TOutputChannel;
begin
  Result := FOutputChannel;
end; // TBaseSetPointControl.Get_OutputChannel

function TBaseSetPointControl.ComputeNewSetPoint(SPValue : Double) : SmallInt;
begin
  Result := 0;
  if FEnabled then
  begin
    Result        := FOutputChannel.ComputeADOutput(SPValue);
    FScaledOutput := FOutputChannel.Value_ScaledOutput;
//    if Assigned(FOnNewSetPoint) then
//      FOnNewSetPoint(Self,FSPCNumber,FSetPointControlType,Result);
  end; // If
end; // TBaseSetPointControl.ComputeNewSetPoint

procedure TBaseSetPointControl.ConfigureSPChannel(Var ChannelConfig : TSPControlConfiguration);
begin
  FChannelConfig := ChannelConfig;
  with FChannelConfig do
  begin
    FInputChannel.Config_InputChannel(FChannelConfig.InputConfig);
    FOutputChannel.ConfigureOutputChannel(FChannelConfig.OutputConfig,FChannelConfig.PIDConfig);
    SetRequiresOutputCal(FChannelConfig.RequiresOutputCal);
//    if Assigned(FOnNewPIDValues) then
//      FOnNewPIDValues(Self,FSPCNumber,FSetPointControlType,PIDConfig);
  end; // With
end; // TBaseSetPointControl.ConfigureSPChannel

function TBaseSetPointControl.GetRawInput : Double;
begin
  Result := FInputChannel.RawAtoD_Input;
end; // TBaseSetPointControl.GetRawInput

procedure TBaseSetPointControl.SetRawInput(Value : Double);
begin
  FInputChannel.RawAtoD_Input := Value;
end; // TBaseSetPointControl.SetRawInput

function TBaseSetPointControl.GetInputCalFactor(Index : TCalFactorNum) : Double;
begin
  Result := FInputChannel.Input_CalFactor[Index];
end; // TBaseSetPointControl.GetInputCalFactor

procedure TBaseSetPointControl.SetRequiresOutputCal(Value : Boolean);
var
  Config : TChannelConfig;
  PIDConfig : TPIDConfiguration;
begin
  FRequiresOutputCal := Value;
  if Not FRequiresOutputCal then
  begin
    Config := FInputChannel.Read_InputConfig;
    PIDConfig := FOutputChannel.Read_PIDConfig;
    FOutputChannel.ConfigureOutputChannel(Config,PIDConfig);
  end; // If
end; // TBaseSetPointControl.SetRequiredOutputCal

function TBaseSetPointControl.GetInputChanDescription : String;
begin
  Result := FInputChannel.Input_ChanDescription;
end; // TBaseSetPointControl.GetInputChanDescription

procedure TBaseSetPointControl.SetInputCalFactor(Index : TCalFactorNum; Value : Double);
begin
  FInputChannel.Input_CalFactor[Index] := Value;
end; // TBaseSetPointControl.SetInputCalFactor

function TBaseSetPointControl.GetInputCalOffset : Double;
begin
  Result := FInputChannel.Input_CalOffset;
end; // TBaseSetPointControl.GetInputCalOffset

procedure TBaseSetPointControl.SetInputCalOffset(Value : Double);
begin
  FInputChannel.Input_CalOffset := Value;
end; // TBaseSetPointControl.SetInputCalOffset

function TBaseSetPointControl.GetInputCalUnits : TUnits;
begin
  Result := FInputChannel.Input_CalUnits;
end; // TBaseSetPointControl.GetInputCalUnits

function TBaseSetPointControl.GetInputDisplayUnits : TUnits;
begin
  Result := FInputChannel.Input_DisplayUnits;
end; // TBaseSetPointControl.GetInputDisplayUnits

function TBaseSetPointControl.GetInputScale : Double;
begin
  Result := FInputChannel.Input_Scale;
end; // TBaseSetPointControl.GetInputScale

function TBaseSetPointControl.GetInputHiAtoDRange : SmallInt;
begin
  Result := FInputChannel.AtoDRange_Hi;
end; // TBaseSetPointControl.GetInputHiAtoDRange

function TBaseSetPointControl.GetInputLoAtoDRange : SmallInt;
begin
  Result := FInputChannel.AtoDRange_Lo;
end; // TBaseSetPointControl.GetInputLoAtoDRange

function TBaseSetPointControl.GetInputChannelZero : Double;
begin
  Result := FInputChannel.Input_ChannelZero;
end; // TBaseSetPointControl.GetInputChannelZero

procedure TBaseSetPointControl.SetInputChannelZero(Value : Double);
begin
  FInputChannel.Input_ChannelZero := Value;
end; // TBaseSetPointControl.SetInputChannelZero

function TBaseSetPointControl.GetInputGuage : TDVM;
begin
  Result := FInputChannel.Input_Guage;
end; // TBaseSetPointControl.GetInputGuage

procedure TBaseSetPointControl.SetInputGuage(Value : TDVM);
begin
  FInputChannel.Input_Guage := Value;
end; // TBaseSetPointControl.SetInputGuage

function TBaseSetPointControl.GetInputUseCalOffset : Boolean;
begin
  Result := FInputChannel.UseCalOffset;
end; // TBaseSetPointControl.GetInputUseCalOffset

function TBaseSetPointControl.GetInputEUValue : Double;
begin
  Result := FInputChannel.Value_EUofInput;
end; // TBaseSetPointControl.GetInputEUValue

function TBaseSetPointControl.GetOutputCalFactor(Index : TCalFactorNum) : Double;
begin
  Result := FOutputChannel.Output_CalFactor[Index];
end; // TBaseSetPointControl.GetOutputCalFactor

procedure TBaseSetPointControl.SetOutputCalFactor(Index : TCalFactorNum; Value : Double);
begin
  FOutputChannel.Output_CalFactor[Index] := Value;
end; // TBaseSetPointControl.SetOutputCalFactor

function TBaseSetPointControl.GetOutputCalOffset : Double;
begin
  Result := FOutputChannel.Output_CalOffset;
end; // TBaseSetPointControl.GetOutputCalOffset

procedure TBaseSetPointControl.SetOutputCalOffset(Value : Double);
begin
  FOutputChannel.Output_CalOffset := Value;
end; // TBaseSetPointControl.SetOutputCalOffset

function TBaseSetPointControl.GetOutputCalUnits : TUnits;
begin
  Result := FOutputChannel.Output_CalUnits;
end; // TBaseSetPointControl.GetOutputCalUnits

function TBaseSetPointControl.GetOutputScale : Double;
begin
  Result := FOutputChannel.Output_Scale;
end; // TBase SetPointControl.GetOutputScale

function TBaseSetPointControl.GetOutputChannelZero : Double;
begin
  Result := FOutputChannel.Output_ChannelZero;
end; // TBaseSetPointControl.GetOutputChannelZero

procedure TBaseSetPointControl.SetOutputChannelZero(Value : Double);
begin
  FOutputChannel.Output_ChannelZero := Value;
end; // TBaseSetPointControl.SetOutputChannelZero

function TBaseSetPointControl.GetOutputHiAtoDRange : SmallInt;
begin
  Result := FOutputChannel.AtoDRange_Hi;
end; // TBaseSetPointControl.GetOutputHiAtoDRange

function TBaseSetPointControl.GetOutputLoAtoDRange : SmallInt;
begin
  Result := FOutputChannel.AtoDRange_Lo;
end; // TBseSetPointControl.GetOutputLoAtoDRange

function TBaseSetPointControl.GetRawAtoDOutput : SmallInt;
begin
  Result := FOutputChannel.Value_IntOutput;
end; // TBaseSetPointControl.GetRawAtoDOutput

function TBaseSetPointControl.GetScaledInput : Double;
begin
  Result := FInputChannel.Value_ScaledInput;
end; // TBaseSetPointControl.GetScaledInput

function TBaseSetPointControl.GetInputCalculationMethod : TCalculationMethod;
begin
  Result := FInputChannel.CalculationMethod;
end; // TBaseSetPointControl.GetInputCalulationMethod

function TBaseSetPointControl.GetOutputCalculationMethod : TCalculationMethod;
begin
  Result := FOutputChannel.CalculationMethod;
end; // TBaseSetPointControl.GetOutputCalculationMethod

procedure TBaseSetPointControl.SetOutputCalculationMethod(Value : TCalculationMethod);
begin
  FOutputChannel.CalculationMethod := Value;
end; // TBaseSetPointControl.SetOutputCalculationMethod

function TBaseSetPointControl.GetPIDPValue : SmallInt;
begin
  Result := FOutputChannel.PID_P;
end; // TBaseSetPointControl.GetPIDPValue

procedure TBaseSetPointControl.SetPIDPValue(Value : SmallInt);
begin
  FOutputChannel.PID_P := Value;
end; // TBaseSetPointControl.SetPIDPValue

function TBaseSetPointControl.GetPIDIValue : SmallInt;
begin
  Result := FOutputChannel.PID_I;
end; // TBaseSetPointControl.GetPIDIValue

procedure TBaseSetPointControl.SetPIDIValue(Value : SmallInt);
begin
  FOutputChannel.PID_I := Value
end; // TBaseSetPointControl.SetPIDIValue

function TBaseSetPointControl.GetPIDDValue : SmallInt;
begin
  Result := FOutputChannel.PID_D;
end; // TBaseSetPointControl.GetPIDDValue

procedure TBaseSetPointControl.SetPIDDValue(Value : SmallInt);
begin
  FOutputChannel.PID_D := Value
end; // TBaseSetPointControl.SetPIDDValue

function TBaseSetPointControl.GetPIDCNValue : SmallInt;
begin
  Result := FOutputChannel.PID_CN;
end; // TBaseSetPointControl.GetPIDCNValue

procedure TBaseSetPointControl.SetPIDCNValue(Value : SmallInt);
begin
  FOutputChannel.PID_CN := Value;
end; // TBaseSetPointControl.SetPIDCNValue

function TBaseSetPointControl.GetPIDCPValue : SmallInt;
begin
  Result := FOutputChannel.PID_CP;
end; // TBaseSetPointControl.GetPIDCPValue

procedure TBaseSetPointControl.SetPIDCPValue(Value : SmallInt);
begin
  FOutputChannel.PID_CP := Value;
end; // TBaseSetPointControl.SetPIDCPValue

procedure TBaseSetPointControl.SetNewSetPoint(Value : Double);
begin
  FIntSetPoint := ComputeNewSetPoint(Value);
end; // TBaseSetPointControl.SetNewSetPoint

constructor TLoad_SetPointControl.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FSetPointControlType := SPC_Load;
end; // TLoad_SetPointControl.Create

destructor TLoad_SetPointControl.Destroy;
begin
  inherited Destroy;
end; // TLoad_Set_PointControl.Destroy

constructor TSlip_SetPointControl.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FSetPointControlType := SPC_Slip;
end; // TSlip_SetPointControl.Create

destructor TSlip_SetPointControl.Destroy;
begin
  inherited Destroy;
end; // TSlip_SetPointControl.Destroy

constructor TCamber_SetPointControl.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FSetPointControlType := SPC_Camber;
end; // TCamber_SetPointControl.Create

constructor TInflation_SetPointControl.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FSetPointControlType := SPC_Inflation;
end; // TCamber_SetPointControl.Create

destructor TInflation_SetPointControl.Destroy;
begin
  inherited Destroy;
end; // TCamber_SetPointControl.Destroy

destructor TCamber_SetPointControl.Destroy;
begin
  inherited Destroy;
end; // TCamber_SetPointControl.Destroy

constructor TPosition_SetPointControl.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FSetPointControlType := SPC_Position;
  FErrorAngle := 0;
  FCorrectionFactor := 0;
  FSpindleoffset := 0;
  FPivotToWheelCenter := 0;
  FUncorrectedPz := 0;
  FDeflection := 0;
  FTireOD := 0;
end; // TPosition_SetPointControl.Create

destructor TPosition_SetPointControl.Destroy;
begin
  inherited Destroy;
end; // TPosition_SetPointControl.Destroy

function TPosition_SetPointControl.ComputeNewSetPoint(SPValue : Double) : SmallInt;
var
  SP_Corrected : Double;
begin
  if FEnabled then
  begin
    FEUSetPoint := SPValue;
    if (FSetPointControlType = SPC_Camber) then
    begin
      if (FSpindleOffset <> 0) then
        FEUSetPoint := (SPValue + (FPivotToWheelCenter * Sin(FErrorAngle / 57.3)))
      else
        FEuSetPoint := (SPValue + FCorrectionFactor + FSpindleoffset);
    end; // If
    Result := inherited ComputeNewSetPoint(FEUSetPoint);
//    if Assigned(FOnNewSetPoint) then
//      FOnNewSetPoint(Self,FSPCNumber,FSetPointControlType,FIntSetPoint);
  end; // If
end; // TPosition_SetPointControl.ComputeNewSetPoint

procedure TPosition_SetPointControl.SetRawInput(Value : Double);
var
  L1 : Double;
  ErrAngleRadians : Double;
  TireRadius : Double;
begin
  inherited SetRawInput(Value);
  FUncorrectedPz := FInputChannel.Value_EUofInput;
  if FEnabled then
  begin
    if (FSetPointControlType = SPC_Position) then
    begin
      if (FSpindleOffset = 0) then
      begin // Spindle is NOT offset...
        FCorrectionFactor := (FPivotToWheelCenter * Sin(FErrorAngle / 57.3));
        FReqeustedEUSpValue :=  UnCorrectedPz - FCorrectionFactor;
      end
      else
      begin // Spindle IS offset...
        L1 := Sqrt(Sqr(FSpindleOffset) + Sqr(FPivotToWheelCenter));
        ErrAngleRadians := (FErrorAngle / (180 / Pi));
        FCorrectionFactor := ((L1 * ErrAngleRadians) * Sin( ((180 - Abs(FErrorAngle)) / (( 180 / Pi) * 2)) - (ArcTan(FSpindleOffset / FPivotToWheelCenter)) ));
        FReqeustedEUSpValue := (UnCorrectedPz - FSpindleOffset) - FCorrectionFactor;
      end; // If
    end; // If
  end; // If
  TireRadius := (FTireOD / 2);
  FDeflection := (TireRadius - FReqeustedEUSpValue);
  if (FDeflection < 0) then
    FDeflection := 0;
end; // TPosition_SetPointControl.SetRawInput

constructor TDrive_SetPointControl.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FSetPointControlType := SPC_Drive;
//  FSampleMethod := M_Normal;
//  FillChar(FDriveConfig,SizeOf(FDriveConfig),#0);
end; // TDrive_SetPointControl.Create

destructor TDrive_SetPointControl.Destroy;
begin
  inherited Destroy;
end; // TDrive_SetPointControl.Destroy

//procedure TDrive_SetPointControl.ConfigureDriveChannel(Var ChannelConfig : TDriveConfiguration);
//begin
//  FDriveConfig := ChannelConfig;
//  FSampleMethod := FDriveConfig.SpeedMeasurementType;
//  ConfigureSPChannel(FDriveConfig.NormalConfig);
//end; // TDrive_SetPointControl.ConfigureDriveChannel

//procedure TDrive_SetPointControl.SetRawInput(Value : Double);
//var
//  RWRpm : Double;
//begin
//  case FSampleMethod of
//    M_Normal  : inherited SetRawInput(Value);
//    M_Samples : begin
//                  with FDriveConfig.DeltaSampleConfig do
//                  begin
//                    if (Value = 0) then
//                      RWRpm := 0
//                    else
//                      RWRpm := (((SamplesPerSecond * RoadWheelRevsPerPeriod) / Value) * 60{sec per min});
//                    FReqeustedEUSpValue{mph} := (RWrpm / RWConstant);
//                  end; // With
//                end; // M_Samples
//  end; // Case
//end; // TDrive_SetPointControl.SetRawInput

constructor TSetPointControlManager.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FSetPointControls := TStringList.Create;
end; // TSetPointControlManager.Create

destructor TSetPointControlManager.Destroy;
var
  SP : DWord;
begin
  if (FSetPointControls.Count > 0) then
  begin
    for SP := 0 to (FSetPointControls.Count - 1) do
      RemoveSetPointControl(SP);
  end; // If
  FSetPointControls.Free;
  inherited Destroy;
end; // TSetPointControlManager.Destory

function TSetPointControlManager.GetSetPointControl(Index : LongInt) : TBaseSetPointControl;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl
  else
    Result := Nil;
end; // TSetPointControlManager.GetSetPointControl

function TSetPointControlManager.GetSPCInputChanDescription(Index : DWord) : String;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Input_ChanDescription
  else
    Result := '';
end; // TSetPointControlManager.GetSPCInputChanDescription

function TSetPointControlManager.GetSPCInputCalFactor(Index : DWord; CFNum : TCalFactorNum) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Input_CalFactor[CFNum]
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCInputCalFactor

procedure TSetPointControlManager.SetSPCInputCalFactor(Index : DWord; CFNum : TCalFactorNum; Value : Double);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.Input_CalFactor[CFNum] := Value;
end; // TSetPointControlManager.SetSPCInputCalFactor

function TSetPointControlManager.GetSPCInputCalOffset(Index : DWord) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Input_CalOffset
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCInputCalOffset

procedure TSetPointControlManager.SetSPCInputCalOffset(Index : DWord; Value : Double);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.Input_CalOffset := Value;
end; // TSetPointControlManager.SetSPCInputCalOffset

function TSetPointControlManager.GetSPCInputCalUnits(Index : DWord) : TUnits;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Input_CalUnits
  else
    Result := uCustom;
end; // TSetPointControlManager.GetSPCInputCalUnits

function TSetPointControlManager.GetSPCInputDisplayUnits(Index : DWord) : TUnits;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Input_DisplayUnits
  else
    Result := uCustom;
end; // TSetPointControlManager.GetSPCInputDisplayUnits

function TSetPointControlManager.GetSPCInputScale(Index : DWord) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Input_Scale
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCInputScale

function TSetPointControlManager.GetSPCInputGuage(Index : DWord) : TDVM;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Input_Guage
  else
    Result := Nil;
end; // TSetPointControlManager.GetSPCInputScale

procedure TSetPointControlManager.SetSPCInputGuage(Index : DWord; Value : TDVM);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.Input_Guage := Value;
end; // TSetPointControlManager.SetSPCInputGuage

function TSetPointControlManager.GetSPCChannelZero(Index : DWord) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Input_ChannelZero
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCChannelZero

procedure TSetPointControlManager.SetSPCChannelZero(Index : DWord; Value : Double);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.Input_ChannelZero := Value;
end; // TSetPonitControlManager.SetSPCChannelZero

function TSetPointControlManager.GetSPCInputHiADRange(Index : DWord) : SmallInt;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Input_HiAtoDRange
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCInputHiADRange

function TSetPointControlManager.GetSPCInputLoADRange(Index : Dword) : SmallInt;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Input_LoAtoDRange
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCInputLoADRange

function TSetPointControlManager.GetSPCScaledInput(Index : DWord) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Value_ScaledInput
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCScaledInput

function TSetPointControlManager.GetSPCEUofInput(Index : DWord) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Value_EUofInput
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCEUofInput

function TSetPointControlManager.GetSPCCalcType(Index : DWord) : TCalculationMethod;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.InputCalculationMethod
  else
    Result := Calc_Linear;
end; // TSetPointControlManager.GetSPCCalcType

function TSetPointControlManager.GetSPCUseCalOffset(Index : DWord) : Boolean;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Input_UseCalOffset
  else
    Result := False;
end; // TSetPointControlManager.GetSPCUseCalOffset

function TSetPointControlManager.GetSPCIntSetPoint(Index : DWord) : SmallInt;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.IntSetPoint
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCIntSetPoint

function TSetPointControlManager.GetSPCEUSetPoint(Index : DWord) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.EUSetPoint
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCEUSetPoint

function TSetPointControlManager.GetSPCOutputCalFactor(Index : DWord; CFNum : TCalFactorNum) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Output_CalFactor[CFNum]
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCOutputCalFactor

procedure TSetPointControlManager.SetSPCOutputCalFactor(Index : DWord; CFNum : TCalFactorNum; Value : Double);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.Output_CalFactor[CFNum] := Value;
end; // TSetPointControlManager.SetSPCOutputCalFactor

function TSetPointControlManager.GetSPCOutputCalOffset(Index : DWord) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Output_CalOffset
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCOutputCalOffset

procedure TSetPointControlManager.SetSPCOutputCalOffset(Index : DWord; Value : Double);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.Output_CalOffset := Value;
end; // TSetPointControlManager.SetSPCOutputCalOffset

function TSetPointControlManager.GetSPCOutputCalUnits(Index : DWord) : TUnits;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Output_CalUnits
  else
    Result := uCustom;
end; // TSetPointControlManager.GetSPCOutputCalUnits

function TSetPointControlManager.GetSPCOutputScale(Index : DWord) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Output_Scale
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCOutputScale

function TSetPointControlManager.GetSPCOutputChannelZero(Index : DWord) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Output_ChannelZero
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCOutputChannelZero

procedure TSetPointControlManager.SetSPCOutputChannelZero(Index : DWord; Value : Double);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.Output_ChannelZero := Value;
end; // TSetPointControlManager.SetSPCOutputChannelZero

function TSetPointControlManager.GetSPCOutputHiADRange(Index : DWord) : SmallInt;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Output_HiAtoDRange
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCOutputHiADRange

function TSetPointControlManager.GetSPCOutputLoADRange(Index : DWord) : SmallInt;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Output_LoAtoDRange
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCOutputLoADRange

function TSetPointControlManager.GetSPCRawAtoDInput(Index : DWord) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.RawAtoD_Input
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCRawAtoDInput

procedure TSetPointControlManager.SetSPCRawAtoDInput(Index : DWord; Value : Double);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.RawAtoD_Input := Value;
end; // TSetPointControlManager.SetSPCRawAtoDInput

function TSetPointControlManager.GetSPCCurrentEUSetPoint(Index : DWord) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Requested_EUSetPoint
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCCurrentEUSetPoint

procedure TSetPointControlManager.SetSPCNewSetPoint(Index : DWord; Value : Double);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.NewSetPoint := Value;
end; // TSetPointControlManager.SetSPCNewSetPoint

function TSetPointControlManager.GetSPCScaledOutput(Index : DWord) : Double;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Value_ScaledOutput
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCScaledOutput

function TSetPointControlManager.GetSPCPID_PValue(Index : DWord) : SmallInt;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.PID_P
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCPID_PValue

procedure TSetPointControlManager.SetSPCPID_PValue(Index : DWord; Value : SmallInt);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.PID_P := Value;
end; // TSetPointControlManager.SetSPCPID_PValue

function TSetPointControlManager.GetSPCPID_IValue(Index : DWord) : SmallInt;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.PID_I
  else
    Result := 0;
end; // TSetPointControlManger.GetSPCPID_IValue

procedure TSetPointControlManager.SetSPCPID_IValue(Index : DWord; Value : SmallInt);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.PID_I := Value;
end; // TSetPointControlManager.SetSPCPID_IValue

function TSetPointControlManager.GetSPCPID_DValue(Index : DWord) : SmallInt;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.PID_D
  else
    Result := 0;
end; // TSetPointcontrolManager.GetSPCPID_DValue

procedure TSetPointControlManager.SetPSCPID_DValue(Index : DWord; Value : SmallInt);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.PID_D := Value;
end; // TSetPointControlManager.SetPSCPID_DValue

function TSetPointControlManager.GetSPCPID_CNValue(Index : DWord) : SmallInt;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.PID_CN
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCPID_CNValue

procedure TSetPointControlManager.SetSPCPID_CNValue(Index : DWord; Value : SmallInt);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.PID_CN := Value;
end; // TSetPointControlManager.SetSPCPID_CNValue

function TSetPointControlManager.GetSPCPID_CPValue(Index : DWord) : SmallInt;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.PID_CP
  else
    Result := 0;
end; // TSetPointControlManager.GetSPCPID_CPValue

procedure TSetPointControlManager.SetSPCPID_CPValue(Index : DWord; Value : SmallInt);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.PID_CP := Value;
end; // TSetPointControlManager.SetSPCPID_CPValue

function TSetPointControlManager.GetRequiresOutputCal(Index : DWord) : Boolean;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.RequiresOutputCal
  else
    Result := False;
end; // TSetPointControlManager.GetRequiresOutputCal

procedure TSetPointControlManager.SetRequriesOutputCal(Index : DWord; Value : Boolean);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    SPControl.RequiresOutputCal := Value;
end; // TSetPointControlManager.SetRequiresOutputCal

function TSetPointControlManager.GetSPCEnabled(Index : DWord) : Boolean;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Enabled
  else
    Result := False;
end; // TSetPointControlManager.GetSPCEnabled

procedure TSetPointControlManager.SetSPCEnabled(Index :DWord; Value : Boolean);
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index, SPControl) then
    SPControl.Enabled := Value;
end; // TSetPointManager.SetSPCEnabled

function TSetPointControlManager.SPControlType(SPControl : TBaseSetPointControl) : TSetPointControlType;
begin
  Result := SPC_Base;
  if Assigned(SPControl) then
  begin
    if (SPControl is TLoad_SetPointControl) then
      Result := SPC_Load;
    if (SPControl is TSlip_SetPointControl) then
      Result := SPC_Slip;
    if (SPControl is TCamber_SetPointControl) then
      Result := SPC_Camber;
    if (SPControl is TPosition_SetPointControl) then
      Result := SPC_Position;
    if (SPControl is TDrive_SetPointControl) then
      Result := SPC_Drive;
    if (SPControl is TInflation_SetPointControl) then
      Result := SPC_Inflation;
  end; // If
end; // TSetPointControlManager.SPControlType

//procedure TSetPointControlManager.SPCNewSetPoint(Sender : TObject; SPCNumber : Byte; SetPointControlType : TSetPointControlType; NewSetPoint : SmallInt);
//begin
//  if Assigned(FOnSPCNewSetPoint) then
//    FOnSPCNewSetPoint(Sender,SPCNumber,SetPointControlType,NewSetPoint);
//end; // TSetPointControlManager.SPCNewSetPoint

//procedure TSetPointControlManager.SPCNewPIDValues(Sender : TObject; SPCNumber : Byte; SetPointControlType : TSetPointControlType; PIDConfig : TPIDConfiguration);
//begin
//  if Assigned(FOnSPCNewPIDValues) then
//    FOnSPCNewPIDValues(Sender,SPCNumber,SetPointControlType,PIDConfig);
//end; // TSetPointControlManager.SPCNewPIDValues

function TSetPointControlManager.SPControlExists(Index : LongInt; Var SPControl : TBaseSetPointControl) : Boolean;
var
  ActualIndex : LongInt;
begin
  ActualIndex := FSetPointControls.IndexOf(IntToStr(Index));
  Result := (ActualIndex > INVALID_INDEX);
  if Result then
    SPControl := (FSetPointControls.Objects[ActualIndex] as TBaseSetPointControl)
  else
    SPControl := Nil;
end; // TSetPointControlManager.SPControlExists

function TSetPointControlManager.AddSetPointControl(SetPointControlType : TSetPointControlType) : LongInt;
var
  SPControl : TBaseSetPointControl;
begin
  Result := INVALID_INDEX;
  case SetPointControlType of
    SPC_Load      : SPControl := TLoad_SetPointControl.Create(Self);
    SPC_Position  : SPControl := TPosition_SetPointControl.Create(Self);
    SPC_Slip      : SPControl := TSlip_SetPointControl.Create(Self);
    SPC_Camber    : SPControl := TCamber_SetPointControl.Create(Self);
    SPC_Drive     : SPControl := TDrive_SetPointControl.Create(Self);
    SPC_Inflation : SPControl := TInflation_SetPointControl.Create(Self);
  else
    SPControl := Nil;
  end; // Case
  if Assigned(SPControl) then
  begin
    SPControl.Enabled := True;
    SPControl.SPC_Number := FSetPointControls.Count;
//    SPControl.OnNewSetPoint := SPCNewSetPoint;
//    SPControl.OnNewPIDValues := SPCNewPIDValues;
    Result := SPControl.SPC_Number;
    FSetPointControls.AddObject(IntToStr(Result),SPControl);
  end; // If
end; // TSetPointControlManager.AddSetPointControl

function TSetPointControlManager.RemoveSetPointControl(Index : DWord) : Boolean;
var
  SPControl : TBaseSetPointControl;
  ActualIndex : DWord;
begin
  ActualIndex := FSetPointControls.IndexOf(IntToStr(Index));
  if (ActualIndex > INVALID_INDEX) then
  begin
    SPControl := FSetPointControls.Objects[ActualIndex] as TBaseSetPointControl;
    FSetPointControls.Delete(ActualIndex);
    SPControl.Free;
    Result := True;
  end
  else
    Result := False;
end; // TSetPointControlManager.RemoveSetPointControl

function TSetPointControlManager.SetPointControlCount : DWord;
begin
  Result := FSetPointControls.Count;
end; // TSetPointControlManager.SetPointControlCount

function TSetPointControlManager.ConfigureSPControl(Index : DWord; ChannelConfig : Pointer; RecSize : DWord) : Boolean;
var
  SPControl : TBaseSetPointControl;
//  DriveConfigPtr : ^TDriveConfiguration;
  ChannelCfgPtr : ^TSPControlConfiguration;
  ChanCfg : TSPControlConfiguration;
//  DrvCfg : TDriveConfiguration;
begin
  Result := False;
  if SPControlExists(Index,SPControl) then
  begin
    case RecSize of
      SizeOf(TSPControlConfiguration) : begin
                                          FillChar(ChanCfg,SizeOf(ChanCfg),#0);
                                          ChannelCfgPtr := ChannelConfig;
                                          with ChanCfg do
                                          begin
                                            InputConfig       := ChannelCfgPtr.InputConfig;
                                            OutputConfig      := ChannelCfgPtr.OutputConfig;
                                            PIDConfig         := ChannelCfgPtr.PIDConfig;
                                            RequiresOutputCal := ChannelCfgPtr.RequiresOutputCal;
                                          end; // If
                                          SPControl.ConfigureSPChannel(ChanCfg);
                                          Result := True;
                                        end; // TSPControlConfiguration
//        SizeOf(TDriveConfiguration)   : begin
//                                          if (SPControl is TDrive_SetPointControl) then
//                                          begin
//                                            FillChar(DrvCfg,SizeOf(DrvCfg),#0);
//                                            DriveConfigPtr := ChannelConfig;
//                                            with DrvCfg do
//                                            begin
//                                              SpeedMeasurementType := DriveConfigPtr.SpeedMeasurementType;
//                                              NormalConfig         := DriveConfigPtr.NormalConfig;
//                                              DeltaSampleConfig    := DriveConfigPtr.DeltaSampleConfig;
//                                            end; // If
//                                            (SPControl as TDrive_SetPointControl).ConfigureDriveChannel(DrvCfg);
//                                            Result := True;
//                                          end
//                                          else
//                                            Result := False;
//                                        end; // TDriveConfiguration
    end; // Case
  end; // If
end; // TSetPointControlManager.ConfigureSPControl

function TSetPointControlManager.Get_SPCInputChannel(Index : DWord) : TInputChannel;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Get_InputChannel
  else
    Result := Nil;
end; // TSetPointControlManager.Get_SPCInputChannel

function TSetPointControlManager.Get_SPCOutputChannel(Index : DWord) : TOutputChannel;
var
  SPControl : TBaseSetPointControl;
begin
  if SPControlExists(Index,SPControl) then
    Result := SPControl.Get_OutputChannel
  else
    Result := Nil;
end; // TSetPointControlManager.Get_SPCOutputChannel

end.
