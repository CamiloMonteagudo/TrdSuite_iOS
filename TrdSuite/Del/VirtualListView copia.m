//
//  VirtualListView.m
//  PruScroll
//
//  Created by Camilo on 19/02/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//

#import "VirtualListView.h"

#define RowSep  0.5               // Separación entre las filas de la lista

//=========================================================================================================================================================
@interface VirtualListView ()
  {
  float lastWidth;
  
  float YIni;
  float YFin;
  }
@end

//=========================================================================================================================================================
@implementation VirtualListView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];
  if( !self ) return nil;

  _MinHeight = 30;
  _SelectedIndex = -1;
  
  self.bounces = YES;
  
  self.alwaysBounceVertical   = YES;
  self.alwaysBounceHorizontal = NO;
  
  self.showsHorizontalScrollIndicator = NO;
  self.showsVerticalScrollIndicator   = YES;
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cambia la cantidad de elementos de la lista
- (void)setCount:(int)Count
  {
  _Count = Count;
  _SelectedIndex = -1;
  YIni = -1;
  YFin = -1;

  lastWidth = self.bounds.size.width;
  
  self.contentSize = CGSizeMake(lastWidth, (_MinHeight+RowSep) * Count );
  self.contentOffset = CGPointMake(0, 0);                 // Pone la lista en el origen
  
  [self ClearRowsView ];                                  // Borra todas las filas que habia anteriormente
  [self setNeedsLayout];                                  // Muestra las filas según los datos nuevos
  [self layoutIfNeeded];                                  // Hace los cambios inmediatamente
  
  if( Count>0 )                                           // Si haya elementos en la lista
    self.backgroundColor = [UIColor lightGrayColor];      // Pone el fondo gris
  else                                                    // La lista esta vacia
    self.backgroundColor = [UIColor whiteColor];          // Pone el fondo blanco
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza los datos de la lista, cuando cambie el número de filas, o otro evento que necesite actualizar el contenido completo de la lista
- (void)UpdateCount:(int)Count
  {
  _Count = Count;                                         // Reasigna el número de filas de la lista
  
  [self ClearRowsView ];                                  // Borra todas las filas que habia anteriormente
  [self setNeedsLayout];                                  // Muestra las filas según los datos nuevos
  [self layoutIfNeeded];                                  // Hace los cambios inmediatamente
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setMinHeight:(int)MinHeight
  {
  _MinHeight = MinHeight;
  }

- (CGSize)sizeThatFits:(CGSize)size
  {
  return size;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
  {
  if( lastWidth != self.bounds.size.width )
    {
    lastWidth = self.bounds.size.width;
    self.contentSize = CGSizeMake(lastWidth, (_MinHeight+RowSep) * _Count );
    
    for( int i=0; i<self.subviews.count; ++i )
      {
      UIView* view = self.subviews[i];
      if(view.tag != -1 ) continue;
    
      VirtualRowView* vRow = (VirtualRowView*)view;
      [vRow ResizeWidth:lastWidth];
      }
    }
  
  if( _VirtualListDelegate==nil ) return;
  
  [self UpdateVisiblesRows];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone la fila 'iRow' como la seleccionada
- (void)setSelectedIndex:(int)iRow
  {
  int old = _SelectedIndex;                                         // Guarda la seleccion actual
  _SelectedIndex = iRow;                                            // Pone selecciono nueva
  
  if( _VirtualListDelegate==nil ) return;                           // No hace nada si no hay delegado

  if( old >=0 )                                                     // Si habia una seleccion anteriormente
    {
    int Idx = [self FindRowIndex: old ];                            // Busca si la fila seleccioada esta entre las actuales
    if( Idx >= 0 )                                                  // Si esta
      [self ChangeSubView:Idx At:old];                              // Manda a cambiar la fila para quitar la seleccion
    }
  
  if( iRow >=0 )                                                    // Si se establecio una nueva selección
    {
    int Idx = [self FindRowIndex: iRow ];                           // Busca si la fila a seleccinar esta entre las actuales
    if( Idx >= 0 )                                                  // Si esta entre las actuales
      [self ChangeSubView:Idx At:iRow];                             // La manda a refresca para que refleje la selección
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Si la fila 'iRow' es visible devuelve la vista que la representa, si no es visible retorna nil
-(VirtualRowView*) GetVisualRow:(int) iRow
  {
  int Idx = [self FindRowIndex: iRow ];
  if( Idx < 0 ) return nil;
  
  return self.subviews[Idx];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambia la vista de la fila en 'iRow' por la nueva solicitada al delegado
-(void) ChangeRow:(int) iRow
  {
  if( _VirtualListDelegate==nil ) return;
  
  int Idx = [self FindRowIndex: iRow ];
  if( Idx < 0 ) return;
  
  [self ChangeSubView:Idx At:iRow];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambia la vista de la fila en 'iRow' por la nueva solicitada al delegado
-(void) ChangeSubView:(int) Idx At:(int) iRow
  {
  VirtualRowView* nowRow = self.subviews[Idx];
  
  float YPos = nowRow.frame.origin.y;
  
  [nowRow CacheView];
  [nowRow removeFromSuperview];
  
  nowRow = [_VirtualListDelegate GetRowViewAt:iRow];
  
  CGRect rc = nowRow.frame;
  rc.origin.y = YPos;
  nowRow.frame = rc;
  
  [self insertSubview:nowRow atIndex:Idx ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Asegura que la fila iRow sea completamente visible
-(void) SetVisibleRow:(int) iRow
  {
  float    topOff = self.contentOffset.y;
  float buttomOff = topOff + self.bounds.size.height;
  float    newOff;
  
  if( iRow<0 )
    {
    self.contentOffset = CGPointMake(0, 0 );
    return;
    }
    
  if( iRow >= _Count )
    {
    newOff = self.contentSize.height - self.bounds.size.height;
    self.contentOffset = CGPointMake(0, newOff );
    return;
    }
    
  int Idx = [self FindRowIndex: iRow ];
  if( Idx >= 0 )
    {
    VirtualRowView* rowView = self.subviews[Idx];
    
    float y1 = rowView.frame.origin.y;
    float y2 = y1 + rowView.frame.size.height;
    
    if( y1>=topOff && y2<=buttomOff ) return;
    
    if( y1<topOff ) newOff = iRow * (_MinHeight+RowSep);
    else            newOff = topOff + y2 - buttomOff;
    }
  else
    {
    newOff = iRow * (_MinHeight+RowSep);
    
    if( newOff>topOff )
      {
      float H = [_VirtualListDelegate GetHeightRowAt:iRow] + RowSep;
      
      while( iRow>0 && H < self.bounds.size.height )                      // Mientras haya filas y este en zona visible
        {
        --iRow;                                                           // Toma la proxima fila
        H += (RowSep + [_VirtualListDelegate GetHeightRowAt:iRow]);
        }
        
      newOff = iRow * (_MinHeight+RowSep) + (H - self.bounds.size.height);
      }
    }
  
  self.contentOffset = CGPointMake(0, newOff );
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Selecciona la fila 'iRow' y la pone en la parte de arriba de la lista
-(void) SelectAtTopRow:(int) iRow
  {
  _SelectedIndex = iRow;
  
  if( iRow<0 || iRow >= _Count ) return;
  
  self.contentOffset = CGPointMake(0, iRow * (_MinHeight+RowSep) );
  }

////--------------------------------------------------------------------------------------------------------------------------------------------------------
////
//- (void) NewFirstRow
//  {
//  float YOff   = self.contentOffset.y;                                    // Desplazamiento en la vertical del scroll
//  float IdxPos = YOff / (_MinHeight+RowSep);                              // Elemento  y fracción, correspondiente al borde superior
//  int   iRow   = (int) IdxPos;                                            // Elemento exacto, correspondiente al borde superior
//  
//  if( _Count==0 || YOff<0 ) return;                                       // Si no hay elemantos no hace nada
//  
//  VirtualRowView* vRow = [_VirtualListDelegate GetRowViewAt:iRow];                      // Obtiene una vista nueva para la fila 'iRow'
//    
//  float H = vRow.frame.size.height;                                       // Toma la altura que tiene la fila
//  float dtH  = (IdxPos-iRow) * (H+RowSep);                                // Parte de la fila que queda por encima del origen
//  float YPos = YOff - dtH;                                                // Posición de la primera fila en el contenido del scroll
//
//  YIni = YPos;
//  vRow.frame = CGRectMake(0, YPos, self.contentSize.width, H);            // Posiciona la vista adecuadamnete
//  
//  [self ClearRowsView];
//  [self addSubview:vRow];                                                 // Si no esta en las subviews, la adiciona
//  
//  YFin = YPos + RowSep + H;                                               // Calcula la posición para la proxima fila
//  }
//
////--------------------------------------------------------------------------------------------------------------------------------------------------------
////
//- (void) FillFromRow:(int) iRow
//  {
//  while( iRow<_Count-1 && YFin < YOff + self.bounds.size.height )         // Mientras haya filas y este en zona visible
//    {
//    ++iRow;                                                               // Toma la proxima fila
//    
//    vRow = [self GetViewWidthRowIndex:iRow From: &iView ];                // Busca (borrando las que no sean) la subview de la fila 'iRow'
//    if( vRow == nil)                                                      // No se encuentra
//      vRow = [_VirtualListDelegate GetRowViewAt:iRow];                    // Obtiene una vista nueva para la fila 'iRow'
//  
//    H = vRow.frame.size.height;                                           // Toma la altura que tiene la vista
//    vRow.frame = CGRectMake(0, YPos, self.contentSize.width, H);          // Posiciona la vista adecuadamnete
//
//    if( iView < 0 ) [self addSubview:vRow];                               // Si no esta en las subviews, la adiciona
//      
//    YFin += H + RowSep;                                                   // Avanza en la vertical el alto de la fila
//    }
//    
//  YFin -= YPos;
//  
//  if( iView!=-1 )                                                         // Si todavia quedan subviews sin considerar
//    vRow = [self GetViewWidthRowIndex:-1 From: &iView ];                  // Las borra todas
//  }
//
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza el todas las filas visibles, se acuerdo a la posicion del scroll
- (void) UpdateVisiblesRows
  {
  float YOff   = self.contentOffset.y;                                    // Desplazamiento en la vertical del scroll
  float IdxPos = YOff / (_MinHeight+RowSep);                              // Elemento  y fracción, correspondiente al borde superior
  int   iRow   = (int) IdxPos;                                            // Elemento exacto, correspondiente al borde superior
  int   iView  = 0;                                                       // Indice de la subview de la fila actual, -1 no esta en las subviews
  float H;                                                                // Altura de la fila actual
  
  if( _Count==0 || YOff<0 ) return;                                       // Si no hay elemantos no hace nada
  
  VirtualRowView* vRow = [self GetViewWidthRowIndex:iRow From: &iView ];  // Busca (borrando las que no sean) la subview de la fila 'iRow'
  if( vRow == nil)                                                        // No se encuentra
    vRow = [_VirtualListDelegate GetRowViewAt:iRow];                      // Obtiene una vista nueva para la fila 'iRow'
    
  H = vRow.frame.size.height;                                             // Toma la altura que tiene la fila
  float dtH  = (IdxPos-iRow) * (H+RowSep);                                // Parte de la fila que queda por encima del origen
  float YPos = YOff - dtH;                                                // Posición de la primera fila en el contenido del scroll

  YIni = YPos;
  vRow.frame = CGRectMake(0, YPos, self.contentSize.width, H);            // Posiciona la vista adecuadamnete
  
  if( iView < 0 ) [self addSubview:vRow];                                 // Si no esta en las subviews, la adiciona
  
  YPos = YPos + RowSep + H;                                               // Calcula la posición para la proxima fila
  
  while( iRow<_Count-1 && YPos < YOff + self.bounds.size.height )         // Mientras haya filas y este en zona visible
    {
    ++iRow;                                                               // Toma la proxima fila
    
    vRow = [self GetViewWidthRowIndex:iRow From: &iView ];                // Busca (borrando las que no sean) la subview de la fila 'iRow'
    if( vRow == nil)                                                      // No se encuentra
      vRow = [_VirtualListDelegate GetRowViewAt:iRow];                    // Obtiene una vista nueva para la fila 'iRow'
  
    H = vRow.frame.size.height;                                           // Toma la altura que tiene la vista
    vRow.frame = CGRectMake(0, YPos, self.contentSize.width, H);          // Posiciona la vista adecuadamnete

    if( iView < 0 ) [self addSubview:vRow];                               // Si no esta en las subviews, la adiciona
      
    YPos += H + RowSep;                                                   // Avanza en la vertical el alto de la fila
    }
    
  YFin = YPos - RowSep;
  
  if( iView!=-1 )                                                         // Si todavia quedan subviews sin considerar
    vRow = [self GetViewWidthRowIndex:-1 From: &iView ];                  // Las borra todas

//  if( YPos > self.contentSize.height || iRow >= _Count-1)
//    {
//    NSLog(@"Cambio de scroll %lf", YPos);
//    self.contentSize = CGSizeMake(self.bounds.size.width, YPos );       // Ajusta el tamaño del contenido al tamaño exacto
//    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la subview de la fila con indice 'idx' comenzando por la vista 'ini' y borra todas la filas que anteceden a 'idx'
- (VirtualRowView*) GetViewWidthRowIndex:(int) idx From:(int *) ini
  {
  int i = *ini;                                                           // Indice de la subview, donde comienza la busqueda
  if( i<0 ) return nil;                                                   // Si no es valido, retorna
  
  int nVRows = self.subviews.count;                                       // Obtiene la cantidad de subview en la lista
  for( ; i<nVRows; ++i )                                                  // Recorre las subviews hasta el final
    {
    UIView* view = self.subviews[ *ini];                                  // Obtiene la subview acual
    if(view.tag != -1 )                                                   // Si no esta marcada como una fila
      {
      *ini = *ini + 1;                                                    // Salta la subview
      continue;                                                           // Continua con la proxima subview
      }
    
    VirtualRowView* vRow = (VirtualRowView*)view;                         // Castea la subview a una vista de fila
    if( vRow.Index == idx  )                                              // Si el indice de la fila es el buscado
      {
      *ini = *ini + 1;                                                    // Salta la subvista encontrada
      return vRow;                                                        // Retorna la vista encontrada
      }
      
    // No es la subvista buscada
    [vRow CacheView];                                                     // Guarda la vista en la cache, para usarla mas adelante
    [vRow removeFromSuperview];                                           // La quita de la lista
    }
    
  *ini = -1;                                                              // No encontro la subvista buscada
  return nil;                                                             // Retorna nulo
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
//// Obtiene la posicion exacta de la primera fila a mostrar
//- (float) GetYPosIni
//  {
//  float y = self.contentOffset.y;                                    // Desplazamiento en la vertical del scroll
//  if( y>=YIni && y<YFin )
//    {
//    int nVRows = self.subviews.count;
//    for( int i=0; i<nVRows; ++i )
//      {
//      UIView* view = self.subviews[i];
//      if(view.tag != -1 ) continue;
//    
//      float yi = view.frame.origin.y;
//      float yf = yi + view.frame.size.height + RowSep;
//
//      if( yi >= YIni && yf<YFin )
//        return (yi + yf) / y;
//      }
//    }
//    
//  return y / (_MinHeight+RowSep);                              // Elemento  y fracción, correspondiente al borde superior
//  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Borra todas las filas visuales de la lista
- (void) ClearRowsView
  {
  int nVRows = self.subviews.count;
  for( int i=nVRows-1; i>=0; --i )
    {
    VirtualRowView* view = self.subviews[i];
    if(view.tag != -1 ) continue;
    
    [view CacheView];
    [view removeFromSuperview];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la subview de la fila con indice 'idx'
- (int) FindRowIndex:(int) idx
  {
  if( idx<0 || idx>=_Count ) return -1;
  
  for( int i=0; i<self.subviews.count; ++i )
    {
    UIView* view = self.subviews[i];
    if(view.tag != -1 ) continue;
    
    VirtualRowView* vRow = (VirtualRowView*)view;
    if( vRow.Index == idx  ) return i;
    }
    
  return -1;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end

//=========================================================================================================================================================
@implementation VirtualRowView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone la fila actual en el cache para poder reusarla
- (void) CacheView
  {
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se necesita cambiar el ancho de la fila, para poder reorganizar su contenido y su altura
-(void) ResizeWidth:(int) w;
  {
  CGRect frm = self.frame;
  frm.size.width = w;
  
  self.frame = frm;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Atienede cuando se toca sobre la fila
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
  {
  VirtualListView* List = (VirtualListView*)self.superview;       // Obtiene la lista que contiene la fila
  
  List.SelectedIndex = self.Index;                                // Pone la fila como seleccionada
  [List.VirtualListDelegate OnSelectedRow: self.Index];           // Llama a la función que atiende el evento de seleccionar una fila
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
@end


//=========================================================================================================================================================

