{$I OPTIONS.INC}
unit gpParser;

interface

uses
  System.Classes,
  System.SysUtils,
  gppIDT,
  Dialogs,
  gppTree,
  gpFileEdit;

type
  EUnitNotFoundException = class(Exception);
  TNotifyProc = procedure(const aUnitName: String) of object;
  TNotifyInstProc = procedure(const aFullName, aUnitName: String;aParse: boolean) of object;

  // Do not change order
  TCommentType = (Ct_Arrow = 0, Ct_IfDef = 1);

  TUnitList = class;
  TProcList = class;
  TAPIList = class;
  TProcSetThreadNameList = class;
  TProject = class;
  TProc = class;

  TDefineList = class
    dlDefines: TStringList;
    constructor Create;
    destructor Destroy; override;
    procedure Define(conditional: string);
    procedure Undefine(conditional: string);
    function IsDefined(conditional: string): boolean;
    procedure Assign(conditionals: string);
  end;

  TUnit = class
  private
    procedure AddToIntArray(var anArray: TArray<Integer>;const aValue: Integer);
    procedure InstrumentUses(const aProject: TProject; const ed: TFileEdit;const anIndex: Integer);
    procedure BackupInstrumentedFile(const aSrc: string);
  public
    unName: AnsiString;
    unFullName: AnsiString;
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
    unFileDate: Integer;
    constructor Create(const aUnitName: String;const aUnitLocation: String = ''; aExcluded: boolean = False);
    destructor Destroy; override;
    procedure Parse(aProject: TProject; const aExclUnits, aSearchPath,aDefaultDir, aConditionals: string;
      const aRescan, aParseAsm: boolean);
    procedure CheckInstrumentedProcs;
    function LocateUnit(unitName: string): TUnit;
    function LocateProc(procName: string): TProc;
    procedure Instrument(aProject: TProject; aIDT: TIDTable;aKeepDate, aBackupFile: boolean);
    procedure ConstructNames(idt: TIDTable);
    function AnyInstrumented: boolean;
    function AnyChange: boolean;
  end;

  TProcSetThreadName = class
  const
  public
    tpstnPos: Cardinal;
    tpstnWithSelf: string;
  end;

  TProcSetThreadNameList = class(TRootNode<TProcSetThreadName>)
    constructor Create; reintroduce;
    procedure AddPosition(const aPos: Cardinal; const aSelfBuffer: string);
  end;

  TProc = class
    prName: AnsiString;
    prHeaderLineNum: Integer;
    prStartOffset: Integer;
    prStartLineNum: Integer;
    prEndOffset: Integer;
    prEndLineNum: Integer;
    prInstrumented: boolean;
    prInitial: boolean;
    prCmtEnterBegin: Integer;
    prCmtEnterEnd: Integer;
    prCmtExitBegin: Integer;
    prCmtExitEnd: Integer;
    prPureAsm: boolean;
    unSetThreadNames: TProcSetThreadNameList;
    constructor Create(procName: string; offset: Integer = 0;
      lineNum: Integer = 0; headerLineNum: Integer = 0);
    destructor Destroy; override;
  end;

  TAPI = class
    apiCommands: string;
    apiBeginOffs: Integer;
    apiEndOffs: Integer;
    apiExitBegin: Integer;
    apiExitEnd: Integer;
    apiMeta: boolean;
    constructor Create(apiCmd: string; apiBegin, apiEnd, apiExStart,apiExEnd: Integer; apiIsMetaComment: boolean);
  end;

  TUnitList = class(TRootNode<TUnit>)
    constructor Create; reintroduce;
    procedure Add(anUnit: TUnit);
  end;

  TGlbUnitList = class(TRootNode<TUnit>)
  public
    constructor Create(); reintroduce;
    function Locate(unitName: string): TUnit;
    function LocateCreate(unitName, unitLocation: string;excluded: boolean): TUnit;
  end;

  TProcList = class(TRootNode<TProc>)
    constructor Create; reintroduce;
    procedure Add(var procName: string; pureAsm: boolean;offset, lineNum, headerLineNum: Integer);
    procedure AddEnd(procName: string; offset, lineNum: Integer);
    procedure AddInstrumented(procName: string;cmtEnterBegin, cmtEnterEnd, cmtExitBegin, cmtExitEnd: Integer);
  end;

  TAPIList = class(TRootNode<TAPI>)
    constructor Create; reintroduce;
    procedure AddMeta(apiCmd: string; apiBegin, apiEnd: Integer);
    procedure AddExpanded(apiEnterBegin, apiEnterEnd, apiExitBegin,apiExitEnd: Integer);
  end;

  TProject = class
  private
    prName: string;
    prUnit: TUnit;
    prUnits: TGlbUnitList;
    prConditStart: string;
    prConditStartUses: string;
    prConditStartAPI: string;
    prConditEnd: string;
    prConditEndUses: string;
    prConditEndAPI: string;
    prAppendUses: string;
    prCreateUses: string;
    prProfileEnterProc: string;
    prProfileExitProc: string;
    prProfileEnterAsm: string;
    prProfileExitAsm: string;
    prProfileAPI: string;
    prAPIIntro: string;
    prNameThreadForDebugging: string;
    prGpprofDot: string;
    procedure PrepareComments(const aCommentType: TCommentType);
  public
    constructor Create(projName: string);
    destructor Destroy; override;
    procedure Parse(aExclUnits: String;const aSearchPath, aConditionals: String; aNotify: TNotifyProc;
      aCommentType: TCommentType; aParseAsm: boolean;const anErrorList : TStrings);
    procedure Rescan(aExclUnits: String;const aSearchPath, aConditionals: string; aNotify: TNotifyProc;
      aCommentType: TCommentType; aIgnoreFileDate: boolean; aParseAsm: boolean);
    property Name: string read prName;
    procedure GetUnitList(var aSL: TStringList;const aProjectDirOnly, aGetInstrumented: boolean);
    procedure GetProcList(unitName: string; s: TStringList;getInstrumented: boolean);
    function GetUnitPath(unitName: string): string;
    procedure InstrumentAll(Instrument, projectDirOnly: boolean);
    procedure InstrumentUnit(unitName: string; Instrument: boolean);
    procedure InstrumentProc(unitName, procName: string; Instrument: boolean);
    procedure InstrumentTUnit(anUnit: TUnit; Instrument: boolean);
    function AllInstrumented(projectDirOnly: boolean): boolean;
    function NoneInstrumented(projectDirOnly: boolean): boolean;
    function AnyInstrumented(projectDirOnly: boolean): boolean;
    procedure Instrument(aProjectDirOnly: boolean; aNotify: TNotifyInstProc;
      aCommentType: TCommentType; aKeepDate, aBackupFile: boolean;
      aIncFileName, aConditionals, aSearchPath: string; aParseAsm: boolean);
    function GetFirstLine(unitName, procName: string): Integer;
    function AnyChange(projectDirOnly: boolean): boolean;
    function LocateUnit(const aUnitName: string): TUnit;
  end;

implementation

uses
  Windows,
  IoUtils,
  GpIFF,
{$IFDEF DebugParser}
  uDbg,
  uDbgIntf,
{$ENDIF}
  GpString,
  CastaliaPasLex,
  CastaliaPasLexTypes,
  gppCommon,
  gppCurrentPrefs;

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
  Result := StrIComp(pAnsichar(node1.Data.unName),
    pAnsichar(node2.Data.unName));
end; { CompareUnit }

constructor TUnitList.Create;
begin
  inherited Create(False);
  CompareFunc := @CompareUnit;
end; { TUnitList.Create }

procedure TUnitList.Add(anUnit: TUnit);
begin
  AppendNode(anUnit);
end; { TUnitList.Add }

{ ========================= TGlbUnitList ========================= }

constructor TGlbUnitList.Create();
begin
  inherited Create(true);
  CompareFunc := @CompareUnit;
end; { TGlbUnitList.Create }

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

{ ========================= TProcList ========================= }

procedure DisposeProc(aData: pointer);
begin
  TProc(aData).Free;
end; { DisposeProc }

function CompareProc(node1, node2: INode<TProc>): Integer;
begin
  Result := StrIComp(pAnsichar(node1.Data.prName),
    pAnsichar(node2.Data.prName));
end; { CompareProc }

constructor TProcList.Create;
begin
  inherited Create(true);
  CompareFunc := @CompareProc;
  // DisposeData := @DisposeProc;
end; { TProcList.Create }

procedure TProcList.Add(var procName: string; pureAsm: boolean;
  offset, lineNum, headerLineNum: Integer);
var
  post: Integer;
  overloaded: boolean;
  LSearchEntry: INode<TProc>;
  LFoundEntry: INode<TProc>;

begin
  if Pos('GetThreadPriority', procName) > 0 then
    pureAsm := pureAsm;
  LSearchEntry := TNode<TProc>.Create();
  LSearchEntry.Data := TProc.Create(procName, offset, lineNum, headerLineNum);
  if FindNode(LSearchEntry, LFoundEntry) then
  begin
    LFoundEntry.Data.prName := LFoundEntry.Data.prName + ':1';
    overloaded := true;
    LSearchEntry.Data.prName := procName + ':1';
  end
  else
  begin
    LSearchEntry.Data.prName := procName + ':1';
    overloaded := FindNode(LSearchEntry, LFoundEntry);
    if not overloaded then
      LSearchEntry.Data.prName := procName;
  end;
  if overloaded then
  begin // fixup for overloaded procedures
    post := 1;
    while FindNode(LSearchEntry, LFoundEntry) do
    begin
      Inc(post);
      LSearchEntry.Data.prName := procName + ':' + IntToStr(post);
    end;
    procName := LSearchEntry.Data.prName;
  end;
  with LSearchEntry.Data do
  begin
    prCmtEnterBegin := -1;
    prCmtEnterEnd := -1;
    prCmtExitBegin := -1;
    prCmtExitEnd := -1;
    prPureAsm := pureAsm;
  end;
  AppendNode(LSearchEntry.Data);

end; { TProcList.Add }

procedure TProcList.AddEnd(procName: string; offset, lineNum: Integer);
var
  LFoundEntry, LSearchEntry: INode<TProc>;
begin
  LSearchEntry := TNode<TProc>.Create();
  LSearchEntry.Data := TProc.Create(procName);
  if FindNode(LSearchEntry, LFoundEntry) then
  begin
    with LFoundEntry.Data do
    begin
      prEndOffset := offset;
      prEndLineNum := lineNum;
      prInitial := False;
    end;
  end;
end; { TProcList.AddEnd }

procedure TProcList.AddInstrumented(procName: string;
  cmtEnterBegin, cmtEnterEnd, cmtExitBegin, cmtExitEnd: Integer);
var
  LFoundEntry, LSearchEntry: INode<TProc>;
begin
  LSearchEntry := TNode<TProc>.Create();
  LSearchEntry.Data := TProc.Create(procName);
  if FindNode(LSearchEntry, LFoundEntry) then
  begin
    with LFoundEntry.Data do
    begin
      prCmtEnterBegin := cmtEnterBegin;
      prCmtEnterEnd := cmtEnterEnd;
      prCmtExitBegin := cmtExitBegin;
      prCmtExitEnd := cmtExitEnd;
      prInstrumented := true;
      prInitial := true;
    end;
  end;
end; { TProcList.AddInstrumented }

{ ========================= TProc ========================= }

constructor TProc.Create(procName: string;
  offset, lineNum, headerLineNum: Integer);
begin
  prName := procName;
  prHeaderLineNum := headerLineNum;
  prStartOffset := offset;
  prStartLineNum := lineNum;
  prInstrumented := False;
  unSetThreadNames := TProcSetThreadNameList.Create();
end; { TProc.Create }

destructor TProc.Destroy;
begin
  unSetThreadNames.Free;
end; { TProc.Destroy }

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
  unFileDate := -1;
end; { TUnit.Create }

destructor TUnit.Destroy;
begin
  unUnits.Free;
  unProcs.Free;
  unAPIs.Free;
end; { TUnit.Destroy }

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

procedure TUnit.Parse(aProject: TProject; const aExclUnits, aSearchPath,
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
          (MakeBackslash(ExtractFilePath(aProject.prUnit.unFullName)) +
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
      raise EUnitNotFoundException.Create('Unit not found in search path: '
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
      (not(Result[Length(Result)] in ['a' .. 'z', 'A' .. 'Z', '0' .. '9', '_',
      '+', '-'])) do
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
      begin
        Result := true;
        Exit;
      end;
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
      if not FindOnPath(unFullName, aSearchPath, aDefaultDir, vUnitFullName)
      then
        raise EUnitNotFoundException.Create('Unit not found in search path: ' +
          unFullName);
      unFullName := vUnitFullName;
      Assert(IsAbsolutePath(unFullName));
      unInProjectDir := (self = aProject.prUnit) or
        AnsiSameText(ExtractFilePath(unFullName),
        ExtractFilePath(aProject.prUnit.unFullName));
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
    unFileDate := FileAge(unFullName);
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
                    unUnits.Add(aProject.prUnits.LocateCreate(unName,
                      ExpandLocation(unLocation),
                      (Pos(#13#10 + uun + #13#10, aExclUnits) <> 0) or
                      (uun = ugpprof)));
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
                    unProcs.LastNode.Data.unSetThreadNames.AddPosition(tokenPos,
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
  LCurrentEntry: INode<TProc>;
begin
  unAllInst := true;
  unNoneInst := true;
  with unProcs do
  begin
    LCurrentEntry := FirstNode;
    while assigned(LCurrentEntry) do
    begin
      if not LCurrentEntry.Data.prInstrumented then
        unAllInst := False
      else
        unNoneInst := False;
      LCurrentEntry := LCurrentEntry.NextNode;
    end;
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
  LCurrentEntry: INode<TProc>;
begin
  LCurrentEntry := unProcs.FirstNode;
  while assigned(LCurrentEntry) do
  begin
    if LCurrentEntry.Data.prInstrumented then
      idt.ConstructName(unName, unFullName, LCurrentEntry.Data.prName,
        LCurrentEntry.Data.prHeaderLineNum);
    LCurrentEntry := LCurrentEntry.NextNode;
  end;
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

procedure TUnit.InstrumentUses(const aProject: TProject; const ed: TFileEdit;
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

procedure TUnit.Instrument(aProject: TProject; aIDT: TIDTable;
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
  name: Integer;
  api: TAPI;
  LCurrentApi: INode<TAPI>;
  LCurrentProc: INode<TProc>;
  LCurrentSetTName: INode<TProcSetThreadName>;
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
    LCurrentApi := unAPIs.FirstNode;
    while assigned(LCurrentApi) do
    begin
      api := LCurrentApi.Data;
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
      LCurrentApi := LCurrentApi.NextNode;
    end;

    LCurrentProc := unProcs.FirstNode;
    while assigned(LCurrentProc) do
    begin
      pr := LCurrentProc.Data;
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
          LCurrentSetTName := pr.unSetThreadNames.FirstNode;
          while assigned(LCurrentSetTName) do
          begin
            LPosition := LCurrentSetTName.Data.tpstnPos -
              Length(aProject.prGpprofDot);
            if LCurrentSetTName.Data.tpstnWithSelf <> '' then
              LPosition := LPosition - 1; // remove } as well
            ed.Remove(LPosition, LCurrentSetTName.Data.tpstnPos - 1);
            if LCurrentSetTName.Data.tpstnWithSelf <> '' then
            begin
              LPosition := LPosition - 2 -
                Length(LCurrentSetTName.Data.tpstnWithSelf);
              ed.Remove(LPosition, LPosition);
            end;

            LCurrentSetTName := LCurrentSetTName.NextNode;
          end;
        end;
      end
      else
      begin
        name := aIDT.ConstructName(unName, unFullName, pr.prName,
          pr.prHeaderLineNum);

        if haveInst then
          ed.Remove(pr.prCmtEnterBegin, pr.prCmtEnterEnd +
            Length(aProject.prConditEnd) - 1);

        if pr.prPureAsm then
          ed.Insert(pr.prStartOffset + Length('asm'),
            Format(aProject.prProfileEnterAsm, [name]))
        else
          ed.Insert(pr.prStartOffset + Length('begin'),
            Format(aProject.prProfileEnterProc, [name]));

        if haveInst then
        begin
          LCurrentSetTName := pr.unSetThreadNames.FirstNode;
          while assigned(LCurrentSetTName) do
          begin
            LPosition := LCurrentSetTName.Data.tpstnPos -
              Length(aProject.prGpprofDot);
            ed.Remove(LPosition, LCurrentSetTName.Data.tpstnPos - 1);
            LCurrentSetTName := LCurrentSetTName.NextNode;
          end;
        end;
        // add gpprof in from of NameThreadForDebugging interceptor
        LCurrentSetTName := pr.unSetThreadNames.FirstNode;
        while assigned(LCurrentSetTName) do
        begin
          LPosition := LCurrentSetTName.Data.tpstnPos;
          if LCurrentSetTName.Data.tpstnWithSelf <> '' then
          begin
            ed.Insert(LPosition - Length('self') - 1, '{');
            ed.Insert(LPosition, '}' + aProject.prGpprofDot);
          end
          else
            ed.Insert(LPosition, aProject.prGpprofDot);
          LCurrentSetTName := LCurrentSetTName.NextNode;
        end;

        if haveInst then
          ed.Remove(pr.prCmtExitBegin, pr.prCmtExitEnd +
            Length(aProject.prConditEnd) - 1);

        if pr.prPureAsm then
          ed.Insert(pr.prEndOffset, Format(aProject.prProfileExitAsm, [name]))
        else
          ed.Insert(pr.prEndOffset, Format(aProject.prProfileExitProc, [name]));
      end;
      LCurrentProc := LCurrentProc.NextNode;
    end;

    ed.Execute(aKeepDate);
  finally
    ed.Free;
  end;
end; { TUnit.Instrument }

function TUnit.AnyInstrumented: boolean;
var
  LCurrentProc: INode<TProc>;
begin
  Result := False;
  with unProcs do
  begin
    LCurrentProc := FirstNode;
    while assigned(LCurrentProc) do
    begin
      if LCurrentProc.Data.prInstrumented then
      begin
        Result := true;
        Exit;
      end;
      LCurrentProc := LCurrentProc.NextNode;
    end; // while
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
  LCurrentProc: INode<TProc>;
begin
  Result := False;
  with unProcs do
  begin
    LCurrentProc := FirstNode;
    while assigned(LCurrentProc) do
    begin
      pr := LCurrentProc.Data;
      if pr.prInstrumented <> pr.prInitial then
      begin
        Result := true;
        Exit;
      end;
      LCurrentProc := LCurrentProc.NextNode;
    end; // while
  end; // with
end; { TUnit.AnyChange }

{ ========================= TProject ========================= }

constructor TProject.Create(projName: string);
begin
  prUnits := TGlbUnitList.Create();
  prName := projName;
  prUnit := nil;
end; { TProject.Create }

destructor TProject.Destroy;
begin
  prUnits.Free;
end; { TProject.Destroy }

procedure TProject.Parse(aExclUnits: String;
  const aSearchPath, aConditionals: string; aNotify: TNotifyProc;
  aCommentType: TCommentType; aParseAsm: boolean; const anErrorList : TStrings);

  procedure DoNotify(const aUnitName: string);
  begin
    if assigned(aNotify) then
    begin
      if GetCurrentThreadId() = MainThreadID then
        aNotify(aUnitName)
      else
      begin
        TThread.Queue(nil,
          procedure
          begin
            aNotify(aUnitName)
          end);
      end;
    end;
  end;


var
  un: TUnit;
  u1: TUnit;
  LNode: INode<TUnit>;
  vOldCurDir: string;
begin
  PrepareComments(aCommentType);
  if Last(aExclUnits, 2) <> #13#10 then
    aExclUnits := aExclUnits + #13#10;
  if First(aExclUnits, 2) <> #13#10 then
    aExclUnits := #13#10 + aExclUnits;
  prUnits.ClearNodes;
  prUnit := prUnits.LocateCreate(prName, '', False);
  prUnit.unInProjectDir := true;

  vOldCurDir := GetCurrentDir;
  if not SetCurrentDir(ExtractFilePath(prUnit.unFullName)) then
    Assert(False);
  try
    un := prUnit;
    repeat
      DoNotify(un.unName);
      try
        un.Parse(self, aExclUnits, aSearchPath, ExtractFilePath(prName),
          aConditionals, False, aParseAsm);
      except
        on E: Exception do
          anErrorList.Add(E.Message);
      end;
      LNode := prUnits.FirstNode;
      un := nil;
      while assigned(LNode) do
      begin
        u1 := LNode.Data;
        if not(u1.unParsed or u1.unExcluded) then
        begin
          un := u1;
          Break;
        end;
        LNode := LNode.NextNode;
      end;
    until (un = nil);
  finally
    SetCurrentDir(vOldCurDir);
  end;
end; { TProject.Parse }

procedure TProject.GetUnitList(var aSL: TStringList;
  const aProjectDirOnly, aGetInstrumented: boolean);
var
  un: TUnit;
  LNode: INode<TUnit>;
  s: String;
begin
  aSL.Clear;
  with prUnits do
  begin
    LNode := FirstNode;
    while assigned(LNode) do
    begin
      un := LNode.Data;
      if (not un.unExcluded) and (un.unProcs.Count > 0) and
        ((not aProjectDirOnly) or un.unInProjectDir) then
      begin
        s := un.unName;

        if aGetInstrumented then
          // Add 2 char flags to indicate, whether unit is fully instrumented or nothing is instrumented
          s := s + IntToStr(Ord(un.unAllInst)) + IntToStr(Ord(un.unNoneInst));

        aSL.Add(s);
      end;
      LNode := LNode.NextNode;
    end;
  end;
end; { TProject.GetUnitList }

procedure TProject.GetProcList(unitName: string; s: TStringList;
  getInstrumented: boolean);
var
  un: TUnit;
  pr: TProc;
  LCurrentProc: INode<TProc>;
begin
  s.Clear;
  un := prUnits.Locate(unitName);
  if un <> nil then
  begin
    with un.unProcs do
    begin
      LCurrentProc := FirstNode;
      while assigned(LCurrentProc) do
      begin
        pr := LCurrentProc.Data;
        if getInstrumented then
          s.Add(pr.prName + IntToStr(Ord(pr.prInstrumented)))
        else
          s.Add(pr.prName);
        LCurrentProc := LCurrentProc.NextNode;
      end;
    end;
  end;
end; { TProject.GetProcList }

procedure TProject.InstrumentTUnit(anUnit: TUnit; Instrument: boolean);
var
  LCurrentProc: INode<TProc>;
begin
  anUnit.unAllInst := Instrument;
  anUnit.unNoneInst := not Instrument;
  with anUnit.unProcs do
  begin
    LCurrentProc := FirstNode;
    while assigned(LCurrentProc) do
    begin
      LCurrentProc.Data.prInstrumented := Instrument;
      LCurrentProc := LCurrentProc.NextNode;
    end;
  end;
end; { TProject.InstrumentTUnit }

procedure TProject.InstrumentAll(Instrument, projectDirOnly: boolean);
var
  un: TUnit;
  LNode: INode<TUnit>;
begin
  with prUnits do
  begin
    LNode := FirstNode;
    while assigned(LNode) do
    begin
      un := LNode.Data;
      if (not un.unExcluded) and (un.unProcs.Count > 0) then
        if (not projectDirOnly) or un.unInProjectDir then
          InstrumentTUnit(un, Instrument);
      LNode := LNode.NextNode;
    end;
  end;
end; { TProject.InstrumentAll }

procedure TProject.InstrumentUnit(unitName: string; Instrument: boolean);
var
  un: TUnit;
begin
  un := prUnits.Locate(unitName);
  if un <> nil then
    InstrumentTUnit(un, Instrument);
end; { TProject.InstrumentUnit }

procedure TProject.InstrumentProc(unitName, procName: string;
  Instrument: boolean);
var
  un: TUnit;
  pr: TProc;
begin
  un := prUnits.Locate(unitName);
  if un = nil then
    raise Exception.Create('Trying to instrument unexistent unit!')
  else
  begin
    pr := un.LocateProc(procName);
    if pr = nil then
      raise Exception.Create('Trying to instrument unexistend procedure!')
    else
    begin
      pr.prInstrumented := Instrument;
      un.CheckInstrumentedProcs;
    end;
  end;
end; { TProject.InstrumentProc }

function TProject.AllInstrumented(projectDirOnly: boolean): boolean;
var
  un: TUnit;
  LNode: INode<TUnit>;
begin
  Result := False;
  with prUnits do
  begin
    LNode := FirstNode;
    while assigned(LNode) do
    begin
      un := LNode.Data;
      if (not un.unExcluded) and (un.unProcs.Count > 0) and
        (un.unInProjectDir or (not projectDirOnly)) then
        if not un.unAllInst then
          Exit;
      LNode := LNode.NextNode;;
    end;
  end;
  Result := true;
end; { TProject.AllInstrumented }

procedure TProject.Instrument(aProjectDirOnly: boolean;
  aNotify: TNotifyInstProc; aCommentType: TCommentType;
  aKeepDate, aBackupFile: boolean; aIncFileName, aConditionals,
  aSearchPath: string; aParseAsm: boolean);

  procedure DoNotify(const aFullname, aUnitName: string; const aParse : Boolean);
  begin
    if assigned(aNotify) then
    begin
      if GetCurrentThreadId() = MainThreadID then
        aNotify(aFullname,aUnitName,aParse)
      else
      begin
        TThread.Queue(nil,
          procedure
          begin
            aNotify(aFullname,aUnitName,aParse)
          end);
      end;
    end;
  end;

var
  vOldCurDir: string;
  un: TUnit;
  idt: TIDTable;
  Rescan: TList;
  i: Integer;
  unAny: boolean;
  anyInst: boolean;
  LNode: INode<TUnit>;
begin
  PrepareComments(aCommentType);
  Rescan := TList.Create;
  try
    idt := TIDTable.Create;
    try
      vOldCurDir := GetCurrentDir;
      if not SetCurrentDir(ExtractFileDir(prUnit.unFullName)) then
        Assert(False);
      try
        with prUnits do
        begin
          anyInst := False;
          LNode := FirstNode;
          while assigned(LNode) do
          begin
            un := LNode.Data;
            if (not un.unExcluded) and (un.unProcs.Count > 0) then
            begin
              DoNotify(un.unFullName, un.unName, False);

              unAny := un.AnyInstrumented;
              if unAny then
                anyInst := true;

              if un.AnyChange or unAny then
              begin
                un.Instrument(self, idt, aKeepDate, aBackupFile);
                Rescan.Add(un);
              end
              else
                un.ConstructNames(idt);
            end;
            LNode := LNode.NextNode;
          end;
        end;
        if not ForceDirectories(ExtractFileDir(aIncFileName)) then
          raise Exception.Create('Could not create output folder ' +
            ExtractFileDir(aIncFileName) + ': ' +
            SysErrorMessage(GetLastError));
        idt.Dump(aIncFileName);
      finally
        SetCurrentDir(vOldCurDir);
      end;
    finally
      idt.Free;
    end;
    if not anyInst then
    begin
      System.SysUtils.DeleteFile(aIncFileName);
      System.SysUtils.DeleteFile(ChangeFileExt(aIncFileName, '.gpd'));
    end;
    for i := 0 to Rescan.Count - 1 do
    begin
      DoNotify(TUnit(Rescan[i]).unFullName, TUnit(Rescan[i]).unName, true);
      TUnit(Rescan[i]).Parse(self, '', aSearchPath, ExtractFilePath(prName),
        aConditionals, true, aParseAsm);
    end;
  finally
    Rescan.Free;
  end;
end; { TProject.Instrument }

function TProject.NoneInstrumented(projectDirOnly: boolean): boolean;
var
  un: TUnit;
  LNode: INode<TUnit>;
begin
  Result := False;
  with prUnits do
  begin
    LNode := FirstNode;
    while assigned(LNode) do
    begin
      un := LNode.Data;
      if (not un.unExcluded) and (un.unProcs.Count > 0) and
        (un.unInProjectDir or (not projectDirOnly)) then
        if not un.unNoneInst then
          Exit;
      LNode := LNode.NextNode;
    end;
  end;
  Result := true;
end; { TProject.NoneInstrumented }

function TProject.GetUnitPath(unitName: string): string;
var
  un: TUnit;
begin
  un := prUnits.Locate(unitName);
  if un = nil then
    raise Exception.Create('Trying to get name of unexistent unit!')
  else
    Result := un.unFullName;
end; { TProject.GetUnitPath }

procedure TProject.PrepareComments(const aCommentType: TCommentType);
begin
  case aCommentType of
    Ct_Arrow:
      begin
        prConditStart := '{>>GpProfile}';
        prConditStartUses := '{>>GpProfile U}';
        prConditStartAPI := '{>>GpProfile API}';
        prConditEnd := '{GpProfile>>}';
        prConditEndUses := '{GpProfile U>>}';
        prConditEndAPI := '{GpProfile API>>}';
      end;
    Ct_IfDef:
      begin
        prConditStart := '{$IFDEF GpProfile}';
        prConditStartUses := '{$IFDEF GpProfile U}';
        prConditStartAPI := '{$IFDEF GpProfile API}';
        prConditEnd := '{$ENDIF GpProfile}';
        prConditEndUses := '{$ENDIF GpProfile U}';
        prConditEndAPI := '{$ENDIF GpProfile API}';
      end;
  end;
  prAppendUses := prConditStartUses + ' ' + cProfUnitName + ', ' +
    prConditEndUses;
  prCreateUses := prConditStartUses + ' uses ' + cProfUnitName + '; ' +
    prConditEndUses;
  prProfileEnterProc := prConditStart + ' ' + 'ProfilerEnterProc(%d); try ' +
    prConditEnd;
  prProfileExitProc := prConditStart + ' finally ProfilerExitProc(%d); end; ' +
    prConditEnd;
  prProfileEnterAsm := prConditStart +
    ' pushad; mov eax, %d; call ProfilerEnterProc; popad ' + prConditEnd;
  prProfileExitAsm := prConditStart +
    ' push eax; mov eax, %d; call ProfilerExitProc; pop eax ' + prConditEnd;
  prProfileAPI := prConditStartAPI + '%s' + prConditEndAPI;
  prAPIIntro := 'GPP:';
  prNameThreadForDebugging := 'namethreadfordebugging';
  prGpprofDot := 'gpprof.';
end; { TProject.PrepareComments }

function TProject.GetFirstLine(unitName, procName: string): Integer;
var
  un: TUnit;
  pr: TProc;
begin
  un := prUnits.Locate(unitName);
  if un = nil then
    Result := -1
  else
  begin
    pr := un.LocateProc(procName);
    if pr = nil then
      Result := -1
    else
      Result := pr.prHeaderLineNum;
  end;
end; { TProject.GetFirstLine }

function TProject.AnyInstrumented(projectDirOnly: boolean): boolean;
var
  un: TUnit;
  LNode: INode<TUnit>;
begin
  Result := true;
  with prUnits do
  begin
    LNode := FirstNode;
    while assigned(LNode) do
    begin
      un := LNode.Data;
      if (not un.unExcluded) and (un.unProcs.Count > 0) and
        (un.unInProjectDir or (not projectDirOnly)) then
        if un.AnyInstrumented then
          Exit;
      LNode := LNode.NextNode;
    end;
  end;
  Result := False;
end; { TProject.AnyInstrumented }

procedure TProject.Rescan(aExclUnits: String;
  const aSearchPath, aConditionals: string; aNotify: TNotifyProc;
  aCommentType: TCommentType; aIgnoreFileDate: boolean; aParseAsm: boolean);
var
  un: TUnit;
  LNode: INode<TUnit>;
  vOldCurDir: string;
begin
  PrepareComments(aCommentType);
  vOldCurDir := GetCurrentDir;
  if not SetCurrentDir(ExtractFilePath(prUnit.unFullName)) then
    Assert(False);
  try
    if Last(aExclUnits, 2) <> #13#10 then
      aExclUnits := aExclUnits + #13#10;
    with prUnits do
    begin
      LNode := FirstNode;
      while assigned(LNode) do
      begin
        un := LNode.Data;
        if (not un.unExcluded) and (un.unProcs.Count > 0) and
          (aIgnoreFileDate or (un.unFileDate <> FileAge(un.unFullName))) then
          un.Parse(self, aExclUnits, aSearchPath, ExtractFilePath(prName),
            aConditionals, true, aParseAsm);
        LNode := LNode.NextNode;
      end;
    end;
  finally
    SetCurrentDir(vOldCurDir);
  end;
end; { TProject.Rescan }

function TProject.AnyChange(projectDirOnly: boolean): boolean;
var
  un: TUnit;
  LNode: INode<TUnit>;
begin
  Result := true;
  with prUnits do
  begin
    LNode := FirstNode;
    while assigned(LNode) do
    begin
      un := LNode.Data;
      if (not un.unExcluded) and (un.unProcs.Count > 0) and
        (un.unInProjectDir or (not projectDirOnly)) then
        if un.unFileDate <> FileAge(un.unFullName) then
          Exit;
      LNode := LNode.NextNode;
    end;
  end;
  Result := False;
end;

function TProject.LocateUnit(const aUnitName: string): TUnit;
begin
  Result := prUnits.Locate(aUnitName)
end;

{ TAPI }

constructor TAPI.Create(apiCmd: string; apiBegin, apiEnd, apiExStart,
  apiExEnd: Integer; apiIsMetaComment: boolean);
begin
  inherited Create;
  apiCommands := apiCmd;
  apiBeginOffs := apiBegin;
  apiEndOffs := apiEnd;
  apiExitBegin := apiExStart;
  apiExitEnd := apiExEnd;
  apiMeta := apiIsMetaComment;
end;

{ TAPIList }

procedure TAPIList.AddExpanded(apiEnterBegin, apiEnterEnd, apiExitBegin,
  apiExitEnd: Integer);
var
  api: TAPI;
begin
  api := TAPI.Create('', apiEnterBegin, apiEnterEnd, apiExitBegin,
    apiExitEnd, False);
  AppendNode(api);
end; { TAPIList.AddExpanded }

procedure TAPIList.AddMeta(apiCmd: string; apiBegin, apiEnd: Integer);
var
  api: TAPI;
begin
  api := TAPI.Create(apiCmd, apiBegin, apiEnd, -1, -1, true);
  AppendNode(api);
end; { TAPIList.AddMeta }

constructor TAPIList.Create;
begin
  inherited Create(true);
end; { TAPIList.Create }

{ TProcSetThreadNameList }

procedure TProcSetThreadNameList.AddPosition(const aPos: Cardinal;
  const aSelfBuffer: string);
var
  LThreadName: TProcSetThreadName;
begin
  LThreadName := TProcSetThreadName.Create();
  LThreadName.tpstnPos := aPos;
  LThreadName.tpstnWithSelf := aSelfBuffer;
  self.AppendNode(LThreadName);
end;

constructor TProcSetThreadNameList.Create;
begin
  inherited Create(true);
end;

end.
