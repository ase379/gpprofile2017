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
    fList: TVirtualStringTree;
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

    function GetName(const anIndex: Cardinal): string; overload;
    function GetName(const aNode : PVirtualNode) : string; overload; virtual;
    procedure setSelectedIndex(const anIndex : cardinal);
    procedure SetVisible(const aNode: PVirtualNode;const aVisible : boolean);

    property Tree : TVirtualStringTree read fTree;
  end;

implementation

uses
  System.SysUtils,
  GpIFF,
  gpString;


constructor TVirtualTreeBaseTools.Create(const aList: TVirtualStringTree);
begin
  fList := aList;
  fList.OnHeaderClick := self.OnHeaderClick;
  fList.IncrementalSearch := isAll;
  fList.OnIncrementalSearch := self.OnIncrementalSearch;
end;

destructor TVirtualTreeBaseTools.Destroy;
begin
  inherited;
end;

procedure TVirtualTreeBaseTools.BeginUpdate;
begin
  FList.BeginUpdate;
  fList.TreeOptions.MiscOptions := fList.TreeOptions.MiscOptions;
end;

procedure TVirtualTreeBaseTools.EndUpdate;
begin
  fList.TreeOptions.MiscOptions := fList.TreeOptions.MiscOptions;
  FList.EndUpdate;
end;

procedure TVirtualTreeBaseTools.Clear;
begin
  fList.Clear();
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
  result := fList.GetFirstSelected;
end;

function TVirtualTreeBaseTools.GetCount: integer;
begin
  result := fList.TotalCount;
end;


function TVirtualTreeBaseTools.GetName(const anIndex: Cardinal): string;
var
  LNode : PVirtualNode;
begin
  LNode := GetNode(anIndex);
  result := GetName(LNode);
end;

function TVirtualTreeBaseTools.GetName(const aNode: PVirtualNode): string;
begin
  result := '';
  if Assigned(aNode) then
    fList.OnGetText(fList,aNode,0,TVSTTextType.ttNormal,Result);
end;

procedure TVirtualTreeBaseTools.setSelectedIndex(const anIndex: cardinal);
var
  LEnumor : TVTVirtualNodeEnumerator;
begin
  LEnumor := fList.Nodes().GetEnumerator();
  while(LEnumor.MoveNext) do
  begin
    fList.Selected[LEnumor.Current] := LEnumor.Current.index = anIndex;
  end;
end;


procedure TVirtualTreeBaseTools.SetVisible(const aNode: PVirtualNode;const aVisible : boolean);
begin
 if not Assigned(aNode) then
    Exit;
  fList.IsVisible[aNode] := aVisible;
end;

function TVirtualTreeBaseTools.GetNode(const anIndex: Cardinal): PVirtualNode;
var
  LEnumor : TVTVirtualNodeEnumerator;
begin
  result := nil;
  LEnumor := fList.Nodes().GetEnumerator();
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
  LEnumor := fList.Nodes().GetEnumerator();
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
  fList.SortTree(HitInfo.Column,Sender.SortDirection,True);

  if Sender.SortDirection=sdAscending then
    Sender.SortDirection:=sdDescending
  else
    Sender.SortDirection:=sdAscending;
  fList.Header.SortDirection := Sender.SortDirection;
  fList.Header.SortColumn := HitInfo.Column;
end;


procedure TVirtualTreeBaseTools.OnIncrementalSearch(Sender: TBaseVirtualTree; Node: PVirtualNode;
  const SearchText: string; var Result: Integer);
begin
  result := AnsiStrLIComp(pWidechar(GetName(node.Index)),PWideChar(SearchText), Length(SearchText));
end;

end.

