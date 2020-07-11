

#include "ApiConj.h"
#include "ConjVerb.h"


//-----------------------------------------------------------------------------------------------------------------
// Crea un objeto de conjugación y retorna un handle para usar con las diferentes funciones del API
//-----------------------------------------------------------------------------------------------------------------
HCONJ CVNew()
  {
  return (HCONJ)(new CConjVerb());
  }

//-----------------------------------------------------------------------------------------------------------------
// Libera todos los recursos relacionados con el objeto de conjugación  'hConj'
//-----------------------------------------------------------------------------------------------------------------
void CVFree( HCONJ hConj )
  {
  delete ((CConjVerb *)hConj);
  }

//-----------------------------------------------------------------------------------------------------------------
// Abre un idioma, identificado por una cadena de caracteres (Codigo del idioma)
//-----------------------------------------------------------------------------------------------------------------
bool CVOpen( HCONJ hConj, LPCSTR sLang )
  {
  return ((CConjVerb *)hConj)->Open(sLang);
  }

//-----------------------------------------------------------------------------------------------------------------
// Abre un idioma, identificado por un entero (Codigo del idioma)
//-----------------------------------------------------------------------------------------------------------------
bool CVOpen( HCONJ hConj, int iLang )
  {
  return ((CConjVerb *)hConj)->Open(iLang);
  }

//-----------------------------------------------------------------------------------------------------------------
// Establece el directorio donde estan los diccionarios
//-----------------------------------------------------------------------------------------------------------------
void CVSetDataPath( HCONJ hConj, const CStringF& Path)
  {
  ((CConjVerb *)hConj)->SetDataPath(Path);
  }

//-----------------------------------------------------------------------------------------------------------------
// Conjuga un verbo, segun los parametros solicitados
//-----------------------------------------------------------------------------------------------------------------
CStringA CVConjugate( HCONJ hConj, const CStringA& verboi, int modo, int tiempo, int persona, int numero, bool negado, bool compuesto )
  {
	//COLLECT_INTERVAL("CVConjugate"); // 0.86 82082
  return ((CConjVerb *)hConj)->ConjugaVerb(verboi, (Modo)modo, (Tiempo)tiempo, (Persona)persona, (Numero)numero, negado, compuesto);
  }

//-----------------------------------------------------------------------------------------------------------------
// Función que concuerda un sustantivo o adjetivo en un género, número y grado determinado
//-----------------------------------------------------------------------------------------------------------------
CStringA CVConcordWords( HCONJ hConj, const CStringA& noun, int srcGen, int srcNum, int desGen, int desNum, int grado)
  {
  return ((CConjVerb *)hConj)->ConcordWords( noun, (Genero)srcGen, (Numero)srcNum, (Genero)desGen, (Numero)desNum, (Grado)grado);
  }

//-----------------------------------------------------------------------------------------------------------------
// Función que concuerda un sustantivo o adjetivo en un género, número y grado determinado
//-----------------------------------------------------------------------------------------------------------------
CStringA CVConcordWordsIndex( HCONJ hConj, const CStringA& noun, int srcGen, int srcNum, int desGen, int desNum, int grado, LPWORD decCount, WORD idx)
  {
  return ((CConjVerb *)hConj)->ConcordWordsIndex( noun, (Genero)srcGen, (Numero)srcNum, (Genero)desGen, (Numero)desNum, (Grado)grado, decCount, idx);
  }

//--------------------------------------------------------------------------------------------------------------
// Función que declina un sustantivo según el género, el número y el caso
//--------------------------------------------------------------------------------------------------------------
CStringA CVDeclineNoun( HCONJ hConj, const CStringA& noun, int gen, int num, int decl)
  {
  return ((CConjVerb *)hConj)->DeclineNoun( noun, (Genero)gen, (Numero)num, (Declination)decl );
  }

//--------------------------------------------------------------------------------------------------------------
// Función que declina un sustantivo según el género, el número y el caso para un indice dado
//--------------------------------------------------------------------------------------------------------------
CStringA CVDeclineNounIndex( HCONJ hConj, const CStringA& noun, int gen, int num, int decl, LPWORD decCount, WORD idx)
  {
  return ((CConjVerb *)hConj)->DeclineNounIndex( noun, (Genero)gen, (Numero)num, (Declination)decl, decCount, idx);
  }

//--------------------------------------------------------------------------------------------------------------
// Función que declina un adjetivo según el género, el número el caso y el tipo de artículo que se le inserta 
//--------------------------------------------------------------------------------------------------------------
CStringA CVDeclineAdjective( HCONJ hConj, const CStringA& adj, int gen, int num, int decl, int artic)
  {
  return ((CConjVerb *)hConj)->DeclineAdjective( adj, (Genero)gen, (Numero)num, (Declination)decl, (ArticleType) artic);
  }

//--------------------------------------------------------------------------------------------------------------
// Devuelve el número total de conjugaciones posibles para un idioma dado
//--------------------------------------------------------------------------------------------------------------
int CVCount(HCONJ hConj)
  {
  return ((CConjVerb *)hConj)->Count();
  }

//--------------------------------------------------------------------------------------------------------------
// Función que devuelve si la conjugación idx corresponde a un tiempo compuesto o no en el idioma dado
//--------------------------------------------------------------------------------------------------------------
bool CVCompound(HCONJ hConj, WORD idx)
  {
  return ((CConjVerb *)hConj)->Compound(idx);
  }

//--------------------------------------------------------------------------------------------------------------
// Función que devuelve el modo de la conjugación idx en el idioma dado
//--------------------------------------------------------------------------------------------------------------
WORD CVMood(HCONJ hConj, WORD idx)
  {
  return ((CConjVerb *)hConj)->Mood(idx);
  }

//--------------------------------------------------------------------------------------------------------------
// Función que devuelve el tiempo verbal de la conjugación idx en el idioma dado
//--------------------------------------------------------------------------------------------------------------
WORD CVTime1(HCONJ hConj, WORD idx)
  {
  return ((CConjVerb *)hConj)->Time(idx);
  }

//--------------------------------------------------------------------------------------------------------------
// Función que retorna un puntero al diccionario o tabla especificado
//--------------------------------------------------------------------------------------------------------------
LPVOID CVGetPtrDicRef( HCONJ hConj, int name)
  {
  return ((CConjVerb *)hConj)->GetPtrDicRef( (DicName)name );
  }

//-----------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------
