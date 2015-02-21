unit PickList;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TPickList = class(TComponent)
  private
    { Private declarations }
    FShortNames   : TStrings;
    FLongNames    : TStrings;
  protected
    { Protected declarations }
  public
    { Public declarations }
    Constructor Create( AOwner : TComponent ); OverRide;
    Destructor  Destroy; OverRide;
  published
    { Published declarations }
    property ShortNames : TStrings Read FShortNames Write FShortNames;
    property LongNames : TStrings Read FLongNames Write FLongNames;
  end;


implementation

constructor TPickList.Create;
begin
  inherited create( AOwner );
  FShortNames := TStringList.Create;
  FLongNames := TStringList.Create;
end;

destructor TPickList.Destroy;
begin
  FShortNames.clear;
  FLongNames.Clear;
  FShortNames.Free;
  FLongNames.Free;
  inherited Destroy;
end;

end.
