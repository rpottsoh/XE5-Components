unit DISChannel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls, OvcBase, OvcEF, OvcPB, OvcNF;

type
  TInputType = (itNumeric, itChannel, itFloat, itSensor, itMultiChan);
  TMultiChan = array[1..4] of integer;
  TfrmDISChannel = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    pnlChannel: TPanel;
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
    Panel2: TPanel;
    Label1: TLabel;
    lblInstruction: TLabel;
    RadioButton34: TRadioButton;
    RadioButton35: TRadioButton;
    pnlNumeric: TPanel;
    OvcController1: TOvcController;
    fldNumeric: TOvcNumericField;
    pnlFloat: TPanel;
    fldFloat: TOvcNumericField;
    pnlSensor: TPanel;
    RadioButton36: TRadioButton;
    RadioButton38: TRadioButton;
    RadioButton39: TRadioButton;
    RadioButton41: TRadioButton;
    RadioButton37: TRadioButton;
    RadioButton40: TRadioButton;
    pnlMultiChan: TPanel;
    chkbx1: TCheckBox;
    chkbx4: TCheckBox;
    chkbx5: TCheckBox;
    chkbx6: TCheckBox;
    chkbx7: TCheckBox;
    chkbx8: TCheckBox;
    chkbx2: TCheckBox;
    chkbx3: TCheckBox;
    chkbx9: TCheckBox;
    chkbx12: TCheckBox;
    chkbx13: TCheckBox;
    chkbx14: TCheckBox;
    chkbx15: TCheckBox;
    chkbx16: TCheckBox;
    chkbx10: TCheckBox;
    chkbx11: TCheckBox;
    chkbx25: TCheckBox;
    chkbx28: TCheckBox;
    chkbx29: TCheckBox;
    chkbx30: TCheckBox;
    chkbx31: TCheckBox;
    chkbx32: TCheckBox;
    chkbx26: TCheckBox;
    chkbx27: TCheckBox;
    chkbx17: TCheckBox;
    chkbx18: TCheckBox;
    chkbx19: TCheckBox;
    chkbx20: TCheckBox;
    chkbx21: TCheckBox;
    chkbx22: TCheckBox;
    chkbx23: TCheckBox;
    chkbx24: TCheckBox;
    chkbx33: TCheckBox;
    chkbx34: TCheckBox;
    chkbx35: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
//    procedure SpeedButton11Click(Sender: TObject);
//    procedure SpeedButton12Click(Sender: TObject);
//    procedure SpeedButton1Click(Sender: TObject);
//    procedure SpeedButton13Click(Sender: TObject);
//    procedure SpeedButton14Click(Sender: TObject);
//    procedure SpeedButton2Click(Sender: TObject);
  private
    FRadioVal : integer;
    FCheckedMulti : TMultiChan;
    FRadioFloat : double;
    InputType : TInputType;
    { Private declarations }
  public
    { Public declarations }
  end;

  TDISChannel = class(TComponent)
  private
    { Private declarations }
    DISChannelForm: TfrmDISChannel;
    FChanVal : integer;
    FFloatVal : double;
    FCaption : string;
    FInstruction : string;
    FInputType : TInputType;
    FMultiVal : TMultiChan;
    function GetAsInteger: integer;
    function GetAsFloat: double;
    function GetAsMultiChan : TMultiChan;
    procedure SetAsInteger(Value:integer);
    procedure SetAsFloat(Value:double);
    procedure SetAsMultiChan(Value:TMultiChan);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;
    function Execute: boolean;
    property InputType : TInputType
      write FInputType;
    property Caption : string
      write FCaption;
    property Instruction : string
      write FInstruction;
    property AsInteger : integer
      read GetAsInteger
      write SetAsInteger;
    property AsFloat : double
      read GetAsFloat
      write SetAsFloat;
    property AsMultiChan : TMultiChan
      read GetAsMultiChan
      write SetAsMultiChan;
  published
    { Published declarations }
  end;

var
  frmDISChannel: TfrmDISChannel;

implementation

{$R *.DFM}

constructor TDISChannel.Create;
begin
  inherited create(AOwner);
  FChanVal := 0;
  FFloatVal := 0.0;
  DISChannelForm := TfrmDISChannel.create(nil);
end;

destructor TDISChannel.destroy;
begin
  DISChannelForm.free;
  inherited destroy;
end;

function TDISChannel.GetAsInteger: integer;
begin
  result := FChanVal;
end;

function TDISChannel.GetAsMultiChan: TMultiChan;
begin
  result := FMultiVal;
end;

procedure TDISChannel.SetAsMultiChan(Value:TMultiChan);
begin
  FMultiVal := Value;
end;

procedure TDISChannel.SetAsInteger(Value:integer);
begin
  FChanVal := Value;
end;

function TDISChannel.GetAsFloat: double;
begin
  result := FFloatVal;
end;

procedure TDISChannel.SetAsFloat(Value:double);
begin
  FFloatVal := Value;
end;

function TDISChannel.Execute : boolean;
var
    ClickedOk : boolean;
    tempRadioButton : TComponent;
    i, code : integer;
begin
  DISChannelForm.Caption := FCaption;
  DISChannelForm.lblInstruction.Caption := FInstruction;
  DISChannelForm.pnlChannel.Visible := FALSE;
  DISChannelForm.pnlNumeric.Visible := FALSE;
  DISChannelForm.pnlFloat.Visible := FALSE;
  DISChannelForm.pnlSensor.Visible := FALSE;
  DISChannelForm.pnlMultiChan.Visible := FALSE;
  DISChannelForm.InputType := FInputType;
  case FInputType of
    itNumeric : DISChannelForm.pnlNumeric.Visible := TRUE;
    itChannel : DISChannelForm.pnlChannel.Visible := TRUE;
    itFloat   : DISChannelForm.pnlFloat.Visible := TRUE;
    itSensor  : DISChannelForm.pnlSensor.Visible := TRUE;
    itMultiChan : DISChannelForm.pnlMultiChan.Visible := TRUE;
  end;
  ClickedOk := DISChannelForm.ShowModal = mrok;
  if ClickedOK then
  begin
    if FInputType = itFloat then
      FFloatVal := DISChannelForm.FRadioFloat
    else if FInputType = itMultiChan then
    begin
      FMultiVal := DISChannelForm.FCheckedMulti;
    end
    else
      FChanVal := DISChannelForm.FRadioVal;
  end;
  result := ClickedOK;
end;

{DISChannel Form}


procedure TfrmDISChannel.FormClose(Sender: TObject;
  var Action: TCloseAction);
  var i : integer;
  tempRadioButton : TComponent;
  code : integer;
  chan : integer;
  begin
    case InputType of
    itChannel: begin
                 for i := 1 to 35 do
                 begin
                   tempRadioButton := FindComponent(format('RadioButton%d',[i]));
                   if (tempRadioButton As TRadioButton).Checked then
                   begin
                     if (tempRadioButton As TRadioButton).Caption = 'All' then
                       FRadioVal := 0
                     else
                       val((tempRadioButton As TRadioButton).Caption,FRadioVal, code );
                     break;
                   end;
                 end;
               end;
    itMultiChan: begin
                 chan := 1;
                 for i := 1 to 35 do
                 begin
                   tempRadioButton := FindComponent(format('chkbx%d',[i]));
                   if (tempRadioButton As TCheckBox).Checked then
                   begin
                     val((tempRadioButton As TCheckBox).Caption,FCheckedMulti[chan], code );
                     inc(chan);
                     if chan = 5 then
                       break;
                   end;
                 end;
               end;
    itNumeric: begin
                 FRadioVal := fldNumeric.AsInteger;
               end;
    itFloat: begin
                 FRadioFloat := fldFloat.AsFloat;
               end;
    itSensor: begin
                 for i := 36 to 41 do
                 begin
                   tempRadioButton := FindComponent(format('RadioButton%d',[i]));
                   if (tempRadioButton As TRadioButton).Checked then
                   begin
                     FRadioVal := (tempRadioButton As TRadioButton).Tag;
                     break;
                   end;
                 end;
               end;
    end;
end;

end.
