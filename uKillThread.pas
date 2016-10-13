unit uKillThread;

interface

uses Classes, Windows, SysUtils;

procedure AbortThread(const Th: TThread);

implementation

// Exception to be raized on thread abort.
type EThreadAbort = class(EAbort);

// Procedure to raize the exception. Needs to be a simple, parameterless procedure
// to simplify pointing the thread to this routine.
procedure RaizeThreadAbort;
begin
  raise EThreadAbort.Create('Thread was aborted using AbortThread()');
end;

procedure AbortThread(const Th: TThread);
const AlignAt = SizeOf(DWORD); // Undocumented; Apparently the memory used for _CONTEXT needs to be aligned on DWORD boundary
var Block:array[0..SizeOf(_CONTEXT)+512] of Byte; // The _CONTEXT structure is probably larger then what Delphi thinks it should be. Unless I provide enough padding space, GetThreadContext fails
    ThContext: PContext;
begin
  SuspendThread(Th.Handle);
  ZeroMemory(@Block, SizeOf(Block));
  ThContext := PContext(((Integer(@Block) + AlignAt - 1) div AlignAt) * AlignAt);
  ThContext.ContextFlags := CONTEXT_FULL;
  if not GetThreadContext(Th.Handle, ThContext^) then
    RaiseLastOSError;
  ThContext.Eip := Cardinal(@RaizeThreadAbort); // Change EIP so we can redirect the thread to our error-raizing routine
  SetThreadContext(Th.Handle, ThContext^);
  ResumeThread(Th.Handle);
end;

end.