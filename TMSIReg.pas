{***************************************************************
 *
 * Unit Name: TMSIReg
 * Purpose  : To Register Components from TMSI into the Delphi
 *            Component Palette
 * Author   : Ryan Potts
 * History  : Designed and Built 2/16/1999
 *
 * On The Menu:  DIO Control interface
 *               CNF file to CFG format (Currently used with
 *                                       SpectraPAC/CR)
 *               Picklist 'Container'
 *               Port call component
 *                (3 components, 1 for Byte (8bit)  operations
 *                               1 for Word (16bit) operations
 *                               1 for Long (32bit) operations
 ****************************************************************}

unit TMSIReg;

interface

procedure Register;

implementation
{$R CNFtoCFG.dcr}
{$R DioCtrl.dcr}
{$R PickList.dcr}
{$R Ports.dcr}
{$R PCB.dcr}
{_R DFMCalc.dcr}
{$R Numberpad.dcr}
{$R AlphaPad.dcr}
{$R DVM.dcr}
{$R RCRACK.DCR}
{$R ABTtoCFG.DCR}
{$R POWERMONITORREV2.DCR}
{_R SNHDChecker.dcr}
{_R DISDriver.dcr}
{_R PLCMonitor.dcr}
{_R CompactLogixComms.dcr}
{$R MicroLogixPLCModules.dcr}
{$R PLCModules.dcr}
{$R SerialNumberTracker.dcr}
{$R MicroLogixComms.dcr}
uses
  Forms, Classes, Controls, SysUtils, CNFtoCFG, DioCtrl, PickList,
  Ports,pcb{,DFMCalc}, Numberpad, AlphaPad, DVM{, RcRack}, ABTtoCFG,
  PowerMonitorRev2{, SNHDChecker}{, DISDriver}{, PLCMonitor, CompactLogixComms},
  MicroLogixPLCModules, PLCModules, SerialNumberTracker, MicroLogixComms;

procedure Register;
begin
  RegisterComponents('TMSI', [TCNFTOCFG,
                              TDIO,
                              TDIOLED,
                              TPICKLIST,
                              TBYTEPORT,
                              TWORDPORT,
                              TLONGPORT,
                              TPCB,
//                              TDFMCALCER,
                              TINITOCFG,
                              TNumberPad,
                              TAlphaPad,
                              TDVM{,
                              TRCRACK},
                              TABTtoCFG,
                              TPowerMonitor{,
                              TSNHDChecker}{,
                              TDis3500Drv}{,
                              TPLCMonitor,
                              TCompactLogixPLC},
                              TSNTracker,
                              TMicroLogixPLC]);

  RegisterComponents('Micro Logix Modules',[TMicroLogixProcessor,
                                            TMicroLogix16CHDigitalInputModule,
                                            TMicroLogix16CHDigitalOutputModule,
                                            TMicroLogix8CHRelayedDigitalOutputModule,
                                            TMicroLogix4CHAnalogInputModule,
                                            TMicroLogix4ChAnalogOutputModule,
                                            TMicroLogix4CHRTDAnalogInputModule,
                                            TMicroLogixVirtualBackPlane]);
  RegisterComponents('Compact Logix Modules',[TVirtualPLCBackPlane,
                                              TCompactLogixVirtualDriveModule,
                                              TCompactLogix8ChRelayedDigitalOutputModule,
                                              TCompactLogix16ChDigitalOutputModule,
                                              TCompactLogix8ChAnalogOuputModule,
                                              TCompactLogix16ChDigitalInputModule,
                                              TCompactLogixProcessorModule,
                                              TCompactLogix8ChAnalogInputModule]);
end;

end.
