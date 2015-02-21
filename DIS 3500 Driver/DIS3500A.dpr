program DIS3500A;

uses
  Forms,
  DISSysTest in 'DISSysTest.PAS',
  ChanDlg in 'ChanDlg.pas' {frmChanDlg},
  DISChannel in 'DISChannel.pas' {frmDISChannel};

{$R *.RES}

begin
  Create_DIS_Client;
  frmDISSysTest.Showmodal;
end.
