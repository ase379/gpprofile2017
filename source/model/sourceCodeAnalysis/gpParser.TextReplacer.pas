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
    if LValue.NameThreadForDebuggingSourceString <> '' then
    begin
      fFileEdit.Insert(LPosition - Length('self') - 1, '{');
      fFileEdit.Insert(LPosition, '}' + DOT_GPPROF);
    end
    else
      fFileEdit.Insert(LPosition, DOT_GPPROF);
  end;
  LProcSetThreadNameEnumor.Free;
end;

procedure TGpParserTextReplacer.Remove_SetNameThreadForDebugging(const aSnippetList : TProcSetThreadNameList);
var
  LPosition : Integer;
  LProcSetThreadNameEnumor : TProcSetThreadNameListEnumerator;
  LValue : TProcSetThreadName;
begin
  // remove gpprof in from of NameThreadForDebugging interceptor
  LProcSetThreadNameEnumor := aSnippetList.GetEnumerator;
  while LProcSetThreadNameEnumor.MoveNext do
  begin
    LValue := LProcSetThreadNameEnumor.Current.Data;
    LPosition := LValue.PositionInSource - Length(DOT_GPPROF);
    if LValue.NameThreadForDebuggingSourceString <> '' then
      LPosition := LPosition - 1; // remove } as well
    fFileEdit.Remove(LPosition, LValue.PositionInSource - 1);
    if LValue.NameThreadForDebuggingSourceString <> '' then
    begin
      LPosition := LPosition - 2 - Length(LValue.NameThreadForDebuggingSourceString);
      fFileEdit.Remove(LPosition, LPosition);
    end;
  end;
  LProcSetThreadNameEnumor.Free;
end;


end.
