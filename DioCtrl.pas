unit DioCtrl;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dio,
  {$IFDEF PCI_DIG_IO}
  CBW,
  {$ELSE}
  CBWDLLTMSI,
  {$ENDIF}
  extctrls, DioAbout;

const
  dFIRSTPORTA      = FIRSTPORTA;
  dFIRSTPORTB      = FIRSTPORTB;
  dFIRSTPORTCL     = FIRSTPORTCL;
  dFIRSTPORTCH     = FIRSTPORTCH;
  dSECONDPORTA     = SECONDPORTA;
  dSECONDPORTB     = SECONDPORTB;
  dSECONDPORTCL    = SECONDPORTCL;
  dSECONDPORTCH    = SECONDPORTCH;

  {$IFNDEF PCI_DIG_IO}
  dCIO_DIO24       =   CIO_DIO24;
  dCIO_DIO24H      =   CIO_DIO24H;
  {$ENDIF}
//  dCIO_DIO48       =   CIO_DIO48;

type
  EIllegalDIOPortName = class(Exception);
  EDIOBoardNotInitialized = class(exception);
  EDIOPortsNotInitialized = class(exception);
  EDIOPortNumberTooHigh = class(exception);
  EIllegalBitNum = class(exception);

  tDirectionType = (dInput,dOutput,dNotUsed);

  tDirectionArray = array[dFIRSTPORTA..dSECONDPORTCH] of tDirectionType;

  tBoardType = (dDIO24, dDIO24H{, dDIO48});

  tBitChangeEvent = procedure( Sender : TObject; BitNumber : integer; BitState : boolean ) of Object;

  TLEDStateChangeEvent = procedure ( Sender : TObject; BitState : Boolean ) of Object;

  TDioLed = class(TShape)
  private
    FLit : boolean;
    FLitColor,
    FUnlitColor :TColor;
    FUnLitTransparent : Boolean;
    FOnChangeEvent : TLEDStateChangeEvent;
    procedure SetLit( value : boolean );
    procedure SetLitColor( value : TColor );
    procedure SetUnlitColor( value : TColor );
    procedure SetUnLitTransparent(Value : Boolean);
  protected
    procedure Paint; override;
    procedure FireOnChangeEvent;
  public
    constructor Create(AOwner: TComponent); override;
    destructor destroy; override;
  published
    property LitColor : TColor read FLitColor write SetLitColor default clRed;
    property UnlitColor : TColor read FUnlitColor Write SetUnlitColor default clBlack;
    property Lit : boolean read FLit write SetLit default false;
    property UnLitTransparent : Boolean read FUnLitTransparent write SetUnLitTransparent default False;
    property OnBitChange : TLEDStateChangeEvent read FOnChangeEvent write FOnChangeEvent;
    Property OnClick;
  end;

  TScanInputBits = class(TThread)
  private
    { Private declarations }
    FSleep : Cardinal;
    FInBits : tBits;
    FBitNumber : integer;
    FBitState  : boolean;
    FOnInputChangeFromThread : TNotifyEvent;
    FAutoSuspend             : TNotifyEvent;
    FBitChangeEvent          : tBitChangeEvent;
    FBoardNum                : integer;
  protected
    Procedure InputChangedFromThread;
    Procedure AutoSuspendNow;
    Procedure BitChanged;
    procedure Execute; override;
  end;

  TLedSet = class;

  TDio = class(TCustomControl{TComponent{})
  private
    { Private declarations }
    FHardBits,
    FOutBits       : tBits;
    FInBits        : tBits;
    FUsedPorts     : tDirectionArray;
    FBoardNum      : integer;
    FBoardInitialized : boolean;
    FPortsInitialized : boolean;
    FBoardType        : tBoardType;
    FEnabled          : boolean;
    FInterval         : cardinal;
    FMomentaryInterval : cardinal;
    FScanInputBits    : TScanInputBits;
    FOnInputChange    : TNotifyEvent;
    FOnOutputChange   : TNotifyEvent;
    FAbout            : TfrmAbout;
    FOnSingleBitChange : tBitChangeEvent;
    Bitmap            : tbitmap;
    FDioLeds          : TLedSet;
    FDemoMode         : boolean;
    FPortA,
    FPortB,
    FPortC            : byte;
    procedure SetDioLeds( const Value : TLedSet );
    function GetPortDirection( Index : integer ) : tDirectionType;
    procedure SetPortDirection( Index : integer; porttype : TDirectionType );
    procedure SetHardBit( index : integer; state : boolean);
    function GetHardBit( index : integer ): boolean;
    procedure SetOutputBits( index : integer; State : boolean);
    function GetOutPutBits( index : integer) : boolean;
    function GetInputBits( index : integer ) : boolean;
    procedure SetBoardNum( Value : integer );
    procedure SetInterval( Value : Cardinal );
    procedure SetEnabled( Value : Boolean );
    function GetOutputBitsCount : integer;
    function GetInputBitsCount : integer;
    function GetPortVal( index : integer ): byte;
    procedure SetPortVal( index : integer; Value : byte);
    procedure SetMomentaryInterval( Value : Cardinal );
    procedure InputChangeDetectedFromThread( Sender : TObject);
    procedure AutoSuspendThreadEvent( Sender : TObject);
    procedure BitChangedEvent( sender : TObject; BitNumber : integer; BitState : boolean );
    procedure Notification( AComponent : TComponent; Operation : TOperation ); override;
    procedure SetDemoMode( Value : boolean );
    function GetDemoMode: Boolean;
  protected
    { Protected declarations }
    procedure paint; override;
    procedure OutputChange;
  public
    { Public declarations }
    Constructor Create ( AOwner : TComponent); override;
    destructor  Destroy; Override;
    procedure About;
    procedure InitializeDio;
    procedure SetBits;
    procedure ClearBits;
    function ToggleBit( Bitnum : integer ):boolean;
    procedure InvertBits;
    function Momentary( Index : integer ) : boolean;
    function True_Bit_Number( PortDirection : tDirectionType;
                              BitNum : integer ):integer;
    property BoardInitialized : boolean read FBoardInitialized;
    property PortDirection[ index : integer ] : tDirectionType read GetPortDirection
        Write SetPortDirection;
    property InputBits[ index : integer ] : boolean read GetInputBits;
    property OutputBits[ index : integer ] : boolean read GetOutputBits
        Write SetOutputBits;
    property HardBits[ index : integer ] : boolean read GetHardBit
        Write SetHardBit;
    property OutputBitsCount : integer read GetOutputBitsCount;
    property InputBitsCount : integer read GetInputBitsCount;
    property PortVal[ index : integer ] : byte read GetPortVal write SetPortVal;
  published
    { Published declarations }
    property BoardNum : integer read FBoardNum Write SetBoardNum default 1;
    property BoardType : tBoardType read FBoardType write FBoardType default dDIO24;
    Property Enabled : boolean read FEnabled write SetEnabled default false;
    Property Interval : cardinal read FInterval write SetInterval default 1000;
    Property MomentaryInterval : Cardinal read FMomentaryInterval write SetMomentaryInterval
       default 100;
    Property DioLeds : TLedSet read FDioLeds write SetDioLeds;
    Property DemoMode : Boolean read GetDemoMode write SetDemoMode default false;
    Property OnInputChange : TNotifyEvent read FOnInputChange write FOnInputChange;
    Property OnSingleBitChange : tBitChangeEvent read FOnSingleBitChange
       write FOnSingleBitChange;
    Property OnOutputChange : TNotifyEvent read FOnOutputChange
       write FOnOutputChange;
    Property InitialPortA : byte read FPortA write FPortA default 255;
    Property InitialPortB : byte read FPortB write FPortB default 255;
    Property InitialPortC : byte read FPortC write FPortC default 255;
  end;

  TLedSet = class(TPersistent)
  protected
    FBit : array[1..24] of TDioLed;
    function GetBit( Index : integer ): TdioLed;
    procedure SetBit( Index : integer; const Value : TDioLed );
  public
    constructor create;
    procedure InitLights;
    procedure UpdateLeds( BoardNum: integer; const OutBits, InBits : tBits );
  published
    property Bit01 : TDIOLed index 1 read GetBit write SetBit;
    property Bit02 : TDIOLed index 2 read GetBit write SetBit;
    property Bit03 : TDIOLed index 3 read GetBit write SetBit;
    property Bit04 : TDIOLed index 4 read GetBit write SetBit;
    property Bit05 : TDIOLed index 5 read GetBit write SetBit;
    property Bit06 : TDIOLed index 6 read GetBit write SetBit;
    property Bit07 : TDIOLed index 7 read GetBit write SetBit;
    property Bit08 : TDIOLed index 8 read GetBit write SetBit;
    property Bit09 : TDIOLed index 9 read GetBit write SetBit;
    property Bit10 : TDIOLed index 10 read GetBit write SetBit;
    property Bit11 : TDIOLed index 11 read GetBit write SetBit;
    property Bit12 : TDIOLed index 12 read GetBit write SetBit;
    property Bit13 : TDIOLed index 13 read GetBit write SetBit;
    property Bit14 : TDIOLed index 14 read GetBit write SetBit;
    property Bit15 : TDIOLed index 15 read GetBit write SetBit;
    property Bit16 : TDIOLed index 16 read GetBit write SetBit;
    property Bit17 : TDIOLed index 17 read GetBit write SetBit;
    property Bit18 : TDIOLed index 18 read GetBit write SetBit;
    property Bit19 : TDIOLed index 19 read GetBit write SetBit;
    property Bit20 : TDIOLed index 20 read GetBit write SetBit;
    property Bit21 : TDIOLed index 21 read GetBit write SetBit;
    property Bit22 : TDIOLed index 22 read GetBit write SetBit;
    property Bit23 : TDIOLed index 23 read GetBit write SetBit;
    property Bit24 : TDIOLed index 24 read GetBit write SetBit;
//    property Bit25 : TDIOLed index 25 read GetBit write SetBit;
//    property Bit26 : TDIOLed index 26 read GetBit write SetBit;
//    property Bit27 : TDIOLed index 27 read GetBit write SetBit;
//    property Bit28 : TDIOLed index 28 read GetBit write SetBit;
//    property Bit29 : TDIOLed index 29 read GetBit write SetBit;
//    property Bit30 : TDIOLed index 30 read GetBit write SetBit;
//    property Bit31 : TDIOLed index 31 read GetBit write SetBit;
//    property Bit32 : TDIOLed index 32 read GetBit write SetBit;
//    property Bit33 : TDIOLed index 33 read GetBit write SetBit;
//    property Bit34 : TDIOLed index 34 read GetBit write SetBit;
//    property Bit35 : TDIOLed index 35 read GetBit write SetBit;
//    property Bit36 : TDIOLed index 36 read GetBit write SetBit;
//    property Bit37 : TDIOLed index 37 read GetBit write SetBit;
//    property Bit38 : TDIOLed index 38 read GetBit write SetBit;
//    property Bit39 : TDIOLed index 39 read GetBit write SetBit;
//    property Bit40 : TDIOLed index 40 read GetBit write SetBit;
//    property Bit41 : TDIOLed index 41 read GetBit write SetBit;
//    property Bit42 : TDIOLed index 42 read GetBit write SetBit;
//    property Bit43 : TDIOLed index 43 read GetBit write SetBit;
//    property Bit44 : TDIOLed index 44 read GetBit write SetBit;
//    property Bit45 : TDIOLed index 45 read GetBit write SetBit;
//    property Bit46 : TDIOLed index 46 read GetBit write SetBit;
//    property Bit47 : TDIOLed index 47 read GetBit write SetBit;
//    property Bit48 : TDIOLed index 48 read GetBit write SetBit;
  end;


implementation
{$R *.res}

{_ifdef NoDio}
//const Demo = true;
{_else}
const Demo = false;
{_endif}

constructor TLedSet.Create;
var loop : integer;
begin
  for loop := 1 to 24{48} do
    FBit[loop]     := nil;
end;

procedure TLedSet.UpdateLeds(BoardNum : integer; const OutBits, InBits : tBits );
var loop : integer;
    TrueBitNum : integer;
begin
  if OutBits.Size > 0 then
    for loop := 0 to OutBits.Size - 1 do
    begin
      TrueBitNum := Return_True_DIO_Bitnum(BoardNum, tIoType(ord(dOutput)), loop + 1);
      if (TrueBitNum > 0) and (TrueBitNum < 49) then
        if assigned(FBit[TrueBitNum]) then
          case TrueBitNum of
            1 : Bit01.Lit := OutBits.Bits[loop];
            2 : Bit02.Lit := OutBits.Bits[loop];
            3 : Bit03.Lit := OutBits.Bits[loop];
            4 : Bit04.Lit := OutBits.Bits[loop];
            5 : Bit05.Lit := OutBits.Bits[loop];
            6 : Bit06.Lit := OutBits.Bits[loop];
            7 : Bit07.Lit := OutBits.Bits[loop];
            8 : Bit08.Lit := OutBits.Bits[loop];
            9 : Bit09.Lit := OutBits.Bits[loop];
           10 : Bit10.Lit := OutBits.Bits[loop];
           11 : Bit11.Lit := OutBits.Bits[loop];
           12 : Bit12.Lit := OutBits.Bits[loop];
           13 : Bit13.Lit := OutBits.Bits[loop];
           14 : Bit14.Lit := OutBits.Bits[loop];
           15 : Bit15.Lit := OutBits.Bits[loop];
           16 : Bit16.Lit := OutBits.Bits[loop];
           17 : Bit17.Lit := OutBits.Bits[loop];
           18 : Bit18.Lit := OutBits.Bits[loop];
           19 : Bit19.Lit := OutBits.Bits[loop];
           20 : Bit20.Lit := OutBits.Bits[loop];
           21 : Bit21.Lit := OutBits.Bits[loop];
           22 : Bit22.Lit := OutBits.Bits[loop];
           23 : Bit23.Lit := OutBits.Bits[loop];
           24 : Bit24.Lit := OutBits.Bits[loop];
//           25 : Bit25.Lit := OutBits.Bits[loop];
//           26 : Bit26.Lit := OutBits.Bits[loop];
//           27 : Bit27.Lit := OutBits.Bits[loop];
//           28 : Bit28.Lit := OutBits.Bits[loop];
//           29 : Bit29.Lit := OutBits.Bits[loop];
//           30 : Bit30.Lit := OutBits.Bits[loop];
//           31 : Bit31.Lit := OutBits.Bits[loop];
//           32 : Bit32.Lit := OutBits.Bits[loop];
//           33 : Bit33.Lit := OutBits.Bits[loop];
//           34 : Bit34.Lit := OutBits.Bits[loop];
//           35 : Bit35.Lit := OutBits.Bits[loop];
//           36 : Bit36.Lit := OutBits.Bits[loop];
//           37 : Bit37.Lit := OutBits.Bits[loop];
//           38 : Bit38.Lit := OutBits.Bits[loop];
//           39 : Bit39.Lit := OutBits.Bits[loop];
//           40 : Bit40.Lit := OutBits.Bits[loop];
//           41 : Bit41.Lit := OutBits.Bits[loop];
//           42 : Bit42.Lit := OutBits.Bits[loop];
//           43 : Bit43.Lit := OutBits.Bits[loop];
//           44 : Bit44.Lit := OutBits.Bits[loop];
//           45 : Bit45.Lit := OutBits.Bits[loop];
//           46 : Bit46.Lit := OutBits.Bits[loop];
//           47 : Bit47.Lit := OutBits.Bits[loop];
//           48 : Bit48.Lit := OutBits.Bits[loop];
          end; //case
    end;
  if InBits.Size > 0 then
    for loop := 0 to InBits.Size - 1 do
    begin
      TrueBitNum := Return_True_DIO_Bitnum(BoardNum,tIoType(ord(dInput)), loop + 1);
      if (TrueBitNum > 0) and (TrueBitNum < 49) then
        if assigned(FBit[TrueBitNum]) then
          case TrueBitNum of
            1 : Bit01.Lit := InBits.Bits[loop];
            2 : Bit02.Lit := InBits.Bits[loop];
            3 : Bit03.Lit := InBits.Bits[loop];
            4 : Bit04.Lit := InBits.Bits[loop];
            5 : Bit05.Lit := InBits.Bits[loop];
            6 : Bit06.Lit := InBits.Bits[loop];
            7 : Bit07.Lit := InBits.Bits[loop];
            8 : Bit08.Lit := InBits.Bits[loop];
            9 : Bit09.Lit := InBits.Bits[loop];
           10 : Bit10.Lit := InBits.Bits[loop];
           11 : Bit11.Lit := InBits.Bits[loop];
           12 : Bit12.Lit := InBits.Bits[loop];
           13 : Bit13.Lit := InBits.Bits[loop];
           14 : Bit14.Lit := InBits.Bits[loop];
           15 : Bit15.Lit := InBits.Bits[loop];
           16 : Bit16.Lit := InBits.Bits[loop];
           17 : Bit17.Lit := InBits.Bits[loop];
           18 : Bit18.Lit := InBits.Bits[loop];
           19 : Bit19.Lit := InBits.Bits[loop];
           20 : Bit20.Lit := InBits.Bits[loop];
           21 : Bit21.Lit := InBits.Bits[loop];
           22 : Bit22.Lit := InBits.Bits[loop];
           23 : Bit23.Lit := InBits.Bits[loop];
           24 : Bit24.Lit := InBits.Bits[loop];
//           25 : Bit25.Lit := InBits.Bits[loop];
//           26 : Bit26.Lit := InBits.Bits[loop];
//           27 : Bit27.Lit := InBits.Bits[loop];
//           28 : Bit28.Lit := InBits.Bits[loop];
//           29 : Bit29.Lit := InBits.Bits[loop];
//           30 : Bit30.Lit := InBits.Bits[loop];
//           31 : Bit31.Lit := InBits.Bits[loop];
//           32 : Bit32.Lit := InBits.Bits[loop];
//           33 : Bit33.Lit := InBits.Bits[loop];
//           34 : Bit34.Lit := InBits.Bits[loop];
//           35 : Bit35.Lit := InBits.Bits[loop];
//           36 : Bit36.Lit := InBits.Bits[loop];
//           37 : Bit37.Lit := InBits.Bits[loop];
//           38 : Bit38.Lit := InBits.Bits[loop];
//           39 : Bit39.Lit := InBits.Bits[loop];
//           40 : Bit40.Lit := InBits.Bits[loop];
//           41 : Bit41.Lit := InBits.Bits[loop];
//           42 : Bit42.Lit := InBits.Bits[loop];
//           43 : Bit43.Lit := InBits.Bits[loop];
//           44 : Bit44.Lit := InBits.Bits[loop];
//           45 : Bit45.Lit := InBits.Bits[loop];
//           46 : Bit46.Lit := InBits.Bits[loop];
//           47 : Bit47.Lit := InBits.Bits[loop];
//           48 : Bit48.Lit := InBits.Bits[loop];
          end; //case
    end;
end;

procedure TLedSet.InitLights;
begin
  if assigned(FBit[1]) then
    Bit01.Lit := false;
  if assigned(FBit[2]) then
    Bit02.Lit := false;
  if assigned(FBit[3]) then
    Bit03.Lit := false;
  if assigned(FBit[4]) then
    Bit04.Lit := false;
  if assigned(FBit[5]) then
    Bit05.Lit := false;
  if assigned(FBit[6]) then
    Bit06.Lit := false;
  if assigned(FBit[7]) then
    Bit07.Lit := false;
  if assigned(FBit[8]) then
    Bit08.Lit := false;
  if assigned(FBit[9]) then
    Bit09.Lit := false;
  if assigned(FBit[10]) then
    Bit10.Lit := false;
  if assigned(FBit[11]) then
    Bit11.Lit := false;
  if assigned(FBit[12]) then
    Bit12.Lit := false;
  if assigned(FBit[13]) then
    Bit13.Lit := false;
  if assigned(FBit[14]) then
    Bit14.Lit := false;
  if assigned(FBit[15]) then
    Bit15.Lit := false;
  if assigned(FBit[16]) then
    Bit16.Lit := false;
  if assigned(FBit[17]) then
    Bit17.Lit := false;
  if assigned(FBit[18]) then
    Bit18.Lit := false;
  if assigned(FBit[19]) then
    Bit19.Lit := false;
  if assigned(FBit[20]) then
    Bit20.Lit := false;
  if assigned(FBit[21]) then
    Bit21.Lit := false;
  if assigned(FBit[22]) then
    Bit22.Lit := false;
  if assigned(FBit[23]) then
    Bit23.Lit := false;
  if assigned(FBit[24]) then
    Bit24.Lit := false;
//  if assigned(FBit[25]) then
//    Bit25.Lit := false;
//  if assigned(FBit[26]) then
//    Bit26.Lit := false;
//  if assigned(FBit[27]) then
//    Bit27.Lit := false;
//  if assigned(FBit[28]) then
//    Bit28.Lit := false;
//  if assigned(FBit[29]) then
//    Bit29.Lit := false;
//  if assigned(FBit[30]) then
//    Bit30.Lit := false;
//  if assigned(FBit[31]) then
//    Bit31.Lit := false;
//  if assigned(FBit[32]) then
//    Bit32.Lit := false;
//  if assigned(FBit[33]) then
//    Bit33.Lit := false;
//  if assigned(FBit[34]) then
//    Bit34.Lit := false;
//  if assigned(FBit[35]) then
//    Bit35.Lit := false;
//  if assigned(FBit[36]) then
//    Bit36.Lit := false;
//  if assigned(FBit[37]) then
//    Bit37.Lit := false;
//  if assigned(FBit[38]) then
//    Bit38.Lit := false;
//  if assigned(FBit[39]) then
//    Bit39.Lit := false;
//  if assigned(FBit[40]) then
//    Bit40.Lit := false;
//  if assigned(FBit[41]) then
//    Bit41.Lit := false;
//  if assigned(FBit[42]) then
//    Bit42.Lit := false;
//  if assigned(FBit[43]) then
//    Bit43.Lit := false;
//  if assigned(FBit[44]) then
//    Bit44.Lit := false;
//  if assigned(FBit[45]) then
//    Bit45.Lit := false;
//  if assigned(FBit[46]) then
//    Bit46.Lit := false;
//  if assigned(FBit[47]) then
//    Bit47.Lit := false;
//  if assigned(FBit[48]) then
//    Bit48.Lit := false;
end;

function TLedSet.GetBit( Index : integer ): TdioLed;
begin
  if assigned(FBit[index]) then
    result := FBit[Index]
  else
    result := nil;
end;

procedure TLedSet.SetBit( Index : integer; const Value : TDioLed );
begin
  if assigned(value) then
    FBit[Index] := Value
  else
    FBit[Index] := nil;
end;

constructor TDioLed.Create;
begin
  inherited Create(AOwner);
  FLit := false;
  FLitColor := clRed;
  FUnlitColor := clBlack;
  FUnLitTransparent := False;
  width := 13;
  height := 13;
  Brush.Color := FUnlitColor;
end;

destructor TDioLed.destroy;
begin
  inherited destroy;
end;

procedure TDioLed.SetLit( value : boolean );
begin
  if FLit <> value then
  begin
    Flit := value;
    if Flit then
      Brush.Color := FLitColor
    else
      Brush.Color := FUnlitColor;
    FireOnChangeEvent;
    invalidate;
  end;
end;

procedure TDioLed.FireOnChangeEvent;
begin
  if assigned(FOnChangeEvent) then
    FOnChangeEvent( Self, FLit );
end;

procedure TDioLED.SetUnLitTransparent(Value : Boolean);
begin
  FUnLitTransparent := Value;
end; // TDioLED.SetUnLitTransparent

procedure TDioLed.SetLitColor( value : TColor );
begin
  if FLitColor <> value then
  begin
    FLitColor := Value;
    if FLit then
    begin
      Brush.Color := FLitColor;
      invalidate;
    end;
  end;
end;

procedure TDioLed.SetUnlitColor( value : TColor );
begin
  if FUnlitColor <> value then
  begin
    FUnlitColor := Value;
    if not FLit then
    begin
      Brush.Color := FUnlitColor;
      invalidate;
    end;
  end;
end;

procedure TDioLed.Paint;
begin
  if FUnLitTransparent then
  begin
    if (Parent is TWinControl) then
    begin
      FUnlitColor := Parent.Brush.Color;
      Self.Pen.Color := FUnlitColor;
    end; // If
  end; // If
  if FLit then
    Brush.color := FLitColor
  else
    Brush.color := FUnlitColor;
  inherited paint;
end;

constructor TDio.Create( AOwner : TComponent);
begin
  inherited Create(AOwner);
  FAbout := TfrmAbout.create(self);
  FHardBits := tBits.Create;
  FOutBits := tBits.Create;
  FInBits  := tBits.Create;
  FDioLeds := TLedSet.create;
  FBoardInitialized := false;
  FBoardNum := 1;
  FBoardType := dDIO24;
  Finterval := 1000;
  FMomentaryInterval := 100;
  FEnabled := false;
  FDemoMode := demo;
  FPortA := 255;
  FPortB := 255;
  FPortC := 255;
  fillchar(FUsedPorts, Sizeof(FUsedPorts), tDirectionType(2));
  FScanInputBits := TScanInputBits.Create(true);
  FScanInputBits.FSleep := FInterval;
  FScanInputBits.FInBits := tBits.Create;
  FScanInputBits.FreeOnTerminate := true;
  FScanInputBits.Priority := tpLowest;
  FScanInputBits.FOnInputChangeFromThread := InputChangeDetectedFromThread;
  FScanInputBits.FAutoSuspend := AutoSuspendThreadEvent;
  FScanInputBits.FBitChangeEvent := BitChangedEvent;
  FScanInputBits.FBoardNum := FBoardNum;
  Bitmap := tbitmap.create;
  Bitmap.LoadFromResourceName(HInstance, 'DIOBITMAP');
  width := Bitmap.Width;
  height := Bitmap.Height;
  if not (csDesigning in ComponentState) then
    visible := false;{}
end;

destructor TDio.Destroy;
begin
  FScanInputBits.Terminate;
  FinBits.Free;
  FHardBits.Free;
  FOutBits.Free;
  Bitmap.free;
  FDioLeds.free;
  {$ifndef PCI_DIG_IO}
  RemoveBoard(FBoardNum);
  {$endif}
  inherited Destroy;
end;

procedure TDio.Notification( AComponent : TComponent; Operation : TOperation );
begin
  inherited Notification( AComponent, Operation );
  if operation = opRemove then
  begin
    if AComponent = DioLeds.Bit01 then
      DioLeds.Bit01 := nil
    else
    if AComponent = DioLeds.Bit02 then
      DioLeds.Bit02 := nil
    else
    if AComponent = DioLeds.Bit03 then
      DioLeds.Bit03 := nil
    else
    if AComponent = DioLeds.Bit04 then
      DioLeds.Bit04 := nil
    else
    if AComponent = DioLeds.Bit05 then
      DioLeds.Bit05 := nil
    else
    if AComponent = DioLeds.Bit06 then
      DioLeds.Bit06 := nil
    else
    if AComponent = DioLeds.Bit07 then
      DioLeds.Bit07 := nil
    else
    if AComponent = DioLeds.Bit08 then
      DioLeds.Bit08 := nil
    else
    if AComponent = DioLeds.Bit09 then
      DioLeds.Bit09 := nil
    else
    if AComponent = DioLeds.Bit10 then
      DioLeds.Bit10 := nil
    else
    if AComponent = DioLeds.Bit11 then
      DioLeds.Bit11 := nil
    else
    if AComponent = DioLeds.Bit12 then
      DioLeds.Bit12 := nil
    else
    if AComponent = DioLeds.Bit13 then
      DioLeds.Bit13 := nil
    else
    if AComponent = DioLeds.Bit14 then
      DioLeds.Bit14 := nil
    else
    if AComponent = DioLeds.Bit15 then
      DioLeds.Bit15 := nil
    else
    if AComponent = DioLeds.Bit16 then
      DioLeds.Bit16 := nil
    else
    if AComponent = DioLeds.Bit17 then
      DioLeds.Bit17 := nil
    else
    if AComponent = DioLeds.Bit18 then
      DioLeds.Bit18 := nil
    else
    if AComponent = DioLeds.Bit19 then
      DioLeds.Bit19 := nil
    else
    if AComponent = DioLeds.Bit20 then
      DioLeds.Bit20 := nil
    else
    if AComponent = DioLeds.Bit21 then
      DioLeds.Bit21 := nil
    else
    if AComponent = DioLeds.Bit22 then
      DioLeds.Bit22 := nil
    else
    if AComponent = DioLeds.Bit23 then
      DioLeds.Bit23 := nil
    else
    if AComponent = DioLeds.Bit24 then
      DioLeds.Bit24 := nil;
//    else
//    if AComponent = DioLeds.Bit25 then
//      DioLeds.Bit25 := nil
//    else
//    if AComponent = DioLeds.Bit26 then
//      DioLeds.Bit26 := nil
//    else
//    if AComponent = DioLeds.Bit27 then
//      DioLeds.Bit27 := nil
//    else
//    if AComponent = DioLeds.Bit28 then
//      DioLeds.Bit28 := nil
//    else
//    if AComponent = DioLeds.Bit29 then
//      DioLeds.Bit29 := nil
//    else
//    if AComponent = DioLeds.Bit30 then
//      DioLeds.Bit30 := nil
//    else
//    if AComponent = DioLeds.Bit31 then
//      DioLeds.Bit31 := nil
//    else
//    if AComponent = DioLeds.Bit32 then
//      DioLeds.Bit32 := nil
//    else
//    if AComponent = DioLeds.Bit33 then
//      DioLeds.Bit33 := nil
//    else
//    if AComponent = DioLeds.Bit34 then
//      DioLeds.Bit34 := nil
//    else
//    if AComponent = DioLeds.Bit35 then
//      DioLeds.Bit35 := nil
//    else
//    if AComponent = DioLeds.Bit36 then
//      DioLeds.Bit36 := nil
//    else
//    if AComponent = DioLeds.Bit37 then
//      DioLeds.Bit37 := nil
//    else
//    if AComponent = DioLeds.Bit38 then
//      DioLeds.Bit38 := nil
//    else
//    if AComponent = DioLeds.Bit39 then
//      DioLeds.Bit39 := nil
//    else
//    if AComponent = DioLeds.Bit40 then
//      DioLeds.Bit40 := nil
//    else
//    if AComponent = DioLeds.Bit41 then
//      DioLeds.Bit41 := nil
//    else
//    if AComponent = DioLeds.Bit42 then
//      DioLeds.Bit42 := nil
//    else
//    if AComponent = DioLeds.Bit43 then
//      DioLeds.Bit43 := nil
//    else
//    if AComponent = DioLeds.Bit44 then
//      DioLeds.Bit44 := nil
//    else
//    if AComponent = DioLeds.Bit45 then
//      DioLeds.Bit45 := nil
//    else
//    if AComponent = DioLeds.Bit46 then
//      DioLeds.Bit46 := nil
//    else
//    if AComponent = DioLeds.Bit47 then
//      DioLeds.Bit47 := nil
//    else
//    if AComponent = DioLeds.Bit48 then
//      DioLeds.Bit48 := nil;
  end;
end;

procedure tDIO.About;
begin
  FAbout.showmodal;
end;

procedure TDio.InitializeDio;
var errcode : integer;
    LBoardType : integer;
begin
  if FDemoMode then
  begin
    FBoardInitialized := true;
    exit;
  end;
  {$ifdef PCI_DIG_IO}
  FBoardInitialized := true;
  {$else}
  if FBoardInitialized then
  begin
    messagedlg('DIO Interface already initialized', mtinformation, [mbok], 0);
    exit;
  end;
  errcode := 0;
  try
    LBoardType := dCIO_DIO24H;
    {$IFNDEF PCI_DIG_IO}
    case FBoardType of
      dDIO24  : LBoardType := dCIO_DIO24;
      dDIO24H : LBoardType := dCIO_DIO24H;
//      dDIO48  : LBoardType := dCIO_DIO48;
    end; //case
    {$ELSE}
    FBoardType := dDIO24;
    {$ENDIF}
//    ErrCode := addboard(FBoardNum, LBoardType);
    ErrCode := addboardWithDefinePorts(FBoardNum, LBoardType, FPortA, FPortB, FPortC);
    if ErrCode <> -1 then
      FBoardInitialized := true
    else
      raise EDIOBoardNotInitialized.create('Unable to Initialize DIO');
  except
    on EDIOBoardNotInitialized do
    begin
      messageDlg('AddBoard returned ' + inttostr(ErrCode) + '.',
                 mtinformation, [mbok],0);
      raise;
    end;
  end;
  {$endif}
end;

procedure TDio.SetDioLeds( const Value : TLedSet );
begin
  FDioLeds := Value;
end;

procedure tDio.SetPortDirection( Index : integer; porttype : TDirectionType );
var InitResult : integer;
    loop       : integer;
    OutSize,
    InSize     : integer;
    MsgStr     : string;
begin
  try
    if FDemoMode then
      exit;
    if not FBoardInitialized then
      InitializeDIO;
    if FUsedPorts[index] <> PortType then
      if (Index <= dSECONDPORTCH) and (Index >= dFIRSTPORTA) then
      begin
        FUsedPorts[index] := porttype;
        if (FBoardType = dDIO24) or (FBoardType = dDIO24H) then
        begin
          if Index > dFIRSTPORTCH then
            raise EDIOPortNumberTooHigh.create('DIO port is to high for the board defined');
          InitResult := Init_DIO_DIP24_With_Port_Defaults(FPortA, FPortB, FPortC,
                                                          ord(FUsedPorts[dFIRSTPORTA]),
                                                          ord(FUsedPorts[dFIRSTPORTB]),
                                                          ord(FUsedPorts[dFIRSTPORTCH]),
                                                          ord(FUsedPorts[dFIRSTPORTCL]), FBoardNum);
        end;
{        else
          InitResult := Init_DIO_DIP48(ord(FUsedPorts[dFIRSTPORTA]),
                                       ord(FUsedPorts[dFIRSTPORTB]),
                                       ord(FUsedPorts[dFIRSTPORTCH]),
                                       ord(FUsedPorts[dFIRSTPORTCL]),
                                       ord(FUsedPorts[dSECONDPORTA]),
                                       ord(FUsedPorts[dSECONDPORTB]),
                                       ord(FUsedPorts[dSECONDPORTCH]),
                                       ord(FUsedPorts[dSECONDPORTCL]), FBoardNum);{}
        if InitResult <> 0 then
          raise EDIOPortsNotInitialized.Create('Init_DIO_DIP returned ' + inttostr(InitResult));
        FPortsInitialized := BoardInitialized;
        OutSize := 0;
        InSize  := 0;
        for loop := dFIRSTPORTA to dFIRSTPORTB do
          case FUsedPorts[loop] of
            dInput :  InSize := Insize + 8;
            dOutput:  OutSize := OutSize + 8;
          end; //case
        for loop := dFIRSTPORTCL to dFIRSTPORTCH do
          case FUsedPorts[loop] of
            dInput :  InSize := Insize + 4;
            dOutput:  OutSize := OutSize + 4;
          end; //case
        for loop := dSECONDPORTA to dSECONDPORTB do
          case FUsedPorts[loop] of
            dinput :  InSize := Insize + 8;
            dOutput:  OutSize := OutSize + 8;
          end; //case
        for loop := dSECONDPORTCL to dSECONDPORTCH do
          case FUsedPorts[loop] of
            dinput :  InSize := Insize + 4;
            dOutput:  OutSize := OutSize + 4;
          end; //case
        FOutBits.Size := OutSize;
        FInBits.Size := InSize;
        FHardBits.Size := 24; //48;
        FScanInputBits.FInBits.size := FinBits.Size;
        if FEnabled and (FInBits.Size > 0) then
          FScanInputBits.Resume;
      end
      else
        raise EIllegalDIOPortName.CreateFmt('Port #%d is not legal.' +
                                            '  Must be between %d and %d',
                                            [index, dFIRSTPORTA, dSECONDPORTCH]);
  except
    on EIllegalDIOPortName do
      messagedlg('Call to SetPortDirection Ignored.', mtInformation, [mbok], 0);

    on EDioPortsNotInitialized do
    begin
      FPortsInitialized := false;
      dio.BoardInitialized[FBoardnum] := false;
      MessageDlg('DIO Ports NOT initialized', mtinformation, [mbok],0);
    end;

    on EDIOPortNumberTooHigh do
    begin
      MsgStr := format('Port #%d is to high for this DIO24(h) board.  ' +
                       'Must be lower than %d', [index,dSECONDPORTA]);
      messagedlg(MsgStr, mterror, [mbok],0);
    end;
  end;
end;

function tDio.GetPortDirection( index : integer ) : tDirectionType;
begin
  try
    if (index >= dFIRSTPORTA) and (index <= dSECONDPORTCH) then
      Result := FUsedPorts[index]
    else
      raise EIllegalDIOPortName.CreateFmt('Port #%d is not legal.' +
                                          '  Must be between %d and %d',
                                          [index, dFIRSTPORTA, dSECONDPORTCH]);
  except
    on EIllegalDIOPortName do
    begin
      result := tDirectionType(2);
      messagedlg('Call to GetPortDirection Ignored.', mtInformation, [mbok], 0);
    end;
  end;
end;

procedure tdio.SetBits;
var loop : integer;
begin
  for loop := 0 to FOutBits.Size - 1 do
  begin
    FOutBits.Bits[loop] := true;
    Bit_On(FBoardNum,loop + 1);
    OutputChange;
  end;{}
end;

procedure tdio.ClearBits;
var loop : integer;
begin
  for loop := 0 to FOutBits.Size - 1 do
  begin
    FOutBits.Bits[loop] := false;
    Bit_Off(FBoardNum,loop + 1);
    OutputChange;
  end;{}
end;

procedure tDio.InvertBits;
var loop : integer;
begin
  for loop := 1 to FOutBits.Size do
    if not ToggleBit( loop ) then
      break;
end;

function tdio.ToggleBit( Bitnum : integer ):boolean;
begin
  result := false;
  try
    if not FPortsInitialized then
      raise EDIOPortsNotInitialized.create('DIO Ports Not Initialized');

    if (bitnum > FOutBits.Size) or (bitnum < 1) then
      raise EIllegalBitNum.create('Unknown Output Bit');

    if FOutBits.bits[bitnum - 1] then
    begin
      FOutBits.bits[bitnum - 1] := False;
      bit_off(FBoardNum,bitnum);
    end
    else
    begin
      FOutBits.bits[bitnum - 1] := True;
      bit_on(FBoardNum,bitnum);
    end;
    result := true;
    OutputChange;
  except
    on EIllegalBitNum do
      messagedlg('Output Bits must fall between 1 and ' + inttostr(FOutBits.Size),
                 mtinformation, [mbok], 0);
    on EDIOPortsNotInitialized do
      Messagedlg('DIO Ports must be initialized before IO Bits can be accessed.', mtinformation, [mbok], 0);
  end;
end;

function tdio.GetHardBit( index : integer ): boolean;
begin
  if FEnabled then
  begin
    if (index > 49) or (index < 1) then
      raise EIllegalBitNum.create('Unknown Input Bit');
    result := FHardBits.Bits[Index - 1];
    exit;
  end;
end;

procedure tdio.SetHardBit( index : integer; state : boolean);
begin
  try
    if not FPortsInitialized then
      raise EDIOPortsNotInitialized.create('DIO Ports Not Initialized');

    if (index > 24{48}) or (index < 1) then
      raise EIllegalBitNum.create('Unknown Bit');

    if FHardBits.bits[index - 1] <> State then
    begin
      FHardBits.bits[index - 1] := State;
      if FHardBits.bits[index - 1] then
        Hard_bit_on(FBoardNum,index)
      else
        Hard_bit_off(FBoardNum,index);
      OutputChange;
    end;
  except
    on EIllegalBitNum do                             {48}
      messagedlg('Output Bits must fall between 1 and 24', mtinformation, [mbok], 0);
    on EDIOPortsNotInitialized do
      Messagedlg('DIO Ports must be initialized before IO Bits can be accessed.', mtinformation, [mbok], 0);
  end;
end;

procedure tdio.SetOutputBits( index : integer; State : boolean);
begin
  if FDemoMode then exit;
  
  try
    if not FPortsInitialized then
      raise EDIOPortsNotInitialized.create('DIO Ports Not Initialized');

    if (index > FOutBits.Size) or (index < 1) then
      raise EIllegalBitNum.create('Unknown Output Bit');

    if FOutBits.bits[index - 1] <> State then
    begin
      FOutBits.bits[index - 1] := State;
      if FOutBits.bits[index - 1] then
        bit_on(FBoardNum,index)
      else
        bit_off(FBoardNum,index);
      OutputChange;
    end;
  except
    on EIllegalBitNum do
      messagedlg('Output Bits must fall between 1 and ' + inttostr(FOutBits.Size),
                 mtinformation, [mbok], 0);
    on EDIOPortsNotInitialized do
      Messagedlg('DIO Ports must be initialized before IO Bits can be accessed.', mtinformation, [mbok], 0);
  end;
end;

function tdio.GetOutPutBits( index : integer) : boolean;
begin
  try
    if not FPortsInitialized then
      raise EDIOPortsNotInitialized.create('DIO Ports Not Initialized');
    if (index > FOutBits.Size) or (index < 1) then
      raise EIllegalBitNum.create('Unknown Output Bit');
    result := FOutBits.bits[index-1];
  except
    on EIllegalBitNum do
    begin
      messagedlg('Output Bits must fall between 1 and ' + inttostr(FOutBits.Size),
                 mtinformation, [mbok], 0);
      result := false;
    end;
    on EDIOPortsNotInitialized do
    begin
      Messagedlg('DIO Ports must be initialized before IO Bits can be accessed.', mtinformation, [mbok], 0);
      result := false;
    end;
  end;
end;

function tdio.GetInputBits( index : integer ) : boolean;
var tempbit : boolean;
begin
  try
    if FInBits.size <= 0 then
    begin
      result := false;
      exit
    end;

    if FEnabled then
    begin
      if (index > FInBits.Size) or (index < 1) then
        raise EIllegalBitNum.create('Unknown Input Bit');
      FInBits := FScanInputBits.FInBits;
      result := FInBits.Bits[Index - 1];
      exit;
    end;

    if not FPortsInitialized then
      raise EDIOPortsNotInitialized.create('DIO Ports Not Initialized');
    if (index > FInBits.Size) or (index < 1) then
      raise EIllegalBitNum.create('Unknown Input Bit');
    tempbit := Read_bit(FBoardNum,index) = 0;
    if FInbits.bits[index-1] <> tempbit then
      FInBits.bits[index-1] := tempbit;
    result := FInBits.bits[index-1];
  except
    on EIllegalBitNum do
    begin
      messagedlg('Input Bits must fall between 1 and ' + inttostr(FInBits.Size) + #13+#10+
                 inttostr(index) + ' is out of range.', mtinformation, [mbok], 0);
      result := false;
    end;
    on EDIOPortsNotInitialized do
    begin
      Messagedlg('DIO Ports must be initialized before IO Bits can be accessed.', mtinformation, [mbok], 0);
      result := false;
    end;
  end;
end;

function tdio.Momentary( Index : integer ) : boolean;
begin
  if FDemoMode then exit;
  
  try
    if not FPortsInitialized then
      raise EDIOPortsNotInitialized.create('DIO Ports Not Initialized');
    if (index > FOutBits.Size) or (index < 1) then
      raise EIllegalBitNum.create('Unknown Output Bit');
    if FOutBits.Bits[index - 1] then
    begin
      OutputBits[index] := false; //Bit_Off(index);
      application.processmessages;
      sleep(FMomentaryInterval);
      OutputBits[index] := true; //Bit_On(index);
    end
    else
    begin
      OutputBits[index] := true; //Bit_On(index);
      application.processmessages;
      sleep(FMomentaryInterval);
      OutputBits[index] := false; //Bit_Off(index);
    end;
//    OutputChange;
    result := true;
  except
    on EIllegalBitNum do
    begin
      messagedlg('Output Bits must fall between 1 and ' + inttostr(FOutBits.Size),
                 mtinformation, [mbok], 0);
      result := false;
    end;
    on EDIOPortsNotInitialized do
    begin
      Messagedlg('DIO Ports must be initialized before IO Bits can be accessed.', mtinformation, [mbok], 0);
      result := false;
    end;
  end;
end;

procedure tDIO.SetBoardNum( Value : integer );
begin
  if csDesigning in ComponentState then
  begin
    if value <> FBoardNum then
      FBoardNum := value;
  end
  else
  if value <> FBoardNum then
  begin
    {$ifndef PCI_DIG_IO}
    RemoveBoard(FBoardNum);
    {$endif}
    FBoardInitialized := false;
    FBoardNum := Value;
    FScanInputBits.FBoardNum := FBoardNum;
    InitializeDio;
  end;
end;

function tDIO.True_Bit_Number( PortDirection : tDirectionType;
                               BitNum : integer ):integer;
begin
  result := Return_True_DIO_Bitnum(FBoardNum,tIoType(ord(PortDirection)), Bitnum);
end;

procedure tDio.SetDemoMode( Value : boolean );
begin
  FDemoMode := Value;
end;

function tDio.GetDemoMode: Boolean;
begin
  result := FDemoMode;
end;

procedure tDio.SetMomentaryInterval( Value : Cardinal );
begin
  if Value <> FMomentaryInterval then
    if Value < 50 then
      FMomentaryInterval := 50
    else
      FMomentaryInterval := Value;
end;

procedure tDio.SetInterval( Value : Cardinal );
begin
  if Value <> FInterval then
  begin
    if csDesigning in ComponentState then
    begin
      if Value < 1 then
        FInterval := 1
      else
        FInterval := Value;
    end
    else
    begin
      if Value < 1 then
        FInterval := 1
      else
        FInterval := Value;
      FScanInputBits.FSleep := FInterval;
    end;
  end;
end;

procedure tDio.SetEnabled( Value : Boolean );
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    if not (csDesigning in ComponentState) then
    begin
      if FEnabled then
        FScanInputBits.Resume
      else
        FScanInputBits.Suspend;
    end;
  end;
end;

function tDio.GetOutputBitsCount : integer;
begin
  result := FOutBits.Size;
end;

function tDio.GetInputBitsCount : integer;
begin
  result := FInBits.Size;
end;

procedure tDio.AutoSuspendThreadEvent( Sender : TObject);
begin
  FScanInputBits.Suspend;
end;

procedure tDio.InputChangeDetectedFromThread( Sender : TObject);
begin
  if assigned(FDioLeds) then
  begin
    FInBits := FScanInputBits.FInBits;
    FDioLeds.UpdateLeds( FBoardNum, FOutBits, FInBits );
  end;
  if Assigned( FOnInputChange ) then
  begin
    FOnInputChange( Self );
  end;
end;

procedure tDio.BitChangedEvent( sender : TObject; BitNumber : integer; BitState : boolean );
begin
  if assigned(FDioLeds) then
  begin
    FInBits := FScanInputBits.FInBits;
    FDioLeds.UpdateLeds(FBoardNum, FOutBits, FInBits );
  end;
  if Assigned( FOnSingleBitChange ) then
  begin
    FOnSingleBitChange( Self, BitNumber, BitState );
  end;
end;

procedure tdio.OutputChange;
begin
  if assigned(FDioLeds) then
  begin
    if FEnabled then
      FInBits := FScanInputBits.FInBits;
    FDioLeds.UpdateLeds(FBoardNum, FOutBits, FInBits );
  end;
  if Assigned( FOnOutputChange ) then
  begin
    FOnOutputChange( Self );
  end;
end;

Procedure TScanInputBits.InputChangedFromThread;
begin
  if Assigned( FOnInputChangeFromThread ) then
  begin
    FOnInputChangeFromThread( Self );
  end;
end;

Procedure TScanInputBits.AutoSuspendNow;
begin
  if Assigned( FAutoSuspend ) then
  begin
    FAutoSuspend( Self );
  end;
end;

Procedure TScanInputBits.BitChanged;
begin
  if Assigned( FBitChangeEvent ) then
  begin
    FBitChangeEvent( Self, FBitNumber, FBitState);
  end;
end;

procedure TScanInputBits.Execute;
var loop : integer;
    tempbit : boolean;
begin
  While not Terminated do
  begin
    if FInBits.Size > 0 then
    begin
      for loop := 0 to FInBits.Size - 1 do
        if Terminated then
        begin
          FInBits.Free;
          exit;
        end
        else
        begin
          tempbit := read_bit(FBoardNum,loop + 1) = 0;
          if tempbit <> FInBits.Bits[loop] then
          begin
            FInBits.Bits[loop] := tempbit;
            InputChangedFromThread;
            FBitNumber := loop + 1;
            FBitState := tempbit;
            BitChanged;
          end;
        end;
      sleep(FSleep);
    end
    else
      AutoSuspendNow;
  end;
  FInBits.Free;
  exit;
end;

procedure tdio.paint;
begin
  if csDesigning in ComponentState then
  begin
//    BringToFront;
    width := Bitmap.Width;
    height := Bitmap.Height;
    Canvas.Draw(0,0,BitMap);
  end
  else
   visible := false;
end;{}

function tdio.GetPortVal( index : integer ): byte;
var msgstr : string;
    WordVal : word;
begin
  try
    if (index < dFIRSTPORTA) and (index > dSECONDPORTCH) then
      raise EIllegalDIOPortName.CreateFmt('Port #%d is not legal.' +
                                          '  Must be between %d and %d',
                                          [index, dFIRSTPORTA, dSECONDPORTCH])
    else
    begin
      if FUsedPorts[index] = dInput then
      begin
        cbDin(FBoardNum, index, WordVal);
        result := WordVal div 256;
      end
      else
      begin
        result := 0;
        msgstr := format('Port #%d is not configured as in Input Port',[index]);
        messagedlg(msgstr, mterror, [mbok],0);
      end;
    end;
  except
    on EIllegalDIOPortName do
    begin
      result := 0;
      msgstr := format('Port #%d is not legal.  Must be between %d and %d',
                       [index, dFIRSTPORTA, dSECONDPORTCH]);
      messagedlg(msgstr, mtInformation, [mbok], 0);
    end;
  end;
end;

procedure tdio.SetPortVal( index : integer; Value : Byte);
var msgstr : string;
//    tmpbyte : integer;
begin
  try
    if (index < dFIRSTPORTA) and (index > dSECONDPORTCH) then
      raise EIllegalDIOPortName.CreateFmt('Port #%d is not legal.' +
                                          '  Must be between %d and %d',
                                          [index, dFIRSTPORTA, dSECONDPORTCH])
    else
    begin
//      tmpbyte := 0;
      if FUsedPorts[index] = dOutput then
        cbDOut(FBoardNum, index, value)
      else
      begin
        msgstr := format('Port #%d is not configured as in Output Port',[index]);
        messagedlg(msgstr, mterror, [mbok],0);
      end;
    end;
  except
    on EIllegalDIOPortName do
    begin
      msgstr := format('Port #%d is not legal.  Must be between %d and %d',
                       [index, dFIRSTPORTA, dSECONDPORTCH]);
      messagedlg(msgstr, mtInformation, [mbok], 0);
    end;
  end;
end;


end.
