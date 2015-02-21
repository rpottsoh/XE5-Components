unit DVM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, stdctrls;

type
  tLimitEvent = procedure( Sender : TObject; TriggerValue : extended ) of Object;
  TUnits = (uCustom, uPounds, uKilograms, uNewtons, uMM, uCM, uIN, uPSI, uKPA,
            uMPH, uKPH, uIN3pSEC, uCM3pSEC, uGPM, uLPM, uDegrees, uINLBS, uFTLBS, uKGM, uNM, udegF,
            udegC,uBar,uMI,uKM);
  TCustomDVM = class(TCustomPanel)
  private
    { Private declarations }
    FDataWork,
    FData : extended;
    FTitle : TLabel;
    FUnits : TLabel;
    FUnitsCaption : string;
    FTitleFont : TFont;
    FUnitsFont : TFont;
    FLength : integer;
    FPrecision : integer;
    FUpperLimit : extended; //Always enter this value in accordance to ValueUnits
    FLowerLimit : extended; //Always enter this value in accordance to ValueUnits
    FLimitsEnabled : boolean;
    FLimitsUseAvg : Boolean;
    FUpperColor : TColor;
    FLowerColor : TColor;
    FNormalColor : TColor;
    FOnUpperLimit : tLimitEvent;
    FOnLowerLimit : tLimitEvent;
    FOnNormalLevel : tLimitEvent;
    FMeterOn      : boolean;
    ForceChange   : boolean;
    FConvert      : extended;
    FValueUnits   : TUnits;
    FDisplayUnits : TUnits;
    FAvg          : boolean;
    FNumberOfAvgs : integer;
    AvgCount      : integer;
    procedure Convert_Units;
    procedure SetTitle(const TitleVal : string);
    function GetTitle: string;
    procedure SetUnits(const UnitsVal : string);
    function GetUnits: string;
    procedure SetTitleFont(FontVal : TFont);
    function GetTitleFont: TFont;
    procedure SetUnitsFont(FontVal : TFont);
    function GetUnitsFont: TFont;
    procedure SetLength(LengthVal : integer);
    procedure SetValue(NewVal : extended);
    function GetValue: extended;
    procedure SetPrecision(PrecisionVal : integer);
    procedure SetColor(ColorVal : TColor);
    procedure SetUpperLimit(LimitVal : extended);
    procedure SetLowerLimit(LimitVal : extended);
    procedure SetMeterOn(OnVal : boolean);
    procedure SetValueUnits(NewVal : TUnits);
    procedure SetDisplayUnits(NewVal : TUnits);
  protected
    { Protected declarations }
    procedure FireUpperLimitEvent;
    procedure FireLowerLimitEvent;
    procedure FireNormalEvent;
  public
    { Public declarations }
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;
    property Title : string read GetTitle write SetTitle;
    property Units : string read GetUnits write SetUnits;
    property TitleFont : TFont read GetTitleFont write SetTitleFont;
    property UnitsFont : TFont read GetUnitsFont write SetUnitsFont;
    property value : extended read GetValue write SetValue;
    property ValueLength : integer read FLength write SetLength default 0;
    property Precision : integer read FPrecision write SetPrecision default 2;
      //Always enter this value in accordance to ValueUnits
    property UpperLimit : extended read FUpperLimit write SetUpperLimit;
      //Always enter this value in accordance to ValueUnits
    property LowerLimit : extended read FLowerLimit write SetLowerLimit;
    property LimitsEnabled : boolean read FLimitsEnabled write FLimitsEnabled default false;
    property LimitsUseAvg : Boolean read FLimitsUseAvg write FLimitsUseAvg;
    property MeterColor : TColor read FNormalColor write SetColor;
    property LowerLimitColor : TColor read FLowerColor write FLowerColor;
    property UpperLimitColor : TColor read FUpperColor write FUpperColor;
    property OnUpperLimit : tLimitEvent read FOnUpperLimit write FOnUpperLimit;
    property OnLowerLimit : tLimitEvent read FOnLowerLimit write FOnLowerLimit;
    property OnNormalLevel : tLimitEvent read FOnNormalLevel write FOnNormalLevel;
    property MeterOn : boolean read FMeterOn write SetMeterOn default true;
    property ValueUnits : TUnits read FValueUnits write SetValueUnits default uCustom;
    property DisplayUnits : TUnits read FDisplayUnits write SetDisplayUnits default uCustom;
    property NumberOfAverages : integer read FNumberOfAvgs write FNumberOfAvgs default 1;
      // if Average is FALSE then the DVM will skip "NumberOfAverages" instead of
      //   Average.  If "NumberOfAverages" is 1 and "Average" is false then every
      //   value passed into "Value" will be displayed.  This is the same as if
      //   "Average" is true and "NumberOfAverages" is 1.
    property Average : boolean read FAvg write FAvg default true;
  published
    { Published declarations }
    property Alignment;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderWidth;
    property BorderStyle;
    property font;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    Property OnMouseUp;
    property Visible;
  end;

  TDVM = class(TCustomDVM)
  published
    property Title;
    property Units;
    Property TitleFont;
    property UnitsFont;
    property value;
    property ValueLength;
    property Precision;
    property MeterColor;
    property LimitsEnabled;
    property LimitsUseAvg;    
    property LowerLimitColor;
    property UpperLimitColor;
    property UpperLimit;
    property LowerLimit;
    property OnUpperLimit;
    property OnLowerLimit;
    property OnNormalLevel;
    property MeterOn;
    property ValueUnits;
    property DisplayUnits;
    property NumberOfAverages;
    property Average;
  end;

const
  UnitStrings : array[uCustom..uKM] of shortstring = ('',
                                                      'lbs',
                                                      'kg',
                                                      'N',
                                                      'mm',
                                                      'cm',
                                                      'in',
                                                      'PSI',
                                                      'KPA',
                                                      'MPH',
                                                      'KPH',
                                                      'in³/sec.',
                                                      'cm³/sec.',
                                                      'GPM',
                                                      'LPM',
                                                      'DEG',
                                                      'inlbs',
                                                      'ftlbs',
                                                      'kgm',
                                                      'Nm',
                                                      'F',
                                                      'C',
                                                      'bar',
                                                      'miles',
                                                      'km');

//procedure Register;

implementation

uses TMSIDataTypes, math;

constructor TCustomDVM.create;
begin
  inherited create(AOwner);
  FConvert := 1.0;
  FDisplayUnits := uCustom;
  FValueUnits := uCustom;
  FMeterOn := true;
  FUpperLimit := 1.0;
  FLowerLimit := -1.0;
  FUpperColor := clRed;
  FLowerColor := clBlue;
  FLimitsEnabled := false;
  FLimitsUseAvg := False;
  FAvg := true;
  FNumberOfAvgs := 1;
  AvgCount      := 0;
  FLength := 0;
  FPrecision := 2;
  Alignment := taCenter;
  BevelInner := bvLowered;
  BevelOuter := bvRaised;
  BevelWidth := 2;
  BorderWidth := 1;
  FData := 0.0;
  FDataWork := 0.0;
  Caption := format('%*.*f',[FLength,FPrecision,FData]);
  FNormalColor := $00D2E3E2;
  Color := FNormalColor;
  with font do
  begin
    font.Color := $00004080;
    size := 18;
    name := 'arial';
    style := [fsbold];
  end;
  width := 107;
  height := 97;
  FTitle := TLabel.create(self);
  FUnits := TLabel.create(self);
  FTitle.Caption := 'DVM';
  FUnitsCaption := 'Volts';
  FUnits.Caption := FUnitsCaption;
  FTitle.Parent := self;
  FUnits.Parent := self;
  FTitle.align := alTop;
  FTitle.Alignment := taCenter;
  FUnits.Alignment := taCenter;
  FUnits.Align := alBottom;
  FTitle.Transparent := true;
  FUnits.Transparent := true;
  FTitleFont := TFont.Create;
  FUnitsFont := TFont.Create;
  FTitleFont.Color := clWindowText;
  FTitleFont.Name := 'arial';
  FTitleFont.Size := 12;
  FTitleFont.Style := [fsbold];
  FUnitsFont := FTitleFont;
  FTitle.Font := FTitleFont;
  FUnits.Font := FUnitsFont;
end;

//******************* FtoC *************************
//  Convert a Degree F to a Degree C
//
//  Termpature Conversion
//**************************************************
function FtoC(Value : extended): extended;
begin
  result := (Value - 32) * (5/9);
end;

//******************* CtoF *************************
//  Convert a Degree C to a Degree F
//
//  Termpature Conversion
//**************************************************
function CtoF(Value : extended): extended;
begin
  result := (Value * (9/5)) + 32;
end;

destructor TCustomDVM.destroy;
begin
  FTitle.free;
  FUnits.Free;
  inherited destroy;
end;

procedure TCustomDVM.SetTitle(const TitleVal : string);
begin
  FTitle.Caption := TitleVal;
end;

function TCustomDVM.GetTitle: string;
begin
  result := FTitle.Caption;
end;

procedure TCustomDVM.SetUnits(const UnitsVal : string);
begin
  FUnitsCaption := UnitsVal;
  if FDisplayUnits = uCustom then
    FUnits.Caption := FUnitsCaption
  else
  begin
    FUnits.Caption := UnitStrings[FDisplayUnits];
  end;
end;

function TCustomDVM.GetUnits: string;
begin
  result := FUnits.Caption;
end;

procedure TCustomDVM.SetTitleFont(FontVal : TFont);
begin
  FTitle.Font := FontVal;
end;

function TCustomDVM.GetTitleFont: TFont;
begin
  result := FTitle.Font;
end;

procedure TCustomDVM.SetUnitsFont(FontVal : TFont);
begin
  FUnits.Font := FontVal;
end;

function TCustomDVM.GetUnitsFont: TFont;
begin
  result := FUnits.Font;
end;

procedure TCustomDVM.SetLength(LengthVal: integer);
var temp : integer;
    i    : integer;
    TempStr : string;
begin
  if LengthVal <> FLength then
  begin
    FLength := LengthVal;
    Caption := format('%*.*f',[FLength,FPrecision,FData]);
  end;
end;

procedure TCustomDVM.SetPrecision(PrecisionVal : integer);
begin
  if FPrecision <> PrecisionVal then
  begin
    FPrecision := PrecisionVal;
    if FMeterOn then
      Caption := format('%*.*f',[FLength,FPrecision,FData]);
  end;
end;

procedure TCustomDVM.SetValue(NewVal : extended);
var
  LocalFDataWork : extended;
begin
//  if (NewVal <> FData) or ForceChange then
//  begin
//    ForceChange := false;
//    AvgCount := 0;
//  end;
    if FConvert > 0 then
    begin
      if FAvg then
      begin
        LocalFDataWork := FDataWork;
        LocalFDataWork := ((LocalFDataWork * AvgCount) + (NewVal * FConvert)) / (AvgCount + 1);
        FDataWork := LocalFDataWork;
      end
      else
        FDataWork := NewVal * FConvert;
    end
    else
    if FConvert = -1 then // convert C to F
    begin
      if FAvg then
        FDataWork := ((FDataWork * AvgCount) + CtoF(NewVal)) / (AvgCount + 1)
      else
        FDataWork := CtoF(NewVal);
    end
    else
    if FConvert = -2 then // convert F to C
    begin
      if FAvg then
        FDataWork := ((FdataWork * AvgCount) + FtoC(NewVal)) / (AvgCount + 1)
      else
        FDataWork := FtoC(NewVal);
    end;
    inc(AvgCount);
    if FMeterOn and (AvgCount >= FNumberOfAvgs) then
    begin
      AvgCount := 0;
      FData := FDataWork;
      Caption := format('%*.*f',[FLength,FPrecision,FData]);
      if FLimitsUseAvg then // Override NewVal with average data.
        NewVal := FData;
      if FLimitsEnabled then
      begin
        if NewVal{FData} >= FUpperLimit then
        begin
          Color := FUpperColor;
          FireUpperLimitEvent;
        end
        else
        if NewVal{FData} <= FLowerLimit then
        begin
          Color := FLowerColor;
          FireLowerLimitEvent;
        end
        else
        begin
          Color := FNormalColor;
          FireNormalEvent;
        end;
      end
      else
        Color := FNormalColor;
    end;
//  end;
end;

function TCustomDVM.GetValue: extended;
begin
  result := FData;
end;

procedure TCustomDVM.SetColor(ColorVal : TColor);
begin
//  if ColorVal <> FNormalColor then
//  begin
    FNormalColor := ColorVal;
    Color := FNormalColor;
//  end;
end;

procedure TCustomDVM.SetUpperLimit(LimitVal : extended);
begin
  if LimitVal <> FUpperLimit then
    if LimitVal > FLowerLimit then
      FUpperLimit := LimitVal;
end;

procedure TCustomDVM.SetLowerLimit(LimitVal : extended);
begin
  if LimitVal <> FLowerLimit then
    if LimitVal < FUpperLimit then
      FLowerLimit := LimitVal;
end;

procedure TCustomDVM.FireUpperLimitEvent;
begin
  if assigned(FOnUpperLimit) then
    FOnUpperLimit(self, FData);
end;

procedure TCustomDVM.FireLowerLimitEvent;
begin
  if assigned(FOnLowerLimit) then
    FOnLowerLimit(self, FData);
end;

procedure TCustomDVM.FireNormalEvent;
begin
  if assigned(FOnNormalLevel) then
    FOnNormalLevel(self, FData);
end;

procedure TCustomDVM.SetMeterOn(OnVal : boolean);
begin
  if OnVal <> FMeterOn then
  begin
    FMeterOn := OnVal;
    if FMeterOn then
    begin
      ForceChange := true;
      Value := FData;
      Caption := format('%*.*f',[FLength,FPrecision,FData]);
    end
    else
    begin
      SetColor(FNormalColor);
      Caption := 'N/A';
    end;
  end;
end;

procedure TCustomDVM.SetValueUnits(NewVal : TUnits);
begin
  if FValueUnits <> NewVal then
  begin
    if (FDisplayUnits in [uCustom,udegF,udegC]) and
       (NewVal        in [uCustom,udegF,udegC]) then
      FValueUnits := NewVal
    else
    if (FDisplayUnits in [uCustom,uINLBS,uNM,uFTLBS,uKGM]) and
       (NewVal        in [uCustom,uINLBS,uNM,uFTLBS,uKGM]) then
      FValueUnits := NewVal
    else
    if (FDisplayUnits in [uCustom,uPounds,uKilograms,uNewtons]) and
       (NewVal        in [uCustom,uPounds,uKilograms,uNewtons]) then
      FValueUnits := NewVal
    else
    if (FDisplayUnits in [uCustom,uMM,uCM,uIN]) and
       (NewVal        in [uCustom,uMM,uCM,uIN]) then
      FValueUnits := NewVal
    else
    if (FDisplayUnits in [uCustom,uPSI,uKPA,uBar]) and
       (NewVal        in [uCustom,uPSI,uKPA,uBar]) then
      FValueUnits := NewVal
    else
    if (FDisplayUnits in [uCustom,uMPH,uKPH]) and
       (NewVal        in [uCustom,uMPH,uKPH]) then
      FValueUnits := NewVal
    else
    if (FDisplayUnits in [uCustom,uIN3pSEC,uCM3pSEC,uGPM,uLPM]) and
       (NewVal        in [uCustom,uIN3pSEC,uCM3pSEC,uGPM,uLPM]) then
      FValueUnits := NewVal
    else
    if (FDisplayUnits in [uCustom,uDegrees]) and
       (NewVal      in [uCustom,uDegrees]) then
      FValueUnits := NewVal
    else
    if (FDisplayUnits in [uCustom,uMI,uKM]) and
       (NewVal        in [uCustom,uMI,uKM]) then
      FValueUnits := NewVal;
    if FValueUnits = NewVal then
      Convert_Units;
  end;
end;

procedure TCustomDVM.SetDisplayUnits(NewVal : TUnits);
begin
  if FDisplayUnits <> NewVal then
  begin
    if (FValueUnits in [uCustom,udegF,udegC]) and
       (NewVal      in [uCustom,udegF,udegC]) then
      FDisplayUnits := NewVal
    else
    if (FValueUnits in [uCustom,uNM,uINLBS,uFTLBS,uKGM]) and
       (NewVal      in [uCustom,uNM,uINLBS,uFTLBS,uKGM]) then
      FDisplayUnits := NewVal
    else
    if (FValueUnits in [uCustom,uPounds,uKilograms,uNewtons]) and
       (NewVal      in [uCustom,uPounds,uKilograms,uNewtons]) then
      FDisplayUnits := NewVal
    else
    if (FValueUnits in [uCustom,uMM,uCM,uIN]) and
       (NewVal      in [uCustom,uMM,uCM,uIN]) then
      FDisplayUnits := NewVal
    else
    if (FValueUnits in [uCustom,uPSI,uKPA,uBar]) and
       (NewVal      in [uCustom,uPSI,uKPA,uBar]) then
      FDisplayUnits := NewVal
    else
    if (FValueUnits in [uCustom,uMPH,uKPH]) and
       (NewVal      in [uCustom,uMPH,uKPH]) then
      FDisplayUnits := NewVal
    else
    if (FValueUnits in [uCustom,uIN3pSEC,uCM3pSEC,uGPM,uLPM]) and
       (NewVal        in [uCustom,uIN3pSEC,uCM3pSEC,uGPM,uLPM]) then
      FDisplayUnits := NewVal
    else
    if (FValueUnits in [uCustom,uDegrees]) and
       (NewVal      in [uCustom,uDegrees]) then
      FDisplayUnits := NewVal
    else
    if (FValueUnits in [uCustom,uMI,uKM]) and
       (NewVal      in [uCustom,uMI,uKM]) then
      FDisplayUnits := NewVal;
    if FDisplayUNits = NewVal then
    begin
      Convert_Units;
      SetUnits(FUnitsCaption);
    end;
  end;
end;

procedure TCustomDVM.Convert_Units;
begin
  if (FDisplayUnits = uCustom) or (FValueUnits = uCustom) then
  begin
    FConvert := 1.0;
  end
  else
  case FDisplayUnits of
    udegF   : case FValueUnits of
                 udegF : FConvert := 1;
                 udegC : FConvert := -1; // -1 means convert C to F
              end; //case
    udegC   : case FValueUnits of
                 udegF : FConvert := -2; // -2 means convert F to C
                 udegC : FConvert := 1;
              end; //case
    uINLBS     : case FValueUnits of
                   uNM    : FConvert := 1 / siLoad / siDistance * 1000; //Nm --> inlbs
                   uINLBS : FConvert := 1;
                   uFTLBS : FConvert := 12; //foot pounds to inch pounds
                   uKGM   : FConvert := 1 / siLoadkg / siDistance * 1000; //kgm --> inlbs
                 end; //case
    uNM     : case FValueUnits of
                uINLBS : FConvert := siLoad / siDistance * 1000; //inlbs -- > Nm
                uNM    : FConvert := 1;
                uFTLBS : FConvert := 1.3558180389149605165449797379773; //ftlbs --> Nm
                uKGM   : FConvert := 9.80665; //kgm --> Nm
              end; //case
    uFTLBS  : case FValueUnits of
                uNM    : FConvert := 1 / siLoad / siDistance * 1000 / 12; //Nm --> FTlbs
                uINLBS : FConvert := 1 / 12; //inlbs to ftlbs
                uFTLBS : FConvert := 1;
                uKGM   : FConvert := 1 / siLoadkg / siDistance * 1000 / 12; //kgm --> FTlbs
              end; //case
    uKGM  : case FValueUnits of
              uNM    : FConvert := 1 / 9.8066; //Nm --> kgm
              uINLBS : FConvert := siLoadkg / siDistance * 1000; //inlbs -- > kgm
              uFTLBS : FConvert := 0.13825495344;
              uKGM   : FConvert := 1; //kgm --> FTlbs
            end; //case
    uPounds    : case FValueUnits of
                   uPounds    : FConvert := 1.0;           // lbs --> lbs
                   uKilograms : FConvert := 1 / siLoadKg;  // Kg  --> lbs
                   uNewtons   : FConvert := 1 / siLoad;    // N   --> lbs
                 end; //case
    uKilograms : case FValueUnits of
                   uPounds    : FConvert := siLoadKg;                // lbs --> Kg
                   uKilograms : FConvert := 1.0;                     // Kg  --> Kg
                   uNewtons   : FConvert := (1 / siLoad) * siLoadKg; // N   --> Kg
                 end; //case
    uNewtons   : case FValueUnits of
                   uPounds    : FConvert := siLoad;                  // lbs --> N
                   uKilograms : FConvert := (1 / siLoadKg) * siLoad; // Kg  --> N
                   uNewtons   : FConvert := 1.0;                     // N   --> N
                 end; //case
//---------------------------------------
    uMM        : case FValueUnits of
                    uMM : FConvert := 1.0;                             // mm --> mm
                    uCM : FConvert := (1 / siDistanceCM) * siDistance; // cm --> mm
                    uIN : FConvert := siDistance;                      // in --> mm
                 end; //case
    uCM        : case FValueUnits of
                    uMM : FConvert := (1 / siDistance) * siDistanceCM; // mm --> cm
                    uCM : FConvert := 1.0;                             // cm --> cm
                    uIN : FConvert := siDistanceCM;                    // in --> mm
                 end; //case
    uIN        : case FValueUnits of
                    uMM : FConvert := 1 / siDistance;   // mm --> in
                    uCM : FConvert := 1 / siDistanceCM; // cm --> in
                    uIN : FConvert := 1.0;          // in --> in
                 end; //case
//---------------------------------------
    uPSI       : case FValueUnits of
                   uPSI : FConvert := 1.0;            // PSI --> PSI
                   uKPA : FConvert := 1 / siPressure; // KPA --> PSI
                   uBar : FConvert := BarToPSI;       // bar --> PSI
                 end; //case
    uKPA       : case FValueUnits of
                   uPSI : FConvert := siPressure;            // PSI --> KPA
                   uKPA : FConvert := 1.0;                   // KPA --> KPA
                   uBar : FConvert := BarToPSI * siPressure; // bar --> KPA
                 end; //case
    uBar       : case FValueUnits of
                   uPSI : FConvert := PSItoBar;                   // PSI --> bar
                   uKPA : FConvert := (1 / siPressure) * PSItoBar;// KPA --> bar
                   uBar : FConvert := 1;                          // bar --> bar
                 end; //case
//---------------------------------------
    uMPH       : case FValueUnits of
                   uMPH : FConvert := 1.0;         // MPH --> MPH
                   uKPH : FConvert := 1 / siSpeed; // KPH --> MPH
                 end; //case
    uKPH       : case FValueUnits of
                   uMPH : FConvert := siSpeed;  // MPH --> KPH
                   uKPH : FConvert := 1.0;      // KPH --> KPH
                 end; //case
//---------------------------------------
    uLPM       : case FValueUnits of
                   uCM3pSEC : FConvert := CM3pSECtoLPM; // cm^3/sec --> LPM
                   uIN3pSEC : FConvert := IN3pSECtoLPM; // in^3/sec --> LPM
                   uGPM     : FConvert := GPMtoLPM; // GPM --> LPM
                   uLPM     : FConvert := 1.0;
                 end; //case
    uIN3pSEC   : case FValueUnits of
                   uCM3pSEC : FConvert := 1 / power(siDistanceCM,3); // cm^3/sec --> in^3/sec
                   uIN3pSEC : FConvert := 1.0;                       // in^3/sec --> in^3/sec
                   uGPM     : FConvert := GPMtoI3pSEC;
                   uLPM     : FConvert := 1 / IN3pSECtoLPM; // LPM --> in^3/sec
                 end; //case
    uCM3pSEC   : case FValueUnits of
                   uCM3pSEC : FConvert := 1.0;                   // cm^3/sec --> cm^3/sec
                   uIN3pSEC : FCOnvert := power(siDistanceCM,3); // in^3/sec --> cm^3/sec
                   uGPM     : FCOnvert := GPMtoI3pSEC * power(siDistanceCM,3);
                   uLPM     : FConvert := 1 / CM3pSECtoLPM; // LPM --> cm^3/sec
                 end; //case
    uGPM       : case FValueUnits of
                   uGPM     : FConvert := 1.0;
                   uCM3pSEC : FConvert := (1 / power(siDistanceCM,3)) / GPMtoI3pSEC; // cm^3/sec --> GPM
                   uIN3pSEC : FCOnvert := 1 / GPMtoI3pSEC; // in^3/sec --> GPM
                   uLPM     : FConvert := 1 / GPMtoLPM;    // LPM --> GPM
                 end; //case
    uMI        : case FValueUnits of
                   uMI      : FConvert := 1.0;
                   uKM      : FConvert := 1 / siSpeed;
                 end; //case
    uKM        : case FValueUnits of
                   uMI      : FConvert := siSpeed;
                   uKM      : FConvert := 1;
                 end; //case
  end; //case
  ForceChange := true;
  SetValue(FData);
end;

//procedure Register;
//begin
//  RegisterComponents('TMSI', [TDVM]);
//end;

end.
