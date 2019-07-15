unit gpParser.BaseProject;

interface

uses
  System.Generics.Collections, gpParser.Types;

type
  TBaseProject = class
  protected
    fFullUnitName : string;
  private
    fAPIIntro: string;
    fConditStart: string;
    fConditStartUses: string;
    fConditStartAPI: string;
    fConditEnd: string;
    fConditEndUses: string;
    fConditEndAPI: string;
    fNameThreadForDebugging: string;
    fAppendUses: string;
    fCreateUses: string;
    fProfileEnterProc: string;
    fProfileExitProc: string;
    fProfileEnterAsm: string;
    fProfileExitAsm: string;
    fProfileAPI: string;
    fGpprofDot: string;


    fMissingUnitNames : TDictionary<String, Cardinal>;

  protected
    procedure PrepareComments(const aCommentType: TCommentType);


  public
    constructor Create();
    destructor Destroy; override;
    function GetFullUnitName(): string;
    property prAPIIntro: string read fAPIIntro;
    property prMissingUnitNames : TDictionary<String, Cardinal> read fMissingUnitNames;
    property prConditStart: string read fConditStart;
    property prConditStartUses: string read fConditStartUses;
    property prConditStartAPI: string read fConditStartAPI;
    property prConditEnd: string read fConditEnd;
    property prConditEndUses: string read fConditEndUses;
    property prConditEndAPI: string read fConditEndAPI;
    property prNameThreadForDebugging: string read fNameThreadForDebugging;
    property prAppendUses: string read fAppendUses;
    property prCreateUses: string read fCreateUses;
    property prProfileEnterProc: string read fProfileEnterProc;
    property prProfileExitProc: string read fProfileExitProc;
    property prProfileEnterAsm: string read fProfileEnterAsm;
    property prProfileExitAsm: string read fProfileExitAsm;
    property prProfileAPI: string read fProfileAPI;
    property prGpprofDot: string read fGpprofDot;


    function LocateOrCreateUnit(const unitName, unitLocation: string;const excluded: boolean): TBaseUnit; virtual; abstract;
  end;

implementation

{ TBaseProject }

constructor TBaseProject.Create;
begin
  inherited Create();
  fMissingUnitNames := TDictionary<String, Cardinal>.Create;

end;

destructor TBaseProject.Destroy;
begin
  fMissingUnitNames.free;

  inherited;
end;

function TBaseProject.GetFullUnitName: string;
begin
  result := fFullUnitName;
end;

procedure TBaseProject.PrepareComments(const aCommentType: TCommentType);
begin
  case aCommentType of
    Ct_Arrow:
      begin
        fConditStart := '{>>GpProfile}';
        fConditStartUses := '{>>GpProfile U}';
        fConditStartAPI := '{>>GpProfile API}';
        fConditEnd := '{GpProfile>>}';
        fConditEndUses := '{GpProfile U>>}';
        fConditEndAPI := '{GpProfile API>>}';
      end;
    Ct_IfDef:
      begin
        fConditStart := '{$IFDEF GpProfile}';
        fConditStartUses := '{$IFDEF GpProfile U}';
        fConditStartAPI := '{$IFDEF GpProfile API}';
        fConditEnd := '{$ENDIF GpProfile}';
        fConditEndUses := '{$ENDIF GpProfile U}';
        fConditEndAPI := '{$ENDIF GpProfile API}';
      end;
  end;
  fAppendUses := prConditStartUses + ' ' + cProfUnitName + ', ' +
    prConditEndUses;
  fCreateUses := prConditStartUses + ' uses ' + cProfUnitName + '; ' +
    prConditEndUses;
  fProfileEnterProc := prConditStart + ' ' + 'ProfilerEnterProc(%d); try ' +
    prConditEnd;
  fProfileExitProc := prConditStart + ' finally ProfilerExitProc(%d); end; ' +
    prConditEnd;
  fProfileEnterAsm := prConditStart +
    ' pushad; mov eax, %d; call ProfilerEnterProc; popad ' + prConditEnd;
  fProfileExitAsm := prConditStart +
    ' push eax; mov eax, %d; call ProfilerExitProc; pop eax ' + prConditEnd;
  fProfileAPI := prConditStartAPI + '%s' + prConditEndAPI;
  fAPIIntro := 'GPP:';
  fNameThreadForDebugging := 'namethreadfordebugging';
  fGpprofDot := 'gpprof.';
end; { TProject.PrepareComments }


end.
