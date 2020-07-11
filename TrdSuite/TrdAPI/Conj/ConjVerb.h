// ConjVerb.h : main header file for the CONJVERB DLL
//
#ifndef __CONJVERB__
#define __CONJVERB__

#include <stdlib.h>
#include "ApiConj.h"
#include "cvdefn.h"

//---------------------------------------------------------------------------
// CConjVerb
//---------------------------------------------------------------------------

class CConjVerb
{
public:
	CStringF m_DataPath;        // Caminos a los diccionarios y tablas
  CDicRef* m_Dicts;           // Diccionarios a utilizar en la conjugación
  int      m_Lang;            // Direccion de de traducción actual
  CString  m_Ret;
  
//---------------------------------------------------------------------------
// Constructor de la clase
//---------------------------------------------------------------------------
CConjVerb()	
  {  
  m_Dicts = NULL;  
  m_Lang  = -1;  
  }
~CConjVerb()
  {	
  if( m_Dicts != NULL )
  	{
    m_Dicts->Close();
    delete m_Dicts;
  	}
  }

void   SetDataPath( const CStringF& dataPath )
  {
  m_DataPath = dataPath;
  }
CStringF GetDataPath()       {return m_DataPath;}
bool   Open( LPCSTR sLang ){return Open( atoi(sLang) );}

//--------------------------------------------------------------------------------------------------------------
bool Open( int Lang );
bool Close();
int  Count();
CDataConj* DataConj(int idx);
CStringA Name(int idx);
int   Mood(int idx);
int   Time(int idx);
bool   Compound(int idx);
CStringA ReflexivePronoun( Persona persona, Numero numero );
bool   ReflexiveVerb( const CStringA& RefVerb, CStringA& RootVerb );
CStringA PersonalPronoun( Persona persona, Numero numero );
CStringA ConjugaVerb( const CStringA& verboi, Modo modo, Tiempo tiempo, Persona persona, Numero numero, bool negado, bool compuesto);
LPCSTR AuxiliaryVerb( LPCSTR verbo);
CStringA DeclineNoun( const CStringA& noun, Genero gen, Numero num, Declination decl);
CStringA DeclineAdjective( const CStringA& adj, Genero gen, Numero num, Declination decl, ArticleType artic);
CStringA ConcordWords( const CStringA& noun, Genero genfuente, Numero numfuente, Genero gendestino, Numero numdestino, Grado adjgrado);
CStringA DeclineNounIndex( const CStringA& noun, Genero gen, Numero num, Declination decl, LPWORD decCount, WORD idx);
CStringA ConcordWordsIndex( const CStringA& noun, Genero genfuente, Numero numfuente, Genero gendestino, Numero numdestino, Grado adjgrado, LPWORD decCount, WORD idx);
LPVOID GetPtrDicRef(DicName name);
bool   SetCelda( int fila, int col, LPCSTR s, TableName tbname );
bool   GetCelda( int fila, int col, LPSTR sval, TableName tbname);
bool   InsFila( int fila, LPCSTR namefila, TableName tbname);
bool   AddFila( LPCSTR namefila, TableName tbname);
bool   DelFila(int fila, TableName tbname);
bool   InsCol(int col, LPCSTR namecol, LPCSTR s, TableName tbname);
bool   AddCol(LPCSTR namecol, LPCSTR s, TableName tbname);
bool   DelCol(int col, TableName tbname);

private:
int      IndiceCnj( Modo modo, Tiempo tiempo, Persona persona, Numero numero);
CString  ConjVerbSimple(const CStringA& verboi,Modo modo, Tiempo tiempo, Persona persona, Numero numero, int *nfila, int *ncol);
bool     FindVerbPrefix(const CStringA& verbo, CString& verbprefix, CString& verbroot);
void     Prefijo_Conjugac( int fila,int col,bool negado, CString& prefijo, CString& sufijo, bool *verboinf );
CString  GetDeclElement(const CStringA& key, const CStringA& declList, Declination decl, int index = 0, LPWORD declCount = NULL );
CString  GetDeclArtType(const CString& declList, ArticleType artic);
int      GetDeclIndex(Genero gen, Numero num);
CString  GetIrregElement(const CString& key, LPCSTR elemList, int index = 0, LPWORD declCount = NULL);
};

#endif
