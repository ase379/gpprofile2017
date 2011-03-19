/*-----------------------------------------------------------------------------*
 | Code:        main.cpp
 | Created:     1999-9-5
 | Author:      Jeff Corbets
 | Description: A simple Pascal code explorer example for C++Builder
 | Version:     0.1
 |
 | The same conditions that govern mwEdit in general also cover this code.
 | However, I do ask that you send any changes you make to me at my e-mail
 | address shown below.
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
 |  Jeff Corbets
 |  jeff@ccsdesign.com
 |
 */


//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "main.h"
#include <vcl/dstring.h>
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "mwCustomEdit"
#pragma link "mwHighlighter"
#pragma link "mwPasSyn"
#pragma resource "*.dfm"
TForm1 *Form1;
enum TParseState {psIdle, psInClassDef, psProcSeen, psWaitForSymbol};
TParseState ParseState;
String ProcedureName;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//-------------------------------------------------------------------------
void __fastcall TForm1::mwPasSyn1Token(TObject *Sender, int TokenKind,
      AnsiString TokenText, int LineNo)
{
int CurrentItem = 0;
bool ItemInserted;
//TtkTokenKind TokenKind = _TokenKind;

  if ((TokenKind == 3) && (TokenText.UpperCase() == "CLASS"))
      ParseState = psInClassDef;

  if ((TokenKind == 3) && (TokenText.UpperCase() == "END") && (ParseState == psInClassDef))
      ParseState = psIdle;

  if (ParseState != psInClassDef)
  {
      if ((ParseState == psIdle) && (TokenKind == 3) && ((TokenText.UpperCase() == "PROCEDURE") || (TokenText.UpperCase() == "FUNCTION")))
        ParseState = psProcSeen;

      if ((ParseState == psProcSeen) && (TokenKind == 2))
      {
          ProcedureName = TokenText;
          ParseState = psWaitForSymbol;
      }

      if ((ParseState == psWaitForSymbol) && (TokenKind == 8) && (TokenText == "."))
        ParseState = psProcSeen;

      if ((ParseState == psWaitForSymbol) && (TokenKind == 8) && (TokenText != "."))
      {
          ItemInserted = false;
          for (CurrentItem = 0; CurrentItem <= (ListBox1->Items->Count - 1); CurrentItem++)
          {
          if (int(ListBox1->Items->Objects[CurrentItem]) == LineNo)
          {
              ListBox1->Items->Delete(CurrentItem);
              ListBox1->Items->InsertObject(CurrentItem, ProcedureName, (TObject*)LineNo);
              ItemInserted = true;
          }
          }
          if (!ItemInserted)
          {
             ListBox1->Items->AddObject(ProcedureName, (TObject*)LineNo);
          }
         ParseState = psIdle;
// if (ParseState == psFuncNameExpected) && (TokenKind == tkIdentifier)
//    {
//    }
//  if ((ParseState == psLookForSymbol) && (TokenKind == tkSymbol) && (TokenText == "."))
//    {
//     ParseState = psFuncNameExpected;
//    }
  }
}
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ListBox1DblClick(TObject *Sender)
{
  Form1->mwCustomEdit1->CaretY = int(Form1->ListBox1->Items->Objects[Form1->ListBox1->ItemIndex]) + 1;
  Form1->mwCustomEdit1->SetFocus();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::OpenClick(TObject *Sender)
{
  if (OpenDialog1->Execute())
  {
      mwCustomEdit1->Lines->LoadFromFile(OpenDialog1->FileName);
      mwCustomEdit1->RefreshAllTokens();
  }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
   ParseState = psIdle;
}
//---------------------------------------------------------------------------













