unit gpParser.TextReplacer;

interface

uses
  System.Classes,
  gppTree, gpParser.Procs, gpFileEdit;


type
  /// <summary>
  /// Replaces the text when instrumenting or deinstrumenting the source code.
  /// </summary>
  TGpParserTextReplacer = class
  private
    fFileEdit: TFileEdit;
  public
    constructor Create(AFileEdit: TFileEdit);
    procedure Adjust_SetNameThreadForDebugging(const aSnippetList : TProcSetThreadNameList);
    procedure Remove_SetNameThreadForDebugging(const aSnippetList : TProcSetThreadNameList);
  end;

implementation

const
  DOT_GPPROF = 'gpprof.';


constructor TGpParserTextReplacer.Create(AFileEdit: TFileEdit);
begin
  inherited Create();
  fFileEdit := aFileEdit;
end;

procedure TGpParserTextReplacer.Adjust_SetNameThreadForDebugging(const aSnippetList : TProcSetThreadNameList);
var
  LPosition : Integer;
  LProcSetThreadNameEnumor : TProcSetThreadNameListEnumerator;
  LValue : TProcSetThreadName;
begin
  LProcSetThreadNameEnumor := aSnippetList.GetEnumerator;
  while LProcSetThreadNameEnumor.MoveNext do
  begin
    LValue := LProcSetThreadNameEnumor.Current.Data;
    LPosition := LValue.PositionInSource;
    if LValue.NameThreadForDebuggingPrefix <> '' then
    begin
      fFileEdit.Insert(LPosition - Length(LValue.NameThreadForDebuggingPrefix), '{');
      fFileEdit.Insert(LPosition, '}' + DOT_GPPROF);
    end
    else
      fFileEdit.Insert(LPosition, DOT_GPPROF);

  end;
  LProcSetThreadNameEnumor.Free;
end;

procedure TGpParserTextReplacer.Remove_SetNameThreadForDebugging(const aSnippetList : TProcSetThreadNameList);
var
  LFromPosition : Integer;
  LToPosition : integer;
  LProcSetThreadNameEnumor : TProcSetThreadNameListEnumerator;
  LValue : TProcSetThreadName;
begin
  // remove gpprof in from of NameThreadForDebugging interceptor
  LProcSetThreadNameEnumor := aSnippetList.GetEnumerator;
  while LProcSetThreadNameEnumor.MoveNext do
  begin
    LValue := LProcSetThreadNameEnumor.Current.Data;
    // remove Gpprof., as it is at the end
    LFromPosition := LValue.PositionInSource - Length(DOT_GPPROF);
    LToPosition := LValue.PositionInSource;
    fFileEdit.Remove(LFromPosition, LToPosition-1);
    // remove closing tag
    if LValue.NameThreadForDebuggingPrefix <> '' then
    begin
      // the snipped is removed, so the to will be the old from
      fFileEdit.RemoveOneChar(LFromPosition-1);
      LFromPosition := LFromPosition - Length(LValue.NameThreadForDebuggingPrefix);
      fFileEdit.RemoveOneChar(LFromPosition);
    end;

  end;
  LProcSetThreadNameEnumor.Free;
end;


end.
