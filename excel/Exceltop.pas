{*******************************************************}
{       TExcel Component Demo for Delphi 1.0 .. 3.0     }
{                                                       }
{       Copyright (c) 1996 ... 1998 Tibor F. Liska      }
{       Tel/Fax:    00-36-1-165-2019                    }
{       Office:     00-36-1-209-5284                    }
{       E-mail: liska@sztaki.hu                         }
{*******************************************************}
unit ExcelTop;

interface

uses
  Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, Buttons, TabNotBk,
{$IFDEF WIN32}
  ComCtrls,
{$ENDIF}
  Excels;

type
  TForm1 = class(TForm)
    cmClose: TBitBtn;
    Timer1: TTimer;
    Notebook: TTabbedNotebook;
    Panel1: TPanel;
    Label1: TLabel;
    tbTime: TLabel;
    tbSpeed: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    cmTable: TBitBtn;
    tbLeft: TComboBox;
    tbRight: TComboBox;
    tbMode: TRadioGroup;
    tbNew: TCheckBox;
    Panel2: TPanel;
    Label5: TLabel;
    cbCommand: TComboBox;
    cmCommand: TBitBtn;
    Panel3: TPanel;
    Label7: TLabel;
    cmRun: TBitBtn;
    cbMacro: TComboBox;
    tbTop: TComboBox;
    tbBottom: TComboBox;
    GroupBox1: TGroupBox;
    Memo: TMemo;
    Panel4: TPanel;
    Label6: TLabel;
    cmRequest: TBitBtn;
    cbItem: TComboBox;
    Panel5: TPanel;
    Label9: TLabel;
    Label8: TLabel;
    cmGetData: TBitBtn;
    gdRow: TComboBox;
    gdCol: TComboBox;
    gdRange: TCheckBox;
    cmBook: TBitBtn;
    Label12: TLabel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure ExcelOpen (Sender: TObject);
    procedure ExcelClose(Sender: TObject);
    procedure ClearReply(Sender: TObject);
    procedure CheckBuff(Sender: TObject);
    procedure cmTableClick(Sender: TObject);
    procedure cmCommandClick(Sender: TObject);
    procedure cmRunClick(Sender: TObject);
    procedure cmRequestClick(Sender: TObject);
    procedure cmGetDataClick(Sender: TObject);
    procedure cmBookClick(Sender: TObject);
    procedure cmCloseClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  public
{$IFNDEF INSTALLED}
     Excel : TExcel;
{$ENDIF}
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
{$IFNDEF INSTALLED}
  Excel := TExcel.Create(Self);
{$ENDIF}
  cbMacro.ItemIndex := 0;
  Timer1.Enabled := True;          { Delayed Connect }
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Excel.Connected then Excel.CloseMacroFile;
  Excel.OnClose := nil;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
try
  Timer1.Enabled := False;
  Excel.OnOpen  := ExcelOpen;
  Excel.OnClose := ExcelClose;
  Excel.Connect;   { Same as Excel.Connected := True; }
finally
  Screen.Cursor := crDefault;
end; end;

procedure TForm1.ExcelOpen(Sender: TObject);
  var
      MacroFile : TFileName;
begin
  cmTable  .Enabled := True;
  cmCommand.Enabled := True;
  cmRequest.Enabled := True;
  cmGetData.Enabled := True;
  cmBook   .Enabled := True;
  MacroFile := ExtractFilePath(ParamStr(0))+'Excel.xls';
  if FileExists(Macrofile) then
  begin
    Excel.OpenMacroFile(MacroFile, True);
    cmRun.Enabled := True;
  end;
end;

procedure TForm1.ExcelClose(Sender: TObject);
begin
  cmTable  .Enabled := False;
  cmCommand.Enabled := False;
  cmRequest.Enabled := False;
  cmGetData.Enabled := False;
  cmBook   .Enabled := False;
  cmRun    .Enabled := False;
  ShowMessage('Excel closed');
end;

procedure TForm1.ClearReply(Sender: TObject);
begin
  Memo.Lines.Clear;
end;

procedure TForm1.CheckBuff(Sender: TObject);
  var
      Rows, Cols : Integer;
      RowSize : Longint;
      Over64KB : Boolean;
begin
  Rows := StrToInt(tbBottom.Text) - StrToInt(tbTop.Text) + 1;
  Cols := StrToInt(tbRight.Text) - StrToInt(tbLeft.Text) + 1;
  if (Rows < 0) or (Cols < 0) then
    ShowMessage('Invalid values');
  if tbMode.ItemIndex = 0 then Exit;           { Execute }
  RowSize := Longint(Length(tbBottom.Text) + 5) * Cols;
  Over64KB := 65535 < RowSize * Rows;          { Prepared batch }
  if tbMode.ItemIndex = 1 then                 { Normal batch }
    with Excel do Over64KB := Over64KB and
             (65535 < RowSize * (BatchMax mod BatchMin + BatchMin));
  if Over64KB then
    ShowMessage('Data will be lost.  Transfer buffer exceeds 64 KB')
{$IFNDEF WIN32}
  else if RowSize > 255 then
    ShowMessage('Data will be lost.  Line buffer exceeds 255')
{$ENDIF}
end;

procedure TForm1.cmTableClick(Sender: TObject);
  var
      Top, Left, Bottom, Right : Integer;

  procedure Normal;
    var
        i, j : Longint;
  begin
    for i:=Top to Bottom do
      for j:=Left to Right do
        Excel.PutInt(i, j, i*10000+j);
  end;

  procedure Prepared;
    var
        i, j : Longint;
        Line : string;
  begin
    Excel.LastCol := Right;         { Need to set LastCol }
    for i:=Top to Bottom do
    begin
      Line := floatToStrF(i*10000+Left+0.65,fffixed,7,4);
      for j:=Left+1 to Right do
        Line := Line + #9 + floatToStrf(i*10000+j+0.65,fffixed,7,4);
      Excel.Lines.Add(Line);
    end;
  end;

  var
      t, t0 : TDateTime;
      n : Longint;
begin                              { cmTableClick }
  tbTime.Caption := ' RUNNING';
  tbSpeed.Caption := '';
  Refresh;
  try
    if tbNew.Checked then Excel.Exec('[NEW(1)]');      { New table }
    Top    := StrToInt(tbTop   .Text);
    Left   := StrToInt(tbLeft  .Text);
    Bottom := StrToInt(tbBottom.Text);
    Right  := StrToInt(tbRight .Text);
    n := (Bottom - Top + 1)*(Right - Left + 1);
    Screen.Cursor := crHourGlass;
    Enabled := False;
    t0 := Time;                    { Start time }
    try
      if tbMode.ItemIndex > 0 then Excel.BatchStart(Top, Left);
      if tbMode.ItemIndex = 2 then Prepared
                              else Normal;
      if tbMode.ItemIndex > 0 then Excel.BatchSend;
    finally
      Excel.BatchCancel;
      Enabled := True;
      Screen.Cursor := crDefault;
    end;
  except
    tbTime.Caption := '';
    raise
  end;
  t := Time - t0;                  { End time }
  tbTime.Caption := TimeToStr(t);
  tbSpeed.Caption := Format('%.1f', [0.000001 * n / t]);
end;

procedure TForm1.cmCommandClick(Sender: TObject);
begin
  Excel.Exec(cbCommand.Text);
end;

procedure TForm1.cmRunClick(Sender: TObject);
begin
  Excel.Run(cbMacro.Text);
end;

procedure TForm1.cmRequestClick(Sender: TObject);
  var
      i : Integer;
      Reply : string;
begin
  Memo.Lines.Clear;
  Reply := Excel.Request(cbItem.Text);
  i := Pos(#9, Reply);
  while i > 0 do
  begin
    Memo.Lines.Add(Copy(Reply, 1, i-1));
    Delete(Reply, 1, i);
    i := Pos(#9, Reply);
  end;
  Memo.Lines.Add(Reply);
end;

procedure TForm1.cmGetDataClick(Sender: TObject);
  var
      Row, Col : Integer;
      Range : TStringList;
begin
  Row := StrToInt(gdRow.Text);
  Col := StrToInt(gdCol.Text);
  Screen.Cursor := crHourGlass;
try
  Memo.Lines.Clear;
  if gdRange.Checked then
  try
    Range := TStringList.Create;
    Excel.GetRange(Rect(1, 1, Col, Row), Range);
    Memo.Lines.AddStrings(Range);
  finally
    Range.Free;
  end
  else
    Memo.Lines.Add(Excel.GetCell(Row, Col));
finally
  Screen.Cursor := crDefault;
end; end;

procedure TForm1.cmBookClick(Sender: TObject);
  var
      Books, Sheets : TStringList;
      i : Integer;
begin
  Memo.Lines.Clear;
  Books := TStringList.Create;
  Sheets := TStringList.Create;
try
  Excel.GetBooks(Books);
  for i:=0 to Books.Count-1 do
  begin
    Memo.Lines.Add('Sheets in '+ Books[i]);
    Excel.GetSheets(Books[i], Sheets);
    Memo.Lines.AddStrings(Sheets);
    Sheets.Clear;
  end;
finally
  Books.Free;
  Sheets.Free;
end; end;

procedure TForm1.cmCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  excel.Disconnect;
end;

end.
