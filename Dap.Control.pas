unit Dap.Control;

interface
uses DAPLib_TLB, Dap.Interfaces, Spring.Container, Spring.Container.Common, Spring.Services;
const
      CMaxADCount = 32767;
      CMinADCount = -32768;

type

  TDapControl = class(TInterfacedObject, IDapControl)
  private
    [Inject]
    FDapInterface : IDapInterface;
    [Inject(CMaxADCount)]
    FMaxADCount : integer;
    [Inject(CMinADCount)]
    FMinADCount : integer;
    function GetDapName: string;
    procedure SetDapName(aValue: string);
    procedure SetOnNewBinaryData(aValue: TDAPNewBinaryData);
    function GetOnNewBinaryData: TDapNewBinaryData;
    procedure SetOnNewTextData(aValue: TDAPNewTextData);
    function GetOnNewTextData: TDapNewTextData;
  public
    constructor Create(aDap : IDapInterface; aMaxADCount : integer; aMinADCount : integer);
    function MaxAdCount : integer;
    function MinAdCount : integer;
    function GetDAPData(aLength: integer; var aBuffer : smallint): integer;
    function Stop_DAP: boolean;
    function Reset_DAP: boolean;
    function Flush_DAP: boolean;
    function DapPresent: boolean;
    function Get_Dap_Var(DapVar : string): string;
    procedure Set_Dap_Var(DapVar : string; Value : integer);
    procedure Send_DAPL_Command(aCommand : string);
    procedure ReleaseDAP;
    function CheckInRange(aADValue: integer): integer;
    function ConvertDtoA(aDigitalVal : integer; aAtoDRange : double): double;
    function ConvertAToD(aFloatVal : double; aAtoDRange : double): integer;
    procedure ConvertAToDandSend(aFloatVal : double; aAtoDRange : double; aDapVarName : string);
    procedure SendStringToDAP(aString : string);
    procedure SendCCFileToDAP(aFilename : string);
    procedure SendDaplFileToDap(aFilename: string);
    property DapName: string read GetDapName write SetDapName;
    property OnNewBinaryData : TDAPNewBinaryData read GetOnNewBinaryData write SetOnNewBinaryData;
    property OnNewTextData : TDAPNewTextData read GetOnNewTextData write SetOnNewTextData;
  end;

procedure RegisterDapControl(aUseHardware : boolean=true);
function GetADAP: IDapControl;

implementation
uses Dialogs, SysUtils;

type

  TDapInterface = class(TInterfacedObject, IDapInterface)
  private
    FDap: TDap;
    function GetBinaryHandle: Smallint;
    procedure SetBinaryHandle(aValue: Smallint);
    function GetAccel32Version: Smallint;
    procedure SetAccel32Version(aValue: Smallint);
    function GetFlushTextInput: WordBool;
    procedure SetFlushTextInput(aValue: WordBool);
    function GetCtlVersion: Smallint;
    procedure SetCtlVersion(aValue: Smallint);
    function GetFlushBinaryInput: WordBool;
    procedure SetFlushBinaryInput(aValue: WordBool);
    function GetCharData: Smallint;
    procedure SetCharData(aValue: Smallint);
    function GetAutomaticDataRead: WordBool;
    procedure SetAutomaticDataRead(aValue: WordBool);
    function GetFlushInputs: WordBool;
    procedure SetFlushInputs(aValue: WordBool);
    function getGetAvail: Smallint;
    procedure SetGetAvail(aValue: Smallint);
    function GetIntData: Smallint;
    procedure SetIntData(aValue: Smallint);
    function GetIoCtlString: WideString;
    procedure SetIoCtlString(aValue: WideString);
    function GetLoadError: Smallint;
    procedure SetLoadError(aValue: Smallint);
    function GetLongData: Integer;
    procedure SetLongData(aValue: Integer);
    function GetPutAvail: Smallint;
    procedure SetPutAvail(aValue: Smallint);
    function GetStringData: WideString;
    procedure SetStringData(aValue: WideString);
    function GetTextHandle: Smallint;
    procedure SetTextHandle(aValue: Smallint);
    function GetBinaryACCELNumber: Smallint;
    procedure SetBinaryACCELNumber(aValue: Smallint);
    function GetAutomaticTextDataRead: WordBool;
    procedure SetAutomaticTextDataRead(aValue: WordBool);
    function GetACCELVersion: Smallint;
    procedure SetACCELVersion(aValue: Smallint);
    function GetCCFile: WideString;
    procedure SetCCFile(aValue: WideString);
    function GetMinBytesToRead: Smallint;
    procedure SetMinBytesToRead(aValue: Smallint);
    function GetDAPLFile: WideString;
    procedure SetDAPLFile(aValue: WideString);
    function GetCCStackSize: Smallint;
    procedure SetCCStackSize(aValue: Smallint);
    function GetMinPollingInterval: Smallint;
    procedure SetMinPollingInterval(aValue: Smallint);
    function GetFlushOnStartup: WordBool;
    procedure SetFlushOnStartup(aValue: WordBool);
    function GetFlushOnShutdown: WordBool;
    procedure SetFlushOnShutdown(aValue: WordBool);
    function GetFloatData: single;
    procedure SetFloatData(aValue: single);
    function GetAutomaticBinaryDataRead: WordBool;
    procedure SetAutomaticBinaryDataRead(aValue: WordBool);
    function GetOutputSpace: Integer;
    procedure SetOutputSpace(aValue: Integer);
    function GetInputAvail: Integer;
    procedure SetInputAvail(aValue: Integer);
    function GetTextACCELNumber: Smallint;
    procedure SetTextACCELNumber(aValue: Smallint);
    function GetDapName: WideString;
    procedure SetDapName(aValue: WideString);
    procedure SetOnNewBinaryData(aValue: TDAPNewBinaryData);
    function GetOnNewBinaryData: TDapNewBinaryData;
    procedure SetOnNewTextData(aValue: TDAPNewTextData);
    function GetOnNewTextData: TDapNewTextData;
  public
    constructor Create(aDap: TDap);
    procedure ReleaseDap;
    procedure AboutBox;
    function Int16BufferPut(Length: Integer; var Buffer: Smallint): Integer;
    function Int16BufferGet(Length: Integer; var Buffer: Smallint): Integer;
    function GetOCXCreated: boolean;
    property BinaryHandle: Smallint read GetBinaryHandle write SetBinaryHandle;
    property Accel32Version: Smallint read GetAccel32Version write SetAccel32Version;
    property FlushTextInput: WordBool read GetFlushTextInput write SetFlushTextInput;
    property CtlVersion: Smallint read GetCtlVersion write SetCtlVersion;
    property FlushBinaryInput: WordBool read GetFlushBinaryInput write SetFlushBinaryInput;
    property CharData: Smallint read GetCharData write SetCharData;
    property AutomaticDataRead: WordBool read GetAutomaticDataRead write SetAutomaticDataRead;
    property FlushInputs: WordBool read GetFlushInputs write SetFlushInputs;
    property GetAvail: Smallint read getGetAvail write SetGetAvail;
    property IntData: Smallint read GetIntData write SetIntData;
    property IoCtlString: WideString read GetIoCtlString write SetIoCtlString;
    property LoadError: Smallint read GetLoadError write SetLoadError;
    property LongData: Integer read GetLongData write SetLongData;
    property PutAvail: Smallint read GetPutAvail write SetPutAvail;
    property StringData: WideString read GetStringData write SetStringData;
    property TextHandle: Smallint read GetTextHandle write SetTextHandle;
    property BinaryACCELNumber: Smallint read GetBinaryACCELNumber write SetBinaryACCELNumber;
    property AutomaticTextDataRead: WordBool read GetAutomaticTextDataRead write SetAutomaticTextDataRead;
    property ACCELVersion: Smallint read GetACCELVersion write SetACCELVersion;
    property CCFile: WideString read GetCCFile write SetCCFile;
    property MinBytesToRead: Smallint read GetMinBytesToRead write SetMinBytesToRead;
    property DAPLFile: WideString read GetDAPLFile write SetDAPLFile;
    property CCStackSize: Smallint read GetCCStackSize write SetCCStackSize;
    property MinPollingInterval: Smallint read GetMinPollingInterval write SetMinPollingInterval;
    property FlushOnStartup: WordBool read GetFlushOnStartup write SetFlushOnStartup;
    property FlushOnShutdown: WordBool read GetFlushOnShutdown write SetFlushOnShutdown;
    property FloatData: Single read GetFloatData write SetFloatData;
    property AutomaticBinaryDataRead: WordBool read GetAutomaticBinaryDataRead write SetAutomaticBinaryDataRead;
    property OutputSpace: Integer read GetOutputSpace write SetOutputSpace;
    property InputAvail: Integer read GetInputAvail write SetInputAvail;
    property TextACCELNumber: Smallint read GetTextACCELNumber write SetTextACCELNumber;
    property DapName: WideString read GetDapName write SetDapName;
    property OnNewBinaryData : TDAPNewBinaryData read GetOnNewBinaryData write SetOnNewBinaryData;
    property OnNewTextData : TDAPNewTextData read GetOnNewTextData write SetOnNewTextData;
  end;

{$REGION 'TDapInterface'}

procedure TDapInterface.ReleaseDap;
begin
  if assigned(FDap) then
  begin
    FDap.OnNewBinaryData := nil;
    FDap.OnNewTextData := nil;
    FDap.Free;
  end;
end;

function TDapInterface.GetBinaryHandle: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.BinaryHandle;
end;

procedure TDapInterface.SetBinaryHandle(aValue: Smallint);
begin
  if assigned(Fdap) then
    FDap.BinaryHandle := aValue;
end;

function TDapInterface.GetAccel32Version: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.Accel32Version;
end;

procedure TDapInterface.SetAccel32Version(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.Accel32Version := aValue;
end;

function TDapInterface.GetFlushTextInput: WordBool;
begin
  result := true;
  if assigned(FDap) then
    result := FDap.FlushTextInput;
end;

procedure TDapInterface.SetFlushTextInput(aValue: WordBool);
begin
  if assigned(FDap) then
    FDap.FlushTextInput := aValue;
end;

function TDapInterface.GetCtlVersion: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.CtlVersion;
end;

procedure TDapInterface.SetCtlVersion(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.CtlVersion := aValue;
end;

function TDapInterface.GetFlushBinaryInput: WordBool;
begin
  result := true;
  if assigned(FDap) then
    result := FDap.FlushBinaryInput;
end;

procedure TDapInterface.SetFlushBinaryInput(aValue: WordBool);
begin
  if assigned(FDap) then
    FDap.FlushBinaryInput := aValue;
end;

function TDapInterface.GetCharData: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.CharData;
end;

procedure TDapInterface.SetCharData(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.CharData := aValue;
end;

function TDapInterface.GetAutomaticDataRead: WordBool;
begin
  result := true;
  if assigned(FDap) then
    result := FDap.AutomaticDataRead;
end;

procedure TDapInterface.SetAutomaticDataRead(aValue: WordBool);
begin
  if assigned(FDap) then
    FDap.AutomaticDataRead := aValue;
end;

function TDapInterface.GetFlushInputs: WordBool;
begin
  result := true;
  if assigned(FDap) then
    result := FDap.FlushInputs;
end;

procedure TDapInterface.SetFlushInputs(aValue: WordBool);
begin
  if assigned(FDap) then
   FDap.FlushInputs := aValue;
end;

function TDapInterface.getGetAvail: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.GetAvail;
end;

procedure TDapInterface.SetGetAvail(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.GetAvail := aValue;
end;

function TDapInterface.GetIntData: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.IntData;
end;

procedure TDapInterface.SetIntData(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.IntData := aValue;
end;

function TDapInterface.GetIoCtlString: WideString;
begin
  result := '';
  if assigned(FDap) then
    result := FDap.IoCtlString;
end;

procedure TDapInterface.SetIoCtlString(aValue: WideString);
begin
  if assigned(FDap) then
    FDap.IoCtlString := aValue;
end;

function TDapInterface.GetLoadError: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.LoadError;
end;

procedure TDapInterface.SetLoadError(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.LoadError := aValue;
end;

function TDapInterface.GetLongData: Integer;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.LongData;
end;

procedure TDapInterface.SetLongData(aValue: Integer);
begin
  if assigned(FDap) then
    FDap.LongData := aValue;
end;

function TDapInterface.GetPutAvail: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.PutAvail;
end;

procedure TDapInterface.SetPutAvail(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.PutAvail := aValue;
end;

function TDapInterface.GetStringData: WideString;
begin
  result := '';
  if assigned(FDap) then
    result := FDap.StringData;
end;

procedure TDapInterface.SetStringData(aValue: WideString);
begin
  if assigned(FDap) then
    FDap.StringData := aValue;
end;

function TDapInterface.GetTextHandle: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.TextHandle;
end;

procedure TDapInterface.SetTextHandle(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.TextHandle := aValue;
end;

function TDapInterface.GetBinaryACCELNumber: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.BinaryACCELNumber;
end;

procedure TDapInterface.SetBinaryACCELNumber(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.BinaryACCELNumber := aValue;
end;

function TDapInterface.GetAutomaticTextDataRead: WordBool;
begin
  result := true;
  if assigned(FDap) then
    result := FDap.AutomaticTextDataRead;
end;

procedure TDapInterface.SetAutomaticTextDataRead(aValue: WordBool);
begin
  if assigned(FDap) then
    FDap.AutomaticTextDataRead := aValue;
end;

function TDapInterface.GetACCELVersion: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.ACCELVersion;
end;

procedure TDapInterface.SetACCELVersion(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.ACCELVersion := aValue;
end;

function TDapInterface.GetCCFile: WideString;
begin
  result := '';
  if assigned(FDap) then
    result := FDap.CCFile;
end;

procedure TDapInterface.SetCCFile(aValue: WideString);
begin
  if assigned(FDap) then
    FDap.CCFile := aValue;
end;

function TDapInterface.GetMinBytesToRead: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.MinBytesToRead;
end;

procedure TDapInterface.SetMinBytesToRead(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.MinBytesToRead := aValue;
end;

function TDapInterface.GetDAPLFile: WideString;
begin
  result := '';
  if assigned(FDap) then
    result := FDap.DAPLFile;
end;

procedure TDapInterface.SetDAPLFile(aValue: WideString);
begin
  if assigned(FDap) then
    FDap.DAPLFile := aValue;
end;

function TDapInterface.GetCCStackSize: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.CCStackSize;
end;

procedure TDapInterface.SetCCStackSize(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.CCStackSize := aValue;
end;

function TDapInterface.GetMinPollingInterval: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.MinPollingInterval;
end;

procedure TDapInterface.SetMinPollingInterval(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.MinPollingInterval := aValue;
end;

function TDapInterface.GetFlushOnStartup: WordBool;
begin
  result := true;
  if assigned(FDap) then
    result := FDap.FlushOnStartup;
end;

procedure TDapInterface.SetFlushOnStartup(aValue: WordBool);
begin
  if assigned(FDap) then
    FDap.FlushOnStartup := aValue;
end;

function TDapInterface.GetFlushOnShutdown: WordBool;
begin
  result := true;
  if assigned(FDap) then
    result := FDap.FlushOnShutdown;
end;

procedure TDapInterface.SetFlushOnShutdown(aValue: WordBool);
begin
  if assigned(FDap) then
    FDap.FlushOnShutdown := aValue;
end;

function TDapInterface.GetFloatData: single;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.FloatData;
end;

procedure TDapInterface.SetFloatData(aValue: single);
begin
  if assigned(FDap) then
    FDap.FloatData := aValue;
end;

function TDapInterface.GetAutomaticBinaryDataRead: WordBool;
begin
  result := true;
  if assigned(FDap) then
    result := FDap.AutomaticBinaryDataRead;
end;

procedure TDapInterface.SetAutomaticBinaryDataRead(aValue: WordBool);
begin
  if assigned(FDap) then
    FDap.AutomaticBinaryDataRead := aValue;
end;

function TDapInterface.GetOutputSpace: Integer;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.OutputSpace;
end;

procedure TDapInterface.SetOutputSpace(aValue: Integer);
begin
  if assigned(FDap) then
    FDap.OutputSpace := aValue;
end;

function TDapInterface.GetInputAvail: Integer;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.InputAvail;
end;

procedure TDapInterface.SetInputAvail(aValue: Integer);
begin
  if assigned(FDap) then
    FDap.InputAvail := aValue;
end;

function TDapInterface.GetTextACCELNumber: Smallint;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.TextACCELNumber;
end;

procedure TDapInterface.SetTextACCELNumber(aValue: Smallint);
begin
  if assigned(FDap) then
    FDap.TextACCELNumber := aValue;
end;

function TDapInterface.GetDapName: WideString;
begin
  result := '';
  if assigned(FDap) then
    result := FDap.DapName;
end;

procedure TDapInterface.SetDapName(aValue: WideString);
begin
  if assigned(FDap) then
    FDap.DapName := aValue;
end;

procedure TDapInterface.AboutBox;
begin
  if assigned(FDap) then
    FDap.AboutBox;
end;

function TDapInterface.Int16BufferPut(Length: Integer; var Buffer: Smallint): Integer;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.Int16BufferPut(Length, Buffer);
end;

function TDapInterface.Int16BufferGet(Length: Integer; var Buffer: Smallint): Integer;
begin
  result := 0;
  if assigned(FDap) then
    result := FDap.Int16BufferGet(Length, Buffer);
end;

function TDapInterface.GetOCXCreated: boolean;
begin
  result := FDap <> nil;
end;

constructor TDapInterface.Create(aDap: TDap);
begin
  FDap := aDap;
end;
{$ENDREGION}

{$REGION 'TDapControl'}

function TDapControl.CheckInRange(aADValue: integer): integer;
begin
  result := aADValue;
  if result > MaxAdCount then
    result := MaxAdCount
  else
  if result < MinAdCount then
    result := MinAdCount;
end;

procedure TDapControl.Send_DAPL_Command(aCommand : string);
begin
  FDapInterface.StringData := aCommand;
end;

procedure TDapControl.Set_Dap_Var(DapVar : string; Value : integer);
var lValue : integer;
begin
  lValue := CheckInRange(Value);
  Send_DAPL_Command(format('let %s=%d',[DapVar, lValue]));
end;

function TDapControl.Get_Dap_Var(DapVar : string): string;
begin
  Send_DAPL_Command(format('SDisplay %s',[DapVar]));
  result := FDapInterface.stringdata;
end;

function TDapControl.Flush_DAP: boolean;
var lFlushBinaryInput,
    lFlushTextInput   : WordBool;
begin
  result := true;
  lFlushBinaryInput := FDapInterface.FlushBinaryInput;
  lFlushTextInput   := FDapInterface.FlushTextInput;
  result := lFlushBinaryInput and lFlushTextInput;
end;

function TDapControl.DapPresent: boolean;
begin
  result := FDapInterface.GetOCXCreated;
end;

function TDapControl.Reset_DAP: boolean;
begin
  result := true;
  Send_DAPL_Command('RESET');
  result := Flush_DAP;
end;

function TDapControl.Stop_DAP: boolean;
begin
  Send_DAPL_Command('STOP');
  result := Flush_DAP;
end;

function TDapControl.GetDAPData(aLength: integer; var aBuffer : smallint): integer;
begin
  result := FDapInterface.Int16BufferGet(aLength, aBuffer);
end;

function TDapControl.MaxAdCount : integer;
begin
  result := FMaxAdCount;
end;

function TDapControl.MinAdCount : integer;
begin
  result := FMinAdCount;
end;

function TDapControl.ConvertDtoA(aDigitalVal : integer; aAtoDRange : double): double;
begin
  if aDigitalVal >= 0 then
    result := (aDigitalVal / (MaxADCount{a positive number})) * aAtoDRange
  else
    result := (-aDigitalVal / (MinADCount{a negative number})) * aAtoDRange;
end;

function TDapControl.ConvertAToD(aFloatVal : double; aAtoDRange : double): integer;
var ADVal : integer;
begin
  if aFloatVal >= 0 then
    ADVal := trunc((aFloatVal / aAtoDRange) * (MaxAdCount))
  else
    ADVal := trunc((-aFloatVal / aAtoDRange) * (MinAdCount));
  result := CheckInRange(ADVal);
end;

procedure TDapControl.ConvertAToDandSend(aFloatVal : double; aAtoDRange : double; aDapVarName : string);
var dapVarVal : integer;
begin
  inherited;
  dapVarVal := ConvertAToD(aFloatVal, aAtoDRange);
  Set_Dap_Var(aDapVarName, dapVarVal);
end;

procedure TDapControl.SendStringToDAP(aString : string);
begin
  inherited;
  Send_DAPL_Command(aString);
end;

procedure TDapControl.SendCCFileToDAP(aFilename : string);
begin
  inherited;
  FDapInterface.ccFile := aFilename;
end;

procedure TDapControl.SendDaplFileToDap(aFilename: string);
begin
  inherited;
  FDapInterface.DaplFile := aFilename;
end;

procedure TDapInterface.SetOnNewBinaryData(aValue: TDapNewBinaryData);
begin
  if assigned(FDap) then
    FDap.OnNewBinaryData := aValue;
end;

procedure TDapControl.SetOnNewBinaryData(aValue: TDAPNewBinaryData);
begin
  FDapInterface.OnNewBinaryData := aValue;
end;

function TDapInterface.GetOnNewBinaryData: TDapNewBinaryData;
begin
  result := nil;
  if assigned(FDap) then
    result := FDap.OnNewBinaryData;
end;

function TDapControl.GetOnNewBinaryData: TDapNewBinaryData;
begin
  result := FDapInterface.OnNewBinaryData;
end;

function TDapControl.GetDapName: string;
begin
  result := FDapInterface.DapName;
end;

procedure TDapControl.SetDapName(aValue: string);
begin
  FDapInterface.DapName := aValue;
end;

procedure TDapInterface.SetOnNewTextData(aValue: TDapNewTextData);
begin
  if assigned(FDap) then
    FDap.OnNewTextData := aValue;
end;

procedure TDapControl.SetOnNewTextData(aValue: TDAPNewTextData);
begin
  FDapInterface.OnNewTextData := aValue;
end;

function TDapInterface.GetOnNewTextData: TDapNewTextData;
begin
  result := nil;
  if assigned(FDap) then
    result := FDap.OnNewTextData;
end;

function TDapControl.GetOnNewTextData: TDapNewTextData;
begin
  result := FDapInterface.OnNewTextData;
end;

procedure TDapControl.ReleaseDAP;
begin
  FDapInterface.OnNewBinaryData := nil;
  FDapInterface.OnNewTextData := nil;
  FDapInterface.ReleaseDap;
end;

constructor TDapControl.Create(aDap: IDapInterface; aMaxADCount : integer; aMinADCount : integer);
begin
  inherited create;
  FDapInterface := aDap;
  FMaxADCount := aMaxADCount;
  FMinADCount := aMinADCount;
end;

{$endregion}

procedure RegisterDapControl(aUseHardware : boolean=true);
begin
  GlobalContainer.RegisterType<TDapControl>.Implements<IDapControl>;
  GlobalContainer.RegisterType<TDapInterface>.Implements<IDapInterface>.DelegateTo
    (
    function: TDapInterface
    var aDap : TDap;
    begin
      aDap := nil;
      if aUseHardware then
        aDap := TDap.Create(nil);
      result := TDapInterface.Create(aDap);
    end
    );
  GlobalContainer.Build;
end;

function GetADAP: IDapControl;
begin
  result := GlobalContainer.Resolve<IDapControl>;
end;

end.
