//---------------------------------------------------------------------------
#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "mwCustomEdit.hpp"
#include <Dialogs.hpp>
#include <ExtCtrls.hpp>
#include "DcjCppSyn.hpp"
#include "mwPasSyn.hpp"
#include "mwHighlighter.hpp"
#include "DcjPerlSyn.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
  TmwCustomEdit *mwCustomEdit1;
  TPanel *Panel1;
  TButton *cmdOpen;
  TButton *cmdUndo;
  TOpenDialog *dlgOpen;
  TComboBox *cboHighlight;
  TLabel *Label1;
  TComboBox *cboLanguage;
  TLabel *lblLanguage;
  TmwPasSyn *mwPasSyn1;
  TDcjCppSyn *DcjCppSyn1;
  TLabel *Label2;
  TDcjPerlSyn *DcjPerlSyn1;
  void __fastcall cmdUndoClick(TObject *Sender);
  void __fastcall cmdOpenClick(TObject *Sender);
  void __fastcall cboHighlightChange(TObject *Sender);
  void __fastcall cboLanguageChange(TObject *Sender);
  void __fastcall FormCreate(TObject *Sender);
  void __fastcall mwCustomEdit1Change(TObject *Sender);
  void __fastcall mwCustomEdit1KeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
  void __fastcall mwCustomEdit1Enter(TObject *Sender);
private:	// User declarations
public:		// User declarations
  __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
