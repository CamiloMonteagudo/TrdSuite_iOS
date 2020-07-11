//------------------------------------------------------------------------------------------------------------
// Definiciones para el uso del API de traducció
//------------------------------------------------------------------------------------------------------------

#ifndef __API_TRD__
#define __API_TRD__

//------------------------------------------------------------------------------------------------------------
// Manipuladores usados por las funciones
//------------------------------------------------------------------------------------------------------------
#define HTRD  LPVOID    // Manipulador para una dirección de traducción
#define HUTRD LPVOID    // Manipiladar para la trducción por un usuario

//------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------
// Constantes para la función 'CatTranslateSentence'
//---------------------------------------------------------------------------
#define TD_TRANSLATE					  0	  // ok
#define TD_REFRESH						  1	
#define TD_RETRANSLATE					2
#define TD_TRANSLATE_NO_STAT		4
#define TD_FIND_PROPER_NOUN	    5   // ok
#define TD_FIND_NOUN_PHRASE	    6	  // ok
#define TD_SCAN_WORD_FRECUENCY	7   // ok
#define TD_SCAN_SEM_VALUE_WORD	8   // ok
#define TD_FILL_GRAM_TYPE_DCC	  9   // ok
#define TD_FILL_STAT_FOR_WORD	  10
#define TD_SCAN_NOT_FOUND_WORD  11  // ok
#define TD_EVAL_INPUT					  12
#define TD_FILL_NGRAM_DIC				13
#define	TD_FILL_SGRAM_TYPE_DCC  14
#define TD_FILL_COMPOUNT_TYPE		15

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
#define PATH_TRAD   0x00000001
#define PATH_LANG   0x00000002

//---------------------------------------------------------------------------
// Constantes para la función 'CatGetDictionary'
//---------------------------------------------------------------------------

#define GD_GENERAL_DIC    0
#define GD_USER_DIC       20
#define GD_VERBOS_IRR     1
#define GD_PREFIJOS       2
#define GD_SUFIJOS        3
#define GD_TRAD_PREFIJOS  4
#define GD_TRAD_SUFIJOS   5
#define GD_TIPO_SUFIJOS   6
#define GD_COMODINES      7
#define GD_CONJ_PALABRA   8
#define GD_CONJ_SUFIJOS   9
#define GD_TIPO_COMODINES 10
#define GD_FEM_IRREG      11
#define GD_FEM_SUFIJO     12
#define GD_PLURAL_IRREG   13
#define GD_PLURAL_SUFIJO  14
#define GD_PATRONES       15
#define GD_PATRON         16
#define GD_TIPOS          17

//---------------------------------------------------------------------------

HTRD TDNew();
void TDFree( HTRD hTrd );

void TDSetPath( HTRD hTrd, const CStringA& Path, int sw=(PATH_TRAD|PATH_LANG) );

//bool TDOpen( HTRD hTrd, LPCSTR sSrc, LPCSTR sDes );
bool TDOpen( HTRD hTrd, const CStringA& sSrc, const CStringA& sDes );
bool TDOpen( HTRD hTrd, int iSrc, int iDes );
bool TDOpen( HTRD hTrd,LPCSTR sLang );

#ifdef ACTIVE_SAVE
bool TDSave( HTRD hTrd);
#endif

HUTRD  TDOpenUser( HTRD hTrd ) ;
void   TDFreeUser( HUTRD hUTrd );
void   TDSetIniNF( HUTRD hUTrd, LPCSTR sMark );
void   TDSetEndNF( HUTRD hUTrd, LPCSTR sMark );
void   TDSetIniNT( HUTRD hUTrd, LPCSTR sMark );
void   TDSetEndNT( HUTRD hUTrd, LPCSTR sMark );
void   TDSetSentence( HUTRD hUTrd, const CStringA& sSentence);
void   TDTranslate( HUTRD hUTrd, WORD wherebegin);
const CStringA& TDGetSentence( HUTRD hUTrd );
const CStringA& TDGetOutput( HUTRD hUTrd, int data );
void   TDSetEsp( HUTRD hUTrd, LPCSTR ptrStr);

//------------------------------------------------------------------------------------------------------------

#endif

