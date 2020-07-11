//
//  RowHistoryView.m
//  TrdSuite
//
//  Created by Camilo on 19/04/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//

#import "RowHistoryView.h"
#import "AppData.h"
#import "ColAndFont.h"

//=========================================================================================================================================================
@interface RowHistSingleView()
  {
  }
@end

//=========================================================================================================================================================
@implementation RowHistSingleView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
+(RowHistSingleView *) RowWithOraIndex:(int) index Width:(float)w
  {
  TrdItem* Item = [History TrdItemAtIndex:index];
  [Item SetSizeWithWidth:w-10];
  
  CGRect frame = CGRectMake(0, 0, w, Item.Height);
  
  RowHistSingleView* view = [[RowHistSingleView alloc] initWithFrame:frame];
  
  frame.origin.x = 5;
  frame.size.width = w-10;
  
  UILabel* src = [[UILabel alloc] initWithFrame: frame];
  
  src.text             = Item.Text;
  src.autoresizingMask = 0xFF;
  src.numberOfLines    = 0;
  src.font             = fontHistory;
    
  [view addSubview: src];
  
  view.tag   = -1;
  view.backgroundColor = [UIColor whiteColor];
  
  view.Index = index;
  
  return view;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona la fila al cache
- (void) CacheView
  {
//  if( ConjRowCache == nil )
//    ConjRowCache = [[NSMutableArray alloc] initWithCapacity:20];
//  
//  [ConjRowCache addObject: self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================================

//=========================================================================================================================================================
@interface RowHistSelectedView()
  {
  NSArray* Rows;
  }
@end

//=========================================================================================================================================================
@implementation RowHistSelectedView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
+(RowHistSelectedView *) RowWithOraIndex:(int) index Width:(float)w
  {
  RowHistSelectedView* view = [[RowHistSelectedView alloc] init];
  
  view.tag   = -1;
  view.Index = index;
  view->Rows = [History TrdRowsAtIndex:index];
  
  int yPos = 0;
  
  for( int i=0; i<view->Rows.count; ++i )
    {
    int h = [view CreateLabelNum:i YPos:yPos Width:w ];
    yPos += h;
    }
    
  view.frame = CGRectMake(0, 0, w, yPos);
  view.backgroundColor = ColBckSelHistoy1;
    
  return view;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el un label con la información del item de traducción 'idx'
- (int) CreateLabelNum:(int) idx YPos:(int) yPos Width:(float)w
  {
  TrdRow* row = Rows[idx];
   
  int wTxt = w - ((row.Lng==LGSrc)? 10 : 50);
  [row SetSizeWithWidth:wTxt ];

  CGRect frame = CGRectMake( 0, yPos, w, row.Height);
  
  UIView* rowView = [[UIView alloc] initWithFrame: frame];
  rowView.backgroundColor  = (idx%2)? ColBckSelHistoy2 : ColBckSelHistoy1;
   
  CGRect rc = CGRectMake( 5, 0, wTxt, row.Height);
  UILabel* Text = [[UILabel alloc] initWithFrame: rc];
  Text.numberOfLines    = 0;
  Text.font             = fontHistory;
  Text.text             = row.Text;
  
  [rowView  addSubview: Text];
  [self addSubview: rowView];
  
  if( row.Lng!=LGSrc )
   {
   [self CreateFlagLang:row.Lng InView:rowView];
   [self CreateDelRowInView:rowView];
   }
  
  return row.Height;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) CreateFlagLang:(int) Lng InView:(UIView*)rowView
  {
  CGRect frame = CGRectMake( 5, (LineHeight-FLAG_H)/2.0, FLAG_W, FLAG_H);
  
  UIImageView* img = [[UIImageView alloc] initWithFrame: frame];
  img.image   = [UIImage imageNamed: LGFlagFile(Lng,@"30") ];
  
  [rowView addSubview: img];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) CreateDelRowInView:(UIView*)rowView
  {
  float x = rowView.frame.size.width - 45;
  float y = (rowView.frame.size.height - 30) / 2;
  
  CGRect frame = CGRectMake( x, y, 40, 30);
  
  UIImageView* img = [[UIImageView alloc] initWithFrame: frame];
  img.image   = [UIImage imageNamed: @"Delete" ];
  
  [rowView addSubview: img];
  
  rowView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona la fila al cache
// Nota: No implementada, porque estas filas son muy diferentes y solo se usa una en toda la lista
- (void) CacheView
  {
//  if( ConjRowCache == nil )
//    ConjRowCache = [[NSMutableArray alloc] initWithCapacity:20];
//  
//  [ConjRowCache addObject: self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Atienede cuando se toca sobre la fila
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
  {
  VirtualListView* List = (VirtualListView*)self.superview;     // Obtiene la lista que contiene la fila
  CGPoint pnt = [[touches anyObject] locationInView: self];     // Punto que se toco dentro de la fila
  
  for( int i=1; i<Rows.count; ++i )                             // Recorre todas las traduciones
    {
    TrdRow* row = Rows[i];                                      // Toma la traducción actual
    
    UIView* vRow = self.subviews[i];                            // Obtiene la vista de la tradución (fondo de la fila)
    UIView* vTxt = vRow.subviews[0];                            // Obtiene la vista del texto de la traducción
    UIView* vDel = vRow.subviews[2];                            // Obtiene la vista del boton de borrar
    
    CGPoint pnt2 = [self convertPoint:pnt toView:vRow];         // Refiere el punto a la vista de la traducción
    if( CGRectContainsPoint( vDel.frame, pnt2 ) )               // Si esta dentro de boton de borrar
      {
      [List.VirtualListDelegate OnSelectedRow: -(row.Lng+20)];  // Llama a la función que atiende el evento de seleccionar una fila
      return;
      }
    
    if( CGRectContainsPoint( vTxt.frame, pnt2 ) )               // Si esta dentro de boton de borrar
      {
      [List.VirtualListDelegate OnSelectedRow: -(row.Lng+10)];  // Llama a la función que atiende el evento de seleccionar una fila
      return;
      }
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------


@end
//=========================================================================================================================================================

/*
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Calcula el tamaño de la altura de la fila, teniendo en cuenta el texto que se va a mostrar y el ancho disponible
BOOL UpdateRowSize(TrdRow* row, int Width)
  {
  if( row.Width == Width ) return FALSE;
  
  row.Width = Width;
  row.Height = 30;
  
  if( row.TrdTxt.length*14 > Width )
    {
    int wTxt = Width - ((row.Lng==LGSrc)? 10 : 50);
    CGSize  sz = CGSizeMake( wTxt, 5000);
    CGRect rc1 = [row.TrdTxt boundingRectWithSize: sz
                                          options: NSStringDrawingUsesLineFragmentOrigin
                                       attributes: attrDict
                                           context: nil      ];
  
    int hTxt = rc1.size.height + 12.5;
    if( hTxt>30 ) row.Height = hTxt;
    }
  
  return TRUE;
  }
*/

//=========================================================================================================================================================


