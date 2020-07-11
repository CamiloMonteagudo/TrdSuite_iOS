/*
 *  ProxyDict.mm
 *  IdiomaXTranslator
 *
 *  Created by MacPC on 5/27/11.
 *  Copyright 2011 IdiomaX. All rights reserved.
 *
 */

#include "ProxyDict.h"
#include "WinUtil.h"
#include "Dict.h"
#include "AppData.h"
#include "UtilFun.h"
#include "ApiRed.h"
#include "DictUserIndex.h"
#import "ColAndFont.h"

//-----------------------------------------------------------------------------------------------------------------------------------------------
LPCSTR   GetTypeDesc( TGramMean &sType );
void     AddFixMean( NSMutableAttributedString* Str, CStringA &Mean );

NSAttributedString* WordDataFormated(CStringA &csKey, CStringA &csData, BOOL noKey);
NSAttributedString* WordDataKeyFormated(CStringA &csKey, CStringA &csData, BOOL noKey);

static void AddNSString( NSMutableAttributedString* Str, NSString* mStr,  NSDictionary* attrDict );

//-----------------------------------------------------------------------------------------------------------------------------------------------
@implementation ProxyDict

static CDict* _Dict    = NULL;
static int    _openSrc = -1;
static int    _openDes = -1;
static bool   _Found   = FALSE;
static TInt   _LastIdx = -1;

static LPCSTR TypCodes[] = { "SS"    , "NP"       , "AA"  , "DD"  , "VT"      , "VI"        , "VR"    , "VA"     , "PP"   , "PT"      , "PI"        , "GT"      , "GI"        , "CC"     , "JJ"     , "AI"          };
static LPCSTR TypDesEn[] = { "Noun"  , "Prop.Noun", "Adj.", "Adv.", "Trans.V.", "Intrans.V.", "Ref.V.", "Aux.V." , "Prep.", "Trans.P.", "Intrans.P.", "Trans.G.", "Intrans.G.", "Conj."  , "Interj.", "Static Adj." };
static LPCSTR TypDesEs[] = { "Sust." , "N.Prop."  , "Adj.", "Adv.", "V.Trans.", "V.Intrans.", "V.Ref.", "V.Aux." , "Prep.", "P.Trans.", "P.Intrans.", "G.Trans.", "G.Intrans.", "Conj."  , "Interj" , "Adj.Estat."  };
static LPCSTR TypDesFr[] = { "Subst.", "N.Propre" , "Adj.", "Adv.", "V.Trans.", "V.Intrans.", "V.Ref.", "V.Aux." , "Prep.", "P.Trans.", "P.Intrans.", "G.Trans.", "G.Intrans.", "Conj."  , "Interj.", "Adj.Fixe"    };
static LPCSTR TypDesIt[] = { "Sost." , "N.Proprio", "Agg.", "Avv.", "V.Trans.", "V.Intrans.", "V.Rif.", "V.Auss.", "Prep.", "P.Trans.", "P.Intrans.", "G.Trans.", "G.Intrans.", "Coniug.", "Inter." , "Agg.Stat."   };

static LPCSTR *TypsDes[] = { TypDesEs, TypDesEn, TypDesIt, TypDesEn, TypDesFr };
static LPCSTR *TypDes = TypDesEn; 

static CDictUserIndex* Index = NULL;
static CDictUserIndex* SaveIndex = NULL;

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Abre el diccionario actual
+(bool) OpenDictSrc:(int) src Dest:(int) des
  {
  if( src==_openSrc && des==_openDes ) return TRUE;
  if( src==-1       || des==-1       ) return FALSE;
  
  NSString *dicName = [NSString stringWithFormat:@"%@2%@.dic", LGAbrv(src), LGAbrv(des)];
  
  [self CloseDict];                  
  
  _Dict = new CDict("");
  
 	NSString *path = [[NSBundle mainBundle] bundlePath];	
            path = [path stringByAppendingPathComponent: dicName];
  
 	CStringA dictPath = [path cStringUsingEncoding:NSUTF8StringEncoding ];
    
 	if( !_Dict->Open(dictPath) ) 
    {
    NSAssert( _Dict !=  NULL, @"No se pudo crear el objeto CDict" );
    return FALSE; 
    }
    
  _openSrc = src;
  _openDes = des;
  
  TypDes = TypsDes[des];

  LoadIndexFromFile();
    
//  if( LoadIndexFromFile() != DICT_NO_ERROR )
//    GenerateDictIndex();
  
  return TRUE;
  }

//------------------------------------------------------------------------------------------------------
// Carga el fichero de indice para mostrar el diccionario
int LoadIndexFromFile()
  {
  NSString*  fName = [NSString stringWithFormat:@"Index%@%@", LGAbrv(_openSrc), LGAbrv(_openDes) ];
  NSString*   Path = GetFullAppPath( fName );
  CStringA  csPath = [Path cStringUsingEncoding:NSUTF8StringEncoding ];
  
  Index = new CDictUserIndex();
  
  if( Index->Load(csPath) == DICT_NO_ERROR )
		return DICT_NO_ERROR;
  
  delete Index;
  Index = NULL;
  return CAN_NOT_OPENFILE_IDX;
  }

////------------------------------------------------------------------------------------------------------
//// Crea un indice para el diccionario, ordenado sin mayusculas ni acentos y sin llaves 'especiales'
//void GenerateDictIndex()
//  {
//  if( Index     != NULL )   delete Index;
//  if( SaveIndex != NULL ) { delete Index; SaveIndex=NULL; }
//  
//  Index = new CDictUserIndex();
//  
//  int count = _Dict->GetCount();
//  Index->SetSize( count );
//  
//  CStringA csKey;
//  for( int i=0; i<count; ++i )
//    {
//    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
//    
//    _Dict->GetKeyAt( i, csKey);
//    
//    int iFind = csKey.Find( "xxxx" );
//    if( iFind >= 0 ) continue;
//    
//    iFind = csKey.Find( '[' );
//    if( iFind >= 0 ) continue;
//    
//    iFind = csKey.Find( '(' );
//    if( iFind >= 0 ) continue;
//    
//    iFind = csKey.Find( ')' );
//    if( iFind >= 0 ) continue;
//    
//    iFind = csKey.Find( '$' );
//    if( iFind >= 0 ) continue;
//    
//    iFind = csKey.Find( '<' );
//    if( iFind >= 0 ) continue;
//    
//    if( csKey[0] == ','   ) continue;
//    if( csKey[0] == '\''  ) continue;
//    if( csKey[0] == '-'   ) continue;
//    if( csKey[0] == '"'   ) continue;
//    if( csKey[0] == ';'   ) continue;
//    if( isdigit(csKey[0]) ) continue;
//    
//    NSString* sKey = [NSString stringWithCString:csKey.c_str() encoding:NSISOLatin1StringEncoding ];
//    
//    int Idx;
//    if( !Index->Find(_Dict, sKey, &Idx )  )
//      Index->InsertAt(Idx, i);
//    }
//  
//  NSLog(@"%d-%d de %8d a %8d eliminados %d",_openSrc, _openDes , count, Index->Count(), count-Index->Count());
//  
//  SaveIndexToFile();
//  }
//
////------------------------------------------------------------------------------------------------------
//// Guarda el indice generado en ese momento hacia un fichero
//void SaveIndexToFile()
//  {
//  NSString*  fName = [NSString stringWithFormat:@"Index%@%@", LGAbrv(_openSrc), LGAbrv(_openDes) ];
//  NSString*   Path = GetFullDocPath( fName );
//  CStringA  csPath = [Path cStringUsingEncoding:NSUTF8StringEncoding ];
//  
//  Index->Save( csPath );
//  }

//------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el camino completo del fichero en el directorio para documentos de la aplicación
 NSString* GetFullDocPath( NSString* fName )
  {
  NSFileManager *fMng = [[NSFileManager alloc] init];                             // Crea objeto para manejo de ficheros
  
  NSURL *url =[fMng URLForDirectory:NSDocumentDirectory                           // Le pide el directorio de los documentos
                           inDomain:NSUserDomainMask 
                  appropriateForURL:nil 
                             create:YES 
                              error:nil];
  
  return [[url path] stringByAppendingPathComponent:fName];               // Le adiciona el nombre del fichero para los datos
  }

//------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el camino completo del fichero en el directorio de la aplicación
 NSString* GetFullAppPath( NSString* fName )
  {
  NSString *Path =[[NSBundle mainBundle] bundlePath];                             // Obtiene el directorio donde se instalo el paquete
  
  return [Path stringByAppendingPathComponent:fName];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Determina si las llaves estan filtradas o no
+(BOOL) IsFiltered
  {
  return ( SaveIndex != NULL );
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Filtra las llaves actales del diccionario
+(void) KeysFilter:(NSString*) sFilter
  {
  if( Index==NULL ) return;                                 // No hay diccionario abierto, no hace nada
 
  if( SaveIndex != NULL )                                   // Si ya habia un filtro lo borra
    {
    [self RemoveFilter];                                    // Quita el filtro
    return;                                                 // Retorna
    }
  
  int fLen = (int)sFilter.length;
  if( sFilter==nil || fLen==0 ) return;                     // Si el filtros es nulo o vacio no hace nada
  
  SaveIndex = Index;                                        // Guarda el indice original
  Index = new CDictUserIndex();                             // Crea un nuevo indice vacio
  
  int count = SaveIndex->Count();                           // Obtiene tamaño del indice original
  Index->SetSize( count );                                  // Reserva memoria, para el caso mas critico
  
 	CStringA csFilter = [sFilter cStringUsingEncoding:NSUTF8StringEncoding ];
  
  CStringA csKey;
  for( int i=0; i<count; ++i )                              // Recorre todas las llaves del diccionario
    {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
    
    int idx = SaveIndex->IndexAt(i);                        // Toma indice real al diccionario
    
    _Dict->GetKeyAt( idx, csKey);                           // Obtiene la llave del diccionario
    
    int ini = csKey.Find( csFilter );                       // Busca si la llave contiene el filtro
    
    if( ini >= 0  )                                         // Si la llave contiene el filtro
      {
      int kLen = csKey.Length();                            // Longitud del la llave
      int fin  = ini + fLen;                                // Indice de la ultima letra de la llave que machea con el filtro
  
      if( (ini==0    || csKey[ini-1]==' ')  &&            // Empieza en una frontera de palabra
          (fin==kLen || csKey[fin  ]==' ') )              // Termina en una frotera de palabra
        Index->Add(idx);                                    // Adiciona la llave al indice
      }
    }
    
  Index->SetSize( Index->Count() );                         // Reajusta el tamaño del indice
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Muestra todos los datos, eliminando lo filtros existentes
+(void) RemoveFilter
  {
  if( SaveIndex == NULL )                                     // No habia filtro
    return;
  
  delete Index;
  Index = SaveIndex;
  SaveIndex = NULL;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Cierra el diccinario activo, si esta abierto
+(void) CloseDict
  {
  if( _Dict!= NULL )
    {
    _Dict->Close();

    delete _Dict;

    _openSrc = -1;
    _openDes = -1;
    
    _Dict = NULL;
    }
    
  if(     Index != NULL ) { delete Index;   Index = NULL; }
  if( SaveIndex != NULL ) { delete Index; SaveIndex=NULL; }
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene los datos de una palabra en el diccionario actual, 'NoKey' inidica que no se incluya la llave en los datos
+(NSAttributedString*) getWDataFromIndex: (int)idx NoKey:(BOOL) noKy
  {
  if( _openSrc==-1 || _openDes==-1 ) return nil;
  
  CStringA sHtm, sKey, sData;
  
  if( Index != NULL )
    idx = Index->IndexAt( idx );
    
  _Dict->GetKeyAt (idx, sKey);
  _Dict->GetDataAt(idx, sData);
   
  if( sData.Length()>0 )
    return WordDataFormated( sKey, sData, noKy );
    
  return nil;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Obtiiene una cadena con un mensage formateado
+(NSAttributedString*) FormatedMsg:(NSString*) sMsg Title:(NSString*) sTitle
  {
  NSMutableAttributedString* Str = [[NSMutableAttributedString alloc] init];
  
  if( sTitle && sTitle.length>0 )
    {
    AddNSString( Str, sTitle, attrKey );
    AddNSString( Str, @"\r\n", attrKey );
    }
  
  AddNSString( Str, sMsg, attrBody2  );
  
  return Str;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la cantidad de palabras en el diccionario actual
+(int) getSize
  {
  if( _openSrc==-1 || _openDes==-1 ) return 0;
  
  return (Index != NULL)? Index->Count() : _Dict->GetCount();
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la palabra que se encuentra en el indice 'idx' en el diccionario actual
+(NSString *)getWordAt: (int)idx
	{
  if( _openSrc==-1 || _openDes==-1 ) return @"";
  
  CStringA csKey;
    
  if( Index != NULL )
    idx = Index->IndexAt( idx );
    
  _Dict->GetKeyAt( idx, csKey);

  return [NSString stringWithCString:csKey.c_str() encoding:NSISOLatin1StringEncoding ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la el indice de la palabra Key en el diccionario
+(int) getWordIdx: (NSString *) Key
  {
  if( _openSrc==-1 || _openDes==-1 ) return 0;
  
  if( Index != NULL )
    _Found = Index->Find(_Dict, Key, &_LastIdx );
  else
    {
    CStringA csKey = [Key cStringUsingEncoding:NSISOLatin1StringEncoding];
    _Found = _Dict->FindIndex( csKey, _LastIdx);
    }
  
  return _LastIdx;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la palabra que se encuentra en el indice 'idx' en el diccionario actual
+(bool) Found { return _Found; }

//-----------------------------------------------------------------------------------------------------------------------------------------------

@end

//-----------------------------------------------------------------------------------------------------------------------------------------------
static void AddCString( NSMutableAttributedString* Str, CStringA &cStr,  NSDictionary* attrDict )
  {
  NSString* mStr = [NSString stringWithCString:cStr.c_str() encoding:NSISOLatin1StringEncoding ];
  
  [Str appendAttributedString: [[NSMutableAttributedString alloc] initWithString:mStr attributes:attrDict] ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
static void AddLPCSTR( NSMutableAttributedString* Str, LPCSTR cStr,  NSDictionary* attrDict )
  {
  NSString* mStr = [NSString stringWithCString:cStr encoding:NSISOLatin1StringEncoding ];
  
  [Str appendAttributedString: [[NSMutableAttributedString alloc] initWithString:mStr attributes:attrDict] ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
static void AddNSString( NSMutableAttributedString* Str, NSString* mStr,  NSDictionary* attrDict )
  {
  [Str appendAttributedString: [[NSMutableAttributedString alloc] initWithString:mStr attributes:attrDict] ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene los datos de una palabra formateados
NSAttributedString* WordDataFormated(CStringA &csKey, CStringA &csData, BOOL noKey)
  {
  CDictData* oDictData = new CDictData();
  oDictData->ParseTxt(csData);
    
  TInt nTypes = oDictData->GetTypesCount();
  
  if( nTypes <= 0 )
    return WordDataKeyFormated( csKey, csData, noKey );

  NSMutableAttributedString* Str = [[NSMutableAttributedString alloc] init];
  
  if( noKey==FALSE )
    AddCString ( Str, csKey, attrKey );
  
  // para cada tipo gramatical
  for( int idxType=0; idxType < nTypes; idxType++)
    {
    // poner el tipo gramatical
    oDictData->put_ActualTypeIdx(idxType);
    TGramType sType;
    oDictData->get_ActualType(sType);
    
    if( Str.length > 0 )
      AddNSString( Str, @"\r\n", attrBody );
    
    AddLPCSTR  ( Str, GetTypeDesc(sType), attrType );
    AddNSString( Str, @" "              , attrBody );
    
    TInt nMean = oDictData->MeanCountAt(idxType);
      
    // para cada significado
    for(int idxMean=0; idxMean<nMean; idxMean++)
      {
      oDictData->put_ActualMeanIdx(idxMean);
        
      TGramMean sMean;
      oDictData->get_ActualMean(sMean);
        
      // la especialidad solo se pone si no esta vacia y no es la general
      TGramEsp esp;
      oDictData->get_ActualEsp(esp);
      if (!esp.IsEmpty() && esp != "GG")
        {
        AddCString ( Str, esp , attrAttr );
        AddNSString( Str, @" ", attrBody );
        }
        
      // el genero solo se pone si no esta vacio y no es masculino
      TText gender = oDictData->get_ActualGen();
      if( gender != 0 && gender != 'm' )
        {
        if (gender == 'f') AddNSString( Str, @"f. " , attrAttr );
        else               AddNSString( Str, @"n. " , attrAttr );
        }
        
      // el numero solo se pone si es plural
      TText number = oDictData->get_ActualNum();
      if( number == 'p' )
        AddNSString( Str, @"p. " , attrAttr );
      
      AddFixMean( Str, sMean );

      if( idxMean==(nMean-1) ) AddNSString( Str, @". ", attrBody );
      else                     AddNSString( Str, @", ", attrBody );
      }
    }
    
  return Str;
  }

//------------------------------------------------------------------------------------------------------
// Obtiene la descripcion del tipo gramatical
LPCSTR GetTypeDesc( TGramMean &sType )
  {
  for( int i=0; i<sizeof(TypCodes)/sizeof(LPCSTR); ++i )
    if( sType.Compare(TypCodes[i]) == 0 )
      return TypDes[i];
    
  return "";
  }

//------------------------------------------------------------------------------------------------------
// Resalta las palabras dentro del significado que estan entre <>
void AddFixMean( NSMutableAttributedString* Str, CStringA &Mean )
  {
  int iIni = Mean.Find( '<' );
  if( iIni < 0 )
    {
    AddCString( Str, Mean, attrBody );
    return;
    }
  
  int iEnd = Mean.Find( '>', iIni );
  if( iEnd < 0 )
    {
    AddCString( Str, Mean, attrBody );
    return;
    }

  CStringA sLeft  = Mean.Left( iIni );
  CStringA sMidle = Mean.Mid( iIni+1, iEnd-iIni-1 );
  CStringA sRight = Mean.Mid( iEnd+1 );
  
  AddCString( Str, sLeft , attrBody  );
  AddCString( Str, sMidle, attrBody2 );
  AddCString( Str, sRight, attrBody  );
  }

//------------------------------------------------------------------------------------------------------
// Adiciona todo lo que este entre comillas a la cadena formateada 'Str'
void AddEntreComillas( NSMutableAttributedString* Str, CStringA &aDataText, BOOL noKey)
  {
  int  pos1 = 0;
  bool first = true;
  
  int len = aDataText.Length();
  while( pos1 < len )
    {
    pos1 = aDataText.Find('\"', pos1 );
    if( pos1 == -1 ) break;
    
    int pos2 = aDataText.Find('\"', pos1 + 1);
    if( pos2 == -1 ) break;
    
    CStringA sMean = aDataText.Mid( pos1+1, pos2-(pos1+1) );
    
    if( first && !noKey ) AddNSString( Str, @"\r\n", attrBody );
    else                  AddNSString( Str, @", "  , attrBody );
    
    AddFixMean( Str, sMean );
    
    pos1  = pos2 + 1;
    first = false;
    }
  }
  
  //------------------------------------------------------------------------------------------------------
  // Quita todas las partes de la cadena 'aDataText' que esten entre parentisis 
  void RemoveParenthesis(CStringA& aDataText)
    {
    int pClose = 0;
    int pOpen = 0;
    
    // buscar el primer parentesis que cierra
    while ((pClose = aDataText.Find(')')) > 0)
      {
      // ir hacia atras buscando el primero que abre
      pOpen = pClose - 1;
      while (pOpen >= 0 && aDataText[pOpen] != '(')
        pOpen--;
      
      if (pOpen >= 0)
        // borrar el texto y los parentesis
        aDataText.Delete(pOpen, pClose - pOpen + 1);
      else // no se encontro el parentesis que cierra, terminar
        break;
      }
    }

//------------------------------------------------------------------------------------------------------
// Obtiene una cadena formateada con los datos de una entrada que tiene una palabra clave
NSAttributedString* WordDataKeyFormated(CStringA &csKey, CStringA &csData, BOOL noKey)
  {
//  CStringA cpy = csData;
  RemoveParenthesis(csData);
    
  NSMutableAttributedString* Str = [[NSMutableAttributedString alloc] init];
  
  if( noKey==FALSE )
    AddCString ( Str, csKey  , attrKey  );
    
  int pos1 = 0, pos2 = 0;
  int len = csData.Length();
  bool first = TRUE;
    
  while( pos1 < len )                         // Si hay llaves solo coje la que esta adentro
    {
    pos1 = csData.Find('{', pos1 );           // Busca llave inicial
    if( pos1 == -1 )                          // No encontro llave inicial
      {
      if( first ){ pos1=0; pos2=len; }        // Si no hay llaves, lo coge todo
      else break;                             // No hay mas llaves, termina
      }
    else                                      // Encontro llave inicial
      {
      pos2 = csData.Find('}', pos1 + 1);      // Busca llave final
      if( pos2==-1 ) break;                   // No la encontro, termina (llaves no macheadas)
      }
      
    CStringA sMeans = csData.Mid( pos1+1, pos2-(pos1+1) );        // Coge el contenido
    AddEntreComillas( Str, sMeans, noKey );                       // Adiciona solo lo que esta entre comillas
    
    pos1  = pos2 + 1;                                             // Pasa a buscar la otra llave
    first = FALSE;                                                // Quita bandera de primera ves
    }
  
  return Str;
  }

//------------------------------------------------------------------------------------------------------

