unit gpParser.API;

interface

uses
  gppTree;

type
  TAPI = class
    apiCommands: string;
    apiBeginOffs: Integer;
    apiEndOffs: Integer;
    apiExitBegin: Integer;
    apiExitEnd: Integer;
    apiMeta: boolean;
    constructor Create(apiCmd: string; apiBegin, apiEnd, apiExStart,apiExEnd: Integer; apiIsMetaComment: boolean);
  end;


  TAPIList = class(TRootNode<TAPI>)
  protected
    function GetLookupKey(const aValue : TAPI) : string; override;
  public
    constructor Create; reintroduce;
    procedure AddMeta(apiCmd: string; apiBegin, apiEnd: Integer);
    procedure AddExpanded(apiEnterBegin, apiEnterEnd, apiExitBegin,apiExitEnd: Integer);
  end;


implementation

uses
  System.SysUtils;

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
  inherited Create();
end;

function TAPIList.GetLookupKey(const aValue: TAPI): string;
begin
  result := aValue.apiCommands + aValue.apiBeginOffs.ToString + aValue.apiEndOffs.ToString +
            aValue.apiExitBegin.ToString + aValue.apiExitEnd.ToString + aValue.apiMeta.ToString();
end;

end.
