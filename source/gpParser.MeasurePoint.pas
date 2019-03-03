unit gpParser.MeasurePoint;

interface

uses gppTree;

const
  ENTER_MP_FUNCTION_NAME = AnsiString('ProfilerEnterMP');
  EXIT_MP_FUNCTION_NAME = AnsiString('ProfilerExitMP');
  MAX_MP_NAME_LEN = 4096;
type
  TMPScanState = (undefined, ScanEnterBegin, ScanEnterEnd, ScanLeaveBegin, ScanLeaveEnd);
  // forward declaration
  TMeasurePoint = class;

  /// <summary>
  /// A tree with measure points.
  /// </summary>
  TMeasurePointList = TRootNode<TMeasurePoint>;

  /// <summary>
  /// A measure point in a proc (defined by the user)
  /// </summary>
  TMeasurePoint = class
  private
    fFileContents : PAnsiChar;
    fEnterPosBegin : Int64;
    fEnterPosEnd : Int64;
    fLeavePosBegin : Int64;
    fLeavePosEnd : Int64;

    fEnterSnippet : AnsiString;
    fLeaveSnippet : AnsiString;
    fMeasurePointName : AnsiString;
    procedure ExtractMpName();
    procedure RaiseError(const aContext: string);
  public
    constructor Create(const aFileBuffer: PAnsiChar);
    /// <summary>
    /// The position where the enter token begins
    /// </summary>
    property EnterPosBegin: Int64 read fEnterPosBegin write fEnterPosBegin;
    /// <summary>
    /// The position where the enter token ends
    /// </summary>
    property EnterPosEnd: Int64 read fEnterPosEnd write fEnterPosEnd;
    /// <summary>
    /// The position where the leave token begins
    /// </summary>
    property LeavePosBegin: Int64 read fLeavePosBegin write fLeavePosBegin;
    /// <summary>
    /// The position where the leave token ends
    /// </summary>
    property LeavePosEnd: Int64 read fLeavePosEnd write fLeavePosEnd;

    /// <summary>
    /// Extracts the buffer information from the given external buffer.
    /// </summary>
    procedure ExtractSnippets();
  end;

implementation

uses
  System.Classes,System.SysUtils, System.Ansistrings;


{ TMeasurePoint }

constructor TMeasurePoint.Create(const aFileBuffer: PAnsiChar);
begin
  inherited Create();
  fFileContents := aFileBuffer;
end;

procedure TMeasurePoint.ExtractMpName();
var
  LTempBuffer : ansistring;
  LFuncNamePos : integer;
begin
  if Length(fMeasurePointName) = 0 then
  begin
    LFuncNamePos := System.AnsiStrings.PosEx(ENTER_MP_FUNCTION_NAME, fEnterSnippet);
    LTempBuffer := Copy(fEnterSnippet, LFuncNamePos+Length(ENTER_MP_FUNCTION_NAME),MAX_MP_NAME_LEN);
    LTempBuffer := Trim(LTempBuffer);
    if not StartsStr('(', LTempBuffer) then
      RaiseError('"(" not found after "'+ENTER_MP_FUNCTION_NAME+'".');
    Delete(LTempBuffer,1,1); // eat "("
    if not StartsStr('''', LTempBuffer) then
      RaiseError('Beginning "''" not found in "'+ENTER_MP_FUNCTION_NAME+'" call.');
    Delete(LTempBuffer,1,1); // eat "'"
    LFuncNamePos := System.AnsiStrings.PosEx('''', LTempBuffer);
    if LFuncNamePos = -1 then
      RaiseError('Ending "''" not found in "'+ENTER_MP_FUNCTION_NAME+'" call.');
    fMeasurePointName := Copy(LTempBuffer, 1,LFuncNamePos-1)
  end;

end;



procedure TMeasurePoint.ExtractSnippets();
begin
  fEnterSnippet := Copy(fFileContents,EnterPosBegin+1,EnterPosEnd-EnterPosBegin);
  fLeaveSnippet := Copy(fFileContents,LeavePosBegin+1,LeavePosEnd-LeavePosBegin);
  if not ContainsStr(fEnterSnippet, ENTER_MP_FUNCTION_NAME) then
    RaiseError(ENTER_MP_FUNCTION_NAME+ ' not found in Measure Point enter define.');
  ExtractMpName();
end;

procedure TMeasurePoint.RaiseError(const aContext: string);
begin
  raise EParserError.Create(aContext);
end;

end.
