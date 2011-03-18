program DTstBtre;
  {Test program for binary trees: normal, search and redblack}

{$I EZDSLDEF.INC}
{---Place any compiler options you require here-----------------------}


{---------------------------------------------------------------------}
{$I EZDSLOPT.INC}

{$IFDEF Win32}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  {$IFDEF Win32}
  Windows,
  {$ELSE}
  WinProcs,
  WinTypes,
  {$ENDIF}
  SysUtils,
  EZDSLCts in 'EZDSLCTS.PAS',
  EZDSLBse in 'EZDSLBSE.PAS',
  ezdslbtr in 'ezdslbtr.pas',
  EZDSLSup in 'EZDSLSUP.PAS',
  DTstGen in 'DTstGen.pas';

function PrintStrs(C : TAbstractContainer;
                   aData : pointer;
                   ExtraData : pointer) : boolean; far;
  var
    S : PEZString absolute aData;
  begin
    Result := true;
    WriteLogNoCR(S^);
  end;

function AlterStrs(C : TAbstractContainer;
                   aData : pointer;
                   ExtraData : pointer) : boolean; far;
  var
    S : PEZString absolute aData;
  begin
    Result := true;
    if (S^ <> '') then
      S^[length(S^)] := 'z';
  end;

function ReverseCompare(aData1, aData2 : pointer) : integer; far;
begin
  Result := EZStrCompare(aData2, aData1);
end;

const
  InsertSeq : string [79] = 'titlitritllitlritrlitrritlllitllritrrri';

var
  BinTree, NewBinTree : TBinTree;
  BSTree, NewBSTree : TBinSearchTree;
  rbTree, NewrbTree : TrbSearchTree;
  i, j : integer;
  Walker : TTreeCursor;

begin
  OpenLog;
  try
    WriteLog('Starting tests');
    {$IFDEF UseTreeRecursion}
    WriteLog('(EZDSL compiled to use tree recursion)');
    {$ELSE}
    WriteLog('(EZDSL compiled to unroll tree recursion)');
    {$ENDIF}

    WriteLog('----------------BINARY TREE----------------');
    BinTree := nil;
    NewBinTree := nil;
    try
      WriteLog('First test: insertion; traversing');
      BinTree := TBinTree.Create(true);
      with BinTree do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          WriteLog('...inserting names of numbers');
          j := 0;
          for i := 1 to length(InsertSeq) do
            case InsertSeq[i] of
              't' : Walker := Root;
              'l' : if not IsLeaf(Walker) then
                      Walker := Left(Walker);
              'r' : if not IsLeaf(Walker) then
                      Walker := Right(Walker);
              'i' : begin
                      inc(j);
                      Insert(Walker, EZStrNew(NumToName(j)));
                    end;
            end;{case}
          WriteLog('...the tree now looks like this');
          WriteLog('...               one');
          WriteLog('...            /       \');
          WriteLog('...         two         three');
          WriteLog('...        /   \       /     \');
          WriteLog('...    four     five  six     seven');
          WriteLog('...    /  \                      \');
          WriteLog('...eight  nine                   ten');
          WriteLog('...Traversals');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..preorder reversed..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, true, nil);
          WriteLog('');
          WriteLog('..inorder reversed..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, true, nil);
          WriteLog('');
          WriteLog('..postorder reversed..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, true, nil);
          WriteLog('');
          WriteLog('..levelorder reversed..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, true, nil);
          WriteLog('');
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: deletion');
      with BinTree do
        begin
          WriteLog('...delete the rightmost');
          Walker := Root;
          while not IsLeaf(Walker) do
            Walker := Right(Walker);
          Walker := Parent(Walker);
          Erase(Walker);
          WriteLog('...the tree now looks like this');
          WriteLog('...               one');
          WriteLog('...            /       \');
          WriteLog('...         two         three');
          WriteLog('...        /   \       /     \');
          WriteLog('...    four     five  six     seven');
          WriteLog('...    /  \');
          WriteLog('...eight  nine');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...delete the leftmost');
          Walker := Root;
          while not IsLeaf(Walker) do
            Walker := Left(Walker);
          Walker := Parent(Walker);
          Erase(Walker);
          WriteLog('...the tree now looks like this');
          WriteLog('...               one');
          WriteLog('...            /       \');
          WriteLog('...         two         three');
          WriteLog('...        /   \       /     \');
          WriteLog('...    four     five  six     seven');
          WriteLog('...       \');
          WriteLog('...       nine');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...delete the leftmost');
          Walker := Root;
          while not IsLeaf(Walker) do
            Walker := Left(Walker);
          Walker := Parent(Walker);
          Erase(Walker);
          WriteLog('...the tree now looks like this');
          WriteLog('...               one');
          WriteLog('...            /       \');
          WriteLog('...         two         three');
          WriteLog('...        /   \       /     \');
          WriteLog('...    nine     five  six     seven');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          Empty;
          WriteLog('...end of test 2');
        end;

      WriteLog('Third test: cloning');
      with BinTree do
        begin
          WriteLog('...inserting names of numbers');
          j := 0;
          for i := 1 to length(InsertSeq) do
            case InsertSeq[i] of
              't' : Walker := Root;
              'l' : if not IsLeaf(Walker) then
                      Walker := Left(Walker);
              'r' : if not IsLeaf(Walker) then
                      Walker := Right(Walker);
              'i' : begin
                      inc(j);
                      Insert(Walker, EZStrNew(NumToName(j)));
                    end;
            end;{case}
          WriteLog('...creating clone');
          NewBinTree := TBinTree.Clone(BinTree, true, EZStrCompare);
          WriteLog('..clone preorder..');
          NewBinTree.TraversalType := ttPreOrder;
          NewBinTree.Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..clone inorder..');
          NewBinTree.TraversalType := ttInOrder;
          NewBinTree.Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..clone postorder..');
          NewBinTree.TraversalType := ttPostOrder;
          NewBinTree.Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..clone levelorder..');
          NewBinTree.TraversalType := ttLevelOrder;
          NewBinTree.Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...end of test 3');
        end;

      WriteLog('Fourth test: joining');
      with BinTree do
        begin
          WriteLog('...alter clone''s strings to have last letter Z');
          NewBinTree.Iterate(AlterStrs, false, nil);
          WriteLog('');
          WriteLog('...join at left child of "five"');
          Walker := Left(Right(Left(Root)));
          Join(Walker, NewBinTree);
          NewBinTree := nil;
          WriteLog('...the tree now looks like this');
          WriteLog('...               one');
          WriteLog('...            /       \');
          WriteLog('...         two         three');
          WriteLog('...        /   \       /     \');
          WriteLog('...    four     five  six     seven');
          WriteLog('...    /  \      /               \');
          WriteLog('...eight  nine  CLONE            ten');
          WriteLog('...with CLONE being the cloned tree');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...end of test 4');
        end;
    finally
      BinTree.Free;
      NewBinTree.Free;
    end;

    WriteLog('----------------BINARY SEARCH TREE----------------');
    BSTree := nil;
    NewBSTree := nil;
    try
      WriteLog('First test: insertion; traversing');
      BSTree := TBinSearchTree.Create(true);
      with BSTree do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            Insert(Walker, EZStrNew(NumToName(i)));
          WriteLog('...the tree now looks like this');
          WriteLog('...               one');
          WriteLog('...            /       \');
          WriteLog('...         four        two');
          WriteLog('...        /   \       /');
          WriteLog('...    five     nine  three');
          WriteLog('...    /              /');
          WriteLog('...eight             six');
          WriteLog('...                 /   \');
          WriteLog('...            seven     ten');
          WriteLog('...Traversals');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..preorder reversed..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, true, nil);
          WriteLog('');
          WriteLog('..inorder reversed..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, true, nil);
          WriteLog('');
          WriteLog('..postorder reversed..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, true, nil);
          WriteLog('');
          WriteLog('..levelorder reversed..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, true, nil);
          WriteLog('');
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: deletion');
      with BSTree do
        begin
          WriteLog('...delete the rightmost');
          Walker := Root;
          while not IsLeaf(Walker) do
            Walker := Right(Walker);
          Walker := Parent(Walker);
          Erase(Walker);
          WriteLog('...the tree now looks like this');
          WriteLog('...               one');
          WriteLog('...            /       \');
          WriteLog('...         four        three');
          WriteLog('...        /   \       /');
          WriteLog('...    five     nine  six');
          WriteLog('...    /             /   \');
          WriteLog('...eight        seven     ten');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...delete the leftmost');
          Walker := Root;
          while not IsLeaf(Walker) do
            Walker := Left(Walker);
          Walker := Parent(Walker);
          Erase(Walker);
          WriteLog('...the tree now looks like this');
          WriteLog('...               one');
          WriteLog('...            /       \');
          WriteLog('...         four        three');
          WriteLog('...        /   \       /');
          WriteLog('...    five     nine  six');
          WriteLog('...                  /   \');
          WriteLog('...             seven     ten');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...delete the rightmost');
          Walker := Root;
          while not IsLeaf(Walker) do
            Walker := Right(Walker);
          Walker := Parent(Walker);
          Erase(Walker);
          WriteLog('...the tree now looks like this');
          WriteLog('...               one');
          WriteLog('...            /       \');
          WriteLog('...         four        six');
          WriteLog('...        /   \       /   \');
          WriteLog('...    five     nine seven  ten');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          Empty;
          WriteLog('...end of test 2');
        end;

      WriteLog('Third test: cloning');
      with BSTree do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            Insert(Walker, EZStrNew(NumToName(i)));
          WriteLog('...creating clone');
          NewBSTree := TBinSearchTree.Clone(BSTree, true, EZStrCompare);
          WriteLog('..clone preorder..');
          NewBSTree.TraversalType := ttPreOrder;
          NewBSTree.Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..clone inorder..');
          NewBSTree.TraversalType := ttInOrder;
          NewBSTree.Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..clone postorder..');
          NewBSTree.TraversalType := ttPostOrder;
          NewBSTree.Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..clone levelorder..');
          NewBSTree.TraversalType := ttLevelOrder;
          NewBSTree.Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...end of test 3');
        end;

      WriteLog('Fourth test: joining');
      with BSTree do
        begin
          WriteLog('...alter clone''s strings to have last letter Z');
          NewBSTree.Iterate(AlterStrs, false, nil);
          WriteLog('');
          WriteLog('...join');
          Join(Walker, NewBSTree);
          NewBSTree := nil;
          WriteLog('...the tree now looks like this');
          WriteLog('...                one');
          WriteLog('...         /                \');
          WriteLog('...     four                  two');
          WriteLog('...    /    \               /     \');
          WriteLog('...  five  nine          three     twz');
          WriteLog('...  / \   / \          /     \');
          WriteLog('... 8  5z 4z 9z       six      threz');
          WriteLog('...  \               /  \');
          WriteLog('...  8z             7    10');
          WriteLog('...                / \   / \');
          WriteLog('...               1z 7z 6z 10z');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...end of test 4');
        end;
    finally
      BSTree.Free;
      NewBSTree.Free;
    end;

    WriteLog('----------------RED-BLACK SEARCH TREE----------------');
    rbTree := nil;
    NewrbTree := nil;
    try
      WriteLog('First test: insertion; traversing');
      rbTree := TrbSearchTree.Create(true);
      with rbTree do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            Insert(Walker, EZStrNew(NumToName(i)));
          WriteLog('...the tree now looks like this');
          WriteLog('...              seven');
          WriteLog('...            /       \');
          WriteLog('...        four*        three*');
          WriteLog('...        /   \       /     \');
          WriteLog('...    five     one   six     two');
          WriteLog('...    /       /         \');
          WriteLog('...eight*   nine*         ten*');
          WriteLog('...(*=red nodes)');
          WriteLog('...Traversals');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..preorder reversed..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, true, nil);
          WriteLog('');
          WriteLog('..inorder reversed..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, true, nil);
          WriteLog('');
          WriteLog('..postorder reversed..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, true, nil);
          WriteLog('');
          WriteLog('..levelorder reversed..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, true, nil);
          WriteLog('');
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: deletion');
      with rbTree do
        begin
          WriteLog('...delete the rightmost');
          Walker := Root;
          while not IsLeaf(Walker) do
            Walker := Right(Walker);
          Walker := Parent(Walker);
          Erase(Walker);
          WriteLog('...the tree now looks like this');
          WriteLog('...              seven');
          WriteLog('...            /       \');
          WriteLog('...        four*        ten*');
          WriteLog('...        /   \       /    \');
          WriteLog('...    five     one   six    three');
          WriteLog('...    /       /');
          WriteLog('...eight*   nine*');
          WriteLog('...(*=red nodes)');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...delete the leftmost');
          Walker := Root;
          while not IsLeaf(Walker) do
            Walker := Left(Walker);
          Walker := Parent(Walker);
          Erase(Walker);
          WriteLog('...the tree now looks like this');
          WriteLog('...              seven');
          WriteLog('...            /       \');
          WriteLog('...        four*        ten*');
          WriteLog('...        /   \       /    \');
          WriteLog('...    five     one   six    three');
          WriteLog('...            /');
          WriteLog('...         nine*');
          WriteLog('...(*=red nodes)');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...delete the rightmost');
          Walker := Root;
          while not IsLeaf(Walker) do
            Walker := Right(Walker);
          Walker := Parent(Walker);
          Erase(Walker);
          WriteLog('...the tree now looks like this');
          WriteLog('...              seven');
          WriteLog('...            /       \');
          WriteLog('...        four*        ten');
          WriteLog('...        /   \       /');
          WriteLog('...    five     one   six*');
          WriteLog('...            /');
          WriteLog('...         nine*');
          WriteLog('...(*=red nodes)');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          Empty;
          WriteLog('...end of test 2');
        end;

      WriteLog('Third test: cloning');
      with rbTree do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            Insert(Walker, EZStrNew(NumToName(i)));
          WriteLog('...creating clone');
          NewrbTree := TrbSearchTree.Clone(rbTree, true, EZStrCompare);
          WriteLog('..clone preorder..');
          NewrbTree.TraversalType := ttPreOrder;
          NewrbTree.Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..clone inorder..');
          NewrbTree.TraversalType := ttInOrder;
          NewrbTree.Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..clone postorder..');
          NewrbTree.TraversalType := ttPostOrder;
          NewrbTree.Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..clone levelorder..');
          NewrbTree.TraversalType := ttLevelOrder;
          NewrbTree.Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...end of test 3');
        end;

      WriteLog('Fourth test: joining');
      with rbTree do
        begin
          WriteLog('...alter clone''s strings to have last letter Z');
          NewrbTree.Iterate(AlterStrs, false, nil);
          WriteLog('');
          WriteLog('...join');
          Join(Walker, NewrbTree);
          NewrbTree := nil;
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...end of test 4');
        end;

      WriteLog('Fifth test: resetting Compare');
      with rbTree do
        begin
          Empty;
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            Insert(Walker, EZStrNew(NumToName(i)));
          WriteLog('...setting Compare');
          Compare := ReverseCompare;
          WriteLog('...the tree now looks like this');
          WriteLog('...               nine');
          WriteLog('...            /       \');
          WriteLog('...         six         five');
          WriteLog('...        /   \       /     \');
          WriteLog('...    three    one  four    eight');
          WriteLog('...    /  \     /');
          WriteLog('...  two  ten  seven');
          WriteLog('..preorder..');
          TraversalType := ttPreOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..inorder..');
          TraversalType := ttInOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..postorder..');
          TraversalType := ttPostOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('..levelorder..');
          TraversalType := ttLevelOrder;
          Iterate(PrintStrs, false, nil);
          WriteLog('');
          WriteLog('...end of test 5');
        end;
    finally
      rbTree.Free;
      NewrbTree.Free;
    end;
  finally
    CloseLog;
  end;
end.

