unit gpParser.Units;

interface

uses
  System.Classes, System.SysUtils, CastaliaPasLexTypes,
  gppTree,gpParser.baseProject,gpParser.Types,gpParser.Procs,gpParser.Defines,gpParser.API,gpParser.Units.ParserStack,
  gppIDT, gpFileEdit;

type
  TUnit = class;

  TUnitList = class(TRootNode<TUnit>)
  protected
    function GetLookupKey(const aValue : TUnit) : string; override;
    function AdjustKey(const aKey : string) : string;
  private
    constructor Create();
    procedure Add(anUnit: TUnit);
    function FindNode(const aLookupKey: string; out aResultNode: INode<TUnit>): boolean; overload;
  end;

  TGlbUnitList = class(TUnitList)
  strict private
    fProject : TBaseProject;
  public
    constructor Create(const aProject : TBaseProject);
    function Locate(unitName: string): TUnit;
    function LocateCreate(unitName, unitLocation: string;excluded: boolean): TUnit;
    function AreAllUnitsInstrumented(const aCheckProjectDirOnly: Boolean): Boolean;
    function IsNoUnitInstrumented(const aCheckProjectDirOnly : Boolean) : Boolean;
    function IsAnyUnitInstrumented(const aCheckProjectDirOnly: boolean): boolean;
    function DidAnyTimestampChange(const aCheckProjectDirOnly: boolean): boolean;
  end;

  TUnit = class(TBaseUnit)
  private
    fProject : TBaseProject;
    fDefines: TDefineList;
    fSkippedList : TSkippedCodeRecList;
    fUnitParserStack : TUnitParserStack;
    fCurrentUnitParserStackEntry : TUnitParserStackEntry;
    fName: TFilename;
    fFullName: TFileName;


    procedure AddToIntArray(var anArray: TArray<Integer>;const aValue: Integer);
    procedure InstrumentUses(const ed: TFileEdit;const anIndex: Integer);
    procedure BackupInstrumentedFile(const aSrc: string);
    /// <summary>
    /// Processes the given data and return the directive string, e.g. "IFDEF" or "INCLUDE"
    /// </summary>
    function ProcessDirectives(const aProject: TBaseProject; const tokenID: TptTokenKind; const tokenData : string): string;

    /// <summary>
    /// Creates the parser for a uses or an include and stacks it away.
    /// </summary>
    function CreateNewParser(const aUnitFN, aDefaultDir: string): boolean;

    function ResolveFullyQualifiedUnitPath(const aUnitName: String; const aDefDir: string;
      out aUnitFullName: TFileName): boolean;

    /// <summary>
    /// Kills the current parser for a uses or an include and unstack the next one.
    /// </summary>
    function RemoveLastParser(): boolean;


    class function ExtractCommentBody(const comment: string): string; static;
    class function ExtractParameter(const comment: string; const parameter: Integer): string; static;
    class function ExtractNumElements(const comment: string): integer;
    class function IsOneOf(const key: string; const compareWith: array of string): boolean; static;
    class function ExtractDirective(const comment: string): string; static;
    function GoBackToStartOfTerm(const aLexerPos : integer; const aTerm : String; out aNewPosition: integer): boolean;

  public
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
    constructor Create(const aProject: TBaseProject;const aUnitName: String;const aUnitLocation: String = ''; aExcluded: boolean = False);
    destructor Destroy; override;
    procedure Parse(const aDefaultDir, aConditionals: string;
      const aRescan, aParseAsm: boolean);
    procedure CheckInstrumentedProcs;
    function LocateUnit(const unitName: string): TUnit;
    function LocateProc(const aProcName: string): TProc;
    procedure Instrument(aIDT: TIDTable;aBackupFile: boolean);
    /// <summary>
    /// Registers the procs of this unit at the given TIDTable.
    /// </summary>
    procedure RegisterProcs(const idt: TIDTable);
    function AnyInstrumented: boolean;
    function AnyChange: boolean;
    function DidFileTimestampChange(): boolean;
    function NeedsToBeReparsed() : Boolean;
    function IsValidForInstrumentation(): boolean;

    property Name : TFilename read fName;
    property FullName : TFilename read fFullName;
  end;

implementation

uses
  System.IOUtils, Winapi.Windows,
  GpString, gppCommon, gpParser.TextReplacer,
  CastaliaPasLex;


{ ========================= TUnitList ========================= }

function CompareUnit(node1, node2: INode<TUnit>): Integer;
begin
  Result := String.Compare(node1.Data.fName,node2.Data.fName,true);
end; { CompareUnit }

function TUnitList.AdjustKey(const aKey: string): string;
begin
  result := AnsiLowerCase(aKey);
end;

constructor TUnitList.Create();
begin
  inherited Create();
  CompareFunc := @CompareUnit;
end;

function TUnitList.FindNode(const aLookupKey: string; out aResultNode: INode<TUnit>): boolean;
begin
  result := inherited FindNode(AdjustKey(aLookupKey),aResultNode);
end;

function TUnitList.GetLookupKey(const aValue: TUnit): string;
begin
  result := AdjustKey(aValue.fName);
end;

{ TUnitList.Create }

procedure TUnitList.Add(anUnit: TUnit);
begin
  AppendNode(anUnit);
end; { TUnitList.Add }

{ ========================= TGlbUnitList ========================= }

function TGlbUnitList.AreAllUnitsInstrumented(const aCheckProjectDirOnly: Boolean): Boolean;
var
  un: TUnit;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
begin
  Result := true;
  LUnitEnumor := GetEnumerator();
  try
    while LUnitEnumor.MoveNext do
    begin
      un := LUnitEnumor.Current.Data;
      if (un.unInProjectDir or (not aCheckProjectDirOnly)) and un.IsValidForInstrumentation then
        if not un.unAllInst then
          Exit(false);
    end;
  finally
    LUnitEnumor.Free;
  end;
end;

function TGlbUnitList.IsNoUnitInstrumented(const aCheckProjectDirOnly: Boolean): Boolean;
var
  un: TUnit;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
begin
  Result := false;
  LUnitEnumor := GetEnumerator();
  try
    while LUnitEnumor.MoveNext do
    begin
      un := LUnitEnumor.Current.Data;
      if un.IsValidForInstrumentation and
        (un.unInProjectDir or (not aCheckProjectDirOnly)) then
        if not un.unNoneInst then
        begin
          Exit;
        end;
    end;
  finally
    LUnitEnumor.Free;
  end;
  Result := true;
end;


constructor TGlbUnitList.Create(const aProject: TBaseProject);
begin
  inherited Create();
  fProject := aProject;
end;

function TGlbUnitList.DidAnyTimestampChange(const aCheckProjectDirOnly: Boolean): boolean;
var
  un: TUnit;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
begin
  Result := true;
  LUnitEnumor := GetEnumerator();
  try
    while LUnitEnumor.MoveNext do
    begin
      un := LUnitEnumor.Current.Data;
      if un.IsValidForInstrumentation and (un.unInProjectDir or (not aCheckProjectDirOnly)) then
        if un.DidFileTimestampChange() then
          Exit;
    end;
  finally
    LUnitEnumor.Free;
  end;
  Result := False;
end;

function TGlbUnitList.IsAnyUnitInstrumented(const aCheckProjectDirOnly: boolean): boolean;
var
  un: TUnit;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
begin
  Result := true;
  LUnitEnumor := GetEnumerator();
  try
    while LUnitEnumor.MoveNext do
    begin
      un := LUnitEnumor.Current.Data;
      if un.IsValidForInstrumentation and
        (un.unInProjectDir or (not aCheckProjectDirOnly)) then
        if un.AnyInstrumented then
        begin
          Exit;
        end;
    end;
  finally
    LUnitEnumor.Free;
  end;
  Result := False;
end;

function TGlbUnitList.Locate(unitName: string): TUnit;
var
  LFoundEntry: INode<TUnit>;
begin
  if FindNode(unitName, LFoundEntry) then
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
    un := TUnit.Create(fProject, unitName, unitLocation, excluded);
    Result := AppendNode(un).Data;
  end;
end;

{ TGlbUnitList.LocateCreate }


{ ========================= TUnit ========================= }

constructor TUnit.Create(const aProject: TBaseProject;const aUnitName: String;
  const aUnitLocation: String = ''; aExcluded: boolean = False);
begin
  inherited Create();
  fProject := aProject;
  fName := ExtractFileName(aUnitName);
  if aUnitLocation = '' then
    fFullName := aUnitName
  else
    fFullName := aUnitLocation;
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
  inherited;
end;

function TUnit.DidFileTimestampChange: boolean;
var
  LOutDateTime : TDateTime;
begin
  if not FileAge(FullName,LOutDateTime) then
    LOutDateTime := 0.0;
  result := unFileDate <> LOutDateTime;
end;

function TUnit.NeedsToBeReparsed(): Boolean;
begin
  Result := false;
  if IsValidForInstrumentation then
  begin
    result := DidFileTimestampChange()
  end;
end;


{ TUnit.Destroy }

// Get full path to unit having short unit name or relative path
// NB!!! This path can differ from location, which Delphi will use for this unit during compilation!
// (it is just _some_ location from search paths where unit file with the given name is found)
function TUnit.ResolveFullyQualifiedUnitPath(const aUnitName: String; const aDefDir: string;
  out aUnitFullName: TFileName): boolean;
const
  EXT_INCLUDE = '.inc';
  EXT_PAS_SOURCE = '.pas';
  EXT_PAS_PROJECT_SOURCE = '.dpr';
var
  i, k: Integer;
  LDefDir: string;
  LExtension: string;
  LUnitName : TFileName;
  LSearchPath : TFileName;
  LUnitPath : TFileName;
begin
  LUnitName := aUnitName;
  LDefDir := MakeBackslash(aDefDir);

  aUnitFullName := '';
  Result := False;

  LExtension := ExtractFileExt(aUnitName).ToLower;
  if (LExtension <> EXT_PAS_SOURCE) and (LExtension <> EXT_PAS_PROJECT_SOURCE) and (LExtension <> EXT_INCLUDE) then
  begin
    LUnitName := aUnitName + EXT_PAS_SOURCE;
    LExtension := EXT_PAS_SOURCE;
  end;

  Assert(LExtension <> '');

  if FileExists(LUnitName) then
  begin
    aUnitFullName := LowerCase(ExpandUNCFileName(LUnitName));
    Result := true;
    Exit;
  end;


  if FileExists(LDefDir + LUnitName) then
  begin
    aUnitFullName := LowerCase(LDefDir + LUnitName);
    Result := true;
    Exit;
  end;

  for i := Low(fProject.SearchPathes) to High(fProject.SearchPathes) do
  begin
    LSearchPath := fProject.SearchPathes[i];
    Assert(IsAbsolutePath(LSearchPath));
    // Search paths must be converted to absolute before calling ResolveFullyQualifiedUnitPath()
    LUnitPath := MakeSmartBackslash(LSearchPath) + LUnitName;
    if FileExists(LUnitPath) then
    begin
      aUnitFullName := LowerCase(LUnitPath);
      Result := true;
      Exit;
    end;

  end;

  if LExtension <> EXT_INCLUDE then
  begin
    // resolve namespace if not found
    for i := Low(fProject.SearchPathes) to High(fProject.SearchPathes) do
    begin
      LSearchPath := fProject.SearchPathes[i];
      for k := Low(fProject.Namespaces) to High(fProject.Namespaces) do
      begin
        LUnitPath := MakeSmartBackslash(LSearchPath);
        LUnitPath := LUnitPath + fProject.Namespaces[k] + '.' + LUnitName ;
        if FileExists(LUnitPath) then
        begin
          aUnitFullName := LowerCase(LUnitPath);
          Result := true;
          Exit;
        end;
      end;
    end;
  end;
  if (LExtension = EXT_INCLUDE) and fUnitParserStack.HasEntries() then
  begin
    // the include has been used in a unit and referenced from there.
    // assume they are in the same path.
    LUnitPath := ExtractFilePath(fUnitParserStack.GetLastEntry.Filename);
    LUnitPath := TPath.Combine(LUnitPath, aUnitName);
    if FileExists(LUnitPath) then
    begin
      aUnitFullName := LowerCase(LUnitPath);
      Result := true;
      Exit;
    end;
  end;
end;

function TUnit.ProcessDirectives(const aProject: TBaseProject; const tokenID: TptTokenKind; const tokenData : string): string;
var
  LIsInstrumentationFlag: boolean;
  LDirective: string;
  LParameter : string;
  i : Integer;
  LNumElements : Integer;
  LIfExpressionList : TIfExpressionPartList;
  tokenDataLowerCase : string;
begin
  LDirective := '';
  LIsInstrumentationFlag := false;
  case tokenID of
    ptIfDefDirect : LDirective := 'IFDEF';
    ptIfOptDirect : LDirective := 'IFOPT';
    ptIfNDefDirect : LDirective := 'IFNDEF';
    ptIfDirect : LDirective := 'IF';
    ptIfEndDirect : LDirective := 'IFEND';
    ptEndIfDirect : LDirective := 'ENDIF';
    ptElseDirect : LDirective := 'ELSE';
    ptIncludeDirect :
    begin
      LDirective := 'INCLUDE';
      // the lexer recognizes $i+ as $i, ignore it
      tokenDataLowerCase := AnsiLowerCase(tokendata);
      if (tokenDataLowerCase = '{$i-}') or
         (tokenDataLowerCase = '{$i+}') then
         exit('');
    end;
    ptDefineDirect : LDirective := 'DEFINE';
    ptUndefDirect : LDirective := 'UNDEF';
    ptCompDirect :
    begin
      LIsInstrumentationFlag := IsOneOf(tokenData,
        [aProject.prConditStart, aProject.prConditStartUses,
        aProject.prConditStartAPI, aProject.prConditEnd, aProject.prConditEndUses,
        aProject.prConditEndAPI]
      );
      LDirective := ExtractDirective(tokenData);
    end;
    else
      exit('');
  end;

    // Don't process conditional compilation directive if it is
    // actually an instrumentation flag!
  if not LIsInstrumentationFlag then
  begin
    if LDirective = 'IFDEF' then
    begin // process $IFDEF
      fSkippedList.TriggerIfDef(fDefines.IsDefined(ExtractParameter(tokenData, 1)));
    end
    else if LDirective = 'IFOPT' then
    begin // process $IFOPT
      fSkippedList.TriggerIfOpt();
    end
    else if LDirective = 'IFNDEF' then
    begin // process $IFNDEF
      fSkippedList.TriggerIfNDef(fDefines.IsDefined(ExtractParameter(tokenData, 1)));
    end
    else if LDirective = 'IF' then
    begin
      LIfExpressionList := TIfExpressionPartList.Create();
      LNumElements := ExtractNumElements(tokenData);
      for I := 1 to LNumElements do
      begin
        LParameter := ExtractParameter(tokenData, i);
        if Trim(LParameter) = '' then
          Continue;
        if SameText(LParameter, 'AND') then
          LIfExpressionList.Add(if_And)
        else if SameText(LParameter, 'OR') then
          LIfExpressionList.Add(if_OR)
        else
        begin
          if LParameter.StartsWith('DEFINED', True) then
          begin
            // remove ')' at end
            DelLastOccurance(LParameter, ')');
            Delete(LParameter, 1, Length('DEFINED'));
            // remove '(' after DEFINED
            DelFirstOccurance(LParameter, '(');
          end;
          if fDefines.IsDefined(LParameter) then
            LIfExpressionList.Add(if_true)
          else
            LIfExpressionList.Add(if_false);
        end;
      end;
      try
        fSkippedList.TriggerIf(fDefines.IsTrue(LIfExpressionList));
      finally
        LIfExpressionList.Free;
      end;
    end
    else if LDirective = 'IFEND' then
    begin
      fSkippedList.TriggerIfEnd;
    end
    else if LDirective = 'ENDIF' then
    begin // process $ENDIF
      fSkippedList.TriggerEndIf;
    end
    else if LDirective = 'ELSE' then
    begin // process $ELSE
      fSkippedList.TriggerElse;
    end;
  end;
  result := LDirective;

end;

class function TUnit.ExtractCommentBody(const comment: string): string;
  begin
  if comment = '' then
    Result := ''
  else if comment[1] = '{' then
    Result := Copy(comment, 2, Length(comment) - 2)
  else
    Result := Copy(comment, 3, Length(comment) - 4);
end;

class function TUnit.ExtractParameter(const comment: string; const parameter: Integer): string;
begin
  Result := NthEl(ExtractCommentBody(comment), parameter + 1, ' ', -1);
end; { ExtractParameter }


class function TUnit.ExtractNumElements(const comment: string): Integer;
begin
  Result := NumElements(ExtractCommentBody(comment), ' ', -1);
end; { ExtractParameter }

class function TUnit.IsOneOf(const key: string; const compareWith: array of string): boolean;
var
  i: Integer;
begin
  Result := False;
  for i := Low(compareWith) to High(compareWith) do
    if key = compareWith[i] then
      exit(true);
end;

function TUnit.IsValidForInstrumentation: boolean;
begin
  result := (not unExcluded) and (unProcs.Count > 0);
end;

{ IsOneOf }

class function TUnit.ExtractDirective(const comment: string): string;
begin
  Result := ButFirst(UpperCase(FirstEl(ExtractCommentBody(comment),
    ' ', -1)), 1);
  // Fix Delphi stupidity - Delphi parses {$ENDIF.} (where '.' is any
  // non-ident character (alpha, number, underscore)) as {$ENDIF}
  while (Result <> '') and
    (not(CharInSet(Result[Length(Result)],['a'..'z','A'..'Z','0'..'9','_','+', '-']))) do
    Delete(Result, Length(Result), 1);
end; { ExtractDirective }

function TUnit.CreateNewParser(const aUnitFN, aDefaultDir: string): boolean;
var
  LUnitFullName: TFileName;
begin
  result := true;
  if fCurrentUnitParserStackEntry <> nil then
    fUnitParserStack.Add(fCurrentUnitParserStackEntry);

  if not ResolveFullyQualifiedUnitPath(aUnitFN, aDefaultDir, LUnitFullName) then
    Exit(False);

  fCurrentUnitParserStackEntry := TUnitParserStackEntry.Create(LUnitFullName);
end;


function TUnit.RemoveLastParser(): boolean;
begin
  fCurrentUnitParserStackEntry.Free;
  if fUnitParserStack.HasEntries() then
  begin
    fCurrentUnitParserStackEntry := fUnitParserStack.GetLastEntry();
    fUnitParserStack.RemoveLastEntry();
    fCurrentUnitParserStackEntry.Lexer.Next;
    Result := true;
  end
  else
  begin
    fCurrentUnitParserStackEntry := nil;
    Result := False;
  end;
end;

procedure TUnit.Parse(const aDefaultDir, aConditionals: String; const aRescan, aParseAsm: boolean);
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
  fName: string;
  unLocation: string;
  tokenID: TptTokenKind;
  tokenData: string;
  tokenPos: Integer;
  tokenLN: Integer;
  lIsInAsmBlock: TBooleanStack;
  lIsInRecordDef: TBooleanStack;
  prevTokenID: TptTokenKind;
  apiCmd: string;
  apiStart: Integer;
  apiStartEnd: Integer;

  incName: string;

  function IsBlockStartToken(token: TptTokenKind): boolean;
  begin
    if lIsInRecordDef.PeekOrReturnFalseIfEmpy() and (token = ptCase) then
      Result := False
    else
      Result := (token = ptBegin) or (token = ptRepeat) or (token = ptCase) or
        (token = ptTry) or (token = ptAsm) or (token = ptRecord);

    if token = ptAsm then
      lIsInAsmBlock.Push(true);
    if token = ptRecord then
      lIsInRecordDef.Push(true);
  end; { IsBlockStartToken }

  function IsBlockEndToken(const aPreviousToken, aCurrentToken: TptTokenKind): boolean;
  begin
    IsBlockEndToken := (aPreviousToken <> ptPoint) and ((aCurrentToken = ptEnd) or (aCurrentToken = ptUntil));
    if Result then
    begin
      lIsInAsmBlock.PopIfNotEmpty();
      lIsInRecordDef.PopIfNotEmpty();
    end;
  end;

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
          (MakeBackslash(ExtractFilePath(fProject.GetFullUnitName())) +
          vLocation);
    end;
  end; { ExpandLocation }

var
  vUnitFullName: TFileName;
  LSelfBuffer: string;
  LDataLowerCase: string;
  LDirective : string;
  lLexerRunPos : integer;
  lCurrentLexerRunPos : integer;
  lThreadNameTokenPos : integer;
begin
  unParsed := true;
  LSelfBuffer := '';

  if not aRescan then
  begin
    // Anton Alisov: not sure, for what reason ResolveFullyQualifiedUnitPath() is called here with unFullName instead of Name
    if not ResolveFullyQualifiedUnitPath(FullName, aDefaultDir, vUnitFullName) then
    begin
      fProject.prMissingUnitNames.AddOrSetValue(FullName,0);
      raise EUnitInSearchPathNotFoundError.Create('Unit not found in search path: ' + FullName);
    end;
    fFullName := vUnitFullName;
    Assert(IsAbsolutePath(FullName));
    unInProjectDir := (self.FullName = fProject.GetFullUnitName) or
      AnsiSameText(ExtractFilePath(self.FullName),
      ExtractFilePath(fProject.GetFullUnitName));
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

  fUnitParserStack := TUnitParserStack.Create;
  fCurrentUnitParserStackEntry := nil;
  CreateNewParser(FullName, aDefaultDir);
  if not FileAge(FullName,unFileDate) then
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
  fName := '';
  unLocation := '';
  SetLength(unUsesOffset, 0);
  SetLength(unImplementOffset, 0);
  SetLength(unStartUses, 0);
  SetLength(unEndUses, 0);

  prevTokenID := ptNull;
  apiStart := -1;
  apiStartEnd := -1;

  try
    lIsInAsmBlock := TBooleanStack.Create;
    lIsInRecordDef := TBooleanStack.Create;
    fSkippedList := TSkippedCodeRecList.Create();
    fDefines := TDefineList.Create;
    fDefines.Assign(aConditionals);
    try
      repeat
        while fCurrentUnitParserStackEntry.Lexer.tokenID <> ptNull do
        begin
          tokenID := fCurrentUnitParserStackEntry.Lexer.tokenID;
          tokenData := fCurrentUnitParserStackEntry.Lexer.token;
          tokenPos := fCurrentUnitParserStackEntry.Lexer.tokenPos;
          tokenLN := fCurrentUnitParserStackEntry.Lexer.LineNumber;

          LDirective := ProcessDirectives(fProject, tokenID, tokenData);

          if not fSkippedList.SkippingCode then
          begin // we're not in the middle of conditionally removed block
            if (tokenID = ptPoint) and (prevTokenID = ptEnd) then
              Break; // final end.

            if (LDirective = 'INCLUDE') or (LDirective = 'I') then
            begin // process $INCLUDE
              // process {$I *.INC}
              incName := ExtractParameter(tokendata, 1);
              // having double spaces causes problems with ExtractParameter; the result is then empty...
              if incName = '' then
              begin
                incName := tokenData.Replace('  ',' ',[rfReplaceAll]);
                incName := ExtractParameter(incName, 1);
              end;
              if FirstEl(incName, '.', -1) = '*' then
                incName := FirstEl(ExtractFileName(FullName), '.', -1) +
                  '.' + ButFirstEl(incName, '.', -1);
              if incName = '' then
                raise Exception.Create('Include contains empty unit name : "'+ tokenData + '".' );
              if not CreateNewParser(incName, aDefaultDir) then
                raise EUnitInSearchPathNotFoundError.Create('Unit not found in search path: '+ incName);
              continue;
            end
            else if LDirective = 'DEFINE' then // process $DEFINE
              fDefines.Define(ExtractParameter(tokenData, 1))
            else if LDirective = 'UNDEF' then // process $UNDEF
              fDefines.Undefine(ExtractParameter(tokenData, 1));

            if lIsInAsmBlock.PeekOrReturnFalseIfEmpy() and ((prevTokenID = ptAddressOp) or
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
              if tokenData = fProject.prConditStartUses then
                AddToIntArray(unStartUses, tokenPos)
              else if tokenData = fProject.prConditEndUses then
                AddToIntArray(unEndUses, tokenPos)
              else if ((tokenID = ptBorComment) and
                (Copy(tokenData, 1, 1 + Length(fProject.prAPIIntro)) = '{' +
                fProject.prAPIIntro)) or
                ((tokenID = ptAnsiComment) and
                (Copy(tokenData, 1, 2 + Length(fProject.prAPIIntro)) = '(*' +
                fProject.prAPIIntro)) then
              begin
                if tokenID = ptBorComment then
                  apiCmd := TrimL
                    (Trim(ButLast(ButFirst(tokenData,
                    1 + Length(fProject.prAPIIntro)), 1)))
                else
                  apiCmd := TrimL
                    (Trim(ButLast(ButFirst(tokenData,
                    2 + Length(fProject.prAPIIntro)), 2)));

                if not fUnitParserStack.HasEntries then
                  unAPIs.AddMeta(apiCmd, tokenPos,
                    tokenPos + Length(tokenData) - 1);
              end
              else if tokenData = fProject.prConditStartAPI then
              begin
                apiStart := tokenPos;
                apiStartEnd := tokenPos + Length(tokenData) - 1;
              end
              else if tokenData = fProject.prConditEndAPI then
                if not fUnitParserStack.HasEntries then
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
                if fName <> '' then
                begin
                  uun := UpperCase(fName);
                  unUnits.Add(fProject.LocateOrCreateUnit(fName, ExpandLocation(unLocation),
                    (uun = ugpprof) or fProject.IsAnExcludedUnit(uun))as TUnit);
                end;
                fName := '';
                unLocation := '';
              end
              else if tokenID = ptIdentifier then // unit name
                fName := fName + tokenData
              else if tokenID = ptPoint then
                fName := fName + '.'
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
                else if IsBlockEndToken(prevTokenID, tokenID) then
                  Dec(block);

                if block < 0 then
                begin
                  state := stScan;
                  stk := '';
                  lnumstk := '';
                  procName := '';
                  proclnum := -1;
                end
                else if (block > 0) and (not lIsInRecordDef.PeekOrReturnFalseIfEmpy()) then
                begin
                  if stk <> '' then
                    procn := ButFirst(stk, 1) + '/' + procName
                  else
                    procn := procName;

                  if not fUnitParserStack.HasEntries then
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
              else if IsBlockEndToken(prevTokenID, tokenID) then
                Dec(block);

              if (tokenID = ptBorComment) or (tokenID = ptCompDirect) then
              begin
                if tokenData = fProject.prConditStart then
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
                else if tokenData = fProject.prConditEnd then
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
                if LDataLowerCase = fProject.prNameThreadForDebugging then
                begin
                  LSelfBuffer := '';
                  lThreadNameTokenPos := tokenPos;

                  lLexerRunPos := fCurrentUnitParserStackEntry.Lexer.RunPos;
                  try
                    lCurrentLexerRunPos := lLexerRunPos;

                    // subtract the NameThreadForDebugging part
                    dec(lCurrentLexerRunPos, fProject.prNameThreadForDebugging.Length);
                    fCurrentUnitParserStackEntry.Lexer.RunPos := lCurrentLexerRunPos;

                    // if instrumented: gpprof is the last term.. it is removed in the textReplacer.. skip it
                    GoBackToStartOfTerm(lCurrentLexerRunPos, 'gpprof.', lCurrentLexerRunPos);

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, '}', lCurrentLexerRunPos)) then
                      LSelfBuffer := '}'+ lSelfBuffer;

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, fProject.prCurrentThread+'.', lCurrentLexerRunPos)) then
                      LSelfBuffer := fProject.prCurrentThread+'.' + lSelfBuffer;


                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, '}', lCurrentLexerRunPos)) then
                      LSelfBuffer := '}'+ lSelfBuffer;

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, '{', lCurrentLexerRunPos)) then
                      LSelfBuffer := '{'+ lSelfBuffer;


                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, fProject.prtTThread+'.', lCurrentLexerRunPos)) then
                      LSelfBuffer := fProject.prtTThread + '.' + lSelfBuffer;

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, '}', lCurrentLexerRunPos)) then
                      LSelfBuffer := '}'+ lSelfBuffer;

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, '{', lCurrentLexerRunPos)) then
                      LSelfBuffer := '{'+ lSelfBuffer;

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, 'self.', lCurrentLexerRunPos)) then
                      LSelfBuffer := 'self.' + lSelfBuffer;

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, '}', lCurrentLexerRunPos)) then
                      LSelfBuffer := '}'+ lSelfBuffer;

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, '{', lCurrentLexerRunPos)) then
                      LSelfBuffer := '{'+ lSelfBuffer;

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, 'tthread.', lCurrentLexerRunPos)) then
                      LSelfBuffer := 'tthread.' + lSelfBuffer;

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, '}', lCurrentLexerRunPos)) then
                      LSelfBuffer := '}'+ lSelfBuffer;

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, '{', lCurrentLexerRunPos)) then
                      LSelfBuffer := '{'+ lSelfBuffer;

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, 'gpprof.', lCurrentLexerRunPos)) then
                      LSelfBuffer := 'gpprof.' + lSelfBuffer;

                    if (GoBackToStartOfTerm(lCurrentLexerRunPos, '{', lCurrentLexerRunPos)) then
                      LSelfBuffer := '{'+ lSelfBuffer;

                    unProcs.Last.Data.unSetThreadNames.AddPosition(lThreadNameTokenPos, LSelfBuffer);
                  finally
                    fCurrentUnitParserStackEntry.Lexer.RunPos := lLexerRunPos;
                  end
                end
              end;

              if block = 0 then
              begin
                if not fUnitParserStack.HasEntries then
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
          fCurrentUnitParserStackEntry.Lexer.Next;
        end; // while
      until not RemoveLastParser;
    finally
      FreeAndNil(fDefines);
    end;
  finally
    lIsInAsmBlock.Free;
    lIsInRecordDef.Free;
    fUnitParserStack.Free;
    FreeAndNil(fSkippedList);
  end;
end; { TUnit.Parse }


function TUnit.GoBackToStartOfTerm(const aLexerPos : integer; const aTerm : String; out aNewPosition : integer): boolean;
var
  x : integer;
  lCurrentLexerRunPos : integer;
begin
  result := true;
  // go back over the 'CurrentThread.'... and check if we find it for the next replace pos
  lCurrentLexerRunPos := aLexerPos;
  for x := Length(aTerm) downto 1 do
  begin
    dec(lCurrentLexerRunPos);
    fCurrentUnitParserStackEntry.Lexer.RunPos := lCurrentLexerRunPos;
    if not (LowerCase(fCurrentUnitParserStackEntry.Lexer.token[1]) = aTerm[x]) then
    begin
      // return given pos if the term was not found
      aNewPosition := aLexerPos;
      exit(false);
    end;
  end;
  aNewPosition := lCurrentLexerRunPos;
end;


procedure TUnit.CheckInstrumentedProcs;
var
  LEnumor: TRootNode<TProc>.TEnumerator;
begin
  unAllInst := true;
  unNoneInst := true;
  LEnumor := unProcs.GetEnumerator();
  while LEnumor.MoveNext do
  begin
    if not LEnumor.Current.Data.prInstrumented then
      unAllInst := False
    else
      unNoneInst := False;
  end;
  LEnumor.Free;
end; { TUnit.CheckInstrumentedProcs }

function TUnit.LocateUnit(const unitName: string): TUnit;
var
  LSearchEntry: INode<TUnit>;
  LFoundEntry: INode<TUnit>;
begin
  LSearchEntry := TNode<TUnit>.Create();
  LSearchEntry.Data := TUnit.Create(fProject, unitName);
  if unUnits.FindNode(unitName, LFoundEntry) then
    Result := LFoundEntry.Data
  else
    Result := nil;
end; { TUnit.LocateUnit }

function TUnit.LocateProc(const aProcName: string): TProc;
var
  LFoundEntry: INode<TProc>;
begin
  if unProcs.FindNode(aProcName, LFoundEntry) then
    Result := LFoundEntry.Data
  else
    Result := nil;
end; { TUnit.LocateProc }

procedure TUnit.RegisterProcs(const idt: TIDTable);
var
  LEnumor: TRootNode<TProc>.TEnumerator;
begin
  LEnumor := unProcs.GetEnumerator;
  while LEnumor.MoveNext do
  begin
    if LEnumor.Current.Data.prInstrumented then
      idt.RegisterProc(fName, FullName, LEnumor.Current.Data.Name,
        LEnumor.Current.Data.prHeaderLineNum);
  end;
  LEnumor.Free;
end; { TUnit.RegisterProcs }

procedure TUnit.BackupInstrumentedFile(const aSrc: string);
var
  justName: string;
begin
  justName := ButLastEl(aSrc, '.', Ord(-1));
  System.SysUtils.DeleteFile(justName + '.bk2');
  RenameFile(justName + '.bk1', justName + '.bk2');
  TFile.Copy(aSrc, justName + '.bk1', true);
end;

procedure TUnit.InstrumentUses(const ed: TFileEdit; const anIndex: Integer);

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
    ed.Remove(LStartUses, LEndUses + Length(fProject.prConditEndUses) - 1)
  else if (not haveUses) and any then
  begin
    LUnit := LocateUnit(cProfUnitName);
    if (LUnit = nil) then
    begin
      if LUsesOffset > 0 then
        ed.Insert(LUsesOffset + Length('uses'), fProject.prAppendUses)
      else
        ed.Insert(LImplementationOffset + Length('implementation'),
          fProject.prCreateUses);
    end;
  end;
end;

procedure TUnit.Instrument(aIDT: TIDTable; aBackupFile: boolean);

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
  LFileEdit: TFileEdit;
  nameId: Integer;
  api: TAPI;
  LApiEnumor: TRootNode<TAPI>.TEnumerator;
  LProcEnumor: TRootNode<TProc>.TEnumerator;
  i: Integer;
  lGpParserTextReplacer : TGpParserTextReplacer;
begin { TUnit.Instrument }
  if Length(unImplementOffset) = 0 then
    raise Exception.Create('No implementation part defined in unit ' +
      fName + '!');

  if aBackupFile then
    BackupInstrumentedFile(FullName);

  LFileEdit := TFileEdit.Create(FullName);
  lGpParserTextReplacer := TGpParserTextReplacer.Create(LFileEdit);
  try
    // update uses...
    for i := 0 to LAdjustUsesCount - 1 do
      InstrumentUses(LFileEdit, i);

    any := AnyInstrumented;
    LApiEnumor := unAPIs.GetEnumerator();
    while LApiEnumor.MoveNext do
    begin
      api := LApiEnumor.Current.Data;
      if any then
      begin
        if api.apiMeta then
        begin
          LFileEdit.Remove(api.apiBeginOffs, api.apiEndOffs);
          LFileEdit.Insert(api.apiBeginOffs, Format(fProject.prProfileAPI,
            [api.apiCommands]));
        end
      end
      else
      begin
        if not api.apiMeta then
        begin
          LFileEdit.Remove(api.apiBeginOffs, api.apiEndOffs);
          LFileEdit.Insert(api.apiBeginOffs, '{' + fProject.prAPIIntro);
          LFileEdit.Remove(api.apiExitBegin, api.apiExitEnd);
          LFileEdit.Insert(api.apiExitBegin, '}');
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
          LFileEdit.Remove(pr.prCmtEnterBegin, pr.prCmtEnterEnd +
            Length(fProject.prConditEnd) - 1);
          LFileEdit.Remove(pr.prCmtExitBegin, pr.prCmtExitEnd +
            Length(fProject.prConditEnd) - 1);

          lGpParserTextReplacer.Remove_SetNameThreadForDebugging(pr.unSetThreadNames);
        end;
      end
      else
      begin
        nameId := aIDT.RegisterProc(fName, FullName, pr.Name,
          pr.prHeaderLineNum);

        if haveInst then
          LFileEdit.Remove(pr.prCmtEnterBegin, pr.prCmtEnterEnd +
            Length(fProject.prConditEnd) - 1);

        if pr.prPureAsm then
          LFileEdit.Insert(pr.prStartOffset + Length('asm'),
            Format(fProject.prProfileEnterAsm, [nameId]))
        else
          LFileEdit.Insert(pr.prStartOffset + Length('begin'),
            Format(fProject.prProfileEnterProc, [nameId]));

        if haveInst then
          lGpParserTextReplacer.Remove_SetNameThreadForDebugging(pr.unSetThreadNames);
        // add gpprof in from of NameThreadForDebugging interceptor
        lGpParserTextReplacer.Adjust_SetNameThreadForDebugging(pr.unSetThreadNames);

        if haveInst then
          LFileEdit.Remove(pr.prCmtExitBegin, pr.prCmtExitEnd +
            Length(fProject.prConditEnd) - 1);

        if pr.prPureAsm then
          LFileEdit.Insert(pr.prEndOffset, Format(fProject.prProfileExitAsm, [nameId]))
        else
          LFileEdit.Insert(pr.prEndOffset, Format(fProject.prProfileExitProc, [nameId]));
      end;
    end;
    LProcEnumor.Free;

    LFileEdit.Execute();
  finally
    LFileEdit.Free;
    lGpParserTextReplacer.Free;
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
