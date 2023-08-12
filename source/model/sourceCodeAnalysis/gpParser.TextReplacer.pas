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
      fFileEdit.Insert(LPosition - Length(LValue.NameThreadForDebuggingPrefix) - 1, '{');
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
  LProcSetThreadNameEnumor : TProcSetThreadNameListEnumerator;
  LValue : TProcSetThreadName;
begin
  // remove gpprof in from of NameThreadForDebugging interceptor
  LProcSetThreadNameEnumor := aSnippetList.GetEnumerator;
  while LProcSetThreadNameEnumor.MoveNext do
  begin
    LValue := LProcSetThreadNameEnumor.Current.Data;
    LFromPosition := LValue.PositionInSource - Length(DOT_GPPROF);
    if LValue.NameThreadForDebuggingPrefix <> '' then
    begin
      LFromPosition := LValue.PositionInSource - 1;
    end;
    fFileEdit.Remove(LFromPosition, LValue.PositionInSource - 1);
    // remove closing tag
    if LValue.NameThreadForDebuggingPrefix <> '' then
    begin
      LFromPosition := LFromPosition - Length(LValue.NameThreadForDebuggingPrefix);
      fFileEdit.Remove(LFromPosition - Length(LValue.NameThreadForDebuggingPrefix), LFromPosition);
    end;

  end;
  LProcSetThreadNameEnumor.Free;
end;


end.
