{$ifndef Package_Build}
{$I Conditionals.inc}
{$endif}
unit SerialNumberTracker;

interface

uses
  Windows, Messages, SysUtils, Classes, SNHDChecker, DAP_Inspector;

type
  {$IFDEF DELPHIXE}
  // When in DelphiXE or any unicode style IDE ANSI types must be used.
  TPChar = PANSIChar;
  TChar = ANSIChar;
  TString = ANSIString;
  {$ELSE}
  // When in Delphi 3 standard types are OK to use.
  TPChar = PChar;
  TChar = Char;
  TString = String;
  {$ENDIF}


  TSNCheck = (chk_NONE,chk_HD,chk_DAP,chk_MAC);
  TMySet = Set of 0..15;
  TDiskEnum = TMySet;
  TMACEnum = TMySet;
  TSNSearchOptions = Set Of TSNCheck;

  TSNCheckFailed = procedure(Sender : TObject; Failed_Check : TSNCheck) of Object;

  TSNTracker = class(TComponent)
    private
      FOnSNCheckPassed : TNotifyEvent;
      FOnSNCheckFailed : TSNCheckFailed;
      FDAPQuery : TDAP_Inspector;
      FVersion : String;
      FEnabled : Boolean;
      FJobNumber : Single;
      FAdapterNo : LongInt;
      FPassPhrase : String;
      FSNFileName : String;
      FSNToCheck : TSNSearchOptions;
      FSNList : TStringList;
      FDiskEnum : TDiskEnum;
      FMacEnum : TMacEnum;
      FChecksThatPassed : Array[chk_HD..chk_MAC] of Boolean;
    protected
      procedure SetVersion(Value : String);
      procedure SetSNFileName(Value : String);
      function GetAdapterInfo(Lana : TChar) : String;
      function GetMACAddress(AdapterNo : LongInt) : String;
      procedure SetPassPhrase(Value : String);
      function FoundKeyInSNFile(PassPhrase : String; SearchFor : String; SNFileName : String) : Boolean;
      function SearchHDKeys(HDKeysToFind : TStringList) : Boolean;
      function SearchDAPKeys(DAPKeysToFind : TStringList) : Boolean;
      function SearchMACKeys(MACKeysToFind : TStringList) : Boolean;
      function GetDiskSN(DiskNo : LongInt) : String;
      function GetDAPSerialNumber(DAPLoc : String) : String;
      function SelectedSNsFound : Boolean;
      function BitCheck(BitsToCheck : TMySet; ValueToCheck : Word) : Boolean;
    public
      constructor Create(AOwner : TComponent); Override;
      destructor Destroy; Override;
      function ValidateSerialNumbers : Boolean;
      function ListMACAddresses : TStringList;
      property MACsToCheck : TMacEnum read FMACEnum write FMACEnum;
      property DiskNoToCheck : TDiskEnum read FDiskEnum write FDiskEnum;
      property InstalledHD[DiskNo : LongInt] : String read GetDiskSN;
      property MACAddress[AdapterNo : LongInt] : String read GetMACAddress;
      property DAPSerialNo[DAPLoc : String] : String read GetDAPSerialNumber;
    published
      property Version : String read FVersion write SetVersion;
      property DAP_Inspector : TDAP_Inspector read FDAPQuery write FDAPQuery;
      property PassPhrase : String read FPassPhrase write SetPassPhrase;
      property JobNumber : Single read FJobNumber write FJobNumber;
      property SerialNumbersToCheck : TSNSearchOptions read FSNToCheck write FSNToCheck;
      property SerialNumberFile : String read FSNFileName write SetSNFileName;

      property OnSerialNumberCheckPassed : TNotifyEvent read FOnSNCheckPassed write FOnSNCheckPassed;
      property OnSerialNumberCheckFailed : TSNCheckFailed read FOnSNCheckFailed write FOnSNCheckFailed;
  end; // TSNTracker

//  procedure Register;

implementation
{_R SerialNumberTracker.dcr}

uses NB30, STRegINI, TMSIGetDiskSerial, LbString, LbCipher;

// procedure Register;
// begin
//   RegisterComponents('TMSI',[TSNTracker]);
// end; // Register

constructor TSNTracker.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FEnabled := False;
  FJobNumber := 0;
  FAdapterNo := 0;
  FSNFileName := '';
  FVersion := '1.0.1';
  FSNToCheck := [chk_NONE];
  FDiskEnum := [];
  FMacEnum := [];
  FPassPhrase := 'TMSI8674';
  FDAPQuery := Nil;
  FSNList := TStringList.Create;
  FillChar(FChecksThatPassed,SizeOf(FChecksThatPassed),#0);
end; // TSNTracker.Create

destructor TSNTracker.Destroy;
begin
  FSNList.Free;
  inherited Destroy;
end; // TSNTracker.Destroy

procedure TSNTracker.SetVersion(Value : String);
begin
  // Do nothing...
end; // TSNHDChecker.SetVersion

function TSNTracker.ValidateSerialNumbers : Boolean;
var
  i : TSNCheck;
  j : Byte;
  TmpList : TStringList;
begin
  FillChar(FChecksThatPassed,SizeOf(FChecksThatPassed),#0);
  if FileExists(FSNFileName)then
  begin
    for i := chk_HD to chk_MAC do
    begin
      if (i in FSNToCheck) then
      begin
        case i of
          chk_HD   : begin
                       TmpList := TStringList.Create;
                       TmpList.Clear;
                       for j := 0 to 15 do
                       begin
                         if (j in FDiskEnum) then
                           TmpList.Add(GetDiskSN(j));
                       end; // For j
                       FChecksThatPassed[chk_HD] := SearchHDKeys(TmpList);
                       TmpList.Free;
                     end; // chk_HD
          chk_DAP  : begin
                       if Assigned(FDAPQuery) then
                       begin
                         TmpList := FDAPQuery.ListDAPsOnServer;
                         FChecksThatPassed[chk_DAP] := SearchDAPKeys(TmpList);
                         TmpList.Free;
                       end
                       else
                         FChecksThatPassed[chk_DAP] := False;
                     end; // chk_DAP
          chk_MAC  : begin
                       TmpList := TStringList.Create;
                       TmpList.Clear;
                       for j := 0 to 15 do
                       begin
                         if (j in FMACEnum) then
                           TmpList.Add(GetMACAddress(j));
                       end; // For j
                       FChecksThatPassed[chk_MAC] := SearchMACKeys(TmpList);
                       TmpList.Free;
                     end; // chk_MAC
        end; // Case
        if Not FChecksThatPassed[i] then
          Break;
      end; // If
    end; // for i
  end; // If
  Result := SelectedSNsFound;
end; // TSNTracker.ValidateSerialNumbers

function TSNTracker.ListMACAddresses : TStringList;
var
  AdapterNo : LongInt;
  AdapterID : String;
begin
  Result := TStringList.Create;
  Result.Clear;
  for AdapterNo := 0 to Max_LANA do
  begin
    AdapterID := GetMACAddress(AdapterNo);
    if (AdapterID <> 'mac not found') then
    begin
      if (Result.IndexOf(AdapterID) = -1) then
        Result.Add(AdapterID);
    end
    else
      Break;
  end; // For i
end; // TSNTracker.ListMACAddresses

procedure TSNTracker.SetSNFileName(Value : String);
begin
  FSNFileName := Value;
end; // TSNTracker.SetSNFileName

function TSNTracker.GetAdapterInfo(Lana: TChar): String;
var
 Adapter: TAdapterStatus;
 NCB: TNCB;
 i : LongInt;
begin
 result := '';
 FillChar(NCB, SizeOf(NCB), 0);
 NCB.ncb_command := Char(NCBRESET);
 NCB.ncb_lana_num := Lana;
 if Netbios(@NCB) <> Char(NRC_GOODRET) then
 begin
   Result := 'mac not found';
   Exit;
 end;

 FillChar(NCB, SizeOf(NCB), 0);
 NCB.ncb_command := Char(NCBASTAT);
 NCB.ncb_lana_num := Lana;
 NCB.ncb_callname := '*';

 FillChar(Adapter, SizeOf(Adapter), 0);
 NCB.ncb_buffer := @Adapter;
 NCB.ncb_length := SizeOf(Adapter);
 if Netbios(@NCB) <> Char(NRC_GOODRET) then
 begin
   Result := 'mac not found';
   Exit;
 end;
 for i := 0 to 5 do
   Result :=  Result + IntToHex(Byte(Adapter.adapter_address[i]), 2);
end;

function TSNTracker.GetMACAddress(AdapterNo : LongInt) : String;
var
 AdapterList: TLanaEnum;
 NCB: TNCB;
begin
 FillChar(NCB, SizeOf(NCB), 0);
 NCB.ncb_command := Char(NCBENUM);
 NCB.ncb_buffer := @AdapterList;
 NCB.ncb_length := SizeOf(AdapterList);
 Netbios(@NCB);
 if Byte(AdapterList.length) > 0 then
   Result := GetAdapterInfo(AdapterList.lana[AdapterNo])
 else
   Result := 'mac not found';
end;

procedure TSNTracker.SetPassPhrase(Value : String);
begin
  if (Value <> '') then
    FPassPhrase := UpperCase(Value);
end; // TSNTracker.SetPassPhrase

function TSNTracker.FoundKeyInSNFile(PassPhrase : String; SearchFor : String; SNFileName : String) : Boolean;
var
  Key128 : TKey128;
  SNFile : TStringList;
  i : LongInt;
  EncryptedKey : String;
begin
  Result := False;
  fillchar(Key128, SizeOf(Key128),#0); {initialize Key}
  GenerateLMDKey(Key128,SizeOf(Key128),PassPhrase); {Generate Key}
  if FileExists(SNFileName) then
  begin
    SNFile := TStringlist.Create;
    SNFile.LoadFromFile(SNFileName);
    EncryptedKey := TripleDESEncryptStringEx(SearchFor,Key128,True);
    for i := 0 to (SNFile.Count - 1) do
    begin
      if (EncryptedKey = SNFile.Strings[i]) then
      begin
        Result := True;
        Break;
      end; // If
    end; // For i
    SNFile.Free;
  end; // If
end; // TSNTracker.FoundKeyInSNFile

function TSNTracker.SearchHDKeys(HDKeysToFind : TStringList) : Boolean;
var
  i : LongInt;
  CheckVal : SmallInt;
begin
  CheckVal := 0;
  if (HDKeysToFind.Count > 0) then
  begin
    for i := 0 to (HDKeysToFind.Count - 1) do
    begin
      if (FoundKeyInSNFile(FPassPhrase,HDKeysToFind.Strings[i],FSNFileName)) then
        CheckVal := CheckVal + (1 SHL i);
    end; // For i
  end; // If
  Result := BitCheck([0..(HDKeysToFind.Count - 1)],CheckVal);
end; // TSNTracker.SearchHDKeys

function TSNTracker.SearchDAPKeys(DAPKeysToFind : TStringList) : Boolean;
var
  i : LongInt;
  CheckVal : SmallInt;
  DAPSNToFind : String;
begin
  Result := False;
  CheckVal := 0;
  if (DAPKeysToFind.Count > 0) then
  begin
    for i := 0 to (DAPKeysToFind.Count - 1) do
    begin
      with FDAPQuery do
      begin
        DAPLocation := format('%s\%s',[ServerLocation,DAPKeysToFind.Strings[i]]);
        DAPSNToFind := DAPSerialNum
      end; // With
      if (DAPSNtoFind <> '') then
      begin
        if (FoundKeyInSNFile(FPassPhrase,DAPSNToFind,FSNFileName)) then
          CheckVal := CheckVal + (1 SHL i);
      end; // If
    end; // For i
    Result := BitCheck([0..(DAPKeysToFind.Count - 1)],CheckVal);
  end; // If
end; // TSNTracker.SearchDAPKeys

function TSNTracker.SearchMACKeys(MACKeysToFind : TStringList) : Boolean;
var
  i : LongInt;
  CheckVal : SmallInt;
begin
  CheckVal := 0;
  if (MACKeysToFind.Count > 0) then
  begin
    for i := 0 to (MACKeysToFind.Count - 1) do
    begin
      if (FoundKeyInSNFile(FPassPhrase,MACKeysToFind.Strings[i],FSNFileName)) then
        CheckVal := CheckVal + (1 SHL i);
    end; // For i
  end; // If
  Result := BitCheck([0..(MACKeysToFind.Count - 1)],CheckVal);
end; // TSNTracker.SearchMACKeys

function TSNTracker.GetDiskSN(DiskNo : LongInt) : String;
var
  PStr : PWideChar;
begin
  Result := String(GetSerialNumber(DiskNo));
//  Result := String(GetSerialNumber(DiskNo));
end; // TSNHDChecker.GetDiskSN

function TSNTracker.GetDAPSerialNumber(DAPLoc : String) : String;
begin
  if Assigned(FDAPQuery) then
  begin
    with FDAPQuery do
    begin
      DAPLocation := DAPLoc;
      Result := DAPSerialNum;
    end; // With
  end; // If
end; // TSNTracker.GetDAPSerialNumber

function TSNTracker.SelectedSNsFound : Boolean;
var
  i : TSNCheck;
begin
  Result := True;
  for i := Low(TSNCheck) to High(TSNCheck) do
  begin
    if (i in FSNToCheck) then
    begin
      if (i <> chk_NONE) then
      begin
        if Not FChecksThatPassed[i] then
        begin
          Result := False;
          if Assigned(FOnSNCheckFailed) then
            FOnSNCheckFailed(Self,i);
          Break;
        end; // If
      end; // If
    end; // If
  end; // For i
  if Result and Assigned(FOnSNCheckPassed) then
    FOnSNCheckPassed(Self);
end; // TSNTracker.SelectedSNsFound

function TSNTracker.BitCheck(BitsToCheck : TMySet; ValueToCheck : Word) : Boolean;
var
  i : SmallInt;
  TempResult : Boolean;
begin
  TempResult := True;
  for i := 0 to 15 do
  begin
    if (i in BitsToCheck) then
      TempResult := TempResult and ((ValueToCheck SHR i  and 1) = 1);
  end; // For i
  Result := TempResult;
end;  // TSNTracker.BitCheck

end.
