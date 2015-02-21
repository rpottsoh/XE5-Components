{*****************************************************}
{       TExcel Component 3.3 for Delphi 1.0 .. 3.0    }
{                                                     }
{       Copyright (c) 1996 ... 1998 Tibor F. Liska    }
{       Tel/Fax:    +36-1-165-2019                    }
{       Office:     +36-1-209-5284                    }
{       E-mail: liska@sztaki.hu                       }
{*****************************************************}
{                                                     }
{   TExcel is provided free of charge as so long as   }
{   it is not in commercial use. When it produces     }
{   income for you, please send me some portion of    }
{   your income (at least $50).         Thank you.    }
{                                                     }
{*****************************************************}
unit Excels;

interface

uses WinTypes, Forms, Classes, DdeMan, SysUtils;

type
  TExcel = class(TComponent)
  private
      FMacro     : string;
      FMacroPath : string;
      FDDE       : TDdeClientConv;
      FConnected : Boolean;
      FExeName   : string;
      FDecimals  : Integer;
      FOnClose   : TNotifyEvent;
      FOnOpen    : TNotifyEvent;
      FBatch     : Boolean;
      FMin       : Integer;
      FMax       : Integer;
      FFirstRow  : Integer;
      FFirstCol  : Integer;
      FLastCol   : Integer;
      FLines     : TStrings;    { using TStringList }
      FCells     : TStrings;    { using TStringList }
      FLastTime  : TDateTime;
      FCounter   : Integer;
      FLimit     : Integer;
    procedure SetExeName(const Value: string);
    procedure SetConnect(const Value: Boolean);
    procedure SetMin    (const Value: Integer);
    procedure SetMax    (const Value: Integer);
    function GetSelection: string;
    function GetReady: Boolean;
  protected
    procedure DoRect(Top, Left, Bottom, Right: Integer;
                     Data: TStrings; Request: Boolean);
    procedure CheckConnection; virtual;
    procedure LinkSystem;
    procedure OpenLink(Sender: TObject);
    procedure ShutDown(Sender: TObject);
    procedure LocateExcel; virtual;
    procedure CheckLimit; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Connect;
    procedure Disconnect;
    procedure Wait;
    procedure ProcessMessages; virtual;
    function Request(const Item: string): string;
    procedure Exec  (const Cmd : string);
    procedure Run   (const Mn  : string);
    procedure Select(Row, Col: Integer);
    procedure PutStr(Row, Col: Integer; const s: string);
    procedure PutExt(Row, Col: Integer; e: Extended); virtual;
    procedure PutInt(Row, Col: Integer; i: Longint);  virtual;
    procedure PutDay(Row, Col: Integer; d: TDateTime);virtual;
    procedure BatchStart(FirstRow, FirstCol: Integer);
    procedure BatchCancel;
    procedure BatchSend;
    procedure GetBooks(Books: TStrings);
    procedure GetSheets(const Book: string; Sheets: TStrings);
    procedure GetRange(R: TRect; Lines: TStrings);
    function  GetCell(Row, Col: Integer): string;
    procedure OpenMacroFile(const Fn: string; Hide: Boolean);
    procedure CloseMacroFile;
    property DDE: TDdeCLientConv   read FDDE;
    property Connected: Boolean    read FConnected write SetConnect;
    property Ready    : Boolean    read GetReady;
    property Selection: string     read GetSelection;
    property Lines    : TStrings   read FLines;
    property FirstRow : Integer    read FFirstRow;
    property FirstCol : Integer    read FFirstCol;
    property LastCol  : Integer    read FLastCol   write FLastCol;
    property BatchOn  : Boolean    read FBatch;
  published
    property ExeName  : string     read FExeName   write SetExeName;
    property ExecLimit: Integer    read FLimit     write FLimit;
    property Decimals : Integer    read FDecimals  write FDecimals;
    property BatchMin : Integer    read FMin       write SetMin;
    property BatchMax : Integer    read FMax       write SetMax;
    property OnClose: TNotifyEvent read FOnClose   write FOnClose;
    property OnOpen : TNotifyEvent read FOnOpen    write FOnOpen;
  end;

procedure Register;

{$I EXCELS.INC}       { Message strings to be nationalized }

implementation
uses WinProcs, ShellAPI;

procedure Register;
begin
  RegisterComponents('Liska', [TExcel]);
end;

{ TExcel }

constructor TExcel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if not (csDesigning in ComponentState) then
  begin
    FDDE := TDdeClientConv.Create(nil);
    FDDE.ConnectMode := ddeManual;
    FDDE.OnOpen  := OpenLink;
    FDDE.OnClose := ShutDown;
  end;
  SetExeName('Excel');
  FLastTime := Now;
  FLimit    := 99;
  FDecimals := 2;
  FBatch := False;
  FMin := 200;
  FMax := 250;
end;

destructor TExcel.Destroy;
begin
  if not (csDesigning in ComponentState) then FDDE.Free;
  if FLines <> nil then FLines.Free;
  if FCells <> nil then FCells.Free;
  inherited Destroy;
end;

procedure TExcel.SetExeName(const Value: string);
begin
  Disconnect;
  FExeName := ChangeFileExt(Value, '');
  if not (csDesigning in ComponentState) then
    FDDE.ServiceApplication := FExeName;
end;

procedure TExcel.SetConnect(const Value: Boolean);
begin
  if FConnected = Value then Exit;
  if Value then Connect
           else Disconnect;
end;

procedure TExcel.SetMin(const Value: Integer);
begin
  if Value > FMax then FMin := FMax
                  else FMin := Value;
end;

procedure TExcel.SetMax(const Value: Integer);
begin
  if Value < FMin then FMax := FMin
                  else FMax := Value;
end;

function TExcel.GetSelection: string;
  var
      i : Integer;
begin
  Result := Request('Selection');
  i := Pos('''', Result);
  while i > 0 do
  begin
    Delete(Result, i, 1);
    i := Pos('''', Result);
  end
end;

function TExcel.GetReady: Boolean;
begin
  Result := 'Ready' = Request('Status');
end;

procedure TExcel.DoRect(Top, Left, Bottom, Right: Integer;
                        Data: TStrings; Request: Boolean);
  var
      i : Integer;
      Sel, Item : string;
      RowMark,
      ColMark : Char;
      Reply : PChar;

  procedure Synchronize;
  begin
    ProcessMessages;
    Reply := FDDE.RequestData(Copy(Item, 1, Pos(':', Item)-1));
    StrDispose(Reply);           { Just to wait for Excel }
  end;

begin
  Select(1, 1);
  Sel := Selection;
  i := Pos('!', Sel);
  if i = 0 then raise Exception.Create(msgNoTable);
  RowMark := Sel[i+1];           { Some nationalized version }
  ColMark := Sel[i+3];           {  using other then R and C }
  FDDE.OnOpen  := nil;
  FDDE.OnClose := nil;           { Disable event handlers }
try
  FDDE.SetLink('Excel', Copy(Sel, 1, i-1));  { Topic = Sheet name }
  if not FDDE.OpenLink then
    raise Exception.Create(msgNoLink);
  Item := Format('%s%d%s%d:%s%d%s%d', [RowMark, Top, ColMark, Left,
                                    RowMark, Bottom, ColMark, Right]);
  ProcessMessages;
  if Request then
  begin
    Reply := FDDE.RequestData(Item);
    if Reply <> nil then Data.SetText(Reply);
    StrDispose(Reply);
  end
  else if FDDE.PokeDataLines(Item, Data) then
    Synchronize
  else if FDDE.PokeDataLines(Item, Data) then
    Synchronize                  { Sometimes first call fails }
  else
    raise Exception.Create('"Block '+ Item + msgNotAccepted);
finally
  LinkSystem;
  if not FDDE.OpenLink
     and Assigned(FOnClose) then FOnClose(Self);
  FDDE.OnOpen  := OpenLink;
  FDDE.OnClose := ShutDown;      { Enable event handlers }
end; end;

procedure TExcel.LinkSystem;
begin
  FDDE.SetLink('Excel', 'System');
end;

procedure TExcel.CheckConnection;
begin
  if Connected then ProcessMessages
               else raise Exception.Create(msgNoConnect);
end;

procedure TExcel.OpenLink(Sender: TObject);
begin
  FConnected := True;
  if Assigned(FOnOpen) then FOnOpen(Self);
end;

procedure TExcel.ShutDown(Sender: TObject);
begin
  FConnected := False;
  if Assigned(FOnClose) then FOnClose(Self);
end;

procedure TExcel.LocateExcel;
{$IFDEF WIN32}
  const
      BuffSize = 511;
{$ELSE}
  procedure ConvertLongFn(var Fn : string);
    var
	Version : Word;
        Pfn : Pointer;
  begin
    if GetWinFlags and $4000 <> 0 then Exit;    { WinNT+ }
    Version := LoWord(GetVersion);
    if Hi(Version) >= 95 then                   { Win95+ }
    begin
    { Convert 8.3 path from Long File Names under Win95
      based on the idea of Mieczyslaw Dyla  malwa@elb.pl }
      StrPCopy(@Fn, Fn);
      Pfn := Addr(Fn);
      asm
        push ds
        mov ax, 7160h
        mov cl, 1
        mov ch, 0
        les di,[DWORD PTR Fn]
        lds si,[Pfn];
        int 21h
        pop ds
      end;
      Fn := StrPas(@Fn)
    end
  end;

  const
      BuffSize = 255;
{$ENDIF}
      ExcelExe = 'EXCEL.EXE';
  var
      Buff: array[0..BuffSize] of Char;
      Fn  : string;
      Len : Longint;
begin
  Len := BuffSize;
  StrPCopy(Buff, '.XLS');
  if (RegQueryValue(HKEY_CLASSES_ROOT, Buff, Buff, Len)
    = ERROR_SUCCESS) and (StrScan(Buff,'E') <> nil) then
  begin
    StrCat(Buff, '\Shell\Open\Command');
    Len := BuffSize;
    if RegQueryValue(HKEY_CLASSES_ROOT, Buff, Buff, Len)
      = ERROR_SUCCESS then
    begin
      Fn := StrPas(StrUpper(Buff));
      Len := Pos(ExcelExe, Fn);
      Delete(Fn, Len + Length(ExcelExe), BuffSize);
      if Buff[0] = '"' then Delete(Fn, 1, 1);
{$IFNDEF WIN32}
      ConvertLongFn(Fn);         { Thanks to Mieczyslaw Dyla }
{$ENDIF}
      if FileExists(Fn) then ExeName := Fn
    end
  end
end;

procedure TExcel.CheckLimit;
  var
      Work : Extended;
begin
  Inc(FCounter);
  if FCounter > FLimit then
  begin
    FCounter := 0;
    Work := FLastTime;
    FLastTime := Now;
    Work := FLastTime - Work;
    if Work < 2E-5 then Wait;    { 1.728 sec }
  end;
end;

procedure TExcel.Connect;
begin
  if FConnected then Exit;
  LinkSystem;
  if FDDE.OpenLink then Exit;
  LocateExcel;
  if FDDE.OpenLink then Exit;    { Try again }
  if FDDE.OpenLink then Exit;    { Once more }
  raise Exception.Create(msgNoExcel +#13+ ExeName);
end;

procedure TExcel.Disconnect;
begin
  if FConnected then FDDE.CloseLink;
end;

procedure TExcel.Wait;
  const
        TryCount = 64;
  var
      i : Integer;
begin
  i := 0;
  repeat
    ProcessMessages;
    if Ready then Break;         { Waiting for Excel }
    Inc(i);
  until i = TryCount;
  if i = TryCount then
    raise Exception.Create(msgNoRespond);
end;

procedure TExcel.ProcessMessages;
begin
  Application.ProcessMessages;
end;

function TExcel.Request(const Item: string): string;
  var
      Reply : PChar;
begin
  CheckConnection;
  Reply := FDDE.RequestData(Item);
  if Reply = nil then Result := msgNoReply
                 else Result := StrPas(Reply);
  StrDispose(Reply);
end;

procedure TExcel.Exec(const Cmd: string);
  var
      a : array[0..555] of Char;
begin
  CheckConnection;
  CheckLimit;
  StrPCopy(a, Cmd);
  if FDDE.ExecuteMacro(a, False) then
    ProcessMessages
  else
  begin
    Wait;
    if FDDE.ExecuteMacro(a, True) then
      while FDDE.WaitStat do ProcessMessages
    else
      raise Exception.Create('"' + Cmd + msgNotAccepted);
  end
end;

procedure TExcel.Run(const Mn: string);
begin
  if FMacro = '' then
    raise Exception.Create(msgNoMacro);
  Exec('[RUN("' + FMacro + '!' + Mn + '";FALSE)]');
end;

procedure TExcel.Select(Row, Col: Integer);
begin
  Exec(Format('[SELECT("R%dC%d")]', [Row, Col]));
end;

procedure TExcel.PutStr(Row, Col: Integer; const s: string);
  procedure SendMin;
    var
        i : Integer;
  begin
    FCells.Clear;
    for i:=0 to FMin-1 do
    begin
      FCells.Add(FLines[0]);     { FCells as work space }
      FLines.Delete(0);
    end;
    DoRect(FFirstRow, FFirstCol, FFirstRow + FMin - 1, FLastCol,
           FCells, False);
    Inc(FFirstRow, FMin);
  end;

  procedure DoBatch;
    var
        i, j, Index : Integer;
        Line : string;
  begin
    Index := Row - FFirstRow;                { Index to modify }
    if Index >= Lines.Count then
      for i:=Lines.Count to Index do         { Expand if needed }
        Lines.Add('');
    if Lines.Count > FMax then               { Send if needed }
    begin
      SendMin;
      Index := Row - FFirstRow;              { Recalc Index }
    end;
    if Col > FLastCol then FLastCol := Col;  { Adjust to max }
    Line := Lines[Index];
    FCells.Clear;                            { Empty FCells }
    j := 1;
    for i:=1 to Length(Line) do              { Line disasseble }
      if Line[i] = #9 then begin
                             FCells.Add(Copy(Line, j, i-j));
                             j := i + 1;
                           end;
    FCells.Add(Copy(Line, j, Length(Line) + 1 - j));
    if FCells.Count < Col - FFirstCol + 1 then
      for i:=FCells.Count to Col-FFirstCol do{ Expand if needed }
        FCells.Add('');
    FCells[Col-FFirstCol] := s;              { Replace cell }
    Line := FCells[0];
    for i:=1 to FCells.Count-1 do            { Line reasseble }
      Line := Line + #9 + FCells[i];
    Lines[Index] := Line;                    { Replace line }
  end;

begin           { TExcel.PutStr }
  if BatchOn and (Col >= FFirstCol) and (Row >= FFirstRow) then
    DoBatch
  else
    Exec(Format('[FORMULA("%s","R%dC%d")]', [s, Row, Col]));
end;

procedure TExcel.PutExt(Row, Col: Integer; e: Extended);
begin
  PutStr(Row, Col, Format('%0.*f', [Decimals, e]));
end;

procedure TExcel.PutInt(Row, Col: Integer; i: Longint);
begin
  PutStr(Row, Col, IntToStr(i));
end;

procedure TExcel.PutDay(Row, Col: Integer; d: TDateTime);
begin
  PutStr(Row, Col, DateToStr(d));
end;

procedure TExcel.BatchStart(FirstRow, FirstCol: Integer);
begin
  if FLines = nil then FLines := TStringList.Create
                  else FLines.Clear;
  if FCells = nil then FCells := TStringList.Create
                  else FCells.Clear;
  FFirstRow := FirstRow;
  FFirstCol := FirstCol;
  FLastCol  := FirstCol;
  FBatch := True;
end;

procedure TExcel.BatchCancel;
begin
  if FLines <> nil then FLines.Free;
  if FCells <> nil then FCells.Free;
  FLines := nil;
  FCells := nil;
  FBatch := False;
end;

procedure TExcel.BatchSend;
begin
  if (FLines <> nil) and (FLines.Count > 0) then
    DoRect(FFirstRow, FFirstCol, FFirstRow + FLines.Count - 1,
           FLastCol, FLines, False);
  BatchCancel
end;

procedure TExcel.GetBooks(Books: TStrings);
  var
      Reply, P : PChar;
      B : array[0..80] of Char;
      Name : string;
      Len : Integer;
begin
  CheckConnection;
  Reply := FDDE.RequestData('Topics');
  P := Reply;
  if Reply <> nil then
    repeat
      P := StrScan(P, '[');
      if P <> nil then
      begin
        Inc(P);
        Len := StrScan(P, ']') - P;
        Name := StrPas(StrLCopy(B, P, Len));
        if (Name <> ':') and(Books.IndexOf(Name) < 0) then
           Books.Add(Name);
      end;
    until P = nil;
  StrDispose(Reply);
end;

procedure TExcel.GetSheets(const Book: string; Sheets: TStrings);
  var
      Reply, P, Tab, F : PChar;
      Sheet : string;
      Len, n : Integer;
      B, U : array[0..80] of Char;
begin
  CheckConnection;
  Reply := FDDE.RequestData('Topics');
  StrUpper(StrPCopy(B, Book));
  P := Reply;
  if Reply <> nil then
    repeat
      Tab := StrScan(P, #9);
      if Tab = nil then Len := StrLen(P)
                   else Len := Tab-P;
      StrUpper(StrLCopy(U, P, Len));
      F := StrPos(U, B);
      if F <> nil then
      begin
        n := Length(Book) + F - U + 1;
        Inc(P, n);
        Dec(Len, n);
        Sheet := StrPas(StrLCopy(U, P, Len));
        Sheets.Add(Sheet);
      end;
      P := Tab + 1
    until Tab = nil;
  StrDispose(Reply);
end;

procedure TExcel.GetRange(R: TRect; Lines: TStrings);
begin
  DoRect(R.Top, R.Left, R.Bottom, R.Right, Lines, True);
end;

function TExcel.GetCell(Row, Col: Integer): string;
  var
      Data : TStringList;
begin
  Result := msgNoReply;
  Data := TStringList.Create;
try
  DoRect(Row, Col, Row, Col, Data, True);
  if Data.Count = 1 then Result := Data[0];
finally
  Data.Free
end; end;

procedure TExcel.OpenMacroFile(const Fn: string; Hide: Boolean);
begin
  if FMacroPath = Fn then Exit;
  CloseMacroFile;
  Exec('[OPEN("' + Fn + '")]');
  if Hide then  Exec('[HIDE()]');
  FMacroPath := Fn;
  FMacro := ExtractFileName(Fn);
end;

procedure TExcel.CloseMacroFile;
begin
  if FMacro <> '' then
  try
    Exec('[UNHIDE("' + FMacro + '")]');
    Exec('[ACTIVATE("' + FMacro + '")]');
    Exec('[CLOSE(FALSE)]');
  finally
    FMacro := '';
    FMacroPath := '';
  end;
end;

end.
