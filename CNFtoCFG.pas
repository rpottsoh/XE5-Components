unit CNFtoCFG;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TMSIDataTypes, PickList;

type
  TCNFtoCFG = class(TComponent)
  private
    { Private declarations }
    FRecordCount         : integer;
    FMaxAnalogChan : integer;
    FCNFFilename   : string;
    ConfigRecords   : ChnCNFArrPtr;
    FCNFLoaded      : boolean;
    FDFMPos          : TStringList;
    FDFMPosINI       : string;
    FRawDataFilename  : string;
    FVolume_CH        : LongInt;
    FFile_Intvl_CH    : single;
    FChannels         : TStrings;
    FRawFilenames     : TStrings;
    FDataDescINI      : TStrings;
    FTestIDStr        : string;
    FVmax : single;
    FStartSpeed        : single;
    FStoreZeroOffs    : boolean;
    FDataBaseAssigned : boolean;
    FDataBase : tTransducerArrayptr;
    FDummyList2    : tidANDelementArrayPtr;
    FDBasePath     :string;
    FINIFilename : string;
    FTireID      : string;
    FSpeedUnits   : string;
    FPickList    : TPickList;
    FPickListLoaded : boolean;
    FSampleRate : single;
    procedure SetMaxAnalogChan( Value : integer );
    procedure SetCNFFilename( const Value : string );
    function GetChannelUsed( index : integer ): boolean;
    function getBoxChannelNum(BoxNum, ChanNum : integer): integer;
    function GetSensitivity( index : integer ): single;
    procedure SetSensitivity(index : integer; Value : single);
    function GetGain( index : integer ): single;
    procedure SetGain( index : integer; Value : single);
    function GetPolarity( index : integer ): integer;
    function GetDFMPosChanNum( index : integer ): integer;
    function GetVoltsFactor( index : integer ): single;
    procedure SetDFMPosINI( const Value : string );
    procedure SetRawDataFilename( const Value : string );
    procedure SetRawFilenames( const value : string );
    function GetZeroOffset(index : integer): single;
    procedure SetZeroOffset(index : integer; const value : single);
    function GetDatabase(index:integer): XdcrRecType;
    procedure SetDatabase(index : integer; const Value : XdcrRecType);
    procedure SetDataBasePath(const value : string);
    procedure Check_Channel(var ChanValue : CNFrec);
    function GetUnits(index : integer):string;
    function GetRange(index : integer): single;
    function GetActualRange(index : integer):single;
    function GetMicroStrain(index : integer):word;
    function GetDataDesc(index : integer): string;
    procedure SetINIFilename(const value : string);
    function getDFMPos( index : integer ): string;
    function getSenTyp(index : integer):string;
    function GetSenId(index : integer):string;
    function GetSenLoc(index : integer):string;
    function GetSenAtt(index : integer):string;
    function GetAxis(index : integer):string;
    function GetHardware(index : integer):string;
    function GetccSlotnum(index : integer):string;
    function GetExcitation(index : integer):double;
    function GetMaxExcitation(index : integer):double;
    function GetChanNum(index : integer):byte;
    function GetintChanNum(index : integer):integer;
    function getReptFilt(index : integer):string;
    function getAutobalance(index : integer):boolean;
    function getLowpassFilter(index : integer):boolean;

    function getTestObject(index : integer):string;
    function getPosition(index : integer):string;
    function getMainLocation(index : integer):string;
    function getFineLocation1(index : integer):string;
    function getFineLocation2(index : integer):string;
    function getFineLocation3(index : integer):string;
    function getDirection(index : integer):string;
    function getFilterClass(index : integer):string;
    function getPostTestShuntCalStatus(index : integer):boolean;
    function getTPSCheckOK:boolean;
    procedure SetTPSCheckOK(value : boolean);
  protected
    { Protected declarations }
  public
    { Public declarations }
    Constructor Create( AOwner : TComponent ); override;
    Destructor Destroy; override;
    procedure Load_Data_Desc_Picklist(const filename : string);
    Procedure OpenCNFFile( const Value : string );
    Procedure OpenDFMINI( const Value : string );
    procedure LoadTransducerDatabase;
    procedure SaveTransducerDatabase;
    function LocateXdcrRec(const ID : string; var ErrFound : boolean ) : integer;
    function Make_CFG_INI_File: boolean;
    function Find_Chan_Num_Of_DataDesc(const value : string): integer;
    procedure SaveCNFFile;
    procedure Initialize;
    property CNFLoaded : boolean
       read FCNFLoaded;
    property DFMPosChanNum[ index : integer ] : integer
       read GetDFMPosChanNum;
    property  ChannelUsed[ index : integer ] : boolean
       read GetChannelUsed;
    property BoxChannelNum[BoxNum, ChanNum : integer]: integer
       read GetBoxChannelNum;
    property Sensitivity[ index : integer ] : single
       read GetSensitivity
       Write SetSensitivity;
    property Gain[ index : integer ]: single
       read GetGain
       write SetGain;
    property Polarity[ Index : integer ]: integer
       read GetPolarity;
    property DFMPosINI : string
      read FDfmPosIni
      write SetDFMPosIni;
    property CNFFilename : string
      read FCNFFilename
      write SetCNFFilename;
    property RawDataFilename : string
      read FRawDataFilename
      write SetRawDataFilename;
    property VoltsFactor[ index : integer ] : single
      read GetVoltsFactor;
    property Volume_CH : Longint
      read FVolume_CH;
    property File_Intvl_CH : single
      read FFile_Intvl_CH;
    property RawFileNames : tstrings
      read FRawFileNames;
    property ZeroOffset[ index : integer ] : single
      read GetZeroOffset
      write SetZeroOffset;
    property DataBase[index : integer] : XdcrRecType
      read GetDataBase
      write SetDatabase;
    property RecordCount : integer
      read FRecordCount;
    property units[index : integer] : string
      read GetUnits;
    property Range[index : integer] : single
      read GetRange;
    property ActualRange[index : integer]:single
      read GetActualRange;
    property MicroStrain[index : integer]:word
      read GetMicroStrain;
    property DataDescription[ index : integer ] : string
      read GetDataDesc;
    property DFMPos[index : integer] : string
      read getDFMPos;{}
    property SenTyp[ index : integer ] : string
      read getSenTyp;
    property PhysicalDimension[ index : integer ] : string
      read getSenTyp;
    property SenID[ index : integer ] : string
      read GetSenId;
    property SenLoc[ index : integer ] : string
      read GetSenLoc;
    property SenAtt[ index : integer ] : string
      read GetSenAtt;
    property Axis[ index : integer ] : string
      read GetAxis;
    property Hardware[ index : integer] : string
      read GetHardware;
    property ccSlotnum[ index : integer ] : string
      read GetccSlotnum;
    property Excitation[ index : integer ] : double
      read GetExcitation;
    property MaxExcitation[ index : integer ] : double
      read GetMaxExcitation;
    property ChanNum[ index : integer ] : byte
      read GetChanNum;
    property intChanNum[ index : integer ] : integer
      read GetintChanNum;
    property ReptFilt[ index : integer ] : string
      read getReptFilt;
    property Autobalance[ index : integer ] : boolean
      read getAutobalance;
    property LowpassFilter[ index : integer ] : boolean
      read getLowpassFilter;

    property TestObject[ index : integer ] : string
      read getTestObject;
    property Position[ index : integer ] : string
      read getPosition;
    property MainLocation[ index : integer ] : string
      read getMainLocation;
    property FineLocation1[ index : integer ] : string
      read getFineLocation1;
    property FineLocation2[ index : integer ] : string
      read getFineLocation2;
    property FineLocation3[ index : integer ] : string
      read getFineLocation3;
    property Direction[ index : integer ] : string
      read getDirection;
    property FilterClass[ index : integer ] : string
      read getFilterClass;
    property PostTestShuntCalStatus[ index : integer] : boolean
      read getPostTestShuntCalStatus;
    property TPSCheckedOK : boolean
      read getTPSCheckOK
      write SetTPSCheckOK;
  published
    { Published declarations }
    property MaxAnalogChan : integer
      read FMaxAnalogChan
      write SetMaxAnalogChan
      default CMaxAnalogChan;
//    property TestID : string
//      read FTestIDStr
//      write FTestIDStr;
    property MaxAnalogVoltage : single
      read FVMax
      write FVmax;
    property StartSpeed : single
      read FStartSpeed
      write FStartSpeed;
    property SaveZeroOffs : boolean
      read FStoreZeroOffs
      write FStoreZeroOffs
      default false;
    property DataBasePath : string
      read FDBasePath
      write SetDataBasePath;
    property INIFilename : string
      read FINIFilename
      write SetINIFilename;
    property TireID : string
      read FTireID
      write FTireID;
    property SpeedUnits : string
      read FSpeedUnits
      write FSpeedUnits;
    property SampleRate : single
      read FSampleRate
      write FSampleRate;
  end;

  TINItoCFG = class(TCNFtoCFG)
  private
    FChanININame : string;
    procedure SetChannelDefinitionINI(const Value : string);
  protected
  public
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;
    function SequenceOfDay_To_Filename(TestNum : integer): string;
    property ChannelDefinitionINI : string
      read FChanININame
      write SetChannelDefinitionINI;
  published
  end;


implementation
uses inifiles, filectrl;


constructor TCNFtoCFG.create;
begin
  inherited create(AOwner);
  FMaxAnalogChan := CMaxAnalogChan;
  FCNFFilename   := '';
  new(ConfigRecords);
  FCNFLoaded := false;
  FDFMPos := TStringList.Create;
  FDFMPosINI := '';
  FRawDataFilename  := '';
  FVolume_CH        := 0;
  FFile_Intvl_CH    := 0.0;
  FChannels         := TStringList.Create;
  FRawFilenames     := TStringList.create;
  FDataDescINI      := TStringList.create;
  FPickList         := TPickList.create(self);
  FTestIDStr        := '';
  FVMax := 5.0;
  FStoreZeroOffs := false;
  FDBasePath := '';
  FRecordCount := 0;
  FINIFilename := '';
  FTireID := '';
  FSpeedUnits := '';
  FPickListLoaded := false;
  FSampleRate := 0.0;
  FStartSpeed  := 0.0;
end;

destructor TCNFtoCFG.Destroy;
begin
  if FDataBaseAssigned then
    freearray(FDataBase, FDummyList2, FRecordCount);
  Dispose(ConfigRecords);
  FDFMPos.Clear;
  FDFMpos.Free;
  FChannels.Clear;
  FChannels.free;
  FRawFilenames.clear;
  FRawFilenames.free;
  FDataDescINI.clear;
  FDataDescINI.free;
  FPickList.free;
  inherited Destroy;
end;

function TCNFtoCFG.getDFMPos( index : integer ): string;
begin
  if (index <= FDFMPos.count) and (Index > 0) then
    result := FDFMPos[index - 1]
  else
    result := format('ERROR! Index out of bounds in GetDFMPos--%d', [index]);
end;{}

function TCNFtoCFG.GetVoltsFactor( index : integer ): single;
begin
  result := strtofloat(FChannels[index - 1]);
end;

procedure TCNFtoCFG.SetDFMPosINI( const Value : string );
begin
  if (csDesigning in ComponentState) then
  begin
    if uppercase(value) <> uppercase(FDFMPosINI) then
      FDFMPosINI := Value;
  end
  else
  begin
    if uppercase(value) <> uppercase(FDFMPosINI) then
      OpenDFMINI( Value );
  end;
end;

Procedure TCNFtoCFG.OpenDFMINI( const Value : string );

   procedure OpenINI;
   var inifile : TInifile;
       TempString : string;
       loop       : integer;
   begin
     FDFMPos.clear;
     inifile := TIniFile.create(FDFMPosINI);
     try
       for loop := MinAnalogChan to FMaxAnalogChan do
       begin
         TempString := INIFile.ReadString('DFMPositions',inttostr(loop + 1),'MISSING');
         FDFMPos.Add(TempString);
       end;
     finally
       inifile.free;
     end;
   end;

begin
  if FileExists( Value ) then
  begin
    FDFMPosINI := Value;
    OpenINI;
  end
  else
    messageDlg('Unable to Locate DFM INI file.', mtError, [mbok], 0);
end;

function TCNFtoCFG.GetDFMPosChanNum( index : integer ): integer;
var SearchString  : string;
    messagestring : string;
    loop          : integer;
begin
  result := 0;
  if (index > 0) and (index <= FDFMPos.Count) then
  begin
    SearchString := trim(Uppercase(FDFMPos[index - 1]));
    if SearchString = 'MISSING' then
    begin
      messagestring := format('DFM Position %d is missing from Positions list', [index]);
      messagedlg(messagestring, mterror, [mbok], 0);
      exit;
    end;
    for loop := MinAnalogChan to FDFMPos.Count - 1 do
    begin
      if trim(uppercase(ConfigRecords^[loop].DataDesc)) = SearchString then
      begin
        result := loop + 1;
        break;
      end;
    end;
  end;
end;

procedure TCNFtoCFG.SetSensitivity(index : integer; Value : single);
begin
  if (Index <= FMaxAnalogChan) and (index > 0) then
    ConfigRecords^[index - 1].CalcSensi := Value;
end;

function TCNFtoCFG.GetSensitivity( index : integer ): single;
begin
  if (Index <= FMaxAnalogChan) and (index > 0) then
    result := ConfigRecords^[index - 1].CalcSensi
  else
    result := -1;
end;

function TCNFtoCFG.GetRange(index : integer): single;
begin
  if (Index <= FMaxAnalogChan) and (index > 0) then
    result := ConfigRecords^[index - 1].reqscale
  else
    result := -1.0;
end;

function TCNFtoCFG.GetActualRange(index : integer):single;
begin
  if (Index <= FMaxAnalogChan) and (index > 0) then
    result := ConfigRecords^[index - 1].ActualRange
  else
    result := -1.0;
end;

function TCNFtoCFG.GetMicroStrain(index : integer):word;
begin
  if (Index <= FMaxAnalogChan) and (index > 0) then
    result := ConfigRecords^[index - 1].MicroStrain
  else
    result := 65535;
end;

function TCNFtoCFG.GetDataDesc(index : integer): string;
begin
  if (Index <= FMaxAnalogChan) and (index > 0) then
    result := ConfigRecords^[index - 1].DataDesc
  else
    result := '-1';
end;

function TCNFtoCFG.GetUnits(index : integer):string;
begin
  if (Index <= FMaxAnalogChan) and (index > 0) then
    result := ConfigRecords^[index - 1].units
  else
    result := '-1';
end;

function TCNFtoCFG.GetGain( index : integer ): single;
begin
  if (Index <= FMaxAnalogChan) and (index > 0) then
    result := ConfigRecords^[index - 1].Gain
  else
    result := -1;
end;

procedure TCNFtoCFG.SetGain( index : integer; Value : single);
begin
  if (Index <= FMaxAnalogChan) and (Index > 0) then
    ConfigRecords^[Index-1].Gain := Value;
end;

function TCNFtoCFG.GetChannelUsed( index : integer ): boolean;
begin
  if (index > 0) and (index <= FMaxAnalogChan) then
    result := (ConfigRecords^[index - 1].DataDesc <> '') and (ConfigRecords^[index - 1].SenId <> '')
  else
    result := false;
end;

function TCNFtoCFG.getBoxChannelNum(BoxNum, ChanNum : integer): integer;
var i : integer;
    found : boolean;
begin
  i := -1;
  found := false;
  repeat
    inc(i);
    if ConfigRecords^[i].BoxNum = BoxNum then
      if Configrecords^[i].BoxChanNum = ChanNum then
        if Configrecords^[i].DataDesc <> '' then
          found := true;
  until found or (i = FMaxAnalogChan-1);
  if found then
    result := i + 1
  else
    result := 0;  // if channel not used then pass back a zero
end;

function TCNFtoCFG.GetPolarity( index : integer ): integer;
begin
  if (Index <= FMaxAnalogChan) and (index > 0) then
  begin
    if ConfigRecords^[index - 1].Polarity = '+' then
      result := 1
    else
      result := -1;
  end
  else
    result := 0;
end;

procedure TCNFtoCFG.SetCNFFilename( const Value : string );
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

procedure TCNFtoCFG.SetRawFilenames( const value : string );
var pathstr : string;
    loop    : integer;
begin
  PathStr := ExtractFilepath(Value);
  if PathStr[length(PathStr)] <> '\' then
    PathStr := PathStr + '\';
  for loop := 65 to 90 do     // A to Z
  begin
    if fileexists(PathStr + FTestIdStr + chr(loop) + '.bin001.bin') then
      FRawFilenames.add(PathStr + FTestIDStr + chr(loop) + '.bin001.bin');
  end;
  FVolume_CH := FVolume_CH * FRawFilenames.Count;
end;

procedure TCNFtoCFG.SetRawDataFilename( const Value : string );
var templist : tstringlist;
    tempstring : string;
    tempstring2 : string;
    loop,
    loop2       : integer;
    ChannelNum  : integer;

    function Find_ChannelNum(const value : string):integer;
    var i : integer;
        tmpstr : string;
    begin
      result := 0;
      i := 0;
      tmpstr := '';
      repeat
        inc(i);
      until (Value[i] in ['0','1','2','3','4','5','6','7','8','9']) or
            (i = length(Value));
      if i = length(Value) then
        exit;
      repeat
        tmpstr := tmpstr + Value[i];
        inc(i);
      until Value[i] = ',';
      result := strtoint(tmpstr);
    end;

    function Find_AdFactor(const value : string): string;
    var i : integer;
        tmpstr : string;
    begin
      result := '0.0';
      i := 0;
      tmpstr := '';
      repeat
        inc(i);
      until Value[i] = '*';
      inc(i);
      repeat
        tmpstr := tmpstr + Value[i];
        inc(i);
      until Value[i] = '+';
      result := tmpstr;
    end;

begin
  if value <> FRawDataFilename then
  begin
    FChannels.clear;
    FRawDataFilename  := value;
    templist := tstringlist.create;
    try
      templist.loadfromfile( FRawDataFilename );

      if templist[0] <> '// Sony PCscan MKII data log file' then
      begin
        tempstring := Value + ' is not a valid file.';
        messagedlg(tempstring, mterror, [mbok], 0);
        FRawDataFilename := '';
        exit
      end;
      
      tempstring := templist[6]; // VOLUME_CH
      tempstring2 := '';
      loop := 0;
      repeat
        inc(loop)
      until (tempstring[loop] in ['1','2','3','4','5','6','7','8','9','0']) or
            (loop = length(tempstring));
      for loop2 := loop to length(tempstring) do
        tempstring2 := tempstring2 + tempstring[loop2];
      FVolume_CH := strtoint(tempstring2);

      tempstring := templist[7]; // FILE_INTVL_CH
      tempstring2 := '';
      loop := 0;
      repeat
        inc(loop);
      until (tempstring[loop] in ['1','2','3','4','5','6','7','8','9','0']) or
            (loop = length(tempstring));
      repeat
        tempstring2 := tempstring2 + tempstring[loop];
        inc(loop)
      until tempstring[loop] = ' ';
      FFile_Intvl_CH := strtofloat(tempstring2);

      loop := 10;
      ChannelNum := 0;
      while templist[loop] <> '//' do  //CHANNELS
      begin
        inc(ChannelNum);
        tempstring := templist[loop];
        if channelnum = Find_ChannelNum(tempstring) then
          FChannels.add(Find_AdFactor(tempstring))
        else
          FChannels.add('0.0');
        inc(loop);
      end;
    finally
      templist.free;
      SetRawFilenames( value );
    end;
  end;
end;

function TCNFtoCFG.GetZeroOffset(index : integer): single;
begin
  result := 0.0;
  if FCNFLoaded and ChannelUsed[index] then
    result := ConfigRecords^[index-1].ZeroOfs;
end;

procedure TCNFtoCFG.SetZeroOffset(index : integer; const value : single);
begin
  if FCNFLoaded and ChannelUsed[index] then
  begin
    ConfigRecords^[index-1].ZeroOfs := value;
    SaveCNFFile;
  end
end;

procedure TCNFtoCFG.SaveCNFFile;
var CNFfile      : CNFfileType;
    RecNum       : integer;
    TempChan     : CNFrec;
begin
  if FCNFLoaded then
  begin
    assignfile( CNFFile, FCNFFilename );
    rewrite( CNFFile );
    for RecNum := MinAnalogChan to FMaxAnalogChan-1 do
    begin
      TempChan := ConfigRecords^[Recnum];
      TempChan.ZeroOfs := TempChan.ZeroOfs * ord(FStoreZeroOffs); //if FStoreZeroOffs is False then set ZeroOFs equal to zero
      dec(TempChan.ChanNum);
      write(cnffile,TempChan);
    end;
    CloseFile(CnfFile);
  end;
end;

procedure TCNFtoCFG.SetTPSCheckOK(value : boolean);
begin
  ConfigRecords^[0].FilePassedTPSCheck := value;
  if FCNFLoaded then
    SaveCNFFile;
end;

function TCNFtoCFG.getTPSCheckOK:boolean;
begin
  result := ConfigRecords^[0].FilePassedTPSCheck;
end;

Procedure TCNFtoCFG.OpenCNFFile( const Value : string );
var CNFfile      : CNFfileType;
    RecNum       : integer;
    BreakPoint   : integer;
begin
  if not FDataBaseAssigned then
    LoadTransducerDatabase;
  BreakPoint := 0;
  FCNFLoaded := false;
  fillchar(ConfigRecords^,sizeof(ConfigRecords^),#0);
  assignfile( CNFFile, Value );
  reset( CNFFile );
  BreakPoint := FMaxAnalogChan-1;
  for RecNum := MinAnalogChan to FMaxAnalogChan-1 do
  begin
    read(cnffile,ConfigRecords^[Recnum]);
    inc(ConfigRecords^[Recnum].ChanNum);
    Check_Channel(ConfigRecords^[Recnum]);
    if eof(CNFFile) then
    begin
      BreakPoint := Recnum;
      break;
    end;
  end;
  CloseFile(CnfFile);
  FCNFLoaded := true;
  if BreakPoint < FMaxAnalogChan-1 then
  begin
    SaveCNFFile;
  end;
end;

procedure TCNFtoCFG.Initialize;
begin
  FCNFFilename := '';
  FCNFLoaded := false;
  fillchar(ConfigRecords^, sizeof(ConfigRecords^) ,#0);
end;

procedure TCNFtoCFG.SetMaxAnalogChan( Value : integer );
begin
  if Value <> FMaxAnalogChan then
    if (Value > MinAnalogChan) and (Value <= CMaxAnalogChan) then
    FMaxAnalogChan := Value;
end;

procedure TCNFtoCFG.SetDatabase(index : integer; const Value : XdcrRecType);
begin
  if FDatabaseAssigned and ((index >= 0) and (index < FRecordCount))then
{$IFOPT R+}
  {$DEFINE CKRANGEcnf}
  {$R-}
{$ENDIF}
    FDataBase^[index] := value;
{$IFDEF CKRANGEcnf}
  {$UNDEF CKRANGEcnf}
  {$R+}
{$ENDIF}
end;

function TCNFtoCFG.GetDataBase(index : integer): XdcrRecType;
var tempRec : XdcrRecType;
begin
  if FDatabaseAssigned and ((index >= 0) and (index < FRecordCount))then
{$IFOPT R+}
  {$DEFINE CKRANGEcnf}
  {$R-}
{$ENDIF}
    temprec := FDataBase^[index]
{$IFDEF CKRANGEcnf}
  {$UNDEF CKRANGEcnf}
  {$R+}
{$ENDIF}
  else
  begin
    fillchar(temprec, sizeof(temprec), #0);
  end;
  result := temprec;
end;

procedure TCNFtoCFG.SaveTransducerDatabase;
var loop                : integer;
    DataBasefile        : file of XdcrRecType;
begin
  assignfile(DatabaseFIle, format('%sXDCRCURR.DTA',[FDBASEPATH]));
  rewrite(DatabaseFile);
  for loop := 0 to FrecordCount - 1 do
{$IFOPT R+}
  {$DEFINE CKRANGEcnf}
  {$R-}
{$ENDIF}
    write(DatabaseFile, FDatabase^[loop]);
{$IFDEF CKRANGEcnf}
  {$UNDEF CKRANGEcnf}
  {$R+}
{$ENDIF}
  closefile(DatabaseFile);
end;

procedure TCNFtoCFG.LoadTransducerDatabase;
var FileStream          : TFileStream;
    loop                : integer;
begin
  if fileexists(FDBasePath + 'XDCRCURR.dta') then
  begin
    FileStream := tfilestream.create(FDBasePath + 'XDCRCURR.dta',fmOpenReadWrite or fmShareExclusive);
    Frecordcount := FileStream.Size div sizeof(XdcrRecType);
    CreateArray(FDataBase, FDummyList2, FRecordCount);
{$IFOPT R+}
  {$DEFINE CKRANGEcnf}
  {$R-}
{$ENDIF}
    try
      FDataBaseAssigned := true;
      for loop := 0 to Frecordcount - 1 do
        FileStream.Read( FDataBase^[loop], sizeof(XdcrRecType));
    finally
      FileStream.Free;
    end;
{$IFDEF CKRANGEcnf}
  {$UNDEF CKRANGEcnf}
  {$R+}
{$ENDIF}
  end
  else
    MessageDlg('Unable to Locate Transducer Database.  Go'+#13+#10+
               'To the Transducer Database Editor and build'+#13+#10+
               'a Database.',mtError,[mbOK],0);
end;

procedure TCNFtoCFG.SetDataBasePath(const Value : string);
var tempvalue : string;
begin
  tempvalue := value;
  if tempvalue[length(tempvalue)] <> '\' then
    tempvalue := tempvalue + '\';
  if tempvalue <> FDbasePath then
    FDBasePath := tempvalue;
end;

{$IFOPT R+}
  {$DEFINE CKRANGEcnf}
  {$R-}
{$ENDIF}
procedure TCNFtoCFG.Check_Channel(var ChanValue : CNFrec);
var loop : integer;
    tempSID : string;
    ChannelNum : integer;
    SensorFound : boolean;
    FoundAtLoc : integer;
begin
// first try to find the sensor in the database
  if ChanValue.DataDesc = '' then
    exit;
  SensorFound := false;
  FoundAtLoc := 0;
  for loop := 0 to FRecordCount - 1 do
  begin
    tempSID := inttostr(FDataBase^[loop].RefNum div 10);
    tempSID := tempSID + '-';
    TempSID := TempSID + inttostr(FDataBase^[loop].RefNum mod 10);
    if TempSID = ChanValue.SenID then
    begin
      SensorFound := true;
      FoundAtLoc := loop;
      break;
    end;
  end;
  if not SensorFound then
  begin
    ChannelNum := ChanValue.ChanNum;
    fillchar(ChanValue, sizeof(ChanValue), #0);
    messagedlg(format('Unable to locate the sensor in the Transducer Database' +#13#10+
                      'that has been assigned to channel %d in the selected' +#13#10+
                      'Transducer Configuration File.' +#13#10+
                      'This channel will be ignored.', [ChannelNum]), mterror, [mbok],0);
  end
  else
{$ifdef UseOutputAtFs}
    if (round(1000*ChanValue.OutputAtFS) <> round(1000*FDataBase^[FoundAtLoc].OutputAtFS)) then
    begin
      ChanValue.OutputAtFS := FDataBase^[FoundAtLoc].OutputAtFS;
      ChanValue.offset := FDataBase^[FoundAtLoc].Offset;
      ChanValue.Excitation := FDataBase^[FoundAtLoc].Excitation;
      ChanValue.ReqScale := FDataBase^[FoundAtLoc].Range;
      ChanValue.Units := FDataBase^[FoundAtLoc].Units;
    end;  
{$else}
    if (round(10000*ChanValue.CalcSensi) <> round(10000*FDataBase^[FoundAtLoc].Sensitivity)) then
    begin
      ChanValue.CalcSensi := FDataBase^[FoundAtLoc].Sensitivity;
      ChanValue.offset := FDataBase^[FoundAtLoc].Offset;
      ChanValue.Excitation := FDataBase^[FoundAtLoc].Excitation;
      ChanValue.ReqScale := FDataBase^[FoundAtLoc].Range;
      ChanValue.Units := FDataBase^[FoundAtLoc].Units;
//      ChannelNum := ChanValue.ChanNum;
//      fillchar(ChanValue, sizeof(ChanValue), #0);
//      messagedlg(format('The sensitivity of the sensor assigned to channel %d' +#13#10+
//                        'does not match the sensitivity of the sensor of the' +#13#10+
//                        'same Sensor ID listed in the Transducer Database.' +#13#10+
//                        'This channel will be ignored.', [ChannelNum]), mterror, [mbok],0);
    end;
{$endif}
end;
{$IFDEF CKRANGEcnf}
  {$UNDEF CKRANGEcnf}
  {$R+}
{$ENDIF}


procedure TCNFtoCFG.SetINIFilename(const value : string);
begin
  if FINIFilename <> value then
    FINIFilename := value;
end;

function TCNFtoCFG.Make_CFG_INI_File: boolean;
var INIFile : tINIFIle;
    loop    : integer;
    SectionStr : string;
begin
  result := false;
  if not FCNFLoaded then
  begin
    messagedlg('Please assign a transducer configuration.', mterror, [mbok],0);
    exit
  end;

  if FINIFilename = '' then
  begin
    messagedlg('Please assign an INIFilename', mterror, [mbok],0);
    exit
  end;

  if directoryexists( extractfilepath(FINIFilename) ) then
  begin
    inifile := TIniFIle.create(FINIFilename);
    try
      inifile.writestring('General','MaxAnalogVoltage',
                            FloatToStrF(FVmax,fffixed,7,2));
      inifile.writestring('General','Tire ID', FTireID);
      inifile.WriteString('General','Sample Rate', FloatToStrF(FSampleRate,fffixed,3,2));
      inifile.WriteString('General','Test Speed', FloatToStrF(FStartSpeed,fffixed,5,2));
      inifile.WriteString('General','Test Units', FSpeedUnits);
      for loop := 1 to FMaxAnalogChan do
        if GetChannelUsed( loop ) then
        begin
          SectionStr := format('%d', [loop]);
          inifile.writestring(sectionStr,'Sensor ID',ConfigRecords^[loop-1].SenID);
          inifile.writestring(sectionStr,'Units', ConfigRecords^[loop-1].units);
          inifile.writestring(sectionStr,'Data Description', ConfigRecords^[loop-1].DataDesc);
          inifile.Writestring(sectionstr,'Polarity', ConfigRecords^[loop-1].polarity);
          inifile.WriteString(sectionstr,'Requested Fullscale',
                                FloatToStrF(ConfigRecords^[loop-1].ReqScale, fffixed,7,3));
          inifile.WriteString(sectionstr,'Gain',
                                FloatToStrF(ConfigRecords^[loop-1].gain, fffixed,7,1));
          inifile.writestring(sectionstr,'Sensitivity',
                                FloatToStrF(ConfigRecords^[loop-1].CalcSensi, fffixed,7,4));
        end;
    finally
      inifile.free;
    end;
  end;
end;

function TCNFtoCFG.Find_Chan_Num_Of_DataDesc(const value : string): integer;
var loop : integer;
    FoundAtPoint : integer;
    DFMPnt : integer;
begin
  FoundAtPoint := -1;
  for loop := 0 to FPickList.LongNames.Count - 1 do
    if trim(value) = FPickList.longnames[loop] then
    begin
      DFMPnt := loop + 1;
      FoundAtPoint := DFMPosChanNum[DFMPnt];
      break;
    end;
  result := FoundAtPoint;
end;

procedure TCNFtoCFG.Load_Data_Desc_Picklist(const filename : string);
var IniFile      : TInifile;
    loop         : integer;
begin
   FPickListLoaded := false;
   IniFile := TInifile.create(filename);
   try
     IniFile.ReadSection( 'DataDesc', FPickList.ShortNames);
     for loop := 0 to FPickList.ShortNames.Count - 1 do
       FPickList.LongNames.add(IniFile.ReadString( 'DataDesc', FPickList.ShortNames[loop], '(none)' ));
     FPickListLoaded := true;
   finally
     IniFile.free;
   end;
end;

function TCNFtoCFG.LocateXdcrRec(const ID : string; var ErrFound : boolean ) : integer;
var Found : boolean;
    count : integer;
    j     : integer;
    TmpStr : string;
    ValErr : integer;
    TmpLI  : integer;
begin
  Found := FALSE;
  count := 0;
  j := 1;
  tmpstr := '';
  While (J <= Length(ID)) and (ID[J]<>' ') Do
  Begin
    If ID[J] <> '-' then
      TmpStr := TmpStr + ID[J];
    Inc( J );
  End;
  Val( TmpStr, TmpLI, ValErr );
  If ValErr <> 0 then
  begin
    ErrFound := True;
    result := -1;
    exit;
  end;
  while (count <= FRecordcount) AND NOT( Found ) do
  begin
{$IFOPT R+}
  {$DEFINE CKRANGEcnf}
  {$R-}
{$ENDIF}
    if FDataBase^[count].RefNum = TmpLI then
{$IFDEF CKRANGEcnf}
  {$UNDEF CKRANGEcnf}
  {$R+}
{$ENDIF}
      Found := TRUE
    else
      inc( count );
  end;
  if Found then
    Result := count
  else
    Result := -1;
end;

function TCNFtoCFG.getSenTyp(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].SenTyp
  else
    result := '';
end;

function TCNFtoCFG.getAutobalance(index : integer):boolean;
begin
  result := false;
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].AutoBalance;
end;

function TCNFtoCFG.getLowpassFilter(index : integer):boolean;
begin
  result := false;
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].LowPassFilter;
end;

function TCNFtoCFG.getTestObject(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].ISO13499TestObject
  else
    result := '';
end;

function TCNFtoCFG.getPosition(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].ISO13499Position
  else
    result := '';
end;

function TCNFtoCFG.getMainLocation(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].ISO13499MainLocation
  else
    result := '';
end;

function TCNFtoCFG.getFineLocation1(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].ISO13499FineLocation1
  else
    result := '';
end;

function TCNFtoCFG.getFineLocation2(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].ISO13499FineLocation2
  else
    result := '';
end;

function TCNFtoCFG.getFineLocation3(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].ISO13499FineLocation3
  else
    result := '';
end;

function TCNFtoCFG.getDirection(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].ISO13499Direction
  else
    result := '';
end;

function TCNFtoCFG.getFilterClass(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].ISO13499FilterClass
  else
    result := '';
end;

function TCNFtoCFG.getPostTestShuntCalStatus(index : integer):boolean;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].PostTestShuntCalStat
  else
    result := false;
end;

function TCNFtoCFG.GetSenId(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].SenID
  else
    result := '';
end;

function TCNFtoCFG.GetSenLoc(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].SenLoc
  else
    result := '';
end;

function TCNFtoCFG.GetSenAtt(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].SenAtt
  else
    result := '';
end;

function TCNFtoCFG.GetAxis(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].Axis
  else
    result := '';
end;

function TCNFtoCFG.GetHardware(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].Hardware
  else
    result := '';
end;

function TCNFtoCFG.GetccSlotnum(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].ccslotNum
  else
    result := '';
end;

function TCNFtoCFG.GetMaxExcitation(index : integer):double;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].MaxExcitation
  else
    result := 0.0;
end;

function TCNFtoCFG.GetExcitation(index : integer):double;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].Excitation
  else
    result := 0.0;
end;

function TCNFtoCFG.GetChanNum(index : integer):byte;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].ChanNum
  else
    result := 0;
end;

function TCNFtoCFG.GetintChanNum(index : integer):integer;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].intChanNum
  else
    result := 0;
end;

function TCNFtoCFG.getReptFilt(index : integer):string;
begin
  if (index <= FMaxAnalogchan) and (index > 0) then
    result := ConfigRecords^[index - 1].ReptFilt
  else
    result := '';
end;

////////////////////////////////////////////////

{TINItoCFG}

constructor TINItoCFG.Create;
begin
  inherited create(Aowner);
  FChanININame := '';
end;

destructor TINItoCFG.Destroy;
begin
  inherited destroy;
end;

procedure TINItoCFG.SetChannelDefinitionINI(const Value : string);
var inifile : TINIFile;
    Sections : TStringlist;
    i : integer;
    ChanNum : integer;
begin
  if value <> '' then
  begin
    FChanININame := value;
    if fileexists(FChanININame) then
    begin
      inifile := TInifile.Create(FChanININame);
      try
        fillchar(ConfigRecords^, Sizeof(ConfigRecords^), #0);
        Sections := TStringlist.create;
        Sections.clear;
        inifile.ReadSections(Sections);
        for i := 0 to Sections.count - 1 do
        begin
          if uppercase(Sections[i]) = 'GENERAL' then
          begin
            FSampleRate := StrToFloat(inifile.ReadString(Sections[i],'Sample Rate', '0.0'));
            FTireID := inifile.ReadString(Sections[i], 'Tire ID', 'Not Found');
            FSpeedUnits := inifile.ReadString(Sections[i], 'Test Units', 'Not Found');
            FVMax := strtofloat(inifile.readstring(sections[i], 'MaxAnalogVoltage', '10.0'));
            FStartSpeed := strtofloat(inifile.readstring(sections[i], 'Start Speed', '0.0'));
          end
          else
          begin
 //           ChanNum := strtoint(copy(sections[i],length('Channel')+1,length(sections[i])-length('Channel')));
            ChanNum := strtoint(sections[i]);
            if ChanNum in [1..32] then
            begin
              with ConfigRecords^[chanNum-1] do
              begin
                SenId := inifile.ReadString(Sections[i],'Sensor ID', '0-0');
                ConfigRecords^[chanNum].Units := inifile.Readstring(sections[i],'Units','?');
                DataDesc := inifile.ReadString(Sections[i],'Data Description', '');
                polarity := inifile.readstring(sections[i],'Polarity','+');
                ReqScale := strtofloat(inifile.readstring(sections[i], 'Requested Fullscale', '1.0'));
                Gain     := strtofloat(inifile.readstring(sections[i],'Gain', '1.0'));
                CalcSensi := strtofloat(inifile.readstring(sections[i],'Sensitivity', '1.0'));
              end;
            end;
          end;
        end;
        Sections.Clear;
      finally
        Sections.free;
        inifile.free;
      end;
    end
    else
      Messagedlg(FChanININame + ' doesn''t exists.', mterror, [mbok],0);
  end
  else
    messagedlg('Please assign a channel definition INI file', mterror,[mbok],0);
end;

function TINItoCFG.SequenceOfDay_To_Filename(TestNum : integer): string;
var DateString : string;
    TestNumStr : string;
    OldFormat : string;
begin
  OldFormat := FormatSettings.ShortDateFormat;
  FormatSettings.ShortDateFormat := 'yyyymmdd';
  DateString := datetostr(date);
  FormatSettings.ShortDateFormat := OldFormat;
  TestNumStr := inttostr(TestNum);
  if TestNum < 100 then
    testNumStr := '0' + TestnumStr;
  if TestNum < 10 then
    TestNumStr := '0' + TestNumStr;
  result := DateString+testNumStr;
end;

end.

