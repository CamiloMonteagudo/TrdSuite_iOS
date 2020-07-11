//
//  TrdHistory.m
//  PruTranslate
//
//  Created by Camilo on 14/01/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//

#import "TrdHistory.h"
#import "AppData.h"
#import "ColAndFont.h"

//=========================================================================================================================================================
// Implementa una lista de oraciones con sus traducciones en varios idiomas
@interface TrdHistory()
  {
  NSMutableArray* Items;
  }

@end

//=========================================================================================================================================================
@implementation TrdHistory

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea una historia de traducciones vacia
+ (TrdHistory*) HistoryWithSrc:(int) src
  {
  TrdHistory* history = [TrdHistory new];
  
  history->Items = [NSMutableArray new];
  history->_Src = src;
  
  return history;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga la historia de las aplicaciones desde un fichero de texto
+ (TrdHistory*) LoadWithSrc:(int) src
  {
  TrdHistory* history = [TrdHistory HistoryWithSrc:src];
  
  NSString *path = [TrdHistory FileWithSrc:src];
  
  if( [[[NSFileManager alloc] init] fileExistsAtPath:path] )
    [history LoadFromPath:path];
  else
    [history FillFromApp];
  
  return history;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga el contenido del fichero especificado en 'path' para la historia
- (BOOL) LoadFromPath:(NSString *) path
  {
  NSStringEncoding Enc;
  NSError          *Err;
  
  NSString *Txt = [NSString stringWithContentsOfFile:path usedEncoding:&Enc error:&Err];
  if( Txt == nil ) return FALSE;
  
  NSArray*  Lines = [Txt componentsSeparatedByString:@"|\n"];
  NSString* sLang = LGAbrv(_Src);
    
  for( int i=0; i<Lines.count-1; )
    {
    TrdItem* Item = [TrdItem ItemFromLines:Lines Index:&i sLang:sLang];
    if( Item!=nil )
      [Items addObject:Item];
    }
    
  return TRUE;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el camino el fichero que guarda las traduciones realizadas
+ (NSString *) FileWithSrc:(int) src
  {
  NSFileManager *fMng = [[NSFileManager alloc] init];                             // Crea objeto para manejo de ficheros
  
  NSURL *url =[fMng URLForDirectory:NSDocumentDirectory                           // Le pide el directorio de los documentos
                           inDomain:NSUserDomainMask 
                  appropriateForURL:nil 
                             create:YES 
                              error:nil];
  
  NSString* FileName = [NSString stringWithFormat:@"History%@.txt", LGAbrv(src) ];  // Obtiene el nombre del fichero
  return [[url path] stringByAppendingPathComponent:FileName];                      // Une el directorio con el nombre del fichero
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Guarda la hostoria de las traduciones realizadas hacia un fichero de texto
- (BOOL) Save
  {
  if( Items.count==0 ) return FALSE;
  
  NSMutableString* Txt = [NSMutableString stringWithCapacity:80*Items.count];
  
  NSString* sLang = LGAbrv(_Src);
  for( int i=0; i<Items.count; ++i )
    [((TrdItem*)Items[i]) SaveToText:Txt sLang:sLang];
  
  NSString *path = [TrdHistory FileWithSrc:_Src];
  
  NSError *Err;
  BOOL ret = [Txt writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&Err];
  
  return ret;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (int)Count
  {
  return (int)Items.count;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si en la historia existe una traducción de la fuente 'src' para el idioma 'lng' que se igual a 'trd'
- (BOOL) ExistTrdSrc:(NSString*) src Trd:(NSString*) trd ToLang:(int) lng
  {
  if( src.length==0 || trd.length==0 ) return FALSE;
  
  int idx;
  if( ![self BSearchKey:src Index:&idx] )
    {
    if( idx>0 ) --idx;
    return FALSE;
    }
    
  TrdItem* Item = Items[idx];
  NSString* Trd = [Item GetTrdWithLang:lng];
    
  return [trd isEqualToString:Trd ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene una historia con todos los Items que contengan a 'txt'
- (TrdHistory*) FilterByText:(NSString*) txt
  {
  TrdHistory* hist = [TrdHistory new];
  
  hist->Items = [NSMutableArray new];
  hist->_Src = History.Src;
  
  int len1 = (int)txt.length;
  for (TrdItem* Trd in Items)
    {
    NSString* src = Trd.Text;
    int len2 = (int)src.length;
    
    NSRange rgFind = NSMakeRange(0, len2);                                  // Rango de busqueda la cadena completa
    for(;;)                                                                 // Repite el proceso
      {
      NSRange rg = [src rangeOfString:txt options:FindOpt range:rgFind];    // Busca la cadena dentro del texto
      if( rg.length==0 ) break;                                             // Pasa a la proxima oración
      
      int ini = (int)rg.location;                                           // Indice al primer caracter encontrado
      int fin = ini + (int)rg.length - 1;                                   // Indice al ultimo caracter encontrado
      
      if( (ini==0      || !IsLetter(ini-1, src)) &&                         // Frontera de palabra al inicio
          (fin==len2-1 || !IsLetter(fin+1, src)) )                          // Frontera de palabra al final
        {
        [hist->Items addObject:Trd];                                        // Adiciona la oración
        break;                                                              // Pasa a la proxima oración
        }
        
      ++fin;
      if( fin+len1 >= len2 ) break;                                         // No queda espacio para buscar, pasa a la proxima
      
      rgFind = NSMakeRange(fin, len2-fin-1);                                // Crea nuevo rango de busqueda y repite
      }
    
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
    }
    
  return hist;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona una traducción a la historia de traducciones y retorna su indice
// Si retorna -1 no hizo nada, si Found=true modifico una oración que ya existia
- (int) AddTrdSrc:(NSString*) src Trd:(NSString*) trd TrdLang:(int) lng
  {
  _Found = false;
  if( src.length==0 || trd.length==0 ) return -1;
  
  int idx;
  if( [self BSearchKey:src Index:&idx] )
    {
    _Found = true;
    TrdItem* Item = Items[idx];
    NSString* Trd = [Item GetTrdWithLang:lng];
    
    if( [trd isEqualToString:Trd ] ) return -1;
    
    [Item SetTrd:trd ToLang:lng];
    return idx;
    }
  
  TrdItem* Item = [TrdItem ItemWithSrc:src];
  [Item SetTrd:trd ToLang:lng];
  
  [Items insertObject:Item atIndex:idx];
  
  return idx;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca el Item en la historia y lo acatualiza si existe, sino lo adicona.
- (int) UpadateWithItem:(TrdItem*) Item
  {
  if( Item.Text == nil ) return -1;
  
  int idx;
  if( [self BSearchKey:Item.Text Index:&idx] )
    {
    TrdItem* Item = Items[idx];
    [Item UpdateWithItem:Item];
    return idx;
    }
  
  [Items insertObject:Item atIndex:idx];
  
  return idx;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca una traducción en la lista y retorna el indice, si no la encuentra Found=false y el indice es la mas cercana
- (int) FindTrdSrc:(NSString*) src
  {
  _Found = false;
  if( src==nil || src.length==0 || Items.count==0) return -1;
  
  int idx;
  _Found = [self BSearchKey:src Index:&idx];
  
  if( !_Found && idx>0 ) --idx;

  return idx;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la traducción con el indice idx
- (TrdItem*) TrdItemAtIndex:(int) idx
  {
  return Items[idx];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita la informacion del tamaño a todos los items que esten en la lista
- (void) ClearItemsHeight
  {
  for( int i=0; i<Items.count; ++i )
    {
    TrdItem* item = Items[i];
  
    item.Height = 0;
    item.Width  = 0;
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene un arreglo con la cadena original y todas sus traduciones
- (NSArray*) TrdRowsAtIndex:(int) idx
  {
  TrdItem* item = Items[idx];
    
  NSMutableArray* rows = [NSMutableArray arrayWithCapacity:4];
  
  [rows addObject:[TrdRow RowWithText: item.Text Lang:_Src] ];
  
  for( int i=0; i<4; ++i )
    {
    if( i==_Src ) continue;
    
    NSString* Txt = [item GetTrdIdx:i];
    if( Txt!= nil )
      {
      int lng = (i==3)? 4 : i;
      
      Txt = [FlagSpaces stringByAppendingString: Txt ];
      [rows addObject:[TrdRow RowWithText: Txt Lang:lng] ];
      }
    }
  
  return rows;
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Borra la traducción con el indice idx
- (void) RemoveTrdItemAtIndex:(int) idx
  {
  [Items removeObjectAtIndex:idx];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la traducción con el indice idx
- (TrdItem*) FindTrdItemSrc:(NSString*) src
  {
  int idx;
  if( ![self BSearchKey:src Index:&idx] )
    {
    if( idx>0 ) --idx;
    }
  
  return Items[idx];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la traducción con el indice idx
- (int) FindIndexSrc:(NSString*) src
  {
  int idx;
  if( [self BSearchKey:src Index:&idx] )
    return idx;
    
  return -1;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Realiza una busqueda binaria
-(BOOL) BSearchKey:(NSString*) sKey  Index:(int*) Idx
  {
  int  num = (int)Items.count;

  int   lo   = 0;
  int   hi   = num - 1;
  int   mid   = 0;
  int   half, ret;

  while( lo <= hi )
    if( (half = num/2) )
      {
      mid = lo + (num & 1 ? half : (half - 1));

      NSString* Key = ((TrdItem*)Items[mid]).Text;

      ret = (int)[sKey caseInsensitiveCompare: Key ];

      if( ret==0 )
        {
        *Idx = mid;
        return TRUE;
        }
      else if( ret<0 )
        {
        hi = mid - 1;
        num = num & 1 ? half : half-1;
        }
      else
        {
        lo = mid + 1;
        num = half;
        }
      }
    else if( num )
      {
      NSString* Key = ((TrdItem*)Items[lo]).Text;

      ret = (int)[sKey caseInsensitiveCompare: Key ];
      
      *Idx = ( ret<=0 )? lo : lo+1;

      return( ret==0 );
      }
    else
      break;

  *Idx = mid;
  return FALSE;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Crea una historia basada en los datos que vienen con la aplicación
- (void) FillFromApp
  {
  NSString* exePath = [[NSBundle mainBundle] bundlePath];
  
  for( int i=0; i<5; ++i )
    {
    if( i==_Src || i==3 ) continue;
    
    NSString *FName = [NSString stringWithFormat:@"History%@-%@.txt", LGAbrv(_Src), LGAbrv(i) ];
    
    NSString *histPath = [exePath stringByAppendingPathComponent: FName];
    
    TrdHistory* history = [TrdHistory HistoryWithSrc:_Src];
  
    [history LoadFromPath:histPath];
    
    for( int j=0; j<history.Count; ++j )
      {
      TrdItem* Item = [history TrdItemAtIndex:j];
      
      [self UpadateWithItem: Item];
      }
    }

  [self Save];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end

//=========================================================================================================================================================
// Implementa una objeto para cada una de las traduciones de la lista de traducciones
@interface TrdItem()
  {
  NSString* Trds[4];
  }
@end

@implementation TrdItem

//--------------------------------------------------------------------------------------------------------------------------------------------------------
+ (TrdItem*) ItemWithSrc:(NSString*) src
  {
  TrdItem* Item = [TrdItem new];
  if( !Item ) return nil;
  
  Item.Text = src;
  Item.Width  = (int)src.length * 14;
  Item.Height = 30;
  
  return Item;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un Item de traducción a partir de lineas de texto, comenzando con el indice 'idx' y corriendo el mismo hasta la ultima linea analizada
+ (TrdItem*) ItemFromLines:(NSArray*)Lines Index:(int *)idx sLang:(NSString*)sLang
  {
  int i = *idx;
  NSString* srcLng = (NSString *)Lines[i++];
  if( ![sLang isEqualToString:srcLng] )
    {
    NSLog(@"Historia: Se esperaba el Idioma fuente, Ignorado:\n       %@", srcLng);
    
    *idx = i;
    return nil;
    }
  
  NSString* sSrc = (NSString *)Lines[i++];
  TrdItem* Item = [TrdItem ItemWithSrc:sSrc];
  
  int nTrds = 0;
  while( i<=Lines.count-2 )
    {
    NSString* desLng = (NSString *)Lines[i];
    if( [desLng isEqualToString:srcLng] ) break;
    
    ++i;
    
    int idx = -1;
    
         if( [desLng isEqualToString:@"Es"] ) idx = 0;
    else if( [desLng isEqualToString:@"En"] ) idx = 1;
    else if( [desLng isEqualToString:@"It"] ) idx = 2;
    else if( [desLng isEqualToString:@"Fr"] ) idx = 3;
    else
      {
      NSLog(@"Historia: Se esperaba el Idioma Destino, Ignorado:\n       %@", desLng);
      break;
      }
      
    Item->Trds[idx] = (NSString *)Lines[i++];
    
    ++nTrds;
    }
    
  *idx = i;
  
  if( nTrds==0 ) return nil;
  
  return Item;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Guarda del contenido del item hacia un texto
- (void) SaveToText:(NSMutableString*)SaveText sLang:(NSString*)sLang
  {
  NSMutableString* txtItem = [NSMutableString stringWithFormat:@"%@|\n%@|\n", sLang, self.Text];
  int len = (int)txtItem.length;
  
  if( Trds[0]!= nil ) [txtItem appendFormat:@"Es|\n%@|\n", Trds[0] ];
  if( Trds[1]!= nil ) [txtItem appendFormat:@"En|\n%@|\n", Trds[1] ];
  if( Trds[2]!= nil ) [txtItem appendFormat:@"It|\n%@|\n", Trds[2] ];
  if( Trds[3]!= nil ) [txtItem appendFormat:@"Fr|\n%@|\n", Trds[3] ];
  
  if( len == txtItem.length )
    {
    NSLog(@"Historia: No guardo el item porque no hay ninguna traducción");
    return;
    }
  
  [SaveText appendString:txtItem];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) SetTrd:(NSString*) trd ToLang:(int) lng
  {
  if( lng==3 ) return;
  if( lng>3  ) --lng;
  
  if(lng<0 || lng>3) return;
  
  Trds[lng] = trd;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString*) GetTrdWithLang:(int) lng
  {
  if( lng==3 ) return nil;
  if( lng>3  ) --lng;
  
  if(lng<0 || lng>3) return nil;
  
  return Trds[lng];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString*) GetTrdIdx:(int) idx
  {
  return Trds[idx];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL) IsNoTrds
  {
  return (Trds[0]==nil && Trds[1]==nil && Trds[2]==nil && Trds[3]==nil );
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza el item actual, cono las traducciones definidas en Item que se pasa.
- (void) UpdateWithItem:(TrdItem*) Item
  {
  for( int i=0; i<4; ++i )
    {
    NSString* sTrd = [Item GetTrdIdx:i];
    if( sTrd != nil )
      Trds[i] = sTrd;
    }
  }


//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end

//=========================================================================================================================================================
// Implementa un objeto para manejar una traduccuón especifica de un item de la lista de traducciones
@implementation TrdRow

+ (TrdRow*) RowWithText:(NSString*) Txt Lang:(int) lang
  {
  TrdRow* Row = [TrdRow new];
  
  Row.Text = Txt;
  Row.Lng  = lang;
  
  return Row;
  }

@end

//=========================================================================================================================================================
@implementation LabelText

//--------------------------------------------------------------------------------------------------------------------------------------------------------
-(BOOL) SetSizeWithWidth:(int) Width
  {
  if( _Width == Width ) return FALSE;
  
  _Width  = Width;
  _Height = LineHeight;
  
  if( _Text.length*FontSize > Width )
    {
    CGSize  sz = CGSizeMake( Width, 5000);
    CGRect rc1 = [_Text boundingRectWithSize: sz
                                     options: NSStringDrawingUsesLineFragmentOrigin
                                  attributes: attrHistory
                                     context: nil      ];
  
    int hTxt = rc1.size.height + FontSize-1;
    if( hTxt>LineHeight ) _Height = hTxt;

    if( _Height > 3*FontSize )
      _Height = 3*FontSize;
    }
  
  return TRUE;
  }

@end

//=========================================================================================================================================================


