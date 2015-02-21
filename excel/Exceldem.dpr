program ExcelDem;

uses
  Forms,
  ExcelTop in 'EXCELTOP.PAS' {Form1};

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
