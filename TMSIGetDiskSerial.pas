  {
--------------------------------------------------------------------------------
Author   : Hingman
Corp     : DevLib,Inc.
Creation : 2002.09.05
History  :

for more S.M.A.R.T. ioctl              
http://www.microsoft.com/hwdev/download/respec/iocltapi.rtf
--------------------------------------------------------------------------------
}
                                                
unit TMSIGetDiskSerial;

interface

uses
  WinTypes, SysUtils;

type
  DiskInfo = packed record
    SerialNumber: array[0..19] of Char;
    ModelNumber: array[0..39] of Char;
    RevisionNo: array[0..7] of Char;
    BufferSize: Integer;
    Cylinders: Integer;
    Heads: Integer;
    Sectors: Integer;
  end;

//function export
function GetIdeDiskInfo(DiskNo: Byte; var ds: DiskInfo): LongBool;// stdcall; export;
function GetIdeDiskSerialNumberWithAdminRight(DiskNo: Byte; var ds: DiskInfo): LongBool;
function GetIdeDiskSerialNumberWithZeroRight(DiskNo: Byte; var ds: DiskInfo): LongBool;

//Add by hingman, 2005-08-10
function GetSerialNumber(DiskNo: Byte): String;// stdcall; export;
function GetModelNumber(DiskNo: Byte): String;// stdcall; export;
function GetRevisionNo(DiskNo: Byte): String;// stdcall; export;
function GetBufferSize(DiskNo: Byte): Integer;// stdcall; export;
function GetCylinders(DiskNo: Byte): Integer;// stdcall; export;
function GetHeads(DiskNo: Byte): Integer;// stdcall; export;
function GetSectors(DiskNo: Byte): Integer;// stdcall; export;

implementation

function GetIdeDiskInfo(DiskNo: Byte; var ds: DiskInfo): LongBool;
//through two way to get serial number.
var
  i: Byte;
var
  bReadOk: Boolean;
begin
  bReadOk:= False;
  bReadOk:= GetIdeDiskSerialNumberWithZeroRight(DiskNo, ds);
  if not bReadOk then
    bReadOk:= GetIdeDiskSerialNumberWithAdminRight(DiskNo, ds);

  //when single hard disk and get faild, switch the DiskNo to get serialnumber.
  if (DiskNo = 0) and (not bReadOk) then
  begin
    for i:= 0 to 9 do
    begin
      bReadOk := GetIdeDiskSerialNumberWithZeroRight(i, ds);
      if not bReadOk then
        bReadOk := GetIdeDiskSerialNumberWithAdminRight(i, ds);
      if bReadOk then
      begin
        Result:= True;
        Break;
      end;
    end;
  end;
end;

function GetIdeDiskSerialNumberWithAdminRight(DiskNo: Byte; var ds: DiskInfo): LongBool;
const
  IDENTIFY_BUFFER_SIZE = 512;
  //W9xBufferSize = IDENTIFY_BUFFER_SIZE+16;
type
  TIDERegs = packed record
    bFeaturesReg: BYTE; // Used for specifying SMART "commands".
    bSectorCountReg: BYTE; // IDE sector count register
    bSectorNumberReg: BYTE; // IDE sector number register
    bCylLowReg: BYTE; // IDE low order cylinder value
    bCylHighReg: BYTE; // IDE high order cylinder value
    bDriveHeadReg: BYTE; // IDE drive/head register
    bCommandReg: BYTE; // Actual IDE command.
    bReserved: BYTE; // reserved for future use.  Must be zero.
  end;

  TSendCmdInParams = packed record
    cBufferSize: DWORD; // Buffer size in bytes
    irDriveRegs: TIDERegs; // Structure with drive register values.
    bDriveNumber: BYTE; // Physical drive number to send command to (0,1,2,3).
    bReserved: array[0..2] of Byte;
    dwReserved: array[0..3] of DWORD;
    bBuffer: array[0..0] of Byte; // Input buffer.
  end;

  TIdSector = packed record
    wGenConfig: Word;
    wNumCyls: Word;
    wReserved: Word;
    wNumHeads: Word;
    wBytesPerTrack: Word;
    wBytesPerSector: Word;
    wSectorsPerTrack: Word;
    wVendorUnique: array[0..2] of Word;
    sSerialNumber: array[0..19] of AnsiCHAR;
    wBufferType: Word;
    wBufferSize: Word;
    wECCSize: Word;
    sFirmwareRev: array[0..7] of Char;
    sModelNumber: array[0..39] of Char;
    wMoreVendorUnique: Word;
    wDoubleWordIO: Word;
    wCapabilities: Word;
    wReserved1: Word;
    wPIOTiming: Word;
    wDMATiming: Word;
    wBS: Word;
    wNumCurrentCyls: Word;
    wNumCurrentHeads: Word;
    wNumCurrentSectorsPerTrack: Word;
    ulCurrentSectorCapacity: DWORD;
    wMultSectorStuff: Word;
    ulTotalAddressableSectors: DWORD;
    wSingleWordDMA: Word;
    wMultiWordDMA: Word;
    bReserved: array[0..127] of BYTE;
  end;
  PIdSector = ^TIdSector;

  TDriverStatus = packed record
    bDriverError: Byte;
    bIDEStatus: Byte;
    bReserved: array[0..1] of Byte;
    dwReserved: array[0..1] of DWORD;
  end;

  TSendCmdOutParams = packed record
    cBufferSize: DWORD;
    DriverStatus: TDriverStatus;
    bBuffer: array[0..0] of BYTE;
  end;

var
  hDevice: THandle;
  cbBytesReturned: DWORD;
  SCIP: TSendCmdInParams;
  aIdOutCmd: array[0..(SizeOf(TSendCmdOutParams) + IDENTIFY_BUFFER_SIZE - 1) - 1] of Byte;
  IdOutCmd: TSendCmdOutParams absolute aIdOutCmd;

  procedure ChangeByteOrder(var Data; Size: Integer);
  var
    ptr: PANSIChar;
    i: Integer;
    c: ANSIChar;
  begin
    ptr := @Data;
    for i := 0 to ((Size shr 1) - 1) do begin
      c := ptr^;
      ptr^ := (ptr + 1)^;
      (ptr + 1)^ := c;
      Inc(ptr, 2);
    end;
  end;

begin
  Result := False;
  //Clear Value
  ds.SerialNumber := '';
  ds.ModelNumber := '';
  ds.RevisionNo := '';
  ds.BufferSize := 0;
  ds.Cylinders := 0;
  ds.Heads := 0;
  ds.Sectors := 0;

  try
    if SysUtils.Win32Platform = VER_PLATFORM_WIN32_NT then // Windows NT, Windows 2000
    begin
      hDevice := CreateFile(PChar(Format('\\.\PhysicalDrive%d', [DiskNo])), GENERIC_READ or GENERIC_WRITE,
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
    end else // Version Windows 95 OSR2, Windows 98
    begin
      hDevice := CreateFile('\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0);
    end;
    if hDevice = INVALID_HANDLE_VALUE then Exit;

    try
      FillChar(SCIP, SizeOf(TSendCmdInParams) - 1, #0);
      FillChar(aIdOutCmd, SizeOf(aIdOutCmd), #0);
      cbBytesReturned := 0;
      // Set up data structures for IDENTIFY command.
      with SCIP do begin
        cBufferSize := IDENTIFY_BUFFER_SIZE;
        //    bDriveNumber := 0;
        with irDriveRegs do begin
          bSectorCountReg := 1;
          bSectorNumberReg := 1;
          //   if Win32Platform=VER_PLATFORM_WIN32_NT then bDriveHeadReg := $A0
          //   else bDriveHeadReg := $A0 or ((bDriveNum and 1) shl 4);
          bDriveHeadReg := $A0;
          bCommandReg := $EC;
        end;
      end;
      if not DeviceIoControl(hDevice, $0007C088, @SCIP, SizeOf(TSendCmdInParams) - 1,
        @aIdOutCmd, SizeOf(aIdOutCmd), cbBytesReturned, nil) then Exit;
    finally
      CloseHandle(hDevice);
    end;

    with PIdSector(@IdOutCmd.bBuffer)^ do
    begin
      //Serial Number
      ChangeByteOrder(sSerialNumber, SizeOf(sSerialNumber));
      (PChar(@sSerialNumber) + SizeOf(sSerialNumber))^ := #0;
      StrPCopy(ds.SerialNumber, Trim(PANSIChar(StrPas(PAnsiChar(@sSerialNumber)))));
      //Model Number
      ChangeByteOrder(sModelNumber, SizeOf(sModelNumber));
      (PChar(@sModelNumber) + SizeOf(sModelNumber))^ := #0;
      StrPCopy(ds.ModelNumber, Trim(PANSIChar(StrPas(PAnsiChar(@sModelNumber)))));
      //Revision Number
      ChangeByteOrder(sFirmwareRev, SizeOf(sFirmwareRev));
      (PChar(@sFirmwareRev) + SizeOf(sFirmwareRev))^ := #0;
      StrPCopy(ds.RevisionNo, Trim(PANSIChar(StrPas(PAnsiChar(@sFirmwareRev)))));
      //Buffer Size: wBufferSize * 512
      ds.BufferSize := wBufferSize * 512;
      //Cylinders: wNumCyls
      ds.Cylinders := wNumCyls;
      //Heads: wNumHeads
      ds.Heads := wNumHeads;
      //Sectors: wSectorsPerTrack
      ds.Sectors := wSectorsPerTrack;
    end;
    Result := True;
  except
    Result := False;
  end;
end;

function GetIdeDiskSerialNumberWithZeroRight(DiskNo: Byte; var ds: DiskInfo): LongBool;
type
  TSrbIoControl = packed record
    HeaderLength: ULONG;
    Signature: array[0..7] of Char;
    Timeout: ULONG;
    ControlCode: ULONG;
    ReturnCode: ULONG;
    Length: ULONG;
  end;
  SRB_IO_CONTROL = TSrbIoControl;
  PSrbIoControl = ^TSrbIoControl;

  TIDERegs = packed record
    bFeaturesReg: Byte; // Used for specifying SMART "commands".
    bSectorCountReg: Byte; // IDE sector count register
    bSectorNumberReg: Byte; // IDE sector number register
    bCylLowReg: Byte; // IDE low order cylinder value
    bCylHighReg: Byte; // IDE high order cylinder value
    bDriveHeadReg: Byte; // IDE drive/head register
    bCommandReg: Byte; // Actual IDE command.
    bReserved: Byte; // reserved. Must be zero.
  end;
  IDEREGS = TIDERegs;
  PIDERegs = ^TIDERegs;

  TSendCmdInParams = packed record
    cBufferSize: DWORD;
    irDriveRegs: TIDERegs;
    bDriveNumber: Byte;
    bReserved: array[0..2] of Byte;
    dwReserved: array[0..3] of DWORD;
    bBuffer: array[0..0] of Byte;
  end;
  SENDCMDINPARAMS = TSendCmdInParams;
  PSendCmdInParams = ^TSendCmdInParams;

  TIdSector = packed record
    wGenConfig: Word;
    wNumCyls: Word;
    wReserved: Word;
    wNumHeads: Word;
    wBytesPerTrack: Word;
    wBytesPerSector: Word;
    wSectorsPerTrack: Word;
    wVendorUnique: array[0..2] of Word;
    sSerialNumber: array[0..19] of AnsiChar;
    wBufferType: Word;
    wBufferSize: Word;
    wECCSize: Word;
    sFirmwareRev: array[0..7] of Char;
    sModelNumber: array[0..39] of Char;
    wMoreVendorUnique: Word;
    wDoubleWordIO: Word;
    wCapabilities: Word;
    wReserved1: Word;
    wPIOTiming: Word;
    wDMATiming: Word;
    wBS: Word;
    wNumCurrentCyls: Word;
    wNumCurrentHeads: Word;
    wNumCurrentSectorsPerTrack: Word;
    ulCurrentSectorCapacity: ULONG;
    wMultSectorStuff: Word;
    ulTotalAddressableSectors: ULONG;
    wSingleWordDMA: Word;
    wMultiWordDMA: Word;
    bReserved: array[0..127] of Byte;
  end;

  PIdSector = ^TIdSector;

const
  IDE_ID_FUNCTION = $EC;
  IDENTIFY_BUFFER_SIZE = 512;
  DFP_RECEIVE_DRIVE_DATA = $0007C088;
  IOCTL_SCSI_MINIPORT = $0004D008;
  IOCTL_SCSI_MINIPORT_IDENTIFY = $001B0501;
  DataSize = sizeof(TSendCmdInParams) - 1 + IDENTIFY_BUFFER_SIZE;
  BufferSize = SizeOf(SRB_IO_CONTROL) + DataSize;
  W9xBufferSize = IDENTIFY_BUFFER_SIZE + 16;
var
  hDevice: THandle;
  cbBytesReturned: DWORD;
  pInData: PSendCmdInParams;
  pOutData: Pointer; // PSendCmdOutParams
  Buffer: array[0..BufferSize - 1] of Byte;
  srbControl: TSrbIoControl absolute Buffer;

  procedure ChangeByteOrder(var Data; Size: Integer);
  var
    ptr: PChar;
    i: Integer;
    c: Char;
  begin
    ptr := @Data;
    for i := 0 to (Size shr 1) - 1 do
    begin
      c := ptr^;
      ptr^ := (ptr + 1)^;
      (ptr + 1)^ := c;
      Inc(ptr, 2);
    end;
  end;

begin
  Result := False;
  //Clear Value
  ds.SerialNumber := '';
  ds.ModelNumber := '';
  ds.RevisionNo := '';
  ds.BufferSize := 0;
  ds.Cylinders := 0;
  ds.Heads := 0;
  ds.Sectors := 0;
  try
    FillChar(Buffer, BufferSize, #0);
    if Win32Platform = VER_PLATFORM_WIN32_NT then
    begin
      hDevice := CreateFile(PChar(Format('\\.\Scsi%d:', [DiskNo])),
        GENERIC_READ or GENERIC_WRITE,
        FILE_SHARE_READ or FILE_SHARE_WRITE,
        nil, CREATE_NEW {OPEN_EXISTING}, 0, 0);
      if hDevice = INVALID_HANDLE_VALUE then
      begin
        Exit;
      end;

      try
        srbControl.HeaderLength := SizeOf(SRB_IO_CONTROL);
        System.Move('SCSIDISK', srbControl.Signature, 8);
        srbControl.Timeout := 2;
        srbControl.Length := DataSize;
        srbControl.ControlCode := IOCTL_SCSI_MINIPORT_IDENTIFY;
        pInData := PSendCmdInParams(PChar(@Buffer)
          + SizeOf(SRB_IO_CONTROL));
        pOutData := pInData;
        with pInData^ do
        begin
          cBufferSize := IDENTIFY_BUFFER_SIZE;
          bDriveNumber := 0;
          with irDriveRegs do
          begin
            bFeaturesReg := 0;
            bSectorCountReg := 1;
            bSectorNumberReg := 1;
            bCylLowReg := 0;
            bCylHighReg := 0;
            bDriveHeadReg := $A0;
            bCommandReg := IDE_ID_FUNCTION;
          end;
        end;
        if not DeviceIoControl(hDevice, IOCTL_SCSI_MINIPORT,
          @Buffer, BufferSize, @Buffer, BufferSize,
          cbBytesReturned, nil) then Exit;
      finally
        CloseHandle(hDevice);
      end;
    end
    else
    begin // Windows 95 OSR2, Windows 98
      hDevice := CreateFile('\\.\SMARTVSD', 0, 0, nil,
        CREATE_NEW, 0, 0);
      if hDevice = INVALID_HANDLE_VALUE then Exit;
      try
        pInData := PSendCmdInParams(@Buffer);
        pOutData := @pInData^.bBuffer;
        with pInData^ do
        begin
          cBufferSize := IDENTIFY_BUFFER_SIZE;
          bDriveNumber := 0;
          with irDriveRegs do
          begin
            bFeaturesReg := 0;
            bSectorCountReg := 1;
            bSectorNumberReg := 1;
            bCylLowReg := 0;
            bCylHighReg := 0;
            bDriveHeadReg := $A0;
            bCommandReg := IDE_ID_FUNCTION;
          end;
        end;
        if not DeviceIoControl(hDevice, DFP_RECEIVE_DRIVE_DATA,
          pInData, SizeOf(TSendCmdInParams) - 1, pOutData,
          W9xBufferSize, cbBytesReturned, nil) then
          Exit;
      finally
        CloseHandle(hDevice);
      end;
    end;
    with PIdSector(PChar(pOutData) + 16)^ do
    begin
      //Serial Number
      ChangeByteOrder(sSerialNumber, SizeOf(sSerialNumber));
      (PChar(@sSerialNumber) + SizeOf(sSerialNumber))^ := #0;
      StrPCopy(ds.SerialNumber, Trim(PANSIChar(StrPas(PAnsiChar(@sSerialNumber)))));
      //Model Number
      ChangeByteOrder(sModelNumber, SizeOf(sModelNumber));
      (PChar(@sModelNumber) + SizeOf(sModelNumber))^ := #0;
      StrPCopy(ds.ModelNumber, Trim(PANSIChar(StrPas(PAnsiChar(@sModelNumber)))));
      //Revision Number
      ChangeByteOrder(sFirmwareRev, SizeOf(sFirmwareRev));
      (PChar(@sFirmwareRev) + SizeOf(sFirmwareRev))^ := #0;
      StrPCopy(ds.RevisionNo, Trim(PANSIChar(StrPas(PAnsiChar(@sFirmwareRev)))));
      //Buffer Size: wBufferSize * 512
      ds.BufferSize := wBufferSize * 512;
      //Cylinders: wNumCyls
      ds.Cylinders := wNumCyls;
      //Heads: wNumHeads
      ds.Heads := wNumHeads;
      //Sectors: wSectorsPerTrack
      ds.Sectors := wSectorsPerTrack;
    end;
    Result := True;
  except
    Result := False;
  end;
end;

function GetSerialNumber(DiskNo: Byte): String;
var
  vTmp: DiskInfo;
begin
  GetIdeDiskInfo(DiskNo, vTmp);
  Result := vTmp.SerialNumber;
end;

function GetModelNumber(DiskNo: Byte): String;
var
  vTmp: DiskInfo;
begin
  GetIdeDiskInfo(DiskNo, vTmp);
  Result := vTmp.ModelNumber;
end;

function GetRevisionNo(DiskNo: Byte): String;
var
  vTmp: DiskInfo;
begin
  GetIdeDiskInfo(DiskNo, vTmp);
  Result := vTmp.RevisionNo;
end;

function GetBufferSize(DiskNo: Byte): Integer;
var
  vTmp: DiskInfo;
begin
  GetIdeDiskInfo(DiskNo, vTmp);
  Result:= vTmp.BufferSize;
end;

function GetCylinders(DiskNo: Byte): Integer;
var
  vTmp: DiskInfo;
begin
  GetIdeDiskInfo(DiskNo, vTmp);
  Result:= vTmp.Cylinders;
end;

function GetHeads(DiskNo: Byte): Integer;
var
  vTmp: DiskInfo;
begin
  GetIdeDiskInfo(DiskNo, vTmp);
  Result:= vTmp.Heads;
end;

function GetSectors(DiskNo: Byte): Integer;
var
  vTmp: DiskInfo;
begin
  GetIdeDiskInfo(DiskNo, vTmp);
  Result:= vTmp.Sectors;
end;

end.

