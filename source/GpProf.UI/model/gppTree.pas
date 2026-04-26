unit gppTree;

interface
uses
  System.Classes, System.Generics.Collections;

type
  INode<T: class> = interface
  ['{3BE01E57-FEF8-434F-B5D1-679748287C9F}']
    procedure SetData(const aValue : T);
    function GetData(): T;

    property Data : T read GetData write setData;
  end;

  TNode<T: class> = class(TInterfacedObject, INode<T>)
  private
    constructor Create(aValue: T);
  protected
    fData : T;
    fNextNode : INode<T>;
    fPreviousNode : INode<T>;
    procedure SetData(const aValue : T);
    function GetData(): T;
 end;

  TNodeList<T: class> = class(TList<INode<T>>);

  TRootNode<T: class> = class(TNode<T>)
  public type
    TEnumerator = TList<INode<T>>.TEnumerator;
    TCompareFunc = function (const aNodeA, aNodeB : INode<T>) : integer;
  private
    fCompareFunc : TCompareFunc;
    fSortedList : TNodeList<T>;
    fLookupDict : TDictionary<string, INode<T>>;
    function getCount: Cardinal;
  protected
    property CompareFunc : TCompareFunc read fCompareFunc write fCompareFunc;
    function GetLookupKey(const aValue : T) : string; virtual;abstract;
    function FindNode(const aSearchData : T; out aResultNode: INode<T>) : boolean; overload;
    function FindNode(const aLookupKey : string; out aResultNode: INode<T>) : boolean; overload;
  public
    constructor Create();
    destructor Destroy; override;

    function GetEnumerator(): TEnumerator;
    function GetList(): TNodeList<T>;
    function FindNode(const aSearchNode : INode<T>; out aResultNode: INode<T>) : boolean; overload;

    function Last : INode<T>;
    function First : INode<T>;

    function AppendNode(const aValue:T) : INode<T>;
    procedure ClearNodes();
    property Count : Cardinal read getCount;
  end;


implementation

uses
  System.Sysutils, System.Generics.Defaults;

{ TNode<T> }

constructor TNode<T>.Create(aValue: T);
begin
  fData := aValue;
end;

procedure TNode<T>.SetData(const aValue: T);
begin
  if assigned(fData) and (fData <> aValue) then
    raise exception.Create('Must free Instance before setting pointer.');
  fData := aValue;
end;


function TNode<T>.GetData: T;
begin
  result := fData;
end;

{ TRootNode<T> }

constructor TRootNode<T>.Create();
begin
  inherited Create(nil);
  fSortedList := TNodeList<T>.Create();
  fLookupDict := TDictionary<string, INode<T>>.Create;
end;

destructor TRootNode<T>.Destroy;
begin
  fLookupDict.Free;
  fSortedList.Free;
  inherited;
end;

procedure TRootNode<T>.ClearNodes;
begin
  fSortedList.Clear;
  fLookupDict.Clear;
end;


function TRootNode<T>.FindNode(const aSearchNode : INode<T>; out aResultNode: INode<T>) : boolean;
begin
  result := FindNode(aSearchNode.Data, aResultNode);
end;


function TRootNode<T>.FindNode(const aSearchData : T; out aResultNode: INode<T>) : boolean;
var
  LKey : string;
begin
  LKey := GetLookupKey(aSearchData);
  result := FindNode(LKey, aResultNode);
end;


function TRootNode<T>.FindNode(const aLookupKey : string; out aResultNode: INode<T>) : boolean;
begin
  result := fLookupDict.TryGetValue(aLookupKey, aResultNode);
  if not result then
    aResultNode := nil;
end;

function TRootNode<T>.First: INode<T>;
begin
  result := fSortedList.First;
end;

function TRootNode<T>.getCount: Cardinal;
begin
  result := fSortedList.Count;
end;

function TRootNode<T>.GetEnumerator: TEnumerator;
begin
  result := fSortedList.GetEnumerator();
end;

function TRootNode<T>.GetList: TNodeList<T>;
begin
  result := fSortedList;
end;

function TRootNode<T>.Last: INode<T>;
begin
  result := fSortedList.Last;
end;

function TRootNode<T>.AppendNode(const aValue: T): INode<T>;
begin
  // do not allow double keys (e.g. when defines are used)
  if not FindNode(aValue, result) then
  begin
    result := TNode<T>.Create(AValue);
    fSortedList.Add(result);
    fLookupDict.Add(GetLookupKey(aValue),result);
  end;
end;

end.
