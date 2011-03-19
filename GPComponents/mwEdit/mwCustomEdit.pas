{+-----------------------------------------------------------------------------+
 | Class:       TmwCustomEdit
 | Created:     1998-11
 | Last change: 1999-09-14
 | Author:      Martin Waldenburg
 | Description: study on how to create a custom edit control without using
 |              a Windows edit control.
 | Version:     0.86 internal beta (see VERSION.RTF for version history)
 | Copyright (c) 1998 Martin Waldenburg
 | All rights reserved.
 |
 | Thanks to : Woo Young Bum, Angus Johnson, Michael Trier, James Jacobson,
 |             Thomas Kurz, Primoz Gabrijelcic, Michael Beck, Andy Jeffries,
 |             Edward Kreis, Brad Stowers, Willo van der Merwe, Bernt Levinsson,
 |             Ted Berg, Michael Hieke, Dragan Grbic, Lucifer, Kees van Spelde,
 |             Hideo Koiso, Albert Research, Theodoros Bebekis, Heedong Lim,
 |             xyeyu, ArentJan Banck, Alexander Reiter, Tohru Hanai,
 |             Winfried Schoettler 
 |
 | LICENCE CONDITIONS
 |
 | USE OF THE ENCLOSED SOFTWARE
 | INDICATES YOUR ASSENT TO THE
 | FOLLOWING LICENCE CONDITIONS.
 |
 |
 |
 | These Licence Conditions are exlusively
 | governed by the Law and Rules of the
 | Federal Republic of Germany.
 |
 | Redistribution and use in source and binary form, with or without
 | modification, are permitted provided that the following conditions
 | are met:
 |
 | 1. Redistributions of source code must retain the above copyright
 |    notice, this list of conditions and the following disclaimer.
 |    If the source is modified, the complete original and unmodified
 |    source code has to distributed with the modified version.
 |
 | 2. Redistributions in binary form must reproduce the above
 |    copyright notice, these licence conditions and the disclaimer
 |    found at the end of this licence agreement in the documentation
 |    and/or other materials provided with the distribution.
 |
 | 3. Software using this code must contain a visible line of credit.
 |
 | 4. If my code is used in a "for profit" product, you have to donate
 |    to a registered charity in an amount that you feel is fair.
 |    You may use it in as many of your products as you like.
 |    Proof of this donation must be provided to the author of
 |    this software.
 |
 | 5. If you for some reasons don't want to give public credit to the
 |    author, you have to donate three times the price of your software
 |    product, or any other product including this component in any way,
 |    but no more than $500 US and not less than $200 US, or the
 |    equivalent thereof in other currency, to a registered charity.
 |    You have to do this for every of your products, which uses this
 |    code separately.
 |    Proof of this donations must be provided to the author of
 |    this software.
 |
 |
 | DISCLAIMER:
 |
 | THIS SOFTWARE IS PROVIDED BY THE AUTHOR 'AS IS'.
 |
 | ALL EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 | THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 | PARTICULAR PURPOSE ARE DISCLAIMED.
 |
 | IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 | INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 | (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 | OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 | INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 | WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 | NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 | THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 |
 |  Martin.Waldenburg@T-Online.de
 |
 | Known problems:
 |   - dragging cannot be canceled with the chord clicking - don't know how to
 |     fix!
 |
 +----------------------------------------------------------------------------+}

{$I MWEDIT.INC}                                                                 //mt 12/16/1998 added
//mt 12/16/1998 removed {$ObjExportAll On} since it's defined in the include

unit mwCustomEdit;

interface

{$IFDEF MWE_COMPILER_3_UP}                                                      //gp 1999-05-10
//'Imm' is not available in Delphi 2 (and probably in C++ Builder 1).
{$DEFINE MWE_MBCSSUPPORT}                                                       //hk 1999-05-10
{$ENDIF}

{$DEFINE MWE_SELECTION_MODE}

uses
// Nasty BCB linker error when doing it this way:                               //mt 12/10/1998
//   Windows, WinProcs, Messages, Classes, Controls, Printers,
//   Forms, Graphics, SysUtils, StdCtrls, Clipbrd, ExtCtrls, mwPasSyn;
  Windows, Messages, SysUtils, Classes, Controls, Graphics,
  mwKeyCmds,                                                                    //bds 12/23/1998
  mwEditSearch,
  mwLocalStr, mwSupportProcs, mwSupportClasses,                                 //mh 1999-09-12
  Printers,                                                                     //bds 1/24/1999
{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
  Imm,
{$ENDIF}
  ExtCtrls, Forms, StdCtrls, Clipbrd, mwHighlighter,
  uTextDrawer;                                                                  //th 1999-09-16

const
   DIGIT            = ['0'..'9'];
// ALPHA            = ['A'..'Z', 'a'..'z'];                                     //mt 12/10/1998
// break these up because we exceed the 4 byte limit when combined.
   ALPHA_UC         = ['A'..'Z'];
   ALPHA_LC         = ['a'..'z'];

   // not defined in all Delphi versions
   WM_MOUSEWHEEL    = $020A;                                                    //gp 1999-05-10

   // maximum scroll range
   MAX_SCROLL = 32767;                                                          //mh 1999-05-12

// Max number of book/gutter marks returned from GetMarksForLine - that really
// should be enough.
   maxMarks = 16;                                                               //gp 1/10/1999

{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
   MWEDIT_CLIPBOARD_FORMAT = 'mwEdit Control Block Type';

var
  mwEditClipboardFormat: UINT;
{$ENDIF}
{end}                                                                           //bds 1/25/1999

{$IFDEF MWE_MBCSSUPPORT}
{$IFNDEF MWE_COMPILER_4_UP}                                                     //xueyu 1999-06-29
{Windows.pas in D4}
const
  C3_NONSPACING = 1; { nonspacing character }
  C3_DIACRITIC = 2; { diacritic mark }
  C3_VOWELMARK = 4; { vowel mark }
  C3_SYMBOL = 8; { symbols }
  C3_KATAKANA = $0010; { katakana character }
  C3_HIRAGANA = $0020; { hiragana character }
  C3_HALFWIDTH = $0040; { half width character }
  C3_FULLWIDTH = $0080; { full width character }
  C3_IDEOGRAPH = $0100; { ideographic character }
  C3_KASHIDA = $0200; { Arabic kashida character }
  C3_LEXICAL = $0400; { lexical character }
  C3_ALPHA = $8000; { any linguistic char (C1_ALPHA) }
  C3_NOTAPPLICABLE = 0; { ctype 3 is not applicable }
{$ENDIF}
{$ENDIF}

type
  TmwEditExporter = (cfRTF, cfHTML);                                            //ajb 06/16/1999
  TmwEditExporters = set of TmwEditExporter;                                    //ajb 06/16/1999

  TmwSearchOption  = (mwsoMatchCase, mwsoWholeWord, mwsoBackwards,
                      mwsoEntireScope, mwsoSelectedOnly,
                      mwsoReplace, mwsoReplaceAll, mwsoPrompt);
  TmwSearchOptions = set of TmwSearchOption;

  TmwReplaceAction = (mwraCancel, mwraSkip, mwraReplace, mwraReplaceAll);

{begin}                                                                         //bds 1/25/1999
  EmwEditError = class(Exception);

{$IFDEF MWE_SELECTION_MODE}
  PSelectionMode = ^TSelectionMode;
  TSelectionMode = (smNormal, smColumn, smLine);
{$ENDIF}
{end}                                                                           //bds 1/25/1999

//  PIntArray = ^TIntArray;                                                       //bds 12/24/1998 //mh 1999-09-12
//  TIntArray = array[0..0] of integer;                                           //bds 12/24/1998 //mh 1999-09-12

  TIndexEvent = procedure(Index: Integer) of object;
  TPaintEvent = procedure(Sender: TObject; ACanvas: TCanvas)                    //jdj 12/12/1998
                  of object;
  TSpecialLineColorsEvent = procedure(Sender: TObject; Line: integer;           //mh 1999-09-12
                                      var Special: boolean; var FG, BG: TColor)
                              of object;
  TReplaceTextEvent = procedure(const ASearch, AReplace: string;
                                Line, Column: integer;
                                var Action: TmwReplaceAction) of object;        // find / replace

  {begin}                                                                       //bds 12/20/1998
//  TEditorCommand = word;   moved to mwKeyCmds.pas                             //bds 12/23/1998
  TProcessCommandEvent = procedure(var Command: TmwEditorCommand;
                     var AChar: char; Data: pointer) of object;                 //bds 12/23/1998

  // Replaced by TMark                                                          //CdeB 12/16/1998
  (*
  PSetBookMarkRec = ^TSetBookMarkRec;  { Used in ecSetMarker command }
  TSetBookMarkRec = record
    MarkerNum: integer;
    MarkerPos: TPoint;
  end;
  *)
  {end}                                                                         //bds 12/20/1998

  TCaretType = (ctVerticalLine, ctHorizontalLine, ctHalfBlock, ctBlock);        //bds 12/17/1998

  {begin}                                                                       //tskurz 12/10/1998
  // added mw as a prefix otherwise crNone conflicts with the                   //mt 12/16/1998
  // crNone cursor constant.
  TChangeReason = (mwcrInsert, mwcrPaste, mwcrDragDropInsert,                   //tskurz 1999-06-11
                   mwcrDeleteAfterCursor,                                       //bds 12/20/1998
	           mwcrDelete, mwcrSelDelete, {mwcrPasteDelete,}                //th 1999-09-22
                   mwcrDragDropDelete, mwcrLineBreak, mwcrNone);

  TChangePtr = ^TChange;
  TChange = record
              ChangeStr: PChar;
              ChangeReason: TChangeReason;
              ChangeStartPos,
              ChangeEndPos: TPoint;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
              ChangeSelMode: TSelectionMode;
{$ENDIF}                                                                        //bds 1/25/1999
            end;
            
  //had to move it up here or the header creator on BCB bombs                   //mt 12/16/1998
  {+----------------------------------------------+
   |               -Bookmarks-
   |There are 10 available numbered 0 to 9
   |The X and Y values are 1 based as are the
   |  CaretX and CaretY properties
   |Shift+Ctrl+TheBookMarkNumber will Set/Clear
   |Ctrl+TheBookMarkNumber will Goto
   |The bitmaps are in mwCustomEdit.res and
   |  are named MARK_ + TheBookMarkNumber
  +----------------------------------------------+}
  // Replaced by TMark                                                          //CdeB 12/16/1998
  {
  TBookMarkRec = record                                                         //jdj 12/10/1998
    IsSet: Boolean;
    X: Integer;
    Y: Integer;
    Glyph: TBitmap;
  end;
  }

  {begin}                                                                       //bds 1/24/1999
  TmwPrintStatus = (psBegin, psNewPage, psEnd);
  TPrintStatusEvent = procedure(Sender: TComponent; Status: TmwPrintStatus;
     PageNumber: integer; var Abort: boolean) of object;

  TmwMarginUnits = (muPixels, muThousandthsOfInches, muMillimeters);
  TmwPrintOptions = record
    SelectedOnly: boolean;
    Highlighted: boolean;
    WrapLongLines: boolean;
    IgnoreColors: boolean;                                                      //mh 1999-09-12
    Copies: integer;
    MarginUnits: TmwMarginUnits;
    Margins: TRect;
    PrintRange: TRect;
    Title: string;
    Header: TStringList;
    Footer: TStringList;
  end;
  {end}                                                                         //bds 1/24/1999

  TmwHeaderFooterAlign = (hfaLeft, hfaRight, hfaCenter);                        //hdl 1999-05-11

  TmwCustomEdit = class;                                                        //tskurz 12/15/1998

  {begin}                                                                       //CdeB 12/16/1998, //gp 1/9/1999
  TMark = class
  protected
    fLine, fColumn, fImage: Integer;
    fEdit: TmwCustomEdit;
    fVisible: boolean;
    fInternalImage: boolean;
    fBookmarkNum: integer;
    function GetEdit: TmwCustomEdit; virtual;
    procedure SetColumn(const Value: Integer); virtual;
    procedure SetImage(const Value: Integer); virtual;
    procedure SetLine(const Value: Integer); virtual;
    procedure SetVisible(const Value: boolean);
    procedure SetInternalImage(const Value: boolean);
    function GetIsBookmark: boolean;
    procedure SetIsBookmark(const Value: boolean);
  public
    constructor Create(owner: TmwCustomEdit);
    property Line: integer read fLine write SetLine;
    property Column: integer read fColumn write SetColumn;
    property ImageIndex: integer read fImage write SetImage;
    property BookmarkNumber: integer read fBookmarkNum write fBookmarkNum;
    property Visible: boolean read fVisible write SetVisible;
    property InternalImage: boolean read fInternalImage write SetInternalImage;
    property IsBookmark: boolean read GetIsBookmark write SetIsBookmark;
  end;

  TPlaceMarkEvent = procedure(var mark: TMark) of object;                       //gp 1/9/1999 - changed (again) and renamed

  TMarks = array [1..maxMarks] of TMark;

  { A list of mark objects. Each object cause a litle picture to be drawn in the
    gutter. }
  TMarkList = class(TList)
  protected
    fEdit: TmwCustomEdit;                                                       //gp 1/9/1999
    fOnChange: TNotifyEvent;
    function Get(Index: Integer): TMark;
    procedure Put(Index: Integer; Item: TMark);
    Procedure DoChange;
  public
    constructor Create(owner: TmwCustomEdit);                                   //gp 1/9/1999
    function Add(Item: TMark): Integer;
    function First: TMark;
    function Last: TMark;
    procedure Insert(Index: Integer; Item: TMark);
    function Remove(Item: TMark): Integer;
    procedure Delete(Index: Integer);
    procedure ClearLine(line: integer);
    procedure Place(mark: TMark);
    procedure GetMarksForLine(line: integer; var marks: TMarks);                //gp 1/10/1999
    property Items[Index: Integer]: TMark read Get write Put; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;
  {end}                                                                         //CdeB 12/16/1998

  TUndoList = class
  private
    fList: TList;
    fCanUndo: Integer;
    fMaxUndo: Integer;
    fOwner: TmwCustomEdit;                                                      //tskurz 12/15/1998
    fUndoLocked: Boolean;                                                       //tskurz 1999-06-11
    function GetCanUndo: Integer;
    procedure SetMaxUndo(const Value: Integer);
  protected
    procedure RemoveChange(index: Integer);
  public
    constructor Create(AOwner: TmwCustomEdit);                                  //tskurz 12/15/1998
    destructor Destroy; override;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
    procedure AddChange(ChangeReason: TChangeReason; ChangeStartPos,
        ChangeEndPos: TPoint; ChangeStr: PChar; ChangeSelMode: TSelectionMode);
    function GetChange(var ChangeStartPos, ChangeEndPos: TPoint;
        var ChangeStr: PChar; var ChangeSelMode: TSelectionMode): TChangeReason;
{$IFDEF UNDO_DEBUG}                                                             //tskurz 06/11/1999
    function GetChange2(var ChangeStartPos, ChangeEndPos: TPoint;
        var ChangeStr: PChar; var ChangeSelMode: TSelectionMode; i:Integer): TChangeReason;
{$ENDIF}                                                                        //tskurz 06/11/1999
{$ELSE}                                                                         //bds 1/25/1999
    procedure AddChange(ChangeReason: TChangeReason; ChangeStartPos,
               ChangeEndPos: TPoint; ChangeStr: PChar);
    function GetChange(var ChangeStartPos, ChangeEndPos: TPoint;
               var ChangeStr: PChar): TChangeReason;
{$IFDEF UNDO_DEBUG}                                                             //tskurz 06/11/1999
    function GetChange2(var ChangeStartPos, ChangeEndPos: TPoint;
               var ChangeStr: PChar; i:Integer): TChangeReason;
{$ENDIF}                                                                        //tskurz 06/11/1999
{$ENDIF}                                                                        //bds 1/25/1999
    function GetChangeReason: TChangeReason;                                    //tskurz 12/16/1998
    procedure ClearList;                                                        //tskurz 1/4/1999
    procedure LockUndo;                                                         //tskurz 06/11/1999
    procedure UnLockUndo;                                                       //tskurz 06/11/1999
    property CanUndo: Integer read GetCanUndo;
    property MaxUndo: Integer read FMaxUndo write SetMaxUndo;
  end;
  {end}                                                                         //tskurz 12/10/1998

  TmwEditList = class(TStringList)
  private
    FOnAdded: TNotifyEvent;
    FOnDeleted: TIndexEvent;
    FOnInserted: TIndexEvent;
    FOnLoaded: TNotifyEvent;
    fOnPutted: TIndexEvent;
    fLoading: boolean;                                                          //gp 1999-03-06
  protected
    procedure Put(Index: Integer; const S: string); override;
  public
    constructor Create;                                                         //gp 1999-03-06
    function Add(const S: string): Integer; override;
    procedure Clear; override;                                                  //bds 1999-02-27
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
    procedure SetTextStr(const Value: string); override;
    procedure LoadFromFile(const FileName: string); override;                   //gp 1999-03-06
    procedure LoadFromStream(Stream: TStream); override;                        //gp 1999-03-07
    property OnAdded: TNotifyEvent read FOnAdded write FOnAdded;
    property OnDeleted: TIndexEvent read FOnDeleted write FOnDeleted;
    property OnInserted: TIndexEvent read FOnInserted write FOnInserted;
    property OnLoaded: TNotifyEvent read FOnLoaded write FOnLoaded;
    property OnPutted: TIndexEvent read FOnPutted write FOnPutted;
  published
  end;

  TmwBookMarkOpt = class(TPersistent)                                           //jdj 12/12/1998
  private
    fEnableKeys: Boolean;
    fGlyphsVisible: Boolean;
    fLeftMargin: Integer;
    fOwner: TmwCustomEdit;
    fXoffset: integer;
    procedure SetGlyphsVisible(Value: Boolean);
    procedure SetLeftMargin(Value: Integer);
    procedure SetXOffset(const Value: integer);
  public
    constructor Create(AOwner: TmwCustomEdit);
  published
    property EnableKeys: Boolean read fEnableKeys write fEnableKeys default True;
    property GlyphsVisible: Boolean read fGlyphsVisible write SetGlyphsVisible default True;
    property LeftMargin: Integer read fLeftMargin write SetLeftMargin default 2;
    property Xoffset: integer read fXoffset write SetXOffset default 12;
  end;

//  PGutterOffsets = ^TGutterOffsets;                                           //mh 1999-09-12
//  TGutterOffsets = array [0..0] of integer;                                   //mh 1999-09-12

  TmwCustomEdit = class(TCustomControl)
  private
    fBlockBegin: TPoint;
    fBlockEnd: TPoint;
    fCaretX: Integer;
    fCaretY: Integer;
    fCaretVisible: Boolean;
    fCharsInWindow: Integer;
    // Don't assign to directly, always use CharsWidth property                 //bds 12/24/1998
    fCharWidth: Integer;
    fDblClicked: Boolean;
    fFontDummy: TFont;
    fGutterWidth: Integer;
    fHalfpageScroll: Boolean;                                                   //hk 1999-05-10
{$IFDEF MWE_MBCSSUPPORT}
    fImeCount: Integer;                                                         //hk 1999-05-10
    fMBCSStepAside: Boolean;                                                    //hk 1999-05-10
{$ENDIF}
    fInserting: Boolean;
    fLines: TStrings;
    // NEVER assign to directly, always use SetLinesInWindow procedure!         //gp 1/10/1999
    fLinesInWindow: Integer;
    fLeftChar: Integer;
    // Don't assign to directly, always use MaxLeftChar property                //bds 12/24/1998
    fMaxLeftChar: Integer;
    fPaintLock: Integer;
    fNeedsRepaint: boolean;                                                     //mh 02/20/1999
    fNeedsUpdateSB: boolean;                                                    //mh 02/20/1999
    fNeedsUpdateCaret: boolean;                                                 //mh 02/20/1999
    fReadOnly: Boolean;
    fRightEdge: Integer;
    fRightEdgeColor: TColor;                                                    //kvs 1999-05-07
    FScrollBars: TScrollStyle;
    fTextHeight: Integer;
    fTextOffset: Integer;
    fTopLine: Integer;
    fHighLighter: TmwCustomHighLighter;
    fSelectedColor: TmwSelectedColor;                                           //jdj 12/09/1998
{$IFNDEF UNDO_DEBUG}                                                            //tskurz 06/11/1999
    fUndoList : TUndoList;                                                      //tskurz 12/10/1998
    fRedoList : TUndoList;                                                      //tskurz 1/4/1999
{$ENDIF}                                                                        //tskurz 06/11/1999
    fBookMarks: array[0..9] of TMark;                                           //jdj 12/10/1998 //CdeB 12/16/1998 - modified to use marks
    fDragBlockBegin: TPoint;                                                    //ked 12/10/1998
    fDragBlockEnd: TPoint;                                                      //ked 12/10/1998
    fMouseDownX: integer;                                                       //ked 12/10/1998
    fMouseDownY: integer;                                                       //ked 12/10/1998
    fWaitForDragging: boolean;                                                  //gp 12/12/1998
    fBookMarkOpt: TmwBookMarkOpt;                                               //jdj 12/12/1998
    fOnPaint: TPaintEvent;                                                      //jdj 12/12/1998
    fOnChange: TNotifyEvent;                                                    //tskurz 12/15/1998
    fSelectionChange: TNotifyEvent;                                             //WvdM 1999-05-10
    fBorderStyle: TBorderStyle;                                                 //bds 12/16/1998
    fHideSelection: boolean;                                                    //bds 12/16/1998
    fScrollPastEOL: boolean;                                                    //bds 12/16/1998
    fMouseWheelAccumulator: integer;                                            //ajb 1999-06-13
{$IFNDEF MWE_DRAW_NOBMP}
//    fTextBM: TBitMap;                                                           //WvdM 12/18/1998 //mh 1999-09-12
{$ENDIF}
    fOverwriteCaret: TCaretType;                                                //bds 12/17/1998
    fInsertCaret: TCaretType;                                                   //bds 12/17/1998
    fCaretOffset: TPoint;                                                       //bds 12/17/1998
    fOnProcessCommand: TProcessCommandEvent;                                    //bds 12/20/1998
    fOnProcessUserCommand: TProcessCommandEvent;                                //bds 12/20/1998
    fKeyStrokes: TmwKeyStrokes;                                                 //bds 12/23/1998
    fModified: Boolean;                                                         //CdeB 12/16/1998
//    fETODist: PIntArray;                                                        //bds 12/24/1998
    fMarkList: TMarkList;                                                       //CdeB 12/16/1998
    fBookmarkImages: TImageList;                                                //CdeB 12/16/1998, //gp 1/2/1999 - renamed
    fBookMarksGlyphs: array [0..9] of TBitmap;                                  //CdeB 12/16/1998
    fOnPlaceMark: TPlaceMarkEvent;                                              //CdeB 12/16/1998, //gp 1/9/1999 - renamed
//    fGutterOffsets: PGutterOffsets;                                             //gp 1/10/1999 //mh 1999-09-12
    fExtraLineSpacing: integer;                                                 //gp 1/10/1999
    fOnCommandDone: TNotifyEvent;                                               //DG 1/22/1999
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
    fSelectionMode: TSelectionMode;
{$ENDIF}                                                                        //bds 1/25/1999
    fOnPrintStatus: TPrintStatusEvent;                                          //bds 1/24/1999
    fAutoindent: boolean;                                                       //tb 1999-05-07
    fWantTabs: boolean;								//ar 1999-05-10
    fTabIndent: integer;							//ar 1999-05-10
    // rect describing invalid lines and columns, 1-based
//    fInvalidLinesCols: TRect;                                                   //mh 1999-09-12
    fInScrollLoop: boolean;                                                     //mh 1999-05-12
    fGutter: TmwGutter;                                                         //mh 1999-05-12
    fClipboardFormats: TmwEditExporters;                                        //ajb 1999-06-16
    fScrollHint: THintWindow;                                                   //ra 1999-08-19
    fShowScrollHint: boolean;                                                   //mh 1999-08-20
    fTabsToSpaces: boolean;                                                     //mh 1999-09-12
    fTabWidth: Cardinal;                                                        //mh 1999-09-12
    fOnSpecialLineColors: TSpecialLineColorsEvent;                              //mh 1999-09-12
    fTextDrawer: TheTextDrawer;                                                 //th 1999-09-16
    fIsLinesChanging: Boolean;                                                  //th 1999-09-19
    fInvalidateRect: TRect;                                                     //th 1999-09-19

    procedure ComputeCaret(X, Y: Integer);
    function GetBlockBegin: TPoint;
    function GetBlockEnd: TPoint;
    function GetCaretX: Integer;
    function GetCaretY: Integer;
    function GetFont: TFont;
    function GetLeftChar: Integer;
    function GetLineCount: Integer;
    function GetLineText: String;
    function GetSelAvail: Boolean;
    function GetText: String;
    function GetTopLine: Integer;
    procedure FontChanged(Sender: TObject);
    function LeftSpaces(Line: String): Integer;
    procedure LinesChanging(Sender: TObject);                                   //th 1999-09-19
    procedure LinesChanged(Sender: TObject);
    procedure SetBlockBegin(Value: TPoint);
    procedure SetBlockEnd(Value: TPoint);
    procedure SetWordBlock(Value: TPoint);
    procedure SetCaretX(Value: Integer);
    procedure SetCaretY(Value: Integer);
    procedure SetGutterWidth(Value: Integer);
    procedure SetFont(const Value: TFont);
    procedure SetLeftChar(Value: Integer);
    procedure SetLines(Value: TStrings);
    procedure SetLineText(Value: String);
    procedure SetScrollBars(const Value: TScrollStyle);
    procedure SetText(const Value: String);
    procedure SetTopLine(Value: Integer);
    procedure UpdateCaret;
    procedure UpdateScrollBars(Force: boolean);                                 //mh 02/20/1999
    function GetSelText: String;
    procedure SetSelText(const Value: String);
//    procedure ScanFrom(Index: Integer);                                       //th 1999-09-15
    function ScanFrom(Index: integer): integer;                                 
//    procedure PaintHighLighted(TextCanvas: TCanvas);                            //bds 12/27/1998 //mh 1999-05-12
    function GetCanUndo: Boolean;                                               //tskurz 12/10/1998
    function GetCanRedo: Boolean;                                               //tskurz 1/4/1999
    procedure SetRightEdge(Value: Integer);                                     //jdj 12/12/1998
    procedure SetRightEdgeColor(Value: TColor);                                 //kvs 1999-05-07
    procedure SetMaxUndo(const Value: Integer);
    function GetMaxUndo: Integer;                                               //tskurz 12/14/1998
    procedure SetHighlighter(const Value: TmwCustomHighLighter);                //gp 12/16/1998
    procedure SetBorderStyle(Value: TBorderStyle);                              //bds 12/16/1998
    procedure SetHideSelection(const Value: boolean);                           //bds 12/16/1998
    procedure SetInsertMode(const Value: boolean);                              //bds 12/16/1998
    procedure SetScrollPastEOL(const Value: boolean);                           //bds 12/16/1998
    procedure SetInsertCaret(const Value: TCaretType);                          //bds 12/17/1998
    procedure SetOverwriteCaret(const Value: TCaretType);                       //bds 12/17/1998
    function GetCaretXY: TPoint;                                                //bds 12/17/1998
    procedure SetCaretXY(const Value: TPoint);                                  //bds 12/17/1998
    procedure SetKeystrokes(const Value: TmwKeyStrokes);                        //bds 12/23/1998
    procedure SetMaxLeftChar(Value: integer);                                   //bds 12/24/1998 //mh 1999-08-21
//    procedure SetCharWidth(const Value: integer);                               //bds 12/24/1998 //mh 1999-09-12
//    procedure SetLinesInWindow(const Value: integer);                           //gp 1/10/1999 //mh 1999-09-12
    procedure SetExtraLineSpacing(const Value: integer);
    procedure SetSelTextExternal(const Value: String);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
    procedure SetSelectionMode(const Value: TSelectionMode);
{$ENDIF}                                                                        //bds 1/25/1999
    procedure SetGutter(const Value: TmwGutter);
//    procedure UpdateGutter;                                                   //mh 1999-09-12
    procedure SelectedColorsChanged(Sender: TObject);                           //mh 1999-09-12
    procedure GutterChanged(Sender: TObject);                                   //mh 1999-09-12
{$IFDEF MWE_MBCSSUPPORT}
    Procedure WMImeComposition(Var Msg: TMessage); Message WM_IME_COMPOSITION;  //hk 1999-05-10
    Procedure WMImeNotify(Var Message: TMessage); Message WM_IME_NOTIFY;        //hk 1999-05-10
{$ENDIF}
    procedure SetWantTabs(const Value: boolean);                                //ar 1999-05-10
    procedure SetTabIndent(const Value: integer);                               //ar 1999-05-10
    procedure LockUndo;                                                         //tskurz 06/11/1999
    procedure UnLockUndo;                                                       //tskurz 06/11/1999
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DecPaintLock;
    procedure HideCaret;
    procedure IncPaintLock;
    procedure ListAdded(Sender: TObject);
    procedure ListDeleted(Index: Integer);
    procedure ListInserted(Index: Integer);
    procedure ListLoaded(Sender: TObject);
    procedure ListPutted(Index: Integer);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
{begin}                                                                         //mh 1999-09-12
//    procedure PaintGutter(TextCanvas: TCanvas; AClip: TRect); virtual;
//    procedure PaintTextLines(TextCanvas: TCanvas; AClip: TRect); virtual;
    procedure PaintGutter(AClip: TRect; FirstLine, LastLine: integer); virtual;
    procedure PaintTextLines(AClip: TRect; FirstLine, LastLine,
                             FirstCol, LastCol: integer); virtual;
{end}                                                                           //mh 1999-09-12
    procedure Paint; override;
    procedure SetName(const Value: TComponentName); override;
    procedure ShowCaret;
    procedure Loaded; override;                                                 //jdj 12/12/1998
    function CoorToIndex(CPos: TPoint): integer;                                //ked 12/10/1998
    function IndexToCoor(ind: integer): TPoint;                                 //ked 12/10/1998
    procedure DragOver(Source: TObject; X, Y: Integer;                          //ked 12/10/1998
                       State: TDragState; var Accept: Boolean); override;
    procedure InitializeCaret;                                                  //bds 12/16/1998
    procedure MarkListChange(Sender: TObject);                                  //CdeB 12/16/1998
    procedure SetBookmarkImages(const Value: TImageList);                       //CdeB 12/16/1998
    procedure WMEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMHScroll(var Message: TWMScroll); message WM_HSCROLL;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMVScroll(var Message: TWMScroll); message WM_VSCROLL;
    procedure WMMouseWheel(var Msg: TMessage); message WM_MOUSEWHEEL;           //woza 05/07/1999
    procedure ProcessCommand(var Command: TmwEditorCommand; var AChar: char;
                             Data: pointer); virtual;                           //bds 12/23/1998
    // If the translations requires Data, memory will be allocated for it via a
    // GetMem call.  The client must call FreeMem on Data if it is not NIL.
    function TranslateKeyCode(Code: word; Shift: TShiftState;
                          var Data: pointer): TmwEditorCommand;                 //bds 12/23/1998
    procedure SelectionChange; virtual;                                         //WvdM 1999-05-10
    property PaintLock: Integer read fPaintLock;
    property CharWidth: integer read fCharWidth; // write SetCharWidth;             //bds 12/24/1998 //mh 1999-09-12
    property MaxLeftChar: integer read fMaxLeftChar write SetMaxLeftChar;       //bds 12/24/1998
//    function CreateSelectionRgn: HRGN;                                          //bds 1/25/1999 //mh 1999-09-12
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
    procedure SetSelTextPrimitive(PasteMode: TSelectionMode; Value: PChar;
       Tag: PInteger);
{$IFDEF MWE_MBCSSUPPORT}                                                        //th 1999-09-21
    procedure MBCSGetSelRangeInLineWhenColumnSelectionMode(const s: string;
      var ColFrom, ColTo: Integer);
{$ENDIF}
{$ENDIF}                                                                        //bds 1/25/1999
    procedure PrintStatus(Status: TmwPrintStatus; PageNumber: integer;
       var Abort: boolean); virtual;                                            //bds 1/24/1999
{begin}                                                                         //mh 1999-05-12
    // note: FirstLine and LastLine don't need to be in correct order
    procedure InvalidateGutter(FirstLine, LastLine: integer);
    procedure InvalidateLines(FirstLine, LastLine: integer);
{end}                                                                           //mh 1999-05-12
  public
{$IFDEF UNDO_DEBUG}                                                             //tskurz 06/11/1999
    fUndoList : TUndoList;                                                      //tskurz 06/11/1999
    fRedoList : TUndoList;                                                      //tskurz 06/11/1999
{$ENDIF}                                                                        //tskurz 06/11/1999
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure WndProc(var msg: TMessage); override;
    procedure DragDrop(Source: TObject; X, Y: Integer);                         //ked 12/10/1998
                override;
    function CaretXPix: Integer;                                                //tdb 1999-05-07
    function CaretYPix: Integer;                                                //tdb 1999-05-07
    procedure DoCopyToClipboard(const SText: string);                           //th 1999-09-22
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure PasteFromClipboard;
    procedure SelectAll;
    procedure ClearAll;                                                         //bds 12/20/1998
    procedure Undo;                                                             //tskurz 12/10/1998
    procedure Redo;                                                             //tskurz 1/4/1999
    procedure ClearBookMark(BookMark: Integer);                                 //jdj 12/10/1998, //CdeB 12/16/1998 - removed, //gp 12/31/1998 - reinstated
    procedure GotoBookMark(BookMark: Integer);                                  //jdj 12/10/1998, //CdeB 12/16/1998 - removed, //gp 12/31/1998 - reinstated
    procedure SetBookMark(BookMark: Integer; X: Integer; Y: Integer);           //jdj 12/10/1998, //CdeB 12/16/1998 - removed, //gp 12/31/1998 - reinstated
    function GetBookMark(BookMark: integer; var X, Y: integer): boolean;        //gp 1/10/1999
    function IsBookmark(BookMark: integer): boolean;                            //gp 1/10/1999
    procedure Notification(AComponent: TComponent;                              //gp 12/16/1998
                Operation: TOperation); override;
    procedure EnsureCursorPosVisible;                                           //bds 12/17/1998
    procedure CommandProcessor(Command: TmwEditorCommand; AChar: char;
                               Data: pointer); virtual;                         //bds 12/23/1998
    function NextWordPos: TPoint; virtual;
    function LastWordPos: TPoint; virtual;
    procedure SetDefaultKeystrokes; virtual;                                    //bds 12/23/1998
    procedure BeginUpdate;                                                      //jdj 12/27/1998
    procedure EndUpdate;                                                        //jdj 12/27/1998
    function GetSelEnd: integer;
    function GetSelStart: integer;
    procedure SetSelEnd(const Value: integer);
    procedure SetSelStart(const Value: integer);
    procedure ClearUndo;                                                        //gp 1/10/1999
    procedure RefreshAllTokens;                                                 //aj 1999-02-22
    // Pass NIL in PrintFont to use editor's current font.                      //bds 1/24/1999
    procedure Print(PrintFont: TFont; Options: TmwPrintOptions);                //bds 1/24/1999
    procedure SaveStreamToClipboardFormat(const ClipboardFormat: Word;          //ajb 1999/06/16
                Stream: TStream);
    procedure SaveToFile(const FileName: string);                               //ajb 1999/06/16
    procedure ExportToFile(const FileName: string; Format: TmwEditExporter);    //ajb 1999/06/16
    procedure ExportToClipboard(Format: TmwEditExporter);                       //ajb 1999/06/16
    procedure CopyToClipboardEx;                                                //ajb 1999/06/16

    property SelAvail: Boolean read GetSelAvail;                                //bds 1/24/1999, moved from proteced section
    property BlockBegin: TPoint read GetBlockBegin write SetBlockBegin;
    property BlockEnd: TPoint read GetBlockEnd write SetBlockEnd;
    property CaretX: Integer read GetCaretX write SetCaretX;
    property CaretY: Integer read GetCaretY write SetCaretY;
    property CaretXY: TPoint read GetCaretXY write SetCaretXY;                  //bds 12/17/1998
    property ClipboardFormats: TmwEditExporters read FClipboardFormats          //ajb 1999-06-16
               write FClipboardFormats;
    property LineHeight: integer read fTextHeight;                              //gp 1999-05-17
    property LineText: String read GetLineText write SetLineText;               //gp 12/30/1998 - moved from published to public
    property CharsInWindow: Integer read fCharsInWindow;
    property LinesInWindow: Integer read fLinesInWindow;
    property SelText: String read GetSelText write SetSelTextExternal;          //tskurz 1/7/1999 - new Set
    property Text: String read GetText write SetText;
    property Modified: Boolean read fModified write fModified;                  //CdeB 12/16/1998
    property Marks: TMarkList read fMarkList;                                   //CdeB 12/16/1998

    // find/replace
  private
    fTSearch: TmwEditSearch;
    fOnReplaceText: TReplaceTextEvent;
  public
    function SearchReplace(const ASearch, AReplace: string;
                           AOptions: TmwSearchOptions): integer;
  published
    property OnReplaceText: TReplaceTextEvent read fOnReplaceText
                                              write fOnReplaceText;

  published
    property Align;
    property Autoindent: boolean read fAutoindent write fAutoindent             //td 1999-05-07
      default true;
    {begin}                                                                     //bds 12/16/1998
    {$IFDEF MWE_COMPILER_4_UP}
    property Anchors;
    property Constraints;
    {$ENDIF}
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle
               default bsSingle;
    {end}                                                                       //bds 12/16/1998
    property BookMarkOptions: TmwBookMarkOpt                                    //jdj 12/12/1998
               read fBookMarkOpt write fBookMarkOpt;
    property CanUndo: Boolean read GetCanUndo;
    property CanRedo: boolean read GetCanRedo;                                  //tskurz 1/4/1999
    property Color;
    property Ctl3D;
    property Enabled;
    property ExtraLineSpacing: integer                                          //gp 1/10/1999
               read fExtraLineSpacing write SetExtraLineSpacing default 0;
    property Font: TFont read GetFont write SetFont;
    property Gutter: TmwGutter read fGutter write SetGutter;                    //mh 1999-05-12

    property HalfpageScroll: Boolean Read fHalfpageScroll Write fHalfpageScroll //hk 1999-05-10
               Default False;                                                   //hk 1999-05-10
    property Height;
    property HideSelection: boolean read fHideSelection write SetHideSelection  //bds 12/16/1998
               default false;
    property HighLighter: TmwCustomHighLighter                                  //gp 12/16/1998 - added Set
               read fHighLighter write SetHighlighter;
    property BookmarkImages: TImageList                                         //CdeB 12/16/1998, //gp 1/2/1999 - renamed
               read fBookmarkImages write SetBookmarkImages;
    property InsertCaret: TCaretType read FInsertCaret write SetInsertCaret     //bds 12/17/1998
               default ctVerticalLine;
    property InsertMode: boolean read fInserting write SetInsertMode            //bds 12/16/1998
               default true;
    property Keystrokes: TmwKeyStrokes                                          //bds 12/23/1998
               read FKeystrokes write SetKeystrokes;
    property LeftChar: Integer read GetLeftChar write SetLeftChar;
    property Lines: TStrings read fLines write SetLines;
    property LineCount: Integer read GetLineCount;
    property MaxUndo: Integer read GetMaxUndo write SetMaxUndo;                 //tskurz 12/14/1998
    property Name;
    property OverwriteCaret: TCaretType read FOverwriteCaret                    //bds 12/17/1998
               write SetOverwriteCaret default ctBlock;
    property ParentColor;
    property ParentCtl3D;                                                       //bds 12/16/1998
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly: Boolean read fReadOnly write fReadOnly;
    property RightEdge: Integer read fRightEdge write SetRightEdge default 80;  //jdj 12/12/1998 added Set-Default
    property RightEdgeColor: TColor                                             //kvs 12/12/1998
               read fRightEdgeColor write SetRightEdgeColor default clSilver;
    property ShowHint;
    property ScrollBars: TScrollStyle
               read FScrollBars write SetScrollBars default ssBoth;
    property ScrollPastEOL: boolean read FScrollPastEOL write SetScrollPastEOL  //bds 12/16/1998
               default true;
    property ShowScrollHint: boolean read fShowScrollHint write fShowScrollHint //mh 1999-08-20
               default TRUE;
    property SelectedColor: TmwSelectedColor                                    //jdj 12/09/1998
               read FSelectedColor write FSelectedColor;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
    property SelectionMode: TSelectionMode
               read FSelectionMode write SetSelectionMode default smNormal;
{$ENDIF}                                                                        //bds 1/25/1999
    property TabOrder;
    property TabIndent: integer read fTabIndent write SetTabIndent;		//ar 1999-05-10
    property TabStop default True;                                              //jdj 12/12/1998 Added Default
    property Tag;
    property TopLine: Integer read GetTopLine write SetTopLine;
    property Visible;
    property WantTabs: boolean read fWantTabs write SetWantTabs;		//ar 1999-05-10
    property Width;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;             //tskurz 12/15/1998
    property OnClick;
    property OnCommandDone: TNotifyEvent                                        //DG 1/22/1999
               read fOnCommandDone write fOnCommandDone;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;                                                       //levin 1/6/1999
    property OnMouseMove;                                                       //levin 1/6/1999
    property OnMouseUp;                                                         //levin 1/6/1999
    property OnPaint: TPaintEvent read fOnPaint write fOnPaint;                 //jdj 12/12/1998
    property OnPlaceBookmark: TPlaceMarkEvent                                   //CdeB 12/16/1998
               read FOnPlaceMark write FOnPlaceMark;
    property OnPrintStatus: TPrintStatusEvent
               read FOnPrintStatus write FOnPrintStatus;                        //bds 1/24/1999
    property OnProcessCommand: TProcessCommandEvent                             //bds 12/20/1998
               read FOnProcessCommand write FOnProcessCommand;
    property OnProcessUserCommand: TProcessCommandEvent                         //bds 12/20/1998
               read FOnProcessUserCommand write FOnProcessUserCommand;
    property OnSelectionChange: TNotifyEvent
               read fSelectionChange write fSelectionChange;                    //WvdM 1999-05-10
    property OnSpecialLineColors: TSpecialLineColorsEvent                       //mh 1999-09-12
               read fOnSpecialLineColors write fOnSpecialLineColors;
    property OnStartDrag;
  end;

procedure Register;

implementation

{$R mwCustomEdit.RES}                                                           //jdj 12/10/1998

uses mwExport, mwHTMLExport, mwRTFExport;                                       //ajb 1999-06-16

procedure Register;
begin
  RegisterComponents('mw', [TmwCustomEdit]);
end;

function maxPoint(P1, P2: TPoint): TPoint;                                      //tskurz 12/14/1998
begin
{begin}                                                                         //mh 1999-06-13
// old lines deleted
  Result := P1;
  if (P2.y > P1.y) or ((P2.y = P1.y) and (P2.x > P1.x)) then Result := P2;
{end}                                                                           //mh 1999-06-13
end;

function minPoint(P1, P2: TPoint): TPoint;                                      //tskurz 12/14/1998
begin
{begin}                                                                         //mh 1999-06-13
// old lines deleted
  Result := P1;
  if (P2.y < P1.y) or ((P2.y = P1.y) and (P2.x < P1.x)) then Result := P2;
{end}                                                                           //mh 1999-06-13
end;

Function Roundoff(X: Extended): Longint;                                        //hk 1999-05-10
Begin
  If (x >= 0) Then Begin
    Result := Trunc(x + 0.5)
  End Else Begin
    Result := Trunc(x - 0.5);
  End;
End;

{ TmwEditList }

function TmwEditList.Add(const S: string): Integer;
begin
  BeginUpdate;
  Result := inherited Add(S);
  if Assigned(FOnAdded) then FOnAdded(Self);
  EndUpdate;
end;

procedure TmwEditList.Clear;                                                    //bds 1999-02-27
begin
  inherited Clear;
  if not fLoading and (Count = 0) then Add('');                                 //gp 1999-03-06 //mh 1999-05-12
end;

constructor TmwEditList.Create;                                                 //gp 1999-03-06
begin
  inherited Create;
  fLoading := false;
end;

procedure TmwEditList.Delete(Index: Integer);
begin
  BeginUpdate;
  inherited Delete(Index);
  if Assigned(FOnDeleted) then fOnDeleted(Index);
  EndUpdate;
end;

procedure TmwEditList.Insert(Index: Integer; const S: string);
begin
  BeginUpdate;
  inherited Insert(Index, S);
  if Assigned(FOnInserted) then fOnInserted(Index);
  EndUpdate;
end;

procedure TmwEditList.LoadFromFile(const FileName: string);                     //gp 1999-03-06
begin
  fLoading := true; // prevent triggering Add('') in .Clear
  try
    inherited LoadFromFile(FileName);
  finally fLoading := false; end;
end;
               
procedure TmwEditList.LoadFromStream(Stream: TStream);                          //gp 1999-03-07
begin
  fLoading := true; // prevent triggering Add('') in .Clear
  try
    inherited LoadFromStream(Stream);
  finally fLoading := false; end;
end;

procedure TmwEditList.Put(Index: Integer; const S: string);
begin
  BeginUpdate;
  inherited Put(Index, S);
  if Assigned(FOnPutted) then fOnPutted(Index);
  EndUpdate;
end;

procedure TmwEditList.SetTextStr(const Value: string);
begin
  BeginUpdate;
  inherited SetTextStr(Value);
  if Assigned(FOnLoaded) then FOnLoaded(Self);
  EndUpdate;
end;

{ TmwCustomEdit }

procedure TmwCustomEdit.ComputeCaret(X, Y: Integer);
{$IFDEF MWE_MBCSSUPPORT}
Var                                                                             //hk 1999-05-10
  pt: TPoint;
  s: String;
  f: Single;                                                                    //th 1999-09-15
{$ENDIF}
begin
{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
  f := (X + LeftChar * fCharWidth - fGutterWidth - 2) / fCharWidth;             //th 1999-09-15
  pt := Point(Roundoff(f), Y div fTextHeight + TopLine);
  If ((pt.Y - 1) < Lines.Count) Then Begin
    s := Lines[pt.Y - 1];
{begin}                                                                         //th 1999-09-15
(*
    If (Length(s) > CaretX) Then Begin
      Case ByteType(s, pt.X) Of
      mbTrailByte:
        Begin
          pt.X := (pt.X + 1);
        End;
      End;
    End;
*)
    if (Length(s) >= pt.x) and (ByteType(s, pt.X) = mbTrailByte) then
      if Frac(f) >= 0.5 then
        Dec(pt.X)
      else
        Inc(pt.X);
{end}                                                                           //th 1999-09-15        
  End;
  fMBCSStepAside := False;

  CaretXY := pt;
{$ELSE}
  CaretXY := Point(                                                             //hk 1999-05-10
    Roundoff((X + LeftChar * fCharWidth - FGutterWidth - 2) / fCharWidth),
    Y div fTextHeight + TopLine
  );
{$ENDIF}
end;

//bds: 1/25/1999
// Rewrite to support new SelectionMode property.
procedure TmwCustomEdit.DoCopyToClipboard(const SText: string);                 //th 1999-09-22
{$IFDEF MWE_SELECTION_MODE}
var
  Mem: HGLOBAL;
  P: PChar;
  SLen: integer;
  Failed: boolean;
begin
    if SText <> '' then
  begin
    Failed := TRUE;  // assume the worst.
    SLen := Length(SText);                                                      //ajb 1999-06-16
    // Open and Close are the only TClipboard methods we use because TClipboard
    // is very hard (impossible) to work with if you want to put more than one
    // format on it at a time.
    Clipboard.Open;
    try
      // Clear anything already on the clipboard.
      EmptyClipboard;
      // Put it on the clipboard as normal text format so it can be pasted into
      // things like notepad or Delphi.
      Mem := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, SLen + 1);
      if Mem <> 0 then
      begin
        P := GlobalLock(Mem);
        try
          if P <> NIL then
          begin
          // According to Delphi 3 help file, StrPCopy will translate
          // only 255 bytes at the maximum.
//            StrPCopy(P, SText);                                               //th 1999-09-22
            Move(PChar(SText)^, P^, SLen + 1);                                  //th 1999-09-22
            // Put it on the clipboard in text format
            Failed := SetClipboardData(CF_TEXT, Mem) = 0;
          end;
        finally
          GlobalUnlock(Mem);
        end;
      end;
      // Don't free Mem!  It belongs to the clipboard now, and it will free it
      // when it is done with it.

      if not Failed then
      begin
        // Copy it in our custom format so we know what kind of block it is.
        // That effects how it is pasted in.
        Mem := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, SLen +
           SizeOf(TSelectionMode) + 1);

        P := GlobalLock(Mem);
        try
          if P <> NIL then
          begin
            // Our format:  TSelectionMode value followed by text.
            PSelectionMode(P)^ := SelectionMode;
            inc(P, SizeOf(TSelectionMode));
//            StrPCopy(P, SText);                                               //th 1999-09-22
            Move(PChar(SText)^, P^, SLen + 1);                                  //th 1999-09-22
            Failed := SetClipboardData(mwEditClipboardFormat, Mem) = 0;
          end;
        finally
          GlobalUnlock(Mem);
        end;
        // Don't free Mem!  It belongs to the clipboard now, and it will free it
        // when it is done with it.
      end;
    finally
      Clipboard.Close;
      if Failed then
        raise EmwEditError.Create('Clipboard copy operation failed');
    end;
  end;
{$ELSE}
{end}                                                                           //bds 1/25/1999
begin
  if SelAvail then ClipBoard.SetTextBuf(PChar(SelText));
{$ENDIF}                                                                        //bds 1/25/1999
end;

procedure TmwCustomEdit.CopyToClipboard;
// (moved the copy processing to DoCopyToClipboard.)                            //th 1999-09-22
var
  SText: string;
begin
  if SelAvail then
  begin
    SText := SelText;
    DoCopyToClipboard(SText);
  end;
end;

procedure TmwCustomEdit.CutToClipboard;
var
  SText: string;                                                                //th 1999-09-22
begin
  if SelAvail then
  begin
    SText := SelText;                                                           //th 1999-09-22
    DoCopyToClipboard(SText);                                                   //th 1999-09-22
{begin}                                                                         //bds 1/25/1999
//    ClipBoard.SetTextBuf(PChar(SelText));
//    CopyToClipboard;
{$IFDEF MWE_SELECTION_MODE}
//    FUndoList.AddChange(mwcrDelete,fBlockBegin,fBlockEnd,PChar(SelText),
    FUndoList.AddChange(mwcrDelete,fBlockBegin,fBlockEnd,PChar(SText),          //th 1999-09-22
       SelectionMode);
{$ELSE}
//    FUndoList.AddChange(mwcrDelete,fBlockBegin,fBlockEnd,PChar(SelText));       //tskurz 12/10/1998
    FUndoList.AddChange(mwcrDelete,fBlockBegin,fBlockEnd,PChar(SText));         //th 1999-09-22
{$ENDIF}
    LockUndo;                                                                   //tskurz 06/11/1999
    SelText := '';
    UnLockUndo;                                                                 //tskurz 06/11/1999
{end}                                                                           //bds 1/25/1999
  end;
end;

constructor TmwCustomEdit.Create(AOwner: TComponent);
var
  i: Integer;                                                                   //jdj 12/10/1998
begin
  fLines := TmwEditList.Create;
  fFontDummy := TFont.Create;
  fUndoList := TUndoList.Create(self);                                          //tskurz 12/15/1998
  fRedoList := TUndoList.Create(self);                                          //tskurz 1/4/1999
  inherited Create(AOwner);
{$IFNDEF MWE_DRAW_NOBMP}
//  fTextBM := TBitmap.Create;                                                    //WvdM 12/18/1998 //mh 1999-09-12
{$ENDIF}  
  {$IFDEF MWE_COMPILER_4_UP}                                                    //gp 11/09/1998, //mt 12/16/1998
    DoubleBuffered := false;                                                    //gp 12/30/1998 - disabled as we are doing buffering on our own
  {$ENDIF}
  if not (csDesigning in ComponentState) then fLines.Add('');                   //jdj 12/08/1998
  TmwEditList(fLines).OnAdded := ListAdded;
  TmwEditList(fLines).OnDeleted := ListDeleted;
  TmwEditList(fLines).OnInserted := ListInserted;
  TmwEditList(fLines).OnLoaded := ListLoaded;
  TmwEditList(fLines).OnPutted := ListPutted;
  fSelectedColor := TmwSelectedColor.Create;                                    //jdj 12/09/1998 //mh 1999-09-12
  fSelectedColor.OnChange := SelectedColorsChanged;                             //mh 1999-09-12
  fBookMarkOpt := TmwBookMarkOpt.Create(Self);                                  //jdj 12/12/1998
  fCharsInWindow := 10;
// fRightEdge has to be set before FontChanged is called for the first time
  fRightEdge := 80;                                                             //gp 1/2/1999
  fGutter := TmwGutter.Create;                                                  //mh 1999-09-12
  fGutter.OnChange := GutterChanged;                                            //mh 1999-09-12
  fGutterWidth := fGutter.Width;                                                //mh 1999-05-12
  fTextOffset := fGutterWidth + 2;
  ControlStyle := ControlStyle + [csOpaque, csSetCaption];
  Height := 150;
  Width := 200;
  Cursor := crIBeam;
  Color := clWindow;
//  fCaretX := 0;                                                               //mh 1999-05-12 - done by Create
//  fCaretY := 0;                                                               //mh 1999-05-12 - done by Create
//  fCaretOffset := Point(0,0);                                                   //bds 12/17/1998 //mh 1999-05-12 - done by Create
//  fGutterColor := clBtnFace;                                                  //mh 1999-05-12
  fFontDummy.Name := 'Courier New';
  fFontDummy.Size := 10;
{$IFDEF MWE_COMPILER_3_UP}                                                      //th 1999-09-16
  fFontDummy.CharSet := DEFAULT_CHARSET;
{$ENDIF}
  fTextDrawer := TheTextDrawer.Create([fsBold], fFontDummy);                    //th 1999-09-16
  Font.Assign(fFontDummy);
  Font.OnChange := FontChanged;
  FontChanged(nil);
  ParentFont := False;
  ParentColor := False;
  TabStop := True;                                                              //jdj 12/12/1998
  TStringList(Lines).OnChanging := LinesChanging;                               //th 1999-09-21
  TStringList(Lines).OnChange := LinesChanged;
  fInserting := True;
  fMaxLeftChar := 1024;                                                          //bds 12/24/1998 //mh 1999-09-12
//  fPaintLock := 0;                                                            //mh 1999-05-12 - done by Create
//  fReadOnly := False;                                                         //mh 1999-05-12 - done by Create
  fScrollBars := ssBoth;
//  fTopLine := 0;                                                              //mh 1999-05-12 - done by Create
//  fBlockBegin := (Point(0, 0));                                               //mh 1999-05-12 - done by Create
//  fBlockEnd := (Point(0, 0));                                                 //mh 1999-05-12 - done by Create
  for i := 0 to 9 do begin                                                      //jdj 12/10/1998
    fBookMarksGlyphs[i] := TBitmap.Create;                                      //CdeB 12/16/1998
    fBookMarksGlyphs[i].LoadFromResourceName(HInstance, 'MARK_' + IntToStr(i)); //CdeB 12/16/1998
  end;
  fBorderStyle := bsSingle;                                                     //bds 12/16/1998
//  fHideSelection := false;                                                      //bds 12/16/1998 //mh 1999-05-12 - done by Create
  fScrollPastEOL := true;                                                       //bds 12/16/1998
  fInsertCaret := ctVerticalLine;                                               //bds 12/17/1998
  fOverwriteCaret := ctBlock;                                                   //bds 12/17/1998
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
  FSelectionMode := smNormal;
{$ENDIF}                                                                        //bds 1/25/1999
  fKeystrokes := TmwKeyStrokes.Create(Self);                                    //bds 12/23/1998
  fMarkList:= TMarkList.Create(self);                                           //CdeB 12/16/1998, //gp 1/9/1999
  fMarkList.OnChange:= MarkListChange;                                          //CdeB 12/16/1998
  SetDefaultKeystrokes;                                                         //bds 12/23/1998
  fAutoindent := true;                                                          //tb 1999-05-07
  fRightEdgeColor := clSilver;                                                  //kvs 1999-05-07
  fHalfpageScroll := False;                                                     //hk 1999-05-10
{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
  fImeCount := 0;
  fMBCSStepAside := False;
{$ENDIF}
  fWantTabs := False;                                                           //ar 1999-05-10
  fTabIndent := 4;                                                              //ar 1999-05-10
  fScrollHint := HintWindowClass.Create(Self);                                  //ra 1999-08-19
  fShowScrollHint := TRUE;                                                      //mh 1999-08-20
  fTabsToSpaces := TRUE;                                                        //mh 1999-09-12
  fTabWidth := 8;                                                               //mh 1999-09-12
  // find / replace
  fTSearch := TmwEditSearch.Create;
end;

procedure TmwCustomEdit.CreateParams(var Params: TCreateParams);
const
  ScrollBar: array[TScrollStyle] of DWORD = (0, WS_HSCROLL, WS_VSCROLL,
    WS_HSCROLL or WS_VSCROLL);
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);                  //bds 12/16/1998
begin
  inherited CreateParams(Params);
  with Params do
  begin
    {begin}                                                                     //bds 12/16/1998
    Style := Style or ScrollBar[FScrollBars] or BorderStyles[fBorderStyle]
                   or WS_CLIPCHILDREN;
    if NewStyleControls and Ctl3D and (fBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
    {end}                                                                       //bds 12/16/1998
  end;
end;

procedure TmwCustomEdit.DecPaintLock;
begin
  dec(fPaintLock);
  if (PaintLock = 0) and (Parent <> NIL) then
  begin
    if fNeedsUpdateSB then UpdateScrollBars(FALSE);
    // note: Paint does a UpdateCaret().  Order is important!
//    if fNeedsRepaint then Paint;                                              //th 1999-09-15
    if fNeedsRepaint then Update;
    if fNeedsUpdateCaret then UpdateCaret;
  end;
end;

destructor TmwCustomEdit.Destroy;
var
  i: Integer;                                                                   //jdj 12/10/1998
begin
  fHighlighter := nil;                                                          //mh 1999-09-12
  fKeyStrokes.Free;                                                             //bds 12/23/1998
  fFontDummy.Free;
  Lines.Free;
  fSelectedColor.Free;                                                          //jdj 12/09/1998
  fBookMarkOpt.Free;                                                            //jdj 12/12/1998
  fBookmarkImages := nil;                                                       //CdeB 12/16/1998, //gp 1/2/1999
  fMarkList.Free;                                                               //CdeB 12/16/1998
  fUndoList.Free;                                                               //tskurz 12/10/1998
  fRedoList.Free;                                                               //tskurz 1/4/1999
  for i := 0 to 9 do                                                            //jdj 12/10/1998
//  fBookMarks[i].Glyph.Free;                                                   //CdeB 12/16/1998 - removed
    fBookMarksGlyphs[i].Free;                                                   //CdeB 12/16/1998
{$IFNDEF MWE_DRAW_NOBMP}
//  fTextBM.Free;                                                                 //WvdM 12/18/1998 //mh 1999-09-12
{$ENDIF}
//  FreeMem(fETODist);                                                            //bds 12/24/1998 //mh 1999-09-12
//  if assigned(fGutterOffsets) then FreeMem(fGutterOffsets);                     //gp 1/10/1999 //mh 1999-09-12
  fGutter.Free;                                                                 // ???
  fScrollHint.Free;                                                             //ra 1999-08-19
  fTextDrawer.Free;                                                             //th 1999-09-16

  // find / replace
  fTSearch.Free;

  inherited Destroy;
end;

function TmwCustomEdit.GetBlockBegin: TPoint;
begin
  Result := fBlockBegin;
  if fBlockEnd.Y < fBlockBegin.Y then Result := fBlockEnd else
    if fBlockEnd.Y = fBlockBegin.Y then
      if fBlockEnd.X < fBlockBegin.X then Result := fBlockEnd;
end;

function TmwCustomEdit.GetBlockEnd: TPoint;
begin
  Result := fBlockEnd;
  if fBlockEnd.Y < fBlockBegin.Y then Result := fBlockBegin else
    if fBlockEnd.Y = fBlockBegin.Y then
      if fBlockEnd.X < fBlockBegin.X then Result := fBlockBegin;
end;

function TmwCustomEdit.GetCaretX: Integer;
begin
  Result := fCaretX + 1;
end;

function TmwCustomEdit.CaretXPix: Integer;
begin
  Result := fCaretX * fCharWidth + fTextOffset;
end;

function TmwCustomEdit.GetCaretY: Integer;
begin
  Result := fCaretY + 1;
end;

function TmwCustomEdit.CaretYPix: Integer;
begin
  Result := fCaretY * fTextHeight - fTopLine * fTextHeight + 1;
end;

procedure TmwCustomEdit.FontChanged(Sender: TObject);
{begin}                                                                         //th 1999-09-16
(*
{begin}                                                                         //bds 12/24/1998
var
  DC: HDC;
  Save: THandle;
  Metrics: TTextMetric;
  TMFont: HFONT;
  TMLogFont: TLogFont;
begin
  GetObject(Font.Handle, SizeOf(TLogFont), @TMLogFont);

  // We need to get the font with bold and italics set so we have enough room
  // for the widest character it will draw.  This is because fixed pitch fonts
  // always have the same character width, but ONLY when the same attributes
  // are being used.  That is, a bold character can be wider than a non-bold
  // character in a fixed pitch font.
  TMLogFont.lfWeight := FW_BOLD;
  TMLogFont.lfItalic := 1;
  TMFont := CreateFontIndirect(TMLogFont);
  try
    DC := GetDC(0);
    try
      Save := SelectObject(DC, TMFont);
      GetTextMetrics(DC, Metrics);
      SelectObject(DC, Save);
    finally
      ReleaseDC(0, DC);
    end;
  finally
    DeleteObject(TMFont);
  end;
  with Metrics do
  begin
    // Note:  Through trial-and-error I found that tmAveCharWidth should be used
    // instead of tmMaxCharWidth as you would think.  I'm basing this behavior
    // on the Delphi IDE editor behavior.  If tmMaxCharWidth is used, we end up
    // with chars being much farther apart than the same font in the IDE.
    fCharWidth := tmAveCharWidth;

    fTextHeight := tmHeight + tmExternalLeading + fExtraLineSpacing;            //gp 1/10/1999
    {begin}                                                                     //gp 12/24/1998
    if assigned(Parent) then begin
      fLinesInWindow := ClientHeight div fTextHeight;                           //gp 1/10/1999 - changed to procedure call //mh 1999-09-12
      fCharsInWindow := (ClientWidth - fGutterWidth - 2) div fCharWidth;
    end;
    {end}                                                                       //gp 12/24/1998
//  fRightEdgeOffset := fTextOffset + fRightEdge * fCharWidth;                  //mh 03/02/1999
*)

begin
  fTextDrawer.SetBaseFont(Font);
  fCharWidth := fTextDrawer.GetCharWidth;
  fTextHeight := fTextDrawer.GetCharHeight + fExtraLineSpacing;
  if assigned(Parent) then begin
    fLinesInWindow := ClientHeight div fTextHeight;                             //gp 1/10/1999 - changed to procedure call //mh 1999-09-12
    fCharsInWindow := (ClientWidth - fGutterWidth - 2) div fCharWidth;
    InitializeCaret;
  end;
{end}                                                                           //th 1999-09-16
//  fRightEdgeOffset := fTextOffset + fRightEdge * fCharWidth;                  //mh 03/02/1999
  if Gutter.ShowLineNumbers then GutterChanged(Self);                           //mh 1999-09-12
  UpdateScrollBars(TRUE);                                                       //mh 1999-05-08
  Invalidate;                                                                   //bds 2/24/1999
end;

function TmwCustomEdit.GetFont: TFont;
begin
  Result := inherited Font;
end;

function TmwCustomEdit.GetLineCount: Integer;
begin
  Result := Lines.Count;
end;

function TmwCustomEdit.GetLeftChar: Integer;
begin
  Result := fLeftChar + 1;
end;

function TmwCustomEdit.GetLineText: String;
begin
  Result := '';
  if (Lines.Count > 0) and (fCaretY < Lines.Count) then
    Result := Lines[fCaretY];
end;

function TmwCustomEdit.GetSelAvail: Boolean;
begin
{$IFDEF MWE_SELECTION_MODE}
  Result := (fBlockBegin.X <> fBlockEnd.X) or (fBlockBegin.Y <> fBlockEnd.Y);
{$ELSE}
  Result := (fBlockBegin.X <> fBlockEnd.X) or
            ((fBlockBegin.Y <> fBlockEnd.Y) and (fSelectionMode <> smColumn));
{$ENDIF}
end;

//bds 1/25/1998:
// Rewrite to support new SelectionMode property.
function TmwCustomEdit.GetSelText: String;
{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
(*
  function CopyPadded(const S: string; Index, Count: integer): string;
  var
    Len: integer;
  begin
    Result := Copy(S, Index, Count);
    Len := Length(Result);
    if Len < Count then
      Result := Result + StringOfChar(' ', Count - Len);
  end;
var
  BB, BE: TPoint;
  First, Last: Integer;
  Helper: TStringList;
  ColLen: integer;
  s: string;                                                                    //th 1999-09-21
begin{>>GpProfile} ProfilerEnterProc(1); try {GpProfile>>}
  Result := '';
  if SelAvail then
  begin
    Helper := TStringList.Create;
    BB := BlockBegin;
    BE := BlockEnd;
    if BB.Y = BE.Y then
    begin
      case SelectionMode of
        smNormal, smColumn:
          Result := (Copy(Lines[BB.Y - 1], BB.X, BE.X - BB.X));
        smLine:
          Result := Lines[BB.Y - 1] + #13#10; // Line mode always has a trailing CR/LF
      end;
    end else begin
      First := BB.Y - 1;
      Last := BE.Y - 1;
      case SelectionMode of
        smNormal:
          begin
            Helper.Add(Copy(Lines[First], BB.X, Length(Lines[First])));
            inc(First);
            while First < Last do
            begin
              Helper.Add(Lines[First]);
              inc(First);
            end;
            Helper.Add(Copy(Lines[First], 1, BE.X - 1));
          end;
        smColumn:
          begin
            ColLen := BE.X - BB.X;
            while First <= Last do
            begin
              Helper.Add(CopyPadded(Lines[First], BB.X, ColLen));
              inc(First);
            end;
          end;
        smLine:
          begin
            while First <= Last do
            begin
              Helper.Add(Lines[First]);
              inc(First);
            end;
            Helper.Add('');   // Line mode always has a trailing CR/LF          //th 1999-09-20
          end;
      end;
     // Strip last CR+LF
{begin}                                                                         //th 1999-09-21
//     Result := Copy(Helper.Text,1,Length(Helper.Text)-2);			//tskurz 06/11/1999
     s := Helper.Text;
     Result := Copy(s, 1, Length(s) - 2);                                       
     //Result := Helper.Text;
{end}
    end;
    Helper.Free;
  end;
{end}                                                                           //bds 1/25/1999
*)
  function CopyPadded(const S: string; Index, Count: integer): string;
  var
    SrcLen: Integer;
    DstLen: integer;
    P: PChar;
  begin
    SrcLen := Length(S);
    DstLen := Index + Count;
    if SrcLen >= DstLen then
      Result := Copy(S, Index, Count)
    else
    begin
      SetLength(Result, DstLen);
      P := PChar(Result);
      StrPCopy(P, Copy(S, Index, Count));
      Inc(P, Length(S));
      FillChar(P^, DstLen - Srclen, $20);
    end;
  end;

  procedure CopyAndForward(const S: string; Index, Count: Integer; var P: PChar);
  var
    pSrc: PChar;
    SrcLen: Integer;
    DstLen: Integer;
  begin
    SrcLen := Length(S);
    if (Index <= SrcLen) and (Count > 0) then
    begin
      Dec(Index);
      pSrc := PChar(S) + Index;
      DstLen := Min(SrcLen - Index, Count);
      Move(pSrc^, P^, DstLen);
      Inc(P, DstLen);
      P^ := #0;
    end;
  end;

  procedure CopyPaddedAndForward(const S: string; Index, Count: Integer;
    var P: PChar);
  var
    OldP: PChar;
    Len: Integer;
  begin
    OldP := P;
    CopyAndForward(S, Index, Count, P);
    Len := Count - (P - OldP);
    FillChar(P^, Len, #$20);
    Inc(P, Len);
  end;

const
  sLineBreak = #$0D#$0A;
var
  First, Last, TotalLen: Integer;
  ColFrom, ColTo: Integer;
  I: Integer;
{$IFDEF MWE_MBCSSUPPORT}
  l, r: Integer;
  s: string;
{$ELSE}
  ColLen: integer;
{$ENDIF}
  P: PChar;
begin
  if not SelAvail then
    Result := ''
  else
  begin
    with BlockBegin do
    begin
      ColFrom := X;
      First := Y - 1;
    end;
    with BlockEnd do
    begin
      ColTo := X;
      Last := Y - 1;
    end;
    TotalLen := 0;
    case SelectionMode of
      smNormal:
        if (First = Last) then
          Result := Copy(Lines[First], ColFrom, ColTo - ColFrom)
        else
        begin
          // step1: calclate total length of result string
          TotalLen := Max(0, Length(Lines[First]) - ColFrom + 1);
          for i := First + 1 to Last - 1 do
            Inc(TotalLen, Length(Lines[i]));
          Inc(TotalLen, ColTo - 1);
          Inc(TotalLen, Length(sLineBreak) * (Last - First));

          // step2: build up result string
          SetLength(Result, TotalLen);
          P := PChar(Result);

          CopyAndForward(Lines[First], ColFrom, MaxInt, P);
          CopyAndForward(sLineBreak, 1, MaxInt, P);
          for i := First + 1 to Last - 1 do
          begin
            CopyAndForward(Lines[i], 1, MaxInt, P);
            CopyAndForward(sLineBreak, 1, MaxInt, P);
          end;
          CopyAndForward(Lines[Last], 1, ColTo - 1, P);
        end;
      smColumn:
        begin
          if ColFrom > ColTo then
            SwapInt(ColFrom, ColTo);
          // step1: calclate total length of result string
{$IFNDEF MWE_MBCSSUPPORT}
          ColLen := ColTo - ColFrom;
          TotalLen := ColLen + (ColLen + Length(sLineBreak)) * (Last - First);

          // step2: build up result string
          SetLength(Result, TotalLen);
          P := PChar(Result);

          for i := First to Last - 1 do
          begin
            CopyPaddedAndForward(Lines[i], ColFrom, ColLen, P);
            CopyAndForward(sLineBreak, 1, MaxInt, P);
          end;
          CopyPaddedAndForward(Lines[Last], ColFrom, ColLen, P);
{$ELSE} //MWE_MBCSSUPPORT
          for i := First to Last do
          begin
            s := Lines[i];
            l := ColFrom;
            r := ColTo;
            MBCSGetSelRangeInLineWhenColumnSelectionMode(s, l, r);
            Inc(TotalLen, r - l);
          end;
          Inc(TotalLen, Length(sLineBreak) * (Last - First));

          // step2: build up result string
          SetLength(Result, TotalLen);
          P := PChar(Result);

          for i := First to Last - 1 do
          begin
            s := Lines[i];
            l := ColFrom;
            r := ColTo;
            MBCSGetSelRangeInLineWhenColumnSelectionMode(s, l, r);
            CopyPaddedAndForward(s, l, r - l, P);
            CopyAndForward(sLineBreak, 1, MaxInt, P);
          end;
          s := Lines[Last];
          l := ColFrom;
          r := ColTo;
          MBCSGetSelRangeInLineWhenColumnSelectionMode(s, l, r);
          CopyPaddedAndForward(Lines[Last], l, r - l, P);
{$ENDIF}
        end;
      smLine:
        begin
          // If block selection includes LastLine,
          // line break code(s) of the last line will not be added.

          // step1: calclate total length of result string
          for i := First to Last do
            Inc(TotalLen, Length(Lines[i]) + Length(sLineBreak));
          if Last = Lines.Count then
            Dec(TotalLen, Length(sLineBreak));

          // step2: build up result string
          SetLength(Result, TotalLen);
          P := PChar(Result);

          for i := First to Last - 1 do
          begin
            CopyAndForward(Lines[i], 1, MaxInt, P);
            CopyAndForward(sLineBreak, 1, MaxInt, P);
          end;
          CopyAndForward(Lines[Last], 1, MaxInt, P);
          if (Last + 1) < Lines.Count then
            CopyAndForward(sLineBreak, 1, MaxInt, P);
        end;
    end;
  end;

{end}                                                                           //th 1999-09-21

{$ELSE}
var
  BB, BE: TPoint;
  First, Last: Integer;
  Helper: TStringList;
begin
  Result := '';
  if SelAvail then
  begin
    Helper := TStringList.Create;
    BB := BlockBegin;
    BE := BlockEnd;
    if BB.Y = BE.Y then
    begin
      Result := (Copy(Lines[BB.Y - 1], BB.X, BE.X - BB.X));
    end else
    begin
      First := BB.Y - 1;
      Last := BE.Y - 1;
      Helper.Add(Copy(Lines[First], BB.X, Length(Lines[First])));
      inc(First);
      while First < Last do
      begin
        Helper.Add(Lines[First]);
        inc(First);
      end;
      Result := Helper.Text + Copy(Lines[First], 1, BE.X - 1);
    end;
    Helper.Free;
  end;
{$ENDIF}                                                                        //bds 1/25/1999
end;

function TmwCustomEdit.GetText: String;
begin
  Result := Lines.Text;
end;

function TmwCustomEdit.GetTopLine: Integer;
begin
  Result := fTopLine + 1;
end;

procedure TmwCustomEdit.HideCaret;
begin
  if fCaretVisible then
  begin
    if Windows.HideCaret(Handle) then fCaretVisible := False;
  end;
end;

{begin}                                                                         //hk 1999-05-10
{$IFDEF MWE_MBCSSUPPORT}
Procedure TmwCustomEdit.WMImeComposition(Var Msg: TMessage);
Var
  imc: HIMC;
  p: PChar;
Begin
  If ((Msg.LParam and GCS_RESULTSTR) <> 0) Then Begin
    imc := ImmGetContext(Handle);
    Try
      fImeCount := ImmGetCompositionString(imc, GCS_RESULTSTR, Nil, 0);
      GetMem(p, fImeCount+1);
      Try
        ImmGetCompositionString(imc, GCS_RESULTSTR, p, fImeCount+1);
        p[fImeCount] := #0;
        CommandProcessor(ecImeStr, #0, p);
      Finally
        FreeMem(p, fImeCount+1);
      End;
    Finally
      ImmReleaseContext(Handle, imc);
    End;
  End;

  Inherited;
End;


Procedure TmwCustomEdit.WMImeNotify(Var Message: TMessage);                     
Var
  imc: HIMC;
  logFont: TLogFont;
Begin
  With Message Do Begin
    Case WParam Of
    IMN_SETOPENSTATUS:
      Begin
        imc := ImmGetContext(Handle);
        If (imc <> 0) Then Begin
          GetObject(Font.Handle, SizeOf(TLogFont), @logFont);
          ImmSetCompositionFont(imc, @logFont);

          ImmReleaseContext(Handle, imc);
        End;
      End;
    End;
  End;

  Inherited;
End;
{$ENDIF}
{end}                                                                           //hk 1999-05-10

procedure TmwCustomEdit.IncPaintLock;
begin
  inc(fPaintLock);
end;

{begin}                                                                         //mh 1999-05-12
procedure TmwCustomEdit.InvalidateGutter(FirstLine, LastLine: integer);
var rcInval: TRect;
begin
  if Visible and HandleAllocated then
    if (FirstLine = -1) and (LastLine = -1) then
    begin
      rcInval := Rect(0, 0, fGutterWidth, ClientHeight);
{begin}                                                                         //th 1999-09-21
//      InvalidateRect(Handle, @rcInval, FALSE);
      if fIsLinesChanging then
        UnionRect(fInvalidateRect, fInvalidateRect, rcInval)
      else
        InvalidateRect(Handle, @rcInval, FALSE);
{end}                                                                           //th 1999-09-21
    end else begin
      { find the visible lines first }
      if (LastLine < FirstLine) then SwapInt(LastLine, FirstLine);
      FirstLine:= Max(FirstLine, TopLine);
      LastLine:= Min(LastLine, TopLine + LinesInWindow);
      { any line visible? }
      if (LastLine >= FirstLine) then begin
        rcInval:= Rect(0, fTextHeight * (FirstLine - TopLine),
                       fGutterWidth, fTextHeight * (LastLine - TopLine + 1));
{begin}                                                                         //th 1999-09-21
//        InvalidateRect(Handle, @rcInval, FALSE);
        if fIsLinesChanging then
          UnionRect(fInvalidateRect, fInvalidateRect, rcInval)
        else
          InvalidateRect(Handle, @rcInval, FALSE);
{end}                                                                           //th 1999-09-21
      end;
    end;
end;

procedure TmwCustomEdit.InvalidateLines(FirstLine, LastLine: integer);
var rcInval: TRect;
begin
  if Visible and HandleAllocated then
    if (FirstLine = -1) and (LastLine = -1) then
    begin
      rcInval := ClientRect;
      rcInval.Left := fGutterWidth;
{begin}                                                                         //th 1999-09-21
//      InvalidateRect(Handle, @rcInval, FALSE);
      if fIsLinesChanging then
        UnionRect(fInvalidateRect, fInvalidateRect, rcInval)
      else
        InvalidateRect(Handle, @rcInval, FALSE);
{end}                                                                           //th 1999-09-21
    end else begin
      { find the visible lines first }
      if (LastLine < FirstLine) then SwapInt(LastLine, FirstLine);
      FirstLine:= Max(FirstLine, TopLine);
      LastLine:= Min(LastLine, TopLine + LinesInWindow);
      { any line visible? }
      if (LastLine >= FirstLine) then begin
        rcInval:= Rect(fGutterWidth, fTextHeight * (FirstLine - TopLine),
                       ClientWidth, fTextHeight * (LastLine - TopLine + 1));
{begin}                                                                         //th 1999-09-21
//        InvalidateRect(Handle, @rcInval, FALSE);
        if fIsLinesChanging then
          UnionRect(fInvalidateRect, fInvalidateRect, rcInval)
        else
          InvalidateRect(Handle, @rcInval, FALSE);
{end}                                                                           //th 1999-09-21
      end;
    end;
end;
{end}                                                                           //mh 1999-05-12

procedure TmwCustomEdit.KeyDown(var Key: Word; Shift: TShiftState);
var
{begin}                                                                         //bds 12/20/1998
//  moveBkm: boolean;
  Data: pointer;
  C: char;
  Cmd: TmwEditorCommand;                                                        //bds 12/23/1998
{end}                                                                           //bds 12/20/1998
begin
  {$IFDEF DebugKeyEvents} OutputDebugString('>KeyDown'); try {$ENDIF}
  inherited;

//  OnKeyDown is already called in ancestor
//  if Assigned(OnKeyDown) then                                                 //mk 1999-06-10 - removed
//    OnKeyDown(Self, Key, Shift);

  {begin}                                                                       //bds 12/20/1998
  Data := NIL;
  C := #0;
  try
    Cmd := TranslateKeyCode(Key, Shift, Data);
    if Cmd <> ecNone then
    begin
      Key := 0; // eat it.
      CommandProcessor(Cmd, C, Data);
    end;
  finally
    if Data <> NIL then
      FreeMem(Data);
  end;
// old lines (hardwired key processing) removed                                 //mh 1999-08-20
{end}                                                                           //bds 12/20/1998

  {$IFDEF DebugKeyEvents} finally OutputDebugString('<KeyDown'); end; {$ENDIF}
end;

procedure TmwCustomEdit.Loaded;                                                 //jdj 12/12/1998
begin
  inherited Loaded;
//fRightEdgeOffset := fTextOffset + fRightEdge * fCharWidth;                    //mh 03/02/1999
  GutterChanged(Self);                                                          //mh 1999-09-12
  UpdateScrollBars(FALSE);
end;

procedure TmwCustomEdit.KeyPress(var Key: Char);
// Changes stop caret from going out of view when character width is less       // jdj 12/08/1998
// than 25
{begin}                                                                         //bds 12/20/1998
{
var
  Len: Integer;
  Temp, Helper: string;
  StartOfBlock : TPoint;                                                        //tskurz 12/10/1998
  oldScroll: boolean;                                                           //gp 12/16/1998
}
{end}                                                                           //bds 12/20/1998
begin
  {$IFDEF DebugKeyEvents} OutputDebugString('>KeyPress'); try {$ENDIF}

{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
  If (fImeCount > 0) Then Begin                                                 //hk 1999-05-10
    Dec(fImeCount);
    Exit;
  End;
{$ENDIF}

  try
    if Assigned(OnKeyPress) then
      OnKeyPress(Self, Key);

{begin}                                                                         //bds 12/20/1998
  CommandProcessor(ecChar, Key, NIL);
// old lines (hardwired key processing) removed                                 //mh 1999-08-20
{end}                                                                           //bds 12/20/1998
  finally
  end;
  {$IFDEF DebugKeyEvents} finally OutputDebugString('<KeyPress'); end; {$ENDIF}
end;

function TmwCustomEdit.LeftSpaces(Line: String): Integer;
var
  Len: Integer;
begin
  Result := 0;
  if fAutoindent then begin                                                     //tb 1999-05-07
    Len := Length(Line);
    while Result < Len do
    begin
      if Line[Result + 1] > #32 then break;
      inc(Result);
    end;
  end;                                                                          //tb 1999-05-07
end;

{begin}                                                                         //th 1999-09-19
procedure TmwCustomEdit.LinesChanging(Sender: TObject);
begin
  fIsLinesChanging := True;
end;
{end}                                                                           //th 1999-09-19

procedure TmwCustomEdit.LinesChanged(Sender: TObject);
begin
  fIsLinesChanging := False;                                                    //th 1999-09-19
  if HandleAllocated then
  begin
    UpdateScrollBars(FALSE);
    SetBlockBegin(CaretXY);                                                     //bds 12/20/1998
//    Invalidate;                                                                 //bds 2/24/1999 //th 1999-09-19
    InvalidateRect(Handle, @fInvalidateRect, False);                            //th 1999-09-19
    FillChar(fInvalidateRect, SizeOf(TRect), 0);                                //th 1999-09-19
  end;
end;

procedure TmwCustomEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;     //tk 12/09/1998
  X, Y: Integer);
var
  bWasSel: boolean;                                                             //ked 12/10/1998
  BlStart, BlEnd, Dwn: integer;
begin
  {$IFDEF DebugMouseEvents} OutputDebugString('>MouseDown'); try {$ENDIF}
  if (Button = mbRight) and (Shift = [ssRight]) and Assigned(PopupMenu)         //levin 1/6/1999
    then exit;
  if ssDouble in Shift then Exit;                                               //gp 12/27/1998 - ignore stray MouseDown on double click
  {begin}                                                                       //ked 12.10.1998
  if SelAvail then begin
    //remember selection state, as it will be cleared later
    bWasSel := true;
    fDragBlockBegin := BlockBegin;
    fDragBlockEnd := BlockEnd;
    fMouseDownX := X;
    fMouseDownY := Y;
  end else
    bWasSel := false;
  {end}                                                                         //ked 12/10/1998

  inherited MouseDown(Button, Shift, X, Y);
  MouseCapture := True;
  ComputeCaret(X, Y);
  //if mousedown occured in selected block then begin drag operation
  BlStart := CoorToIndex(fDragBlockBegin);                                      //ked 12/10/1998
  BlEnd := CoorToIndex(fDragBlockEnd);
  Dwn := CoorToIndex(CaretXY);                                                  //bds 12/20/1998
  fWaitForDragging := false;                                                    //gp 12/12/1998
  if bWasSel and (Dwn >= BlStart) and (Dwn < BlEnd)
    then fWaitForDragging := true                                               //gp 12/12/1998
    else begin
      if not fDblClicked then begin
        if ssShift in Shift then
          SetBlockEnd(CaretXY)                                                  //bds 12/20/1998
        else
          SetBlockBegin(CaretXY);                                               //bds 12/20/1998
      end;
    end;
//  fDblClicked := False;                                                       //gp 12/12/1998
  Windows.SetFocus(Handle);                                                     //ajb 1999-06-13
  {$IFDEF DebugMouseEvents} finally OutputDebugString('<MouseDown'); end; {$ENDIF}
end;

procedure TmwCustomEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
//var
//threshold: integer;                                                           //gp 12/16/1998, //gp 12/24/1998 - removed
{begin}                                                                         //mh 1999-05-12
var bDoSleep: boolean;
    nDelta: integer;

// replacement for fInEditRect and WMNCHitTest
  function IsInEditRect(bGetCoor: boolean): boolean;
  var ptMouse: TPoint;
  begin
    if bGetCoor then
    begin
      GetCursorPos(ptMouse);
      ptMouse:= ScreenToClient(ptMouse);
      X:= ptMouse.X;
      Y:= ptMouse.Y;
    end;
    Result:= (X >= fGutterWidth) and (X < ClientWidth) and
             (Y >= 0) and (Y < ClientHeight);
  end;
{end}                                                                           //mh 1999-05-12

begin
  {$IFDEF DebugMouseMove} OutputDebugString('>MouseMove'); try {$ENDIF}
  inherited MouseMove(Shift, x, y);
  {begin}
  if MouseCapture and fWaitForDragging and not ReadOnly then begin              //bds 12/20/1998
    {begin}                                                                     //gp 12/24/1998 - rewritten
    if (Abs(fMouseDownX - X) >= GetSystemMetrics(SM_CXDRAG)) or
       (Abs(fMouseDownY - Y) >= GetSystemMetrics(SM_CYDRAG)) then begin
    {end}                                                                       //gp 12/24/1998
      fWaitForDragging := false;
      {$IFDEF DebugDragEvents} OutputDebugString('BeginDrag'); {$ENDIF}
      BeginDrag(false);                                                         //ked 12/10/1998
    end;
  end
  {end}                                                                         //gp 12/12/1998
  else begin
{begin}                                                                         //mh 1999-05-12

// a lot of lines removed here that did basically the same

    if X > fGutterWidth then Cursor := crIBeam
                         else Cursor := crArrow;
    if not fInScrollLoop and (ssLeft in Shift) and MouseCapture then
    begin
      fInScrollLoop := TRUE;
      try
        if IsInEditRect(FALSE) then ComputeCaret(X, Y);
        SetBlockEnd(CaretXY);
        // fInScrollLoop is to prevent reentrancy of this code block here
        Application.ProcessMessages;

        // now do the scrolling in three different ways depending on the
        // distance to the client area of the control:
        //  - small changes, sleep 100 ms
        //  - big changes, sleep 100 ms   -> more than 10 pixel distance
        //  - big changes, no delay       -> more than 42 pixel distance
        // maybe somebody wants to tweak this, it worked best for me on a
        // Pentium 133...

        // we have to constantly update the mouse position!
        while MouseCapture and not IsInEditRect(TRUE) do
        begin
          bDoSleep := TRUE;
          // changes to line / column in one go
          IncPaintLock;
          try
            // horizontal scrolling
            if X < fGutterWidth then
            begin
              nDelta := fGutterWidth - X;
              if nDelta < 10 then LeftChar := LeftChar - 1
                             else LeftChar := LeftChar - 8;
              if nDelta >= 42 then bDoSleep := FALSE;
              CaretX := LeftChar;
              SetBlockEnd(CaretXY);
            end else if X > ClientWidth then
            begin
              nDelta := X - ClientWidth;
              if nDelta < 10 then LeftChar := LeftChar + 1
                             else LeftChar := LeftChar + 8;
              if nDelta >= 42 then bDoSleep := FALSE;
              CaretX := LeftChar + CharsInWindow;
              SetBlockEnd(CaretXY);
            end;
            // vertical scrolling
            if Y < 0 then
            begin
              if Y <= -10 then TopLine := TopLine - LinesInWindow
                          else TopLine := TopLine - 1;
              if Y <= -42 then bDoSleep := FALSE;
              CaretY := TopLine;
              SetBlockEnd(CaretXY);
            end else if Y > ClientHeight then
            begin
              nDelta := Y - ClientHeight;
              if nDelta >= 10 then TopLine := TopLine + LinesInWindow
                              else TopLine := TopLine + 1;
              if nDelta >= 42 then bDoSleep := FALSE;
              CaretY := TopLine + LinesInWindow - 1;
              SetBlockEnd(CaretXY);
            end;
          finally
            DecPaintLock;
            Update;                                                             //th 1999-09-15
          end;
          // paint and update cursor and so on...
          Application.ProcessMessages;
          if bDoSleep then Sleep(100);
        end;
      finally
        fInScrollLoop := FALSE;
      end;
    end;
{end}                                                                           //mh 1999-05-12
  end;
  {$IFDEF DebugMouseMove} finally OutputDebugString('<MouseMove'); end; {$ENDIF}
end;

procedure TmwCustomEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  {$IFDEF DebugMouseEvents} OutputDebugString('>MouseUp'); try {$ENDIF}
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbRight) and (Shift = [ssRight]) and Assigned(PopupMenu)         //levin 1/6/1999
    then exit;
  MouseCapture := False;
  {begin}                                                                       //gp 12/12/1998
  if fWaitForDragging and (not fDblClicked) then begin
    ComputeCaret(X,Y);
    SetBlockBegin(CaretXY);                                                     //bds 12/20/1998
    SetBlockEnd(CaretXY);                                                       //bds 12/20/1998
    fWaitForDragging := false;
  end;
  fDblClicked := False;
  {end}                                                                         //gp 12/12/1998
  {$IFDEF DebugMouseEvents} finally OutputDebugString('<MouseUp'); end; {$ENDIF}
end;

{begin}                                                                         //mh 1999-09-12
// Complete rewrite of the painting code again. Removed Brads code with the
// Windows regions, since it made painting selected text very slow (the lines
// were scanned twice by the assigned highlighter) - on my system it took up to
// threetimes as long to paint the window if everything was selected.
// Splitting the paint into two operations caused weird effects on slower
// systems when scrolling in the column selection mode.
// The new code features the following:
// - No more doublebuffering of the drawing operations. The bitmap member has
//   been removed completely.
// - The highlighters don't touch the canvas of the control any more. Instead
//   the active token attribute is read from the highlighter, and only the
//   necessary changes to the font and the brush are made. This removes a lot
//   of color changes for selected text. Also the font color for spaces is
//   ignored, since no chars are visible anyway.
// - Tokens with the same font and brush attributes (also depending on the
//   selection state) are concatenated and painted in one go, this reduces
//   the number of ExtTextOut calls.
// - New event to assign special font and background colors to a line. Can be
//   used to paint breakpoint or current lines like seen in the Delphi IDE.
// - The font width array for the ExtTextOut calls is dynamically allocated
//   (only the maximum number of visible chars, not fCharsInWindow) and filled
//   with the fCharWidth value. This should save memory... Thanks to James
//   Jacobson for spotting this one.
                                                                                //mh 1999-09-21
// A lot of changes have been made by Tohru Hanai before the new version was
// released. Speed is now considerably higher, thanks to the new text painter
// classes and the changes in the client area invalidation code.
// I did however not mark the changes, but removed all the commented out lines
// for the sake of clarity. Please consider the painting code a joint effort of
// Tohru and me. The gains in speed come mostly from Tohrus new code.

procedure TmwCustomEdit.Paint;
var rcClip, rcDraw: TRect;
    nL1, nL2, nC1, nC2: integer;
begin
  fNeedsRepaint := FALSE;
  // Get the invalidated rect. Compute the invalid area in lines / columns.
  rcClip := Canvas.ClipRect;
  // columns
  nC1 := LeftChar;
  if (rcClip.Left > fGutterWidth + 2) then
    Inc(nC1, (rcClip.Left - fGutterWidth - 2) div CharWidth);
  nC2 := nC1 +
         (rcClip.Right - fGutterWidth - 2 + CharWidth - 1) div CharWidth;
  // lines
  nL1 := Max(TopLine + rcClip.Top div fTextHeight, TopLine);
  nL2 := Min(TopLine + (rcClip.Bottom + fTextHeight - 1) div fTextHeight,
             Lines.Count);
  // Now paint everything while the caret is hidden.
  HideCaret;
  try
    // First paint the gutter area if it was (partly) invalidated.
    if (rcClip.Left < fGutterWidth) then begin
      rcDraw := rcClip;
      rcDraw.Right := fGutterWidth;
      PaintGutter(rcDraw, nL1, nL2);
    end;
    // Then paint the text area if it was (partly) invalidated.
    if (rcClip.Right > fGutterWidth) then begin
      rcDraw := rcClip;
      rcDraw.Left := Max(rcDraw.Left, fGutterWidth);
      PaintTextLines(rcDraw, nL1, nL2, nC1, nC2);
    end;
    // If there is a custom paint handler call it.
    if Assigned(fOnPaint) then begin
      Font.Assign(Font);
      Brush.Color:= Color;
      fOnPaint(Self, Canvas);
    end;
  finally
    UpdateCaret;
  end;
end;

procedure TmwCustomEdit.PaintGutter(AClip: TRect; FirstLine, LastLine: integer);
var i, iLine: integer;
    rcLine: TRect;
    bHasOtherMarks: boolean;
    aGutterOffs: PIntArray;
    s: string;
    dc: HDC;

  procedure DrawMark(iMark: integer);
  var iLine: integer;
  begin
    if Assigned(fBookmarkImages) and not Marks[i].InternalImage then
    begin
      if Marks[iMark].ImageIndex <= fBookmarkImages.Count then
      begin
        iLine := Marks[iMark].Line - TopLine;
        fBookmarkImages.Draw(Canvas,
                             fBookMarkOpt.LeftMargin + aGutterOffs^[iLine],
                             iLine * fTextHeight,
                             Marks[iMark].ImageIndex);
        Inc(aGutterOffs^[iLine], fBookMarkOpt.XOffset);
      end;
    end else begin
      if Marks[iMark].ImageIndex in [0..9] then
      begin
        iLine := Marks[iMark].Line - TopLine;
        Canvas.Draw(fBookMarkOpt.LeftMargin + aGutterOffs^[iLine],
                    iLine * fTextHeight,
                    fBookMarksGlyphs[Marks[iMark].ImageIndex]);
        Inc(aGutterOffs^[iLine], fBookMarkOpt.XOffset);
      end;
    end;
  end;

begin
  dc := Canvas.Handle;
  fTextDrawer.BeginDrawing(Canvas.Handle);
  try
    fTextDrawer.SetBackColor(fGutter.Color);
    // If we have to draw the line numbers then we don't want to erase
    // the background first. Do it line by line with TextRect instead
    // and fill only the area after the last visible line.
    if fGutter.ShowLineNumbers then
    begin
      fTextDrawer.SetForeColor(Self.Font.Color);
      fTextDrawer.Style := [];
      // prepare the rect initially
      rcLine := AClip;
      rcLine.Right := Max(rcLine.Right, fGutterWidth - 2);
      rcLine.Bottom := (FirstLine - TopLine) * fTextHeight;
      for iLine := FirstLine to LastLine do
      begin
        // next line rect
        rcLine.Top := rcLine.Bottom;
        Inc(rcLine.Bottom, fTextHeight);
        // erase the background and draw the line number string in one go
        s := fGutter.FormatLineNumber(iLine);
        Windows.ExtTextOut(DC, fGutter.LeftOffset, rcLine.Top, ETO_OPAQUE,
          @rcLine, PChar(s), Length(s), nil);
      end;
      // now erase the remaining area if any
      if AClip.Bottom > rcLine.Bottom then
      begin
        rcLine.Top := rcLine.Bottom;
        rcLine.Bottom := AClip.Bottom;
        with rcLine do
          fTextDrawer.ExtTextOut(Left, Top, ETO_OPAQUE, rcLine, nil, 0);
      end;
    end else
      with AClip do
        fTextDrawer.ExtTextOut(Left, Top, ETO_OPAQUE, AClip, nil, 0);

    // the gutter separator if visible
    if AClip.Right >= fGutterWidth - 2 then
    with Canvas do begin
      Pen.Color := clBtnHighlight;
      Pen.Width := 1;
      with AClip do begin
        MoveTo(fGutterWidth - 2, Top);
        LineTo(fGutterWidth - 2, Bottom);
        Pen.Color := clBtnShadow;
        MoveTo(fGutterWidth - 1, Top);
        LineTo(fGutterWidth - 1, Bottom);
      end;
    end;

    // now the gutter marks
    if BookMarkOptions.GlyphsVisible and (Marks.Count > 0) then
    begin
      aGutterOffs := AllocMem((fLinesInWindow + 1) * SizeOf(integer));
      try
        // Instead of making a two pass loop we look while drawing the bookmarks
        // whether there is any other mark to be drawn
        bHasOtherMarks := FALSE;
        for i := 0 to Marks.Count - 1 do
        begin
          if not Marks[i].Visible or (Marks[i].Line < FirstLine) or
                                     (Marks[i].Line > LastLine)
          then continue;

          if Marks[i].IsBookmark then bHasOtherMarks := TRUE
                                 else DrawMark(i);
        end;
        if bHasOtherMarks then for i := 0 to Marks.Count - 1 do
          with Marks[i] do
            if Visible and IsBookmark and
               (Line >= FirstLine) and (Line <= LastLine)
            then DrawMark(i);
      finally
        FreeMem(aGutterOffs);
      end;
    end;
  finally
    fTextDrawer.EndDrawing;
  end;
end;

procedure TmwCustomEdit.PaintTextLines(AClip: TRect; FirstLine, LastLine,
                                       FirstCol, LastCol: integer);
var bDoRightEdge: boolean; // right edge
    nRightEdge: integer;
    // selection info
    bAnySelection: boolean;    // any selection visible?
    nSelL1, nSelCol1: integer; // start of selected area
    nSelL2, nSelCol2: integer; // end of selected area
    // info about normal and selected text and background colors
    bSpecialLine, bLineSelected: boolean;
    colFG, colBG: TColor;
    colSelFG, colSelBG: TColor;
    // info about selction of the current line
    nSelStart, nSelEnd: integer;
    bComplexLine: boolean;
    // painting the background and the text
    rcLine, rcToken: TRect;
    TokenAccu: record
                 // Note: s is not managed as a string, it will only grow!!!
                 // Never use AppendStr or "+", use Len and MaxLen instead and
                 // copy the string chars directly. This is for efficiency.
                 Len, MaxLen, CharsBefore: integer;
                 s: string;
                 FG, BG: TColor;
                 Style: TFontStyles;
               end;
    dc: HDC;

{ local procedures }

  procedure ComputeSelectionInfo;
  begin
    bAnySelection := FALSE;
    // Only if selection is visible anyway.
    if (not HideSelection or Self.Focused) then begin
      bAnySelection := TRUE;
      // Get the *real* start of the selected area.
      if (fBlockBegin.Y < fBlockEnd.Y) then begin
        nSelL1 := fBlockBegin.Y;
        nSelCol1 := fBlockBegin.X;
        nSelL2 := fBlockEnd.Y;
        nSelCol2 := fBlockEnd.X;
      end else if (fBlockBegin.Y > fBlockEnd.Y) then begin
        nSelL2 := fBlockBegin.Y;
        nSelCol2 := fBlockBegin.X;
        nSelL1 := fBlockEnd.Y;
        nSelCol1 := fBlockEnd.X;
      end else if (fBlockBegin.X <> fBlockEnd.X) then begin
        // No selection at all, or it is only on this line.
        nSelL1 := fBlockBegin.Y;
        nSelL2 := nSelL1;
        if (fBlockBegin.X < fBlockEnd.X) then begin
          nSelCol1 := fBlockBegin.X;
          nSelCol2 := fBlockEnd.X;
        end else begin
          nSelCol2 := fBlockBegin.X;
          nSelCol1 := fBlockEnd.X;
        end;
      end else
        bAnySelection := FALSE;
      // If there is any visible selection so far, then test if there is an
      // intersection with the area to be painted.
      if bAnySelection then begin
      // Don't care if the selection is not visible.
        bAnySelection := (nSelL2 >= FirstLine) and (nSelL1 <= LastLine);
{$IFDEF MWE_SELECTION_MODE}
      // In the column selection mode sort the begin and end of the selection,
      // this makes the painting code simpler.
        if (SelectionMode = smColumn) and (nSelCol1 > nSelCol2) then
          SwapInt(nSelCol1, nSelCol2);
{$ENDIF}
      end;
    end;
  end;

  procedure SetDrawingColors(Selected: boolean);
  begin
    with fTextDrawer do
      if Selected then begin
        SetBackColor(colSelBG);
        SetForeColor(colSelFG);
      end else begin
        SetBackColor(colBG);
        SetForeColor(colFG);
      end;
  end;

  function ColumnToXValue(Col: integer): integer;
  begin
    Result := fTextOffset + Pred(Col) * fCharWidth;
  end;

  // CharsBefore tells if Token starts at column one or not
  procedure PaintToken(const Token: string;
                       TokenLen, CharsBefore, First, Last: integer);
  var pszText: PChar;
      nX, nCharsToPaint: integer;
  const ETOOptions = ETO_CLIPPED or ETO_OPAQUE;
  begin
    if (Last >= First) and (rcToken.Right > rcToken.Left) then begin
      nX := ColumnToXValue(First);
      Dec(First, CharsBefore);
      Dec(Last, CharsBefore);
      if (First > TokenLen) then begin
        pszText := nil;
        nCharsToPaint := 0;
      end else begin
        pszText := PChar(@Token[First]);
        nCharsToPaint := Min(Last - First + 1, TokenLen - First + 1);
      end;
      fTextDrawer.ExtTextOut(nX, rcToken.Top, ETOOptions, rcToken,
                             pszText, nCharsToPaint);
      rcToken.Left := rcToken.Right;
    end;
  end;

  procedure PaintHighlightToken(bFillToEOL: boolean);
  var bComplexToken: boolean;
      nC1, nC2, nC1Sel, nC2Sel: integer;
      bU1, bSel, bU2: boolean;
      nX1, nX2: integer;
  begin
    // Compute some helper variables.
    nC1 := Max(FirstCol, TokenAccu.CharsBefore + 1);
    nC2 := Min(LastCol, TokenAccu.CharsBefore + TokenAccu.Len + 1);
    if bComplexLine then begin
      bU1 := (nC1 < nSelStart);
      bSel := (nC1 < nSelEnd) and (nC2 >= nSelStart);
      bU2 := (nC2 >= nSelEnd);
      bComplexToken := bSel and (bU1 or bU2);
    end else begin
      bU1 := FALSE; // to shut up Compiler warning Delphi 2
      bSel := bLineSelected;
      bU2 := FALSE; // to shut up Compiler warning Delphi 2
      bComplexToken := FALSE;
    end;
    // Any token chars accumulated?
    if (TokenAccu.Len > 0) then begin
      // Initialize the colors and the font style.
      if not bSpecialLine then begin
        colBG := TokenAccu.BG;
        colFG := TokenAccu.FG;
      end;
      fTextDrawer.SetStyle(TokenAccu.Style);
      // Paint the chars
      if bComplexToken then begin
        // first unselected part of the token
        if bU1 then begin
          SetDrawingColors(FALSE);
          rcToken.Right := ColumnToXValue(nSelStart);
          with TokenAccu do PaintToken(s, Len, CharsBefore, nC1, nSelStart);
        end;
        // selected part of the token
        SetDrawingColors(TRUE);
        nC1Sel := Max(nSelStart, nC1);
        nC2Sel := Min(nSelEnd, nC2);
        rcToken.Right := ColumnToXValue(nC2Sel);
        with TokenAccu do PaintToken(s, Len, CharsBefore, nC1Sel, nC2Sel);
        // second unselected part of the token
        if bU2 then begin
          SetDrawingColors(FALSE);
          rcToken.Right := ColumnToXValue(nC2);
          with TokenAccu do PaintToken(s, Len, CharsBefore, nSelEnd, nC2);
        end;
      end else begin
        SetDrawingColors(bSel);
        rcToken.Right := ColumnToXValue(nC2);
        with TokenAccu do PaintToken(s, Len, CharsBefore, nC1, nC2);
      end;
    end;
    // Fill the background to the end of this line if necessary.
    if bFillToEOL and (rcToken.Left < rcLine.Right) then begin
      if not bSpecialLine then colBG := Color;
      if bComplexLine then begin
        nX1 := ColumnToXValue(nSelStart);
        nX2 := ColumnToXValue(nSelEnd);
        if (rcToken.Left < nX1) then begin
          SetDrawingColors(FALSE);
          rcToken.Right := nX1;
          InternalFillRect(dc, rcToken);
          rcToken.Left := nX1;
        end;
        if (rcToken.Left < nX2) then begin
          SetDrawingColors(TRUE);
          rcToken.Right := nX2;
          InternalFillRect(dc, rcToken);
          rcToken.Left := nX2;
        end;
        if (rcToken.Left < rcLine.Right) then begin
          SetDrawingColors(FALSE);
          rcToken.Right := rcLine.Right;
          InternalFillRect(dc, rcToken);
        end;
      end else begin
        SetDrawingColors(bLineSelected);
        rcToken.Right := rcLine.Right;
        InternalFillRect(dc, rcToken);
      end;
    end;
  end;

  procedure AddHighlightToken(const Token: AnsiString;
                              CharsBefore, TokenLen: integer;
                              Foreground, Background: TColor;
                              Style: TFontStyles);
  var bCanAppend: boolean;
      bSpacesTest, bIsSpaces: boolean;
      i: integer;

    function TokenIsSpaces: boolean;
    var pTok: PChar;
    begin
      if bSpacesTest then Result := bIsSpaces
      else begin
        bSpacesTest := TRUE;
        Result := FALSE;
        pTok := PChar(Token);
        while (pTok^ <> #0) do begin
          if (pTok^ <> ' ') then exit;
          Inc(pTok);
        end;
        Result := TRUE;
      end;
    end;

  begin
    // Do we have to paint the old chars first, or can we just append?
    bCanAppend := FALSE;
    bSpacesTest := FALSE;
    if (TokenAccu.Len > 0) then begin
      // font style must be the same or token is only spaces
      if (TokenAccu.Style = Style) or TokenIsSpaces then
      // either special colors or same colors
      if bSpecialLine or bLineSelected or
        // background color must be the same and
        ((TokenAccu.BG = Background) and
          // foreground color must be the same or token is only spaces
          ((TokenAccu.FG = Foreground) or TokenIsSpaces))
      then bCanAppend := TRUE;
      // If we can't append it, then we have to paint the old token chars first.
      if not bCanAppend then PaintHighlightToken(FALSE);
    end;
    // Don't use AppendStr because it's more expensive.
    if bCanAppend then begin
      if (TokenAccu.Len + TokenLen > TokenAccu.MaxLen) then begin
        TokenAccu.MaxLen := TokenAccu.Len + TokenLen + 32;
        SetLength(TokenAccu.s, TokenAccu.MaxLen);
      end;
      for i := 1 to TokenLen do TokenAccu.s[TokenAccu.Len + i] := Token[i];
      Inc(TokenAccu.Len, TokenLen);
    end else begin
      TokenAccu.Len := TokenLen;
      if (TokenAccu.Len > TokenAccu.MaxLen) then begin
        TokenAccu.MaxLen := TokenAccu.Len + 32;
        SetLength(TokenAccu.s, TokenAccu.MaxLen);
      end;
      for i := 1 to TokenLen do TokenAccu.s[i] := Token[i];
      TokenAccu.CharsBefore := CharsBefore;
      TokenAccu.FG := Foreground;
      TokenAccu.BG := Background;
      TokenAccu.Style := Style;
    end;
  end;

  procedure PaintLines;
  var nLine: integer;              // line index for the loop
      sLine: string;               // the current line (expanded)
      pConvert: TConvertTabsProc;
      sToken: string;              // highlighter token info
      nTokenPos, nTokenLen: integer;
      attr: TmwHighLightAttributes;
  begin
    // Initialize rcLine for drawing. Note that Top and Bottom are updated
    // inside the loop. Get only the starting point for this.
    rcLine := AClip;
    rcLine.Bottom := (FirstLine - TopLine) * fTextHeight;
    // Make sure the token accumulator string doesn't get reassigned to often.
    if Assigned(fHighlighter) then begin
      TokenAccu.MaxLen := Max(128, fCharsInWindow);
      SetLength(TokenAccu.s, TokenAccu.MaxLen);
    end;
    // Find the fastest function for the tab expansion.
    pConvert := GetBestConvertTabsProc(fTabWidth);
    // Now loop through all the lines. The indices are valid for Lines.
    for nLine := FirstLine to LastLine do begin
      // Get the expanded line.
      sLine := pConvert(Lines[nLine - 1], fTabWidth);
      // Get the information about the line selection. Three different parts
      // are possible (unselected before, selected, unselected after), only
      // unselected or only selected means bComplexLine will be FALSE. Start
      // with no selection, compute based on the visible columns.
      bComplexLine := FALSE;
      nSelStart := 0;
      nSelEnd := 0;
      // Does the selection intersect the visible area?
      if bAnySelection and (nLine >= nSelL1) and (nLine <= nSelL2) then begin
        // Default to a fully selected line. This is correct for the smLine
        // selection mode and a good start for the smNormal mode.
        nSelStart := FirstCol;
        nSelEnd := LastCol + 1;
{$IFDEF MWE_SELECTION_MODE}
        if (SelectionMode = smColumn) or
           ((SelectionMode = smNormal) and (nLine = nSelL1)) then
{$ELSE}
        if (nLine = nSelL1) then
{$ENDIF}
          if (nSelCol1 > LastCol) then begin
            nSelStart := 0;
            nSelEnd := 0;
          end else if (nSelCol1 > FirstCol) then begin
            nSelStart := nSelCol1;
            bComplexLine := TRUE;
          end;
{$IFDEF MWE_SELECTION_MODE}
        if (SelectionMode = smColumn) or
           ((SelectionMode = smNormal) and (nLine = nSelL2)) then
{$ELSE}
        if (nLine = nSelL2) then
{$ENDIF}
          if (nSelCol2 < FirstCol) then begin
            nSelStart := 0;
            nSelEnd := 0;
          end else if (nSelCol2 < LastCol) then begin
            nSelEnd := nSelCol2;
            bComplexLine := TRUE;
          end;
{begin}                                                                         //th 1999-09-21
{$IFDEF MWE_SELECTION_MODE}
{$IFDEF MWE_MBCSSUPPORT}
        if (SelectionMode = smColumn) then
          MBCSGetSelRangeInLineWhenColumnSelectionMode(sLine, nSelStart, nSelEnd);
{$ENDIF}
{$ENDIF}
{end}
      end;
      // Update the rcLine rect to this line.
      rcLine.Top := rcLine.Bottom;
      Inc(rcLine.Bottom, fTextHeight);
      // Initialize the text and background colors, maybe the line should
      // use special values for them.
      bSpecialLine := FALSE;
      colFG := Font.Color;
      colBG := Color;
      if Assigned(fOnSpecialLineColors) then
        fOnSpecialLineColors(Self, nLine, bSpecialLine, colFG, colBG);
      if bSpecialLine then begin
        // The selection colors are just swapped, like seen in Delphi.
        colSelFG := colBG;
        colSelBG := colFG;
      end else begin
        colSelFG := fSelectedColor.Foreground;
        colSelBG := fSelectedColor.Background;
      end;
      // Paint the lines depending on the assigned highlighter.
      bLineSelected := not bComplexLine and (nSelStart > 0);
      rcToken := rcLine;
      if not Assigned(fHighlighter) then begin
        // Note: The PaintToken procedure will take care of invalid parameters
        // like empty token rect or invalid indices into sLine.
        nTokenLen := Length(sLine);
        if bComplexLine then begin
          SetDrawingColors(FALSE);
          rcToken.Left := Max(rcLine.Left, ColumnToXValue(FirstCol));
          rcToken.Right := Min(rcLine.Right, ColumnToXValue(nSelStart));
          PaintToken(sLine, nTokenLen, 0, FirstCol, nSelStart);
          rcToken.Left := Max(rcLine.Left, ColumnToXValue(nSelEnd));
          rcToken.Right := Min(rcLine.Right, ColumnToXValue(LastCol));
          PaintToken(sLine, nTokenLen, 0, nSelEnd, LastCol);
          SetDrawingColors(TRUE);
          rcToken.Left := Max(rcLine.Left, ColumnToXValue(nSelStart));
          rcToken.Right := Min(rcLine.Right, ColumnToXValue(nSelEnd));
          PaintToken(sLine, nTokenLen, 0, nSelStart, nSelEnd);
        end else begin
          SetDrawingColors(bLineSelected);
          PaintToken(sLine, nTokenLen, 0, FirstCol, LastCol);
        end;
      end else begin
        // Initialize highlighter with line text and range info. It is
        // necessary because we probably did not scan to the end of the last
        // line - the internal highlighter range might be wrong.
        fHighlighter.SetRange(Lines.Objects[nLine - 1]);
        fHighlighter.SetLine(sLine, nLine - 1);
        // Try to concatenate as many tokens as possible to minimize the count
        // of ExtTextOut calls necessary. This depends on the selection state
        // or the line having special colors. For spaces the foreground color
        // is ignored as well.
        TokenAccu.Len := 0;
        while not fHighLighter.GetEol do begin
          // Test first whether anything of this token is visible.
          nTokenPos := fHighLighter.GetTokenPos;   // zero-based
          sToken := fHighLighter.GetToken;
          nTokenLen := Length(sToken);
          if (nTokenPos + nTokenLen >= FirstCol) then begin
            // It's at least partially visible. Get the token attributes now.
            attr := fHighlighter.GetTokenAttribute;
            // Store the token chars with the attributes in the TokenAccu
            // record. This will paint any chars already stored if there is
            // a (visible) change in the attributes.
            if Assigned(attr) then
              AddHighlightToken(sToken, nTokenPos, nTokenLen, attr.Foreground,
                                attr.Background, attr.Style)
            else
              AddHighlightToken(sToken, nTokenPos, nTokenLen, colFG, colBG,
                                Font.Style);
          end;
          // Let the highlighter scan the next token.
          fHighlighter.Next;
        end;
        // Draw anything that's left in the TokenAccu record. Fill to the end
        // of the invalid area with the correct colors.
        PaintHighlightToken(TRUE);
      end;
      // Now paint the right edge if necessary. We do it line by line to reduce
      // the flicker. Should not cost very much anyway, compared to the many
      // calls to ExtTextOut.
      if bDoRightEdge then begin
        Windows.MoveToEx(dc, nRightEdge, rcLine.Top, nil);
        Windows.LineTo(dc, nRightEdge, rcLine.Bottom + 1);
      end;
    end;
  end;

{ end local procedures }

begin
  // If the right edge is visible and in the invalid area, prepare to paint it.
  // Do this first to realize the pen when getting the dc variable.
  bDoRightEdge := FALSE;
  if (fRightEdge > 0) then // column value
  begin
    nRightEdge := fTextOffset + fRightEdge * fCharWidth; // pixel value
    if (nRightEdge >= AClip.Left) and (nRightEdge <= AClip.Right) then
    begin
      bDoRightEdge := TRUE;
      Canvas.Pen.Color := fRightEdgeColor;
      Canvas.Pen.Width := 1;
    end;
  end;
  // Do everything else with API calls. This (maybe) realizes the new pen color.
  dc := Canvas.Handle;
  // If anything of the two pixel space before the text area is visible, then
  // fill it with the component background color.
  if (AClip.Left < fGutterWidth + 2) then begin
    rcToken := AClip;
    rcToken.Left := Max(AClip.Left, fGutterWidth);
    rcToken.Right := fGutterWidth + 2;
    SetBkColor(dc, ColorToRGB(Self.Color));
    InternalFillRect(dc, rcToken);
    // Adjust the invalid area to not include this area.
    AClip.Left := rcToken.Right;
  end;
  // Paint the visible text lines. To make this easier, compute first the
  // necessary information about the selected area: is there any visible
  // selected area, and what are its lines / columns?
  // Moved to two local procedures to make it easier to read.
  if (LastLine >= FirstLine) then begin
    ComputeSelectionInfo;
    fTextDrawer.BeginDrawing(dc);
    try
      PaintLines;
    finally
      fTextDrawer.EndDrawing;
    end;
  end;
  // If there is anything visible below the last line, then fill this as well.
  rcToken := AClip;
  rcToken.Top := (LastLine - TopLine + 1) * fTextHeight;
  if (rcToken.Top < rcToken.Bottom) then begin
    SetBkColor(dc, ColorToRGB(Self.Color));
    InternalFillRect(dc, rcToken);
    // Draw the right edge if necessary.
    if bDoRightEdge then begin
      Windows.MoveToEx(dc, nRightEdge, rcToken.Top, nil);
      Windows.LineTo(dc, nRightEdge, rcToken.Bottom + 1);
    end;
  end;
end;
{end}                                                                           //mh 1999-09-12

//bds 1/25/1998:
// Rewrite to support new SelectionMode property.
procedure TmwCustomEdit.PasteFromClipboard;
{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
var
  StartOfBlock: TPoint;
  EndOfBlock: TPoint;
  PasteMode: TSelectionMode;
  Mem: HGLOBAL;
  P: PChar;
  Tag: Integer;
begin
  // Check for our special format first.
  if Clipboard.HasFormat(mwEditClipboardFormat) then
  begin
    Clipboard.Open;
    try
      Mem := Clipboard.GetAsHandle(mwEditClipboardFormat);
      P := GlobalLock(Mem);
      if P <> NIL then
      begin
        if SelAvail then
//          FUndoList.AddChange(mwcrPasteDelete, fBlockBegin, fBlockEnd,          //tskurz 06/11/1999
          FUndoList.AddChange(mwcrSelDelete, fBlockBegin, fBlockEnd,            //th 1999-09-22
             PChar(SelText), SelectionMode);
        // Our format: SelectionMode value followed by text. See CopyToClipboard
        PasteMode := PSelectionMode(P)^;
        inc(P, SizeOf(TSelectionMode));
        if SelAvail then
        begin
          StartOfBlock := minPoint(fBlockBegin,fBlockEnd);                      //tskurz 06/11/1999
          EndOfBlock := maxPoint(fBlockBegin,fBlockEnd);                        //tskurz 06/11/1999
          fBlockBegin := StartOfBlock;                                          //tskurz 06/11/1999
          fBlockEnd := EndOfBlock;                                              //tskurz 06/11/1999
          if SelectionMode = smLine then
            // Pasting always occurs at column 0 when current selection is
            // smLine type
            StartOfBlock.X := 1;
        end else
          StartOfBlock := Point(CaretX, CaretY);
        Tag := 0;
        SetSelTextPrimitive(PasteMode, P, @Tag);
        EndOfBlock := BlockEnd;
{begin}                                                                         //th 1999-09-22
(*
        case PasteMode of
          smColumn:
            begin
              // Column pasting moves caret to beginning of line after block,
              // we have to fix it back up so we can select the block and
              // replace it.
              dec(EndOfBlock.Y);
              Inc(EndOfBlock.X, Tag);
            end;
          smLine:
            begin
              // Line pasting moves caret to the line after block,
              // we have to fix it back up so we can select the block and
              // replace it unless that last line was also selected
              if Tag = 0 then
                dec(EndOfBlock.Y);
              EndOfBlock.X := Length(Lines[EndOfBlock.Y-1]);
            end;
        else
          // no adjustment needed
        end;
*)
{end}                                                                           //th 1999-09-22
        FUndoList.AddChange(mwcrPaste, StartOfBlock, EndOfBlock,                //tskurz 06/11/1999
           PChar(SelText), PasteMode);
{begin}                                                                         //th 1999-09-22
        if PasteMode = smColumn then
          CaretXY := Point(
            Min(StartOfBlock.X, EndOfBlock.X),
            Max(StartOfBlock.Y, EndOfBlock.Y) + 1);
{end}
      end else
        raise EmwEditError.Create('Clipboard paste operation failed.');
    finally
      Clipboard.Close;
    end;
    EnsureCursorPosVisible;                                                     //th 1999-09-22
  // If our special format isn't there, check for regular text format.
  end else if Clipboard.HasFormat(CF_TEXT) then
  begin
    // Normal text is much easier...
    if SelAvail then
//      FUndoList.AddChange(mwcrPasteDelete, fBlockBegin,fBlockEnd,PChar(SelText),//tskurz 06/11/1999
      FUndoList.AddChange(mwcrSelDelete, fBlockBegin,fBlockEnd,PChar(SelText),  //th 1999-09-22
         SelectionMode);
    StartOfBlock := minPoint(fBlockBegin,fBlockEnd);                            //tskurz 06/11/1999
    EndOfBlock := maxPoint(fBlockBegin,fBlockEnd);                              //tskurz 06/11/1999
    fBlockBegin := StartOfBlock;                                                //tskurz 06/11/1999
    fBlockEnd := EndOfBlock;                                                    //tskurz 06/11/1999
    LockUndo;									//tskurz 06/11/1999
    SelText := Clipboard.AsText;
    UnLockUndo;									//tskurz 06/11/1999
    FUndoList.AddChange(mwcrPaste,StartOfBlock,fBlockBegin,PChar(SelText),      //tskurz 06/11/1999
       SelectionMode);
    EnsureCursorPosVisible;                                                     //th 1999-09-22
  end;
{$ELSE}
{end}                                                                           //bds 1/25/1999
var
   StartOfBlock: TPoint;                                                        //tskurz 12/10/1998
begin
  if Clipboard.HasFormat(CF_TEXT) then
  begin
    if SelAvail then
      FUndoList.AddChange(mwcrPasteDelete,fBlockBegin,fBlockEnd,PChar(GetSelText));  //tskurz 06/11/1999
    StartOfBlock := fBlockBegin;                                                //tskurz 12/10/1998
    SetSelText(Clipboard.AsText);                                               //tskurz 1/7/1999
    FUndoList.AddChange(mwcrPaste,StartOfBlock,fBlockBegin,PChar(GetSelText));  //tskurz 06/11/1999
    EnsureCursorPosVisible;                                                     //th 1999-09-22
  end;
{$ENDIF}                                                                        //bds 1/25/1999
end;

procedure TmwCustomEdit.SelectAll;
begin
  SetBlockBegin(Point(1, 1));
  if Lines.Count > 0 then
    SetBlockEnd(Point(Length(Lines[Lines.Count - 1]) + 1, Lines.Count{ - 1}));  //bds 12/20/1998
  CaretXY := Point(Length(Lines[Lines.Count-1])+1, Lines.Count);                //bds 12/20/1998
end;

procedure TmwCustomEdit.SetBlockBegin(Value: TPoint);
var nInval1, nInval2: integer;
begin
  Value.x := MinMax(Value.x, 1, fMaxLeftChar);
  Value.y := MinMax(Value.y, 1, Lines.Count);
{begin}                                                                         //mh 1999-09-12
{$IFDEF MWE_SELECTION_MODE}
  if (SelectionMode = smNormal) then
{$ENDIF}

    if (Value.y >= 1) and (Value.y <= Lines.Count) then
      Value.x := Min(Value.x, Length(Lines[Value.y - 1]) + 1)
    else
      Value.x := 1;
{end}                                                                           //mh 1999-09-12
  if SelAvail then begin
    if fBlockBegin.Y < fBlockEnd.Y then
    begin
      nInval1 := Min(Value.Y, fBlockBegin.Y);
      nInval2 := Max(Value.Y, fBlockEnd.Y);
    end else begin
      nInval1 := Min(Value.Y, fBlockEnd.Y);
      nInval2 := Max(Value.Y, fBlockBegin.Y);
    end;
    fBlockBegin := Value;
    fBlockEnd := Value;
    InvalidateLines(nInval1, nInval2);
  end else begin
    fBlockBegin := Value;
    fBlockEnd := Value;
  end;
end;

procedure TmwCustomEdit.SetBlockEnd(Value: TPoint);
var nLine: integer;
{$IFDEF MWE_MBCSSUPPORT}
    s: string;                                                                  //th 1999-09-15
{$ENDIF}
begin
  Value.x := MinMax(Value.x, 1, fMaxLeftChar);
  Value.y := MinMax(Value.y, 1, Lines.Count);
{begin}                                                                         //mh 1999-09-12
{$IFDEF MWE_SELECTION_MODE}
  if (SelectionMode = smNormal) then
{$ENDIF}
    if (Value.y >= 1) and (Value.y <= Lines.Count) then
      Value.x := Min(Value.x, Length(Lines[Value.y - 1]) + 1)
    else
      Value.x := 1;
  if (Value.X <> fBlockEnd.X) or (Value.Y <> fBlockEnd.Y) then begin
{end}                                                                           //mh 1999-09-12
{$IFDEF MWE_MBCSSUPPORT}                                                        //th 1999-09-15
    if Value.Y <= Lines.Count then
    begin
      s := Lines[Value.Y - 1];
      if (Length(s) >= Value.X) and (mbTrailByte = ByteType(s, Value.X)) then
        Dec(Value.X);
    end;
{$ENDIF}
{$IFDEF MWE_SELECTION_MODE}
    if (Value.X <> fBlockEnd.X) or (Value.Y <> fBlockEnd.Y) then
      if (SelectionMode = smColumn) and (Value.X <> fBlockEnd.X) then begin
{begin}                                                                         //th 1999-09-21
//        if (fBlockBegin.Y < fBlockEnd.Y) then nLine := Max(fBlockEnd.Y, Value.Y)
//                                         else nLine := Min(fBlockEnd.Y, Value.Y);
//        InvalidateLines(fBlockBegin.Y, nLine);
        InvalidateLines(
          Min(fBlockBegin.Y, Min(fBlockEnd.Y, Value.Y)),
          Max(fBlockBegin.Y, Max(fBlockEnd.Y, Value.Y)));
{end}        
        fBlockEnd := Value;
      end else begin
        nLine:= fBlockEnd.Y;
        fBlockEnd := Value;
        if (SelectionMode <> smColumn) or (fBlockBegin.X <> fBlockEnd.X) then   //th 1999-09-21
          InvalidateLines(nLine, fBlockEnd.Y);
      end;
{$ELSE}
    if (Value.X <> fBlockEnd.X) or (Value.Y <> fBlockEnd.Y) then begin
      nLine:= fBlockEnd.Y;
      fBlockEnd := Value;
      InvalidateLines(nLine, fBlockEnd.Y);
    end;
{$ENDIF}
  end;
end;

// jdj 12/09/1998:
// Smooths caret movement
procedure TmwCustomEdit.SetCaretX(Value: Integer);
var
  Len: integer;
begin
  if Value < 1 then Value := 1;
  {begin}                                                                       //bds 12/16/1998
//if Value > (fMaxLeftChar - fCharsInWindow) then Value := fMaxLeftChar - fCharsInWindow;
  if fScrollPastEOL then
  begin
    if Value > (fMaxLeftChar - fCharsInWindow) then
      Value := fMaxLeftChar - fCharsInWindow;
  end else begin
    {begin}                                                                     //gp 12/16/1998
    Len := Length(LineText) + 1;
    if Value > Len then
      Value := Length(LineText)+1;
    if Value >= (LeftChar + fCharsInWindow) then
      LeftChar := ((Value + 1) - fCharsInWindow)
    else if Value < LeftChar then LeftChar := Value;
    {end}                                                                       //gp 12/16/1998
  end;
  {end}                                                                         //bds 12/16/1998
  if (Value <> fCaretX + 1) then                                                //mh 02/20/1999
  begin                                                                         //mh 02/20/1999
    fCaretX := Value - 1;
    EnsureCursorPosVisible;                                                     //bds 12/17/1998
    UpdateCaret;                                                                //mh 02/20/1999
  end;
  SelectionChange;                                                              //Wvdm 1999-05-10
end;

procedure TmwCustomEdit.SetCaretY(Value: Integer);
var
  Len: integer;
begin
  if Value < 1 then Value := 1;
  if Value > Lines.Count then Value := Lines.Count;
  if (Value <> fCaretY + 1) then                                                //mh 02/20/1999
  begin                                                                         //mh 02/20/1999
    fCaretY := Value - 1;
    {begin}                                                                     //bds 12/16/1998
    //if PaintLock = 0 then                                                     //jdj 12/11/1998
    //  UpdateCaret;
    if not FScrollPastEOL then begin
      {begin}                                                                   //gp 12/16/1998
      Len := Length(LineText) + 1;
      if CaretX > Len then begin
        CaretX := Len;
        if CaretX < LeftChar then LeftChar := CaretX;                           //gp 12/16/1998
        exit;
      end;
      {end}                                                                     //gp 12/16/1998
    end;
    EnsureCursorPosVisible;                                                     //bds 12/17/1998
    UpdateCaret;                                                                //mh 02/20/1999
    {end}                                                                       //bds 12/16/1998
  end;                                                                          //mh 02/20/1999
  SelectionChange;                                                              //Wvdm 1999-05-10
end;

procedure TmwCustomEdit.SetFont(const Value: TFont);
var
  DC: HDC;
  Save: THandle;
  Metrics: TTextMetric;
  AveCW, MaxCW: Integer;
begin
  DC := GetDC(0);
  Save := SelectObject(DC, Value.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, Save);
  ReleaseDC(0, DC);
  with Metrics do
  begin
    AveCW := tmAveCharWidth;
    MaxCW := tmMaxCharWidth;
  end;
  case AveCW = MaxCW of
    True: inherited Font := Value;
    False:
      begin
        with fFontDummy do
        begin
          Color := Value.Color;
          Pitch := fpFixed;
          Size := Value.Size;
          Style := Value.Style;
        end;
        inherited Font := fFontDummy;
      end;
  end;
//  if FLineNumbers then SetLineNumbers(true);                                    //j-la 1/3/1999 //mh 1999-05-12
  if fGutter.ShowLineNumbers then GutterChanged(Self);                          //mh 1999-09-12
end;

procedure TmwCustomEdit.SetGutterWidth(Value: Integer);
begin
  Value := Max(Value, 0);
  if fGutterWidth <> Value then begin
    fGutterWidth := Value;
    if HandleAllocated then                                                     //ajb 1999-08-26
      fCharsInWindow := (ClientWidth - fGutterWidth - 2) div fCharWidth;
    fTextOffset := fGutterWidth + 2;                                            //jdj 12/12/1998
    UpdateScrollBars(FALSE);                                                    //jdj 12/12/1998
    Invalidate;                                                                 //bds 2/24/1999
  end;
end;

procedure TmwCustomEdit.SetLeftChar(Value: Integer);
begin
  Value := MinMax(Value, 1, fMaxLeftChar - fCharsInWindow) - 1;
  if Value <> fLeftChar then
  begin
    fLeftChar := Value;
    fTextOffset := fGutterWidth + 2 - fLeftChar * fCharWidth;
    UpdateScrollBars(FALSE);
    InvalidateLines(-1, -1);
  end;
end;

procedure TmwCustomEdit.SetLines(Value: TStrings);
begin
  if HandleAllocated then
    Lines.Assign(Value);
end;

procedure TmwCustomEdit.SetLineText(Value: String);
begin
  if (Lines.Count > 0) and
    (fCaretY <= Lines.Count - 1) then Lines[fCaretY] := Value;
end;

// jdj 12/09/1998:
// Stops putting name in control when loading in IDE and Text is empty
procedure TmwCustomEdit.SetName(const Value: TComponentName);
var
  OldName: string;
begin
  OldName := Name;
  inherited SetName(Value);
//  if csDesigning in ComponentState then
  if (csDesigning in ComponentState) and                                        //jdj 12/09/1998
  (not (csLoading in ComponentState)) then
    if OldName = TrimRight(Text) then
      Text := Value;
end;

procedure TmwCustomEdit.SetScrollBars(const Value: TScrollStyle);
begin
  if (FScrollBars <> Value) then
  begin
    FScrollBars := Value;
    RecreateWnd;
    UpdateScrollBars(FALSE);
    Invalidate;                                                                 //bds 2/24/1999
  end;
end;

//bds 12/31/1998:
// Rewrite to support new SelectionMode property.  Guts are now in
// SetSelTextPrimitive
procedure TmwCustomEdit.SetSelText(Const Value: String);
{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
begin
  SetSelTextPrimitive(smNormal, PChar(Value), NIL);
{$ELSE}
{end}                                                                           //bds 1/25/1999
var
  BB, BE: TPoint;
  TempString: String;
  Temp: TStringList;
  TempY: Integer;

  procedure DeleteSelection;
  var
    I, Count, Start: Integer;
    TempString2: String;
  begin
    IncPaintLock;
    CaretX := BB.X;
    if BB.Y = BE.Y then
    begin
      TempString := Lines[BB.Y - 1];
      Delete(TempString, BB.X, BE.X - BB.X);
      Lines[BB.Y - 1] := TrimRight(TempString);
      TempString := '';
    end else
    begin
      CaretY := BB.Y;
      TempString := Lines[BB.Y - 1];
      Delete(TempString, BB.X, Length(TempString));
      TempString2 := Lines[BE.Y - 1];
      Delete(TempString2, 1, BE.X - 1);
      TempString := TempString + TempString2;
      Start := BB.Y - 1;
      Count := BE.Y - BB.Y;
      {begin}                                                                   //CdeB 12/16/1998
      for i:= 0 to Marks.count-1 do
        if Marks[i].Line >= BE.Y then
          Marks[i].Line := Marks[i].Line - count
        else if Marks[i].Line > BB.Y then
          Marks[i].Line:= BB.Y;
      {end}                                                                     //CdeB 12/16/1998
//      for I := 1 to Count do Lines.Delete(Start);                             //th 1999-09-15
      for I := Start + Count - 1 downto Start do Lines.Delete(I);
      Lines[Start] := TrimRight(TempString);
    end;
    DecPaintLock;
  end;

  procedure InsertText;
  var
    I, Len: Integer;
    TempString2, Helper: String;
    j: Integer;                                                                 //CdeB 12/16/1998
  begin
    if Value = '' then exit;
    {begin}                                                                     //CdeB 12/16/1998
    // Convert #10 into #10#13
    SetLength(Helper, Length(Value)*2);
    j:= 0;
    for i:= 1 to length(Value) do
      if ((i=1) and (Value[i]=#10)) or ((i>1) and (Value[i]=#10) and (Value[i-1]<>#13)) then
      Begin
        inc(j);
        Helper[j]:= #13;
        inc(j);
        Helper[j]:= Value[i];
      end else Begin
        inc(j);
        Helper[j]:= Value[i];
      end;
    SetLength(Helper, j);
    Temp.Text := Helper + #13#10;
    {end}                                                                       //CdeB 12/16/1998
    IncPaintLock;
    Temp.Text := Value + #13#10;
    if Temp.Count = 1 then
    begin
      TempString := LineText;
      Len := fCaretX - Length(TempString);
      if Len > 0 then
      begin
        Helper := StringOfChar(' ', Len);
        TempString := TempString + Helper;
      end;
      Insert(Temp[0], TempString, CaretX);
      LineText := TempString;
      CaretX := CaretX + Length(Temp[0]);
      TempString := '';
    end else
    begin
      TempString := LineText;
      Len := CaretX - Length(TempString);
      if Len > 0 then
      begin
        Helper := StringOfChar(' ', Len);
        TempString := TempString + Helper;
      end;
      TempString := Copy(TempString, 1, fCaretX) + Temp[0];
      TempString2 := Copy(LineText, CaretX, Length(LineText));
      Lines[fCaretY] := TempString;
      TempString := '';
      TempY := CaretY;
      for I := 1 to Temp.Count - 2 do
      begin
        Lines.Insert(TempY, Temp[I]);
        inc(TempY);
      end;
      {begin}                                                                   //CdeB 12/16/1998
      for i:= 0 to Marks.count-1 do
        if Marks[i].Line >= CaretY then
          Marks[i].Line := Marks[i].Line + Temp.Count - 1;
      {end}                                                                     //CdeB 12/16/1998
      Lines.Insert(TempY, Temp[Temp.Count - 1] + TempString2);
      CaretX := Length(Temp[Temp.Count - 1]) + 1;
      inc(TempY);
      CaretY := TempY;
      TempString2 := '';
    end;
    DecPaintLock;
  end;
begin
  IncPaintLock;
  Lines.BeginUpdate;
  Temp := TStringList.Create;
  try
    BB := BlockBegin;
    BE := BlockEnd;
    if SelAvail then
    begin
      DeleteSelection;
      InsertText;
    end else InsertText;
  finally
    Temp.Free;
  end;
  Lines.EndUpdate;
  DecPaintLock;
{$ENDIF}                                                                        //bds 1/25/1999
end;

{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
procedure TmwCustomEdit.SetSelTextPrimitive(PasteMode: TSelectionMode;
   Value: PChar; Tag: PInteger);
var
  BB, BE: TPoint;
  TempString: String;

  procedure DeleteSelection;
  var
//    cx, cy,                                                                   //th 1999-09-22
    x, MarkOffset: Integer;                                                     //th 1999-09-22
    UpdateMarks: boolean;
{$IFDEF MWE_MBCSSUPPORT}
    l, r: Integer;
{$ENDIF}
  begin
//    cx := BB.X;                                                               //th 1999-09-22
//    cy := BB.Y;                                                               //th 1999-09-22
    UpdateMarks := FALSE;
    MarkOffset := 0;
{begin}                                                                         //th 1999-09-21
(*
    if BB.Y = BE.Y then
    begin
      // We delete selected based on the current selection mode, but paste
      // what's on the clipboard according to what it was when copied.
      case SelectionMode of
        smNormal, smColumn:
          begin
            // Normal and column are the same if selction is on one line.
            Lines[BB.Y - 1] := TrimRight(Copy(Lines[BB.Y - 1], 1, BB.X-1) +
               Copy(Lines[BB.Y - 1], BE.X, MaxInt));
          end;
        smLine:
          begin
            Lines.Delete(BB.Y-1);
            cx := 1; // smLine deletion always resets to first column.
            UpdateMarks := TRUE;
            MarkOffset := 1;
          end;
      end;
    end else begin
*)
{end}                                                                           //th 1999-09-21
      case SelectionMode of
        smNormal:
          begin
            // Create a string that contains everything on the first line up to
            // the selection mark, and everything on the last line after the
            // selection mark.
            TempString := Copy(Lines[BB.Y - 1], 1, BB.X-1) +
               Copy(Lines[BE.Y - 1], BE.X, MaxInt);
            // Delete all lines in the selection range.
//            for x := BE.Y-1 downto BB.Y-1 do                                  //th 1999-09-21
            for x := BE.Y-1 downto BB.Y do                                      //th 1999-09-21
              Lines.Delete(x);
            // Put the stuff that was outside of selection back in.
//            Lines.Insert(BB.Y-1, TrimRight(TempString));                      //th 1999-09-21
            Lines[BB.Y - 1] := TrimRight(TempString);                           //th 1999-09-21 // why trim right?
            UpdateMarks := TRUE;
            CaretXY := BB;                                                      //mh 1999-09-22     
          end;
        smColumn:
          begin
            // swap X if needed
            if BB.X > BE.X then
{$IFDEF MWE_COMPILER_3_UP}
              SwapInt(BB.X, BE.X);
{$ELSE}
            begin
              x := BB.X;
              BB.X := BE.X;
              BE.X := x;
            end;
{$ENDIF}
            for x := BB.Y-1 to BE.Y-1 do
            begin
              TempString := Lines[x];
{$IFNDEF MWE_MBCSSUPPORT}                                                       //th 1999-09-21
              Delete(TempString, BB.X, BE.X - BB.X);
{begin}                                                                         //th 1999-09-21
{$ELSE}
              l := BB.X;
              r := BE.X;
              MBCSGetSelRangeInLineWhenColumnSelectionMode(TempString, l, r);
              Delete(TempString, l, r - l);
{$ENDIF}
{end}
              Lines[x] := TrimRight(TempString);
            end;
            // Lines never get deleted completely, so keep caret at end.
//            cy := BE.Y;                                                       //th 1999-09-22
            CaretXY := Point(BB.X, fBlockEnd.Y);                                //th 1999-09-22
            // Column deletion never removes a line entirely, so no mark
            // updating is needed here.
          end;
        smLine:
          begin
{begin}                                                                         //th 1999-09-22
            if BE.Y = Lines.Count then
            begin
              Lines[BE.Y - 1] := '';
              for x := BE.Y - 2 downto BB.Y - 1 do
                Lines.Delete(x);
            end else
{end}                                                                           //th 1999-09-22
              for x := BE.Y-1 downto BB.Y-1 do
                Lines.Delete(x);
            // smLine deletion always resets to first column.
//            cx := 1;                                                          //th 1999-09-22
            CaretXY := Point(1, BB.Y);                                          //th 1999-09-22
            UpdateMarks := TRUE;
            MarkOffset := 1;
          end;
      end;
//    end;                                                                      //th 1999-09-21

    // Update marks
    if UpdateMarks then
      for x := 0 to Marks.Count-1 do
        if Marks[x].Line >= BE.Y then
          Marks[x].Line := Marks[x].Line - (BE.Y - BB.Y) - MarkOffset
        else if Marks[x].Line > BB.Y then
          Marks[x].Line:= BB.Y;

    // Reset caret pos
//    CaretXY := Point(cx, cy);                                                 //th 1999-09-22
  end;

{begin}                                                                         //th 1999-09-20
(*
  procedure InsertText;
  var
    StartLine, InsertedLines, x: integer;
    LastLen, Len: Integer;
    TempString2: String;
    P, Start: PChar;
    Str: string;
  begin
    // Using a TStringList to do this would be easier, but if we're dealing
    // with a large block of text, it would be very inefficient.  Consider:
    // Assign Value parameter to TStringList.Text: that parses through it and
    // creates a copy of the string for each line it finds.  That copy is passed
    // to the Add method, which in turn creates a copy.  Then, when you actually
    // use an item in the list, that creates a copy to return to you.  That's
    // 3 copies of every string vs. our one copy below.  I'd prefer no copies,
    // but we aren't set up to work with PChars that well.

    StartLine := CaretY;
    InsertedLines := 0;
    LastLen := 0;
    P := PChar(Value);
    if (P <> NIL) and (P[0] <> #0) then
    begin
      // We delete selected based on the current selection mode, but paste
      // what's on the clipboard according to what it was when copied.
      if PasteMode = smNormal then
      begin
        TempString := Copy(LineText, 1, CaretX - 1);
        if fCaretX > Length(TempString) then
          TempString := TempString+StringOfChar(' ',fCaretX-Length(TempString));
        TempString2 := Copy(LineText, CaretX, Length(LineText) - (CaretX - 1));
        Lines.Delete(fCaretY);
      end;
      while P^ <> #0 do
      begin
        Start := P;
        while not (P^ in [#0, #10, #13]) do
          inc(P);

        SetLength(Str, P - Start);
        Move(Start^, Str[1], P - Start);

        // We delete selected based on the current selection mode, but paste
        // what's on the clipboard according to what it was when copied.
        case PasteMode of
          smNormal:
            begin
              if TempString <> '' then
              begin
                if fCaretY = Lines.Count then
                  Lines.Add(TempString + Str)
                else
                  Lines.Insert(fCaretY, TempString + Str);
                LastLen := Length(TempString) + P - Start;
                TempString := '';
              end else begin
                if fCaretY = Lines.Count then
                  Lines.Add(Str)
                else
                  Lines.Insert(fCaretY, Str);
                LastLen := P - Start;
              end;
              inc(fCaretY);
              inc(InsertedLines);
            end;
          smColumn:
            begin
              // Insert string at current position
              if fCaretY = Lines.Count then
              begin
                Lines.Add(StringOfChar(' ', fCaretX) + Str);
                inc(InsertedLines);
              end else begin
                TempString := Lines[fCaretY];
                Len := Length(TempString);
                if Len < CaretX then
                  TempString := TempString + StringOfChar(' ', CaretX-Len-1);
                Insert(Str, TempString, CaretX);
                Lines[fCaretY] := TempString;
              end;
              inc(fCaretY);
              if Tag <> NIL then
                Tag^ := P - Start;
            end;
          smLine:
            begin
              // Insert string before current line
              if fCaretY > Lines.Count-1 then
                Lines.Add(Str)
              else
                Lines.Insert(fCaretY, Str);
              inc(fCaretY);
              inc(InsertedLines);
            end;
        end;
        if P^ = #13 then Inc(P);
        if P^ = #10 then Inc(P);
      end;
      // We delete selected based on the current selection mode, but paste
      // what's on the clipboard according to what it was when copied.
      case PasteMode of
        smNormal:
          begin
            if TempString2 <> '' then
            begin
              if fCaretY > 0 then
                dec(fCaretY);
              Lines[fCaretY] := Lines[fCaretY] + TempString2;
            end else begin
              dec(fCaretY);
            end;
            fCaretX := LastLen;
          end;
        smColumn:
          begin
            if fCaretY = Lines.Count then
            begin
              Lines.Add(StringOfChar(' ', fCaretX));
              inc(InsertedLines);
              //CaretX := 1;                                                    //tskurz 06/11/1999
            end;
          end;
        smLine:
          begin
            if fCaretY = Lines.Count then
            begin
              dec(fCaretY);
              if Tag <> NIL then
                Tag^ := -1;
            end;
          end;
      end;
*)
  procedure InsertText;

    function GetEOL(pStart: PChar): PChar;
    begin
      Result := pStart;
      while not (Result^ in [#0, #10, #13]) do
        Inc(Result);
    end;

    function InsertNormal: Integer;
    var
      sLeftSide: string;
      sRightSide: string;
      Str: string;
      Start: PChar;
      P: PChar;
    begin
      Result := 0;
      sLeftSide := Copy(LineText, 1, CaretX - 1);
      if fCaretX > Length(sLeftSide) then
        sLeftSide := sLeftSide + StringOfChar(' ',fCaretX-Length(sLeftSide));
      sRightSide := Copy(LineText, CaretX, Length(LineText) - (CaretX - 1));

      // step1: insert the first line of Value into current line
      Start := PChar(Value);
      P := GetEOL(Start);
      if P = Start then
        Lines[fCaretY] := sLeftSide
      else
        if p^ <> #0 then
          Lines[fCaretY] := sLeftSide + Copy(Value, 1, P - Start)
        else
          Lines[fCaretY] := sLeftSide + Value + sRightSide;

      // step2: insert left lines of Value
      while p^ <> #0 do
      begin
        if p^ = #13 then
          Inc(p);
        if p^ = #10 then
          Inc(p);
        Inc(fCaretY);
        Start := P;
        P := GetEOL(Start);
        if P = Start then
        begin
          if p^ <> #0 then
            Lines.Insert(fCaretY, '')
          else
            Lines.Insert(fCaretY, sRightSide);
        end
        else
        begin
          SetLength(Str, P - Start);
          Move(Start^, Str[1], P - Start);
          if p^ <> #0 then
            Lines.Insert(fCaretY, Str)
          else
            Lines.Insert(fCaretY, Str + sRightSide);
        end;
        Inc(Result);
      end;
      fCaretX := Length(Lines[fCaretY]) - Length(sRightSide);
    end;

    function InsertColumn: Integer;
    var
      Str: string;
      Start: PChar;
      P: PChar;
      Len: Integer;
      InsertPos: Integer;
    begin
      // Insert string at current position
      InsertPos := CaretX;
      Start := PChar(Value);
      repeat
        P := GetEOL(Start);
        if P <> Start then
        begin
          SetLength(Str, P - Start);
          Move(Start^, Str[1], P - Start);
          if fCaretY = Lines.Count then
            Lines.Add(StringOfChar(' ', InsertPos - 1) + Str)
          else
          begin
            TempString := Lines[fCaretY];
            Len := Length(TempString);
            if Len < InsertPos then
              TempString :=
                TempString + StringOfChar(' ', InsertPos - Len - 1) + Str
            else
            begin
{$IFDEF MWE_MBCSSUPPORT}
              if mbTrailByte = ByteType(TempString, InsertPos) then
                Insert(Str, TempString, InsertPos + 1)
              else
{$ENDIF}
                Insert(Str, TempString, InsertPos);
            end;
            Lines[fCaretY] := TempString;
          end;
        end;
        if Tag <> nil then
          Tag^ := P - Start;
        if P^ = #13 then
        begin
          Inc(P);
          if P^ = #10 then
            Inc(P);
          Inc(fCaretY);
        end;
        Start := P;
      until P^ = #0;

      Inc(fCaretX, Length(Str));
      Result := 0;
    end;

    function InsertLine: Integer;
    var
      Start: PChar;
      P: PChar;
      Str: string;
      n: Integer;                                                               //th 1999-09-22
    begin
      Result := 0;
      fCaretX := 0;                                                             //th 1999-09-22
      // Insert string before current line
      Start := PChar(Value);
      repeat
        P := GetEOL(Start);
        if P <> Start then
        begin
          SetLength(Str, P - Start);
          Move(Start^, Str[1], P - Start);
        end
        else
          Str := '';
{begin}                                                                         //th 1999-09-22
        if (P^ = #0) then
        begin
          n := Lines.Count;
          if (n > fCaretY) then
            Lines[fCaretY] := Str + Lines[fCaretY]
          else
            Lines.Add(Str);
          fCaretX := Length(Str);
        end else begin
{end}                                                                           //th 1999-09-22
          Lines.Insert(fCaretY, Str);
          Inc(fCaretY);
          Inc(Result);
          if P^ = #13 then
            Inc(P);
          if P^ = #10 then
            Inc(P);
          Start := P;
        end;                                                                    //th 1999-09-22
      until P^ = #0;
//      fCaretX := 0;                                                           //th 1999-09-22
    end;

  var
    StartLine: Integer;
    InsertedLines: Integer;
    x: Integer;
  begin
    if Value = '' then
      Exit;

    // Using a TStringList to do this would be easier, but if we're dealing
    // with a large block of text, it would be very inefficient.  Consider:
    // Assign Value parameter to TStringList.Text: that parses through it and
    // creates a copy of the string for each line it finds.  That copy is passed
    // to the Add method, which in turn creates a copy.  Then, when you actually
    // use an item in the list, that creates a copy to return to you.  That's
    // 3 copies of every string vs. our one copy below.  I'd prefer no copies,
    // but we aren't set up to work with PChars that well.

    StartLine := CaretY;
    case PasteMode of
      smNormal:
        InsertedLines := InsertNormal;
      smColumn:
        InsertedLines := InsertColumn;
      smLine:
        InsertedLines := InsertLine;
      else
        InsertedLines := 0;
    end;

      // We delete selected based on the current selection mode, but paste
      // what's on the clipboard according to what it was when copied.
{end}                                                                           //th 1999-09-20
    // Update marks
    if InsertedLines > 0 then
      for x := 0 to Marks.Count-1 do
        if Marks[x].Line >= StartLine then
          Marks[x].Line := Marks[x].Line + InsertedLines;

    // Force caret reset
    CaretXY := CaretXY;
  end;

//var InsertAfterLastLine: boolean;                                             //th 1999-09-22
begin
  IncPaintLock;
  Lines.BeginUpdate;
  try
    BB := BlockBegin;
    BE := BlockEnd;
    if SelAvail then
    begin
//      InsertAfterLastLine := (SelectionMode = smLine) and (BE.Y = Lines.Count); //th 1999-09-22
      DeleteSelection;
//      if InsertAfterLastLine then                                             //th 1999-09-22
//        fCaretY := Lines.Count;                                               //th 1999-09-22

    end;
    if (Value <> NIL) and (Value[0] <> #0) then
      InsertText;
    if Lines.Count = 0 then
      Lines.Add('');
    if CaretY < 1 then
      CaretY := 1;
  finally
    Lines.EndUpdate;
    DecPaintLock;
  end;
end;
{$ENDIF}
{end}                                                                           //bds 1/25/1999

procedure TmwCustomEdit.SetText(const Value: String);
begin
{begin}                                                                         //mh 1999-05-12
  TmwEditList(fLines).fLoading:= TRUE;
  try
    Lines.Text := Value;
  finally
    TmwEditList(fLines).fLoading:= FALSE;
  end;
{end}                                                                           //mh 1999-05-12
  Invalidate;                                                                   //bds 2/24/1999
end;

procedure TmwCustomEdit.SetTopLine(Value: Integer);
var
  Delta: Integer;                                                               //th 1999-09-15
begin
  // don't use MinMax here, it will fail in design mode (Lines.Count is zero,
  // but the painting code relies on TopLine >= 1)
  Value := Min(Value, Lines.Count);
  Value := Max(Value, 1);
  if Value <> fTopLine + 1 then
  begin
    Delta := (fTopLine + 1) - Value;
    fTopLine := Value - 1;
    UpdateScrollBars(FALSE);
    if Abs(Delta) < fLinesInWindow then                                         //th 1999-09-15
      ScrollWindow(Handle, 0, fTextHeight * Delta, nil, nil)                    //th 1999-09-15
    else
      Invalidate;                                                               //bds 2/24/1999
  end;
end;

procedure TmwCustomEdit.ShowCaret;
begin
  if Windows.ShowCaret(Handle) then fCaretVisible := True;
end;

procedure TmwCustomEdit.UpdateCaret;
var
  CX, CY: Integer;
{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
  cf: TCompositionForm;
{$ENDIF}
begin
  if (not Focused) or (PaintLock <> 0) then                                     //mh 02/20/1999
    fNeedsUpdateCaret := TRUE                                                   //mh 02/20/1999
  else begin                                                                    //mh 02/20/1999
    fNeedsUpdateCaret := FALSE;                                                 //mh 02/20/1999
    {begin}                                                                     //bds 12/17/1998
  //CX := CaretXPix;
  //CY := CaretYPix;
    CX := CaretXPix + FCaretOffset.X;
    CY := CaretYPix + FCaretOffset.Y;
    {end}                                                                       //bds 12/17/1998
    SetCaretPos(CX, CY);
    ShowCaret;
    if (CX < fGutterWidth) or (CX > ClientWidth) or
//      (CY < 0) or (CY > ClientHeight - fTextHeight) then                      //th 1999-09-15
      (CY < 0) or (CY > ClientHeight) then                                      //th 1999-09-15
      HideCaret;

{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
    cf.dwStyle := CFS_POINT;
    cf.ptCurrentPos := Point(CX, CY);
    ImmSetCompositionWindow(ImmGetContext(Handle), @cf);
{$ENDIF}
  end;
end;

procedure TmwCustomEdit.UpdateScrollBars(Force: boolean);
var
  ScrollInfo: TScrollInfo;
  nMaxScroll: integer;
begin
  if not HandleAllocated or ((PaintLock <> 0) and not Force) then
    fNeedsUpdateSB := TRUE
  else begin
    fNeedsUpdateSB := FALSE;
    if fScrollBars <> ssNone then
    begin
      ScrollInfo.cbSize := SizeOf(ScrollInfo);
      ScrollInfo.fMask := SIF_ALL or SIF_DISABLENOSCROLL;
      ScrollInfo.nMin := 1;
      ScrollInfo.nTrackPos := 0;
      if fScrollBars in [ssBoth, ssVertical] then
      begin
        nMaxScroll := LinesInWindow + Lines.Count - 1;
        if nMaxScroll <= MAX_SCROLL then
        begin
          ScrollInfo.nMax := Max(1, nMaxScroll);
          ScrollInfo.nPage := LinesInWindow;
          ScrollInfo.nPos := TopLine;
        end else
        begin
          // see Brad's description of MulDiv in the Print method
          ScrollInfo.nMax := MAX_SCROLL;
          ScrollInfo.nPage := MulDiv(MAX_SCROLL, LinesInWindow, nMaxScroll);
          ScrollInfo.nPos := MulDiv(MAX_SCROLL, TopLine, nMaxScroll);
        end;
        SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
      end;
      if fScrollBars in [ssBoth, ssHorizontal] then
      begin
        ScrollInfo.nMax := fMaxLeftChar - fCharsInWindow;                       //bds 12/17/1998
        ScrollInfo.nPage := CharsInWindow;
        ScrollInfo.nPos := LeftChar;
        SetScrollInfo(Handle, SB_HORZ, ScrollInfo, True);
      end;
    end;
  end;
end;

procedure TmwCustomEdit.WMEraseBkgnd(var Message: TMessage);
begin
  Message.Result := 1;
end;

procedure TmwCustomEdit.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  inherited;
  Msg.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;

  if fWantTabs then                                                             //ar 1999-05-10
    Msg.Result := Msg.Result or DLGC_WANTTAB;                                   //ar 1999-05-10
end;


procedure TmwCustomEdit.WMHScroll(var Message: TWMScroll);
{begin}                                                                         //mh 1999-05-12
// old lines deleted                                                            //mh 1999-08-20
begin
  case Message.ScrollCode of
      // Scrolls to start / end of the line
    SB_TOP: LeftChar := 1;
    SB_BOTTOM: LeftChar := MaxLeftChar;
      // Scrolls one char left / right
    SB_LINEDOWN: LeftChar := LeftChar + 1;
    SB_LINEUP: LeftChar := LeftChar - 1;
      // Scrolls one page of chars left / right
    SB_PAGEDOWN: LeftChar := LeftChar + CharsInWindow;
    SB_PAGEUP: LeftChar := LeftChar - CharsInWindow;
      // Scrolls to the current scroll bar position
    SB_THUMBPOSITION,
    SB_THUMBTRACK: LeftChar := Message.Pos;
      // Ends scroll = do nothing
//  SB_ENDSCROLL: LeftChar := LeftChar;
  end;
end;

{end}                                                                           //mh 1999-05-12

procedure TmwCustomEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  HideCaret;
  Windows.DestroyCaret;
  if FHideSelection and SelAvail then Invalidate;                               //bds 12/16/1998
  //free memory bitmap
{$IFNDEF MWE_DRAW_NOBMP}
//  fTextBM.Width := 1;                                                           //gp 12/30/1998, //gp 1/9/1999 - changed from 0 to 1 to prevent various problems //mh 1999-09-12
//  fTextBM.Height := 1;                                                          //gp 12/30/1998, //gp 1/9/1999 - changed from 0 to 1 to prevent various problems //mh 1999-09-12
{$ENDIF}
end;

procedure TmwCustomEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  InitializeCaret;
  if FHideSelection and SelAvail then Invalidate;
end;

procedure TmwCustomEdit.WMSize(var Message: TWMSize);
begin
  inherited;
  fCharsInWindow := (ClientWidth - fGutterWidth - 2) div fCharWidth;
  fLinesInWindow := ClientHeight div fTextHeight;                               //gp 1/10/1999 - changed to procedure call //mh 1999-09-12
  // removed various obsolete lines                                             //mh 1999-05-12
  UpdateScrollbars(FALSE);                                                      //mh 1999-05-12
end;

procedure TmwCustomEdit.WMVScroll(var Message: TWMScroll);
{begin}                                                                         //ra 1999-08-19
var s: ShortString;
    rc: TRect;
    pt: TPoint;
begin
  case Message.ScrollCode of
      // Scrolls to start / end of the text
    SB_TOP: TopLine := 1;
    SB_BOTTOM: TopLine := Lines.Count;
      // Scrolls one line up / down
    SB_LINEDOWN: TopLine := TopLine + 1;
    SB_LINEUP: TopLine := TopLine - 1;
      // Scrolls one page of lines up / down
    SB_PAGEDOWN: TopLine := TopLine + fLinesInWindow;
    SB_PAGEUP: TopLine := TopLine - fLinesInWindow;
      // Scrolls to the current scroll bar position
    SB_THUMBPOSITION,
    SB_THUMBTRACK:
      begin
        if Lines.Count > MAX_SCROLL then
          TopLine := MulDiv(LinesInWindow + Lines.Count - 1, Message.Pos, MAX_SCROLL)
        else
          TopLine := Message.Pos;
        if fShowScrollHint then begin
          s := Format(MWS_ScrollInfoFmt, [TopLine]);
{$IFDEF MWE_COMPILER_3_UP}                                                      //mh 1999-08-20
          rc := fScrollHint.CalcHintRect(200, s, nil);
{$ELSE}
          rc := Rect(0, 0, fScrollHint.Canvas.TextWidth(s) + 6,
                           fScrollHint.Canvas.TextHeight(s) + 4);
{$ENDIF}
          pt := ClientToScreen(Point(ClientWidth - rc.Right - 4, 10));
          OffsetRect(rc, pt.x, pt.y);
          fScrollHint.ActivateHint(rc, s);
{$IFNDEF MWE_COMPILER_3_UP}
// this is a quick hack to get the text updated. Any better solution?           //mh 1999-08-20
          fScrollHint.Invalidate;
{$ENDIF}
          fScrollHint.Update;                                                   //mh 1999-09-15
        end;
      end;
      // Ends scrolling
    SB_ENDSCROLL:
      if fShowScrollHint then fScrollHint.ActivateHint(Rect(0, 0, 0, 0), '');
  end;
  Update;                                                                       //th 1999-09-15
end;
{end}                                                                           //ra 1999-08-19

{begin}                                                                         //th 1999-09-15
// procedure TmwCustomEdit.ScanFrom(Index: Integer);
function TmwCustomEdit.ScanFrom(Index: integer): integer;
//var I: Integer;                                                               //th 1999-09-15
begin
(*
  if Index >= Lines.Count - 1 then exit;
  I := Index;
  fHighLighter.SetLine(Lines[I],I);                                             //aj 1999-02-22
  inc(I);
  fHighLighter.NextToEol;                                                       //mh 1999-08-22
  while fHighLighter.GetRange <> fLines.Objects[I] do
  begin
    Lines.Objects[I] := fHighLighter.GetRange;
    fHighLighter.SetLine(Lines[I],I);                                           //aj 1999-02-22
    fHighLighter.NextToEol;                                                     //mh 1999-08-22
    inc(I);
    if I = Lines.Count then break;
  end;
*)
  Result := Index;
  if Index >= Lines.Count - 1 then Exit;
  fHighLighter.SetLine(Lines[Result], Result);                                  //aj 1999-02-22
  inc(Result);
  fHighLighter.NextToEol;                                                       //mh 1999-08-22
  while fHighLighter.GetRange <> fLines.Objects[Result] do
  begin
    Lines.Objects[Result] := fHighLighter.GetRange;
    fHighLighter.SetLine(Lines[Result],Result);                                 //aj 1999-02-22
    fHighLighter.NextToEol;                                                     //mh 1999-08-22
    inc(Result);
    if Result = Lines.Count then break;
  end;
  Dec(Result);
end;

procedure TmwCustomEdit.ListAdded(Sender: TObject);
var
  LastIndex: Integer;
begin
  if Assigned(fHighLighter) then
  begin
    if Lines.Count > 1 then
    begin
      LastIndex := Lines.Count - 1;
      fHighLighter.SetRange(Lines.Objects[LastIndex - 1]);
      fHighLighter.SetLine(Lines[LastIndex - 1],LastIndex-1);                   //aj 1999-02-22
      fHighLighter.NextToEol;                                                   //mh 1999-08-22
      Lines.Objects[LastIndex] := fHighLighter.GetRange;
    end else
    begin
      fHighLighter.ReSetRange;
      Lines.Objects[0] := fHighLighter.GetRange;
    end;
  end;
  LastIndex := Lines.Count;                                                     //th 1999-09-15
  InvalidateLines(LastIndex, LastIndex);                                        //th 1999-09-15
  InvalidateGutter(LastIndex, LastIndex);                                       //th 1999-09-15
end;

procedure TmwCustomEdit.ListDeleted(Index: Integer);
begin
{begin}                                                                         //mh 1999-08-22
  if Assigned(fHighlighter) and (Lines.Count >= 1) then
    if (Index > 0) then begin
      fHighLighter.SetRange(Lines.Objects[Index - 1]);
      ScanFrom(Index - 1);
    end else begin
      fHighLighter.ReSetRange;
      Lines.Objects[0] := fHighLighter.GetRange;
      if (Lines.Count > 1) then ScanFrom(0);
    end;
(*
  if Assigned(fHighLighter) then
    begin
      if Lines.Count > 1 then
        begin
          if Index > 0 then
            begin
              fHighLighter.SetRange(Lines.Objects[Index - 1]);
              ScanFrom(Index - 1);
            end
          else
            begin
              fHighLighter.ReSetRange;
              Lines.Objects[0] := fHighLighter.GetRange;
              ScanFrom(0);
            end;
        end
      else if Lines.Count = 1 then
        begin
          fHighLighter.ReSetRange;
          Lines.Objects[0] := fHighLighter.GetRange;
        end;
    end;
*)
{end}                                                                           //mh 1999-08-22
//  UpdateScrollBars(TRUE);                                                       //mh 02/20/1999 //th 1999-09-19
  InvalidateLines(Index + 1, MaxInt);                                           //th 1999-09-15
  InvalidateGutter(Index + 1, MaxInt);                                          //th 1999-09-15
end;

procedure TmwCustomEdit.ListInserted(Index: Integer);
begin
{begin}                                                                         //mh 1999-08-22
  if Assigned(fHighlighter) and (Lines.Count >= 1) then
    if (Index > 0) then begin
      fHighLighter.SetRange(Lines.Objects[Index - 1]);
      ScanFrom(Index - 1);
    end else begin
      fHighLighter.ReSetRange;
      Lines.Objects[0] := fHighLighter.GetRange;
      if (Lines.Count > 1) then ScanFrom(0);
    end;
(*
  if Assigned(fHighLighter) then
    begin
      if Lines.Count > 1 then
        begin
          if Index > 0 then
            begin
              fHighLighter.SetRange(Lines.Objects[Index - 1]);
              ScanFrom(Index - 1);
            end
          else
            begin
              fHighLighter.ReSetRange;
              Lines.Objects[0] := fHighLighter.GetRange;
              ScanFrom(0);
            end;
        end
      else if Lines.Count = 1 then
        begin
          fHighLighter.ReSetRange;
          Lines.Objects[0] := fHighLighter.GetRange;
        end;
    end;
*)
{end}                                                                           //mh 1999-08-22
//  UpdateScrollBars(TRUE);                                                       //mh 02/20/1999 //th 1999-09-19
  InvalidateLines(Index + 1, TopLine + LinesInWindow);                          //th 1999-09-15
  InvalidateGutter(Index + 1, TopLine + LinesInWindow);                         //th 1999-09-15
end;

procedure TmwCustomEdit.ListLoaded(Sender: TObject);
//var                                                                           //mh 1999-08-22
//  i: Integer;
begin
  {begin}                                                                       //jdj 12/11/1998
//for i := 0 to 9 do                                                            //CdeB 12/16/1998 - removed
//  fBookMarks[i].IsSet := False;                                               //CdeB 12/16/1998 - removed
  if (FLines.Count = 0) then FLines.Add('');                                    //aj 1999-03-05
  CaretXY := Point(1,1);                                                        //gp 12/30/1998
  LeftChar := 1;
  TopLine := 1;
//  for i := 0 to fUndoList.FList.Count - 1 do                                  //mh 1999-08-22
//    fUndoList.RemoveChange(i);
  ClearUndo;
  {end}                                                                         //jdj 12/11/1998
end;

// mw 12/17/1998 - rewritten
procedure TmwCustomEdit.ListPutted(Index: Integer);
begin
  if Assigned(fHighLighter) then
  begin
    fHighLighter.SetRange(Lines.Objects[Index]);
{begin}                                                                         //th 1999-09-15
//    ScanFrom(Index);
//  end;
    InvalidateLines(Index + 1, ScanFrom(Index) + 1);
  end else
    InvalidateLines(Index + 1, Index + 1);
{end}                                                                           //th 1999-09-15
end;

{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-06-24
Type                                                                            //hk 1999-05-15
  TStringType = (
    stNone,
    stHalfNumAlpha,
    stHalfSymbol,
    stHalfKatakana,
    stWideNumAlpha,
    stWideSymbol,
    stWideKatakana,
    stHiragana,
    stIdeograph,
    stControl,
    stKashida
  );

{  }
Function IsStringType(Value: Word): TStringType;                                //hk 1999-05-15
Begin
  Result := stNone;

  If (Value = C3_SYMBOL) Then Begin
    (***  Controls  ***)
    Result := stControl;
  End Else
  If ((Value And C3_HALFWIDTH) <> 0) Then Begin
    (*** singlebyte ***)
    If (Value = C3_HALFWIDTH) Or
       (Value = (C3_ALPHA Or C3_HALFWIDTH)) Then Begin    { Number & Alphabet }
      Result := stHalfNumAlpha;
    End Else
    If ((Value And C3_SYMBOL) <> 0) Or
       ((Value And C3_LEXICAL) <> 0) Then Begin           { Symbol }
      Result := stHalfSymbol;
    End Else
    If ((Value And C3_KATAKANA) <> 0) Then Begin          { Japanese-KATAKANA }
      Result := stHalfKatakana;
    End;
  End Else Begin
    (*** doublebyte ***)
    If (Value = C3_FULLWIDTH) Or
       (Value = (C3_ALPHA Or C3_FULLWIDTH)) Then Begin    { Number & Alphabet }
      Result := stWideNumAlpha;
    End Else
    If ((Value And C3_SYMBOL) <> 0) Or
       ((Value And C3_LEXICAL) <> 0) Then Begin           { Symbol }
      Result := stWideSymbol;
    End Else
    If ((Value And C3_KATAKANA) <> 0) Then Begin          { Japanese-KATAKANA }
      Result := stWideKatakana;
    End Else
    If ((Value And C3_HIRAGANA) <> 0) Then Begin          { Japanese-HIRAGANA }
      Result := stHiragana;
    End Else
    If ((Value And C3_IDEOGRAPH) <> 0) Then Begin         { Ideograph }
      Result := stIdeograph;
    End;
  End;
(*
    // Is this MBCS ?
    If ((Value And C3_KASHIDA) <> 0) Then Begin           { Alabic-KASHIDA }
      Result := stKashida;
    End;
*)
End;

{  }
Procedure TmwCustomEdit.SetWordBlock(Value: TPoint);                            //hk 1999-05-15
Var
  i: Integer;
  Runner: TPoint;
  TempString: String;
  IdChars: TIdentChars;

  Procedure MultiBlockScan;
  Var
    i: Integer;
    wideX: Integer;
    cType: PWordArray;
    cLeng: Integer;
    stc: TStringType;
  Begin
    wideX := ByteToCharIndex(TempString, Value.X-1);

    cLeng := ByteToCharLen(TempString, Length(TempString));
    GetMem(cType, SizeOf(Word) * cLeng);
    Try
      If Not GetStringTypeEx(
               LOCALE_SYSTEM_DEFAULT,
               CT_CTYPE3,
               PChar(TempString),
               Length(TempString),
               cType^) Then Begin
        Exit;
      End;

      stc := IsStringType(cType^[wideX]);
      If (stc = stControl) Then Begin
        Exit;
      End;
//      Runner := Point(0, cLeng-1);     //comment this line by Xueyu 1999-06-30

      { search BlockEnd }
      For i:=wideX+1 To cLeng-1 Do Begin
        If (IsStringType(cType^[i]) <> stc) Then Begin
          Runner.Y := (i + 1);
          Break;
        End;
      End;
      Runner.Y := (i + 1);
      if Runner.Y>cLeng then Runner.Y:=cLeng;   //Xueyu 1999-06-30

      { search BlockBegin }
      For i:=wideX-1 DownTo 0 Do Begin
        If (IsStringType(cType^[i]) <> stc) Then Begin
          Runner.X := (i + 2);
          Break;
        End;
      End;

      Runner.X := CharToByteIndex(TempString, Runner.X);
      Runner.Y := CharToByteIndex(TempString, Runner.Y);
    Finally
      FreeMem(cType);
    End;
  End;

Begin
  Value.x := MinMax(Value.x, 1, fMaxLeftChar);                                  //mh 1999-06-13
  Value.y := MinMax(Value.y, 1, Lines.Count);

  TempString := (Lines[Value.Y - 1] + #$0);
  If (Value.X >= Length(TempString)) Then Begin
    CaretXY := Point(Length(TempString), Value.Y);
    Exit;
  End;

  If (fHighlighter <> Nil) And
     (ByteType(TempString, Value.X) <> mbLeadByte) Then Begin

    Runner := Point(0, Length(TempString));
    IdChars := fHighlighter.IdentChars;

    { search BlockEnd }
    For i:=Value.X To Length(TempString)-1 Do Begin
      If Not (TempString[i] In IdChars) Then Begin
        Runner.Y := i;
        Break;
      End;
    End;

    { search BlockBegin }
    For i:=Value.X-1 DownTo 0 Do Begin
      If Not (TempString[i] In IdChars) Then Begin
        Runner.X := (i + 1);
        Break;
      End;
    End;
  End Else Begin
    MultiBlockScan;
  End;

  fBlockBegin := Point(Runner.X, Value.Y);
  fBlockEnd := Point(Runner.Y, Value.Y);
  CaretXY := Point(Runner.Y, Value.Y);

  InvalidateLines(Value.Y, Value.Y);
End;
{$ELSE}                                                                         //hk 1999-05-15
procedure TmwCustomEdit.SetWordBlock(Value: TPoint);
var
  Runner: TPoint;
  TempString: String;
  IdChars: TIdentChars;                                                         //mt 12/22/1998
begin                                                                           //tskurz 12/14/1998 - lots of changes
  Value.x := MinMax(Value.x, 1, fMaxLeftChar);                                  //mh 1999-06-13
  Value.y := MinMax(Value.y, 1, Lines.Count);

  TempString := Lines[Value.Y - 1];
  if TempString = '' then exit;

  // Click on right side of text
  if Length(TempString) < Value.X then Value.X := Length(TempString);
  Runner := Value;

  {begin}                                                                       //mt 12/23/1998
  if fHighlighter <> NIL then
    IdChars := fHighlighter.IdentChars
  else
    IDchars := [#33..#255];
  {end}                                                                         //mt 12/23/1998

//  if not (TempString[Runner.X] in ALPHA+DIGIT) then break;                    //mt 12/10/1998
// Add both ALPHA parts because we had to break them up.
// replaced ALPHA_UC+ALPHA_LC+DIGIT constants with IdChars throughout           //mt 12/23/1998
  if not (TempString[Runner.X] in IdChars) then
  begin
    // no word under cursor and next char right is not start of a word
    if (Runner.X > 1) and (not (TempString[Runner.X] in IdChars)) then          //mt 12/23/1998
    begin
      // find end of word on the left side
      while Runner.X > 0 do
      begin
        if (TempString[Runner.X] in IdChars) then break;                        //mt 12/23/1998
        Dec(Runner.X);
      end;
    end;
    // no word on the left side, so look to the right side
    if not (TempString[Runner.X] in IdChars) then                               //mt 12/23/1998
    begin
      Runner := Value;
      while Runner.X < fMaxLeftChar do
      begin
        if (TempString[Runner.X] in IdChars) then break;                        //mt 12/23/1998
        Inc(Runner.X);
      end;
      if Runner.X > fMaxLeftChar then
        exit;
    end;
    Value := Runner;
  end;

  while Runner.X > 0 do
  begin
//  if not (TempString[Runner.X] in ALPHA+DIGIT) then break;                    //mt 12/10/1998
// Add both ALPHA parts because we had to break them up.
    if not (TempString[Runner.X] in IdChars) then break;                        //mt 12/23/1998
    Dec(Runner.X);
  end;
  Inc(Runner.X);
  if Runner.X < 1 then Runner.X := 1;
  fBlockBegin := Runner;

  Runner := Value;
  while Runner.X < fMaxLeftChar do
  begin
//  if not (TempString[Runner.X] in ALPHA+DIGIT) then break;                    //mt 12/10/1998
// Add both ALPHA parts because we had to break them up.
    if not (TempString[Runner.X] in IdChars) then break;                        //mt 12/23/1998
    Inc(Runner.X);
  end;
  if Runner.X > fMaxLeftChar then Runner.X := fMaxLeftChar;
  fBlockEnd := Runner;
// set caret to the end of selected block
  CaretXY := Runner;                                                            //gp 12/27/1998

//  Invalidate;                                                                   //bds 2/24/1999
  InvalidateLines(Value.Y, Value.Y);                                            //mh 1999-05-12
end;
{$ENDIF}                                                                        //hk 1999-05-15

procedure TmwCustomEdit.DblClick;
begin
  {$IFDEF DebugMouseEvents} OutputDebugString('>DblClick'); try {$ENDIF}
   SetWordBlock(CaretXY);                                                       //bds 12/20/1998
   inherited;
   fDblClicked := True;
  {$IFDEF DebugMouseEvents} finally OutputDebugString('<DblClick'); end; {$ENDIF}
end;

function TmwCustomEdit.GetCanUndo: Boolean;
begin
   result := (fUndoList.CanUndo > 0);
end;

function TmwCustomEdit.GetCanRedo: Boolean;
begin
   result := (fRedoList.CanUndo > 0);
end;

{begin}                                                                         //tskurz 1/4/1999
procedure TmwCustomEdit.Redo;
var
  ChangeStr : PChar;
  ChangeStartPos,
  ChangeEndPos: TPoint;
  ChangeReason : TChangeReason;
{$IFDEF MWE_SELECTION_MODE}
  OldSelMode,
  ChangeSelMode: TSelectionMode;                                                //bds 1/25/1999
{$ENDIF}
begin
  if not CanRedo then exit;
{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
  OldSelMode := SelectionMode;
  ChangeReason := FRedoList.GetChange(ChangeStartPos, ChangeEndPos, ChangeStr,
     ChangeSelMode);
  SelectionMode := ChangeSelMode;
{$ELSE}
{end}                                                                           //bds 1/25/1999
  ChangeReason := FRedoList.GetChange(ChangeStartPos,ChangeEndPos,ChangeStr);
{$ENDIF}                                                                        //bds 1/25/1999
  case ChangeReason of
    mwcrInsert, mwcrPaste,                                                      //tskurz 06/11/1999
    mwcrDragDropInsert :
      begin
        IncPaintLock;
        CaretXY := ChangeStartPos;
        SetBlockBegin(ChangeStartPos);
        DecPaintLock;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
        SetSelTextPrimitive(ChangeSelMode, ChangeStr, NIL);
        FUndoList.AddChange(ChangeReason,ChangeStartPos, ChangeEndPos,
           PChar(GetSelText), ChangeSelMode);
{$ELSE}                                                                         //bds 1/25/1999
        SetSelText(ChangeStr);                                                  //tskurz 1/7/1999
        FUndoList.AddChange(ChangeReason,ChangeStartPos,
           fBlockEnd,PChar(GetSelText));                                        //tskurz 1/7/1999
{$ENDIF}                                                                        //bds 1/25/1999
        StrDispose(ChangeStr);
      end;
{begin}                                                                         //bds 12/20/1998
    mwcrDeleteAfterCursor:
      begin
        IncPaintLock;
        CaretXY := ChangeStartPos;
        SetBlockBegin(ChangeStartPos);
        SetBlockEnd(ChangeEndPos);
        DecPaintLock;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
        FUndoList.AddChange(ChangeReason, ChangeStartPos, ChangeEndPos,
          PChar(GetSelText), ChangeSelMode);
        SetSelTextPrimitive(ChangeSelMode, ChangeStr, NIL);
{$ELSE}                                                                         //bds 1/25/1999
        FUndoList.AddChange(ChangeReason,fBlockBegin,fBlockEnd,                 //tskurz 06/11/1999
          PChar(GetSelText));
        SetSelText(ChangeStr);                                                  //tskurz 1/7/1999
{$ENDIF}                                                                        //bds 1/25/1999
        StrDispose(ChangeStr);
        CaretXY := ChangeStartPos;
      end;
{end}
    mwcrDelete,
    mwcrDragDropDelete,
//    mwcrPasteDelete :                                                           //tskurz 06/11/1999
    mwcrSelDelete :                                                             //th 1999-09-22
      begin
        IncPaintLock;
        SetBlockBegin(ChangeStartPos);
        SetBlockEnd(ChangeEndPos);
        DecPaintLock;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
        FUndoList.AddChange(ChangeReason, ChangeStartPos, ChangeEndPos,
          PChar(GetSelText), ChangeSelMode);
        SetSelTextPrimitive(ChangeSelMode, ChangeStr, NIL);
{$ELSE}                                                                         //bds 1/25/1999
        FUndoList.AddChange(ChangeReason,fBlockBegin,fBlockEnd,                 //tskurz 1/7/1999
          PChar(GetSelText));
        SetSelText(ChangeStr);                                                  //tskurz 1/7/1999
{$ENDIF}                                                                        //bds 1/25/1999
        StrDispose(ChangeStr);
        CaretXY := ChangeStartPos;
        if ((FRedoList.GetChangeReason = mwcrDragDropInsert) and                //tskurz 06/11/1999
           (ChangeReason = mwcrDragDropDelete)) or
//          ((FRedoList.GetChangeReason = mwcrPaste) and                          //tskurz 06/11/1999 //th 1999-09-22
//           (ChangeReason = mwcrPasteDelete)) then ReDo;                       //th 1999-09-22
           (ChangeReason = mwcrSelDelete) then Redo;                            //th 1999-09-22
      end;
    mwcrLineBreak :
      begin
        CommandProcessor(ecLineBreak, #13, nil);
      end;
  else
  end;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
  SelectionMode := OldSelMode;
{$ENDIF}                                                                        //bds 1/25/1999
end;
{end}                                                                           //tskurz 1/4/1999

procedure TmwCustomEdit.Undo;
var
  ChangeStr : PChar;
  ChangeStartPos,
  ChangeEndPos: TPoint;
  ChangeReason : TChangeReason;
  Temp: String;
  TmpPos: TPoint;                                                               //th 1999-09-22
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
//  LastLine : Boolean;                                                           //tskurz 06/11/1999 //th 1999-09-22
  OldSelMode,
  ChangeSelMode: TSelectionMode;
{$ENDIF}                                                                        //bds 1/25/1999
begin
  if not CanUndo then exit;
{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
  OldSelMode := SelectionMode;
  ChangeReason := FUndoList.GetChange(ChangeStartPos, ChangeEndPos, ChangeStr,
     ChangeSelMode);
  SelectionMode := ChangeSelMode;
//  LastLine := False;                                                            //bds 1/25/1999 //th 1999-09-22
//  if (ChangeEndPos.y >= GetLineCount) and                                     //th 1999-09-22
//     (ChangeSelMode = smColumn) then LastLine := True;                		//tskurz 06/11/1999 //th 1999-09-22
{$ELSE}
{end}                                                                           //bds 1/25/1999
  ChangeReason := FUndoList.GetChange(ChangeStartPos,ChangeEndPos,ChangeStr);
{$ENDIF}                                                                        //bds 1/25/1999
  IncPaintLock;									//tskurz 06/11/1999
  case ChangeReason of
    mwcrInsert, mwcrPaste,
    mwcrDragDropInsert :                                                        //tskurz 06/11/1998
      begin
        SetBlockBegin(ChangeStartPos);
        SetBlockEnd(ChangeEndPos);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
        FRedoList.AddChange(ChangeReason, ChangeStartPos, ChangeEndPos,
           PChar(GetSelText), ChangeSelMode);
        SetSelTextPrimitive(ChangeSelMode, ChangeStr, NIL);
{$ELSE}                                                                         //bds 1/25/1999
        FRedoList.AddChange(ChangeReason,fBlockBegin,fBlockEnd,                 //tskurz 1/7/1999
          PChar(GetSelText));
        SetSelText(ChangeStr);                                                  //tskurz 1/7/1999
{$ENDIF}                                                                        //bds 1/25/1999
        StrDispose(ChangeStr);
        CaretXY := ChangeStartPos;                                              //bds 12/20/1998
        if ((FUndoList.GetChangeReason = mwcrDragDropDelete) and                //tskurz 06/11/1999
           (ChangeReason = mwcrDragDropInsert)) or
//           ((FUndoList.GetChangeReason = mwcrPasteDelete) and                   //tskurz 06/11/1999 //th 1999-09-22
//           (ChangeReason = mwcrPaste)) then Undo;                             //th 1999-09-22
           (FUndoList.GetChangeReason = mwcrSelDelete) then Undo;               //th 1999-09-22
      end;
{begin}                                                                         //th 1999-09-22
(*
{begin}                                                                         //bds 12/20/1998
    mwcrDeleteAfterCursor:
      begin
        if ChangeStartPos.y > GetLineCount then                                 //tskurz 06/11/1999
        begin
           CaretXY := Point(1,GetLineCount);
           CommandProcessor(ecLineBreak, #13, nil);
{$IFDEF MWE_SELECTION_MODE}                                                     //mh 1999-08-19 - compiler hint
           LastLine := True;
{$ENDIF}
        end;                                                                    //tskurz 06/11/1999
        CaretXY := ChangeStartPos;                                              //bds 12/20/1998
        SetBlockBegin(ChangeStartPos);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
        SetSelTextPrimitive(ChangeSelMode, ChangeStr, NIL);
        FRedoList.AddChange(ChangeReason, ChangeStartPos, ChangeEndPos,
           PChar(GetSelText), ChangeSelMode);
{$ELSE}                                                                         //bds 1/25/1999
        SetSelText(ChangeStr);
        FRedoList.AddChange(ChangeReason,ChangeStartPos,fBlockEnd,
          PChar(GetSelText));
{$ENDIF}                                                                        //bds 1/25/1999
        StrDispose(ChangeStr);
        CaretXY := ChangeEndPos;
      end;
{end}                                                                           //bds 12/20/1998
*)
    mwcrDeleteAfterCursor,
{end}                                                                           //th 1999-09-22
    mwcrDelete,
    mwcrDragDropDelete,
//    mwcrPasteDelete :                                                           //tskurz 06/11/1999
    mwcrSelDelete :                                                             //th 1999-09-22
      begin
        // If there's no selection, we have to set
        // the Caret's position manualy.
{begin}                                                                         //th 1999-09-22
//        CaretXY := ChangeStartPos;                                              //bds 12/20/1998
//        SetBlockBegin(ChangeStartPos);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
        if ChangeSelMode = smColumn then
          TmpPos := Point(
            Min(ChangeStartPos.X, ChangeEndPos.X),
            Min(ChangeStartPos.Y, ChangeEndPos.Y))
        else
{$ENDIF}
          TmpPos := minPoint(ChangeStartPos, ChangeEndPos);

        if (ChangeReason = mwcrDeleteAfterCursor) and
//        if ChangeStartPos.y > GetLineCount then                                 //tskurz 06/11/1999
           (TmpPos.Y > GetLineCount) then
        begin
           CaretXY := Point(1,GetLineCount);
           CommandProcessor(ecLineBreak, #13, nil);
(*                                                                              //th 1999-09-22
{$IFDEF MWE_SELECTION_MODE}                                                     //mh 1999-08-19 - compiler hint
           LastLine := True;
{$ENDIF}
*)                                                                              //th 1999-09-22
        end;

        CaretXY := TmpPos;
        SetBlockBegin(TmpPos);
{end}                                                                           //th 1999-09-22
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
        SetSelTextPrimitive(ChangeSelMode, ChangeStr, NIL);
{begin}                                                                         //th 1999-09-22
        CaretXY := ChangeEndPos;
        SetBlockBegin(ChangeStartPos);
        SetBlockEnd(ChangeEndPos);
        FRedoList.AddChange(ChangeReason, ChangeStartPos, ChangeEndPos,
//           PChar(GetSelText), ChangeSelMode);
           nil, ChangeSelMode);
{end}
{$ELSE}                                                                         //bds 1/25/1999
        SetSelText(ChangeStr);                                                  //tskurz 1/7/1999
{begin}                                                                         //th 1999-09-22
        CaretXY := ChangeEndPos;
        SetBlockBegin(ChangeStartPos);
        SetBlockEnd(ChangeEndPos);
        FRedoList.AddChange(ChangeReason,ChangeStartPos,fBlockEnd,              //tskurz 1/7/1999
//          PChar(GetSelText));
          nil);
{end}
{$ENDIF}                                                                        //bds 1/25/1999
        EnsureCursorPosVisible;
{end}                                                                           //th 1999-09-22
        StrDispose(ChangeStr);
      end;
    mwcrLineBreak:
      begin
        // If there's no selection, we have to set
        // the Caret's position manualy.
        CaretXY := ChangeStartPos;                                              //gp 12/22/1998
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
        FRedoList.AddChange(ChangeReason, ChangeStartPos, ChangeEndPos, NIL,
           ChangeSelMode);
{$ELSE}                                                                         //bds 1/25/1999
        FRedoList.AddChange(ChangeReason,fBlockBegin,fBlockEnd,nil);            //tskurz 1/4/1999
{$ENDIF}                                                                        //bds 1/25/1999
        if CaretY > 0 then
        begin
//        Temp := Lines.Strings[fCaretY] + ChangeStr;                           //tskurz 12/21/1998
          Temp := Lines.Strings[fCaretY];                                       //tskurz 12/21/1998
          if (Length(Temp) < fCaretX) and (LeftSpaces(ChangeStr) = 0) then      //tskurz 1/4/1999
             Temp := Temp + StringOfChar(' ', fCaretX-Length(Temp));            //tskurz 1/4/1999
          Lines.Delete(ChangeEndPos.y);
        end;
        CaretXY := ChangeStartPos;                                              //bds 12/20/1998
        LineText := TrimRight(Temp+ChangeStr);                                  //gp 12/24/1998
        //CaretX := ChangeStartPos.x;
        StrDispose(ChangeStr);
      end;
  else
  end;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
  SelectionMode := OldSelMode;
//  if LastLine and (Lines.Count > 1) then Lines.Delete(Lines.Count-1);           //tskurz 06/11/1999 //th 1999-09-22
{$ENDIF}                                                                        //bds 1/25/1999
{end}
  DecPaintLock;									//tskurz 06/11/1999
end;
{end}                                                                           //tskurz 12/10/1998

{begin}                                                                         //jdj 12/10/1998
                                                                                //CdeB 12/16/1998 - removed, //gp 12/31/1998 - reinstantianted
procedure TmwCustomEdit.ClearBookMark(BookMark: Integer);
begin
(*                                                                              //gp 12/31/1998 - removed
  if (BookMark in [0..9]) then
    begin
      fBookMarks[BookMark].IsSet := False;
      Invalidate;
    end;
*)
  {begin}                                                                       //CdeB 12/16/1998
  if (BookMark in [0..9]) and assigned(fBookMarks[BookMark]) then begin         //gp 12/31/1998
    FMarkList.Remove(fBookMarks[Bookmark]);
    fBookMarks[BookMark].Free;
    fBookMarks[BookMark] := nil;
  end
  {end}                                                                         //CdeB 12/16/1998
end;

procedure TmwCustomEdit.GotoBookMark(BookMark: Integer);
begin
  {begin}                                                                       //CdeB 12/16/1998
  if (BookMark in [0..9]) and assigned(fBookMarks[BookMark]) and                //gp 12/31/1998
     (fBookMarks[BookMark].Line <= fLines.Count) then begin
    CaretXY := Point(fBookMarks[BookMark].Column,fBookMarks[BookMark].Line);
    EnsureCursorPosVisible;
  end;
  {end}                                                                         //CdeB 12/16/1998
end;

procedure TmwCustomEdit.SetBookMark(BookMark: Integer; X: Integer; Y: Integer);
var
  i: Integer;
  mark: TMark;                                                                  //gp 1/9/1999
begin
  {begin}                                                                       //CdeB 12/16/1998, //gp 1/9/1999 - changed a lot
  if (BookMark in [0..9]) and (Y <= fLines.Count) then begin
    mark := TMark.Create(self);
    with mark do begin
      Line := Y;
      Column := X;
      ImageIndex := Bookmark;
      BookmarkNumber := Bookmark;
      Visible := true;
      InternalImage := (BookmarkImages = nil);
    end;
    if Assigned(FOnPlaceMark) then FOnPlaceMark(mark);
    if (mark <> nil) and (BookMark in [0..9]) then begin
      for i := 0 to 9 do
        if assigned(fBookMarks[i]) and (fBookMarks[i].Line = Y) then
          ClearBookmark(i);
      if assigned(fBookMarks[BookMark]) then ClearBookmark(BookMark);
      fBookMarks[BookMark]:= mark;
      FMarkList.Add(fBookMarks[BookMark]);
    end;
  end;
  {end}                                                                         //CdeB 12/16/1998, //gp 1/9/1999
end;
{end}                                                                           //jdj 12/10/1998

procedure TmwCustomEdit.WndProc(var msg: TMessage);                             //gp 12/12/1998
// Prevent Alt-Backspace from beeping
const ALT_KEY_DOWN = $20000000;
begin
  if (msg.Msg = WM_SYSCHAR) AND (msg.wParam = VK_BACK) and
     (msg.lParam AND ALT_KEY_DOWN <> 0)
  then msg.Msg := 0
  else inherited;
end;

{begin}                                                                         //ked 12/10/1998
function TmwCustomEdit.CoorToIndex(CPos: TPoint): integer;
begin
  result := CharsInWindow * CPos.Y + CPos.X;
end;

function TmwCustomEdit.IndexToCoor(ind: integer): TPoint;
begin
  result.y := ind div CharsInWindow;
  result.x := ind - result.y * CharsInWindow;
end;

procedure TmwCustomEdit.DragOver(Source: TObject; X, Y: Integer;
                             State: TDragState; var Accept: Boolean);
begin
  {$IFDEF DebugDragEvents} try OutputDebugString(PChar(Format('>DragOver %p %d %d %d',[pointer(Source),x,y,Ord(State)]))); {$ENDIF}
  inherited;
  if Accept or(Source is TmwCustomEdit) then begin
    Accept := True;
    if ((GetKeyState(VK_CONTROL) shr 31)=0) then begin
      if DragCursor<>crDrag then
        DragCursor := crDrag;
    end else //Ctrl is pressed => change cursor to indicate copy instead of move
      if DragCursor<>crMultiDrag then
        DragCursor := crMultiDrag;
    if State=dsDragLeave then //restore prev caret position
      ComputeCaret(FMouseDownX, FMouseDownY)
    else //position caret under the mouse cursor
      ComputeCaret(X, Y);
  end;
  {$IFDEF DebugDragEvents} finally OutputDebugString('<DragOver'); end; {$ENDIF}
end;

procedure TmwCustomEdit.DragDrop(Source: TObject; X, Y: Integer);
var
  CurInd, DragBegInd, DragEndInd: Integer;
  sWK: string;
  dropLine, oldLines, correction: integer;                                      //gp 12/17/1998
  oldScroll: boolean;                                                           //gp 12/16/1998
begin
  {$IFDEF DebugDragEvents} try OutputDebugString(PChar(Format('>DragDrop %p %d %d',[pointer(Source),x,y]))); {$ENDIF}
  if ReadOnly then exit;                                                        //bds 12/20/1998
  IncPaintLock;
  try
    inherited;
    if (Source=self) and (SelAvail) then begin
      ComputeCaret(X,Y);
      sWk := SelText; //text to be moved/copied
      CurInd := CoorToIndex(CaretXY);                                           //bds 12/20/1998
      DragBegInd := CoorToIndex(fDragBlockBegin);
      DragEndInd := CoorToIndex(fDragBlockEnd);
      //copy or move text if drop occured out of selection
      if (CurInd<DragBegInd) or (CurInd>DragEndInd) then begin
        if (GetKeyState(VK_CONTROL) shr 31)=0 then begin
          //if Ctrl is not down then text will be moved
          if (DragBegInd<CurInd) and (FDragBlockEnd.Y = CaretY) then
            //take into account deleted text if dropping occured on the same line
            CurInd := CurInd - (DragEndInd - DragBegInd);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
          FUndoList.AddChange(mwcrDragDropDelete, fBlockBegin, fBlockEnd,
//             PChar(SelText), SelectionMode);                                  //th 1999-09-22
             PChar(sWk), SelectionMode);
{$ELSE}                                                                         //bds 1/25/1999
          FUndoList.AddChange(mwcrDragDropDelete, fBlockBegin,
//            fBlockEnd, PChar(SelText));                                         //tskurz 12/16/1998 // 1999-09-22
            fBlockEnd, PChar(sWk));
{$ENDIF}                                                                        //bds 1/25/1999
          LockUndo;                                                             //tskurz 06/11/1999
          oldLines := Lines.Count;                                              //gp 12/16/1998
          dropLine := CaretY;                                                   //gp 12/17/1998
          SelText := '';
        {begin}                                                                 //gp 12/16/1998
          if dropLine > CaretY
            then correction := oldLines-Lines.Count
            else correction := 0;
        end
        else correction := 0;
        {end}                                                                   //gp 12/16/1998
        //move
        BlockBegin := IndexToCoor(CurInd);
        {begin}                                                                 //gp 12/16/1998
        BlockBegin := Point(BlockBegin.X,BlockBegin.Y-correction);           
        CurInd := CoorToIndex(BlockBegin);
        oldScroll := fScrollPastEOL;                             
        fScrollPastEOL := true;
        try                                                      
        {end}                                                                   //gp 12/16/1998
          CaretXY := BlockBegin;                                                //bds 1/24/1999
//          CaretX := BlockBegin.x;                                             //bds 1/24/1999
//          CaretY := BlockBegin.Y;                                             //bds 1/24/1999
          BlockEnd := BlockBegin;
          SelText := sWk;
        finally fScrollPastEOL := oldScroll; end;                               //gp 12/16/1998
        UnLockUndo;                                                             //tskurz 06/11/1999
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
        FUndoList.AddChange(mwcrDragDropInsert, IndexToCoor(CurInd), BlockEnd,
           PChar(SelText), SelectionMode);
{$ELSE}                                                                         //bds 1/25/1999
        FUndoList.AddChange(mwcrDragDropInsert,IndexToCoor(CurInd),
          BlockEnd,PChar(SelText));                                             //tskurz 12/16/1998
{$ENDIF}                                                                        //bds 1/25/1999
      end;
    end;
  finally
    DecPaintLock;
    UnLockUndo;                                                                 //tskurz 06/11/1999
  end;
  {$IFDEF DebugDragEvents} finally OutputDebugString('<DragDrop'); end; {$ENDIF}
end;
{end}                                                                           //ked 12/10/1998

procedure TmwCustomEdit.SetRightEdge(Value: Integer);                           //jdj 12/12/1998
begin
  if fRightEdge <> Value then
  begin
    fRightEdge := Value;
    Invalidate;
  end;
end;

procedure TmwCustomEdit.SetRightEdgeColor(Value: TColor);                       //kvs 1999-05-07
var nX: integer;                                                                //mh 1999-05-12
    rcInval: TRect;                                                             //mh 1999-05-12
begin
  if fRightEdgeColor <> Value then
  begin
    fRightEdgeColor := Value;
//      Invalidate;                                                             //mh 1999-05-12
    nX:= fTextOffset + fRightEdge * fCharWidth;
    rcInval:= Rect(nX - 1, 0, nX + 1, ClientHeight);
    InvalidateRect(Handle, @rcInval, FALSE);
  end;
end;

{ TmwBookMarkOpt }

{begin}                                                                         //jdj 12/12/1998
constructor TmwBookMarkOpt.Create(AOwner: TmwCustomEdit);
begin
  inherited Create;
  FOwner := AOwner;
  fEnableKeys := True;
  fGlyphsVisible := True;
  fLeftMargin := 2;
  fXOffset := 12;
end;

procedure TmwBookMarkOpt.SetGlyphsVisible(Value: Boolean);
begin
  if (fGlyphsVisible <> Value) then
    begin
      fGlyphsVisible := Value;
//      FOwner.Invalidate;                                                      //mh 1999-05-12
      FOwner.InvalidateGutter(-1, -1);
    end;
end;

procedure TmwBookMarkOpt.SetLeftMargin(Value: Integer);
begin
  if (fLeftMargin <> Value) then
    begin
      fLeftMargin := Value;
//      FOwner.Invalidate;                                                      //mh 1999-05-12
      FOwner.InvalidateGutter(-1, -1);
    end;
end;
{end}                                                                           //jdj 12/12/1998

procedure TmwBookMarkOpt.SetXOffset(const Value: integer);                      //gp 1/10/1999
begin
  fXoffset := Value;
  if assigned(fOwner) then fOwner.Invalidate;
end;

function TmwCustomEdit.GetMaxUndo: Integer;                                     //tskurz 12/14/1998
begin
   result := fUndoList.MaxUndo;
end;

procedure TmwCustomEdit.SetMaxUndo(const Value: Integer);                       //tskurz 12/14/1998
begin
  if Value > -1 then
  begin
     fUndoList.MaxUndo := Value;
     fRedoList.MaxUndo := Value;                                                //tskurz 1/4/1999
  end;
end;

procedure TmwCustomEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = fHighLighter) then
    begin
      fHighLighter := nil;
      Invalidate;                                                               //jdj 12/18/1998
    end;
  if (Operation = opRemove) and (AComponent = fBookmarkImages) then begin       //gp 1/2/1999
    fBookmarkImages := nil;
    Invalidate;
  end;
end;

procedure TmwCustomEdit.SetHighlighter(const Value: TmwCustomHighLighter);
begin
//  fHighLighter := Value;                                                      //jdj 12/18/1998
  if Value <> nil then
    begin
//    Value.mwEdit := Self;                                                     //jdj 12/18/1998
      Value.mwEditList.AddInstance(Self);                                       //jdj 12/18/1998
      Value.FreeNotification(Self);
    end
  else if Assigned(fHighLighter) then
    fHighLighter.mwEditList.RemoveInstance(Self);                               //jdj 12/18/1998
//  fHighLighter.mwEdit := nil;                                                 //jdj 12/18/1998
  fHighLighter := Value;                                                        //jdj 12/18/1998
  Invalidate;                                                                   //jdj 12/18/1998
end;

{begin}                                                                         //bds 12/16/1998
procedure TmwCustomEdit.SetBorderStyle(Value: TBorderStyle);
begin
  if fBorderStyle <> Value then
  begin
    fBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TmwCustomEdit.SetHideSelection(const Value: boolean);
begin
  if fHideSelection <> Value then
  begin
    FHideSelection := Value;
    Invalidate;
  end;
end;

procedure TmwCustomEdit.SetInsertMode(const Value: boolean);
begin
  if fInserting <> Value then
  begin
    fInserting := Value;
    if not (csDesigning in ComponentState) then
      // Reset the caret.
      InitializeCaret;
  end;
end;

procedure TmwCustomEdit.InitializeCaret;
{begin}                                                                         //bds 12/17/1998
var
  ct: TCaretType;
  cw, ch: integer;
{end}                                                                           //bds 12/17/1998
begin
  // CreateCaret automatically destroys the previous one, so we don't have to
  // worry about cleaning up the old one here with DestroyCaret.
  // Ideally, we will have properties that control what these two carets look like.
  {begin}                                                                       //bds 12/17/1998
//if InsertMode then
//  CreateCaret(Handle, 0, 2, fTextHeight - 2)
//else
//  CreateCaret(Handle, 0, fCharWidth, fTextHeight - 2);
  if InsertMode then
    ct := FInsertCaret
  else
    ct := FOverwriteCaret;
  case ct of
    ctHorizontalLine:
      begin
        cw := fCharWidth;
        ch := 2;
        FCaretOffset := Point(0,fTextHeight-2);
      end;
    ctHalfBlock:
      begin
        cw := fCharWidth;
        ch := (fTextHeight - 2) div 2;
        FCaretOffset := Point(0,ch);
      end;
    ctBlock:
      begin
        cw := fCharWidth;
        ch := fTextHeight - 2;
        FCaretOffset := Point(0,0);
      end;
  else // ctVerticalLine
    cw := 2;
    ch := fTextHeight - 2;
    FCaretOffset := Point(-1,0);                                                //bds 12/27/1998
  end;
  CreateCaret(Handle, 0, cw, ch);
  {end}                                                                         //bds 12/17/1998
  UpdateCaret;
end;

procedure TmwCustomEdit.SetScrollPastEOL(const Value: boolean);
begin
  if FScrollPastEOL <> Value then
  begin
    FScrollPastEOL := Value;
    if not FScrollPastEOL then
      CaretX := CaretX;  // Reset pos in case it's past EOL currently.
  end;
end;
{end}                                                                           //bds 12/16/1998

{begin}                                                                         //bds 12/17/1998
procedure TmwCustomEdit.SetInsertCaret(const Value: TCaretType);
begin
  if FInsertCaret <> Value then
  begin
    FInsertCaret := Value;
    InitializeCaret;
  end;
end;

procedure TmwCustomEdit.SetOverwriteCaret(const Value: TCaretType);
begin
  if FOverwriteCaret <> Value then
  begin
    FOverwriteCaret := Value;
    InitializeCaret;
  end;
end;

function TmwCustomEdit.GetCaretXY: TPoint;
begin
  Result := Point(CaretX, CaretY);
end;

procedure TmwCustomEdit.SetCaretXY(const Value: TPoint);
begin
  IncPaintLock;
  try
//    CaretX := Value.X;                                                        //bds 12/20/1998
    // Set Y first because ScrollPastEOL can effect the X pos
    CaretY := Value.Y;
    CaretX := Value.X;                                                          //bds 12/20/1998
  finally
    DecPaintLock;
  end;
end;

{begin}                                                                         //mh 1999-09-12
{begin}                                                                         //bds 12/24/1998
procedure TmwCustomEdit.SetMaxLeftChar(Value: integer);
begin
  Value := MinMax(Value, 1, MAX_SCROLL); // horz scrolling is only 16 bit
  if fMaxLeftChar <> Value then
  begin
    fMaxLeftChar := Value;
    Invalidate;
  end;
end;

(*
procedure TmwCustomEdit.SetCharWidth(const Value: integer);
begin
  if fCharWidth <> Value then
  begin
    fCharWidth := Value;
    FillIntArrayValue(fCharWidth, @fETODist[0], fETODistLen);
    Invalidate;
  end;
end;
*)
{end}                                                                           //bds 12/24/1998
{end}                                                                           //mh 1999-09-12

procedure TmwCustomEdit.EnsureCursorPosVisible;
begin
  IncPaintLock;
  try
    // Make sure X is visible
    if fCaretX < (LeftChar - 1) then
      LeftChar := fCaretX + 1
    else if fCaretX >= (fCharsInWindow + LeftChar) then                         //bds 12/24/1998
      LeftChar := fCaretX - fCharsInWindow + 2;

    // Make sure Y is visible
    if fCaretY < (TopLine - 1) then
      TopLine := fCaretY + 1
    else if fCaretY > (TopLine + (LinesInWindow - 2)) then                      //bds 12/20/1998
      TopLine := fCaretY - (LinesInWindow - 2);                                 //bds 12/20/1998
  finally
    DecPaintLock;
  end;
end;
{end}                                                                           //bds 12/17/1998


{begin}                                                                         //bds 12/23/1998
procedure TmwCustomEdit.SetKeystrokes(const Value: TmwKeyStrokes);
begin
  if Value = NIL then
    FKeystrokes.Clear
  else
    FKeystrokes.Assign(Value);
end;
{end}                                                                           //bds 12/23/1998


procedure TmwCustomEdit.SetDefaultKeystrokes;
begin
  {begin}                                                                       //bds 12/29/1998
  // The guts of this have been moved into mwKeyCmds.pas
  FKeystrokes.ResetDefaults;
  {end}                                                                         //bds 12/29/1998
end;


{begin}                                                                         //bds 12/20/1998
// If the translations requires Data, memory will be allocated for it via a
// GetMem call.  The client must call FreeMem on Data if it is not NIL.
function TmwCustomEdit.TranslateKeyCode(Code: word; Shift: TShiftState;
                          var Data: pointer): TmwEditorCommand;                 //bds 12/23/1998

{begin}                                                                         //bds 12/23/1998
var
  i: integer;
begin
  i := Keystrokes.FindKeycode(Code, Shift);
  if i >= 0 then
    Result := Keystrokes[i].Command
  else
    Result := ecNone;
// removed old code
{end}                                                                           //bds 12/23/1998
end;

procedure TmwCustomEdit.CommandProcessor(Command: TmwEditorCommand; AChar: char;//bds 12/23/1998
   Data: pointer);
const
  ALPHANUMERIC = DIGIT + ALPHA_UC + ALPHA_LC;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
  SEL_MODE: array[ecNormalSelect..ecLineSelect] of TSelectionMode = (
     smNormal, smColumn, smLine);
{$ENDIF}                                                                        //bds 1/25/1999
var
  CX: Integer;
  Len: Integer;
  Temp: string;
  Temp2: String;
  Helper: string;
  SpaceCount1: Integer;
  SpaceCount2: Integer;
  BackCounter: Integer;
  StartOfBlock: TPoint;
  oldScroll: boolean;
  moveBkm: boolean;
  WP: TPoint;
  Caret: TPoint;                                                                //gp 12/27/1998
  i: integer;                                                                   //CdeB 12/16/1998
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
  OldSelMode: TSelectionMode;
{$ENDIF}                                                                        //bds 1/25/1999
{$IFDEF MWE_MBCSSUPPORT}                                                       //mh 1999-06-13
  s: String;
{$ENDIF}                                                                        //mh 1999-06-13
  counter: Integer;                                                             //hk 1999-05-10
  V_MyIndent:integer;                                                           //ar 1999-05-10
begin
  ProcessCommand(Command, AChar, Data);
  if (Command = ecNone) or (Command >= ecUserFirst) then exit;

  IncPaintLock;
  try
    case Command of
      ecLeft,
      ecSelLeft:
        begin

{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
          s := LineText;
          counter := 1;
          If (Length(s) > (CaretX - 2)) Then Begin
            Case ByteType(s, (CaretX - 1)) Of
            mbTrailByte:
              Begin
                counter := 2;
              End;
            End;
          End;
          fMBCSStepAside := False;
          CX := CaretX - counter;
{$ELSE}
          CX := CaretX - 1;
{$ENDIF}

          if (Command = ecSelLeft) then
          begin

{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
            if not SelAvail then SetBlockBegin(Point(CX + counter, CaretY));
{$ELSE}
            if not SelAvail then SetBlockBegin(Point(CX + 1, CaretY));
{$ENDIF}

            SetBlockEnd(Point(CX, CaretY));
          end else
            SetBlockBegin(Point(CX, CaretY));
          if (not fScrollPastEOL) and (CX < 1) then
          begin
            if CaretY > 1 then
            begin
              CaretY := CaretY - 1;
              CaretX := Length(LineText) + 1;
            end;
          end else
            CaretX := CX;
        end;
      ecRight,
      ecSelRight:
        begin

{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
          s := LineText;
          counter := 1;
          If (Length(s) > CaretX) Then Begin
            Case ByteType(s, CaretX) Of
            mbLeadByte:
              Begin
                counter := 2;
              End;
            End;
          End;
          fMBCSStepAside := False;
          CX := CaretX + counter;
{$ELSE}
          CX := CaretX + 1;
{$ENDIF}

          if (Command = ecSelRight) then
          begin
{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
            if not SelAvail then SetBlockBegin(Point(CX - counter, CaretY));
{$ELSE}
            if not SelAvail then SetBlockBegin(Point(CX - 1, CaretY));
{$ENDIF}

            SetBlockEnd(Point(CX, CaretY));
          end else
            SetBlockBegin(Point(CX, CaretY));
          if (not fScrollPastEOL) and (CX > (Length(LineText) + 1)) then
          begin
            if CaretY < Lines.Count then
            begin
              CaretX := 1;
              CaretY := CaretY + 1;
            end;
          end else
            CaretX := CX;
        end;
{begin}                                                                         //th 1999-09-15
(*
      ecUp,
      ecSelUp:
        begin
// Note: bug reported by Alston Chen, but different fix.
          i := CaretY;                                                          //mh 1999-08-19
          CaretY := CaretY - 1;
          if (Command = ecSelUp) then
          begin
            if not SelAvail then
              SetBlockBegin(Point(CaretX, i{CaretY + 1}));                      //mh 1999-08-19
            SetBlockEnd(CaretXY);
          end else
            SetBlockBegin(CaretXY);

{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
          s := LineText;
          If (Length(s) > CaretX) Then Begin
            Case ByteType(s, CaretX) Of
            mbTrailByte:
              Begin
                If fMBCSStepAside Then Begin
                  CaretX := CaretX + 1;
                End Else Begin
                  CaretX := CaretX - 1;
                End;
                fMBCSStepAside := Not fMBCSStepAside;
              End;
            mbSingleByte:
              Begin
                If fMBCSStepAside Then Begin
                  CaretX := CaretX + 1;
                End;
                fMBCSStepAside := False;
              End;
            End;
          End Else Begin
            If fMBCSStepAside Then Begin
              CaretX := CaretX + 1;
            End;
            fMBCSStepAside := False;
          End;
{$ENDIF}
        end;
      ecDown,
      ecSelDown:
        begin
// Note: bug reported by Alston Chen, but different fix.
          i := CaretY;                                                          //mh 1999-08-19
          CaretY := CaretY + 1;
          if Command = ecSelDown then
          begin
            if not SelAvail then
              SetBlockBegin(Point(CaretX, i{CaretY - 1}));                      //mh 1999-08-19
            SetBlockEnd(CaretXY);
          end else
            SetBlockBegin(CaretXY);

{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
          s := LineText;
          If (Length(s) > CaretX) Then Begin
            Case ByteType(s, CaretX) Of
            mbTrailByte:
              Begin
                If fMBCSStepAside Then Begin
                  CaretX := CaretX + 1;
                End Else Begin
                  CaretX := CaretX - 1;
                End;
                fMBCSStepAside := Not fMBCSStepAside;
              End;
            mbSingleByte:
              Begin
                If fMBCSStepAside Then Begin
                  CaretX := CaretX + 1;
                End;
                fMBCSStepAside := False;
              End;
            End;
          End Else Begin
            If fMBCSStepAside Then Begin
              CaretX := CaretX + 1;
            End;
            fMBCSStepAside := False;
          End;
{$ENDIF}
        end;
*)
      ecUp,
      ecSelUp:
        begin
          Caret := GetCaretXY;
          Dec(Caret.Y);
          cx := Caret.X;
{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
          if (0 < Caret.Y) and (Caret.Y <= Lines.Count) then
          begin
            s := Lines[Caret.Y - 1];
            if fMBCSStepAside then
              Inc(Caret.X);
            fMBCSStepAside :=
              (Length(s) >= Caret.X) and (mbTrailByte = ByteType(s, Caret.X));
            if fMBCSStepAside then
              Dec(Caret.X);
          end;
{$ENDIF}
// Note: bug reported by Alston Chen, but different fix.
          SetCaretXY(Caret);
          if (Command = ecSelUp) then
          begin
            if not SelAvail then
              SetBlockBegin(Point(cx, Caret.Y + 1{previous CaretY}));
            SetBlockEnd(CaretXY);
          end else
            SetBlockBegin(CaretXY);
          Update;                                                               //th 1999-09-22
        end;
      ecDown,
      ecSelDown:
        begin
          Caret := GetCaretXY;
          cx := Caret.X;
          CaretY := CaretY + 1;
{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
          if (Caret.Y <> CaretY) then
          begin
            if fMBCSStepAside then
              Inc(Caret.X);
            if CaretY > Lines.Count then
              fMBCSStepAside := False
            else
            begin
              s := Lines[Caret.Y];
              fMBCSStepAside :=
                (Length(s) >= Caret.X) and (mbTrailByte = ByteType(s, Caret.X));
              if fMBCSStepAside then
                Dec(Caret.X);
            end;
          end;
          CaretX := Caret.X;
{$ENDIF}

// Note: bug reported by Alston Chen, but different fix.
          if Command = ecSelDown then
          begin
            if not SelAvail then
              SetBlockBegin(Point(cx, Caret.Y{previous CaretY}));
            SetBlockEnd(CaretXY);
          end else
            SetBlockBegin(CaretXY);
          Update;
        end;
{end}                                                                           //th 1999-09-15        
      ecWordLeft,
      ecSelWordLeft:
        begin
          if (Command = ecSelWordLeft) and (not SelAvail) then
            SetBlockBegin(CaretXY);
          CaretXY := LastWordPos;
          if Command = ecSelWordLeft then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
        end;
      ecWordRight,
      ecSelWordRight:
        begin
          if (Command = ecSelWordRight) and (not SelAvail) then
            SetBlockBegin(CaretXY);
          CaretXY := NextWordPos;
          if Command = ecSelWordRight then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
        end;
      ecLineStart,
      ecSelLineStart:
        begin
          if (Command = ecSelLineStart) and (not SelAvail) then
            SetBlockBegin(CaretXY);
          CaretX := 1;
          if Command = ecSelLineStart then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
        end;
      ecLineEnd,
      ecSelLineEnd:
       begin
          if (Command = ecSelLineEnd) and (not SelAvail) then
            SetBlockBegin(CaretXY);
          CX := Length(LineText) + 1;
          CaretX := CX;
          if Command = ecSelLineEnd then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
        end;
      ecPageUp,
      ecSelPageUp:
        begin
          if (Command = ecSelPageUp) and (not SelAvail) then
            SetBlockBegin(CaretXY);

//          TopLine := TopLine - LinesInWindow;
//          CaretY := CaretY - LinesInWindow;
          If HalfpageScroll Then Begin                                          //hk 1999-05-10
            counter := (fLinesInWindow Div 2);
          End Else Begin
            counter := fLinesInWindow;
          End;
          TopLine := TopLine - counter;
          CaretY := CaretY - counter;

          if Command = ecSelPageUp then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
          Update;                                                               //th 1999-09-15
        end;
      ecPageDown,
      ecSelPageDown:
        begin
          if (Command = ecSelPageDown) and (not SelAvail) then
            SetBlockBegin(CaretXY);

//          TopLine := TopLine + LinesInWindow;
//          CaretY := CaretY + LinesInWindow;
          If HalfpageScroll Then Begin                                          //hk 1999-05-10
            counter := (fLinesInWindow Div 2);
          End Else Begin
            counter := fLinesInWindow;
          End;
          TopLine := TopLine + counter;
          CaretY := CaretY + counter;

          if (Command = ecSelPageDown) then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
          Update;                                                               //th 1999-09-15
        end;
      ecPageLeft,
      ecSelPageLeft:
        begin
          if (Command = ecSelPageLeft) and (not SelAvail) then
            SetBlockBegin(CaretXY);
          LeftChar := LeftChar - CharsInWindow;
          CaretX := CaretX - CharsInWindow;
          if (Command = ecSelPageLeft) then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
        end;
      ecPageRight,
      ecSelPageRight:
        begin
          if (Command = ecSelPageRight) and (not SelAvail) then
            SetBlockBegin(CaretXY);
          LeftChar := LeftChar + CharsInWindow;
          CaretX := CaretX + CharsInWindow;
          if (Command = ecSelPageRight) then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
        end;
      ecPageTop,
      ecSelPageTop:
        begin
          if (Command = ecSelPageTop) and (not SelAvail) then
            SetBlockBegin(CaretXY);
          CaretY := TopLine;
          if Command = ecSelPageTop then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
        end;
      ecPageBottom,
      ecSelPageBottom:
        begin
          if (Command = ecSelPageBottom) and (not SelAvail) then
            SetBlockBegin(CaretXY);
          CaretY := TopLine + (LinesInWindow - 1);
          if (Command = ecSelPageBottom) then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
        end;
      ecEditorTop,
      ecSelEditorTop:
        begin
          if (Command = ecSelEditorTop) and (not SelAvail) then
            SetBlockBegin(CaretXY);
          CaretX := 1;
          CaretY := 1;
          if Command = ecSelEditorTop then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
          Update;                                                               //th 1999-09-15
        end;
      ecEditorBottom,
      ecSelEditorBottom:
        begin
          if (Command = ecSelEditorBottom) and (not SelAvail) then
            SetBlockBegin(CaretXY);
          CaretY := Lines.Count;
          TopLine := Lines.Count - fLinesInWindow + 1;
          CaretX := Length(Lines[Lines.Count-1]) + 1;
          LeftChar := 1;
          if Command = ecSelEditorBottom then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
          Update;                                                               //th 1999-09-15
        end;
      ecGotoXY,
      ecSelGotoXY:
        begin
          if Data = NIL then exit;
          if (Command = ecSelGotoXY) and (not SelAvail) then
            SetBlockBegin(CaretXY);
          CaretXY := PPoint(Data)^;
          if Command = ecSelGotoXY then SetBlockEnd(CaretXY)
          else SetBlockBegin(CaretXY);
        end;
      ecSelectAll:
        begin
          SelectAll;
        end;
      ecDeleteLastChar:
        begin
          if ReadOnly then exit;
          if SelAvail then
          begin
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
            FUndoList.AddChange(mwcrDelete, fBlockBegin, fBlockEnd,
               PChar(SelText), SelectionMode);
{$ELSE}                                                                         //bds 1/25/1999
            FUndoList.AddChange(mwcrDelete, fBlockBegin, fBlockEnd, PChar(SelText));
{$ENDIF}                                                                        //bds 1/25/1999
            SetSelText('');
            exit;
          end;
          Temp := LineText;
          Len := Length(Temp);
          SpaceCount2 := 0;
          if Len + 1 >= CaretX then
          begin
            if CaretX > 1 then
            begin
              SpaceCount1 := LeftSpaces(Temp);
              if (Temp[CaretX - 1] <= #32) and (SpaceCount1 = fCaretX) then
              begin
                if SpaceCount1 > 0 then
                begin
                  BackCounter := fCaretY - 1;
                  if BackCounter < 0 then SpaceCount2 := 0;
                  while BackCounter >= 0 do                                     //gp 1999-08-28 (added equal)
                  begin
                    SpaceCount2 := LeftSpaces(Lines[BackCounter]);
                    if SpaceCount2 < SpaceCount1 then break;
                    Dec(BackCounter);
                  end;
                end;
                if SpaceCount2 = SpaceCount1 then SpaceCount2 := 0;             //gp 1999-08-28

                Helper := Copy(Temp, 1, SpaceCount1 - SpaceCount2);
                Delete(Temp, 1, SpaceCount1 - SpaceCount2);
                LineText := TrimRight(Temp);
                fCaretX := fCaretX - (SpaceCount1 - SpaceCount2);               //gp 1999-09-26
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
                FUndoList.AddChange(mwcrDelete, CaretXY, CaretXY, PChar(Helper),
                   smNormal);
{$ELSE}                                                                         //bds 1/25/1999
                FUndoList.AddChange(mwcrDelete, CaretXY, CaretXY, PChar(Helper));
{$ENDIF}                                                                        //bds 1/25/1999
              end else begin
                counter := 1;
{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
                if (ByteType(Temp, CaretX-2) = mbLeadByte) then Inc(counter);
{$ENDIF}
                CaretX := CaretX - counter;
                Helper := Temp[CaretX];
                If (counter > 1) Then Begin                                     //hk 1999-05-10
                  Helper := Helper + Temp[CaretX + 1];
                End;

                Caret := CaretXY;                                               //gp 12/27/1998
//              FUndoList.AddChange(mwcrDelete, Caret, Caret, PChar(Helper));   //gp 12/27/1998
//                Delete(Temp, CaretX, 1);
{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
                Delete(Temp, CaretX, counter);
{$ELSE}
                Delete(Temp, CaretX, 1);
{$ENDIF}
                LineText := TrimRight(Temp);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
                FUndoList.AddChange(mwcrDelete, Caret, Caret, PChar(Helper),
                   smNormal);
{$ELSE}                                                                         //bds 1/25/1999
                FUndoList.AddChange(mwcrDelete, Caret, Caret, PChar(Helper));   //gp 12/27/1998
{$ENDIF}                                                                        //bds 1/25/1999
              end;
            end else begin
              if fCaretY > 0 then
              begin
                Lines.Delete(fCaretY);
                {begin}                                                         //CdeB 12/16/1998
                for i := 0 to Marks.count-1 do
                  if Marks[i].Line >= CaretY then
                    Marks[i].Line := Marks[i].Line - 1;
                {end}                                                           //CdeB 12/16/1998
                CaretY := CaretY - 1;
                CaretX := Length(LineText) + 1;
                Caret := CaretXY;                                               //gp 12/27/1998
//              FUndoList.AddChange(mwcrDelete, CaretXY, CaretXY, PChar(#13#10));
                                                                                //gp 12/27/1998
                LineText := LineText + TrimRight(Temp);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
                FUndoList.AddChange(mwcrDelete, CaretXY, CaretXY, PChar(#13#10),
                   smNormal);
{$ELSE}                                                                         //bds 1/25/1999
                FUndoList.AddChange(mwcrDelete, CaretXY, CaretXY, PChar(#13#10));
                                                                                //gp 12/27/1998
{$ENDIF}                                                                        //bds 1/25/1999
              end;
            end;
          end else begin
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
            FUndoList.AddChange(mwcrDelete, CaretXY, CaretXY, '',
               smNormal);
{$ELSE}                                                                         //bds 1/25/1999
            FUndoList.AddChange(mwcrDelete, CaretXY, CaretXY, '');
{$ENDIF}                                                                        //bds 1/25/1999
            CaretX := CaretX - 1;
          end;
        end;
      ecDeleteChar:
        begin
          if ReadOnly then exit;
          if SelAvail then
          begin
{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
            FUndoList.AddChange(mwcrDeleteAfterCursor, fBlockBegin, fBlockEnd,
               PChar(SelText), SelectionMode);
{$ELSE}
            FUndoList.AddChange(mwcrDeleteAfterCursor, fBlockBegin, fBlockEnd,
               PChar(SelText));
{$ENDIF}
{end}                                                                           //bds 1/25/1999
            SetSelText('');
            exit;
          end;
          Temp := LineText;
          Len := Length(Temp);
          if Len >= CaretX then
          begin

{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
            Case ByteType(Temp, CaretX) Of
            mbLeadByte:
              Begin
                counter := 2;
              End;
            Else
              counter := 1;
            End;

            Helper := Temp[CaretX];
            If counter > 1 Then Begin
              Helper := Helper + Temp[CaretX+1];
            End;
{$ELSE}
            Helper := Temp[CaretX];
{$ENDIF}

{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
            FUndoList.AddChange(mwcrDeleteAfterCursor, CaretXY, CaretXY,
               PChar(Helper), smNormal);
{$ELSE}
            FUndoList.AddChange(mwcrDeleteAfterCursor, CaretXY, CaretXY,
               PChar(Helper));
{$ENDIF}
{end}                                                                           //bds 1/25/1999

{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
            Delete(Temp, CaretX, counter);                                      
{$ELSE}
            Delete(Temp, CaretX, 1);
{$ENDIF}

            LineText := TrimRight(Temp);
            {begin}                                                             //CdeB 12/16/1998
            for i:= 0 to Marks.count-1 do
              if Marks[i].Line > CaretY then
                Marks[i].Line := Marks[i].Line - 1;
            {end}                                                               //CdeB 12/16/1998
          end else begin
            if fCaretY < Lines.Count - 1 then
            begin
              Helper := StringOfChar(' ', fCaretX - Len);
              LineText := TrimRight(Temp + Helper + Lines[CaretY]);
{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
              FUndoList.AddChange(mwcrDeleteAfterCursor, CaretXY, CaretXY,
                 #13#10, smNormal);
{$ELSE}
              FUndoList.AddChange(mwcrDeleteAfterCursor, CaretXY, CaretXY,
                 #13#10);
{$ENDIF}
{end}                                                                           //bds 1/25/1999
              Lines.Delete(CaretY);
              if Lines.Count = 0 then
                Lines.Add('');
            end;
          end;
        end;
      ecDeleteWord:
        begin
          if ReadOnly then exit;
          WP := NextWordPos;
          if (CaretX = WP.x) and (CaretY = WP.y) then exit; // nothing to do
{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
          OldSelMode := fSelectionMode;
          try
            fSelectionMode := smNormal;
            SetBlockBegin(CaretXY);
            SetBlockEnd(WP);
            FUndoList.AddChange(mwcrDeleteAfterCursor, CaretXY, CaretXY,
               PChar(SelText), smNormal);
            SetSelText('');
          finally
            fSelectionMode := OldSelMode;
          end;
{$ELSE}
{end}                                                                           //bds 1/25/1999
          SetBlockBegin(CaretXY);
          SetBlockEnd(WP);
          FUndoList.AddChange(mwcrDeleteAfterCursor, CaretXY, CaretXY,
             PChar(SelText));
          SetSelText('');
{$ENDIF}                                                                        //bds 1/25/1999
          CaretXY := CaretXY; // Fix up cursor position
        end;
      ecDeleteLastWord:
        begin
          if ReadOnly then exit;
          WP := LastWordPos;
          if (CaretX = WP.x) and (CaretY = WP.y) then exit; // nothing to do
{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
          OldSelMode := fSelectionMode;
          try
            fSelectionMode := smNormal;
            SetBlockBegin(WP);
            SetBlockEnd(CaretXY);
            FUndoList.AddChange(mwcrDeleteAfterCursor, WP, CaretXY,
               PChar(SelText), smNormal);
            SetSelText('');
          finally
            fSelectionMode := OldSelMode;
          end;
{$ELSE}
{end}                                                                           //bds 1/25/1999
          SetBlockBegin(WP);
          SetBlockEnd(CaretXY);
          FUndoList.AddChange(mwcrDeleteAfterCursor, WP, CaretXY,
             PChar(SelText));
          SetSelText('');
{$ENDIF}                                                                        //bds 1/25/1999
          CaretXY := CaretXY; // Fix up cursor position
        end;
      ecDeleteBOL:
        begin
{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
          FUndoList.AddChange(mwcrDelete, Point(0, CaretY), Point(0, CaretY),
             PChar(Copy(LineText, 1, CaretX-1)), smNormal);
          OldSelMode := fSelectionMode;
          try
            fSelectionMode := smNormal;
            SetBlockBegin(Point(1, CaretY));
            SetBlockEnd(CaretXY);
            SetSelText('');
          finally
            fSelectionMode := OldSelMode;
          end;
          CaretXY := Point(1, CaretY); // Fix up cursor position
{$ELSE}
{end}                                                                           //bds 1/25/1999
          FUndoList.AddChange(mwcrDelete, Point(0, CaretY), Point(0, CaretY),
             PChar(Copy(LineText, 1, CaretX-1)));
          SetBlockBegin(Point(1, CaretY));
          SetBlockEnd(CaretXY);
          SetSelText('');
{$ENDIF}                                                                        //bds 1/25/1999
          CaretXY := Point(1, CaretY); // Fix up cursor position
        end;
      ecDeleteEOL:
        begin
{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
          FUndoList.AddChange(mwcrDeleteAfterCursor, CaretXY, CaretXY,
             PChar(Copy(LineText, CaretX, Length(LineText)-CaretX+1)),smNormal);
          OldSelMode := fSelectionMode;
          try
            fSelectionMode := smNormal;
            SetBlockBegin(CaretXY);
            SetBlockEnd(Point(Length(LineText)+1, CaretY));
            SetSelText('');
          finally
            fSelectionMode := OldSelMode;
          end;
{$ELSE}
{end}                                                                           //bds 1/25/1999
          FUndoList.AddChange(mwcrDeleteAfterCursor, CaretXY, CaretXY,
             PChar(Copy(LineText, CaretX, Length(LineText)-CaretX+1)));
          SetBlockBegin(CaretXY);
          SetBlockEnd(Point(Length(LineText)+1, CaretY));
          SetSelText('');
{$ENDIF}                                                                        //bds 1/25/1999
          CaretXY := CaretXY; // Fix up cursor position
        end;
      ecDeleteLine:
        begin
          if SelAvail then
            SetBlockBegin(CaretXY);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
          FUndoList.AddChange(mwcrDeleteAfterCursor, Point(1, CaretY), CaretXY,
           PChar(LineText+#13#10), smNormal);
{$ELSE}                                                                         //bds 1/25/1999
          FUndoList.AddChange(mwcrDeleteAfterCursor, Point(1, CaretY), CaretXY,
             PChar(LineText+#13#10));
{$ENDIF}                                                                        //bds 1/25/1999
          Lines.Delete(CaretY-1);
          if Lines.Count = 0 then
            Lines.Add('');
          CaretXY := CaretXY; // Fix up cursor position
        end;
      ecClearAll:
        begin
          if not ReadOnly then ClearAll;
        end;
      ecInsertLine,
      ecLineBreak:
        begin
          if ReadOnly then exit;
{begin}                                                                         //bds 1/24/1999
          if SelAvail then
          begin
{$IFDEF MWE_SELECTION_MODE}
            FUndoList.AddChange(mwcrDelete, fBlockBegin, fBlockEnd,
               PChar(SelText), SelectionMode);
{$ELSE}
            FUndoList.AddChange(mwcrDelete, fBlockBegin, fBlockEnd,
               PChar(SelText));
{$ENDIF}
            SetSelText('');
          end;
{end}                                                                           //bds 1/24/1999
          SpaceCount2 := 0;
          Temp := LineText;
          Temp2 := LineText;
          Len := Length(Temp);
          if Len > 0 then
          begin
            if Len >= CaretX then
            begin
              if CaretX > 1 then
              begin
                SpaceCount1 := LeftSpaces(Temp);
                if fCaretX <= SpaceCount1 then
                begin
                  Lines[fCaretY] := '';
                  Lines.Insert(CaretY, Temp);
//                FUndoList.AddChange(mwcrLineBreak, CaretXY, CaretXY, PChar(Temp));
                                                                                //tskurz 12/21/1998
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
                  FUndoList.AddChange(mwcrLineBreak, Point(CaretX,CaretY-1),
                    CaretXY, PChar(Temp), smNormal);
{$ELSE}                                                                         //bds 1/25/1999
                  FUndoList.AddChange(mwcrLineBreak,Point(CaretX,CaretY-1),     //tskurz 12/21/1998
                    CaretXY,PChar(Temp));
{$ENDIF}                                                                        //bds 1/25/1999
                  if Command = ecLineBreak then
                    CaretY := CaretY + 1;
                end else begin
                  Temp := Copy(LineText, 1, fCaretX);
                  LineText := TrimRight(Temp);
                  Helper := StringOfChar(' ', SpaceCount1);
                  Delete(Temp2, 1, fCaretX);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
                  FUndoList.AddChange(mwcrLineBreak, CaretXY, CaretXY,
                     PChar(Temp2), smNormal);
{$ELSE}                                                                         //bds 1/25/1999
                  FUndoList.AddChange(mwcrLineBreak, CaretXY, CaretXY,
                     PChar(Temp2));
{$ENDIF}                                                                        //bds 1/25/1999
                  Temp2 := Helper + Temp2;
                  Lines.Insert(CaretY, Temp2);
                  if Command = ecLineBreak then
                    CaretXY := Point(SpaceCount1 + 1, CaretY + 1);
                end;
              end else begin
                BackCounter := fCaretY - 1;
                while BackCounter >= 0 do                                       //gp 1999-08-28 (added =)
                begin
                  if Length(Lines[BackCounter]) > 0 then break;
                  dec(BackCounter);
                end;
                Lines[fCaretY] := '';
                Lines.Insert(CaretY, Temp);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
                FUndoList.AddChange(mwcrLineBreak, CaretXY, CaretXY,
                   PChar(Temp2), smNormal);
{$ELSE}                                                                         //bds 1/25/1999
                FUndoList.AddChange(mwcrLineBreak, CaretXY, CaretXY,
                   PChar(Temp2));
{$ENDIF}                                                                        //bds 1/25/1999
                if Command = ecLineBreak then
                  CaretY := CaretY + 1;
              end;
            end else begin
              BackCounter := fCaretY;
              while BackCounter >= 0 do                                         //gp 1999-08-28 (added =)
              begin
                SpaceCount2 := LeftSpaces(Lines[BackCounter]);
                if Length(Lines[BackCounter]) > 0 then break;
                dec(BackCounter);
              end;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
              FUndoList.AddChange(mwcrLineBreak, CaretXY, CaretXY, NIL,
                 smNormal);
{$ELSE}                                                                         //bds 1/25/1999
              FUndoList.AddChange(mwcrLineBreak, CaretXY, CaretXY, NIL);
{$ENDIF}                                                                        //bds 1/25/1999
              if Command = ecLineBreak then
                CaretX := SpaceCount2 + 1;
              if (Command = ecInsertLine) or ScrollPastEol then                 //gp 1999-08-28
                Lines.Insert(CaretY, '');
              if Command = ecLineBreak then
                fCaretY := fCaretY + 1;                                         //gp 1999-09-26
{begin}                                                                         //gp 1999-08-28
              if (Command = ecLineBreak) and (not ScrollPastEol) and AutoIndent
              then begin
                Lines.Insert(fCaretY, StringOfChar(' ', SpaceCount2));
                CaretX := SpaceCount2 + 1;
              end;
{end}                                                                           //gp 1999-08-28
            end;
          end else begin
            BackCounter := fCaretY;
            while BackCounter >= 0 do
            begin
              SpaceCount2 := LeftSpaces(Lines[BackCounter]);
              if Length(Lines[BackCounter]) > 0 then break;
              dec(BackCounter);
            end;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
            FUndoList.AddChange(mwcrLineBreak, CaretXY, CaretXY, NIL, smNormal);
{$ELSE}                                                                         //bds 1/25/1999
            FUndoList.AddChange(mwcrLineBreak, CaretXY, CaretXY, NIL);
{$ENDIF}                                                                        //bds 1/25/1999
            if Command = ecLineBreak then
              CaretX := SpaceCount2 + 1;
            Lines.Insert(fCaretY, '');
            if Command = ecLineBreak then
              CaretY := CaretY + 1;
          end;
          {begin}                                                               //CdeB 12/16/1998
          for i:= 0 to Marks.count-1 do
            if Marks[i].Line >= CaretY then
              Marks[i].Line := Marks[i].Line + 1;
          {end}                                                                 //CdeB 12/16/1998
        end;
      ecChar:
        begin
          // #127 is Ctrl+Backspace.

          {begin}                                                               //ar 1999-05-10
          if (AChar = #9) and (fTabIndent > 0) then begin                       //sva 1999-09-11
            {* Emulate a TAB * }
//            V_MyIndent := 0;                                                  //ws 1999-09-07
            V_MyIndent := fCaretX mod fTabIndent;
            repeat
              CommandProcessor(ecChar,#32,nil);
              inc(V_MyIndent);
            until V_MyIndent >= fTabIndent;
            exit;
          end
	  else
          {end}                                                                 //ar 1999-05-10
            if (AChar < #32) or (AChar = #127) or ReadOnly then exit; // This will cause problems when we put tabs in.
          if SelAvail then
          begin
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
//            FUndoList.AddChange(mwcrDelete,fBlockBegin,fBlockEnd,PChar(SelText),  //th 1999-09-22
            FUndoList.AddChange(mwcrSelDelete,fBlockBegin,fBlockEnd,PChar(SelText),
               SelectionMode);
{begin}                                                                         //th 1999-09-22
            if SelectionMode = smLine then
              StartOfBlock := Point(1, BlockBegin.Y)
            else
{end}
{$ELSE}                                                                         //bds 1/25/1999
//            FUndoList.AddChange(mwcrDelete,fBlockBegin,fBlockEnd,PChar(SelText)); //th 1999-09-22
            FUndoList.AddChange(mwcrSelDelete,fBlockBegin,fBlockEnd,PChar(SelText));
{$ENDIF}                                                                        //bds 1/25/1999
//            StartOfBlock := fBlockBegin;                                      //th 1999-09-22
            StartOfBlock := BlockBegin;
            SetSelText(AChar);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
//            FUndoList.AddChange(mwcrInsert,StartOfBlock,fBlockEnd,PChar(SelText),
//               SelectionMode);
            FUndoList.AddChange(mwcrInsert,StartOfBlock,fBlockEnd, nil,
               smNormal);                                                       //th 1999-09-22
{$ELSE}                                                                         //bds 1/25/1999
//            FUndoList.AddChange(mwcrInsert,StartOfBlock,fBlockEnd,PChar(SelText));  //th 1999-09-22
            FUndoList.AddChange(mwcrInsert,StartOfBlock,fBlockEnd,nil);
{$ENDIF}                                                                        //bds 1/25/1999
            exit;
          end;
          Temp := LineText;
          Len := Length(Temp);
          if Len < CaretX then
          begin
            Helper := StringOfChar(' ', CaretX - Len);
            Temp := Temp + Helper;
            Helper := '';
          end;
          if fInserting then
          begin
            oldScroll := fScrollPastEOL;
            fScrollPastEOL := true;
            try
              StartOfBlock := CaretXY;
              Insert(AChar, Temp, CaretX);
              CaretX := CaretX + 1;
              LineText := TrimRight(Temp); ;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
              FUndoList.AddChange(mwcrInsert, StartOfBlock, CaretXY, NIL,
                 smNormal);
{$ELSE}                                                                         //bds 1/25/1999
              FUndoList.AddChange(mwcrInsert, StartOfBlock, CaretXY, NIL);
{$ENDIF}                                                                        //bds 1/25/1999
              Temp := '';
              if CaretX >= LeftChar + fCharsInWindow then
                LeftChar := LeftChar + min(25, fCharsInWindow - 1);
            finally
              fScrollPastEOL := oldScroll;
            end;
          end else begin
            oldScroll := fScrollPastEOL;
            fScrollPastEOL := true;
            try
              StartOfBlock := CaretXY;
              Helper := Temp[CaretX];
// This is extremely inefficient.  Need some sort of direct access to the string here.
              Temp[CaretX] := AChar;
              CaretX := CaretX + 1;
              LineText := TrimRight(Temp);
//              CaretX := CaretX + 1;                                           //bds 12/28/1998, removed
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
              FUndoList.AddChange(mwcrInsert, StartOfBlock, CaretXY,
                 PChar(Helper), smNormal);
{$ELSE}                                                                         //bds 1/25/1999
              FUndoList.AddChange(mwcrInsert, StartOfBlock, CaretXY, PChar(Helper));
{$ENDIF}                                                                        //bds 1/25/1999
              Temp := '';
              if CaretX >= LeftChar + fCharsInWindow then
                LeftChar := LeftChar + min(25, fCharsInWindow - 1);
            finally
              fScrollPastEOL := oldScroll;
            end;
          end;
        end;
      ecUndo:
        begin
          Undo;
        end;
      ecRedo:
        begin
          //raise Exception.Create('Redo not yet supported by mwEdit');
          Redo;                                                                 //tskurz 1/4/1999
        end;
      ecGotoMarker0..ecGotoMarker9:
        begin
          if BookMarkOptions.EnableKeys then begin                              //gp 12/30/1998
            GotoBookMark(Command - ecGotoMarker0);                              //CdeB 12/16/1998 - removed, //gp 12/31/1998 - reinstated
          end;

        end;
      ecSetMarker0..ecSetMarker9:
        begin
          if BookMarkOptions.EnableKeys then begin                              //gp 12/30/1998
            CX := Command - ecSetMarker0;
                                                                                //CdeB 12/16/1998 - removed, //gp 12/31/1998 - reinstated
            if assigned(fBookMarks[CX]) then                                    //gp 12/31/1998
            begin
              moveBkm := (fBookMarks[CX].Line <> CaretY);
              ClearBookMark(CX);
              if moveBkm then
                SetBookMark(CX, CaretX, CaretY);
            end else
              SetBookMark(CX, CaretX, CaretY);

{begin}                                                                         //bds 12/23/1998
(* This commented out stuff will become ecSetMarkerAt in the next version
{end}                                                                           //bds 12/23/1998
            if Data <> NIL then
            begin
              with PPoint(Data)^ do
              begin
                CX := Command - ecSetMarker0;
                if fBookMarks[CX].IsSet then
                begin
                  moveBkm := (fBookMarks[CX].Y <> Y);
                  ClearBookMark(CX);
                  if moveBkm then
                    SetBookMark(CX, X, Y);
                end else
                  SetBookMark(CX, X, Y);
              end;
            end;
*)                                                                              //bds 12/23/1998
          end; // if BookMarkOptions.EnableKeys
        end;
      ecCut:
        begin
          if (not ReadOnly) and SelAvail then
            CutToClipboard;
        end;
      ecCopy:
        begin
          CopyToClipboard;
        end;
      ecPaste:
        begin
          if not ReadOnly then PasteFromClipboard;
        end;
      ecScrollUp:
        begin
          TopLine := TopLine - 1;
          if CaretY > TopLine + LinesInWindow - 1 then
            CaretY := TopLine + LinesInWindow - 1;
          Update;                                                               //th 1999-09-15
        end;
      ecScrollDown:
        begin
          TopLine := TopLine + 1;
          if CaretY < TopLine then
            CaretY := TopLine;
          Update;                                                               //th 1999-09-15
        end;
      ecScrollLeft:
        begin
          LeftChar := LeftChar - 1;
          if CaretX > LeftChar + CharsInWindow then
            CaretX := LeftChar + CharsInWindow;
          Update;                                                               //th 1999-09-15
        end;
      ecScrollRight:
        begin
          LeftChar := LeftChar + 1;
          if CaretX < LeftChar then
            CaretX := LeftChar;
          Update;                                                               //th 1999-09-15
        end;
      ecInsertMode:
        begin
          InsertMode := TRUE;
        end;
      ecOverwriteMode:
        begin
          InsertMode := FALSE;
        end;
      ecToggleMode:
        begin
          InsertMode := not InsertMode;
        end;
      ecBlockIndent:
        begin
        end;
      ecBlockUnindent:
        begin
        end;
{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
      ecNormalSelect,
      ecColumnSelect,
      ecLineSelect:
        begin
          SelectionMode := SEL_MODE[Command];
        end;
{$ENDIF}
{end}                                                                           //bds 1/25/1999

{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-05-10
      ecImeStr:                                                                 
        begin
          if ReadOnly then exit;
          SetLength(s, StrLen(Data));
          StrCopy(PChar(s), PChar(Data));
          if SelAvail then begin
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
            FUndoList.AddChange(mwcrDelete, fBlockBegin, fBlockEnd,
               PChar(Helper), smNormal);
{$ELSE}                                                                         //bds 1/25/1999
            FUndoList.AddChange(mwcrDelete, fBlockBegin, fBlockEnd, PChar(Helper));
{$ENDIF}                                                                        //bds 1/25/1999
            StartOfBlock := fBlockBegin;
            SetSelText(s);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
            FUndoList.AddChange(mwcrInsert, fBlockBegin, fBlockEnd,
               PChar(Helper), smNormal);
{$ELSE}                                                                         //bds 1/25/1999
            FUndoList.AddChange(mwcrInsert, fBlockBegin, fBlockEnd, PChar(Helper));
{$ENDIF}                                                                        //bds 1/25/1999
            exit;
          end;
          Temp := LineText;
          Len := Length(Temp);
          if Len < CaretX then begin
            Helper := StringOfChar(' ', CaretX - Len);
            Temp := Temp + Helper;
            Helper := '';
          end;
          if fInserting then begin
            oldScroll := fScrollPastEOL;
            fScrollPastEOL := true;
            try
              StartOfBlock := CaretXY;
              Insert(s, Temp, CaretX);
              CaretX := CaretX + Length(s);
              LineText := TrimRight(Temp); ;
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
              FUndoList.AddChange(mwcrInsert, StartOfBlock, CaretXY,
                 Nil, smNormal);
{$ELSE}                                                                         //bds 1/25/1999
              FUndoList.AddChange(mwcrInsert, StartOfBlock, CaretXY, Nil);
{$ENDIF}                                                                        //bds 1/25/1999
              Temp := '';
              if CaretX >= LeftChar + fCharsInWindow then
                LeftChar := LeftChar + min(25, fCharsInWindow - 1);
            finally
              fScrollPastEOL := oldScroll;
            end;
          end else begin
            oldScroll := fScrollPastEOL;
            fScrollPastEOL := true;
            try
              StartOfBlock := CaretXY;
              Helper := Copy(Temp, CaretX, Length(s));
              Delete(Temp, CaretX, Length(s));
              Insert(s, Temp, CaretX);
              CaretX := CaretX + Length(s);;
              LineText := TrimRight(Temp);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
              FUndoList.AddChange(mwcrInsert, StartOfBlock, CaretXY,
                  PChar(Helper), smNormal);
{$ELSE}                                                                         //bds 1/25/1999
              FUndoList.AddChange(mwcrInsert, StartOfBlock, CaretXY, PChar(Helper));
{$ENDIF}                                                                        //bds 1/25/1999
              Temp := '';
              if CaretX >= LeftChar + fCharsInWindow then
                LeftChar := LeftChar + min(25, fCharsInWindow - 1);
            finally
              fScrollPastEOL := oldScroll;
            end;
          end;
        end;
{$ENDIF}
    end;
  finally
    DecPaintLock;
  end;

  // Add to macro recorder stuff here?  Can't without rewriting several "exit"
  // statements above, or putting it in the finally section.

  {begin}                                                                       //DG 1/22/1999 OnCommandDone
  if assigned(fOnCommandDone) then
     fOnCommandDone (Self);
  {end}
end;

procedure TmwCustomEdit.ProcessCommand(var Command: TmwEditorCommand;           //bds 12/23/1998
   var AChar: char; Data: pointer);
begin
  if Command < ecUserFirst then
  begin
    if assigned(FOnProcessCommand) then
      FOnProcessCommand(Command, AChar, Data);
  end else begin
    if assigned(FOnProcessUserCommand) then
      FOnProcessUserCommand(Command, AChar, Data);
  end;
end;

procedure TmwCustomEdit.ClearAll;
begin
  IncPaintLock;
  try
    if SelAvail then
      SetBlockBegin(Point(1,1));
    Lines.Clear;
// this one is already in Lines.Clear
//    Lines.Add('');                                                            //mh 1999-05-12
  finally
    DecPaintLock;
  end;
end;

// NOTE:  These functions (NextWordPos & LastWordPos) are not very efficient or
//        pretty.  I just wrote them as "placeholders" until we work out
//        exactly how next/prev word should really be implemented.
//mt 12/22/1998 fixed to support IdentChars. Still could use some cleaning up.
function TmwCustomEdit.NextWordPos: TPoint;
var
  CX, CY: Integer;
  X: integer;
  FoundWhiteSpace: boolean;
  Len: Integer;
  Temp: string;
  IdChars: TIdentChars;                                                         //mt 12/22/1998
begin
  Result := CaretXY;
  if CaretX < Length(LineText) then
  begin
    CX := CaretX;
    CY := CaretY;
  end else begin
    if CaretY >= Lines.Count then exit;
    CY := CaretY + 1;
    if CY > Lines.Count then exit;
    if Trim(Lines[CY-1]) = '' then
    begin
      Result := Point(1, CY);
      exit;
    end;
    CX := 1;
  end;

  {begin}                                                                       //bds 12/22/1998
  if fHighlighter <> NIL then
    IdChars := fHighlighter.IdentChars
  else
    IDchars := [#33..#255];
  {end}                                                                         //bds 12/22/1998

  Temp := Lines[CY-1];
  Len := Length(Temp);
  FoundWhiteSpace := (not (Temp[CX] in IdChars)) or (CY <> CaretY);             //mt 12/22/1998
  if not FoundWhiteSpace then
    for X := CX to Len do
      if (not (Temp[X] in IdChars)) then                                        //mt 12/22/1998
      begin
        CX := X;
        FoundWhiteSpace := TRUE;
        break;
      end;

  if FoundWhiteSpace then
  begin
    FoundWhiteSpace := FALSE;                                                   //mt 12/22/1998
    for X := CX to Len do
      if (Temp[X] in IdChars) then                                              //mt 12/22/1998
      begin
        Result := Point(X, CY);
        FoundWhiteSpace := TRUE;
        break;
      end;
  end;

  if not FoundWhiteSpace then
    Result := Point(Len+1, CY);

end;

//mt 12/22/1998 fixed to support IdentChars
function TmwCustomEdit.LastWordPos: TPoint;
var
  CX, CY: Integer;
  X: integer;
  FoundNonWhiteSpace: boolean;
  Len: Integer;
  Temp: string;
  IdChars: TIdentChars;                                                         //mt 12/22/1998
begin
  Result := CaretXY;
  CX := CaretX;
  Len := Length(LineText);
  if CX > Len then
    CX := Len+1;
  if (CX > 1) then
  begin
    CY := CaretY;
  end else begin
    if CaretY < 2 then
    begin
      Result := Point(1,1);
      exit;
    end;
    CY := CaretY - 1;
    CX := Length(Lines[CY-1]);
    begin
      Result := Point(CX+1, CY);
      exit;
    end;
  end;

  {begin}                                                                       //bds 12/22/1998
  if fHighlighter <> NIL then
    IdChars := fHighlighter.IdentChars
  else
    IDchars := [#33..#255];
  {end}                                                                         //bds 12/22/1998

  Temp := Lines[CY-1];
  FoundNonWhiteSpace := (Temp[CX-1] in IdChars);                                //mt 12/22/1998
  if not FoundNonWhiteSpace then
    for X := CX downto 2 do
      if Temp[X-1] in IdChars then                                              //mt 12/22/1998
      begin
        CX := X-1;
        FoundNonWhiteSpace := TRUE;
        break;
      end;

  if FoundNonWhiteSpace then
  begin
    FoundNonWhiteSpace := FALSE;
    for X := CX downto 2 do
      if (not(Temp[X-1] in IdChars)) then                                       //mt 12/22/1998
      begin
        Result := Point(X, CY);
        FoundNonWhiteSpace := TRUE;
        break;
      end;
    if not FoundNonWhiteSpace then
      Result := Point(1, CY);
  end else begin
    dec(CY);
    if CY = 0 then Result := Point(0,0)                                         //gp 01/19/1999
              else Result := Point(Length(Lines[CY-1])+1, CY);
  end;

end;

{begin}                                                                         //bds 1/25/1999
{$IFDEF MWE_SELECTION_MODE}
procedure TmwCustomEdit.SetSelectionMode(const Value: TSelectionMode);
begin
  if FSelectionMode <> Value then
  begin
    FSelectionMode := Value;
    if SelAvail then
      Invalidate;
  end;
end;
{$ENDIF}
{end}                                                                           //bds 1/25/1999

{begin}                                                                         //jdj 12/27/1998
procedure TmwCustomEdit.BeginUpdate;
begin
  IncPaintLock;
end;

procedure TmwCustomEdit.EndUpdate;
begin
  DecPaintLock;
end;
{end}                                                                           //jdj 12/27/1998

{begin}                                                                         //bds 1/24/1999
// Pass NIL in PrintFont to use editor's current font.
procedure TmwCustomEdit.Print(PrintFont: TFont; Options: TmwPrintOptions);
{begin}                                                                         //hdl 1999-05-11
var
  PageNumber: integer;
  timeStr: string;
  dateStr: string;
{end}                                                                           //hdl 1999-05-11
  function PaintLines(UseHighlighter: boolean; MarginPixels: TRect; StartLine,
     StopLine, StartCol, StopCol: integer; ColsApplyToAll: boolean): boolean;
  var
    PrinterETO: PIntArray;

    procedure PrintHeaderFooter(Strs: TStringList; XOffset: integer;
       var YOffset: integer; LineHeight, CharWidth: integer);

       {begin}                                                                  //hdl 1999-05-11
       function ParseScript(s: string): string;
       var
         i, j: integer;
         v: string;
       begin
          i := 1;
          Result := '';
          while i <= Length(s) do begin
            if s[i] = '$' then begin
              for j := i + 1 to Length(s) do
                if s[j] = '$' then break;
              if i + 1 = j then v := '$'
              else v := Copy(s, i + 1, j - i - 1);

              v := UpperCase(Trim(v));
              if v = 'PAGENUM' then v := IntToStr(PageNumber)
              else if v = 'TITLE' then v := Options.Title
              else if v = 'TIME' then v := timeStr
              else if v = 'DATE' then v := dateStr
              else if v = 'DATETIME' then v := dateStr + ' ' + timeStr
              else if v = 'TIMEDATE' then v := timeStr + ' ' + dateStr;

              Result := Result + v;
              i := j + 1;
            end
            else begin
              Result := Result + s[i];
              Inc(i);
            end;
          end;
       end;
       {end}                                                                    //hdl 1999-05-11
    var
      x: integer;
      TextRect: TRect;
      {begin}                                                                   //hdl 1999-05-11
      parse: string;
      al: TmwHeaderFooterAlign;
      xoffs: integer;
      w: integer;
      {end}                                                                     //hdl 1999-05-11
    begin
      if (Strs <> NIL) and (Strs.Count > 0) then
      begin
        for x := 0 to Strs.Count-1 do
        begin
        // right margin!!!
          TextRect := Rect(0, YOffset, Printer.PageWidth - MarginPixels.Right,
             YOffset + LineHeight);

          {begin}                                                               //hdl 1999-05-11
          parse := ParseScript(Strs[x]);
          w := Printer.Canvas.TextWidth(parse);
          al := TmwHeaderFooterAlign(Strs.Objects[x]);
          xoffs := XOffset;
          case al of
            hfaRight: Inc(xoffs, TextRect.Right - XOffset - w);
            hfaCenter: Inc(xoffs, (TextRect.Right - XOffset - w) div 2);
          end;
          {end}                                                                 //hdl 1999-05-11

          {begin}                                                               //hdl 1999-05-11
//        ExtTextOut(Printer.Canvas.Handle, XOffset, YOffset, ETO_CLIPPED,
//           @TextRect, @Strs[x][1], Length(Strs[x]), @PrinterETO[0]);
          ExtTextOut(Printer.Canvas.Handle, xoffs, YOffset, ETO_CLIPPED,
             @TextRect, @parse[1], Length(parse), @PrinterETO^[0]);
          {end}                                                                 //hdl 1999-05-11
          inc(YOffset, LineHeight);
        end;
      end;
    end;

  var
    StartIndex, StopIndex, XOffset, YOffset, LineIndex, LineLen, x: integer;
    PrinterCharWidth, PrinterTextHeight: integer;
    Metrics: TTextMetric;
    SaveFontStyle: TFontStyles;
    TokenPos, TokenIndex, TokenLen: integer;
    Token: String;
    TextRect: TRect;
    PrinterBackground: TColor;
    PrinterFont: TFont;
//  PageNumber: integer;                                                        //hdl 1999-05-11
    Abort: boolean;
    attr: TmwHighLightAttributes;                                               //mh 1999-09-12 
  begin
    Result := FALSE;
    PageNumber := 1;
    if UseHighlighter then
    begin
      SaveFontStyle := Printer.Canvas.Font.Style;
      try
        Printer.Canvas.Font.Style := Printer.Canvas.Font.Style +
           [fsBold, fsItalic];
        GetTextMetrics(Printer.Canvas.Handle, Metrics);
      finally
        Printer.Canvas.Font.Style := SaveFontStyle;
      end;
    end else begin
      GetTextMetrics(Printer.Canvas.Handle, Metrics);
    end;

    with Metrics do
    begin
      // Note:  Through trial-and-error I found that tmAveCharWidth should be
      // used instead of tmMaxCharWidth as you would think.  I'm basing this
      // behavior on the Delphi IDE editor behavior.  If tmMaxCharWidth is used,
      // we end up with chars being much farther apart than the same font in the
      // IDE.
      PrinterCharWidth := tmAveCharWidth;
      PrinterTextHeight := tmHeight + tmExternalLeading + fExtraLineSpacing;
    end;

    PrinterBackground := Printer.Canvas.Brush.Color;
    PrinterFont := TFont.Create;
    PrinterFont.Assign(Printer.Canvas.Font);
{begin}                                                                         //mh 1999-09-12
    PrinterETO := GetIntArray(MaxLeftChar, PrinterCharWidth);
    try
(*
      // Must have range checking turned off here!
      for x := 0 to MaxLeftChar-1 do
        {$IFOPT R+} {$DEFINE MWE_RESET_RANGE_CHECK} {$R-} {$ENDIF}
        PrinterETO[x] := PrinterCharWidth;
        {$IFDEF MWE_RESET_RANGE_CHECK} {$R+} {$UNDEF MWE_RESET_RANGE_CHECK} {$ENDIF}
*)
{end}                                                                           //mh 1999-09-12
      YOffset := MarginPixels.Top;

      Abort := FALSE;
      PrintStatus(psNewPage, PageNumber, Abort);
      if Abort then
      begin
        Printer.Abort;
        exit;
      end;

      // Print initial header, if any
      PrintHeaderFooter(Options.Header, MarginPixels.Left, YOffset,
         PrinterTextHeight, PrinterCharWidth);

      if UseHighlighter then
      begin
        // Set up the highlighter
//        fHighLighter.SetCanvas(Printer.Canvas);                               //mh 1999-09-12
        fHighLighter.SetRange(Lines.Objects[StartLine-1]);
      end;

      // Loop through all the lines requested.
      for LineIndex := StartLine-1 to StopLine-1 do
      begin
        LineLen := Length(Lines[LineIndex]);

        if ColsApplyToAll or ((LineIndex = StartLine-1) and (StartCol > 0)) then
          StartIndex := StartCol
        else
          StartIndex := 1;

// word wrap

        if ColsApplyToAll or ((LineIndex = StopLine-1) and (StopCol > 0)) then
          StopIndex := Min(LineLen, StopCol)
        else
          StopIndex := LineLen;

        if StartIndex <= LineLen then
        begin
          if UseHighlighter then
          begin
            fHighLighter.SetLine(Lines[LineIndex],LineIndex);                   //aj 1999-02-22

            XOffset := MarginPixels.Left;
            if ColsApplyToAll or (StartIndex = 1) then
              Dec(XOffset, ((StartIndex-1) * PrinterCharWidth));

            // Repeat until we get to the end of the line.
            while not fHighLighter.GetEol do
            begin
              // Get the current token (string) to be painted.
              Token := fHighLighter.GetToken;
              // Get it's index in the line string
              TokenPos := fHighLighter.GetTokenPos;
              TokenLen := Length(Token);
              // If this token comes entirely before the left of the printing
              // area or starts to the right of it, we don't need to do anything
              // with it.
              if (TokenPos + TokenLen >= StartIndex) and
                 (TokenPos < StopIndex) then
              begin
{begin}                                                                         //mh 1999-09-12
                // Only use background color if different from editor's normal
                // background color.  Not everyone's clWindow color is white...
//                if Printer.Canvas.Brush.Color = Self.Color then
//                  Printer.Canvas.Brush.Color := PrinterBackground;

                // The Next method of the highlighters does not set the
                // canvas properties any longer, so we have to do it here:
                attr := fHighlighter.GetTokenAttribute;
                if Assigned(attr) then begin
                  Printer.Canvas.Font.Style := attr.Style;
                  // Should the printout use colors?
                  if not Options.IgnoreColors then begin
                    Printer.Canvas.Font.Color := attr.Foreground;
                    // Only use background color if different from editor's
                    // normal background color.  Not everyone's clWindow color
                    // is white...
                    if attr.Background = Color then
                      Printer.Canvas.Brush.Color := PrinterBackground
                    else
                      Printer.Canvas.Brush.Color := attr.Background;
                  end;
                end;
{end}                                                                           //mh 1999-09-12
                if (StartIndex > TokenPos + 1) and
                   (StartIndex < TokenPos + TokenLen + 1) then
                begin
                  TokenIndex := StartIndex - TokenPos;
                  Inc(TokenPos, TokenIndex - 1);
                  TokenLen := Min(TokenLen - (TokenIndex - 1),
                     StopIndex - StartIndex + 1);
                end else if (StopIndex >= TokenPos + 1) and
                   (StopIndex < TokenPos + TokenLen + 1) then
                begin
                  TokenIndex := 1;
                  TokenLen := StopIndex - TokenPos;
                end else
                  TokenIndex := 1;

                TextRect := Rect(0,YOffset,Printer.PageWidth-MarginPixels.Right,
                   YOffset + PrinterTextHeight);
                // Paint the token string
                ExtTextOut(Printer.Canvas.Handle, XOffset + TokenPos *
                   PrinterCharWidth, YOffset, ETO_CLIPPED, @TextRect,
                   @Token[TokenIndex], TokenLen, @PrinterETO[0]);
              end;
              // Tell highlighter to find the next token. When it does, it will
              // set the correct colors and font style for that token.
              fHighLighter.Next;
            end;
          end else begin
            // Plain text, no highlighting
            if ColsApplyToAll or (StartIndex = 1) then
              XOffset := MarginPixels.Left
            else
              XOffset := MarginPixels.Left + PrinterCharWidth * (StartIndex-1);

            // Don't bother if there isn't anything to draw.
            if StopIndex >= StartIndex then
            begin
              TextRect := Rect(0, YOffset, Printer.PageWidth-MarginPixels.Right,
                 YOffset + PrinterTextHeight);
              ExtTextOut(Printer.Canvas.Handle, XOffset, YOffset, ETO_CLIPPED,
                 @TextRect, @Lines[LineIndex][StartIndex],
                 StopIndex-StartIndex+1, @PrinterETO[0]);
            end;
          end;
        end;

        inc(YOffset, PrinterTextHeight);
        // Will an entire line fit horizontally in space remaining?  First,
        // figure out where the bottom of the next line would be printed
        x := YOffset + PrinterTextHeight;
        // Add space for any footer lines
        if (Options.Footer <> NIL) then
          inc(x, Options.Footer.Count * PrinterTextHeight);
        // Will it all fit on the page?
        if x > (Printer.PageHeight - MarginPixels.Bottom) then
        begin
          // Highlighter may have changed the font/color.  Reset them.
          if UseHighlighter then
          begin
            Printer.Canvas.Font := PrinterFont;
            Printer.Canvas.Brush.Color := PrinterBackground;
          end;

          // Nope, finish up this page and start the next.
          if (Options.Footer <> NIL) then
          begin
            YOffset := Printer.PageHeight - MarginPixels.Bottom -
               (Options.Footer.Count * PrinterTextHeight);
            PrintHeaderFooter(Options.Footer, MarginPixels.Left, YOffset,
               PrinterTextHeight, PrinterCharWidth);
          end;
          Printer.NewPage;

          inc(PageNumber);
          PrintStatus(psNewPage, PageNumber, Abort);
          if Abort then
          begin
            Printer.Abort;
            exit;
          end;

          YOffset := MarginPixels.Top;
          PrintHeaderFooter(Options.Header, MarginPixels.Left, YOffset,
             PrinterTextHeight, PrinterCharWidth);
        end;
      end;
      // Print final footer, if any
      if (Options.Footer <> NIL) then
      begin
        // Highlighter may have changed the font/color.  Reset them.
        if UseHighlighter then
        begin
          Printer.Canvas.Font := PrinterFont;
          Printer.Canvas.Brush.Color := PrinterBackground;
        end;

        YOffset := Printer.PageHeight - MarginPixels.Bottom -
           (Options.Footer.Count * PrinterTextHeight);
        PrintHeaderFooter(Options.Footer, MarginPixels.Left, YOffset,
           PrinterTextHeight, PrinterCharWidth);
      end;
    finally
      FreeMem(PrinterETO);
      PrinterFont.Free;
    end;
    Result := TRUE;
  end;

  function MarginsInPixels(MarginUnits: TmwMarginUnits;
     const Margins: TRect): TRect;
  var
    XPix, YPix: integer;
    XOffset, YOffset: integer;
  begin
    // Pixels per inch
    XPix := GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSX);
    YPix := GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSX);
    // I use MulDiv because it's faster/safer/etc that doing the floating point
    // math directly.  When you see MulDiv, you can translate this way:
    //   R := MulDiv(X, Y, Z);
    //       is
    //   R := Round((X * Y) / Z)
    // MulDiv is safer because Delphi would truncate (X * Y) to a 32-bit value
    // before dividing it by Z.  This often results in very hard to find bugs.
    // For example, if x and y were 90,000 and z were 10, using the direct
    // method you would get a value of -48,993,459 instead of the 810,000,000
    // value you would expect.  90,000 multiplied by 90,000 results in a value
    // that won't fit into a 32-bit value, so it get's "lopped off" at 32-bits.
    // This is documented behavior, so it is not a bug in Delphi.
    // MulDiv stores the multiplication result in a 64-bit value, so it doesn't
    // have this behavior.
    // In practice, we aren't likely to exceed a 32-bit value in our
    // multiplications here, but it's a very good habit to get into.  Would
    // *you* want to figure out what went wrong given the above description?
    // I wouldn't.
    case MarginUnits of
      muThousandthsOfInches:
        begin
          Result.Left := MulDiv(Margins.Left, XPix, 1000);
          Result.Right := MulDiv(Margins.Right, XPix, 1000);
          Result.Top := MulDiv(Margins.Top, YPix, 1000);
          Result.Bottom := MulDiv(Margins.Bottom, YPix, 1000);
        end;
      muMillimeters:
        begin
          // Same as inches, but divide by 0.0254 (25.4 mm per inch)
          Result.Left := MulDiv(MulDiv(Margins.Left, XPix, 1000), 10000, 254);
          Result.Right := MulDiv(MulDiv(Margins.Right, XPix, 1000), 10000, 254);
          Result.Top := MulDiv(MulDiv(Margins.Top, YPix, 1000), 10000, 254);
          Result.Bottom := MulDiv(MulDiv(Margins.Bottom,YPix,1000),10000,254);
        end;
    else // muPixels
      Result := Margins;
    end;

    // Account for printer limitations.  All printers have an area surrounding
    // the paper that physical can not be printed on.  Delphi's TPrinter
    // object starts at that area when you print at 0,0 on it.  So, we have to
    // subtract the size of this non-printable area out of the margins so that
    // it accounts for it.
    XOffset := GetDeviceCaps(Printer.Canvas.Handle, PHYSICALOFFSETX);
    YOffset := GetDeviceCaps(Printer.Canvas.Handle, PHYSICALOFFSETY);
    Dec(Result.Left, XOffset);
    Dec(Result.Right, XOffset);
    Dec(Result.Top, YOffset);
    Dec(Result.Bottom, YOffset);
    Result.Left := Max(Result.Left, 0);
    Result.Right := Max(Result.Right, 0);
    Result.Top := Max(Result.Top, 0);
    Result.Bottom := Max(Result.Bottom, 0);
  end;
var
  PrintArea: TRect;
  Abort: boolean;
{begin}                                                                         //mh 1999-09-12
//  sysTime: TSystemTime;
//  buff: array [0..32] of char;
begin
  if Options.SelectedOnly and not SelAvail then exit;

// should be functionally equivalent
  datestr := DateToStr(Date);
  timestr := TimeToStr(Time);
(*
  {begin}                                                                       //hdl 1999-05-11
  GetLocalTime(sysTime);
  GetTimeFormat(
    LOCALE_USER_DEFAULT,
    0,
    @sysTime,
    nil,                                                                        //gp 1999-05-11
//  PChar('tt hh:mm'),                                                          //gp 1999-05-11
    @buff,
    SizeOf(buff)
  );
  timeStr := StrPas(@buff);

  GetDateFormat(
    LOCALE_USER_DEFAULT,
    0,
    @sysTime,
    nil,                                                                        //gp 1999-05-11
//  PChar('yyyy-MM-dd'),                                                        //gp 1999-05-11
    @buff,
    SizeOf(buff)
  );
  dateStr := StrPas(@buff);
  {end}                                                                         //hdl 1999-05-11
*)
{end}                                                                           //mh 1999-09-12  

  if PrintFont = NIL then
    Printer.Canvas.Font := Font
  else
    Printer.Canvas.Font := PrintFont;

  Printer.Copies := Options.Copies;
  Printer.Title := Options.Title;
  Printer.BeginDoc;
  try
    Abort := FALSE;
    PrintStatus(psBegin, 0, Abort);
    if Abort then
    begin
      Printer.Abort;
      exit;
    end;

    if Options.SelectedOnly then
    begin
{$IFDEF MWE_SELECTION_MODE}
      if SelectionMode = smLine then
        PrintArea := Rect(0, BlockBegin.Y, 0, BlockEnd.Y)
      else
{$ENDIF}
        PrintArea := Rect(BlockBegin.X, BlockBegin.Y, BlockEnd.X-1, BlockEnd.Y);
    end else if not IsRectEmpty(Options.PrintRange) then
      PrintArea := Options.PrintRange
    else
      // Paint all the text
      PrintArea := Rect(0, 1, 0, Lines.Count);

    Abort := not PaintLines(Options.Highlighted,
       MarginsInPixels(Options.MarginUnits, Options.Margins), PrintArea.Top,
       PrintArea.Bottom, PrintArea.Left, PrintArea.Right,
{$IFDEF MWE_SELECTION_MODE}
       Options.SelectedOnly and (SelectionMode = smColumn));
{$ELSE}
       FALSE);
{$ENDIF}

  finally
    if not Abort then
      Printer.EndDoc;
    PrintStatus(psEnd, 0, Abort);
    // We're done, we don't care about abort at this point.
  end;
end;

procedure TmwCustomEdit.PrintStatus(Status: TmwPrintStatus; PageNumber: integer;
   var Abort: boolean);
begin
  if Assigned(FOnPrintStatus) then
    FOnPrintStatus(Self, Status, PageNumber, Abort);
end;
{end}                                                                           //bds 1/24/1999


{ TUndoList }
{begin}                                                                         //tskurz 12/10/1998
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
procedure TUndoList.AddChange(ChangeReason: TChangeReason; ChangeStartPos,
         ChangeEndPos: TPoint; ChangeStr: PChar; ChangeSelMode: TSelectionMode);
{$ELSE}                                                                         //bds 1/25/1999
procedure TUndoList.AddChange(ChangeReason: TChangeReason; ChangeStartPos,
              ChangeEndPos: TPoint; ChangeStr: PChar);
{$ENDIF}                                                                        //bds 1/25/1999
var
  chngptr : TChangePtr;
begin
   if fUndoLocked then Exit;                                                    //tskurz 06/11/1999
   if FList.Count >= FMaxUndo then RemoveChange(0);
   try
      GetMem(chngptr,SizeOf(TChange));
      try
        chngptr^.ChangeStr := StrNew(ChangeStr);
      except
        FreeMem(chngptr);
        exit;
      end;
   except
     exit;
   end;
   chngptr^.ChangeReason := ChangeReason;
{begin}                                                                         //th 1999-09-22
   {begin}                                                                      //tskurz 12/14/1998
   chngptr^.ChangeStartPos := ChangeStartPos;
   chngptr^.ChangeEndPos := ChangeEndPos;
   //chngptr^.ChangeStartPos := minPoint(ChangeStartPos,ChangeEndPos);
   //chngptr^.ChangeEndPos := maxPoint(ChangeStartPos,ChangeEndPos);
{end}                                                                           //th 1999-09-22
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
   chngptr^.ChangeSelMode := ChangeSelMode;
{$ENDIF}                                                                        //bds 1/25/1999
   {end}                                                                        //tskurz 12/14/1998
   FList.Add(chngptr);
   fOwner.Modified := true;                                                     //CdeB 12/16/1998
   if Assigned(FOwner.OnChange) then FOwner.OnChange(FOwner);                   //tskurz 12/15/1998
end;

constructor TUndoList.Create(AOwner: TmwCustomEdit);                            //tskurz 12/15/1998
begin
   inherited Create;
   FOwner := AOwner;                                                            //tskurz 12/15/1998
   FList := TList.Create;
   FMaxUndo := 10;
   fUndoLocked := False;                                                        //tskurz 06/11/1999
end;

destructor TUndoList.Destroy;
//var                                                                           //mh 1999-08-22
//   i : Integer;
begin
// for i := 0 to FList.Count - 1 do                                             //tskurz 12/21/1998
//   for i := FList.Count - 1 downto 0 do                                         //tskurz 12/21/1998 //mh 1999-08-22
//     RemoveChange(i);
  ClearList;
  FList.Free;
  inherited Destroy;
end;

{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
function TUndoList.GetChange(var ChangeStartPos, ChangeEndPos: TPoint;
        var ChangeStr: PChar; var ChangeSelMode: TSelectionMode): TChangeReason;
{$ELSE}                                                                         //bds 1/25/1999
function TUndoList.GetChange(var ChangeStartPos, ChangeEndPos: TPoint;
  var ChangeStr: PChar): TChangeReason;
{$ENDIF}                                                                        //bds 1/25/1999
begin
   if FList.Count = 0 then
   begin
     result := mwcrNone;
     exit;
   end;
   ChangeStartPos := TChangePtr(FList.Items[FList.Count-1])^.ChangeStartPos;
   ChangeEndPos := TChangePtr(FList.Items[FList.Count-1])^.ChangeEndPos;
   ChangeStr := StrNew(TChangePtr(FList.Items[FList.Count-1])^.ChangeStr);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
   ChangeSelMode := TChangePtr(FList.Items[FList.Count-1])^.ChangeSelMode;
{$ENDIF}                                                                        //bds 1/25/1999
   result := TChangePtr(FList.Items[FList.Count-1])^.ChangeReason;
   RemoveChange(FList.Count-1);
end;

//DELETE FROM HERE
{$IFDEF UNDO_DEBUG}                                                             //tskurz 06/11/1999
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
function TUndoList.GetChange2(var ChangeStartPos, ChangeEndPos: TPoint;
        var ChangeStr: PChar; var ChangeSelMode: TSelectionMode; i:Integer): TChangeReason;
{$ELSE}                                                                         //bds 1/25/1999
function TUndoList.GetChange2(var ChangeStartPos, ChangeEndPos: TPoint;
  var ChangeStr: PChar; i:Integer): TChangeReason;
{$ENDIF}                                                                        //bds 1/25/1999
begin
   if FList.Count = 0 then
   begin
     result := mwcrNone;
     exit;
   end;
   ChangeStartPos := TChangePtr(FList.Items[i])^.ChangeStartPos;
   ChangeEndPos := TChangePtr(FList.Items[i])^.ChangeEndPos;
   ChangeStr := StrNew(TChangePtr(FList.Items[i])^.ChangeStr);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
   ChangeSelMode := TChangePtr(FList.Items[i])^.ChangeSelMode;
{$ENDIF}                                                                        //bds 1/25/1999
   result := TChangePtr(FList.Items[i])^.ChangeReason;
   //RemoveChange(FList.Count-1);
end;
{$ENDIF}                                                                        //tskurz 06/11/1999
//DELETE TO HERE

function TUndoList.GetCanUndo : Integer;
begin
  FCanUndo := FList.Count;
  result := FCanUndo;
end;

procedure TUndoList.SetMaxUndo(const Value: Integer);
var
  i : Integer;
begin
  if Value < FList.Count - 1 then
     for i := 0 to FList.Count - Value - 1 do
        RemoveChange(0);
  FMaxUndo := Value;
end;

procedure TUndoList.RemoveChange(index: Integer);
var
  chngptr : TChangePtr;
begin
  if (index > -1) and (index < FList.Count) then
  begin
    chngptr := FList.Items[Index];
    try
      StrDispose(chngptr^.ChangeStr);
      try
        FreeMem(chngptr);
      except
        exit;
      end;
    except
      exit;
    end;
    Flist.Delete(index);
  end;
end;

function TUndoList.GetChangeReason: TChangeReason;                              //tskurz 12/16/1998
begin
   if FList.Count = 0 then
     result := mwcrNone
   else
     result := TChangePtr(FList.Items[FList.Count-1])^.ChangeReason;
end;

procedure TUndoList.ClearList;
var
  i: Integer;
begin
  for i := FList.Count - 1 downto 0 do                                          //tskurz 1/4/1999
    RemoveChange(i);
end;

procedure TUndoList.LockUndo;                                                   //tskurz 06/11/1999
begin
   fUndoLocked := True;
end;

procedure TUndoList.UnLockUndo;                                                 //tskurz 06/11/1999
begin
   fUndoLocked := False;
end;

{ TmwCustomEdit }

{begin}                                                                         //CdeB 12/16/1998
procedure TmwCustomEdit.SetBookmarkImages(const Value: TImageList);             //gp 1/2/1999 - renamed
begin
  if fBookmarkImages <> Value then                                              //mh 1999-05-12
  begin
    fBookmarkImages := Value;
    if fBookmarkImages <> nil then
      fBookmarkImages.FreeNotification(Self);
//  Invalidate;                                                                   //gp 1/2/1999
    InvalidateGutter(-1, -1);
  end;
end;

{ Called by FMarkList if change }
procedure TmwCustomEdit.MarkListChange(Sender: TObject);
begin
  InvalidateGutter(-1, -1);                                                     //mh 1999-05-12
end;
{end}                                                                           //CdeB 12/16/1998

{begin}                                                                         //mh 1999-09-12
(*
procedure TmwCustomEdit.SetLinesInWindow(const Value: integer);                 //gp 1/10/1999
begin
  fLinesInWindow := Value;
  ReallocMem(fGutterOffsets,fLinesInWindow*SizeOf(integer));
end;
*)
{end}                                                                           //mh 1999-09-12

{begin}                                                                         //tb 1/7/1999
function TmwCustomEdit.GetSelStart: integer;
  function llen(data: string): integer;
  begin
    result:=length(Data)+2;
  end;
var
  loop: integer;
  x, y: integer;
begin
  //x:=Caretx;                                                                  //tb 1/7/1999
  //y:=CaretY;                                                                  //tb 1/7/1999
  x := BlockBegin.X;                                                            //tb 1/7/1999
  y := BlockBegin.Y;                                                            //tb 1/7/1999

  result:=0;
  loop:=0;
  while loop<(Y-1)do begin
    Result:=result+llen(lines.strings[loop]);
    inc(loop);
  end;

  result:=result+Min(X, llen(lines.strings[loop]));
end;

procedure TmwCustomEdit.SetSelStart(const Value: integer);
  function llen(data: string): integer;
  begin
    result:=length(Data)+2;
  end;
var
  loop: integer;
  count: integer;
begin
  loop:=0;
  count:=0;
  while(count+llen(lines.strings[loop])<value)do begin
    count:=count+llen(lines.strings[loop]);
    inc(loop);
  end;
  CaretX:=value-count;
  CaretY:=loop+1;

  fBlockBegin.X := CaretX;                                                      //tdb 1999-05-10
  fBlockBegin.Y := CaretY;                                                      //tdb 1999-05-10
end;

function TmwCustomEdit.GetSelEnd: integer;
  function llen(data: string): integer;
  begin
    result:=length(Data)+2;
  end;
var
  loop: integer;
  x, y: integer;
begin
  x:=BlockEnd.x;
  y:=BlockEnd.y;

  result:=0;
  loop:=0;
  while loop<(y-1)do begin
    Result:=result+llen(lines.strings[loop]);
    inc(loop);
  end;
  result:=result+x;
end;

procedure TmwCustomEdit.SetSelEnd(const Value: integer);
  function llen(data: string): integer;
  begin
    result:=length(Data)+2;
  end;
var
  p: tpoint;
  loop: integer;
  count: integer;
begin
  loop:=0;
  count:=0;
  while(count+llen(lines.strings[loop])<value)do begin
    count:=count+llen(lines.strings[loop]);
    inc(loop);
  end;
  p.X:=value-count; p.y:=loop+1;
  Blockend:=p;
end;
{end}                                                                           //tb 1/7/1999

procedure TmwCustomEdit.SetExtraLineSpacing(const Value: integer);
begin
  fExtraLineSpacing := Value;
  FontChanged(self);
end;

{begin}                                                                         //gp 1/10/1999
function TmwCustomEdit.GetBookMark(BookMark: integer; var X, Y: integer): boolean;
var
  i: integer;
begin
  Result := false;
  if assigned(Marks) then
    for i := 0 to Marks.Count-1 do
      if Marks[i].IsBookmark and (Marks[i].BookmarkNumber = BookMark) then begin
        X := Marks[i].Column;
        Y := Marks[i].Line;
        Result := true;
        Exit;
      end;
end;

function TmwCustomEdit.IsBookmark(BookMark: integer): boolean;
var
  x,y: integer;
begin
  Result := GetBookMark(BookMark,x,y);
end; 
{end}                                                                           //gp 1/10/1999

procedure TmwCustomEdit.ClearUndo;
begin
  fUndoList.ClearList;
  fRedoList.ClearList;
end;

procedure TmwCustomEdit.SetSelTextExternal(const Value: String);                //tskurz 1/7/1999
var
   StartOfBlock: TPoint;
begin
  if SelAvail then
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
    FUndoList.AddChange(mwcrDelete, fBlockBegin, fBlockEnd, PChar(GetSelText),  //tskurz 06/11/1999
       SelectionMode);
{$ELSE}                                                                         //bds 1/25/1999
    FUndoList.AddChange(mwcrDelete,fBlockBegin,fBlockEnd,PChar(GetSelText));
{$ENDIF}                                                                        //bds 1/25/1999
  StartOfBlock := fBlockBegin;
  SetSelText(Value);
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1/25/1999
  FUndoList.AddChange(mwcrInsert, StartOfBlock, fBlockBegin, PChar(Value),
       SelectionMode);
{$ELSE}                                                                         //bds 1/25/1999
  FUndoList.AddChange(mwcrInsert,StartOfBlock,fBlockBegin,PChar(Value));
{$ENDIF}                                                                        //bds 1/25/1999
end;

procedure TmwCustomEdit.RefreshAllTokens;                                       //aj 1999-02-22
var
  I: Integer;
begin
{begin}                                                                         //mh 1999-08-21
(*
  for I:= 0 to Lines.Count - 1 do
    begin
      fHighLighter.SetLine(Lines[I], I);
      while not fHighLighter.GetEol do
        fHighLighter.Next;
    end;
*)
  if Assigned(fHighlighter) then
    if Assigned(fHighlighter.OnToken) then
      for i := 0 to Pred(Lines.Count) do
        fHighlighter.ScanAllLineTokens(Lines[i], i);
{end}                                                                           //mh 1999-08-21
end;

{begin}                                                                         //mh 1999-05-12
procedure TmwCustomEdit.SetGutter(const Value: TmwGutter);
begin
  fGutter.Assign(Value);
end;

procedure TmwCustomEdit.GutterChanged(Sender: TObject);                         //mh 1999-09-12
var nW: integer;
begin
  nW := fGutter.RealGutterWidth(fCharWidth);
  if nW = fGutterWidth then InvalidateGutter(-1, -1)
                       else SetGutterWidth(nW);
end;

procedure TmwCustomEdit.LockUndo;                                               //tskurz 06/11/1999
begin
   FUndoList.LockUndo;
   FRedoList.LockUndo;
end;

procedure TmwCustomEdit.UnLockUndo;                                             //tskurz 06/11/1999
begin
   FUndoList.UnLockUndo;
   FRedoList.UnLockUndo;
end;

{begin}                                                                         //woza 05/07/1999
procedure TmwCustomEdit.WMMouseWheel(var Msg: TMessage);
{begin}                                                                         //mh 1999-05-12
var nDelta: integer;
    nWheelClicks: integer;                                                      //ajb 1999-06-13
//  ScrollMsg: TMessage;
//  i: Byte;
{$IFNDEF MWE_COMPILER_4_UP}
const
  LinesToScroll = 3;
  WHEEL_DELTA = 120;                                                            //ajb 1999-06-13
  WHEEL_PAGESCROLL = MAXDWORD;                                                  //ajb 1999-06-13
{$ENDIF}
begin
// this might break in future versions when new styles are added
//  if ComponentState = [csDesigning] then Exit;
  if csDesigning in ComponentState then exit;

{$IFDEF MWE_COMPILER_4_UP}
  if GetKeyState(VK_CONTROL) >= 0 then nDelta := Mouse.WheelScrollLines
{$ELSE}
  if GetKeyState(VK_CONTROL) >= 0 then nDelta := LinesToScroll
{$ENDIF}
    else if HalfpageScroll then nDelta := LinesInWindow div 2
                           else nDelta := LinesInWindow;
{begin}                                                                         //ajb 1999-06-13
(*
  if ShortInt(Msg.WParamHi) = 120 then TopLine := TopLine - nDelta
                                  else TopLine := TopLine + nDelta;
*)
  Inc(fMouseWheelAccumulator, SmallInt(Msg.wParamHi));
  nWheelClicks := fMouseWheelAccumulator div WHEEL_DELTA;
  fMouseWheelAccumulator := fMouseWheelAccumulator mod WHEEL_DELTA;
  if (nDelta = integer(WHEEL_PAGESCROLL)) or (nDelta > LinesInWindow) then
    nDelta := LinesInWindow;
  TopLine := TopLine - (nDelta * nWheelClicks);
{end}                                                                           //ajb 1999-06-13
  Update;                                                                       //th 1999-09-15
(*
    ScrollMsg.WParamLo := SB_LINEUP
  else
  if ShortInt(Msg.WParamHi) = -120 then
    ScrollMsg.WParamLo := SB_LINEDOWN;

  for i := 0 to LinesToScroll-1 do
  begin
    ScrollMsg.Msg := WM_VSCROLL;
    Self.Dispatch(ScrollMsg);
  end;
*)
{end}                                                                           //mh 1999-05-12
end;
{end}                                                                           //woza 05/07/1999

{begin}                                                                         //ar 1999-05-10
procedure TmwCustomEdit.SetWantTabs(const Value: boolean);
begin
//  if fWantTabs <> Value then                                                  //mh 1999-05-12
  fWantTabs := Value;
end;

procedure TmwCustomEdit.SetTabIndent(const Value: integer);
begin
{begin}                                                                         //sva 1999-09-11
  if (Value >= 0) and (Value <= 16) then fTabIndent := Value;
(*
  {Limits}
  if (Value < 1) or (Value > 16) then exit;
  if Value <> fTabIndent then
    fTabIndent := Value;
*)
{end}                                                                           //sva 1999-09-11
end;
{end}                                                                           //ar 1999-05-10

{begin}                                                                         //WvdM 1999-05-10
procedure TmwCustomEdit.SelectionChange;
begin
  if assigned(fSelectionChange) then
    fSelectionChange(Self);
end;
{end}                                                                           //WvdM 1999-05-10

{begin}                                                                         //ajb 1999-06-16
function GetExporter(ExportFormat : TmwEditExporter) : TmwCustomExport;
begin
  case ExportFormat of
    cfRTF  : result := TmwRTFExport.Create(nil);
    cfHTML : result := TmwHtmlExport.Create(nil);
  else
    result := nil;
  end;
end;

// Adds data from a stream to the clipboard in specified format.
procedure TmwCustomEdit.SaveStreamToClipboardFormat(const ClipboardFormat : Word; Stream: TStream);
var
  Data: THandle;
  DataPtr: Pointer;
  Size: Integer;
begin
  Stream.Position := 0;
  Size := Stream.Size;

  Data := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, Size);
  try
    DataPtr := GlobalLock(Data);
    try
      Stream.ReadBuffer(DataPtr^, Size);
      Clipboard.SetAsHandle(ClipboardFormat, Data);
    finally
      GlobalUnlock(Data);
    end;
  except
    on E: Exception do
    begin
      GlobalFree(Data);
    end;
  end;
end;

procedure TmwCustomEdit.SaveToFile(const FileName : string);
begin
  Lines.SaveToFile(FileName);
end;

procedure TmwCustomEdit.ExportToFile(const FileName : string; Format : TmwEditExporter);
begin
  with GetExporter(Format) do
  begin
    RunExport(0, Lines.Count - 1, Self ,Highlighter);
    SaveToFile(FileName);
    Free;
  end;
end;

procedure TmwCustomEdit.CopyToClipboardEx;
begin
  if not(SelAvail) then
    Exit;
  Clipboard.Open;
  try
    Clipboard.Clear;
//  if cfText in ClipboardFormats then
      ClipBoard.SetTextBuf(PChar(SelText));
    if cfHTML in ClipBoardFormats then
    with GetExporter(cfHTML) do
    begin
      CopyToClipboard(Self, HighLighter);
      Free;
    end;
    if cfRTF in ClipBoardFormats then
    with GetExporter(cfRTF) do
    begin
      CopyToClipboard(Self, HighLighter);
      Free;
    end;
  finally
    Clipboard.Close;
  end;
end;


// Save in a specified to the clipboard as text
procedure TmwCustomEdit.ExportToClipboard(Format : TmwEditExporter);
begin
  with GetExporter(Format) do
  try
    Clipboard.Open;
    try
      Clipboard.Clear;
      CopyToClipboardFormat(Self, HighLighter, CF_TEXT);
    finally
      Clipboard.Close;
    end;
  finally
    Free;
  end;
end;
{end}                                                                           //ajb 1999-06-16

procedure TmwCustomEdit.SelectedColorsChanged(Sender: TObject);                 //mh 1999-09-12
begin
  Invalidate;
end;

// find / replace
function TmwCustomEdit.SearchReplace(const ASearch, AReplace: string;
                                     AOptions: TmwSearchOptions): integer;
var ptStart, ptEnd: TPoint;    // start and end of the search range
    ptCurrent: TPoint;         // current search position
    nSearchLen, nReplaceLen, n, nFound: integer;
    nInLine: integer;
    bBackward, bFromCursor: boolean;
    bReplace, bReplaceAll: boolean;
    nAction: TmwReplaceAction;

  function InValidSearchRange(First, Last: integer): boolean;
  begin
    Result := TRUE;
{$IFDEF MWE_SELECTION_MODE}
    if (fSelectionMode = smNormal) then begin
{$ENDIF}
      if ((ptCurrent.Y = ptStart.Y) and (First < ptStart.X)) or
         ((ptCurrent.Y = ptEnd.Y) and (Last > ptEnd.X)) then Result := FALSE;
{$IFDEF MWE_SELECTION_MODE}
    end else if (fSelectionMode = smColumn) then
      Result := (First >= ptStart.X) and (Last <= ptEnd.X);
{$ENDIF}
  end;

begin
  Result := 0;
  // can't search for or replace an empty string
  if Length(ASearch) = 0 then exit;
  // get the text range to search in, ignore the "Search in selection only"
  // option if nothing is selected
  bBackward := (mwsoBackwards in AOptions);
  bReplace := (mwsoReplace in AOptions);
  bReplaceAll := (mwsoReplaceAll in AOptions);
  bFromCursor := not (mwsoEntireScope in AOptions);
  if not SelAvail then Exclude(AOptions, mwsoSelectedOnly);
  if (mwsoSelectedOnly in AOptions) then begin
    ptStart := BlockBegin;
    ptEnd := BlockEnd;
{$IFDEF MWE_SELECTION_MODE}
    // search the whole line in the line selection mode
    if (fSelectionMode = smLine) then begin
      ptStart.X := 1;
      ptEnd.X := Length(Lines[ptEnd.Y - 1]) + 1;
    end else if (fSelectionMode = smColumn) then
      // make sure the start column is smaller than the end column
      if (ptStart.X > ptEnd.X) then begin
        nFound := ptStart.X;
        ptStart.X := ptEnd.X;
        ptEnd.X := nFound;
      end;
{$ENDIF}
    // ignore the cursor position when searching in the selection
    if bBackward then ptCurrent := ptEnd else ptCurrent := ptStart;
  end else begin
    ptStart := Point(1, 1);
    ptEnd.Y := Lines.Count;
    ptEnd.X := Length(Lines[ptEnd.Y - 1]) + 1;
    if bFromCursor then
      if bBackward then ptEnd := CaretXY else ptStart := CaretXY;
    if bBackward then ptCurrent := ptEnd else ptCurrent := ptStart;
  end;
  // initialize the search engine
  fTSearch.Pattern := ASearch;
  fTSearch.Sensitive := mwsoMatchCase in AOptions;
  fTSearch.Whole := mwsoWholeWord in AOptions;
  // search while the current search position is inside of the search range
  nSearchLen := Length(ASearch);
  nReplaceLen := Length(AReplace);
  if bReplaceAll then IncPaintLock;
  try
    while (ptCurrent.Y >= ptStart.Y) and (ptCurrent.Y <= ptEnd.Y) do begin
      nInLine := fTSearch.FindAll(Lines[ptCurrent.Y - 1]);
      if bBackward then n := Pred(fTSearch.ResultCount) else n := 0;
      // Operate on all results in this line.
      while nInLine > 0 do begin
        nFound := fTSearch.Results[n];
        if bBackward then Dec(n) else Inc(n);
        Dec(nInLine);
        // Is the search result entirely in the search range?
        if not InValidSearchRange(nFound, nFound + nSearchLen) then continue;
        Inc(Result);
        // Select the text, so the user can see it in the OnReplaceText event
        // handler or as the search result.
        ptCurrent.X := nFound;
        BlockBegin := ptCurrent;
        if bBackward then CaretXY := ptCurrent;
        Inc(ptCurrent.X, nSearchLen);
        BlockEnd := ptCurrent;
        if not bBackward then CaretXY := ptCurrent;
        // If it's a search only we can leave the procedure now.
        if not (bReplace or bReplaceAll) then exit;
        // If the event handler is not set we just replace the first occurance
        // and exit.
        if not Assigned(fOnReplaceText) then begin
          SetSelTextExternal(AReplace);
          // fix the caret position
          if not bBackward then CaretX := nFound + nReplaceLen;
          exit;
        end;
        // If the Replace All option is not set we ask the user.
        if not bReplaceAll then begin
          nAction := mwraCancel;
          fOnReplaceText(ASearch, AReplace, ptCurrent.Y, nFound, nAction);
          if nAction = mwraCancel then exit;
          if nAction in [mwraReplace, mwraReplaceAll] then begin
            if nAction = mwraReplaceAll then begin
              bReplaceAll := TRUE;
              IncPaintLock;
            end;
            SetSelTextExternal(AReplace);
            // fix the caret position and the remaining results
            if not bBackward then begin
              CaretX := nFound + nReplaceLen;
              fTSearch.FixResults(nFound, nSearchLen - nReplaceLen);
            end;
          end;
        end;
      end;
      // search next / previous line
      if bBackward then Dec(ptCurrent.Y) else Inc(ptCurrent.Y);
    end;
  finally
    if bReplaceAll then DecPaintLock;
  end;
end;

{begin}                                                                         //th 1999-09-21
{$IFDEF MWE_SELECTION_MODE}
{$IFDEF MWE_MBCSSUPPORT}
procedure TmwCustomEdit.MBCSGetSelRangeInLineWhenColumnSelectionMode(
  const s: string; var ColFrom, ColTo: Integer);

  // --ColFrom and ColTo are in/out parameter. their range
  //    will be from 1 to MaxInt.
  // --a range of selection means:  Copy(s, ColFrom, ColTo - ColFrom);
  //    be careful what ColTo means.

var
  Len: Integer;
begin
  Len := Length(s);
  if (0 < ColFrom) and (ColFrom <= Len) then
    if mbTrailByte = ByteType(s, ColFrom) then
      Inc(ColFrom);
  if (0 < ColTo) and (ColTo <= Len) then
    if mbTrailByte = ByteType(s, ColTo) then
      Inc(ColTo);
end;

{$ENDIF}
{$ENDIF}
{end}                                                                           //th 1999-09-21

{ TMark }

function TMark.GetEdit: TmwCustomEdit;
begin
  if FEdit<>nil then
    try
      if FEdit.Marks.IndexOf(self)=-1 then
        FEdit:= nil;
    except
      FEdit:= nil;
    end;
  Result := FEdit;
end;

function TMark.GetIsBookmark: boolean;
begin
  Result := (fBookmarkNum >= 0);
end;

procedure TMark.SetIsBookmark(const Value: boolean);
begin
  if Value then fBookmarkNum := 0
           else fBookmarkNum := -1;
end;

procedure TMark.SetColumn(const Value: Integer);
begin
  FColumn:= Value;
end;

procedure TMark.SetImage(const Value: Integer);
begin
  FImage:= Value;
//  if assigned(fEdit) then fEdit.Invalidate;                                     //gp 1/2/1999 //mh 1999-05-12
  if fVisible and Assigned(fEdit) then fEdit.InvalidateGutter(fLine, fLine);
end;

procedure TMark.SetInternalImage(const Value: boolean);                         //gp 1/2/1999
begin
  fInternalImage := Value;
//  if assigned(fEdit) then fEdit.Invalidate;                                   //mh 1999-05-12
  if fVisible and Assigned(fEdit) then fEdit.InvalidateGutter(fLine, fLine);
end;

procedure TMark.SetLine(const Value: Integer);
begin
{begin}                                                                         //mh 1999-05-12
//  fLine:= Value;
//  if assigned(fEdit) then fEdit.Invalidate;                                   //gp 1/2/1999
  if fVisible and Assigned(fEdit) then
  begin
    if fLine > 0 then fEdit.InvalidateGutter(fLine, fLine);
    fLine:= Value;
    fEdit.InvalidateGutter(fLine, fLine);
  end else
    fLine := Value;
{end}                                                                           //mh 1999-05-12
end;

procedure TMark.SetVisible(const Value: boolean);                               //gp 1/2/1999
begin
{begin}                                                                         //mh 1999-05-12
//  fVisible := Value;
//  if assigned(fEdit) then fEdit.Invalidate;
  if fVisible <> Value then
  begin
    fVisible := Value;
    if Assigned(fEdit) then fEdit.InvalidateGutter(fLine, fLine);
  end;
end;

constructor TMark.Create(owner: TmwCustomEdit);                                 //gp 1/9/1999
begin
  inherited Create;
  fEdit := owner;
end;

{ TMarkList }

function TMarkList.Add(Item: TMark): Integer;
begin
  Result:= Inherited Add(Item);
  DoChange;
end;

procedure TMarkList.ClearLine(Line: integer);                                   //gp 1/9/1999
var
  i: integer;
begin
{begin}                                                                         //mh 1999-05-12
//  i := 0;
//  while (i < Count) do begin
//    if (not Items[i].IsBookmark) and (Items[i].Line = line)
//      then Delete(i)
//      else Inc(i);
//  end;
  for i:= Count - 1 downto 0 do
    if not Items[i].IsBookmark and (Items[i].Line = Line) then Delete(i);
{end}                                                                           //mh 1999-05-12
end;

constructor TMarkList.Create(owner: TmwCustomEdit);                             //gp 1/9/1999
begin
  inherited Create;
  fEdit := owner;
end;

procedure TMarkList.Delete(Index: Integer);
begin
  inherited Delete(Index);
  DoChange;
end;

procedure TMarkList.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TMarkList.First: TMark;
begin
  result:= inherited First;
end;

function TMarkList.Get(Index: Integer): TMark;
begin
  result:= inherited Get(Index);
end;

//Returns up to maxMarks book/gutter marks for a chosen line.
procedure TMarkList.GetMarksForLine(line: integer; var marks: TMarks);
var
  cnt: integer;
  i  : integer;
begin
  FillChar(marks,SizeOf(marks),0);
  cnt := 0;
  for i := 0 to Count-1 do begin
    if Items[i].Line = line then begin
      Inc(cnt);
      marks[cnt] := Items[i];
      if cnt = maxMarks then break;
    end;
  end;
end;

procedure TMarkList.Insert(Index: Integer; Item: TMark);
begin
  Inherited Insert(Index, Item);
  DoChange;
end;

function TMarkList.Last: TMark;
begin
  result:= Inherited Last;
end;

procedure TMarkList.Place(mark: TMark);
begin
  if assigned(fEdit) then
    if assigned(fEdit.OnPlaceBookmark) then fEdit.OnPlaceBookmark(mark);        //gp 1/9/1999
  if assigned(mark) then                                                        //gp 1/9/1999
    Add(mark);
  DoChange;
end;

procedure TMarkList.Put(Index: Integer; Item: TMark);
begin
  Inherited Put(Index, Item);
  DoChange;
end;

function TMarkList.Remove(Item: TMark): Integer;
begin
  result:= Inherited Remove(Item);
  DoChange;
end;

{$IFDEF MWE_SELECTION_MODE}
initialization                                                                  //bds 1/25/1999
  mwEditClipboardFormat := RegisterClipboardFormat(MWEDIT_CLIPBOARD_FORMAT);    //bds 1/25/1999
{$ENDIF}
end.

