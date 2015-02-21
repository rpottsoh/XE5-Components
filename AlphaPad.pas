unit AlphaPad;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TfrmAlphaPad = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
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
    SpeedButton15: TSpeedButton;
    SpeedButton16: TSpeedButton;
    SpeedButton17: TSpeedButton;
    SpeedButton18: TSpeedButton;
    SpeedButton19: TSpeedButton;
    SpeedButton20: TSpeedButton;
    SpeedButton21: TSpeedButton;
    SpeedButton22: TSpeedButton;
    SpeedButton23: TSpeedButton;
    SpeedButton24: TSpeedButton;
    SpeedButton25: TSpeedButton;
    SpeedButton26: TSpeedButton;
    SpeedButton27: TSpeedButton;
    SpeedButton28: TSpeedButton;
    SpeedButton29: TSpeedButton;
    SpeedButton30: TSpeedButton;
    SpeedButton31: TSpeedButton;
    SpeedButton32: TSpeedButton;
    SpeedButton33: TSpeedButton;
    SpeedButton34: TSpeedButton;
    SpeedButton35: TSpeedButton;
    SpeedButton36: TSpeedButton;
    SpeedButton37: TSpeedButton;
    SpeedButton38: TSpeedButton;
    SpeedButton39: TSpeedButton;
    SpeedButton40: TSpeedButton;
    SpeedButton41: TSpeedButton;
    SpeedButton42: TSpeedButton;
    SpeedButton43: TSpeedButton;
    PassPanel: TPanel;
    procedure SpeedButton27Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TAlphaPad = class(TComponent)
  private
    { Private declarations }
    FAlphaPad : TfrmAlphaPad;
    FAlphaVal : string;
    FCaption : string;
    FPassMask : String;
    FPasswordMode : Boolean;
    procedure SetCaption(const Value : string);
    procedure SetPasswordMode( Value : Boolean );
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor create(AOwner: TComponent); override;
    destructor destroy; override;
    function execute: boolean;
    property AsString : string
      read FAlphaVal
      write FAlphaVal;
  published
    { Published declarations }
    property Caption : string
      read FCaption
      write SetCaption;
    property PasswordMode : Boolean
      read FPasswordMode
      write SetPasswordMode;
  end;


implementation

{$R *.DFM}

constructor TAlphaPad.Create;
begin
  inherited create(AOwner);
  FAlphaVal := '';
  FPassMask := '';
  FCaption := '';
  FPasswordMode := False;
  FAlphaPad := TfrmAlphaPad.create(nil);
  FAlphaPad.Caption := FCaption;
  FAlphaPad.panel1.Caption := FAlphaVal;
  FAlphaPad.PassPanel.Tag := 0;
end;

destructor TAlphaPad.Destroy;
begin
  FAlphaPad.free;
  inherited destroy;
end;

procedure TAlphaPad.SetPasswordMode( Value : Boolean );
begin
   FPasswordMode := Value;
   FAlphaPad.Panel1.Caption := '';
   FAlphaPad.PassPanel.Tag := ord(Value);
end; // TAlphaPad.SetPasswordMode

function TAlphaPad.Execute: boolean;
begin
  result := false;
  FAlphaPad.PassPanel.Visible := FPasswordMode;
  if assigned(FAlphaPad) then
  begin
    if FPasswordMode = False then
    begin
       FAlphaPad.Panel1.Caption := FAlphaVal;
       result := FAlphaPad.Showmodal = mrok;
       if result then
          FAlphaVal := FAlphaPad.Panel1.Caption;
    end
    else
    begin
       FAlphaPad.PassPanel.Caption := FPassMask;
       result := FAlphaPad.ShowModal = mrok;
       if result then
       begin
          FPassMask := FAlphaPad.PassPanel.Caption;
          FAlphaVal := FAlphaPad.Panel1.Caption;
          FAlphaPad.Panel1.Caption := '';
       end; // IF
    end; // IF
  end;
end;

procedure TAlphaPad.SetCaption(const Value : string);
begin
  if Value <> FCaption then
  begin
    FCaption := Value;
    if assigned(FAlphaPad) then
      FAlphaPad.Caption := FCaption;
  end;
end;

procedure TfrmAlphaPad.SpeedButton27Click(Sender: TObject);
var WorkStr : string;
    TagVal  : integer;
    vTemp   : string;
    i       : integer;
begin
   WorkStr := panel1.Caption;
   tagVal := (sender as TSpeedbutton).tag;
   case tagval of
     16 : WorkStr := '';
     8  : delete(WorkStr,length(workStr),1);
     28 : WorkStr := WorkStr + ' ';
   else
      begin
         WorkStr := WorkStr + chr(tagval);
           if PassPanel.Tag = 1 then
              for i := 1 to Length(WorkStr) do vTemp := vTemp + '***';
      end;
   end; //case
   if PassPanel.Tag = 1 then
   begin
      PassPanel.Caption := vTemp;
   end; // If
   panel1.Caption := WorkStr;
end;


end.
