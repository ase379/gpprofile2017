//---------------------------------------------------------------------------
#ifndef mainH
#define mainH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "mwCustomEdit.hpp"
#include "mwHighlighter.hpp"
#include "mwPasSyn.hpp"
#include <Buttons.hpp>
#include <Dialogs.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TmwCustomEdit *mwCustomEdit1;
    TListBox *ListBox1;
    TmwPasSyn *mwPasSyn1;
    TOpenDialog *OpenDialog1;
    TPanel *pnlTop;
    TBitBtn *Open;
    TLabel *lblCaption;
    void __fastcall ListBox1DblClick(TObject *Sender);
    void __fastcall mwPasSyn1Token(TObject *Sender, int TokenKind,
          AnsiString TokenText, int LineNo);
    void __fastcall OpenClick(TObject *Sender);
    void __fastcall FormCreate(TObject *Sender);
private:	// User declarations
public:		// User declarations
    __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
