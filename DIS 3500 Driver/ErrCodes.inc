    // 0-18 is a DIS status flag return
    0 : Result := 'No Error; control command received and processed';
    1 : Result := 'On processing';
    2 : Result := 'Missing command line';
    3 : Result := 'Command name too long';
    4 : Result := 'Partition error';
    5 : Result := 'Number of arguments too long';
    6 : Result := 'Invalid command';
    7 : Result := 'Illegal pair number of arguments';
    8 : Result := 'Numerical value over the predetermined range';
    9 : Result := 'Channel number over the predetermined range';
   10 : Result := 'Illegal format';
   11 : Result := '(Not available)';
   12 : Result := 'Faulty Flash ROM';
   13 : Result := 'Time out DPRAM';
   14 : Result := 'Time out DPRAM';
   15 : Result := 'Accept NAK from DPRAM';
   16 : Result := 'Accept NAK from DPRAM';
   17 : Result := 'Error in battery data transmission';
   18 : Result := 'Error in battery data transmission';
   // IP errors
   100 : Result := 'IP address not specified.';
   101 : Result := 'Unable to connect to specified IP address.';
   102 : Result := 'Already connected to an IP address.';
   103 : Result := 'IP address does not ping';
   104 : Result := 'DIS 3500A unresponsive';
   // Process errors
   200 : Result := 'Process interrupted by user and E-stop sent.';
   201 : Result := 'User has interrupted the process.';
   202 : Result  := 'Error Code returned when trying to send Emergency Stop.';
   // Setup errors
   300 : Result := 'Parameter string not valid IP.';
   301 : Result := 'Not a valid slot for module.';
   302 : Result := 'Not a valid memo number.';
   303 : Result := 'Comma not allowed in memo string.';
   304 : Result := 'Invalid channel specified.';
   305 : Result := 'Sample Rate specified not supported.';
   306 : Result := 'Unknown Sample Rate returned from DIS.';
   307 : Result := 'Invalid number of pre-trigger data points specified.';
   308 : Result := 'Invalid Trigger Use returned from DIS.';
   309 : Result := 'Level for Trigger is invalid.';
   310 : Result := 'Invalid Sensor Type returned from DIS.';
   311 : Result := 'Memory Clear did not execute.';
   312 : Result := 'Memory NOT Cleared.';
   313 : Result := 'Command not accepted to Stop Monitor prior to Setting up.';
   314 : Result := 'Invalid response from SET-TIMER.';
   315 : Result := 'Invalid time value sent to Timer command.';
   316 : Result := 'Invalid current value sent to Timer command.';
   317 : Result := 'Invalid trigger source returned from DIS.';
   318 : Result := 'Process interrupted by user and Shunt Emulation Stop sent.';
   319 : Result := 'Invalid Battery result returned from Battery Controller.';
   320 : Result := 'Unknown Charge Status returned from DIS.'; 
   321 : Result := 'Unknown Lock Pin Status returned from DIS.'; 
   322 : Result := 'Unknown Firing Result returned from DIS.';

   // DIS 3000A Legacy
   500 : Result := 'Command not currently supported.';
