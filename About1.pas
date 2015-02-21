unit About1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TDioXAbout = class(TForm)
    CtlImage: TSpeedButton;
    NameLbl: TLabel;
    OkBtn: TButton;
    CopyrightLbl: TLabel;
    DescLbl: TLabel;
  end;

procedure ShowDioXAbout;

implementation

{$R *.DFM}

procedure ShowDioXAbout;
begin
  with TDioXAbout.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

end.
