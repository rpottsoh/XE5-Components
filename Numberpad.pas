unit Numberpad;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls;

type
  TfrmNumberPad = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure SpeedButton11Click(Sender: TObject);
    procedure SpeedButton12Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton13Click(Sender: TObject);
    procedure SpeedButton14Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TNumberPad = class(TComponent)
  private
    { Private declarations }
    NumberPadForm: TfrmNumberPad;
    FPadVal : double;
    function GetAsInteger: integer;
    procedure SetAsInteger(Value:integer);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor create(AOwner : TComponent); override;
    destructor destroy; override;
    function Execute: boolean;
    property AsFloat : double
      read FPadVal
      write FPadVal;
    property AsInteger : integer
      read GetAsInteger
      write SetAsInteger;
  published
    { Published declarations }
  end;

var
  frmNumberPad: TfrmNumberPad;

implementation

{$R *.DFM}

constructor TNumberpad.Create;
begin
  inherited create(AOwner);
  FPadVal := 0.0;
  NumberPadForm := TfrmNumberPad.create(nil);
end;

destructor TNumberPad.destroy;
begin
  NumberPadForm.free;
  inherited destroy;
end;

function TNumberPad.GetAsInteger: integer;
begin
  result := trunc(FPadVal);
end;

procedure TNumberPad.SetAsInteger(Value:integer);
begin
  FPadVal := Value;
end;

function TNumberpad.Execute : boolean;
var workstr : string;
    ClickedOk : boolean;
begin
  if frac(FpadVal) = 0.0 then
    workStr := FloattoStrF(FPadVal,fffixed,10,0)
  else
    workstr := floattostrf(FpadVal,fffixed,10,8);
  if FPadVal = 0.0 then
    workstr := '';
  NumberPadForm.Panel1.caption := workstr;
  ClickedOk := NumberPadForm.ShowModal = mrok;
  if ClickedOK then
  begin
    workstr := NumberPadForm.Panel1.caption;
    if length(workstr) > 0 then
    begin
      FPadVal := strtofloat(WorkStr);
    end
    else
      FPadVal := 0.0;
  end;
  result := ClickedOK;
end;

{NumberPad Form}

procedure TfrmNumberPad.SpeedButton11Click(Sender: TObject);
var workstr : string;
begin
  workstr := panel1.caption;
  if length(workstr) = 0 then
    workstr := '-'
  else
  if WorkStr[1] <> '-' then
    insert('-',WorkStr,1)
  else
    delete(Workstr,1,1);
  panel1.caption := workstr;
end;

procedure TfrmNumberPad.SpeedButton12Click(Sender: TObject);
var workstr : string;
    FoundAt : integer;
begin
  workstr := panel1.caption;
  if length(workstr) = 0 then
    workstr := '0.'
  else
  begin
    FoundAt := pos('.',WorkStr);
    if Workstr = '-' then
      workstr := workstr + '0.'
    else
    if FoundAt = 0 then
      WorkStr := WorkStr + '.';
  end;
  panel1.caption := workstr;
end;

procedure TfrmNumberPad.SpeedButton1Click(Sender: TObject);
var workstr : string;
begin
  workstr := panel1.caption;
  if length(WorkStr) <> 0 then
    WorkStr := WorkStr + '0';
  Panel1.Caption := WorkStr;
end;

procedure TfrmNumberPad.SpeedButton13Click(Sender: TObject);
begin
  panel1.Caption := '';
end;

procedure TfrmNumberPad.SpeedButton14Click(Sender: TObject);
var workstr : string;
begin
  workstr := Panel1.caption;
  if length(workstr) <> 0 then
    delete(WorkStr,length(workstr),1);
  panel1.caption := workstr;
end;

procedure TfrmNumberPad.SpeedButton2Click(Sender: TObject);
var workstr : string;
begin
  workstr := panel1.caption;
  workstr := workstr + inttostr((sender as TSpeedbutton).tag);
  panel1.caption := workstr;
end;

end.
