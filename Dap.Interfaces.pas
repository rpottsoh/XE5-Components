unit Dap.Interfaces;

interface
uses DAPLib_TLB;
type
{$region 'IDapInterface'}
  IDapInterface = interface(IInvokable)
  ['{45CB53AE-2697-420B-B292-2A9EA7232577}']
    // Getters and Setters
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
    function GetOCXCreated: boolean;

    //Methods and Properties
    procedure ReleaseDap;
    procedure AboutBox;
    function Int16BufferPut(Length: Integer; var Buffer: Smallint): Integer;
    function Int16BufferGet(Length: Integer; var Buffer: Smallint): Integer;
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
{$endregion}


{$region 'IDapControl'}
  IDapControl = interface(IInvokable)
  ['{6453D13D-6E97-41DD-9AC9-7F60EFE28E60}']
    procedure AddLongDapVar(aVarName: string);
    function IsLongDapVar(aVarName: string): Boolean;
    procedure ClearLongDapVarList;
    function GetDapName: string;
    procedure SetDapName(aValue: string);
    function MaxAdCountLong : longint;
    function MinAdCountLong : longint;
    function MaxAdCount : integer;
    function MinAdCount : integer;
    function CheckInRangeLong(aADValue: longint): longint;
    function CheckInRange(aADValue : integer): integer;
    function Stop_DAP: boolean;
    function Reset_DAP: boolean;
    function Flush_DAP: boolean;
    function DapPresent: boolean;
    function GetDAPData(aLength: integer; var aBuffer : smallint): integer;
    function Get_Dap_Var(DapVar : string): string;
    procedure Set_Dap_Var(DapVar : string; Value : integer);
    procedure Set_Dap_LVar(DapVar : string; Value : longint);
    procedure Send_DAPL_Command(aCommand : string);
    procedure SetOnNewBinaryData(aValue: TDAPNewBinaryData);
    function GetOnNewBinaryData: TDapNewBinaryData;
    procedure SetOnNewTextData(aValue: TDAPNewTextData);
    function GetOnNewTextData: TDapNewTextData;
    procedure ReleaseDAP;
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
{$endregion}

implementation

end.
