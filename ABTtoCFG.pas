unit ABTtoCFG;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, TMSIDataTypes;

type
  TABTtoCFG = class(TComponent)
  private
    { Private declarations }
    FMaxABtimer : integer;
    FCNFFilename   : string;
    ConfigRecords   : ChnABTArrPtr;
    FCNFLoaded      : boolean;
    FVmax : single;
    procedure SetMaxABTimer( Value : integer );
    procedure SetCNFFilename( const Value : string );
    function GetChannelIUsed( index : integer ): boolean;
    function GetChannelVUsed( index : integer ): boolean;
    function GetIPolarity( index : integer ): integer;
    function GetVPolarity( index : integer ): integer;
    function getLowpassIFilter(index : integer):boolean;
    function getLowpassVFilter(index : integer):boolean;
    function getSquibControlActive(index : integer):boolean;
    function GetSquibCurrent(index : integer):double;
    function GetSquibDelay(index : integer):double;
  protected
    { Protected declarations }
  public
    { Public declarations }
    Constructor Create( AOwner : TComponent ); override;
    Destructor Destroy; override;
    Procedure OpenCNFFile( const Value : string );
    procedure SaveCNFFile;
    property CNFLoaded : boolean
       read FCNFLoaded;
    property SquibControlActive[ index : integer ] : boolean
       read getSquibControlActive;
    property  ChannelIUsed[ index : integer ] : boolean
       read GetChannelIUsed;
    property  ChannelVUsed[ index : integer ] : boolean
       read GetChannelVUsed;
    property IPolarity[ Index : integer ]: integer
       read GetIPolarity;
    property VPolarity[ Index : integer ]: integer
       read GetVPolarity;
    property SFSFilename : string
      read FCNFFilename
      write SetCNFFilename;
    property LowpassVFilter[ index : integer ] : boolean
      read getLowpassVFilter;
    property LowpassIFilter[ index : integer ] : boolean
      read getLowpassIFilter;
    property SquibCurrent[ index : integer ] : double
      read GetSquibCurrent;
    property SquibDelay[ index : integer ] : double
      read GetSquibDelay;

  published
    { Published declarations }
    property MaxABTimer : integer
      read FMaxABTimer
      write SetMaxABTimer
      default CMaxABTimer;
    property MaxAnalogVoltage : single
      read FVMax
      write FVmax;
  end;

implementation

constructor TABTtoCFG.create;
begin
  inherited create(AOwner);
  FMaxABtimer := CMaxABtimer;
  FCNFFilename   := '';
  new(ConfigRecords);
  FCNFLoaded := false;
  FVMax := 5.0;
end;

destructor TABTtoCFG.Destroy;
begin
  Dispose(ConfigRecords);
  inherited Destroy;
end;

function TABTtoCFG.getSquibControlActive(index : integer):boolean;
begin
  if (index > 0) and (index <= FMaxABtimer) then
    result := ConfigRecords^[index].Active
  else
    result := false;
end;

function TABTtoCFG.GetChannelIUsed( index : integer ): boolean;
begin
  if (index > 0) and (index <= FMaxABtimer) then
    result := ConfigRecords^[index].MeasureCurrent
  else
    result := false;
end;

function TABTtoCFG.GetChannelVUsed( index : integer ): boolean;
begin
  if (index > 0) and (index <= FMaxABtimer) then
    result := ConfigRecords^[index].MeasureVoltage
  else
    result := false;
end;

function TABTtoCFG.GetIPolarity( index : integer ): integer;
begin
  if (Index <= FMaxABtimer) and (index > 0) then
  begin
    if ConfigRecords^[index].CurrentPolarity = '+' then
      result := 1
    else
      result := -1;
  end
  else
    result := 0;
end;

function TABTtoCFG.GetVPolarity( index : integer ): integer;
begin
  if (Index <= FMaxABtimer) and (index > 0) then
  begin
    if ConfigRecords^[index].VoltagePolarity = '+' then
      result := 1
    else
      result := -1;
  end
  else
    result := 0;
end;

procedure TABTtoCFG.SetCNFFilename( const Value : string );
begin
  if (csDesigning in ComponentState) then
  begin
    if uppercase(Value) <> uppercase(FCNFFilename) then
      FCNFFilename := Value;
  end
  else
  begin
    if uppercase(Value) <> uppercase(FCNFFilename) then
    begin
      if fileexists(Value) then
      begin
        FCNFFilename := Value;
        OpenCNFFile( FCNFFilename );
      end;
    end;
  end;
end;

procedure TABTtoCFG.SaveCNFFile;
var CNFfile      : ABTfileType;
    RecNum       : integer;
begin
  if FCNFLoaded then
  begin
    assignfile( CNFFile, FCNFFilename );
    rewrite( CNFFile );
    for RecNum := MinABTimer to FMaxABTimer do
      write(cnffile,ConfigRecords^[Recnum]);
    CloseFile(CnfFile);
  end;
end;

Procedure TABTtoCFG.OpenCNFFile( const Value : string );
var CNFfile      : ABTfileType;
    RecNum       : integer;
    BreakPoint   : integer;
begin
  BreakPoint := 0;
  FCNFLoaded := false;
  assignfile( CNFFile, Value );
  reset( CNFFile );
  for RecNum := MinABTimer to FMaxABTimer do
  begin
    read(cnffile,ConfigRecords^[Recnum]);
    if eof(CNFFile) then
    begin
      BreakPoint := Recnum;
      break;
    end;
  end;
  CloseFile(CnfFile);
  if BreakPoint >= FMaxABTimer then
  begin
    FCNFLoaded := true;
    SaveCNFFile;
  end;
end;

procedure TABTtoCFG.SetMaxABTimer( Value : integer );
begin
  if Value <> FMaxABTimer then
    if (Value >= MinABTimer) and (Value <= CMaxABTimer) then
      FMaxABTimer := Value;
end;

function TABTtoCFG.getLowpassIFilter(index : integer):boolean;
begin
  result := false;
  if (index <= FMaxABtimer) and (index > 0) then
    result := ConfigRecords^[index].CurrLowPassFilt;
end;

function TABTtoCFG.getLowpassVFilter(index : integer):boolean;
begin
  result := false;
  if (index <= FMaxABtimer) and (index > 0) then
    result := ConfigRecords^[index].VoltLowPassFilt;
end;

function TABTtoCFG.GetSquibCurrent(index : integer):double;
begin
  if (Index <= FMaxABtimer) and (index > 0) then
    result := ConfigRecords^[index].CurrentLevel
  else
    result := 0.1;
end;

function TABTtoCFG.GetSquibDelay(index : integer):double;
begin
  if (Index <= FMaxABtimer) and (index > 0) then
    result := ConfigRecords^[index].FireDelay
  else
    result := 0.0001;
end;


end.

