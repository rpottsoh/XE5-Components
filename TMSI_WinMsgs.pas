////////////////////////////////////////////////////////////////////////////////
///                                                                          ///
///   Author: Daniel Muncy, Test Measurement Systems, Inc.                   ///
///   Date: January 10, 2013; Unit has been in existance before this date.   ///
///                                                                          ///
///   This unit is a collection of Windows messages used by TMSI software.   ///
///   If a message is found that is not in this unit, add it and referance   ///
///   this unit.                                                             ///
///                                                                          ///
////////////////////////////////////////////////////////////////////////////////

unit TMSI_WinMsgs;

interface

Uses
  Windows, Messages;

const
  MSG_Base                           = WM_User;

  MSG_CRASH_RPT_HDL                  = MSG_Base + 1; // Message that will contain the Handle for the Crash Report Window...
  MSG_CRASH_RPT_WD_Tx                = MSG_Base + 2; // Watchdog transmit message to sent to TTM software...
  MSG_CRASH_RPT_WD_Rx                = MSG_Base + 3; // Watchdog recieve message sent form TTM software...
  MSG_CRASH_RPT_START_WD             = MSG_Base + 4; // Start monitoring...
  MSG_CRASH_RPT_STOP_WD              = MSG_Base + 5; // Stop monitoring...
  MSG_CRASH_RPT_TOG_VIS              = MSG_Base + 6; // Toggle visibility of Crash Report application...
  PIDTuneScreenClosing               = MSG_Base + 2000; // PID tuning screen closing
  CalLoadCellScreenClosing           = MSG_Base + 2100; // Calibation screen closing
  ClosingSpringRateConfig_msg        = MSG_Base + 2223; // Spring rate config
  RunScreenClosing_Msg               = MSG_Base + 3000; // RR run screen closing
  DLDTestRunScreenClosing_Msg        = MSG_Base + 3001; // DLD test control screen
  SweepTestRunScreenClosing_Msg      = MSG_Base + 3002; // Sweep test run screen closing
  FMTestRunScreenClosing_Msg         = MSG_Base + 3003; // FM test screen closing
  PRATTestRunScreenClosing_Msg       = MSG_Base + 3004; // Generic PRAT screen closing
  HSUTestRunScreenClosing_Msg        = MSG_Base + 3005; // HSU run screen closing
  CTTestRunScreenClosing_Msg         = MSG_Base + 3006; // CT Test control screen closing
  CustomPRATTestRunScreenClosing_Msg = MSG_Base + 3007; // Custom PRAT test control screen closing
  Close6AxisCalibrationScreen_Msg    = MSG_Base + 9999; // Multi axis calibration screen closing
  WM_LOADEDITOR_CLOSING              = MSG_Base + 4000; // Load editor closing
  WM_DRIVEEDITOR_CLOSING             = MSG_Base + 4001; // Drive editor closing
  WM_ENDURANCE_RPT_GEN_CLOSING       = MSG_Base + 4002; // Endurance report generator closing
  WM_HANDLECALLBACK                  = MSG_Base + 4003; // Message used to call back to originating window. WParam should be used to uniquely identify the sender.
  WM_CALLERCLOSING                   = MSG_Base + 4004; // Calling software closing
  WM_MAINT_EDITOR_CLOSING            = MSG_Base + 4005; // Maintenance Editor Closing
  WM_MAINT_LOG_VIEWER_CLOSING        = MSG_Base + 4006; // Maintenance Log Viewer Closing
  WM_HSU_Step_Report_Gen_CLOSING     = MSG_Base + 5000; // HSU Step Report Generator Closing
  WM_HSU_SpectraAnalysis_CLOSING     = MSG_Base + 5001; // HSU Spectra Analysis Closing
  WM_RR_ANALYSIS_CLOSING             = MSG_Base + 6001; // RR Analysis Software Closing
  WM_SpectraPAC_Setup_Wizard_Closing = MSG_Base + 7001; // SpectraPAC Setup Wizard Closing, AKA Uniformaty Wizard
  WM_CoarseRoad_RunScreen_Closing    = MSG_Base + 8001; // SpectarPACcr Run Screen Closing
  CustomSSCTestRunScreenClosing_Msg  = MSG_Base + 9001; // Stead State Cornering Run Screen Closing
  SAFTestRunScreenClosing_Msg        = MSG_Base + 10001; // Sine Angle Frequence Test Run Screen Closing  

type
  // The following call back identifiers need to be sent back to the calling program to
  // properly signal who is calling back.
  TCallBackIdentifier = (CBI_Reserved,CBI_LoadEditor,CBI_DriveEditor,CBI_EnduranceReportGen,
                         CBI_MaintEditor,CBI_MaintLogViewer,CBI_HSUStepReportGen,
                         CBI_HSUSpectraAnalysis,CBI_RRAnalysis,CBI_SpectraPACSetupWizard);

implementation
{EMPTY}

end.
