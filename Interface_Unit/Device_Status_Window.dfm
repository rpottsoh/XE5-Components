�
 TFRMDEVICESTATUS 05  TPF0TfrmDeviceStatusfrmDeviceStatusLeft�Top� Width�Height�CaptionInterface Device Status WindowFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style Menu	MainMenu1PositionpoScreenCenterOnClose	FormCloseOnCreate
FormCreatePixelsPerInch`
TextHeight TOvcNotebook	NBDevicesLeft Top WidthxHeightUActiveTabFont.CharsetDEFAULT_CHARSETActiveTabFont.ColorclWindowTextActiveTabFont.Height�ActiveTabFont.NameMS Sans SerifActiveTabFont.Style AlignalClient
ControllerOvcController1TabOrder  TOvcTabPagePage1CaptionInterface Statistics TLabelLabel1LeftzTop� Width�Height:	AlignmenttaCenterCaption<Interface Unit status window. Test Measurement Systems, Inc.Font.CharsetDEFAULT_CHARSET
Font.ColorclRedFont.Height�	Font.NameMS Sans Serif
Font.StylefsBold 
ParentFontWordWrap	  	TOvcMeterMtrCommandsLeftTop Width� HeightInvertPercentPercent ShowPercent	UnusedColorclGray	UsedColorclBlue  TLabelLabel2LeftTop� WidthWHeightCaptionCommands / Total  TLabelLabel3LeftTopWidthXHeightCaptionResponses / Total  	TOvcMeterMtrResponsesLeftTop&Width� HeightInvertPercentPercent ShowPercent	UnusedColorclGray	UsedColorclBlue  TLabellblActiveDeviceSearchTimeLeftTopLWidthyHeight	AlignmenttaCenterAutoSizeCaption(Active Device Search Time Remaining: N/AFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.StylefsBold 
ParentFont    
TStatusBar
StatusBar1Left TopUWidthxHeightPanelsTextActive Devices: 0Width�  TextCommands Sent: 0Width�  TextResponses: 0Width�  Text
Timouts: 0Width2  SimplePanel  	TMainMenu	MainMenu1Left�Top 	TMenuItemExit1Caption&ExitOnClick
Exit1Click   TOvcControllerOvcController1EntryCommands.TableListDefault	 WordStar Grid  Epoch�Left�Top  TTimertmrActiveDeviceScanEnabledIntervaldOnTimertmrActiveDeviceScanTimerLeft%Top,   