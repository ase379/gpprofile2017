//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "mwCustomEdit"
#pragma link "DcjCppSyn"
#pragma link "mwPasSyn"
#pragma link "mwHighlighter"
#pragma link "DcjPerlSyn"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
  : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::cmdUndoClick(TObject *Sender)
{
  mwCustomEdit1->Undo();
  mwCustomEdit1->SetFocus();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::cmdOpenClick(TObject *Sender)
{
  // set the default extension according to the current language
  dlgOpen->FilterIndex = cboLanguage->ItemIndex + 1;
  if( dlgOpen->Execute() ) {
    AnsiString fName = dlgOpen->FileName;
    AnsiString ext = ExtractFileExt(fName).UpperCase();
    if( ext == ".PAS" || ext == ".INC" ) {
      if( cboLanguage->ItemIndex != 0 ) {
        cboLanguage->ItemIndex = 0;
        cboLanguageChange(Sender);
      }
    }
    else if( ext == ".C" || ext == ".CPP" || ext == ".H" || ext == ".HPP" ) {
      if( cboLanguage->ItemIndex != 1 ) {
        cboLanguage->ItemIndex = 1;
        cboLanguageChange(Sender);
      }
    }
    else if( ext == ".PL" || ext == ".PM" || ext == ".CGI" ) {
      if( cboLanguage->ItemIndex != 2 ) {
        cboLanguage->ItemIndex = 2;
        cboLanguageChange(Sender);
      }
    }
    // load the file, change the caption and set focus to the editor
    mwCustomEdit1->Lines->LoadFromFile(fName);
    Caption = fName;
    mwCustomEdit1->SetFocus();
  }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::cboHighlightChange(TObject *Sender)
{
  if( mwCustomEdit1->HighLighter->UseUserSettings(cboHighlight->ItemIndex) )
    Label2->Caption = "Success!";
  else
    Label2->Caption = "Failure!";

  Label2->Show();

  mwCustomEdit1->Invalidate();
  mwCustomEdit1->SetFocus();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::cboLanguageChange(TObject *Sender)
{
  // change the syntax highlighter
  switch( cboLanguage->ItemIndex ) {
    case 0:
      mwCustomEdit1->HighLighter = mwPasSyn1;
      break;
    case 1:
      mwCustomEdit1->HighLighter = DcjCppSyn1;
      break;
    default:
      mwCustomEdit1->HighLighter = DcjPerlSyn1;
  }

  // get the new highlight settings for the highlighter selected
  cboHighlight->Items->Clear();
  mwCustomEdit1->HighLighter->EnumUserSettings(cboHighlight->Items);
  cboHighlight->Enabled = cboHighlight->Items->Count;
  mwCustomEdit1->Invalidate();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  mwCustomEdit1->MaxUndo = 10;
  mwCustomEdit1->HighLighter->EnumUserSettings(cboHighlight->Items);
  cboHighlight->Enabled = (cboHighlight->Items->Count > 0);
  cboLanguage->ItemIndex = 0;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::mwCustomEdit1Change(TObject *Sender)
{
  cmdUndo->Enabled = mwCustomEdit1->CanUndo;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::mwCustomEdit1KeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
  cmdUndo->Enabled = mwCustomEdit1->CanUndo;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::mwCustomEdit1Enter(TObject *Sender)
{
  cmdUndo->Enabled = mwCustomEdit1->CanUndo;
}
//---------------------------------------------------------------------------
