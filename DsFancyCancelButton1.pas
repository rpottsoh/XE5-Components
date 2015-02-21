unit DsFancyCancelButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DsFancyButton;

type
  TDsFancyCancelButton = class(TDsFancyButton)
  private
    { Private declarations }
    FCancel : boolean;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor destroy; override;
  published
    { Published declarations }
    property Cancel : boolean read FCancel write FCancel;
  end;

procedure Register;

implementation

constructor TDsFancyCancelButton.create;


procedure Register;
begin
  RegisterComponents('Fancy Compo', [TDsFancyCancelButton1]);
end;

end.
