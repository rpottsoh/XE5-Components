// $Header:   M:\eng\dapio\src\dll\import\pascal\dapio32.pav   1.0   18 Oct 2010 11:13:18   XIAOZHI  $
// Copyright (c) 1992-2002, Microstar Laboratories, Inc.

///////////////////////////////////////////////////////////////////
//
//  DAPIO32.PAS
//
//  This unit defines the DAPIO32.DLL Pascal interface
//  version 2.12.  DapStringFormat is not supported.
//
//  Copyright (c) 1996-2002, Microstar Laboratories, Inc.
//
///////////////////////////////////////////////////////////////////
//
//  Updated by Ryan Potts @ TMSI LLC to cope with Unicode types
//  used by modern Delphi compilers.  Support for versions before
//  Delphi 2010 blocked,  See Dapio32_TMSI.inc
//                                           6/14/2016
///////////////////////////////////////////////////////////////////
{$I Dapio32_TMSI.inc}

unit Dapio32_TMSI;

interface

{$IFNDEF LINUX}  {$DEFINE MSWINDOWS}  {$ENDIF}
uses
  {$IFDEF MSWINDOWS} Windows, {$ENDIF}
  {$IFDEF LINUX} Types, {$ENDIF}
  SysUtils;

type
  {$ifdef DELPHI_2010_UP}
  T_Char   = ANSIChar;
  T_PChar  = PANSIChar;
  T_String = ANSIString;
  TDapIoInt64 = int64;
  {$else}   //If we really wanted to support older compilers (before D2010) these types should be used (rp 6/14/16)
  T_Char   = Char;
  T_PChar  = PChar;
  T_String = string;
  TDapIoInt64 = packed record //Only to be used with older version that predate int64 availability
    dwLowPart: DWORD;
    dwHighPart: DWORD;
  end;
  {$endif}

const
  {$IFDEF MSWINDOWS} DapioDll = 'dapio32.dll'; {$ENDIF}
  {$IFDEF LINUX} DapioDll = 'libdapio32rt.so'; {$ENDIF}

type
  // Define a unique type for a handle to the DAP.
  HDAP = integer;
  // Define the TDapHandle type for compatability with Delphi symbols.
  TDapHandle = HDAP;
//type
  // Define TDapIoInt64 type
  // VER80  - Delphi 1
  // VER90  - Delphi 2
  // VER93  - C++Builder 1
  // VER100 - Delphi 3
  // VER110 - C++Builder 3
  // VER120 - Delphi 4
  // VER125 - C++Builder 4
  // VER130 - Delphi 5
  (*   Rendered obsolete since unit is setup for D2010 and UP only.

  {$IFDEF VER80}   {$DEFINE DapIoNoInt64}  {$ENDIF}
  {$IFDEF VER90}   {$DEFINE DapIoNoInt64}  {$ENDIF}
  {$IFDEF VER93}   {$DEFINE DapIoNoInt64}  {$ENDIF}
  {$IFDEF VER100}  {$DEFINE DapIoNoInt64}  {$ENDIF}
  {$IFDEF VER110}  {$DEFINE DapIoNoInt64}  {$ENDIF}

  {$IFDEF DapIoNoInt64}
  TDapIoInt64 = packed record
    dwLowPart: DWORD;
    dwHighPart: DWORD;
  end;
  {$ELSE}
  TDapIoInt64 = int64;
  {$ENDIF}
  (**)


const
  // Open mode constants for DapHandleOpen(. . .).
  // Note:
  //  DAPOPEN_READ and DAPOPEN_WRITE constants match the Win32 constants
  //  GENERIC_READ and GENERIC_WRITE. They can be interchanged with these
  //  constants but are declared separately so that there is less dependency
  //  on WINDOWS.PAS.
 
  DAPOPEN_READ   = $80000000;
  DAPOPEN_WRITE  = $40000000;
  DAPOPEN_QUERY  = $20000000;
  DAPOPEN_DISKIO = $10000000;

  // File share mode constants for DapPipeDiskLog(. . .) and
  //  DapPipeDiskFeed(. . .).
  // Note:
  //  These constants match the Win32 constants FILE_SHARE_READ and
  //  FILE_SHARE_WRITE. They can be interchanged with these constants but are
  //  declared separately so that there is less dependency on WINDOWS.PAS.
 
  DAPIO_FILE_SHARE_READ  = $00000001;
  DAPIO_FILE_SHARE_WRITE = $00000002;

  // File open attribute constants for DapPipeDiskLog(. . .) and
  //  DapPipeDiskFeed(. . .).
  // Note:
  //  These constants match the Win32 constants CREATE_NEW, CREATE_ALWAYS,
  //  OPEN_EXISTING and OPEN_ALWAYS. They can be interchanged with these
  //  constants but are declared separately so that there is less dependency
  //  on WINDOWS.PAS.
 
  DAPIO_CREATE_NEW    = 1;
  DAPIO_CREATE_ALWAYS = 2;
  DAPIO_OPEN_EXISTING = 3;
  DAPIO_OPEN_ALWAYS   = 4;

  // File attributes constants for DapPipeDiskLog(. . .) and
  //  DapPipeDiskFeed(. . .).
  // Note:
  //  These constants match the Win32 constants FILE_ATTRIBUTE_NORMAL,
  //  FILE_ATTRIBUTE_ENCRYPTED and FILE_ATTRIBUTE_READONLY. They can be
  //  interchanged with these constants but are declared separately so that
  //  there is less dependency on WINDOWS.PAS.
 
  DAPIO_FILE_ATTRIBUTE_NORMAL    = $00000080;
  DAPIO_FILE_ATTRIBUTE_ENCRYPTED = $00000040;
  DAPIO_FILE_ATTRIBUTE_READONLY  = $00000001;

  // File flags constants for DapPipeDiskLog(. . .) and
  //  DapPipeDiskFeed(. . .).
  // Note:
  //  These constants match the Win32 constants FILE_FLAG_WRITE_THROUGH,  
  //  FILE_FLAG_RANDOM_ACCESS, and FILE_FLAG_SEQUENTIAL_SCAN. They can be
  //  interchanged with these constants but are declared separately so that
  //  there is less dependency on WINDOWS.PAS.
 
  DAPIO_FILE_FLAG_WRITE_THROUGH   = $80000000;
  DAPIO_FILE_FLAG_RANDOM_ACCESS   = $10000000;
  DAPIO_FILE_FLAG_SEQUENTIAL_SCAN = $08000000;

type
  // Information structure for DapBufferGetEx(. . .).
  TDapBufferGetEx = packed record
    iInfoSize: integer;       // size of this info structure
    iBytesGetMin: integer;    // minimum number of bytes to get
    iBytesGetMax: integer;    // maximum number of bytes to get
    iReserved1: integer;      // not used must be zero
    dwTimeWait: DWORD;        // time to wait with no data before return
    dwTimeOut: DWORD;         // time to wait with data before return
    iBytesMultiple: integer;  // bytes to get is always a multiple of this
  end;

  // Information structure for DapBufferPutEx(. . .).
  TDapBufferPutEx = packed record
    iInfoSize: integer;       // size of this info structure
    iBytesPut: integer;       // number of bytes to put
    dwTimeWait: DWORD;        // longest time in milliseconds to wait
    dwTimeOut: DWORD;         // longest time in milliseconds to put all
    iBytesMultiple: integer;  // bytes to put is always a multiple of this
    iReserved1: integer;      // not used, must be zero
  end;

  // Information structure for DapCommandDownloadA(. . .).
  TDapCommandDownloadA = packed record
    iInfoSize: integer;
    hdapSysPut: TDapHandle;
    hdapSysGet: TDapHandle;
    pszCCFileName: T_PChar;
    pszCCName: T_PChar;
    iCCStackSize: integer;
    end;

  TDapCommandDownload = TDapCommandDownloadA;

const
  // Enumerated data types used in DAPIO32. The type values are consistent to
  //  Microsoft Win32 registry key value types except for DAPIO_VARIANT,
  //  that is:
  // 
  // DAPIO_NONE     = REG_NONE
  // DAPIO_BINARY   = REG_BINARY
  // DAPIO_SZ       = REG_SZ
  // DAPIO_MULTI_SZ = REG_MULTI_SZ
 
  DAPIO_NONE      = 0;  // nothing
  DAPIO_BINARY    = 3;  // binary result
  DAPIO_SZ        = 1;  // null terminated result
  DAPIO_MULTI_SZ  = 7;  // Multiple null terminated results
  DAPIO_VARIANT   =64;  // DAPIO specific variant type
  
type
  // Information query structure for DapHandleQueryA(. . .).
  TDapHandleQueryA = packed record
    iInfoSize: integer;         // size of this info structure
    pszQueryKey: T_PChar;         // pointer to a query key string
    QueryResult: packed record
      case integer of           // If the iBufferSize is 0, the queury result is a
        0: (psz: T_PChar);        //  DWORD, returned in QueryResult.dw; otherwise,
        1: (pvoid: Pointer);    //  the result is returned as a double null
        2: (dw: DWORD);         //  terminated multiple strings in a user-provided
      end;                      //  buffer QueryResult.psz points to. If eResultType
    iBufferSize: integer;       //  is specified, the result is in the buffer
    eResultType: integer;       //  QueryResult.pvoid points to and the result
  end;                          //  type is eResultType.

  TDapHandleQuery = TDapHandleQueryA;

  // Disk I/O status values returned by "DiskIoStatus" query
  TEDapDiskIoStatus = (
    ddios_Completed,  // disk I/O completed successfully
    ddios_Active,     // disk I/O is still active
    ddios_Aborted,    // disk I/O aborted due to an error
    ddios_FileError   // file error on disk I/O
    );

type
  TEDapPipeDiskLog = integer;
const
  // Disk logging flags, used by the bmFlags field in the TDapPipeDiskLog
  //  structure. 
  dpdl_ServerSide    = $00000001;  // log on server side
  dpdl_FlushBefore   = $00000002;  // flush pipe before logging
  dpdl_FlushAfter    = $00000004;  // flush pipe after logging
  dpdl_MirrorLog     = $00000008;  // enable mirror logging
  dpdl_AppendData    = $00000010;  // append data to existing file
  dpdl_BlockTransfer = $00000020;  // higher throughput using blocks

type
  // Information structure for DapPipeDiskLog(. . .).
  TDapPipeDiskLogA = packed record
    iInfoSize: integer;                  // size of this info structure
    bmFlags: DWORD;                      // flags to DapPipeDiskLog()
    pszFileName: T_PChar;                  // name buffer for log files
    dwFileShareMode: DWORD;              // file sharing attributes
    dwOpenFlags: DWORD;                  // file opening attributes
    dwFileFlagsAttributes: DWORD;        // file flags and attributes
    i64MaxCount: TDapIoInt64;            // maximum bytes to log
    dwBlockSize: DWORD;                  // byte threshold for writing to file
    dwReserved: array [0..15] of DWORD;  // reserved must be zero
    end;

  TDapPipeDiskLog = TDapPipeDiskLogA;

type
  TEDapPipeDiskFeed = integer;
const
  dpdf_ServerSide     = $00000001;  // source on server side
  dpdf_FlushBefore    = $00000002;  // flush pipe before feeding
  dpdf_BlockTransfer  = $00000004;  // higher throughput using blocks
  dpdf_ContinuousFeed = $00000008;  // repeat feed from start of file

type
  // Information structure for DapPipeDiskFeed(. . .).
  TDapPipeDiskFeedA = packed record
    iInfoSize: integer;                  // size of this info structure
    bmFlags: DWORD;                      // flags to DapPipeDiskLog()
    pszFileName: T_PChar;                  // name buffer for source file
    dwFileShareMode: DWORD;              // file sharing attributes
    dwFileFlagsAttributes: DWORD;        // file flags and attributes    
    dwBlockSize: DWORD;                  // block size in bytes for reading
    i64MaxCount: TDapIoInt64;            // maximum bytes to log
    dwReserved: array [0..15] of DWORD;  // reserved must be zero
    end;

  TDapPipeDiskFeed = TDapPipeDiskFeedA;

type
  TEDapBufferPeek = integer;
const
  dbpk_Absolute    = $00000000;     // absolute mode
  dbpk_Relative    = $00000001;     // relative mode

type
  // Information structure for DapBufferPeek(. . .).
  TDapBufferPeek = packed record
    iInfoSize: integer;               // size of this info structure
    iBytesGetMin: integer;            // minimum number of bytes to get
    iBytesGetMax: integer;            // maximum number of bytes to get
    bmMode: DWORD;                    // bit mode
    dwTimeWait: DWORD;                // time to wait with no data before return
    dwTimeOut: DWORD;                 // time to wait with data before return
    iBytesMultiple: integer;          // bytes to get is always a multiple of this
    pBuffer: Pointer;                 // pointer to a user-supplied buffer
    i64OffsetRequested: TDapIoInt64;  // requested offset of data
    i64OffsetResult: TDapIoInt64;     // actual offset of data returned
    iBytesResult: integer;            // number of bytes returned in the buffer
    end;

// Module service flag bits.
type
  TEDapModuleFlags = integer;
const
  dmf_NoCopy              =  $00000001; // do not copy the module file
  dmf_NoLoad              =  $00000002; // do not load/unload the module
  dmf_ForceLoad           =  $00000004; // force loading/unloading
  dmf_NoReplace           =  $00000008; // do not replace the existing module file
  dmf_ForceRegister       =  $00000010; // force register/unregister
  dmf_RemoveDependents    =  $00000020; // remove dependent modules
  dmf_Reserved1           =  $00000040; // reserved for internal use
  dmf_OsDAPL2000          =  $00000100; // module intended for DAPL2000
  dmf_OsDAPL3000          =  $00000200; // module intended for DAPL3000    

// Functions supported by all Data Acquisition Processor servers.
function DapComPipeCreateA(pszPipeInfo: T_PChar): Boolean; stdcall;
function DapComPipeCreate(pszPipeInfo: T_PChar): Boolean; stdcall;
function DapComPipeDeleteA(pszPipeInfo: T_PChar): Boolean; stdcall;
function DapComPipeDelete(pszPipeInfo: T_PChar): Boolean; stdcall;
function DapHandleQueryA(hAccel: TDapHandle; var pHandleInfo: TDapHandleQueryA): Boolean; stdcall;
function DapHandleQuery(hAccel: TDapHandle; var pHandleInfo: TDapHandleQuery): Boolean; stdcall;
function DapHandleQueryInt32A(hAccel: TDapHandle; pszKey: T_PChar; var i32Result: integer): Boolean; stdcall;
function DapHandleQueryInt32(hAccel: TDapHandle; pszKey: T_PChar; var i32Result: integer): Boolean; stdcall;
function DapHandleQueryInt64A(hAccel: TDapHandle; pszKey: T_PChar; var i64Result: TDapIoInt64): Boolean; stdcall;
function DapHandleQueryInt64(hAccel: TDapHandle; pszKey: T_PChar; var i64Result: TDapIoInt64): Boolean; stdcall;

function DapHandleClose(hAccel: TDapHandle): Boolean; stdcall;
function DapHandleOpenA(pszAccelName: T_PChar; ulOpenFlags: DWORD): TDapHandle; stdcall;
function DapHandleOpen(pszAccelName: T_PChar; ulOpenFlags: DWORD): TDapHandle; stdcall;
function DapInputAvail(hAccel: TDapHandle): Integer; stdcall;
function DapOutputSpace(hAccel: TDapHandle): Integer; stdcall;

function DapBufferGet(hAccel: TDapHandle; iLength: Integer; var pvBuffer): Integer; stdcall;
function DapBufferGetEx(hAccel: TDapHandle; const pGetInfo: TDapBufferGetEx; var pvBuffer): Integer; stdcall;
function DapBufferPut(hAccel: TDapHandle; iLength: Integer; const pvBuffer): Integer; stdcall;
function DapBufferPutEx(hAccel: TDapHandle; const pPutInfo: TDapBufferPutEx; const pvBuffer): Integer; stdcall;
function DapCharGetA(hAccel: TDapHandle; pch: T_PChar): Boolean; stdcall;
function DapCharGet(hAccel: TDapHandle; pch: T_PChar): Boolean; stdcall;
function DapCharPutA(hAccel: TDapHandle; ch: T_Char): Boolean; stdcall;
function DapCharPut(hAccel: TDapHandle; ch: T_Char): Boolean; stdcall;
function DapCommandDownloadA(const pdcdl: TDapCommandDownloadA): Boolean; stdcall;
function DapCommandDownload(const pdcdl: TDapCommandDownload): Boolean; stdcall;

function DapConfigA(hAccel: TDapHandle; pszDaplFilename: T_PChar): Boolean; stdcall;
function DapConfig(hAccel: TDapHandle; pszDaplFilename: T_PChar): Boolean; stdcall;
function DapConfigParamsClear: Boolean; stdcall;
function DapConfigParamSetA(iParamNumber: Integer; pszParam: T_PChar): Boolean; stdcall;
function DapConfigParamSet(iParamNumber: Integer; pszParam: T_PChar): Boolean; stdcall;
function DapConfigRedirectA(pszOutputFilename: T_PChar): Boolean; stdcall;
function DapConfigRedirect(pszOutputFilename: T_PChar): Boolean; stdcall;
function DapInputFlush(hAccel: TDapHandle): Integer; stdcall;
function DapInputFlushEx(hAccel: TDapHandle; dwTimeOut: DWORD; dwTimeWait: DWORD; var pdwFlushed: DWORD): Boolean; stdcall;
function DapOutputEmpty(hAccel: TDapHandle): Boolean; stdcall;

function DapInt16Get(hAccel: TDapHandle; var pi16: Smallint): Boolean; stdcall;
function DapInt16Put(hAccel: TDapHandle; i16: Smallint): Boolean; stdcall;
function DapInt32Get(hAccel: TDapHandle; var pi32: Longint): Boolean; stdcall;
function DapInt32Put(hAccel: TDapHandle; i32: Longint): Boolean; stdcall;
function DapLastErrorTextGetA(pszError: T_PChar; iLength: Integer): T_PChar; stdcall;
function DapLastErrorTextGet(pszError: T_PChar; iLength: Integer): T_PChar; stdcall;

// DapStringFormat is not supported.
function DapStringGetA(hAccel: TDapHandle; iLength: Integer; psz: T_PChar): Boolean; stdcall;
function DapStringGet(hAccel: TDapHandle; iLength: Integer; psz: T_PChar): Boolean; stdcall;
function DapStringPutA(hAccel: TDapHandle; psz: T_PChar): Boolean; stdcall;
function DapStringPut(hAccel: TDapHandle; psz: T_PChar): Boolean; stdcall;
function DapLineGetA(hAccel: TDapHandle; iLength: Integer; psz: T_PChar; dwTimeWait: DWORD): Integer; stdcall;
function DapLineGet(hAccel: TDapHandle; iLength: Integer; psz: T_PChar; dwTimeWait: DWORD): Integer; stdcall;
function DapLinePutA(hAccel: TDapHandle; psz: T_PChar): Integer; stdcall;
function DapLinePut(hAccel: TDapHandle; psz: T_PChar): Integer; stdcall;

procedure DapStructPrepare(var pStruct; size: integer); stdcall;
function DapModuleInstallA(hAccel: TDapHandle; pszModPath: T_PChar; bmFlags: DWORD; var pDapList): Boolean; stdcall;
function DapModuleInstall(hAccel: TDapHandle; pszModPath: T_PChar; bmFlags: DWORD; var pDapList): Boolean; stdcall;
function DapModuleUninstallA(hAccel: TDapHandle; pszModName: T_PChar; bmFlags: DWORD; var pDapList): Boolean; stdcall;
function DapModuleUninstall(hAccel: TDapHandle; pszModName: T_PChar; bmFlags: DWORD; var pDapList): Boolean; stdcall;
function DapModuleLoadA(hAccel: TDapHandle; pszModPath: T_PChar; bmFlags: DWORD; var pDapList): Boolean; stdcall;
function DapModuleLoad(hAccel: TDapHandle; pszModPath: T_PChar; bmFlags: DWORD; var pDapList): Boolean; stdcall;
function DapModuleUnloadA(hAccel: TDapHandle; pszModName: T_PChar; bmFlags: DWORD; var pDapList): Boolean; stdcall;
function DapModuleUnload(hAccel: TDapHandle; pszModName: T_PChar; bmFlags: DWORD; var pDapList): Boolean; stdcall;
function DapReinitialize(hAccel: TDapHandle): Boolean; stdcall;
function DapReset(hAccel: TDapHandle): Boolean; stdcall;
function DapBufferPeek(hAccel: TDapHandle; var pPeekInfo: TDapBufferPeek): Boolean; stdcall;
function DapServerControlA(pszServer: T_PChar; pszKey: T_PChar): Boolean; stdcall;
function DapServerControl(pszServer: T_PChar; pszKey: T_PChar): Boolean; stdcall;

// Functions only supported by DAPcell and DAPcell Local servers.
function DapPipeDiskLogA(hAccel: TDapHandle; var pLogInfo: TDapPipeDiskLogA; var pGetInfo: TDapBufferGetEx): Boolean; stdcall;
function DapPipeDiskLog(hAccel: TDapHandle; var pLogInfo: TDapPipeDiskLog; var pGetInfo: TDapBufferGetEx): Boolean; stdcall;
function DapPipeDiskFeedA(hAccel: TDapHandle; var pFeedInfo: TDapPipeDiskFeedA; var pPutInfo: TDapBufferPutEx): Boolean; stdcall;
function DapPipeDiskFeed(hAccel: TDapHandle; var pFeedInfo: TDapPipeDiskFeed; var pPutInfo: TDapBufferPutEx): Boolean; stdcall;

function DapLastErrorGet: string;


implementation

function DapComPipeCreateA; external DapioDll name 'DapComPipeCreateA';
function DapComPipeCreate;  external DapioDll name 'DapComPipeCreateA';
function DapComPipeDeleteA; external DapioDll name 'DapComPipeDeleteA';
function DapComPipeDelete;  external DapioDll name 'DapComPipeDeleteA';
function DapHandleQueryA;   external DapioDll name 'DapHandleQueryA';
function DapHandleQuery;    external DapioDll name 'DapHandleQueryA';
function DapHandleQueryInt32A; external DapioDll name 'DapHandleQueryInt32A';
function DapHandleQueryInt32;  external DapioDll name 'DapHandleQueryInt32A';
function DapHandleQueryInt64A; external DapioDll name 'DapHandleQueryInt64A';
function DapHandleQueryInt64;  external DapioDll name 'DapHandleQueryInt64A';

function DapHandleClose; external DapioDll name 'DapHandleClose';
function DapHandleOpenA; external DapioDll name 'DapHandleOpenA';
function DapHandleOpen;  external DapioDll name 'DapHandleOpenA';
function DapInputAvail;  external DapioDll name 'DapInputAvail';
function DapOutputSpace; external DapioDll name 'DapOutputSpace';

function DapBufferGet;   external DapioDll name 'DapBufferGet';
function DapBufferGetEx; external DapioDll name 'DapBufferGetEx';
function DapBufferPut;   external DapioDll name 'DapBufferPut';
function DapBufferPutEx; external DapioDll name 'DapBufferPutEx';
function DapCharGetA;    external DapioDll name 'DapCharGetA';
function DapCharGet;     external DapioDll name 'DapCharGetA';
function DapCharPutA;    external DapioDll name 'DapCharPutA';
function DapCharPut;     external DapioDll name 'DapCharPutA';
function DapCommandDownloadA; external DapioDll name 'DapCommandDownloadA';
function DapCommandDownload;  external DapioDll name 'DapCommandDownloadA';

function DapConfigA;           external DapioDll name 'DapConfigA';
function DapConfig;            external DapioDll name 'DapConfigA';
function DapConfigParamsClear; external DapioDll name 'DapConfigParamsClear';
function DapConfigParamSetA;   external DapioDll name 'DapConfigParamSetA';
function DapConfigParamSet;    external DapioDll name 'DapConfigParamSetA';
function DapConfigRedirectA;   external DapioDll name 'DapConfigRedirectA';
function DapConfigRedirect;    external DapioDll name 'DapConfigRedirectA';
function DapInputFlush;        external DapioDll name 'DapInputFlush';
function DapInputFlushEx;      external DapioDll name 'DapInputFlushEx';
function DapOutputEmpty;       external DapioDll name 'DapOutputEmpty';

function DapInt16Get; external DapioDll name 'DapInt16Get';
function DapInt16Put; external DapioDll name 'DapInt16Put';
function DapInt32Get; external DapioDll name 'DapInt32Get';
function DapInt32Put; external DapioDll name 'DapInt32Put';
function DapLastErrorTextGetA; external DapioDll name 'DapLastErrorTextGetA';
function DapLastErrorTextGet;  external DapioDll name 'DapLastErrorTextGetA';

function DapStringGetA; external DapioDll name 'DapStringGetA';
function DapStringGet;  external DapioDll name 'DapStringGetA';
function DapStringPutA; external DapioDll name 'DapStringPutA';
function DapStringPut;  external DapioDll name 'DapStringPutA';
function DapLineGetA;   external DapioDll name 'DapLineGetA';
function DapLineGet;    external DapioDll name 'DapLineGetA';
function DapLinePutA;   external DapioDll name 'DapLinePutA';
function DapLinePut;    external DapioDll name 'DapLinePutA';

procedure DapStructPrepare;   external DapioDll name 'DapStructPrepare';
function DapModuleInstallA;   external DapioDll name 'DapModuleInstallA';
function DapModuleInstall;    external DapioDll name 'DapModuleInstallA';
function DapModuleUninstallA; external DapioDll name 'DapModuleUninstallA';
function DapModuleUninstall;  external DapioDll name 'DapModuleUninstallA';
function DapModuleLoadA;      external DapioDll name 'DapModuleLoadA';
function DapModuleLoad;       external DapioDll name 'DapModuleLoadA';
function DapModuleUnloadA;    external DapioDll name 'DapModuleUnloadA';
function DapModuleUnload;     external DapioDll name 'DapModuleUnloadA';
function DapReinitialize;     external DapioDll name 'DapReinitialize';
function DapReset;            external DapioDll name 'DapReset';
function DapBufferPeek;       external DapioDll name 'DapBufferPeek';
function DapServerControlA;   external DapioDll name 'DapServerControlA';
function DapServerControl;    external DapioDll name 'DapServerControlA';

function DapPipeDiskLogA;   external DapioDll name 'DapPipeDiskLogA';
function DapPipeDiskLog;    external DapioDll name 'DapPipeDiskLogA';
function DapPipeDiskFeedA;  external DapioDll name 'DapPipeDiskFeedA';
function DapPipeDiskFeed;   external DapioDll name 'DapPipeDiskFeedA';


function DapLastErrorGet: string;
var
  acError: array [0..1023] of T_Char;
begin
  DapLastErrorTextGet(acError, SizeOf(acError));
  Result := StrPas(acError);
end;


end.
