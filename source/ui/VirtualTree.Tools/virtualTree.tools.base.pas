unit virtualTree.tools.base;

interface

uses
  System.Generics.Collections,
  VirtualTrees;


type
  {$SCOPEDENUMS ON}
  TCheckedState = (unchecked, greyed, checked);
  {$SCOPEDENUMS OFF}
  TVirtualTreeBaseTools = class
  private
  protected
    fTree: TVirtualStringTree;
    fSortcols: array of TColumnIndex;

    /// <summary>
    /// Resorts the headers.
    /// </summary>
    procedure OnHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    /// <summary>
    /// processes the input for fast searching
    /// </summary>
    procedure OnIncrementalSearch(Sender: TBaseVirtualTree; Node: PVirtualNode;const SearchText: string;var Result: Integer);

  public
    constructor Create(const aList: TVirtualStringTree);
    destructor Destroy;override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear;

    function GetSelectedNode(): PVirtualNode;
    function GetSelectedIndex : integer;
    function GetCount: integer;

    function GetNode(const anIndex : Cardinal): PVirtualNode;
    function GetNodeByName(const aName: string): PVirtualNode;
    function GetChildByName(const aParent : PVirtualNode;const aName: string): PVirtualNode;

    function GetName(const anIndex: Cardinal;const column : integer = 0): string; overload;
    function GetName(const aNode : PVirtualNode;const column : integer = 0) : string; overload; virtual;
    procedure setSelectedIndex(const anIndex : cardinal);
    procedure setExpanded(const aNode : PVirtualNode; const aExpandedState : boolean);


    procedure SetVisible(const aNode: PVirtualNode;const aVisible : boolean);

    class function FormatTime(const ticks,frequency: int64): string; overload;
    class function FormatTime(const value: double): string; overload;

    class function FormatCnt(const cnt: integer): string;
    class function FormatPerc(const per: real): string;

    property Tree : TVirtualStringTree read fTree;
  end;

implementation

uses
  System.SysUtils,
  GpIFF,
  gpString,
  VirtualTrees.BaseTree,
  VirtualTrees.Types;


constructor TVirtualTreeBaseTools.Create(const aList: TVirtualStringTree);
begin
  fTree := aList;
  fTree.OnHeaderClick := self.OnHeaderClick;
  fTree.IncrementalSearch := TVTIncrementalSearch.isAll;
  fTree.OnIncrementalSearch := self.OnIncrementalSearch;
end;

destructor TVirtualTreeBaseTools.Destroy;
begin
  inherited;
end;

procedure TVirtualTreeBaseTools.BeginUpdate;
begin
  fTree.BeginUpdate;
  fTree.TreeOptions.MiscOptions := fTree.TreeOptions.MiscOptions;
end;

procedure TVirtualTreeBaseTools.EndUpdate;
begin
  fTree.TreeOptions.MiscOptions := fTree.TreeOptions.MiscOptions;
  fTree.EndUpdate;
end;

procedure TVirtualTreeBaseTools.Clear;
begin
  fTree.Clear();
end;

function TVirtualTreeBaseTools.GetSelectedIndex: integer;
var
  LNode : PVirtualNode;
begin
  result := -1;
  LNode := self.GetSelectedNode;
  if assigned(LNode) then
    Result := LNode.Index;
end;

function TVirtualTreeBaseTools.GetSelectedNode: PVirtualNode;
begin
  result := fTree.GetFirstSelected;
end;

function TVirtualTreeBaseTools.GetCount: integer;
begin
  result := fTree.TotalCount;
end;


function TVirtualTreeBaseTools.GetName(const anIndex: Cardinal;const column : integer = 0): string;
var
  LNode : PVirtualNode;
begin
  LNode := GetNode(anIndex);
  result := GetName(LNode);
end;

function TVirtualTreeBaseTools.GetName(const aNode: PVirtualNode; const column : integer = 0): string;
begin
  result := '';
  if Assigned(aNode) then
    fTree.OnGetText(fTree,aNode,column,TVSTTextType.ttNormal,Result);
end;

procedure TVirtualTreeBaseTools.setExpanded(const aNode: PVirtualNode; const aExpandedState : boolean);
begin
  fTree.Expanded[aNode] := aExpandedState;
end;

procedure TVirtualTreeBaseTools.setSelectedIndex(const anIndex: cardinal);
var
  LEnumor : TVTVirtualNodeEnumerator;
begin
  LEnumor := fTree.Nodes().GetEnumerator();
  while(LEnumor.MoveNext) do
  begin
    fTree.Selected[LEnumor.Current] := LEnumor.Current.index = anIndex;
  end;
end;


procedure TVirtualTreeBaseTools.SetVisible(const aNode: PVirtualNode;const aVisible : boolean);
begin
 if not Assigned(aNode) then
    Exit;
  fTree.IsVisible[aNode] := aVisible;
end;

function TVirtualTreeBaseTools.GetNode(const anIndex: Cardinal): PVirtualNode;
var
  LEnumor : TVTVirtualNodeEnumerator;
begin
  result := nil;
  LEnumor := fTree.Nodes().GetEnumerator();
  while(LEnumor.MoveNext) do
  begin
    if LEnumor.Current.Index = anIndex then
      Exit(LEnumor.Current);
  end;
end;


function TVirtualTreeBaseTools.GetChildByName(const aParent: PVirtualNode; const aName: string): PVirtualNode;
var
  LChild : PVirtualNode;
begin
  result := nil;
  LChild := aParent.FirstChild;
  while(Assigned(LChild)) do
  begin
    if sametext(GetName(LChild), aName) then
      Exit(LChild);
    LChild := LChild.NextSibling;
  end
end;

function TVirtualTreeBaseTools.GetNodeByName(const aName: string): PVirtualNode;
var
  LEnumor : TVTVirtualNodeEnumerator;
begin
  result := nil;
  LEnumor := fTree.Nodes().GetEnumerator();
  while(LEnumor.MoveNext) do
  begin
    if sametext(GetName(LEnumor.Current.Index), aName) then
      Exit(LEnumor.Current);
  end;
end;



/// Events

procedure TVirtualTreeBaseTools.OnHeaderClick(Sender: TVTHeader;
  HitInfo: TVTHeaderHitInfo);
begin
  SetLength(fSortCols,length(fSortCols)+1);
  fSortCols[Length(fSortCols)-1] := HitInfo.Column;
  fTree.SortTree(HitInfo.Column,Sender.SortDirection,True);

  if Sender.SortDirection=sdAscending then
    Sender.SortDirection:=sdDescending
  else
    Sender.SortDirection:=sdAscending;
  fTree.Header.SortDirection := Sender.SortDirection;
  fTree.Header.SortColumn := HitInfo.Column;
end;


procedure TVirtualTreeBaseTools.OnIncrementalSearch(Sender: TBaseVirtualTree; Node: PVirtualNode;
  const SearchText: string; var Result: Integer);
begin
  result := AnsiStrLIComp(pWidechar(GetName(node.Index)),PWideChar(SearchText), Length(SearchText));
end;

/// static helpers
///

class function TVirtualTreeBaseTools.FormatTime(const ticks, frequency: int64): string;
begin
  Result := FormatTime( ticks / frequency);
end;


class function TVirtualTreeBaseTools.FormatTime(const value: double): string;
begin
  Result := Format('%.6n',[value]);
end;

class function TVirtualTreeBaseTools.FormatCnt(const cnt: integer): string;
begin
  Result := Format('%.0n',[int(cnt)]);
end;

class function TVirtualTreeBaseTools.FormatPerc(const per: real): string;
begin
  Result := Format('%2.2f %%',[per*100]);
end;



end.

