//****************************************************************************//
//                           Created By Daniel Muncy                          //
//                           For software protection means                    //
//                           Date: 10/17/2008                                 //
//                                                                            //
//          This component will verify that only the specified computer is    //
//          runing the control software.                                      //
//****************************************************************************//
unit SNHDChecker;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;
type
  TSNHDChecker = class(TComponent)
  private
    { Private declarations }
//    Key128 : TKey128;
    HardDriveSN : TStringList;
    FEnabled : Boolean;
    FSNFileName : String;
    FPassPhrase : String;
    FSNOK : Boolean;
    FVersion : String;
    FMatchedSerailNumber : String;
    FJobNumber : Single;
  protected
    { Protected declarations }
    Procedure SetSerialNumberFile(Value : String);
    Procedure SetEnabled(Value : Boolean);
    Function ValidateSNs : Boolean;
    Procedure SetVersion(Value : String);
    function GetDiskSN(DiskNo : LongInt) : String;
  public
    { Public declarations }
    Constructor Create(AOwner : TComponent); Override;
    Destructor Destroy; Override;
    property InstalledHD[DiskNo : LongInt] : String read GetDiskSN;
  published
    { Published declarations }
    property Version : String read FVersion write SetVersion;
    property Enabled : Boolean read FEnabled write SetEnabled default FALSE;
    property SeiralNumberFile : String read FSNFileName write SetSerialNumberFile;
    property SerialNumberFile : String read FSNFileName write SetSerialNumberFile;
    property PassPhrase : String read FPassPhrase write FPassPhrase;
    property SerialNumberOK : Boolean read FSNOK;
    property MatchedSerialNumber : String read FMatchedSerailNumber;
    property JobNumber : Single read FJobNumber write FJobNumber;

  end;

procedure Register;

implementation
{_R SNHDChecker.dcr}

uses   TMSIGetDiskSerial, LbString, LbCipher;

var
  Key128 : TKey128;

procedure Register;
begin
  RegisterComponents('TMSI',[TSNHDChecker]);
end; // Register

Constructor TSNHDChecker.Create(AOwner : TComponent);
begin
  Inherited Create(AOwner);
  FPassPhrase := 'TMSI8674';
  FEnabled := False;
  FSNFileName := '';
  FSNOK := False;
  FVersion := '1.2.0';
  FMatchedSerailNumber := 'N/A';
  FJobNumber := 0;
  fillchar(Key128, SizeOf(Key128),#0); {initialize Key}
  GenerateLMDKey(Key128,SizeOf(Key128),FPassPhrase); {Generate Key}
  HardDriveSN := TStringList.Create;
end; // TSNHDChecker.Create

Destructor TSNHDChecker.Destroy;
begin
  FEnabled := False;
  HardDriveSN.Free;
  Inherited Destroy;
end; // TSNHDChecker.Destroy

Procedure TSNHDChecker.SetSerialNumberFile(Value : String);
begin
  FSNFileName := Value;
  if FEnabled and FileExists(FSNFileName) then
  begin
    FSNOK := False;
    HardDriveSN.LoadFromFile(FSNFileName);
    FSNOK := ValidateSNs;
  end; // If
end; // TSNHDChecker.SetSerialNumberFile

Procedure TSNHDChecker.SetEnabled(Value : Boolean);
begin
  FEnabled := Value;
  if Not FEnabled then
  begin
    FSNOK := True;
  end
  else
  begin
    if (FSNFileName <> '') and FileExists(FSNFileName) then
    begin
      FSNOK := False;
      HardDriveSN.LoadFromFile(FSNFileName);
      FSNOK := ValidateSNs;
    end; // If
  end; // If
end; // TSNHDChecker.SetEnabled

Function TSNHDChecker.ValidateSNs : Boolean;
var
  i : Integer;
  CurrentDiskSN : String;
  CurrentDiskSNEncrypted : String;
begin
  Result := False;
  GenerateLMDKey(Key128,SizeOf(Key128),FPassPhrase); {Generate Key}
  CurrentDiskSN := GetDiskSN(0);
  CurrentDiskSNEncrypted := TripleDESEncryptStringEx(CurrentDiskSN,Key128,True);
  for i := 0 to (HardDriveSN.Count - 1) do
  begin
    if CurrentDiskSNEncrypted = HardDriveSN.Strings[i] then
    begin
      Result := True;
      FMatchedSerailNumber := TripleDESEncryptStringEx(CurrentDiskSNEncrypted,Key128,False);
      Break;
    end; // If
  end; // For i
end; // TSNHDChecker.ValidateSNs

Procedure TSNHDChecker.SetVersion(Value : String);
begin
  // Do nothing...
end; // TSNHDChecker.SetVersion

function TSNHDChecker.GetDiskSN(DiskNo : LongInt) : String;
begin
  Result := string(GetSerialNumber(DiskNo));
end; // TSNHDChecker.GetDiskSN

end.
