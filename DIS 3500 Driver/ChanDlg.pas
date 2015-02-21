unit ChanDlg;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms;

type
  TfrmChanDlg = class(TForm)
    Button2: TButton;
    RadioGroup1: TRadioGroup;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    RadioButton11: TRadioButton;
    RadioButton12: TRadioButton;
    RadioButton13: TRadioButton;
    RadioButton14: TRadioButton;
    RadioButton15: TRadioButton;
    RadioButton16: TRadioButton;
    RadioButton17: TRadioButton;
    RadioButton18: TRadioButton;
    RadioButton19: TRadioButton;
    RadioButton20: TRadioButton;
    RadioButton21: TRadioButton;
    RadioButton22: TRadioButton;
    RadioButton23: TRadioButton;
    RadioButton24: TRadioButton;
    RadioButton25: TRadioButton;
    RadioButton26: TRadioButton;
    RadioButton27: TRadioButton;
    RadioButton28: TRadioButton;
    RadioButton29: TRadioButton;
    RadioButton30: TRadioButton;
    RadioButton31: TRadioButton;
    RadioButton32: TRadioButton;
    RadioButton33: TRadioButton;
    Button1: TButton;
    procedure RadioButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    public
      Channel : integer;
  end;

var
  frmChanDlg: TfrmChanDlg;

implementation

{$R *.DFM}

procedure TfrmChanDlg.RadioButton1Click(Sender: TObject);
var chan, code : integer;
  cap : string;
begin
  val((Sender As TRadioButton).Caption, chan, code );
  if code <> 0 then
    chan := 33;
  Channel := Chan;
end;

procedure TfrmChanDlg.FormShow(Sender: TObject);
begin
  Channel := 0;
end;

end.
