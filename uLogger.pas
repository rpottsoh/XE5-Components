unit uLogger;

interface
uses Spring.Collections;

type
  ILogger = interface(IInvokable)
  ['{6D9190C4-AF56-4796-B5B8-454AC2993328}']
    procedure ChannelData(aChanData: array of variant);
    function getLogOpen: Boolean;
    function getAverage: Boolean;
    procedure setAverage(aValue: Boolean);
    function getaverageCount: integer;
    procedure setaverageCount(aValue: integer);
    procedure StartLog;
    procedure PauseLog;
    procedure ResumeLog;
    procedure CloseLog;
    property Average: Boolean read getAverage write setAverage;
    property averageCount: integer read getaverageCount write setaverageCount;
    property LogOpen: Boolean read getLogOpen;
  end;

  function NewLogger(aHeadings: array of string;
      aChannelsToLog: array of boolean; aPath: string; aFilename: string=''; aPrefix: string=''): ILogger;

implementation
uses System.Classes, System.SysUtils;

type
  TLogger = class(TInterfacedObject, ILogger)
  private
    fPath,
    fFilename: string;
    fPrefix: string;
    fChannelHeadings: IList<string>;
    fChannelsToLog: IList<Boolean>;
    fChannelData: IList<Variant>;
    fAverage: Boolean;
    fAverageCount: integer;
    fCurrentCount: integer;
    fLogOpen: boolean;
    fLogPaused: boolean;
    fLogFile: TStreamWriter;
    function getLogOpen: Boolean;
    function getAverage: Boolean;
    procedure setAverage(aValue: Boolean);
    function getaverageCount: integer;
    procedure setaverageCount(aValue: integer);
    procedure InsertHeadings(aFilename: string);
    procedure UpdateLog;
  public
    constructor Create(aHeadings: array of string;
      aChannelsToLog: array of boolean; aPath: string; aPrefix: string; aFilename: string='');
    destructor Destroy; override;
    procedure StartLog;
    procedure PauseLog;
    procedure ResumeLog;
    procedure CloseLog;
    procedure ChannelData(aChanData: array of variant);
    property Average: Boolean read getAverage write setAverage;
    property averageCount: integer read getaverageCount write setaverageCount;
    property LogOpen: Boolean read getLogOpen;
  end;

function NewLogger(aHeadings: array of string;
    aChannelsToLog: array of boolean; aPath: string; aFilename: string=''; aPrefix: string=''): ILogger;
begin
  result := TLogger.create(aHeadings, aChannelsToLog, aPath, aPrefix, aFilename);
end;

constructor TLogger.Create(aHeadings: array of string; aChannelsToLog: array of boolean;
  aPath: string; aPrefix: string; aFilename: string = '');
var lHeading: string;
    lLogChan: boolean;
begin
  inherited Create;
  fLogOpen := false;
  fLogPaused := false;
  fPath := aPath;
  fFilename := aFilename;
  fPrefix := aPrefix;
  fAverage := true;
  faverageCount := 1;
  fCurrentCount := 0;
  fChannelHeadings := TCollections.CreateList<string>;
  fChannelsToLog := TCollections.CreateList<Boolean>;
  fChannelData := TCollections.CreateList<Variant>;
  if length(aHeadings) > 0 then
  begin
    for lHeading in aHeadings do
      fChannelHeadings.Add(lHeading);
    for lLogChan in aChannelsToLog do
      fChannelsToLog.Add(lLogChan);
  end;
end;

destructor TLogger.Destroy;
begin
  fChannelHeadings.Clear;
  fChannelsToLog.Clear;
  fChannelData.Clear;
  inherited Destroy;
end;

procedure TLogger.StartLog;
var FullFilename: string;
    DateTime: string;
    fs: TFormatSettings;
begin
  if not fLogOpen then
  begin
    fs := TFormatSettings.Create;
    FullFilename := fPath;
    ForceDirectories(FullFilename);
    if not FullFilename.EndsWith('\') then
      FullFilename := FullFilename + '\';
    if fFilename.IsEmpty then
    begin
      FS.ShortDateFormat := 'ddmmyy';
      FS.LongTimeFormat := 'hhmmss';
      DateTime := format('%s%s',[DateToStr(Date, fs), TimeToStr(Time, fs)]);
      DateTime := fPrefix + DateTime;
      FullFilename := FullFilename + DateTime + '.csv';
    end
    else
      FullFilename := FullFilename + fPrefix + fFilename;
    InsertHeadings(FullFilename);
  end;
end;

procedure TLogger.InsertHeadings(aFilename: string);
var
  fs: TFormatSettings;
  rowStr: string;
  chanHeading: string;
begin
  fLogFile := TStreamWriter.Create(aFilename);
  try
    fs := TFormatSettings.Create;
    fLogFile.WriteLine(format('%s,%s,',[DateToStr(Date, fs),TimeToStr(Time, fs)]));
    rowStr := '';
    for chanHeading in fChannelHeadings do
    begin
      if rowStr.IsEmpty then
        rowStr := chanHeading
      else
        rowStr := rowStr + format(',%s',[chanHeading]);
    end;
    fLogFile.WriteLine(rowStr);
    fLogOpen := true;
    fLogPaused := false;
  except
    CloseLog;
  end;
end;

procedure TLogger.PauseLog;
begin
  fLogPaused := fLogOpen;
end;

procedure TLogger.ResumeLog;
begin
  fLogPaused := false;
end;

procedure TLogger.CloseLog;
begin
  fLogOpen := false;
  fLogPaused := false;
  if assigned(fLogFile) then
  begin
    fLogFile.Close;
    FreeAndNil(fLogFile);
  end;
end;

procedure TLogger.UpdateLog;
var pointValue: variant;
    rowStr: string;
    valStr: string;
    vt: word;
begin
  try
    if fLogOpen and not fLogPaused and fCurrentCount.ToBoolean then
    begin
      if not fAverage or
         (fAverage and (fCurrentCount = fAverageCount)) then
      begin
        fCurrentCount := 0;
        rowStr := '';
        for pointValue in fChannelData do
        begin
          vt := TVarData(pointValue).VType;
          case vt of
            varBoolean : valStr := BoolToStr(TVarData(pointValue).VBoolean, True);
            varSmallInt: valStr := format('%d',[TVarData(pointValue).VSmallInt]);
            varInteger : valStr := format('%d',[TVarData(pointValue).VInteger]);
            varShortInt: valStr := format('%d',[TVarData(pointValue).VShortInt]);
            varByte    : valStr := format('%d',[TVarData(pointValue).VByte]);
            varWord    : valStr := format('%d',[TVarData(pointValue).VWord]);
            varLongWord: valStr := format('%d',[TVarData(pointValue).VLongWord]);
            varInt64   : valStr := format('%d',[TVarData(pointValue).VInt64]);
            varUInt64  : valStr := format('%d',[TVarData(pointValue).VUInt64]);

            varSingle : valStr := format('%0.4f',[TVarData(pointValue).VSingle]);
            varDouble : valStr := format('%0.4f',[TVarData(pointValue).VDouble]);

            varUString,
            varOleStr : valStr := format('%s',[TVarData(pointValue).VOleStr]);
          else
            raise Exception.CreateFmt('VType of %d not supported in uLogger.UpdateLog',[vt]);
          end; //case
          if not rowStr.IsEmpty then
            valStr := ',' + valStr;
          rowStr := rowStr + valStr;
        end;
        fLogFile.WriteLine(rowStr);
      end
    end;
  except
    CloseLog;
    raise;
  end;
end;

function TLogger.getLogOpen: Boolean;
begin
  result := fLogOpen;
end;

function TLogger.getAverage: Boolean;
begin
  result := fAverage;
end;

procedure TLogger.setAverage(aValue: Boolean);
begin
  fAverage := aValue;
end;

function TLogger.getaverageCount: integer;
begin
  result := fAverageCount;
end;

procedure TLogger.setaverageCount(aValue: Integer);
begin
  fAverageCount := aValue;
end;

procedure TLogger.ChannelData(aChanData: array of variant);
var idx: integer;
    okIndex: integer;
    vt: word;
    wrkVal: variant;
begin
  if fLogOpen and not fLogPaused then
  begin
    try
      if fCurrentCount = 0 then
      begin
        fChannelData.Clear;
        for idx := Low(aChanData) to High(aChanData) do
          if fChannelsToLog[idx] then
            fChannelData.Add(aChandata[idx]);
        if fChannelData.Count > 0 then
          inc(fCurrentCount);
      end
      else
      begin
        okIndex := -1;
        for idx := low(aChanData) to high(aChanData) do
        begin
          if fChannelsToLog[idx] then
          begin
            wrkVal := aChandata[idx];
            inc(okIndex);
            vt := TVarData(wrkVal).VType;
            case vt of
              varSmallInt,
              varInteger,
              varShortInt,
              varByte,
              varWord,
              varLongWord,
              varInt64,
              varUInt64 : fChannelData[okIndex] := ((fChannelData[okIndex] * fCurrentCount) + wrkVal) div (fCurrentCount + 1);

              varSingle,
              varDouble : fChannelData[okIndex] := ((fChannelData[okIndex] * fCurrentCount) + wrkVal) / (fCurrentCount + 1);

              varBoolean,
              varUString,
              varOleStr : fChannelData[okIndex] := wrkVal;
            else
              raise Exception.CreateFmt('VType of %d not supported in uLogger.ChannelData',[vt]);
            end; //case
          end;
        end;
        inc(fCurrentCount);
      end;
      UpdateLog;
    except
      CloseLog;
      raise;
    end;
  end;
end;

end.
