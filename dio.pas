unit dio;
//---------------------------------------------------------------------------
//
//                                Digital Interface Module
//
//
//                     Written By:  Ryan Potts
//                                  Matt Laun
//
//                     Written On:  01/06/97
//
//---------------------------------------------------------------------------
//
//    This unit serves as a tool to implement the Computer Boards DIO-24H
//    digital I/O board.  This utility will handle as many as two 24H boards
//
//    This unit uses the unit CBW32.PAS 32bit interface header to communicate
//    with CB's 32bit 'thunking' DLL.
//
//    CBW16.DLL and CBW32.DLL are required.  Also a CB.CFG file is required
//    InstaCal (provided by CB) will generate the CB.CFG file.
//
//    GENUL.386 (or cbul.386) also has to be installed in the SYSTEM.INI in
//    the [386enh] section:
//
//         device=c:\cb\genul.386
//
//===========================================================================
//
//  (c) Copyright 1997           Test Measurement Systems, Inc.
//        by TMSI                   202 Montrose West Ave.
//                                    Copley, OH  44321
//  ALL RIGHTS RESERVED                 (330)668-2010
//
//---------------------------------------------------------------------------
//
//  Units required by DIO.PAS:
//
//     Cbw32, stRegIni, dialogs, classes, sysutils
//               ^--- from systools
//---------------------------------------------------------------------------
//  mods
//
//  1/11/97  rp  Added ReadINIFile function.  Ports no longer need to be
//               hardcoded in software
//  1/1999   rp  Modified in order to work with DIO Control VCL Component.
//
//---------------------------------------------------------------------------

interface
{$ifdef PCI_DIG_IO}
uses CBW;
{$else}
uses cbwdlltmsi;
{$endif}

type       // 0      1      2
  tIoType = (Input,Output,NotUsed);
  tIoTypeArray = array[0..9,FIRSTPORTA..FIRSTPORTCH{SECONDPORTCH{}] of TIoType;

  tPortType = array[0..9,0..3] of integer;


var
     OutPutPorts      : tPortType;  //Stores all the OutputPorts
     InputPorts       : tPortType;  //   ""   ""  "" InputPorts
     iPortIndexer     : array[0..9] of integer;     //Input Port Indexer
     oPortIndexer     : array[0..9] of integer;     //Output Port Indexer
     BoardInitialized : array[0..9] of boolean; // equals TRUE if Init_Dio was completed
     IOArray : tIoTypeArray;

  function Init_DIO(inifilename : string; Board_Num : integer):integer;
      // Initialize DIO board
  function Init_DIO_DIP24_With_Port_Defaults(PortA, PortB, PortC : byte; p_A, p_B, p_CH, p_CL, Board_Num : integer):integer;
  function Init_DIO_DIP24(p_A, p_B, p_CH, p_CL, Board_Num : integer):integer;
  function Init_DIO_DIP48(p_FA, p_FB, p_FCH, p_FCL, p_SA, p_SB, p_SCH, p_SCL, Board_Num : integer):integer;
      // Initialize DIO board via 'DIP Settings'
  function Bit_On(Board_Num, BitNum:integer):integer;
        // Turn on a bit
  function Bit_Off(Board_Num, BitNum:integer):integer;
        // Turn off a bit
  function Read_Bit(Board_Num, BitNum:integer):integer;
        // Read an input bit
  function Return_True_DIO_Bitnum(Board_Num : integer; IODirection : tIoType; Bitnum : integer):integer;
  function FindInputBit(Board_Num, bitnum : integer):integer;
  function FindOutputBit(Board_Num, bitnum : integer):integer;
  function Hard_Bit_On(Board_Num, BitNum : integer): integer;
  function Hard_Bit_Off(Board_Num, BitNum : integer): integer;
  function Hard_Read_Bit(Board_num, BitNum : integer): integer;

implementation
uses inifiles, {stRegIni,{} dialogs, classes, sysutils;

var     DIOBoardNum : integer;


//
//-------------------------------- ReadINIFIle ---------------------------
//
//  This function reads the C:\WINDOWS\DIOSETUP.INI file to determine
//  the type of function each port on the dio48h will perform.
//
//  The available functions are OUTPUT, INPUT, or NOTUSED
//
// -----------------------------------------------------------------------
//    Example diosetup.ini file:      This file is being used at CGTI
//
//    [DIO48h]
//    firstporta=output
//    firstportb=input
//    secondporta=output
//
//    Only list the ports that you wish to use.  Ports NOT listed are
//    considered NotUsed.
//
//-------------------------------------------------------------------------
//
Function ReadINIFile(Board_Num : integer; filename : String ):boolean;
var inifile : tinifile {TstRegIni{};
    Strings : TStringList;
    i         : integer;
    temp      : string;
    success : boolean;
    PortNum : integer;

    function Determine_Port_Num(InString : string):Integer;
    var temppnum : integer;
    begin
      if uppercase(InString) = 'FIRSTPORTA' then
        tempPNum := FIRSTPORTA
      else
      if uppercase(InString) = 'FIRSTPORTB' then
        temppnum := FIRSTPORTB
      else
      if uppercase(InString) = 'FIRSTPORTCL' then
        temppnum := FIRSTPORTCL
      else
      if uppercase(InString) = 'FIRSTPORTCH' then
        temppnum := FIRSTPORTCH
      else
      if uppercase(InString) = 'SECONDPORTA' then
        temppnum := SECONDPORTA
      else
      if uppercase(InString) = 'SECONDPORTB' then
        temppnum := SECONDPORTB
      else
      if uppercase(InString) = 'SECONDPORTCL' then
        temppnum := SECONDPORTCL
      else
      if uppercase(InString) = 'SECONDPORTCH' then
        temppnum := SECONDPORTCH
      else
      if uppercase(InString) = 'THIRDPORTA' then
        temppnum := THIRDPORTA
      else
      if uppercase(InString) = 'THIRDPORTB' then
        temppnum := THIRDPORTB
      else
      if uppercase(InString) = 'THIRDPORTCL' then
        temppnum := THIRDPORTCL
      else
      if uppercase(InString) = 'THIRDPORTCH' then
        temppnum := THIRDPORTCH
      else
      if uppercase(InString) = 'FOURTHPORTA' then
        temppnum := FOURTHPORTA
      else
      if uppercase(InString) = 'FOURTHPORTB' then
        temppnum := FOURTHPORTB
      else
      if uppercase(InString) = 'FOURTHPORTCL' then
        temppnum := FOURTHPORTCL
      else
      if uppercase(InString) = 'FOURTHPORTCH' then
        temppnum := FOURTHPORTCH
      else
      if uppercase(InString) = 'FIFTHPORTA' then
        temppnum := FIFTHPORTA
      else
      if uppercase(InString) = 'FIFTHPORTB' then
        temppnum := FIFTHPORTB
      else
      if uppercase(InString) = 'FIFTHPORTCL' then
        temppnum := FIFTHPORTCL
      else
      if uppercase(InString) = 'FIFTHPORTCH' then
        temppnum := FIFTHPORTCH
      else
      if uppercase(InString) = 'SIXTHPORTA' then
        temppnum := SIXTHPORTA
      else
      if uppercase(InString) = 'SIXTHPORTB' then
        temppnum := SIXTHPORTB
      else
      if uppercase(InString) = 'SIXTHPORTCL' then
        temppnum := SIXTHPORTCL
      else
      if uppercase(InString) = 'SIXTHPORTCH' then
        temppnum := SIXTHPORTCH
      else
      if uppercase(InString) = 'SEVENTHPORTA' then
        temppnum := SEVENTHPORTA
      else
      if uppercase(InString) = 'SEVENTHPORTB' then
        temppnum := SEVENTHPORTB
      else
      if uppercase(InString) = 'SEVENTHPORTCL' then
        temppnum := SEVENTHPORTCL
      else
      if uppercase(InString) = 'SEVENTHPORTCH' then
        temppnum := SEVENTHPORTCH
      else
      if uppercase(InString) = 'EIGHTHPORTA' then
        temppnum := EIGHTHPORTA
      else
      if uppercase(InString) = 'EIGHTHPORTB' then
        temppnum := EIGHTHPORTB
      else
      if uppercase(InString) = 'EIGHTHPORTCL' then
        temppnum := EIGHTHPORTCL
      else
      if uppercase(InString) = 'EIGHTPORTCH' then
        temppnum := EIGHTHPORTCH
      else
        temppnum := 32768;
      Determine_Port_Num := temppnum;
    end;

begin
  strings := tstringlist.create;
  inifile := tinifile {tstregini{}.create(filename{,true{});
  success := false;
  try
    strings.clear;
    Success := false;
{    inifile.CurSubKey := 'DIO24h';
    inifile.getsubkeys(strings);{}
    inifile.readsection{values}('DIO_Ports', strings);
    for i := 0 to Strings.count - 1 do
    begin
      temp := inifile.readstring('DIO_Ports',strings[i],'notused');
      portnum := Determine_Port_Num(strings[i]);
      if portnum <> 32768 then
        if uppercase(temp) = 'INPUT' then
          ioarray[Board_Num,portnum] := input
        else
          if uppercase(temp) = 'OUTPUT' then
            ioarray[Board_Num,portnum] := output
          else
            ioarray[Board_Num,portnum] := notused;
    end;
    success := true;
  finally
    inifile.free;
    strings.free;
    readINIFile := success;
  end;
end;(**)

//
//------------------------ INIT_DIO --------------------------------------
//
//  This Function intializes all the bits on ONE dio48h board
//
//  Two parameters are required.  The first equals the board number of the
//  dio board.  This value comes from the CB.CFG file.
//  The second is an array which defines whether a port is a DIGITALIN,
//  DIGITALOUT, or not used
//
//    The function must be run ONE time before any of the others will
//    function.
//------------------------------------------------------------------------
//
//  Example of a procedure to to define types of io ports
//
//  procedure CreateIOArray;
//  begin
//     fillchar(ioarray,sizeof(ioarray),dontcare);
//     ioarray[FIRSTPORTA] := output;
//     ioarray[FIRSTPORTB] := input;
//     ioarray[SECONDPORTA] := output;
//  end;
//
//------------------------------------------------------------------------
function Init_DIO(inifilename : string; Board_Num : integer):integer;
var results,
    ioport : integer;
begin
  if not ReadINIFile(Board_Num, inifilename ) then
  begin
    messagedlg('Error reading ' + inifilename,mterror,[mbok],0);
    result := 32768;
    exit;
  end;
  DIOBoardNum := Board_Num;  // RValue Passed from Function Parameter, LValue globally delcared from Interface
  results := 0;
  iPortIndexer[Board_Num] := -1;
  oPortIndexer[Board_Num] := -1;
  for ioport := FIRSTPORTA to {SECONDPORTCH{} FIRSTPORTCH{} do
   case ioarray[Board_Num,ioport] of
     input : begin
               results := results + cbDConfigPort(Board_Num,ioport,DIGITALIN);
               inc(iPortIndexer[Board_Num]);
               InputPorts[Board_num,iPortIndexer[Board_Num]] := IoPort;
               cbDOut(Board_Num,IoPort,255{});
             end;
     output: begin
               results := results + cbDConfigPort(Board_Num,ioport,DIGITALOUT);
               inc(oPortIndexer[Board_Num]);
               OutputPorts[Board_Num,oPortIndexer[Board_Num]] := ioport;
               cbDOut(Board_Num,IoPort,255{});
             end;
   end; {case}(**)
{  for ioport := SECONDPORTA to SECONDPORTCH do
   case ioarray[ioport] of
     input : begin
               results := results + cbDConfigPort(DIOBoardNum,ioport,DIGITALIN);
               inc(iPortIndexer);
               InputPorts[iPortIndexer] := IoPort;
             end;
     output: begin
               results := results + cbDConfigPort(DIOBoardNum,ioport,DIGITALOUT);
               inc(oPortIndexer);
               OutputPorts[oPortIndexer] := ioport;
               for i := 0 to 7 do
                 results := results + cbDBitOut(DIOBoardNum,IoPort,i,1);
             end;
   end; {case}
  if results = 0 then
    BoardInitialized[Board_Num] := true;
  result := results;
end;

function Init_DIO_DIP48(p_FA, p_FB, p_FCH, p_FCL, p_SA, p_SB, p_SCH, p_SCL, Board_Num : integer):integer;
var results,
    ioport : integer;
begin
(*  Fillchar(IoArray[Board_Num],sizeof(IoArray[Board_Num]),tIoType(2));
  FillChar(InputPorts[Board_Num],sizeof(InputPorts[Board_Num]),#0);
  FillChar(OutputPorts[Board_Num],sizeof(OutputPorts[Board_Num]),#0);
  case p_FA of
    0 : IoArray[Board_Num,FIRSTPORTA] := Input;
    1 : IoArray[Board_Num,FIRSTPORTA] := Output;
    2 : IoArray[Board_Num,FIRSTPORTA] := NotUsed;
  end; {case}
  case p_FB of
    0 : IoArray[Board_Num,FIRSTPORTB] := Input;
    1 : IoArray[Board_Num,FIRSTPORTB] := Output;
    2 : IoArray[Board_Num,FIRSTPORTB] := NotUsed;
  end; {case}
  case p_FCL of
    0 : IoArray[Board_Num,FIRSTPORTCL] := Input;
    1 : IoArray[Board_Num,FIRSTPORTCL] := Output;
    2 : IoArray[Board_Num,FIRSTPORTCL] := NotUsed;
  end; {case}
  case p_FCH of
    0 : IoArray[Board_Num,FIRSTPORTCH] := Input;
    1 : IoArray[Board_Num,FIRSTPORTCH] := Output;
    2 : IoArray[Board_Num,FIRSTPORTCH] := NotUsed;
  end; {case}

  case p_SA of
    0 : IoArray[Board_Num,SECONDPORTA] := Input;
    1 : IoArray[Board_Num,SECONDPORTA] := Output;
    2 : IoArray[Board_Num,SECONDPORTA] := NotUsed;
  end; {case}
  case p_SB of
    0 : IoArray[Board_Num,SECONDPORTB] := Input;
    1 : IoArray[Board_Num,SECONDPORTB] := Output;
    2 : IoArray[Board_Num,SECONDPORTB] := NotUsed;
  end; {case}
  case p_SCL of
    0 : IoArray[Board_Num,SECONDPORTCL] := Input;
    1 : IoArray[Board_Num,SECONDPORTCL] := Output;
    2 : IoArray[Board_Num,SECONDPORTCL] := NotUsed;
  end; {case}
  case p_SCH of
    0 : IoArray[Board_Num,SECONDPORTCH] := Input;
    1 : IoArray[Board_Num,SECONDPORTCH] := Output;
    2 : IoArray[Board_Num,SECONDPORTCH] := NotUsed;
  end; {case}
  DIOBoardNum := Board_Num;  // RValue Passed from Function Parameter, LValue globally delcared from Interface
  results := 0;
  iPortIndexer[Board_Num] := -1;
  oPortIndexer[Board_Num] := -1;
  for ioport := FIRSTPORTA to SECONDPORTCH {FIRSTPORTCH{} do
   case ioarray[Board_Num,ioport] of
     input : begin
               results := results + cbDConfigPort(Board_Num,ioport,DIGITALIN);
               inc(iPortIndexer[Board_Num]);
               InputPorts[Board_Num,iPortIndexer[Board_Num]] := IoPort;
               cbDOut(Board_Num,IoPort,255{});
             end;
     output: begin
               results := results + cbDConfigPort(Board_Num,ioport,DIGITALOUT);
               inc(oPortIndexer[Board_Num]);
               OutputPorts[Board_Num,oPortIndexer[Board_Num]] := ioport;
               cbDOut(Board_Num,IoPort,255{});
             end;
   end; {case}
  if results = 0 then
    BoardInitialized := true;
  result := results;(**)
end;

function Init_DIO_DIP24(p_A, p_B, p_CH, p_CL, Board_Num : integer):integer;
begin
  Init_DIO_DIP24_With_Port_Defaults(255,255,255,p_A, p_B, p_CH, p_CL, Board_Num);
end;

function Init_DIO_DIP24_With_Port_Defaults(PortA, PortB, PortC : byte; p_A, p_B, p_CH, p_CL, Board_Num : integer):integer;
var results,
    ioport : integer;
begin
  Fillchar(IoArray[Board_Num],sizeof(IoArray[Board_Num]),tIoType(2));
  FillChar(InputPorts[Board_Num],sizeof(InputPorts[Board_Num]),#0);
  FillChar(OutputPorts[Board_Num],sizeof(OutputPorts[Board_Num]),#0);
  case p_A of
    0 : IoArray[Board_Num,FIRSTPORTA] := Input;
    1 : IoArray[Board_Num,FIRSTPORTA] := Output;
    2 : IoArray[Board_Num,FIRSTPORTA] := NotUsed;
  end; {case}
  case p_B of
    0 : IoArray[Board_Num,FIRSTPORTB] := Input;
    1 : IoArray[Board_Num,FIRSTPORTB] := Output;
    2 : IoArray[Board_Num,FIRSTPORTB] := NotUsed;
  end; {case}
  case p_CL of
    0 : IoArray[Board_Num,FIRSTPORTCL] := Input;
    1 : IoArray[Board_Num,FIRSTPORTCL] := Output;
    2 : IoArray[Board_Num,FIRSTPORTCL] := NotUsed;
  end; {case}
  case p_CH of
    0 : IoArray[Board_Num,FIRSTPORTCH] := Input;
    1 : IoArray[Board_Num,FIRSTPORTCH] := Output;
    2 : IoArray[Board_Num,FIRSTPORTCH] := NotUsed;
  end; {case}
  DIOBoardNum := Board_Num;  // RValue Passed from Function Parameter, LValue globally delcared from Interface
  results := 0;
  iPortIndexer[Board_Num] := -1;
  oPortIndexer[Board_Num] := -1;
  for ioport := FIRSTPORTA to {SECONDPORTCH{} FIRSTPORTCH{} do
   case ioarray[Board_Num,ioport] of
     input : begin
               results := results + cbDConfigPort(Board_Num,ioport,DIGITALIN);
               inc(iPortIndexer[Board_Num]);
               InputPorts[Board_num,iPortIndexer[Board_Num]] := IoPort;
               cbDOut(Board_Num,IoPort,255{});
             end;
     output: begin
               results := results + cbDConfigPort(Board_Num,ioport,DIGITALOUT);
               inc(oPortIndexer[Board_Num]);
               OutputPorts[Board_Num,oPortIndexer[Board_Num]] := ioport;
               case ioport of
                 FIRSTPORTA  : cbDOut(Board_Num,IoPort,PortA);
                 FIRSTPORTB  : cbDOut(Board_Num,IoPort,PortB);
                 FIRSTPORTCL,
                 FIRSTPORTCH : cbDOut(Board_Num,IoPort,PortC);
               end; //case
             end;
   end; {case}(**)
{  for ioport := SECONDPORTA to SECONDPORTCH do
   case ioarray[ioport] of
     input : begin
               results := results + cbDConfigPort(DIOBoardNum,ioport,DIGITALIN);
               inc(iPortIndexer);
               InputPorts[iPortIndexer] := IoPort;
             end;
     output: begin
               results := results + cbDConfigPort(DIOBoardNum,ioport,DIGITALOUT);
               inc(oPortIndexer);
               OutputPorts[oPortIndexer] := ioport;
               for i := 0 to 7 do
                 results := results + cbDBitOut(DIOBoardNum,IoPort,i,1);
             end;
   end; {case}
  if results = 0 then
    BoardInitialized[Board_Num] := true;
  result := results;
end;

//
//--------------------  BIT_ON  ------------------------------------------
//
//   This function will turn on bit 'bitnum'.
//
//   The function finds bitnum and matches it to the proper bit on the
//   dio board.
//
//------------------------------------------------------------------------
//
function Bit_On(Board_Num,BitNum:integer):integer;
var bitindex : integer;
    IOIndex  : integer;
    offset   : integer;
    bn       : integer;
begin
{$ifndef NoDio}
  if BoardInitialized[Board_Num] then
  begin
    ioindex  := (bitnum -1) div 8;
    offset := -1;
    bn := 0;
    BitIndex := -1;
    case OutputPorts[Board_Num,IOIndex] of
//---------- BOARD0 -----------
      FIRSTPORTA:    begin
                       offset := 0;
                     end;
      FIRSTPORTB:    begin
                       offset := 8;
                     end;
      FIRSTPORTCL:   begin
                       offset := 16;
                     end;
      FIRSTPORTCH:   begin
                       if IoIndex = 0 then
                         Offset := 20
                       else
                       if OutputPorts[Board_Num,IoIndex-1] = FIRSTPORTCL then
                         offset := 16
                       else
                         offset := 20;
                     end;
{      SECONDPORTA:   begin
                       offset := 24;
                     end;
      SECONDPORTB:   begin
                       offset := 32;
                     end;
      SECONDPORTCL:  begin
                       offset := 40;
                     end;
      SECONDPORTCH:  begin
                       if bitnum
                       offset := 44;
                     end;{}
    end; {case}
    bitindex := ((bitnum -1) mod 8) + offset;
    if bitindex <> -1 then
  {$ifdef PCI_DIG_IO}
      result := cbDBitOut(board_num,FIRSTPORTA,BitIndex,0)
  {$else}
      result := cbDBitOut(board_num,OutputPorts[Board_Num,IOIndex],BitIndex,0)
  {$endif}
    else
      result := bitindex;
  end
  else
    result := 32768;
{$else}
  result := 0;
{$endif}
end;

//
//--------------------  BIT_OFF  -----------------------------------------
//
//   This function will turn off bit 'bitnum'.
//
//   The function finds bitnum and matches it to the proper bit on the
//   dio board.
//
//------------------------------------------------------------------------
//
function Bit_Off(Board_Num, BitNum:integer):integer;
var bitindex : integer;
    IOIndex  : integer;
    offset : integer;
    bn : integer;
begin
{$ifndef NoDio}
  if BoardInitialized[Board_Num] then
  begin
    ioindex  := (bitnum -1) div 8;
    offset := -1;
    bn := 0;
    BitIndex := -1;
    case OutputPorts[Board_Num, IOIndex] of
//---------- BOARD0 -----------
      FIRSTPORTA:    begin
                       offset := 0;
                     end;
      FIRSTPORTB:    begin
                       offset := 8;
                     end;
      FIRSTPORTCL:   begin
                       offset := 16;
                     end;
      FIRSTPORTCH:   begin
                       if IOIndex = 0 then
                         offset := 20
                       else
                       if OutputPorts[Board_Num, IOIndex - 1] = FIRSTPORTCL then
                         offset := 16
                       else
                         offset := 20;
                     end;
{      SECONDPORTA:   begin
                       offset := 24;
                     end;
      SECONDPORTB:   begin
                       offset := 32;
                     end;
      SECONDPORTCL:  begin
                       offset := 40;
                     end;
      SECONDPORTCH:  begin
                       offset := 44;
                     end;{}
    end; {case}
    bitindex := ((bitnum -1) mod 8) + offset;
    if bitindex <> -1 then
  {$ifdef PCI_DIG_IO}
      result := cbDBitOut(board_num,FIRSTPORTA,BitIndex,1)
  {$else}
      result := cbDBitOut(board_num,OutputPorts[Board_Num,IOIndex],BitIndex,1)
  {$endif}
    else
      result := bitindex;
  end
  else
    result := 32768;
{$else}
  result := 0;
{$endif}
end;

function Hard_Bit_On(Board_Num,BitNum : integer): integer;
var PortNum : integer;
begin
{$ifndef NoDio}
  if (Bitnum > 0) and (Bitnum < 25{49}) then
  begin
    case Bitnum of
      1..8    : PortNum := FIRSTPORTA;
      9..16   : PortNum := FIRSTPORTB;
      17..20  : PortNUM := FIRSTPORTCL;
      21..24  : PortNum := FIRSTPORTCH;
{      25..32  : PortNum := SECONDPORTA;
      33..40  : PortNum := SECONDPORTB;
      41..44  : PortNUM := SECONDPORTCL;
      45..48  : PortNum := SECONDPORTCH;{}
    else
     begin
       result := -1;
       exit;
     end;
    end; //case
    result := cbDBitOut(Board_Num,Portnum,Bitnum - 1,0);
  end;
{$else}
  result := 0;
{$endif}
end;

function Hard_Bit_Off(Board_Num, BitNum : integer): integer;
var PortNum : integer;
begin
{$ifndef NoDio}
  if (Bitnum > 0) and (Bitnum < 25{49{}) then
  begin
    case Bitnum of
      1..8    : PortNum := FIRSTPORTA;
      9..16   : PortNum := FIRSTPORTB;
      17..20  : PortNUM := FIRSTPORTCL;
      21..24  : PortNum := FIRSTPORTCH;
{      25..32  : PortNum := SECONDPORTA;
      33..40  : PortNum := SECONDPORTB;
      41..44  : PortNUM := SECONDPORTCL;
      45..48  : PortNum := SECONDPORTCH;{}
    else
      begin
        result := -1;
        exit;
      end;
    end; //case
    result := cbDBitOut(Board_Num,Portnum,Bitnum - 1,1)
  end;
{$else}
  result := 0;
{$endif}
end;

//
//--------------------  READ_BIT  ----------------------------------------
//
//   This function will read in the current state of 'bitnum'.
//
//   The function finds bitnum and matches it to the proper bit on the
//   dio board.
//
//------------------------------------------------------------------------
//
function Read_Bit(Board_Num, BitNum:integer):integer;
var bitindex : integer;
    IOIndex  : integer;
  {$ifdef PCI_DIG_IO}
    TempResult : word;
  {$else}
    TempResult : integer;
  {$endif}
    offset     : integer;
    bn         : integer;
    rslt : integer;
begin
{$ifndef NoDio}
  if BoardInitialized[Board_Num] then
  begin
    rslt := 0;
    ioindex  := (bitnum -1) div 8;
    offset := -1;
    TempResult := 0;                                    //  this mod required
    bn := 0;
    bitindex := -1;
    case InputPorts[Board_Num,IOIndex] of
//---------- BOARD0 -----------
      FIRSTPORTA:    begin
                       offset := 0;
                     end;
      FIRSTPORTB:    begin
                       offset := 8;
                     end;
      FIRSTPORTCL:   begin
                       offset := 16;
                     end;
      FIRSTPORTCH:   begin
                       if IOIndex = 0 then
                         offset := 20
                       else
                       if InputPorts[Board_Num, IOIndex - 1] = FIRSTPORTCL then
                         offset := 16
                       else
                         offset := 20;
                     end;
{      SECONDPORTA:   begin
                       offset := 24;
                       bn := DIOBoardNum;
                     end;
      SECONDPORTB:   begin
                       offset := 32;
                       bn := DIOBoardNum;
                     end;
      SECONDPORTCL:  begin
                       offset := 40;
                       bn := DIOBoardNum;
                     end;
      SECONDPORTCH:  begin
                       if bitnum > 4 then
                         offset := 40
                       else
                         offset := 44;
                       bn := DIOBoardNum;
                     end;{}
    end; {case}
    bitindex := ((bitnum -1) mod 8) + offset;
    if (ioindex <= iportindexer[Board_Num]) and (BitIndex <> -1) then
  {$ifdef PCI_DIG_IO}
      rslt := cbDBitIn(board_Num,FIRSTPORTA,BitIndex,TempResult)
  {$else}
      rslt := cbDBitIn(board_Num,InputPorts[Board_Num,IOIndex],BitIndex,TempResult)
  {$endif}
    else
      tempresult := 2;//-1;
    if TempResult > 1 then
      Read_Bit := -1
    else
      Read_Bit := TempResult;
  end
  else
    Read_Bit := 32768;
{$else}
  result := 0;
{$endif}
end;

function Hard_Read_Bit(Board_Num, BitNum : integer): integer;
var portnum : integer;
    {$ifdef PCI_DIG_IO}
    TempResult : word;
    {$else}
    TempResult : integer;
    {$endif}
begin
{$ifndef NoDio}
  if (Bitnum > 0) and (Bitnum < 25{49{}) then
  begin
    case Bitnum of
      1..8    : PortNum := FIRSTPORTA;
      9..16   : PortNum := FIRSTPORTB;
      17..20  : PortNUM := FIRSTPORTCL;
      21..24  : PortNum := FIRSTPORTCH;
{      25..32  : PortNum := SECONDPORTA;
      33..40  : PortNum := SECONDPORTB;
      41..44  : PortNUM := SECONDPORTCL;
      45..48  : PortNum := SECONDPORTCH;{}
    else
      begin
        result := 2;//-1;
        exit;
      end;
    end; //case
    cbDBitIn(Board_Num,PortNum,Bitnum - 1,TempResult);
    result := TempResult;
  end;
{$else}
  result := 0;
{$endif}
end;

function FindOutputBit(Board_Num, bitnum : integer):integer;
var ioindex,
    offset  : integer;
begin
    result := 0;
    ioindex  := (bitnum -1) div 8;
    offset := -1;
    case OutputPorts[Board_Num,IOIndex] of
//---------- BOARD0 -----------
      FIRSTPORTA:    begin
                       offset := 0;
                     end;
      FIRSTPORTB:    begin
                       offset := 8;
                     end;
      FIRSTPORTCL:   begin
                       offset := 16;
                     end;
      FIRSTPORTCH:   begin
                       if IOIndex = 0 then
                         offset := 20
                       else
                       if OutputPorts[Board_Num, IoIndex - 1] = FIRSTPORTCL then
                         offset := 16
                       else
                         offset := 20;
                     end;
{      SECONDPORTA:   begin
                       offset := 24;
                     end;
      SECONDPORTB:   begin
                       offset := 32;
                     end;
      SECONDPORTCL:  begin
                       offset := 40;
                     end;
      SECONDPORTCH:  begin
                       if bitnum > 4 then
                         offset := 40
                       else
                         offset := 44;
                     end;{}
    end; {case}
    result := ((bitnum -1) mod 8) + offset + 1;
end;

function FindInputBit(Board_Num, bitnum : integer):integer;
var ioindex,
    offset  : integer;
begin
    result := 0;
    ioindex  := (bitnum -1) div 8;
    offset := -1;
    case InputPorts[Board_Num,IOIndex] of
//---------- BOARD0 -----------
      FIRSTPORTA:    begin
                       offset := 0;
                     end;
      FIRSTPORTB:    begin
                       offset := 8;
                     end;
      FIRSTPORTCL:   begin
                       offset := 16;
                     end;
      FIRSTPORTCH:   begin
                       if IOIndex = 0 then
                         offset := 20
                       else
                       if InputPorts[Board_Num, Ioindex - 1] = FIRSTPORTCL then
                         offset := 16
                       else
                         offset := 20;{}
                     end;
{      SECONDPORTA:   begin
                       offset := 24;
                     end;
      SECONDPORTB:   begin
                       offset := 32;
                     end;
      SECONDPORTCL:  begin
                       offset := 40;
                     end;
      SECONDPORTCH:  begin
                       if bitnum > 4 then
                         offset := 40
                       else
                         offset := 44;
                     end;{}
    end; {case}
    result := ((bitnum -1) mod 8) + offset + 1;
end;

function Return_True_DIO_Bitnum(Board_Num : integer; IODirection : tIoType; Bitnum : integer):integer;
begin
    case IODirection of
      Input :  result := FindInputBit(Board_Num,bitnum);
      output : result := FindOutputBit(Board_Num,bitnum);
    else
      result := -1;
    end; {case}
end;

initialization
 fillchar(OutputPorts,sizeof(OutputPorts),#0);
 fillchar(inputPorts,sizeof(inputPorts),#0);
 fillchar(ioarray,sizeof(ioarray),notused);
 fillchar(BoardInitialized, sizeof(BoardInitialized), #0);
end.
