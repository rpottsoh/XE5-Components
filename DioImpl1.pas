unit DioImpl1;

interface

uses
  Windows, ActiveX, Classes, Controls, Graphics, Menus, Forms, StdCtrls,
  ComServ, StdVCL, AXCtrls, DioXControl_TLB, DioCtrl;

type
  TDioX = class(TActiveXControl, IDioX)
  private
    { Private declarations }
    FDelphiControl: TDio;
    FEvents: IDioXEvents;
    procedure InputChangeEvent(Sender: TObject);
    procedure SingleBitChangeEvent(Sender: TObject; BitNumber: Integer;
      BitState: Boolean);
  protected
    { Protected declarations }
    procedure InitializeControl; override;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage); override;
    function Get_BoardInitialized: WordBool; safecall;
    function Get_BoardNum: Integer; safecall;
    function Get_BoardType: TxtBoardType; safecall;
    function Get_Cursor: Smallint; safecall;
    function Get_Enabled: WordBool; safecall;
    function Get_InputBitsCount: Integer; safecall;
    function Get_Interval: Integer; safecall;
    function Get_OutputBitsCount: Integer; safecall;
    function Get_Visible: WordBool; safecall;
    function Momentary(Index: Integer): WordBool; safecall;
    function True_Bit_Number(PortDirection: TxtDirectionType;
      BitNum: Integer): Integer; safecall;
    procedure About; safecall;
    procedure AboutBox; safecall;
    procedure ClearBits; safecall;
    procedure InitializeDio; safecall;
    procedure InvertBits; safecall;
    procedure Set_BoardNum(Value: Integer); safecall;
    procedure Set_BoardType(Value: TxtBoardType); safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure Set_Interval(Value: Integer); safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    procedure SetBits; safecall;
    procedure ToggleBit(Bitnum: Integer); safecall;
  end;

implementation

uses About1;

{ TDioX }

procedure TDioX.InitializeControl;
begin
  FDelphiControl := Control as TDio;
  FDelphiControl.OnInputChange := InputChangeEvent;
  FDelphiControl.OnSingleBitChange := SingleBitChangeEvent;
end;

procedure TDioX.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as IDioXEvents;
end;

procedure TDioX.DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
begin
  { Define property pages here.  Property pages are defined by calling
    DefinePropertyPage with the class id of the page.  For example,
      DefinePropertyPage(Class_DioXPage); }
end;

function TDioX.Get_BoardInitialized: WordBool;
begin
  Result := FDelphiControl.BoardInitialized;
end;

function TDioX.Get_BoardNum: Integer;
begin
  Result := FDelphiControl.BoardNum;
end;

function TDioX.Get_BoardType: TxtBoardType;
begin
  Result := Ord(FDelphiControl.BoardType);
end;

function TDioX.Get_Cursor: Smallint;
begin
  Result := Smallint(FDelphiControl.Cursor);
end;

function TDioX.Get_Enabled: WordBool;
begin
  Result := FDelphiControl.Enabled;
end;

function TDioX.Get_InputBitsCount: Integer;
begin
  Result := FDelphiControl.InputBitsCount;
end;

function TDioX.Get_Interval: Integer;
begin
  Result := Integer(FDelphiControl.Interval);
end;

function TDioX.Get_OutputBitsCount: Integer;
begin
  Result := FDelphiControl.OutputBitsCount;
end;

function TDioX.Get_Visible: WordBool;
begin
  Result := FDelphiControl.Visible;
end;

function TDioX.Momentary(Index: Integer): WordBool;
begin

end;

function TDioX.True_Bit_Number(PortDirection: TxtDirectionType;
  BitNum: Integer): Integer;
begin

end;

procedure TDioX.About;
begin
  FDelphiControl.About;
end;

procedure TDioX.AboutBox;
begin
  ShowDioXAbout;
end;

procedure TDioX.ClearBits;
begin
  FDelphiControl.ClearBits;
end;

procedure TDioX.InitializeDio;
begin
  FDelphiControl.InitializeDio;
end;

procedure TDioX.InvertBits;
begin
  FDelphiControl.InvertBits;
end;

procedure TDioX.Set_BoardNum(Value: Integer);
begin
  FDelphiControl.BoardNum := Value;
end;

procedure TDioX.Set_BoardType(Value: TxtBoardType);
begin
  FDelphiControl.BoardType := tBoardType(Value);
end;

procedure TDioX.Set_Cursor(Value: Smallint);
begin
  FDelphiControl.Cursor := TCursor(Value);
end;

procedure TDioX.Set_Enabled(Value: WordBool);
begin
  FDelphiControl.Enabled := Value;
end;

procedure TDioX.Set_Interval(Value: Integer);
begin
  FDelphiControl.Interval := Cardinal(Value);
end;

procedure TDioX.Set_Visible(Value: WordBool);
begin
  FDelphiControl.Visible := Value;
end;

procedure TDioX.SetBits;
begin
  FDelphiControl.SetBits;
end;

procedure TDioX.ToggleBit(Bitnum: Integer);
begin

end;

procedure TDioX.InputChangeEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnInputChange;
end;

procedure TDioX.SingleBitChangeEvent(Sender: TObject; BitNumber: Integer;
  BitState: Boolean);
begin
  if FEvents <> nil then FEvents.OnSingleBitChange(BitNumber, WordBool(BitState));
end;

initialization
  TActiveXControlFactory.Create(
    ComServer,
    TDioX,
    TDio,
    Class_DioX,
    1,
    '{6EE6E398-AB16-11D2-8E80-00105A09424D}',
    0);
end.
