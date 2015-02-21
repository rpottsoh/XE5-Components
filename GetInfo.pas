unit GetInfo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TfrmGetInfo = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Edit1: TEdit;
    Label1: TLabel;
    procedure Edit1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

{var
  frmGetInfo: TfrmGetInfo;{}
  function Get_Info(x,y : integer;
                    const ACaption, APrompt : string;
                    var Value : string): Boolean;

implementation

{$R *.DFM}
function Get_Info(x,y : integer;
                  const ACaption, APrompt : string;
                  var Value : string): Boolean;
var MResult : word;
begin
  Result := false;
  with TfrmGetInfo.create(nil) do
    try
      left := x;
      top := y;
      caption := ACaption;
      label1.caption := APrompt;
      Edit1.Text := Value;
      MResult := showmodal;
      if MResult = mrok then
      begin
        Value := Edit1.Text;
        result := true;
      end;
    finally
      free;
    end;
end;

procedure TfrmGetInfo.Edit1Click(Sender: TObject);
begin
  edit1.SelectAll;
end;

end.
