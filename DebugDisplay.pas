unit DebugDisplay;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmDebugMsgs = class(TForm)
    MemoDebug: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDebugMsgs: TfrmDebugMsgs;
  DebugModeEngaged : boolean;
  Procedure Display_Debug_Message(dbgmsg : string);
  procedure Destroy_Debug_Message_Display;
  procedure Hide_Debug_Message_Display;

implementation

{$R *.DFM}
procedure Destroy_Debug_Message_Display;
begin
  if assigned(frmDebugMsgs) then
  begin
    Hide_Debug_Message_Display;
    frmDebugMsgs.free;
  end;
  frmDebugMsgs := nil;
end;

procedure Hide_Debug_Message_Display;
begin
  if assigned(frmDebugMsgs) then
    if frmDebugMsgs.Visible then
      frmDebugMsgs.close;
end;

Procedure Display_Debug_Message(dbgmsg : string);
begin
  if DebugModeEngaged then
  begin
    if not assigned(frmDebugMsgs) then
      frmDebugMsgs := TfrmDebugMsgs.create(nil);
    if uppercase(dbgmsg) = '!!CLEAR' then
      frmDebugMsgs.MemoDebug.Clear
    else
      frmDebugMsgs.MemoDebug.Lines.Add(dbgmsg);
    if not frmDebugMsgs.Visible then
      frmDebugMsgs.Show;
  end;
end;

initialization
  DebugModeEngaged := false;
  frmDebugMsgs := nil;

finalization
  Destroy_Debug_Message_Display;
end.
