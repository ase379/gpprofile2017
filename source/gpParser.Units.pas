unit gpParser.Units;

interface

uses
  System.Classes, System.SysUtils,
  gppTree,gpParser.baseProject,gpParser.Types, gpFileEdit, gpParser.Procs, gpParser.API, gppIDT;

type
  TUnit = class;

  TDefineList = class
    dlDefines: TStringList;
    constructor Create;
    destructor Destroy; override;
    procedure Define(conditional: string);
    procedure Undefine(conditional: string);
    function IsDefined(conditional: string): boolean;
    procedure Assign(conditionals: string);
  end;

  TUnitList = class(TRootNode<TUnit>)
  protected
    function GetLookupKey(const aValue : TUnit) : string; override;
  private
    constructor Create; reintroduce;
    procedure Add(anUnit: TUnit);
  end;

  TGlbUnitList = class(TRootNode<TUnit>)
  protected
    function GetLookupKey(const aValue : TUnit) : string; override;
  private
    constructor Create(); reintroduce;
  public
    function Locate(unitName: string): TUnit;
    function LocateCreate(unitName, unitLocation: string;excluded: boolean): TUnit;
  end;

  TUnit = class(TBaseUnit)
  private
    procedure AddToIntArray(var anArray: TArray<Integer>;const aValue: Integer);
    procedure InstrumentUses(const aProject: TBaseProject; const ed: TFileEdit;const anIndex: Integer);
    procedure BackupInstrumentedFile(const aSrc: string);
  public
    unName: TFilename;
    unFullName: TFileName;
    unUnits: TUnitList;
    unProcs: TProcList;
    unAPIs: TAPIList;
    unParsed: boolean;
    unExcluded: boolean;
    unInProjectDir: boolean;
    unAllInst: boolean;
    unNoneInst: boolean;
    unUsesOffset: TArray<Integer>;
    unImplementOffset: TArray<Integer>;
    unStartUses: TArray<Integer>;
    unEndUses: TArray<Integer>;
    unFileDate: TDateTime;
    constructor Create(const aUnitName: String;const aUnitLocation: String = ''; aExcluded: boolean = False);
    destructor Destroy; override;
    procedure Parse(aProject: TBaseProject; const aExclUnits, aSearchPath,aDefaultDir, aConditionals: string;
      const aRescan, aParseAsm: boolean);
    procedure CheckInstrumentedProcs;
    function LocateUnit(unitName: string): TUnit;
    function LocateProc(procName: string): TProc;
    procedure Instrument(aProject: TBaseProject; aIDT: TIDTable;aKeepDate, aBackupFile: boolean);
    procedure ConstructNames(idt: TIDTable);
    function AnyInstrumented: boolean;
    function AnyChange: boolean;
    function DidFileTimestampChange(): boolean;

  end;

implementation

uses
  System.IOUtils,
  GpString, gppCommon,
  CastaliaPasLex, CastaliaPasLexTypes;


{ ========================= TDefineList ========================= }

constructor TDefineList.Create;
begin
  inherited Create;
  dlDefines := TStringList.Create;
  dlDefines.Sorted := true;
end;

procedure TDefineList.Define(conditional: string);
begin
  if not IsDefined(conditional) then
    dlDefines.Add(UpperCase(conditional));
end;

destructor TDefineList.Destroy;
begin
  dlDefines.Free;
  inherited Destroy;
end;

function TDefineList.IsDefined(conditional: string): boolean;
begin
  Result := (dlDefines.IndexOf(UpperCase(conditional)) >= 0);
end;

procedure TDefineList.Undefine(conditional: string);
var
  idx: Integer;
begin
  idx := dlDefines.IndexOf(UpperCase(conditional));
  if idx >= 0 then
    dlDefines.Delete(idx);
end;

procedure TDefineList.Assign(conditionals: string);
var
  i: Integer;
begin
  dlDefines.Clear;
  for i := 1 to NumElements(conditionals, ';', -1) do
    Define(NthEl(conditionals, i, ';', -1));
end;


{ ========================= TUnitList ========================= }

function CompareUnit(node1, node2: INode<TUnit>): Integer;
begin
  Result := String.Compare(node1.Data.unName,node2.Data.unName,true);
end; { CompareUnit }

constructor TUnitList.Create;
begin
  inherited Create();
  CompareFunc := @CompareUnit;
end;

function TUnitList.GetLookupKey(const aValue: TUnit): string;
begin
  result := AnsiLowerCase(aValue.unName);
end;

{ TUnitList.Create }

procedure TUnitList.Add(anUnit: TUnit);
begin
  AppendNode(anUnit);
end; { TUnitList.Add }

{ ========================= TGlbUnitList ========================= }

constructor TGlbUnitList.Create();
begin
  inherited Create();
  CompareFunc := @CompareUnit;
end; { TGlbUnitList.Create }

function TGlbUnitList.GetLookupKey(const aValue: TUnit): string;
begin
  result := AnsiLowerCase(aValue.unName);
end;

function TGlbUnitList.Locate(unitName: string): TUnit;
var
  LSearchEntry: INode<TUnit>;
  LFoundEntry: INode<TUnit>;
begin
  LSearchEntry := TNode<TUnit>.Create();
  LSearchEntry.Data := TUnit.Create(unitName);
  if FindNode(LSearchEntry, LFoundEntry) then
    Locate := LFoundEntry.Data
  else
    Locate := nil;
end; { TGlbUnitList.Locate }

function TGlbUnitList.LocateCreate(unitName, unitLocation: string;
  excluded: boolean): TUnit;
var
  un: TUnit;
begin
  Result := Locate(unitName);
  if Result = nil then
  begin
    un := TUnit.Create(unitName, unitLocation, excluded);
    Result := AppendNode(un).Data;
  end;
end; { TGlbUnitList.LocateCreate }


{ ========================= TUnit ========================= }

constructor TUnit.Create(const aUnitName: String;
  const aUnitLocation: String = ''; aExcluded: boolean = False);
begin
  unName := ExtractFileName(aUnitName);
  if aUnitLocation = '' then
    unFullName := aUnitName
  else
    unFullName := aUnitLocation;
  unUnits := TUnitList.Create;
  unProcs := TProcList.Create;
  unAPIs := TAPIList.Create;
  unParsed := False;
  unExcluded := aExcluded;
  unAllInst := False;
  unNoneInst := true;
  SetLength(unUsesOffset, 0);
  SetLength(unImplementOffset, 0);
  SetLength(unStartUses, 0);
  SetLength(unEndUses, 0);
  unFileDate := -1.0;
end; { TUnit.Create }

destructor TUnit.Destroy;
begin
  unUnits.Free;
  unProcs.Free;
  unAPIs.Free;
end;

function TUnit.DidFileTimestampChange: boolean;
var
  LOutDateTime : TDateTime;
begin
  if not FileAge(unFullName,LOutDateTime) then
    LOutDateTime := 0.0;
  result := unFileDate <> LOutDateTime;
end;

{ TUnit.Destroy }

// Get full path to unit having short unit name or relative path
// NB!!! This path can differ from location, which Delphi will use for this unit during compilation!
// (it is just _some_ location from search paths where unit file with the given name is found)
function FindOnPath(aUnitName: String; const aSearchPath, aDefDir: string;
  out aUnitFullName: TFileName): boolean;
var
  i: Integer;
  s: string;
  vDefDir: string;
  LExtension: string;
begin
  aUnitFullName := '';
  Result := False;

  LExtension := ExtractFileExt(aUnitName).ToLower;
  if (LExtension <> '.pas') and (LExtension <> '.dpr') then
    aUnitName := aUnitName + '.pas';

  if FileExists(aUnitName) then
  begin
    aUnitFullName := LowerCase(ExpandUNCFileName(aUnitName));
    Result := true;
    Exit;
  end;

  vDefDir := MakeBackslash(aDefDir);

  if FileExists(vDefDir + aUnitName) then
  begin
    aUnitFullName := LowerCase(vDefDir + aUnitName);
    Result := true;
    Exit;
  end;

  for i := 1 to NumElements(aSearchPath, ';', -1) do
  begin
    s := Compress(NthEl(aSearchPath, i, ';', -1));
    Assert(IsAbsolutePath(s));
    // Search paths must be converted to absolute before calling FindOnPath
    s := MakeSmartBackslash(s) + aUnitName;
    if FileExists(s) then
    begin
      aUnitFullName := LowerCase(s);
      Result := true;
      Exit;
    end;
  end;
end; { FindOnPath }

procedure TUnit.Parse(aProject: TBaseProject; const aExclUnits, aSearchPath,
  aDefaultDir, aConditionals: String; const aRescan, aParseAsm: boolean);
type
  TParseState = (stScan, stParseUses
    // Parse uses list (with optional "in" clause in dpr-file)
    , stScanProcName // Parse method name
    , stScanProcAfterName
    // Parse method after name (e.g. parameters, overload clauses etc.), till the beginning of method body (till begin..end)
    , stScanProcBody // Parse method body (begin..end)
    , stScanProcSkipGenericParams
    // Skip parameters of generic (TSomeGeneric<Params>.MethodName) - wait till symbol ">"
    , stWaitSemi // Parse till semicolon
    );
var
  isInstrumentationFlag: boolean;
  parser: TmwPasLex;
  stream: TMemoryStream;
  state: TParseState;
  stateComment: (stWaitEnterBegin, stWaitEnterEnd, stWaitExitBegin,
    stWaitExitEnd, stWaitExitBegin2, stNone);
  cmtEnterBegin: Integer;
  cmtEnterEnd: Integer;
  cmtExitBegin: Integer;
  cmtExitEnd: Integer;
  implement: boolean;
  block: Integer;
  procName: string;
  proclnum: Integer;
  stk: string;
  lnumstk: string;
  procn: string;
  uun: string;
  ugpprof: string;
  unName: string;
  unLocation: string;
  tokenID: TptTokenKind;
  tokenData: string;
  tokenPos: Integer;
  tokenLN: Integer;
  inAsmBlock: boolean;
  inRecordDef: boolean;
  prevTokenID: TptTokenKind;
  apiCmd: string;
  apiStart: Integer;
  apiStartEnd: Integer;
  direct: string;
  parserStack: TList;
  skipList: TList;
  skipping: boolean;
  conds: TDefineList;
  incName: string;

  function IsBlockStartToken(token: TptTokenKind): boolean;
  begin
    if inRecordDef and (token = ptCase) then
      Result := False
    else
      Result := (token = ptBegin) or (token = ptRepeat) or (token = ptCase) or
        (token = ptTry) or (token = ptAsm) or (token = ptRecord);

    if token = ptAsm then
      inAsmBlock := true;
    if token = ptRecord then
      inRecordDef := true;
  end; { IsBlockStartToken }

  function IsBlockEndToken(token: TptTokenKind): boolean;
  begin
    IsBlockEndToken := (token = ptEnd) or (token = ptUntil);
    if Result then
    begin
      inAsmBlock := False;
      inRecordDef := False;
    end;
  end; { IsBlockEndToken }

// Get absolute unit path from dpr-file (path to unit in dpr file can be relative or absent)
  function ExpandLocation(const aLocation: string): string;
  var
    vLocation: String;
  begin
    if aLocation = '' then // path to unit in dpr-file not specified
      Result := ''
    else
    begin
      // Trim apostrophes
      Assert(Length(aLocation) > 2);
      Assert((aLocation[1] = '''') and (aLocation[Length(aLocation)] = ''''));
      vLocation := Copy(aLocation, 2, Length(aLocation) - 2);
      // Convert path to absolute
      if IsAbsolutePath(vLocation) then
        // If unit path is absolute => simply return it
        Result := vLocation
      else
        // Relative path: full unit path = dpr path + relative unit location
        Result := ExpandFileName
          (MakeBackslash(ExtractFilePath(aProject.GetFullUnitName())) +
          vLocation);
    end;
  end; { ExpandLocation }

  procedure CreateNewParser(const aUnitFN, aSearchPath: string);
  var
    zero: char;
    vUnitFullName: TFileName;
  begin
    if parser <> nil then
    begin
      parserStack.Add(parser);
      parserStack.Add(stream);
    end;


    if not FindOnPath(aUnitFN, aSearchPath, aDefaultDir, vUnitFullName) then
      raise EUnitInSearchPathNotFoundError.Create('Unit not found in search path: '
        + aUnitFN);

    parser := TmwPasLex.Create;
    stream := TMemoryStream.Create();
    try
      stream.LoadFromFile(vUnitFullName);
    except
      stream.Free;
      raise;
    end;

    stream.Position := stream.Size;
    zero := #0;
    stream.Write(zero, 1);
    parser.Origin := pAnsichar(stream.Memory);
    parser.RunPos := 0;
  end; { CreateNewParser }

  function RemoveLastParser: boolean;
  begin
    parser.Free;
    stream.Free;
    if parserStack.Count > 0 then
    begin
      parser := TmwPasLex(parserStack[parserStack.Count - 2]);
      stream := TMemoryStream(parserStack[parserStack.Count - 1]);
      parserStack.Delete(parserStack.Count - 1);
      parserStack.Delete(parserStack.Count - 1);
      parser.Next;
      Result := true;
    end
    else
    begin
      parser := nil;
      stream := nil;
      Result := False;
    end;
  end; { RemoveLastParser }

  function ExtractCommentBody(comment: string): string;
  begin
    if comment = '' then
      Result := ''
    else if comment[1] = '{' then
      Result := Copy(comment, 2, Length(comment) - 2)
    else
      Result := Copy(comment, 3, Length(comment) - 4);
  end; { ExtractCommentBody }

  function ExtractDirective(comment: string): string;
  begin
    Result := ButFirst(UpperCase(FirstEl(ExtractCommentBody(comment),
      ' ', -1)), 1);
    // Fix Delphi stupidity - Delphi parses {$ENDIF.} (where '.' is any
    // non-ident character (alpha, number, underscore)) as {$ENDIF}
    while (Result <> '') and
      (not(CharInSet(Result[Length(Result)],['a'..'z','A'..'Z','0'..'9','_','+', '-']))) do
      Delete(Result, Length(Result), 1);
  end; { ExtractDirective }

  function ExtractParameter(comment: string; parameter: Integer): string;
  begin
    Result := NthEl(ExtractCommentBody(comment), parameter + 1, ' ', -1);
  end; { ExtractParameter }

  procedure PushSkippingState(skipping: boolean; isIFOPT: boolean);
  begin
    skipList.Add(pointer(skipping));
    skipList.Add(pointer(isIFOPT));
  end; { PushSkippingState }

  function WasSkipping: boolean;
  begin
    if skipList.Count = 0 then
      Result := False
    else
      Result := boolean(skipList[skipList.Count - 2]);
  end; { WasSkipping }

  function InIFOPT: boolean;
  begin
    if skipList.Count = 0 then
      Result := False // should not happen, but ...
    else
      Result := boolean(skipList[skipList.Count - 1]);
  end; { TUnit.InIFOPT }

  function PopSkippingState: boolean;
  begin
    if skipList.Count = 0 then
      Result := true // source damaged - skip the rest
    else
    begin
      skipList.Delete(skipList.Count - 1);
      Result := boolean(skipList[skipList.Count - 1]);
      skipList.Delete(skipList.Count - 1);
    end;
  end; { PopSkippingState }

  function IsOneOf(key: string; compareWith: array of string): boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := Low(compareWith) to High(compareWith) do
      if key = compareWith[i] then
        exit(true);
  end; { IsOneOf }

var
  vUnitFullName: TFileName;
  LSelfBuffer: string;
  LDataLowerCase: string;
begin
  unParsed := true;
  parserStack := TList.Create;
  try
    if not aRescan then
    begin
      // Anton Alisov: not sure, for what reason FindOnPath is called here with unFullName instead of unName
      if not FindOnPath(unFullName, aSearchPath, aDefaultDir, vUnitFullName) then
      begin
        aProject.prMissingUnitNames.AddOrSetValue(unFullname,0);
        raise EUnitInSearchPathNotFoundError.Create('Unit not found in search path: ' + unFullName);
      end;
      unFullName := vUnitFullName;
      Assert(IsAbsolutePath(unFullName));
      unInProjectDir := (self.unFullName = aProject.GetFullUnitName) or
        AnsiSameText(ExtractFilePath(self.unFullName),
        ExtractFilePath(aProject.GetFullUnitName));
    end
    else
    begin
      unProcs.Free;
      unProcs := TProcList.Create;
      unUnits.Free;
      unUnits := TUnitList.Create;
    end;
    unAPIs.Free;
    unAPIs := TAPIList.Create;

    parser := nil;
    CreateNewParser(unFullName, '');
    if not FileAge(unFullName,unFileDate) then
      unFileDate := 0.0;
    state := stScan;
    stateComment := stNone;
    implement := False;
    block := 0;
    procName := '';
    proclnum := -1;
    stk := '';
    lnumstk := '';
    ugpprof := UpperCase(cProfUnitName);
    cmtEnterBegin := -1;
    cmtEnterEnd := -1;
    cmtExitBegin := -1;
    cmtExitEnd := -1;
    unName := '';
    unLocation := '';
    SetLength(unUsesOffset, 0);
    SetLength(unImplementOffset, 0);
    SetLength(unStartUses, 0);
    SetLength(unEndUses, 0);
    inAsmBlock := False;
    inRecordDef := False;
    prevTokenID := ptNull;
    apiStart := -1;
    apiStartEnd := -1;
    skipping := False;
    skipList := TList.Create;
    try
      conds := TDefineList.Create;
      conds.Assign(aConditionals);
      try
        repeat
          while parser.tokenID <> ptNull do
          begin
            tokenID := parser.tokenID;
            tokenData := parser.token;
            tokenPos := parser.tokenPos;
            tokenLN := parser.LineNumber;

            if tokenID = ptCompDirect then
            begin
              // Don't process conditional compilation directive if it is
              // actually an instrumentation flag!
              with aProject do
                isInstrumentationFlag :=
                  IsOneOf(tokenData, [prConditStart, prConditStartUses,
                  prConditStartAPI, prConditEnd, prConditEndUses,
                  prConditEndAPI]);
              if not isInstrumentationFlag then
              begin
                direct := ExtractDirective(tokenData);
                if direct = 'IFDEF' then
                begin // process $IFDEF
                  PushSkippingState(skipping, False);
                  skipping := skipping or
                    (not conds.IsDefined(ExtractParameter(tokenData, 1)));
                end
                else if direct = 'IFOPT' then
                begin // process $IFOPT
                  PushSkippingState(skipping, true);
                end
                else if direct = 'IFNDEF' then
                begin // process $IFNDEF
                  PushSkippingState(skipping, False);
                  skipping := skipping or
                    conds.IsDefined(ExtractParameter(tokenData, 1));
                end
                else if direct = 'ENDIF' then
                begin // process $ENDIF
                  skipping := PopSkippingState;
                end
                else if direct = 'ELSE' then
                begin // process $ELSE
                  if (not InIFOPT) and (not WasSkipping) then
                    skipping := not skipping;
                end;
              end;
            end;

            if not skipping then
            begin // we're not in the middle of conditionally removed block
              if (tokenID = ptPoint) and (prevTokenID = ptEnd) then
                Break; // final end.

              if tokenID = ptCompDirect then
              begin
                if (direct = 'INCLUDE') or (direct = 'I') then
                begin // process $INCLUDE
                  // process {$I *.INC}
                  incName := ExtractParameter(tokenData, 1);
                  if FirstEl(incName, '.', -1) = '*' then
                    incName := FirstEl(ExtractFileName(unFullName), '.', -1) +
                      '.' + ButFirstEl(incName, '.', -1);
                  CreateNewParser(incName, aSearchPath);
                  continue;
                end
                else if direct = 'DEFINE' then // process $DEFINE
                  conds.Define(ExtractParameter(tokenData, 1))
                else if direct = 'UNDEF' then // process $UNDEF
                  conds.Undefine(ExtractParameter(tokenData, 1));
              end;

              if inAsmBlock and ((prevTokenID = ptAddressOp) or
                (prevTokenID = ptDoubleAddressOp)) and (tokenID <> ptAddressOp)
                and (tokenID <> ptDoubleAddressOp) then
                tokenID := ptIdentifier;

              // fix mwPasParser's feature - these are not reserved words!
              if (tokenID = ptRead) or (tokenID = ptWrite) or (tokenID = ptName)
                or (tokenID = ptIndex) or (tokenID = ptStored) or
                (tokenID = ptReadonly) or (tokenID = ptResident) or
                (tokenID = ptNodefault) or (tokenID = ptAutomated) or
                (tokenID = ptWriteonly) then
                tokenID := ptIdentifier;

              if (tokenID = ptBorComment) or (tokenID = ptAnsiComment) or
                (tokenID = ptCompDirect) then
              begin
                if tokenData = aProject.prConditStartUses then
                  AddToIntArray(unStartUses, tokenPos)
                else if tokenData = aProject.prConditEndUses then
                  AddToIntArray(unEndUses, tokenPos)
                else if ((tokenID = ptBorComment) and
                  (Copy(tokenData, 1, 1 + Length(aProject.prAPIIntro)) = '{' +
                  aProject.prAPIIntro)) or
                  ((tokenID = ptAnsiComment) and
                  (Copy(tokenData, 1, 2 + Length(aProject.prAPIIntro)) = '(*' +
                  aProject.prAPIIntro)) then
                begin
                  if tokenID = ptBorComment then
                    apiCmd := TrimL
                      (Trim(ButLast(ButFirst(tokenData,
                      1 + Length(aProject.prAPIIntro)), 1)))
                  else
                    apiCmd := TrimL
                      (Trim(ButLast(ButFirst(tokenData,
                      2 + Length(aProject.prAPIIntro)), 2)));

                  if parserStack.Count = 0 then
                    unAPIs.AddMeta(apiCmd, tokenPos,
                      tokenPos + Length(tokenData) - 1);
                end
                else if tokenData = aProject.prConditStartAPI then
                begin
                  apiStart := tokenPos;
                  apiStartEnd := tokenPos + Length(tokenData) - 1;
                end
                else if tokenData = aProject.prConditEndAPI then
                  if parserStack.Count = 0 then
                    unAPIs.AddExpanded(apiStart, apiStartEnd, tokenPos,
                      tokenPos + Length(tokenData) - 1);
              end;

              if state = stWaitSemi then
              begin
                if tokenID = ptSemicolon then
                begin
                  AddToIntArray(unImplementOffset, tokenPos + 1);
                  state := stScan;
                end;
              end
              else if state = stParseUses then
              begin
                if (tokenID = ptSemicolon) or (tokenID = ptComma) then
                begin
                  if tokenID = ptSemicolon then
                    state := stScan;
                  if unName <> '' then
                  begin
                    uun := UpperCase(unName);
                    unUnits.Add(aProject.LocateOrCreateUnit(unName, ExpandLocation(unLocation),
                      (Pos(#13#10 + uun + #13#10, aExclUnits) <> 0) or (uun = ugpprof))as TUnit);
                  end;
                  unName := '';
                  unLocation := '';
                end
                else if tokenID = ptIdentifier then // unit name
                  unName := unName + tokenData
                else if tokenID = ptPoint then
                  unName := unName + '.'
                else if tokenID = ptStringConst then
                // unit location from "in 'somepath\someunit.pas'" (dpr-file)
                  unLocation := tokenData
              end
              else if state = stScanProcSkipGenericParams then
              begin
                if tokenID = ptGreater then
                  state := stScanProcName;
              end
              else if state = stScanProcName then
              begin
                if (tokenID = ptIdentifier) or (tokenID = ptPoint) or
                  (tokenID = ptRegister) then
                begin
                  procName := procName + tokenData;
                  proclnum := tokenLN;
                end
                else if tokenID = ptLower then
                // "<" in method name => skip params of generic till ">"
                  state := stScanProcSkipGenericParams
                else if tokenID in [ptSemicolon, ptRoundOpen, ptColon] then
                  state := stScanProcAfterName
              end
              else if state = stScanProcAfterName then
              begin
                if ((tokenID = ptProcedure) or (tokenID = ptFunction) or
                  (tokenID = ptConstructor) or (tokenID = ptDestructor)) and implement
                then
                begin
                  state := stScanProcName;
                  block := 0;
                  if procName <> '' then
                  begin
                    stk := stk + '/' + procName;
                    lnumstk := lnumstk + '/' + IntToStr(proclnum);
                  end;
                  procName := '';
                  proclnum := -1;
                end
                else if (tokenID = ptForward) or (tokenID = ptExternal) then
                begin
                  procName := '';
                  proclnum := -1;
                end
                else
                begin
                  if IsBlockStartToken(tokenID) then
                    Inc(block)
                  else if IsBlockEndToken(tokenID) then
                    Dec(block);

                  if block < 0 then
                  begin
                    state := stScan;
                    stk := '';
                    lnumstk := '';
                    procName := '';
                    proclnum := -1;
                  end
                  else if (block > 0) and (not inRecordDef) then
                  begin
                    if stk <> '' then
                      procn := ButFirst(stk, 1) + '/' + procName
                    else
                      procn := procName;

                    if parserStack.Count = 0 then
                      if (tokenID <> ptAsm) or aParseAsm then
                        unProcs.Add(procn, (tokenID = ptAsm), tokenPos, tokenLN,
                          proclnum);

                    state := stScanProcBody;
                    stateComment := stWaitEnterBegin;
                  end;
                end;
              end
              else if state = stScanProcBody then
              begin
                if IsBlockStartToken(tokenID) then
                  Inc(block)
                else if IsBlockEndToken(tokenID) then
                  Dec(block);

                if (tokenID = ptBorComment) or (tokenID = ptCompDirect) then
                begin
                  if tokenData = aProject.prConditStart then
                  begin
                    if stateComment = stWaitEnterBegin then
                    begin
                      cmtEnterBegin := tokenPos;
                      stateComment := stWaitEnterEnd;
                    end
                    else if (stateComment = stWaitExitBegin) or
                      (stateComment = stWaitExitBegin2) then
                    begin
                      cmtExitBegin := tokenPos;
                      stateComment := stWaitExitEnd;
                    end;
                  end
                  else if tokenData = aProject.prConditEnd then
                  begin
                    if stateComment = stWaitEnterEnd then
                    begin
                      cmtEnterEnd := tokenPos;
                      stateComment := stWaitExitBegin;
                    end
                    else if stateComment = stWaitExitEnd then
                    begin
                      cmtExitEnd := tokenPos;
                      stateComment := stWaitExitBegin2;
                    end;
                  end

                end
                else if (tokenID = ptIdentifier) then
                begin
                  LDataLowerCase := tokenData.ToLowerInvariant;
                  if LDataLowerCase = aProject.prNameThreadForDebugging then
                  begin
                    unProcs.Last.Data.unSetThreadNames.AddPosition(tokenPos,
                      LSelfBuffer);
                    LSelfBuffer := '';
                  end
                  else if LDataLowerCase = 'self' then
                    LSelfBuffer := tokenData;
                end;

                if block = 0 then
                begin
                  if parserStack.Count = 0 then
                  begin
                    unProcs.AddEnd(procn, tokenPos, tokenLN);
                    if stateComment = stWaitExitBegin2 then
                    begin
                      unProcs.AddInstrumented(procn, cmtEnterBegin, cmtEnterEnd,
                        cmtExitBegin, cmtExitEnd);
                      CheckInstrumentedProcs;
                    end;
                  end;

                  stateComment := stNone;
                  if stk = '' then
                  begin
                    procName := '';
                    proclnum := -1;
                    state := stScan;
                  end
                  else
                  begin
                    procName := LastEl(stk, '/', -1);
                    proclnum := StrToInt(LastEl(lnumstk, '/', -1));
                    stk := ButLastEl(stk, '/', -1);
                    lnumstk := ButLastEl(lnumstk, '/', -1);
                    state := stScanProcAfterName;
                  end;
                end;
              end
              else if (tokenID = ptUses) or (tokenID = ptContains) then
              begin
                state := stParseUses;
                if implement then
                  AddToIntArray(unUsesOffset, tokenPos);
              end
              else if tokenID = ptImplementation then
              begin
                implement := true;
                AddToIntArray(unImplementOffset, tokenPos);
              end
              else if tokenID = ptProgram then
              begin
                implement := true;
                state := stWaitSemi;
              end
              else if ((tokenID = ptProcedure) or (tokenID = ptFunction) or
                (tokenID = ptConstructor) or (tokenID = ptDestructor)) and implement
              then
              begin
                state := stScanProcName;
                block := 0;
                if procName <> '' then
                begin
                  stk := stk + '/' + procName;
                  lnumstk := lnumstk + '/' + IntToStr(proclnum);
                end;
                procName := '';
                proclnum := -1;
              end;
            end; // if not skipping

            prevTokenID := tokenID;
            parser.Next;
          end; // while
        until not RemoveLastParser;
      finally
        conds.Free;
      end;
    finally
      skipList.Free;
    end;
  finally
    parserStack.Free;
  end;
end; { TUnit.Parse }

procedure TUnit.CheckInstrumentedProcs;
var
  LEnumor: TRootNode<TProc>.TEnumerator;
begin
  unAllInst := true;
  unNoneInst := true;
  with unProcs do
  begin
    LEnumor := GetEnumerator();
    while LEnumor.MoveNext do
    begin
      if not LEnumor.Current.Data.prInstrumented then
        unAllInst := False
      else
        unNoneInst := False;
    end;
    LEnumor.Free;
  end;
end; { TUnit.CheckInstrumentedProcs }

function TUnit.LocateUnit(unitName: string): TUnit;
var
  LSearchEntry: INode<TUnit>;
  LFoundEntry: INode<TUnit>;
begin
  LSearchEntry := TNode<TUnit>.Create();
  LSearchEntry.Data := TUnit.Create(unitName);
  if unUnits.FindNode(LSearchEntry, LFoundEntry) then
    Result := LFoundEntry.Data
  else
    Result := nil;
end; { TUnit.LocateUnit }

function TUnit.LocateProc(procName: string): TProc;
var
  LSearchEntry: INode<TProc>;
  LFoundEntry: INode<TProc>;
begin
  LSearchEntry := TNode<TProc>.Create();
  LSearchEntry.Data := TProc.Create(procName);
  if unProcs.FindNode(LSearchEntry, LFoundEntry) then
    Result := LFoundEntry.Data
  else
    Result := nil;
end; { TUnit.LocateProc }

procedure TUnit.ConstructNames(idt: TIDTable);
var
  LEnumor: TRootNode<TProc>.TEnumerator;
begin
  LEnumor := unProcs.GetEnumerator;
  while LEnumor.MoveNext do
  begin
    if LEnumor.Current.Data.prInstrumented then
      idt.ConstructName(unName, unFullName, LEnumor.Current.Data.Name,
        LEnumor.Current.Data.prHeaderLineNum);
  end;
  LEnumor.Free;
end; { TUnit.ConstructNames }

procedure TUnit.BackupInstrumentedFile(const aSrc: string);
var
  justName: string;
begin
  justName := ButLastEl(aSrc, '.', Ord(-1));
  System.SysUtils.DeleteFile(justName + '.bk2');
  RenameFile(justName + '.bk1', justName + '.bk2');
  TFile.Copy(aSrc, justName + '.bk1', true);
end;

procedure TUnit.InstrumentUses(const aProject: TBaseProject; const ed: TFileEdit;
  const anIndex: Integer);

  function LGetValueOrZero(const anArray: TArray<Integer>;
    const anIndex: Integer): Integer;
  begin
    if anIndex < Length(anArray) then
      Result := anArray[anIndex]
    else
      Result := 0;
  end;

var
  any: boolean;
  haveUses: boolean;
  LStartUses: Integer;
  LEndUses: Integer;
  LUsesOffset: Integer;
  LImplementationOffset: Integer;
  LUnit: TUnit;
begin
  any := AnyInstrumented;
  LStartUses := LGetValueOrZero(unStartUses, anIndex);
  LEndUses := LGetValueOrZero(unEndUses, anIndex);
  LUsesOffset := LGetValueOrZero(unUsesOffset, anIndex);
  LImplementationOffset := LGetValueOrZero(unImplementOffset, anIndex);
  haveUses := (LStartUses > 0) and (LEndUses > LStartUses);
  if haveUses and (not any) then
    ed.Remove(LStartUses, LEndUses + Length(aProject.prConditEndUses) - 1)
  else if (not haveUses) and any then
  begin
    LUnit := LocateUnit(cProfUnitName);
    if (LUnit = nil) then
    begin
      if LUsesOffset > 0 then
        ed.Insert(LUsesOffset + Length('uses'), aProject.prAppendUses)
      else
        ed.Insert(LImplementationOffset + Length('implementation'),
          aProject.prCreateUses);
    end;
  end;
end;

procedure TUnit.Instrument(aProject: TBaseProject; aIDT: TIDTable;
  aKeepDate, aBackupFile: boolean);

  function LAdjustUsesCount: Integer;
  begin
    Result := Length(unStartUses);
    if Length(unEndUses) > Result then
      Result := Length(unEndUses);
    if Length(unUsesOffset) > Result then
      Result := Length(unUsesOffset);
    if Length(unImplementOffset) > Result then
      Result := Length(unImplementOffset);
  end;

var
  pr: TProc;
  any: boolean;
  haveInst: boolean;
  ed: TFileEdit;
  nameId: Integer;
  api: TAPI;
  LApiEnumor: TRootNode<TAPI>.TEnumerator;
  LProcEnumor: TRootNode<TProc>.TEnumerator;
  LProcSetThreadNameEnumor: TRootNode<TProcSetThreadName>.TEnumerator;
  i: Integer;
  LPosition: Integer;
begin { TUnit.Instrument }
  if Length(unImplementOffset) = 0 then
    raise Exception.Create('No implementation part defined in unit ' +
      unName + '!');

  if aBackupFile then
    BackupInstrumentedFile(unFullName);

  ed := TFileEdit.Create(unFullName);
  try
    // update uses...
    for i := 0 to LAdjustUsesCount - 1 do
      InstrumentUses(aProject, ed, i);

    any := AnyInstrumented;
    LApiEnumor := unAPIs.GetEnumerator();
    while LApiEnumor.MoveNext do
    begin
      api := LApiEnumor.Current.Data;
      if any then
      begin
        if api.apiMeta then
        begin
          ed.Remove(api.apiBeginOffs, api.apiEndOffs);
          ed.Insert(api.apiBeginOffs, Format(aProject.prProfileAPI,
            [api.apiCommands]));
        end
      end
      else
      begin
        if not api.apiMeta then
        begin
          ed.Remove(api.apiBeginOffs, api.apiEndOffs);
          ed.Insert(api.apiBeginOffs, '{' + aProject.prAPIIntro);
          ed.Remove(api.apiExitBegin, api.apiExitEnd);
          ed.Insert(api.apiExitBegin, '}');
        end;
      end;
    end;
    LApiEnumor.Free;

    LProcEnumor := unProcs.GetEnumerator();
    while LProcEnumor.MoveNext do
    begin
      pr := LProcEnumor.Current.Data;
      haveInst := (pr.prCmtEnterBegin >= 0);
      if not pr.prInstrumented then
      begin
        if haveInst then
        begin // remove instrumentation
          ed.Remove(pr.prCmtEnterBegin, pr.prCmtEnterEnd +
            Length(aProject.prConditEnd) - 1);
          ed.Remove(pr.prCmtExitBegin, pr.prCmtExitEnd +
            Length(aProject.prConditEnd) - 1);

          // remove gpprof in from of NameThreadForDebugging interceptor
          LProcSetThreadNameEnumor := pr.unSetThreadNames.GetEnumerator;
          while LProcSetThreadNameEnumor.MoveNext do
          begin
            LPosition := LProcSetThreadNameEnumor.Current.Data.tpstnPos - Length(aProject.prGpprofDot);
            if LProcSetThreadNameEnumor.Current.Data.tpstnWithSelf <> '' then
              LPosition := LPosition - 1; // remove } as well
            ed.Remove(LPosition, LProcSetThreadNameEnumor.Current.Data.tpstnPos - 1);
            if LProcSetThreadNameEnumor.Current.Data.tpstnWithSelf <> '' then
            begin
              LPosition := LPosition - 2 - Length(LProcSetThreadNameEnumor.Current.Data.tpstnWithSelf);
              ed.Remove(LPosition, LPosition);
            end;
          end;
          LProcSetThreadNameEnumor.Free;
        end;
      end
      else
      begin
        nameId := aIDT.ConstructName(unName, unFullName, pr.Name,
          pr.prHeaderLineNum);

        if haveInst then
          ed.Remove(pr.prCmtEnterBegin, pr.prCmtEnterEnd +
            Length(aProject.prConditEnd) - 1);

        if pr.prPureAsm then
          ed.Insert(pr.prStartOffset + Length('asm'),
            Format(aProject.prProfileEnterAsm, [nameId]))
        else
          ed.Insert(pr.prStartOffset + Length('begin'),
            Format(aProject.prProfileEnterProc, [nameId]));

        if haveInst then
        begin
          LProcSetThreadNameEnumor := pr.unSetThreadNames.GetEnumerator;
          while LProcSetThreadNameEnumor.MoveNext do
          begin
            LPosition := LProcSetThreadNameEnumor.Current.Data.tpstnPos - Length(aProject.prGpprofDot);
            ed.Remove(LPosition, LProcSetThreadNameEnumor.Current.Data.tpstnPos - 1);
          end;
          LProcSetThreadNameEnumor.Free;
        end;
        // add gpprof in from of NameThreadForDebugging interceptor
        LProcSetThreadNameEnumor := pr.unSetThreadNames.GetEnumerator;
        while LProcSetThreadNameEnumor.MoveNext do
        begin
          LPosition := LProcSetThreadNameEnumor.Current.Data.tpstnPos;
          if LProcSetThreadNameEnumor.Current.Data.tpstnWithSelf <> '' then
          begin
            ed.Insert(LPosition - Length('self') - 1, '{');
            ed.Insert(LPosition, '}' + aProject.prGpprofDot);
          end
          else
            ed.Insert(LPosition, aProject.prGpprofDot);
        end;
        LProcSetThreadNameEnumor.Free;

        if haveInst then
          ed.Remove(pr.prCmtExitBegin, pr.prCmtExitEnd +
            Length(aProject.prConditEnd) - 1);

        if pr.prPureAsm then
          ed.Insert(pr.prEndOffset, Format(aProject.prProfileExitAsm, [nameId]))
        else
          ed.Insert(pr.prEndOffset, Format(aProject.prProfileExitProc, [nameId]));
      end;
    end;
    LProcEnumor.Free;

    ed.Execute(aKeepDate);
  finally
    ed.Free;
  end;
end; { TUnit.Instrument }

function TUnit.AnyInstrumented: boolean;
var
  LProcEnumerator: TRootNode<TProc>.TEnumerator;
begin
  Result := False;
  with unProcs do
  begin
    LProcEnumerator := GetEnumerator();
    while LProcEnumerator.MoveNext do
    begin
      if LProcEnumerator.Current.Data.prInstrumented then
      begin
        Result := true;
        Exit;
      end;
    end; // while
    LProcEnumerator.Free;
  end; // with
end; { TUnit.AnyInstrumented }

procedure TUnit.AddToIntArray(var anArray: TArray<Integer>;
  const aValue: Integer);
var
  LCount: Integer;
begin
  LCount := Length(anArray);
  SetLength(anArray, LCount + 1);
  anArray[LCount] := aValue;
end; { TUnit.AddToIntArray }

function TUnit.AnyChange: boolean;
var
  pr: TProc;
  LProcEnumerator: TRootNode<TProc>.TEnumerator;
begin
  Result := False;
  with unProcs do
  begin
    LProcEnumerator := GetEnumerator();
    while LProcEnumerator.MoveNext do
    begin
      pr := LProcEnumerator.Current.Data;
      if pr.prInstrumented <> pr.prInitial then
      begin
        Result := true;
        Exit;
      end;
    end; // while
    LProcEnumerator.Free;
  end; // with
end; { TUnit.AnyChange }

end.
