//
//  VirtualDictRowView.m
//  PruTranslate
//
//  Created by Camilo on 19/03/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//

#import "VirtualDictRowView.h"
#import "ProxyDict.h"
#import "AppData.h"
#import "ColAndFont.h"

//=========================================================================================================================================================
static NSMutableArray *DictRowCache;                               // Filas que se usan en la zona visual

//=========================================================================================================================================================
@implementation VirtualDictRowView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea una fila con una cadena con atributos, el ancho de la fila y el indice
+(VirtualDictRowView *) RowWithIndex:(int)iRow Width:(float)w Select:(BOOL) sel
  {
  NSAttributedString* WordData = [ProxyDict getWDataFromIndex:iRow NoKey:FALSE];  // Obtine los datos de la llave en una cadena formateada
  
  // Determina el rectangulo que ocupan los datos, fijando el ancho disponible
  CGSize sz = CGSizeMake( w-10, 10000 );
  CGRect rc1 = [WordData boundingRectWithSize:sz options:NSStringDrawingUsesLineFragmentOrigin context:nil];
  
  int h = (int)(rc1.size.height + 12);                                  // Determina la altura de la fila
  
  CGRect frame = CGRectMake(0, 0, w, h);                                // Crea un frame para la fila
  
  VirtualDictRowView* view;
  
  if( DictRowCache && DictRowCache.count>0 )                            // Si el cache existe y hay al menos una fila
    {
    view = [DictRowCache lastObject];                                   // Toma la ultima fila del cache
    [DictRowCache removeLastObject];                                    // La quita del cache
    
    view.frame = frame;                                                 // Actualiza el tamaño
    }
  else                                                                  // Si no hay filas en el cache
    {
    view = [[VirtualDictRowView alloc] initWithFrame:frame];            // Crea una fila nueva con el tamaño calculado
  
    frame.origin.x = 5;                                                 // Deja 5 puntos por delante
    frame.size.width = w-10;                                            // Deja 5 puntos por detras
    
    view.Text = [[UILabel alloc] initWithFrame:frame];                  // Crea un label separado 5 puntos de los bordes
    
    view.Text.autoresizingMask = UIViewAutoresizingFlexibleWidth |      // Lo configura para que se redimensione en todas las direcciones
                                 UIViewAutoresizingFlexibleHeight;
      
    view.Text.numberOfLines  = 0;                                       // Para que puede tener culquier número de lineas de tecto
  
    [view addSubview:view.Text];                                        // Adiciona el lavel a la fila
    view.tag   = -1;                                                    // Marca la fila con -1
    }
    
  view.backgroundColor = sel? ColCellBckSel : ColCellBck;               // Pone color del fondo
  view.Text.attributedText  = WordData;                                 // Pone el texto
  view.Index = iRow;                                                    // Pone el indice de la fila en la lista
  
  return view;                                                          // Retorna la lista
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona la fila al cache
- (void) CacheView
  {
  if( DictRowCache == nil )                                             // Si no se ha creado el cache
    DictRowCache = [[NSMutableArray alloc] initWithCapacity:35];        // Lo crea con capacidad para 35 filas
  
  [DictRowCache addObject: self];                                       // Adiciona la fila en el cache
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------


@end
