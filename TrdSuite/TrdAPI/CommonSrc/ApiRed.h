//------------------------------------------------------------------------------------------------------------
// Definiciones para el uso del API de conjugaciones
//------------------------------------------------------------------------------------------------------------

#ifndef __API_REDWORD__
#define __API_REDWORD__

#include "WinUtil.h"
#include "ApiConj.h"

//------------------------------------------------------------------------------------------------------------
// Manipulador a un objeto para reducir verbos
//------------------------------------------------------------------------------------------------------------
#define HREDW  LPVOID

//------------------------------------------------------------------------------------------------------------
// Manipulador a un objeto donde se almacenan los resultados de la conjugación
//------------------------------------------------------------------------------------------------------------
#define HREDDATA  LPVOID

//--------------------------------------------------------------------------------------------------------------
// Clasificación de los tipos reducidos
//--------------------------------------------------------------------------------------------------------------
#define rVERBO        0
#define rADJETIVE     1
#define rSUSTANTIVE   2
#define rPRONOMBRE    3
#define rADVERBIO     4
#define rARTICLE      5

//------------------------------------------------------------------------------------------------------------
// Definición de tipos de diccionarios usados en la reducción
//------------------------------------------------------------------------------------------------------------
enum RWDicName{ drIrregNoun, drIrregVerb, drNounSuffix, drPreffix, drVerbSuffix };

//------------------------------------------------------------------------------------------------------------
// Funciones exportable del API de reducción
//------------------------------------------------------------------------------------------------------------

HREDW    RWNew();
void     RWFree         ( HREDW hRedW );
void     RWSetDataPath  ( HREDW hRedW, const CStringF& Path );
CStringF RWGetDataPath  ( HREDW hRedW );
void     RWSetConjHandle( HREDW hRedW, HCONJ hConj, bool free );
void     RWSetGenDict   ( HREDW hRedW, LPVOID hDic, bool free );
bool     RWOpen         ( HREDW hRedW, LPCSTR sLang );
bool     RWOpen         ( HREDW hRedW, int iLang );
bool     RWClose        ( HREDW hRedW );
HREDDATA RWReduce       ( HREDW hRedW, const CStringA& Word );
LPVOID   RWGetPtrDicRef ( HREDW hRedW, int name );

void RWDump( HREDDATA hRedData );

int  RWGetCount    ( HREDDATA hRedData );

CString RWGetRoot     ( HREDDATA hRedData, int idx );
CString RWGetType     ( HREDDATA hRedData, int idx );
int     RWGetMood     ( HREDDATA hRedData, int idx );
int     RWGetTime     ( HREDDATA hRedData, int idx );
int     RWGetPerson   ( HREDDATA hRedData, int idx );
int     RWGetNumber   ( HREDDATA hRedData, int idx );
int     RWGetGender   ( HREDDATA hRedData, int idx );
int     RWGetDegree   ( HREDDATA hRedData, int idx );
CString RWGetPreffix  ( HREDDATA hRedData, int idx );
CString RWGetCDirect  ( HREDDATA hRedData, int idx );
CString RWGetCIndirect( HREDDATA hRedData, int idx );

int RWGetClassType( HREDDATA hRedData, int idx );

void RWFreehData( HREDDATA hRedData );

//------------------------------------------------------------------------------------------------------------
// Clases para el empleo del API
//------------------------------------------------------------------------------------------------------------
class CRedDataApi               // Representa los datos de una palabra reducida
  {
  public:
  HREDDATA m_hRedData;

  CRedDataApi(HREDDATA h) {m_hRedData=h;}
  ~CRedDataApi() {RWFreehData(m_hRedData);}

  int Count(){ return RWGetCount(m_hRedData);}

  CString Root     ( int idx ){ return RWGetRoot     ( m_hRedData, idx ); }
  CString Type     ( int idx ){ return RWGetType     ( m_hRedData, idx ); }
  int  Mood     ( int idx ){ return RWGetMood     ( m_hRedData, idx ); }
  int  Time     ( int idx ){ return RWGetTime     ( m_hRedData, idx ); }
  int  Person   ( int idx ){ return RWGetPerson   ( m_hRedData, idx ); }
  int  Number   ( int idx ){ return RWGetNumber   ( m_hRedData, idx ); }
  int  Gender   ( int idx ){ return RWGetGender   ( m_hRedData, idx ); }
  int  Degree   ( int idx ){ return RWGetDegree   ( m_hRedData, idx ); }
  CString Preffix  ( int idx ){ return RWGetPreffix  ( m_hRedData, idx ); }
  CString CDirect  ( int idx ){ return RWGetCDirect  ( m_hRedData, idx ); }
  CString CIndirect( int idx ){ return RWGetCIndirect( m_hRedData, idx ); }

  int ClassType  ( int idx ){ return RWGetClassType( m_hRedData, idx ); }
  };

class CRedApi                   // Representa un objeto conjugación para un idioma dado
  {
  public:
  HREDW m_hRedW;

  CRedApi() {m_hRedW = RWNew();}
  ~CRedApi(){RWFree( m_hRedW );}

  void   SetDataPath( const CStringF& Path ) {RWSetDataPath( m_hRedW, Path );}
  CStringF GetDataPath()              {return RWGetDataPath( m_hRedW );}

  void SetConjHandle( HCONJ hConj, bool free=false ) 
    {RWSetConjHandle( m_hRedW, hConj, free );}

  void SetGenDict( LPVOID hDic, bool free=false ) 
    {RWSetGenDict( m_hRedW, hDic, free );}

  bool Open( LPCSTR sLang ) {return RWOpen( m_hRedW, sLang );}
  bool Open( int    iLang ) {return RWOpen( m_hRedW, iLang );}

  CRedDataApi* Reduce( CStringA Word )
    { 
    HREDDATA h = RWReduce( m_hRedW, Word );
    return (h)? new CRedDataApi(h) : NULL; 
    }

  LPVOID GetPtrDic( int iDic ) {return RWGetPtrDicRef( m_hRedW, iDic );}

  bool Close() { return RWClose( m_hRedW );}
  };

//------------------------------------------------------------------------------------------------------------
#endif
