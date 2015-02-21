unit MultiLineBtn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  THorizAlign = (halLeft,halRight,halCentre);
  TVerticalAlign = (valTop,valBottom,valCentre);

  TMultiLineBtn = class(TButton)
  private
    { Private declarations }
    fMultiLine: Boolean;
    fHorizAlign : THorizAlign;
    fVerticalAlign :TVerticalAlign;
    procedure SetMultiLine(Value: Boolean);
    procedure SetHorizAlign(Value: THorizAlign);
    procedure SetVerticalAlign(Value: TVerticalAlign);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property HorizAlign: THorizAlign read fHorizAlign write setHorizAlign default halCentre;
    property VerticalAlign :TVerticalAlign read fVerticalAlign write setVerticalAlign default valCentre;
    property MultiLine: Boolean read fMultiLine write SetMultiLine default True;
  end;

procedure Register;

implementation

constructor TMultiLineBtn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fMultiLine     :=True;
  fHorizAlign    := halCentre;
  fVerticalAlign := valCentre;
end;

procedure TMultiLineBtn.SetVerticalAlign(Value: TVerticalAlign);
begin
  if fVerticalAlign<>Value then
  begin
    fVerticalAlign:=Value;
    RecreateWnd;
  end;
end;

procedure TMultiLineBtn.SetHorizAlign(Value: THorizAlign);
begin
  if fHorizAlign<>Value then
  begin
    fHorizAlign:=Value;
    RecreateWnd;
  end;
end;

procedure TMultiLineBtn.SetMultiLine(Value: Boolean);
begin
  if fMultiLine<>Value then
  begin
    fMultiLine:=Value;
    RecreateWnd;
  end;
end;

procedure TMultiLineBtn.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  case VerticalAlign of
    valTop    :  Params.Style:=Params.Style or BS_TOP;
    valBottom :  Params.Style:=Params.Style or BS_BOTTOM;
    valCentre :  Params.Style:=Params.Style or BS_VCENTER;
  end;

  case HorizAlign of
    halLeft   :  Params.Style:=Params.Style or BS_LEFT;
    halRight  :  Params.Style:=Params.Style or BS_RIGHT;
    halCentre :  Params.Style:=Params.Style or BS_CENTER;
  end;

  if MultiLine then
    Params.Style:=Params.Style or BS_MULTILINE
  else
    Params.Style:=Params.Style and not BS_MULTILINE;
end;


procedure Register;
begin
  RegisterComponents('TMSI', [TMultiLineBtn]);
end;

end.
