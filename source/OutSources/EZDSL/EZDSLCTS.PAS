{===EZDSLCts==========================================================

Constants for the EZDSL (Delphi Structures Library) unit.

EZDSLCTS is Copyright (c) 1993,1997 by  Julian M. Bucknall

VERSION HISTORY
14May98 JMB 3.01 Inclusion of TBooleanArray string codes
19Apr98 JMB 3.00 Major new version, release for Delphi 3
24May96 JMB 2.01 extra string codes
13Mar96 JMB 2.00 release for Delphi 2.0
18Jun95 JMB 1.00 initial release
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EZDSLCts;

interface

{Note: the actual strings are found in EZDSLCTS.RC and EZDSLCTS.R16/.R32}

const
  {Start offset for string constants}
  {Note: this can be altered to suit the application}
  ezdsStartOffset = $62D5;

  {Error string constants}
  escTooManyItems   = ezdsStartOffset+ 1;
  escInsInvalidHere = ezdsStartOffset+ 2;
  escDelInvalidHere = ezdsStartOffset+ 3;
  escInsertDup      = ezdsStartOffset+ 4;
  escCannotMoveHere = ezdsStartOffset+ 5;
  escNoCompare      = ezdsStartOffset+ 6;
  escNoDupData      = ezdsStartOffset+ 7;
  escNoDisposeData  = ezdsStartOffset+ 8;
  escBadSource      = ezdsStartOffset+ 9;
  escIndexError     = ezdsStartOffset+10;
  escBadCaseSwitch  = ezdsStartOffset+11;
  escKeyNotFound    = ezdsStartOffset+12;
  escTableFull      = ezdsStartOffset+13;
  escSortNeedsCmp   = ezdsStartOffset+14;
  escCmpNeeded      = ezdsStartOffset+15;
  escBadBooleanInx  = ezdsStartOffset+16;


  {Assertion string constants}
  ascFreeNilNode    = ezdsStartOffset+50;
  ascNewNodeSize0   = ezdsStartOffset+51;
  ascFreeNodeSize0  = ezdsStartOffset+52;
  ascEmptyExamine   = ezdsStartOffset+53;
  ascEmptyPop       = ezdsStartOffset+54;
  ascDeleteEdges    = ezdsStartOffset+55;
  ascExamineEdges   = ezdsStartOffset+56;
  ascInsertEdges    = ezdsStartOffset+57;
  ascReplaceEdges   = ezdsStartOffset+58;
  ascAlreadyAtEnd   = ezdsStartOffset+59;
  ascAlreadyAtStart = ezdsStartOffset+60;
  ascCannotJoinHere = ezdsStartOffset+61;
  ascCannotJoinData = ezdsStartOffset+62;
  ascSplitEdges     = ezdsStartOffset+63;
  ascOutOfRange     = ezdsStartOffset+64;
  ascExamineLeaf    = ezdsStartOffset+65;
  ascBadSkipLevel   = ezdsStartOffset+66;
  ascIsSortedList   = ezdsStartOffset+67;
  ascIsNotSortedList= ezdsStartOffset+68;
  ascBadCapacity    = ezdsStartOffset+69;
  ascNilArray       = ezdsStartOffset+70;
  ascNotSameSize    = ezdsStartOffset+71;

implementation

end.
