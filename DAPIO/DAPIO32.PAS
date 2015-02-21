{ $Header:   M:\eng\dapio\src32\dll\import\pascal\dapio32.pav   1.8   13 Aug 1998 14:32:22   XIAOZHI  $ }
{ Copyright (c) 1992-1998, Microstar Laboratories, Inc. }

{
   Module: DAPIO32.PAS

   This unit defines procedures in DAPIO32.DLL so that they can be
   called from Pascal programs.

   Copyright (c) 1992-1998, Microstar Laboratories, Inc.
}

unit Dapio32;

interface

uses
  WinTypes, Windows, SysUtils;

{Open mode constants for DapHandleOpen(. . .)}
const
  DAPOPEN_READ  = GENERIC_READ;
  DAPOPEN_WRITE = GENERIC_WRITE;
  DAPOPEN_QUERY = $20000000;

type
  TDapHandle = Integer;


{Records for use in DAPIO32 services.}


{Information structure for DapBufferGetEx() function.}
TDapBufferGetEx = packed record
  iInfoSize: Integer;           {size of this info structure}
  iBytesGetMin: Integer;        {minimum number of bytes to get}
  iBytesGetMax: Integer;        {maximum number of bytes to get}
  iReserved: Integer;           {not used must be zero}
  dwTimeWait: DWORD;            {time to wait with no data before return}
  dwTimeOut: DWORD;             {time to wait with data before return}
  end;


{Information structure for DapBufferPutEx() function.}
TDapBufferPutEx = packed record
  iInfoSize: Integer;           {size of this info structure}
  iBytesPut: Integer;           {number of bytes to put}
  dwTimeWait: DWORD;            {longest time in milliseconds to wait}
  dwTimeOut: DWORD;             {longest time in milliseconds to put all}
  end;


{Information structure for DapCommandDownloadA() and
DapCommandDownload() function.}
TDapCommandDownloadA = packed record
  iInfoSize: Integer;
  hdapSysPut: TDapHandle;
  hdapSysGet: TDapHandle;
  pszCCFileName: PANSIChar;
  pszCCName: PANSIChar;
  iCCStackSize: Integer;
  end;
  
TDapCommandDownload = TDapCommandDownloadA;


{Information query structure for DapHandleQueryA() and
DapHandleQuery() function.}

{If QueryResult is a DWORD, it is returned in QueryResult.dw;
otherwise, it is returned as a double null terminated multiple
string in a user-provided buffer QueryResult.psz points to.
If iBufferSize is 0, the result will be dword; otherwise, it will
be a string, and this field is the size of the user-provided buffer.}

TDapHandleQueryA = packed record
    iInfoSize: Integer;             {size of this info structure}
    pszQueryKey: PANSIChar;             {pointer to a query key string}
    QueryResult: packed record 
      case integer of
        0: (psz: PANSIChar);
        1: (dw: DWORD);
      end;
    iBufferSize: Integer;
end;

TDapHandleQuery = TDapHandleQueryA;


{Function only supported under Windows NT}
function DapComPipeCreateA(pszPipeInfo: PANSIChar): Boolean; stdcall;
function DapComPipeCreate(pszPipeInfo: PANSIChar): Boolean; stdcall;
function DapComPipeDeleteA(pszPipeInfo: PANSIChar): Boolean; stdcall;
function DapComPipeDelete(pszPipeInfo: PANSIChar): Boolean; stdcall;
function DapHandleQueryA(hAccel: TDapHandle;
  var pHandleInfor: TDapHandleQueryA): Boolean; stdcall;
function DapHandleQuery(hAccel: TDapHandle;
  var pHandleInfor: TDapHandleQuery): Boolean; stdcall;

{Functions supported by all versions of DAPIO32 DLL}
function DapHandleClose(hAccel: TDapHandle): Boolean; stdcall;
function DapHandleOpenA(pszAccelName: PANSIChar;
  ulOpenFlags: DWORD): TDapHandle; stdcall;
function DapHandleOpen(pszAccelName: PANSIChar;
  ulOpenFlags: DWORD): TDapHandle; stdcall;
function DapInputAvail(hAccel: TDapHandle): Integer; stdcall;
function DapOutputSpace(hAccel: TDapHandle): Integer; stdcall;

function DapBufferGet(hAccel: TDapHandle; iLength: Integer;
  var pvBuffer): Integer; stdcall;
function DapBufferGetEx(hAccel: TDapHandle; const pGetInfo: TDapBufferGetEx;
  var pvBuffer): Integer; stdcall;  
function DapBufferPut(hAccel: TDapHandle; iLength: Integer;
  const pvBuffer): Integer; stdcall;
function DapBufferPutEx(hAccel: TDapHandle; const pPutInfo: TDapBufferPutEx;
  const pvBuffer): Integer; stdcall;
function DapCharGetA(hAccel: TDapHandle; pch: PANSIChar): Boolean; stdcall;
function DapCharGet(hAccel: TDapHandle; pch: PANSIChar): Boolean; stdcall;
function DapCharPutA(hAccel: TDapHandle; ch: ANSIChar): Boolean; stdcall;
function DapCharPut(hAccel: TDapHandle; ch: ANSIChar): Boolean; stdcall;
function DapCommandDownloadA(const pdcdl: TDapCommandDownloadA): Boolean; stdcall;
function DapCommandDownload(const pdcdl: TDapCommandDownload): Boolean; stdcall;

function DapConfigA(hAccel: TDapHandle; pszDaplFilename: PANSIChar): Boolean; stdcall;
function DapConfig(hAccel: TDapHandle; pszDaplFilename: PANSIChar): Boolean; stdcall;
function DapConfigParamsClear: Boolean; stdcall;
function DapConfigParamSetA(iParamNumber: Integer; pszParam: PANSIChar): Boolean; stdcall;
function DapConfigParamSet(iParamNumber: Integer; pszParam: PANSIChar): Boolean; stdcall;
function DapConfigRedirectA(pszOutputFilename: PANSIChar): Boolean; stdcall;
function DapConfigRedirect(pszOutputFilename: PANSIChar): Boolean; stdcall;
function DapInputFlush(hAccel: TDapHandle): Integer; stdcall;
function DapInputFlushEx(hAccel: TDapHandle; dwTimeOut: DWORD;
  dwTimeWait: DWORD; var pdwFlushed: DWORD): Boolean; stdcall;
function DapOutputEmpty(hAccel: TDapHandle): Boolean; stdcall;
  
function DapInt16Get(hAccel: TDapHandle; var pi16: Smallint): Boolean; stdcall;
function DapInt16Put(hAccel: TDapHandle; i16: Smallint): Boolean; stdcall;
function DapInt32Get(hAccel: TDapHandle; var pi32: Longint): Boolean; stdcall;
function DapInt32Put(hAccel: TDapHandle; i32: Longint): Boolean; stdcall;
function DapLastErrorTextGetA(pszError: PANSIChar; iLength: Integer): PANSIChar; stdcall;
function DapLastErrorTextGet(pszError: PANSIChar; iLength: Integer): PANSIChar; stdcall;

function DapLineGetA(hAccel: TDapHandle; iLength: Integer; psz: PANSIChar; dwTimeWait: DWORD): Integer; stdcall;
function DapLineGet(hAccel: TDapHandle; iLength: Integer; psz: PANSIChar; dwTimeWait: DWORD): Integer; stdcall;
function DapLinePutA(hAccel: TDapHandle; psz: PANSIChar): Integer; stdcall;
function DapLinePut(hAccel: TDapHandle; psz: PANSIChar): Integer; stdcall;
function DapStringGetA(hAccel: TDapHandle; iLength: Integer; psz: PANSIChar): Boolean; stdcall;
function DapStringGet(hAccel: TDapHandle; iLength: Integer; psz: PANSIChar): Boolean; stdcall;
function DapStringPutA(hAccel: TDapHandle; psz: PANSIChar): Boolean; stdcall;
function DapStringPut(hAccel: TDapHandle; psz: PANSIChar): Boolean; stdcall;

function DapLastErrorGet: string;

implementation

const
  DapioDll = 'dapio32.dll';

function DapComPipeCreateA; external DapioDll name 'DapComPipeCreateA';
function DapComPipeCreate;  external DapioDll name 'DapComPipeCreateA';
function DapComPipeDeleteA; external DapioDll name 'DapComPipeDeleteA';
function DapComPipeDelete;  external DapioDll name 'DapComPipeDeleteA';
function DapHandleQueryA;   external DapioDll name 'DapHandleQueryA';
function DapHandleQuery;    external DapioDll name 'DapHandleQueryA';

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

function DapLineGetA;   external DapioDll name 'DapLineGetA';
function DapLineGet;    external DapioDll name 'DapLineGetA';
function DapLinePutA;   external DapioDll name 'DapLinePutA';
function DapLinePut;    external DapioDll name 'DapLinePutA';
function DapStringGetA; external DapioDll name 'DapStringGetA';
function DapStringGet;  external DapioDll name 'DapStringGetA';
function DapStringPutA; external DapioDll name 'DapStringPutA';
function DapStringPut;  external DapioDll name 'DapStringPutA';


function DapLastErrorGet: string;
var
  acError: Array [0..1023] of ANSIChar;
begin
  DapLastErrorTextGet(acError,SizeOf(acError));
  Result := StrPas(acError);
end;


end.
