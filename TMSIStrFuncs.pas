unit TMSIStrFuncs;

interface

uses
  SysUtils;

function OccuranceNo(S : String; F : String; IgnoreCase : Boolean) : LongInt;
function MatchString(S : String; F : String; Count : LongInt; Index : LongInt; ScanBackward : Boolean; IgnoreCase : Boolean) : LongInt;
function ReplaceString(S : String; F : String; R : String; StartPos : LongInt; Occurance : LongInt; IgnoreCase : Boolean) : String;
function InsertString(S : String; W : String; Index : LongInt) : String;
function ExtractFromString(S : String; StartPos : LongInt; EndPos : LongInt) : String;
function InsertCRLFIntoString(S :String; MaxLineLength : LongInt) : String;
function MPos(Substr: string; S: string; Count : LongInt): LongInt;
function RemoveCRLF(S : String) : String;

implementation

function OccuranceNo(S : String; F : String; IgnoreCase : Boolean) : LongInt;
var
  SPos : LongInt;
  TmpInt : LongInt;
begin
  TmpInt := 1;
  if IgnoreCase then
  begin
    S := UpperCase(S);
    F := UpperCase(F);
  end; // If
  repeat
    SPos := MatchString(S,F,TmpInt,1,False,True);
    if (SPos > 0) then
      Inc(TmpInt);
  until (SPos = 0);
  Result := (TmpInt - 1);
end; // OccuranceNo

function MatchString(S : String; F :String; Count : LongInt; Index : LongInt; ScanBackward : Boolean; IgnoreCase : Boolean) : LongInt;
var
  i : LongInt;
  j : LongInt;
  GoodMatch : Boolean;
  MatchCount : LongInt;
  MatchStart : LongInt;
  SkipToPos : LongInt;
begin
  Result := 0;
  if (Count > 0) and (Length(S) >= Length(F)) then
  begin
    MatchCount := 0;
    SkipToPos := -1;
    if IgnoreCase then
    begin
      S := UpperCase(S);
      F := UpperCase(F);
    end; // If
    if Not ScanBackward then
    begin // Scan forward from index...
      for i := Index to Length(S) do
      begin // Find first matching char.
        if (SkipToPos <> - 1) then
        begin
          if (i < (SkipToPos)) then
            Continue
          else
            SkipToPos := -1; // Reset
        end; // If
        if (S[i] = F[1]) then
        begin
          MatchStart := i;
          GoodMatch := True;
          if (((MatchStart - 1) + Length(F)) <= Length(S)) then
          begin
            for j := 1 to Length(F) do
            begin // Scan for search string...
              if (S[(i + (j - 1))] = F[j]) then
                GoodMatch := GoodMatch and True
              else
              begin
                GoodMatch := False;
                Break;
              end; // If
            end; // For j
          end
          else
          begin
            GoodMatch := False;
          end; // If
          if GoodMatch then
          begin
            SkipToPos := i + Length(F);
            Inc(MatchCount);
          end; // If
          if (MatchCount = Count) then
          begin
            Result := MatchStart;
            Break;
          end; // If
        end; // If
      end; // For i
    end
    else
    begin // Scan backward from Index...
      for i := Index downto 1 do
      begin // Find first matching char.
        if (SkipToPos <> - 1) then
        begin
          if (i > (SkipToPos)) then
            Continue
          else
            SkipToPos := -1; // Reset
        end; // If
        if (S[i] = F[1]) then
        begin
          MatchStart := i;
          GoodMatch := True;
          for j := 1 to Length(F) do
          begin // Scan for search string...
            if ((i + (j - 1)) <= Length(S)) then
            begin
              if (S[(i + (j - 1))] = F[j]) then
                GoodMatch := GoodMatch and True
              else
              begin
                GoodMatch := False;
                Break;
              end; // If
            end
            else
            begin
              GoodMatch := False;
              Break;
            end; // If
          end; // For j
          if GoodMatch then
          begin
            SkipToPos := i - Length(F);
            Inc(MatchCount);
          end; // If
          if (MatchCount = Count) then
          begin
            Result := MatchStart;
            Break;
          end; // If
        end; // If
      end; // For i
    end; // If
  end; // If
end; // MatchString

function ReplaceString(S : String; F : String; R : String; StartPos : LongInt; Occurance : LongInt; IgnoreCase : Boolean) : String;
// If "Occurance" = 0 then all occurance of "F" will be replaced with "R".
var
  i : LongInt;
  FPos : LongInt;
  TmpStr1 : String;
  TmpStr2 : String;
  OccurNo : LongInt;
begin
  Result := S;
  if IgnoreCase then
  begin
    S := UpperCase(S);
    F := UpperCase(F);
  end; // If
  if (StartPos <= Length(S)) then
  begin
    if (Occurance = 0) then
      OccurNo := OccuranceNo(S,F,IgnoreCase)
    else
      OccurNo := Occurance;
    for i := 1 to OccurNo do
    begin
      FPos := MatchString(Result,F,1,1,False,IgnoreCase);
      if (FPos > 0) then
      begin
        TmpStr1 := Copy(Result,1,(FPos - 1));
        TmpStr2 := Copy(Result,(FPos + Length(F)),(Length(S) - FPos{ - 1}));
        Result := Trim(TmpStr1 + R + TmpStr2);
      end; // If
    end; // For i
  end; // If
end; // ReplaceString

function InsertString(S : String; W : String; Index : LongInt) : String;
var
  LStr : String;
  RStr : String;
begin
  Result := S;
  if (Index <= Length(S)) then
  begin
    LStr := Copy(S,1,(Index - 1));
    RStr := Copy(S,(Index + 1),(Length(S) - Index));
    Result := LStr + W + RStr;
  end; // If
end; // InsertString

function ExtractFromString(S : String; StartPos : LongInt; EndPos : LongInt) : String;
begin
  Result := '';
  if (StartPos <= EndPos) then
    Result := Copy(S,StartPos,((EndPos - StartPos) + 1));
end; // ExtractFromString

function InsertCRLFIntoString(S : String; MaxLineLength : LongInt) : String;
// This function will insert a CRLF (#13#10) into the string at Index.  If Index
// is the middle of a word the function will insert the CRLF into the string just
// before the word. Also it will attempt to format based on indiviudal sentances.
const
  MinLineLength = 5;
var
  i : LongInt;
  j : LongInt;
  k : LongInt;
  MessagePart : String;
  StrMessage : String;
  CurrPeriodAt : LongInt;
  LastPeriodAt : LongInt;
  PeriodCount : LongInt;
  SequenceIndicated : Boolean;
  LastCRLFPos : LongInt;
begin
  // 56 Charactors is normal break point for "MessageDLG" function.
  Result := S;
  if (Length(S) > MaxLineLength) then
  begin
    LastPeriodAt := 0;
    LastCRLFPos := 0;
    PeriodCount := OccuranceNo(S,'.',True);
    if (PeriodCount > 0) then
    begin
      StrMessage := '';
      MessagePart := '';
      for i := 1 to PeriodCount do
      begin
        CurrPeriodAt := MatchString(S,'.',i,1,False,True);
//        MessagePart := {'  ' +} Trim(Copy(S,(LastPeriodAt + 1),((CurrPeriodAt - LastPeriodAt) + 1)));
        MessagePart := {'  ' +} Copy(S,(LastPeriodAt + 1),(CurrPeriodAt - LastPeriodAt));
        if (Length(MessagePart) > MinLineLength) then
        begin
          LastPeriodAt := CurrPeriodAt;
          StrMessage := StrMessage + MessagePart;
          if (Pos('.',MessagePart) > 1) and (Pos('.',MessagePart) <> Length(S))then
            SequenceIndicated := (MessagePart[(Pos('.',MessagePart) - 1)] in ['0'..'9']);
          if ((Length(StrMessage) - LastCRLFPos) > MaxLineLength) then
          begin
            if Not SequenceIndicated then
            begin
              for j := (Length(StrMessage) div MaxLineLength) downto 1 do
              begin
                  for k := (MaxLineLength * j) downto 1 do
                  begin
                      if (StrMessage[k] = ' ') then
                      begin
                        LastCRLFPos := k;
                        StrMessage := InsertString(StrMessage,#13#10,k);
                        Break;
                      end; // If
                  end; // For k
              end; // For j
            end
            else
            begin
              for j := (Length(MessagePart) div MaxLineLength) downto 1 do
              begin
                for k := Length(MessagePart) downto 1 do
                begin
                  if (MessagePart[k] = ' ') then
                  begin
                    LastCRLFPos := k;
                    StrMessage := InsertString(StrMessage,#13#10,(Length(StrMessage) - (Length(MessagePart) - k)));
                    Break;
                  end; // If
                end; // For k
              end; // For j
            end; // If
          end
          else
          begin
            if SequenceIndicated then
              StrMessage := StrMessage +#13#10;
          end; // If
        end; // If
      end; // For i
      Result := StrMessage;
    end; //
  end; // If
end; // InsertCRLRIntoString

function MPos(Substr: string; S: string; Count : LongInt): LongInt;
var
  i : LongInt;
  SubStrCount : LongInt;
begin
  Result := 0;
  SubStrCount := 0;
  for i := 1 to Length(S) do
  begin
    if (S[i] = SubStr) then
      Inc(SubStrCount);
    if (SubStrCount = Count) then
    begin
      Result := i;
      Break;
    end;
  end; // For i
end; // MPos

function RemoveCRLF(S : String) : String;
const
  CharArray : Array[0..1] of Char = (#13,#10);
var
  i : Byte;
  TmpStr : String;
begin
  TmpStr := S;
  for i := Low(CharArray) to High(CharArray) do
    TmpStr := ReplaceString(TmpStr,CharArray[i],'',1,0{0=All},False);
  Result := TmpStr;
end; // RemoveCRLF

end.
