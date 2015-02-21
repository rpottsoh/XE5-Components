unit Ports;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs{,
  WinRTctl, WinRT, WinRTDriver};//WinRTOb;

type

  TBasePort = class(TComponent)
  private
//    FWinrtObj : tWinrt;
    DeviceOpened : boolean;
    FDeviceNo    : byte;
    FBaseAddr,
    FPortMax,
    FPortLength     : integer;
    function GetDriverVersion: string;
    function GetMinPortAddress: string;
    function GetMaxPortAddress: string;
    function GetPortLength: integer;
    function GetMinPortAddressAsInt : integer;
  public
    constructor create( AOwner : TComponent ); override;
    destructor destroy; override;
    function Init: boolean;
    property DriverVersion : string
      read GetDriverVersion;
    property MinPortAddress : string
      read GetMinPortAddress;
    property MinPortAddressAsInt : integer
      read GetMinPortAddressAsInt;
    property MaxPortAddress : string
      read GetMaxPortAddress;
    property PortLength : Integer
      read GetPortLength;
  published
    property DeviceNo : byte read FDeviceNo write FDeviceNo default 0;
  end;

  TBytePort = class(TBasePort)
  private
    { Private declarations }
    procedure SetPortVal( Index : integer; Value : byte );
    function GetPortVal( Index : integer ): byte;
  protected
    { Protected declarations }
  public
    { Public declarations }
    property PortVal[ index : integer ] : byte read GetPortVal write SetPortVal;
      default;
  end;

  TWordPort = class(TBasePort)
  private
    { Private declarations }
    procedure SetPortVal( Index : integer; Value : Word );
    function GetPortVal( Index : integer ): word;
  protected
    { Protected declarations }
  public
    { Public declarations }
    property PortVal[ index : integer ] : word read GetPortVal write SetPortVal;
      default;
  end;

  TLongPort = class(TBasePort)
  private
    { Private declarations }
    procedure SetPortVal( Index : integer; Value : LongInt );
    function GetPortVal( Index : integer ): LongInt;
  protected
    { Protected declarations }
  public
    { Public declarations }
    property PortVal[ index : integer ] : LongInt read GetPortVal write SetPortVal;
      default;
  end;

implementation

//========= Base Port ===========

constructor TBasePort.create;
begin
  inherited Create( AOwner );
  DeviceOpened := false;
  FDeviceNo := 0;
  FBaseAddr := 0;
  FPortMax  := 0;
//  FWinrtObj := nil;
end;

destructor TBasePort.destroy;
begin
//  FWinRTObj.Free;
//  FWinRTObj := nil;
  DeviceOpened := False;
  inherited destroy;
end;

function TBasePort.Init: boolean;
begin
  if not DeviceOpened then
  begin
//    FWinRTObj := TWinrt.Create(FDeviceNo, False);
//    if assigned(FWinrtObj) then
//      if FWinRTObj.Handle <> -1 then
//      begin
//        GetMinPortAddress;
//        GetMaxPortAddress;
//        GetPortLength;
//        DeviceOpened := true;
//      end;
  end;
  result := DeviceOpened;
end;

function TBasePort.GetDriverVersion: string;
var tempstr : string;
//    Configuration : tWINRT_FULL_CONFIGURATION;
    dummy : integer;
    LoWord,
    HiWord : word;
begin
  tempstr := '';
//  WinRTGetFullConfiguration(FWinrtObj.handle, Configuration,dummy);
////  WinRTGetConfiguration(FWinrtObj.handle, Configuration, dummy);
//  LoWord := Configuration.minorVersion;
//  HiWord := Configuration.majorVersion;
  tempstr := format('%d.%d',[HiWord, LoWord]);
  result := tempstr;
end;

function TBasePort.GetMinPortAddress: string;
var tempstr : string;
//    Configuration : tWINRT_FULL_CONFIGURATION;
    dummy : integer;
begin
  tempstr := '';
//  WinRTGetFullConfiguration(FWinrtObj.handle, Configuration,dummy);
//  tempstr := inttohex(configuration.portStart[0], 5);
//  FBaseAddr := configuration.portStart[0];
  result := tempstr;
end;

function TBasePort.GetMaxPortAddress: string;
var tempstr : string;
//    Configuration : tWINRT_FULL_CONFIGURATION;
    dummy : integer;
begin
  tempstr := '';
//  WinRTGetFullConfiguration(FWinrtObj.handle, Configuration, dummy);
//  tempstr := inttohex(configuration.portStart[0]+configuration.PortLength[0]-1, 5);
//  FPortMax := configuration.PortLength[0];
  result := tempstr;
end;

function TBasePort.GetPortLength: integer;
var
//  Configuration : tWINRT_FULL_CONFIGURATION;
  dummy : integer;
begin
//  WinRTGetFullConfiguration(FWinrtObj.handle, Configuration, dummy);
//  FPortLength := configuration.PortLength[0];
  result := FPortLength;
end;

function TBasePort.GetMinPortAddressAsInt : integer;
var
//  Configuration : tWINRT_FULL_CONFIGURATION;
  dummy : integer;
begin
//  WinRTGetFullConfiguration(FWinrtObj.handle, Configuration,dummy);
//  FBaseAddr := configuration.portStart[0];
  result := FBaseAddr;
end;

//========= Byte Port ===========

procedure TBytePort.SetPortVal( Index : integer; Value : byte );
begin
  if not DeviceOpened or not Init then
    exit;
  if (index > (FBaseAddr+FPortLength-1)) or (Index < FBaseAddr) then
   exit;
//  with FWinrtObj do
//  begin
//    outp([rtfabs], Index, Value);
//    DeclEnd;
//    ProcessBuffer;
//    clear;
//  end;
end;

function TBytePort.GetPortVal( Index : integer ): byte;
var TempVal : byte;
begin
  result := 0;
  if not DeviceOpened or not Init then
    exit;
  if (index > (FBaseAddr+FPortLength-1)) or (Index < FBaseAddr) then
   exit;
//  with FWinrtObj do
//  begin
//    TempVal := 0;
//    inp([rtfabs], Index, TempVal);
//    DeclEnd;
//    ProcessBuffer;
//    clear;
//    result := TempVal;
//  end;
end;

//============== Word Port ================

procedure TWordPort.SetPortVal( Index : integer; Value : Word );
begin
  if not DeviceOpened or not Init then
    exit;
  if (index > FPortMax-1) or (Index < FBaseAddr) then
   exit;
//  with FWinrtObj do
//  begin
//    outp([rtfword, rtfabs], Index, Value);
//    DeclEnd;
//    ProcessBuffer;
//    clear;
//  end;
end;

function TWordPort.GetPortVal( Index : integer ): word;
var TempVal : word;
begin
  result := 0;
  if not DeviceOpened or not Init then
    exit;
  if (index > FPortMax-1) or (Index < FBaseAddr) then
   exit;
//  with FWinrtObj do
//  begin
//    TempVal := 0;
//    inp([rtfword, rtfabs], Index, TempVal);
//    DeclEnd;
//    ProcessBuffer;
//    clear;
//    result := TempVal;
//  end;
end;

//========  Long Port  =============

procedure TLongPort.SetPortVal( Index : integer; Value : LongInt );
begin
  if not DeviceOpened or not Init then
    exit;
  if (index > FPortMax-2) or (Index < FBaseAddr) then
   exit;
//  with FWinrtObj do
//  begin
//    outp([rtflong, rtfabs], Index, Value);
//    DeclEnd;
//    ProcessBuffer;
//    clear;
//  end;
end;

function TLongPort.GetPortVal( Index : integer ): LongInt;
var TempVal : word;
begin
  result := 0;
  if not DeviceOpened or not Init then
    exit;
  if (index > FPortMax-2) or (Index < FBaseAddr) then
//  with FWinrtObj do
//  begin
//    TempVal := 0;
//    inp([rtflong, rtfabs], Index, TempVal);
//    DeclEnd;
//    ProcessBuffer;
//    clear;
//    result := TempVal;
//  end;
end;

end.
