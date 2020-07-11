//=========================================================================================================================================================
//  Sentences.m
//  TrdSuite
//
//  Created by Camilo on 08/11/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "Sentences.h"
#import "AppData.h"

//=========================================================================================================================================================
static Sentences* LoadedSent[LGCount][LGCount] =
	{
  //       Es,  En,  It,  De,  Fr
  /*Es*/{ nil, nil, nil, nil, nil },
  /*En*/{ nil, nil, nil, nil, nil },
  /*It*/{ nil, nil, nil, nil, nil },
  /*De*/{ nil, nil, nil, nil, nil },
  /*Fr*/{ nil, nil, nil, nil, nil }
	};

Sentences* NowOras;

//=========================================================================================================================================================
// Implementa una lista de oraciones con sus traducciones en varios idiomas
@interface Sentences()
  {
  int Lang1;                                      // Primer idioma
  int Lang2;                                      // Segundo idioma

  NSMutableArray* Items;                          // Conjunto de todas las oraciones
  
  NSMutableArray* Indexes1;                       // Indices a las oraciones ordenadas por el primer idioma
  NSMutableArray* Indexes2;                       // Indices a las oraciones ordenadas por el segundo idioma
  
  NSMutableArray* ItemsDeleted;                   // Conjunto de oraciones que ha sido borradas del indice

  NSMutableArray* IdxsSrc;                        // Inidices que se utilizará como fuente
  NSMutableArray* IdxsDes;                        // Inidices que se utilizará como destino
  int             lngSrc;                         // Idioma que se utilizará como fuente
  int             lngDes;                         // Idioma que se utilizará como destino
  }

@end

//=========================================================================================================================================================
@implementation Sentences

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Retorna el objeto actual para manejo de oraciones
+ (Sentences*) Actual
  {
  return NowOras;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si el objeto actual es de la dirección indicada
+ (BOOL) IsActualLangSrc:(int) lngSrc AndLangDes:(int) lngDes
  {
  if( NowOras==nil ) return FALSE;
  
  return (NowOras->lngSrc == lngSrc && NowOras->lngDes == lngDes);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga las oraciones dede el cache, desde el directorio del documento o desde la aplicación por ese orden
+ (Sentences*) LoadWithLang1:(int) lng1 AndLang2:(int) lng2
  {
  NowOras = LoadedSent[lng1][lng2];
  if( NowOras != nil )
    {
    [NowOras SetNowLang:lng1];
    return NowOras;
    }
  
  [self InitWithLang1:lng1 AndLang2:lng2];
  
  NSString *DocPath = [NowOras FNameFromDoc:TRUE];
  
  if( [[[NSFileManager alloc] init] fileExistsAtPath:DocPath] )
    [NowOras LoadFromDoc];
  else
    [NowOras LoadFromApp];
  
  [NowOras SetNowLang:lng1];
  return NowOras;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa un objeto vacio con todos los datos por defecto
+ (void) InitWithLang1:(int) lng1 AndLang2:(int) lng2
  {
  NowOras = [Sentences new];
  NowOras->Lang1 = lng1;
  NowOras->Lang2 = lng2;
  
  NowOras->Items = [NSMutableArray new];
  
  NowOras->Indexes1 = [NSMutableArray new];
  NowOras->Indexes2 = [NSMutableArray new];

  NowOras->ItemsDeleted = [NSMutableArray new];
  
  [NowOras SetNowLang:lng1];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga las oraciones dede el directorio de la aplicación
- (BOOL) LoadFromApp
  {
  NSString *AppPath = [self FNameFromDoc:FALSE];
  
  NSStringEncoding Enc;
  NSError          *Err;
  
  NSString *Txt = [NSString stringWithContentsOfFile:AppPath usedEncoding:&Enc error:&Err];
  if( Txt == nil ) return FALSE;
  
  NSArray*  Lines  = [Txt componentsSeparatedByString:@"\n"];
  NSString* sLang1 = LGAbrv(Lang1);
  NSString* sLang2 = LGAbrv(Lang2);
    
  for( int i=0; i<Lines.count-1; )
    {
    Sentence* Item = [Sentence SentenceFromLines:Lines Index:&i sLang1:sLang1 sLang2:sLang2];
    if( Item!=nil )
      [self AddSentence:Item];
    }
  
  if( Items.count > 0)
    {
    LoadedSent[Lang1][Lang2] = self;
    LoadedSent[Lang2][Lang1] = self;
    
    [self Save];
    }
  
  return TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Macros para la lectura de datos desde un arreglo de bytes
#define ReadInt( b, p ) *(int*)(b+p); p+= sizeof(int);

#define ReadString( txt, b, p ) \
    { \
    int _len = *(int*)(b+p); \
    p += sizeof(int); \
    txt =[[NSString alloc] initWithBytes:b+p length:_len encoding:NSUTF8StringEncoding]; \
    p += _len; \
    }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga las oraciones dede el directorio de documentos
- (BOOL) LoadFromDoc
  {
  NSString *FileName = [self FNameFromDoc:TRUE];
  NSData* Datos = [NSData dataWithContentsOfFile:FileName options:NSDataReadingUncached error:nil];
  if( Datos == nil ) return FALSE;
  
  Byte* bytes = (Byte*)Datos.bytes;
  int     ptr = 0;
  
  Lang1 = ReadInt( bytes, ptr );
  Lang2 = ReadInt( bytes, ptr );

  int nOras = ReadInt( bytes, ptr );
    
   NSString* Txt1, *Txt2;
  for( int i=0; i<nOras; ++i )
    {
    ReadString(Txt1, bytes, ptr);
    ReadString(Txt2, bytes, ptr);
    
    Sentence* ora = [Sentence SentenceWithText1:Txt1 AndText2:Txt2];
    [Items addObject:ora];
    }
    
  int nIdx1 = ReadInt( bytes, ptr );
    
  for( int i=0; i<nIdx1; ++i )
    {
    int Idx = ReadInt( bytes, ptr );
    
    [Indexes1 addObject: [NSNumber numberWithInt:Idx]];
    }
    
  int nIdx2 = ReadInt( bytes, ptr );
    
  for( int i=0; i<nIdx2; ++i )
    {
    int Idx = ReadInt( bytes, ptr );
    
    [Indexes2 addObject: [NSNumber numberWithInt:Idx]];
    }
    
  int nDel = ReadInt( bytes, ptr );
    
  for( int i=0; i<nDel; ++i )
    {
    int Idx = ReadInt( bytes, ptr );
    
    [ItemsDeleted addObject: [NSNumber numberWithInt:Idx]];
    }
    
  if( Items.count == 0 ) return FALSE;
  
  LoadedSent[Lang1][Lang2] = self;
  LoadedSent[Lang2][Lang1] = self;

  return TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Macros para la escritura de datos hacia un NSData
#define WriteInt( buf, num ) \
    { \
    int _n = (int)num; \
    [buf appendBytes:(void*)&_n length:sizeof(int)]; \
    }

#define WriteString( buf, str ) \
    { \
    NSData* _Dat = [str dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; \
    int     _len = (int)_Dat.length; \
    [buf appendBytes:(void*)&_len length:sizeof(int)]; \
    [buf appendData:_Dat]; \
    }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Guarda el contenido del objeto hacia el directorio de documentos de la aplicación
- (BOOL) Save
  {
  NSMutableData *buff = [NSMutableData dataWithCapacity:120*Items.count];

  WriteInt(buff, Lang1);
  WriteInt(buff, Lang2);
  
  WriteInt(buff, Items.count);
  
  for( Sentence*Ora in Items )
    {
    WriteString(buff, Ora.Text1);
    WriteString(buff, Ora.Text2);
    }
    
  WriteInt(buff, Indexes1.count);
  for( NSNumber*Num in Indexes1 )
    WriteInt(buff, Num.intValue);
    
  WriteInt(buff, Indexes2.count);
  for( NSNumber*Num in Indexes2 )
    WriteInt(buff, Num.intValue);
    
  WriteInt(buff, ItemsDeleted.count);
  for( NSNumber*Num in ItemsDeleted )
    WriteInt(buff, Num.intValue);
    
  NSString *FileName = [self FNameFromDoc:TRUE];
  
  BOOL ret = [buff writeToFile:FileName atomically:YES];
  if( !ret )
    NSLog(@"No guardaron las oraciones en: '%@'", FileName );

  return ret;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Agrega una oracion e la lista de items y actualiza los indices
- (int) AddSentence:(Sentence*) sent
  {
  int IdxSrc, IdxTrd;                                                   // Indices del orden del texto fuente y traducido
  [self Find:sent.Text1 InIndex:IdxsSrc ReturnIdx:&IdxSrc];             // Busca texto fuente
  [self Find:sent.Text2 InIndex:IdxsDes ReturnIdx:&IdxTrd];             // Busca texto traducido
  
  NSNumber* idxNum;                                                     // Objeto con indice del la oración en la lista de oraciones
  
  if( ItemsDeleted.count>0 )                                            // Si hay al menos un objeto borrado
    {
    idxNum = [ItemsDeleted lastObject];                                 // Toma el indice del último objeto borrado
    [ItemsDeleted removeLastObject];                                    // Quita el indice del la lista de borrados
  
    Items[ idxNum.intValue ] = sent;                                    // Pone nueva oración en el lugar de la borrada
    }
  else
    {
    idxNum = [NSNumber numberWithInt: (int)Items.count];                // Crea objeto con indice al último elemento de arreglo
  
    [Items addObject:sent];                                             // Adiciona la oración al final de la lista
    }
    
  [IdxsSrc insertObject:idxNum atIndex:(int)IdxSrc ];                   // Agrega el indice para orden por el texto fuente
  [IdxsDes insertObject:idxNum atIndex:(int)IdxTrd ];                   // Agrega el indice para orden por el texto destino
  
  return IdxSrc;                                                        // Retorna el indice ordenado por texto fuente
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Borra la oración que esta en la posición 'Idx' según el indice actual
- (void) RemoveAt:(int) IdxSrc
  {
  NSString* trd    = [self GetTrdTextAt:IdxSrc];                        // Obtiene el texto traducido para la oración
  NSNumber* IdxNum = IdxsSrc[ IdxSrc ];
  int       IdxOra = IdxNum.intValue;                                   // Obtiene el indice a la oración buscada
 
  [self DeleteIndex:IdxOra WithText:trd InIndex:IdxsDes];               // Borra el indice a la oración destino
  [IdxsSrc removeObjectAtIndex:IdxSrc];                                 // Borra el indice a la oración fuente
    
  [ItemsDeleted addObject:IdxNum ];                                     // Pone en la lista de borradas para se reuso
  
  [self Save];                                                          // Guarda el contenido del fichero
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Agrega una oracion con texto txtSrc y traducción txtTrd (El idioma fuente y traducido se toma según SetNowLang)
- (int) AddSrcText:(NSString*) txtSrc TrdText:(NSString*) txtTrd
  {
  int IdxSrc, IdxDes;
  BOOL found = [self Find:txtSrc InIndex:IdxsSrc ReturnIdx:&IdxSrc];    // Busca la oración original
  
  if( found )                                                           // Ya esta, solo hay que modificarlo
    {
    int IdxOra = ((NSNumber*)IdxsSrc[IdxSrc]).intValue;                 // Obtiene el indice a la oración buscada
    Sentence* Ora = Items[IdxOra];                                      // Obtiene la oración
    
    NSString* trd = [self TextOfSentence:Ora ForLang:lngDes];           // Obtiene texto traducido de la oración
    if( [trd isEqualToString:txtTrd] ) return IdxSrc;                   // Si es el mismo, no hay que modificar nada, termina
    
    [self DeleteIndex:IdxOra WithText:trd InIndex:IdxsDes];             // Borra el indice a la traducción que se va a modificar
    
    found = [self Find:txtTrd InIndex:IdxsDes ReturnIdx:&IdxDes];       // Busca nueva traducción
    if( found )
      NSLog(@"Oración repetida:\r\n    %@\r\n", txtTrd);
    
    NSNumber* idxNum = [NSNumber numberWithInt: IdxOra];                // Encasula el indice a la oración
    [IdxsDes insertObject:idxNum atIndex:(int)IdxDes ];                 // Actualiza el indice de la nueva traducción
    
    [self SetText:txtTrd InSentence:Ora ForLang:lngDes];                // Actualiza traducción de la oración

    [self Save];                                                        // Guarda el contenido del fichero
    return IdxSrc;                                                      // Retorna el indice de la oración modificada
    }
  
  // La oración no se encuentra
  NSString* Text1 = (lngSrc == Lang1)? txtSrc : txtTrd;                 // Determina cual es el texto1
  NSString* Text2 = (lngSrc == Lang1)? txtTrd : txtSrc;                 // Determina cual es el texto2
   
  Sentence* Ora = [Sentence SentenceWithText1:Text1 AndText2:Text2];    // Crea la oración
    
  IdxSrc = [self AddSentence:Ora];                                      // Adiciona la oración y retorna el indice
  
  [self Save];                                                          // Guarda el contenido del fichero
  
  return IdxSrc;                                                        // Retorna el indice de la oración modificada
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si una oración con la misma fuente y destino especificadas existe
- (BOOL) ExistTrdSrc:(NSString*) src Trd:(NSString*) trd
  {
  if( src.length==0 || trd.length==0 ) return FALSE;
  
  int IdxSrc;
  BOOL found = [self Find:src InIndex:IdxsSrc ReturnIdx:&IdxSrc];       // Busca la oración original
  if( !found ) return FALSE;
  
  NSString* Trd = [self GetTrdTextAt:IdxSrc];
    
  return [trd isEqualToString:Trd ];
  }


//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el idioma 'lng' como idioma por defecto si esta entre los idiomas del objeto
- (void) SetNowLang:(int) lng
  {
  if( lng == Lang1 )
    {
    lngSrc = Lang1;
    lngDes = Lang2;
    
    IdxsSrc = Indexes1;
    IdxsDes = Indexes2;
    }
  else if( lng== Lang2 )
    {
    lngSrc =  Lang2;
    lngDes =  Lang1;
    
    IdxsSrc = Indexes2;
    IdxsDes = Indexes1;
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el nombre del fichero de oraciones, desde el directorio de documentos o desde a aplicación
- (NSString*) FNameFromDoc:(BOOL) doc
  {
  static NSString* SentSufixes[LGCount][LGCount] =
    {
    //        Es   ,   En   ,   It   , De  ,   Fr
    /*Es*/{ @""    , @"EnEs", @"EsIt", @"" , @"EsFr" },
    /*En*/{ @"EnEs", @""    , @"EnIt", @"" , @"EnFr" },
    /*It*/{ @"EsIt", @"EnIt", @""    , @"" , @"ItFr" },
    /*De*/{ @""    , @""    , @""    , @"" , @""     },
    /*Fr*/{ @"EsFr", @"EnFr", @"ItFr", @"" , @""     }
    };


  NSString *Path, *FName;
  if( doc)
    {
    NSString* Sufix = SentSufixes[Lang1][Lang2];
    NSString* Name  = [@"Sentences" stringByAppendingString:Sufix];
    
    FName = [Name stringByAppendingString:@".txt"];
    
    NSFileManager *fMng = [[NSFileManager alloc] init];                 // Crea objeto para manejo de ficheros
  
    NSURL *url =[fMng URLForDirectory:NSDocumentDirectory               // Le pide el directorio de los documentos
                             inDomain:NSUserDomainMask
                    appropriateForURL:nil
                               create:YES
                                error:nil];
  
    Path = [url path];
    }
  else
    {
    FName = @"Sentences.txt";
    Path = [[NSBundle mainBundle] bundlePath];
    }

  return [Path stringByAppendingPathComponent:FName];
  }

#define FindOpt    (NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
//---------------------------------------------------------------------------------------------------------------------------
// Busca una oración, se
-(BOOL) Find:(NSString*) sKey InIndex:(NSArray*) Array  ReturnIdx:(int*) Idx
		{
		NSComparisonResult ret = 0;                                         // Resultado de la comparación
    int nRec = (int)Array.count;                                        // Número de llaves en el indice
    
		// metodo tradicional de busqueda binaria
		int lo = 0;                                                         // Indice inferior de la busqueda
		int hi = nRec-1;                                                    // Indice superior de la busqueda
		int mid = 0;                                                        // Indice en el medio del rengo de busqueda

		while( lo <= hi )                                                   // Mientras que exista un rango de busqueda valido
			{
			mid = (lo + hi) >> 1;                                             // Tome el elemento que esta en el medio del rango

      NSNumber* iVal = Array[ mid ];
      Sentence* Ora = Items[iVal.intValue];
      
      NSString* Key = (Array==Indexes1)? Ora.Text1 : Ora.Text2;
      
      ret = [sKey compare:Key options:FindOpt];                         // Compara la llave buscada con la actual

			if( ret == NSOrderedAscending )                                   // La llave actual tiene un orden superior a la buscada
				hi = mid - 1;                                                   // Pone limite superior de la busqueda, a la llave anterior a la actual
			else if( ret == NSOrderedDescending )                             // La llave actual tiene un orden inferior a la buscada
				lo = mid + 1;                                                   // Pone limite inferor de la busqueda, a la llave que le sigue a la actual
			else                                                              // La dos llaves son iguales
				{
				*Idx = mid;                                                     // Retorna el indice a la llave encontrada
				return TRUE;                                                    // Retorna verdadero
				}
			}

    // La llave no fue encontrada
		if( ret == NSOrderedDescending && mid < nRec )                      // Si la llave buscada debia tener un orden supperior y no es la ultima
			mid++;                                                            // Retorna la llave siquiente

		*Idx = mid;                                                         // Actualiza el indice donde deberia esta ubicada la llave
			
		return FALSE;                                                       // Retorna que no la encontro
		}

//---------------------------------------------------------------------------------------------------------------------------
// Borra el indice a al elemento 'Idx' del arreglo de oraciones, que tiene el texto sKey en el indice 'Array'
-(BOOL) DeleteIndex:(int) IdxItem WithText:(NSString*) sKey InIndex:(NSMutableArray*) Array
  {
  int retIdx;
  BOOL found = [self Find:sKey InIndex:Array ReturnIdx:&retIdx];        // Busca cadena cuyo indice se quiere borrar
  if( !found ) return TRUE;                                             // No encuentra, nada que hacer, termina
  
  int delIdx = -1;                                                      // Indice a borrar
  
  int Idx = ((NSNumber*)Array[ retIdx ]).intValue;                      // Obtiene el indice a la oracion
  if( IdxItem == Idx )                                                  // Si igual al que se esta buscando
    delIdx = retIdx;                                                    // Pone indice a borrar
  
  if( delIdx == -1 )                                                                          // No se ha encontrado
    delIdx = [self FindIndex:IdxItem WithText:sKey InIndex:Array From:retIdx+1 WithInc:1];    // Busca hacia alante
    
  if( delIdx == -1 )                                                                          // No se ha encontrado
    delIdx = [self FindIndex:IdxItem WithText:sKey InIndex:Array From:retIdx-1 WithInc:-1];   // Busca hacia atras
 
  if( delIdx != -1 )                                                    // Se ha encontrado el incice
    {
    [Array removeObjectAtIndex:delIdx];                                 // Lo borra
    return TRUE;                                                        // Retorna Ok
    }
    
  return FALSE;                                                         // No se puedo borrar el indice
  }

//---------------------------------------------------------------------------------------------------------------------------
// Busca por todas las oraciones iguales la que tiene el indice 'IdxItem' y el texto 'sKey'
-(int) FindIndex:(int) IdxItem WithText:(NSString*) sKey InIndex:(NSMutableArray*) Array From:(int) IdxIni WithInc:(int) dt
  {
  for( int i=IdxIni; i>=0 && i<Array.count; i += dt )
    {
    int Idx = ((NSNumber*)Array[i]).intValue;
    Sentence* Ora = Items[Idx];
    
    NSString* Key = (Array==Indexes1)? Ora.Text1 : Ora.Text2;
    
    NSComparisonResult ret = [sKey compare:Key options:FindOpt];        // Compara la llave buscada con la actual
    if( ret != NSOrderedSame ) break;
    
    if( IdxItem == Idx ) return i;
    }
    
  return -1;
  }
    
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Retorna el texto para el idioma solicitado
- (NSString*) TextOfSentence:(Sentence*) Ora ForLang:(int) lng
  {
  NSString* txt = (lng==Lang1)? Ora.Text1 : Ora.Text2;
  
  unichar c = [txt characterAtIndex:txt.length-1];
  
  if( c=='<' )                                      // Si termina con brake abierto
    {
    txt = [txt substringToIndex:txt.length-1];      // Quita el brake del final
    txt = [@"<" stringByAppendingString:txt ];      // Se lo agrega al principio
    
    c = [txt characterAtIndex:txt.length-1];        // Actualiza el último caracter
    }
  
  if( lng==0 && (c=='?' || c=='!') )                  // Si es español y termina con interrogación o exclamación
    txt = [self BalanceSigno:c InText: txt];
  
  return txt;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca que el caracter c este balanceado, si no lo esta lo adiciona al principio
- (NSString*)  BalanceSigno:(unichar)cEnd InText:(NSString*) txt
  {
  NSString* sFind = (cEnd=='?')? @"¿?" : @"¡!";
  
  NSCharacterSet* chars = [NSCharacterSet characterSetWithCharactersInString:sFind];
  
  NSRange fRg = NSMakeRange(0, txt.length);
  int nIni  = 0;
  int nEnd  = 0;
  for(;;)
    {
    NSRange rg = [txt rangeOfCharacterFromSet:chars options:NSLiteralSearch range:fRg ];
    if( rg.length == 0 ) break;
    
    int   idx = (int)rg.location;
    unichar c = [txt characterAtIndex:idx];
    
    if( c==cEnd ) ++nEnd; else ++nIni;
    
    ++idx;
    fRg = NSMakeRange( idx, txt.length-idx );
    }
    
  if( nEnd > nIni )
    {
    NSString* sIni  = (cEnd=='?')? @"¿"  : @"¡";
    txt =[sIni stringByAppendingString:txt ];
    }
  
  return txt;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el texto para el idioma solicitado
- (void) SetText:(NSString*) txt InSentence:(Sentence*) Ora ForLang:(int) lng
  {
  if( lng == Lang1 ) Ora.Text1 = txt;
  else               Ora.Text2 = txt;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtine el indice (orden) de la cadena 'txtSrc' dentro de la lista de oraciones, en el propiedad 'Found' refleja si fue encotrado o no
- (int) IndexForSrcText:(NSString*) txtSrc
  {
  int IdxSrc;
  _Found = [self Find:txtSrc InIndex:IdxsSrc ReturnIdx:&IdxSrc];        // Busca la oración original
  
  return IdxSrc;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el texto fuente para de la oración con indice 'IdxSrc'
- (NSString*) GetSrcTextAt:(int) Idx
  {
  int IdxItem = ((NSNumber*)IdxsSrc[Idx]).intValue;
  Sentence* Ora = Items[IdxItem];
  
  return [self TextOfSentence:Ora ForLang:lngSrc];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el texto traducido para de la oración con indice 'IdxTrd'
- (NSString*) GetTrdTextAt:(int) Idx
  {
  int IdxItem = ((NSNumber*)IdxsSrc[Idx]).intValue;
  Sentence* Ora = Items[IdxItem];
  
  return [self TextOfSentence:Ora ForLang:lngDes];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el objeto oración con indice 'Idx'
- (Sentence*) GetSentenceAt:(int) Idx
  {
  int IdxItem = ((NSNumber*)IdxsSrc[Idx]).intValue;
  return ( Items[IdxItem] );
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Sobrescribe la propiedad para obtener el número de elementos
- (int) Count   { return (int) IdxsSrc.count; }
- (int) LangSrc { return lngSrc; }
- (int) LangDes { return lngDes; }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene una historia con todos los Items que contengan a 'txt'
- (Sentences*) FilterByText:(NSString*) txt
  {
  [Sentences InitWithLang1:Lang1 AndLang2:Lang2];
  [NowOras SetNowLang:lngSrc];

  int len1 = (int)txt.length;
  for( int i=0; i<self.Count; ++i )
    {
    NSString* src = [self GetSrcTextAt:i];
    int len2 = (int)src.length;
    
    NSRange rgFind = NSMakeRange(0, len2);                              // Rango de busqueda la cadena completa
    for(;;)                                                             // Repite el proceso
      {
      NSRange rg = [src rangeOfString:txt options:FindOpt range:rgFind];    // Busca la cadena dentro del texto
      if( rg.length==0 ) break;                                         // Pasa a la proxima oración
      
      int ini = (int)rg.location;                                       // Indice al primer caracter encontrado
      int fin = ini + (int)rg.length - 1;                               // Indice al ultimo caracter encontrado
      
      if( (ini==0      || !IsLetter(ini-1, src)) &&                     // Frontera de palabra al inicio
          (fin==len2-1 || !IsLetter(fin+1, src)) )                      // Frontera de palabra al final
        {
        [NowOras AddSentence:[self GetSentenceAt:i] ];                  // Adiciona la oración
        break;                                                          // Pasa a la proxima oración
        }
        
      ++fin;
      if( fin+len1 >= len2 ) break;                                     // No queda espacio para buscar, pasa a la proxima
      
      rgFind = NSMakeRange(fin, len2-fin-1);                            // Crea nuevo rango de busqueda y repite
      }
    
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
    }
    
  return NowOras;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si las oraciones estan filtradas o no
- (BOOL) IsFiltered
  {
  return (  NowOras != LoadedSent[Lang1][Lang2] );
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita el filtro de las oraciones
- (Sentences*) RemoveFilter
  {
  NowOras = LoadedSent[Lang1][Lang2];
  return NowOras;
  }


@end
//=========================================================================================================================================================

//=========================================================================================================================================================
// Implementa el objeto que representa una oración en 2 idiomas
@interface Sentence()
  {
  }

@end

//=========================================================================================================================================================
@implementation Sentence

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea una oración com dos textos
+ (Sentence*) SentenceWithText1:(NSString*) txt1 AndText2:(NSString*) txt2
  {
  Sentence *obj = [Sentence new];
  
  obj.Text1 = txt1;
  obj.Text2 = txt2;
  
  return obj;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea una oracion a partir del indice 'idx' en el arreglo de lineas de texto 'Lines' para los idiomas 'sLng1' y 'sLng1' repertivamente
+ (Sentence*) SentenceFromLines:(NSArray*)Lines Index:(int *)idx sLang1:(NSString*)sLng1 sLang2:(NSString*)sLng2
  {
  int i = *idx;
  NSString *Txt1, *Txt2;
  
  for( ;i<Lines.count; ++i )
    {
    NSString* line = (NSString *)Lines[i];
    if( line.length < 4)                                                // Si no hay trducción o esta vacia
      {
      if( line.length == 0 )                                            // Es una linea de separación
        {
        Txt1 = nil;                                                     // Reinicia texto1
        Txt2 = nil;                                                     // Reinicia texto2
        }
      continue;
      }
    
    NSString* hdr = [line substringToIndex:2];
    
    if( [hdr isEqualToString:sLng1] )
      {
      Txt1 = [line substringFromIndex:3];
      
      if( Txt2 != nil )
        {
        *idx = i+1;
        return [self SentenceWithText1:Txt1 AndText2:Txt2];
        }
        
      continue;
      }

    if( [hdr isEqualToString:sLng2] )
      {
      Txt2 = [line substringFromIndex:3];
      
      if( Txt1 != nil )
        {
        *idx = i+1;
        return [self SentenceWithText1:Txt1 AndText2:Txt2];
        }
        
      continue;
      }
    }
    
  *idx = (int)Lines.count;
  return nil;
  }

@end
//=========================================================================================================================================================


