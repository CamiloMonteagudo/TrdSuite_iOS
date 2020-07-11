//
//  VirtualListView.m
//  PruScroll
//
//  Created by Camilo on 19/02/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//

#import "VirtualListView.h"
#import "ColAndFont.h"
#import "AppData.h"

//=========================================================================================================================================================
@interface VirtualListView ()
  {
  float lastWidth;                                        // Ultimo ancho de organización del control
  float lastHeight;                                       // Ultima altura de organización del control
  
  float YPosIni;
  float YPosFin;
  float YOffIni;
  float YOffFin;
  
  int   ItemIni;
  int   ItemFin;
  }
@end

//=========================================================================================================================================================
@implementation VirtualListView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];
  if( !self ) return nil;

  [self initData];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
  {
  self = [super initWithFrame:frame];
  if( !self ) return self;
  
  [self initData];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa los datos especificos de la vista de compras
- (void) initData
  {
  _MinHeight = 30;
  _SelectedIndex = -1;
  
  self.bounces = YES;
  
  self.alwaysBounceVertical   = YES;
  self.alwaysBounceHorizontal = NO;
  
  self.showsHorizontalScrollIndicator = NO;
  self.showsVerticalScrollIndicator   = YES;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cambia la cantidad de elementos de la lista, directamente (Se usa para inicializar la lista)
- (void)setCount:(int)Count
  {
  _SelectedIndex = -1;

  lastWidth = self.bounds.size.width;
  
  self.contentSize = CGSizeMake(lastWidth, (_MinHeight+SEP_ROW) * Count );
  self.contentOffset = CGPointMake(0, 0);                 // Pone la lista en el origen
  
  [self UpdateCount:Count];                               // Actualiza la lista con la nueva cantidad de item
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza los datos de la lista, cuando cambie el número de filas, o otro evento que necesite actualizar el contenido completo de la lista
- (void)UpdateCount:(int)Count
  {
  _Count = Count;                                         // Reasigna el número de filas de la lista
  
  if( Count>0 )                                           // Si haya elementos en la lista
    self.backgroundColor = ColCellSep;                    // Pone el fondo gris
  else                                                    // La lista esta vacia
    self.backgroundColor = ColCellBck;                    // Pone el fondo blanco
  
  [self ClearRowsView ];                                  // Borra todas las filas que habia anteriormente
  [self setNeedsLayout];                                  // Muestra las filas según los datos nuevos
  [self layoutIfNeeded];                                  // Hace los cambios inmediatamente
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setMinHeight:(int)MinHeight
  {
  _MinHeight = MinHeight;
  [self UpdateCount:_Count];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Hace que se redibuje el contenido de la lista
- (void)Refresh
  {
  [self ClearRowsView];                                   // Borar todas las filas actuales de la lista
  [self setNeedsLayout];                                  // Manda a que se redibujen todas nuevamente
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada vez que haya que reorganizar la ditribución de las filas dentro del scroll
- (void)layoutSubviews
  {
  float wView = self.bounds.size.width;                               // Ancho de la vista
  float HView = self.bounds.size.height;                              // Altura de la vista
  
  if( _Count<=0 || HView==0 ) return;                                 // Si no hay filas, o el control no se ha creado
  if( lastWidth != wView || lastHeight!=HView )                       // Cambio el tamaño de la vista
    {
    lastWidth  = wView;                                               // Guarda el tamaño nuevo
    lastHeight = HView;
    
    [self ClearRowsView];                                             // Borra todas las filas para forzar a reorganizar todo
    }
  
  if( _NoLayaut && YOffIni == self.contentOffset.y )                  // Si no organizar y no se ha movido el scroll
    return;                                                           // No hace nada
    
  _NoLayaut = false;                                                  // Quita de bandera de no organizar
    
  if( _VirtualListDelegate==nil ) return;                             // Si no hay delegado no se hace nada (no hay info de las filas)
  
  YOffIni = self.contentOffset.y;                                     // Offset inicial de la zona de scroll
  YOffFin = YOffIni + HView;                                          // Offset final de la zona de scroll

  if( YOffIni >= YPosFin || YOffFin < YPosIni )                       // Todas la filas esta fuera de la zona visible
    {
    [self CreateFirstRow];                                            // Crea la primera fila
    [self CreateRowsDownFromRow: ItemIni];                            // Crea el resto de las filas
    }
  else                                                                // Hay algunas filas en la zona visible
    {
    [self ReuseRows];                                                 // Borra todas las filas fuera de la zona visible
    
    [self CreateRowsUpFromRow: ItemIni];                              // Crea las filas faltantes en la parte de arriba
    [self CreateRowsDownFromRow: ItemFin];                            // Crea las filas faltantes en la parte de abajo
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea la primera fila, basandose en la posición del scroll
- (void) CreateFirstRow
  {
  float IdxPos = YOffIni / (_MinHeight+SEP_ROW);                           // Elemento y fracción, correspondiente al borde superior
  int   iRow   = (int) IdxPos;                                            // Elemento exacto, correspondiente al borde superior

  if( iRow>=_Count )                                                      // Se estima incorrectamente la primera fila, posiblemente
    {                                                                     // debido a un cambio grande en al altura del las filas o de la
    iRow = 0;                                                             // ventana, se resetea la posición actual del scroll y se pone el
    IdxPos = 0;                                                           // desde la primera fila
    YOffIni = 0;
    self.contentOffset = CGPointMake(0, 0 );
    }
  
  [self ClearRowsView];                                                   // Borra las fila que hallan en el scroll
  if( _Count==0 || iRow<0 ) return;                                       // Si no hay elemantos no hace nada
  
  
  VirtualRowView* vRow = [_VirtualListDelegate GetRowViewAt:iRow];        // Obtiene una vista nueva para la fila 'iRow'
  vRow.Index = iRow;
    
  float H = vRow.frame.size.height;                                       // Toma la altura que tiene la fila
  float dtH  = (IdxPos-iRow) * (H+SEP_ROW);                               // Parte de la fila que queda por encima del origen

  YPosIni = YOffIni - dtH;                                                // Posición de la primera fila en el contenido del scroll
  vRow.frame = CGRectMake(0, YPosIni, lastWidth, H);                      // Posiciona la vista adecuadamnete
  
  [self addSubview:vRow];                                                 // Adiciona al scroll
  
  YPosFin = YPosIni + H + SEP_ROW;                                        // Calcula la posición para la proxima fila

  ItemIni = iRow;                                                         // Indice del primer item de la lista
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea filas hasta llegar al final de la zona visible, a partir de la fila 'iRow'
- (void) CreateRowsDownFromRow:(int) iRow
  {
  while( iRow>=0 && iRow<_Count-1 && YPosFin < YOffFin )                  // Mientras haya filas y este en zona visible
    {
    ++iRow;                                                               // Toma la proxima fila
    
    VirtualRowView* vRow = [_VirtualListDelegate GetRowViewAt:iRow];      // Obtiene una vista nueva para la fila 'iRow'
    vRow.Index = iRow;

    float H = vRow.frame.size.height;                                     // Toma la altura que tiene la vista
    vRow.frame = CGRectMake(0, YPosFin, lastWidth, H);                    // Posiciona la vista adecuadamnete

    [self addSubview:vRow];                                               // Adiciona al scroll
      
    YPosFin += H + SEP_ROW;                                               // Avanza en la vertical el alto de la fila
    }
    
  ItemFin = iRow;                                                         // Indice del ultimo inidice de la lista
  [self FixScrollSize];                                                   // Ajusta el tamaño del scroll
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Ajusta el tamaño del scroll de acuerdo al tamaño de la zona visible
- (void) FixScrollSize
  {
  float H  = YPosFin + (_Count-ItemFin-1) * (_MinHeight+SEP_ROW);           // Calcula la altura teniendo en cuanta los items que estan en la pantalla
  
  if( H != self.contentSize.height )                                        // Si la altura diferente a la altura actual del scroll
    {
    float off1 = self.contentOffset.y;                                      // Guarda la posición actual del scroll
  
    _NoLayaut = true;                                                       // Bandera para que no se vuelva a organizar las filas
    
    self.contentSize = CGSizeMake(lastWidth, H );                           // Ajusta el tamaño del scroll
    self.contentOffset = CGPointMake(0, off1 );                             // Restaura la posición del scroll
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Borra todas las filas que esten fuera de la zona visible
- (void) ReuseRows
  {
  VirtualRowView* vRowFirst;                                              // Primera fila de la lista
  
  float yi, yf, yLast=-1, yFirst=-1;
  
  int nVRows = (int)self.subviews.count-1;                                // Guarda número de filas iniciales
  for( int i=nVRows; i>=0; --i )                                          // Recorre todas la filas existentes
    {
    UIView* view = self.subviews[i];                                      // Toma la fila actual
    if(view.tag != -1 )                                                   // No es una fila de la lista
      continue;                                                           // Continua con la proxima
    
    yi = view.frame.origin.y;                                             // Obtiene la posición inicial
    yf = yi + view.frame.size.height + SEP_ROW;                           // Obtiene la posicion final

    VirtualRowView* vRow = (VirtualRowView*)view;                         // Castea la subview a una fila de la lista
      
    if( yf<YOffIni || yi>YOffFin )                                        // Esta fuera de la zona visible
      {
      [vRow CacheView];                                                   // Guarda la vista en la cache, para usarla mas adelante
      [vRow removeFromSuperview];                                         // La quita de la lista
      }
    else                                                                  // Si esta dentro de la zona visible
      {
      if( yLast == -1 )                                                   // Primera fila encontrada (Ultima de la lista)
        {
        yLast = yf;                                                       // Toma la y del final de la lista
        ItemFin = vRow.Index;                                             // Indice de la ultima fila de la lista
        }
        
      yFirst    = yi;                                                     // Toma la y mas pequeña
      vRowFirst = vRow;                                                   // Actualiza la primera fila
      }
    }
    
  YPosIni = yFirst;                                                       // Pone posición inicial de zona visible
  YPosFin = yLast;                                                        // Pone posición final de la zona visible
  
  ItemIni = vRowFirst.Index;                                              // Retorna indice de la primera fila en la lista
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea filas hasta llegar al inicio de la zona visible, a partir de la fila 'iRow'
- (void) CreateRowsUpFromRow:(int) iRow
  {
  while( iRow>0 && YPosIni >= YOffIni )                                   // Mientras haya filas y este en zona visible
    {
    --iRow;                                                               // Toma la fila previa
    
    VirtualRowView* vRow = [_VirtualListDelegate GetRowViewAt:iRow];      // Obtiene una vista nueva para la fila 'iRow'
    vRow.Index = iRow;
 
    float H = vRow.frame.size.height;                                     // Toma la altura que tiene la vista
    YPosIni -= (SEP_ROW + H);                                             // Avanza en la vertical el alto de la fila
    
    vRow.frame = CGRectMake(0, YPosIni, lastWidth, H);                    // Posiciona la vista adecuadamnete

    [self insertSubview:vRow atIndex:0];                                  // Adiciona al scroll, en la parte superior
    }
    
  ItemIni = iRow;
  
  if( ItemIni==0 && YPosIni!=0 )                                          // Si esta en la primera fila y su posición inicial no es 0
    [self ShiftRowsFrom:-1 Delta:-YPosIni ];                              // Desplaza las filas para que quede en 0
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Borra todas las filas visuales de la lista
- (void) ClearRowsView
  {
  int nVRows = (int)self.subviews.count;                                  // Guarda la cantidad de vistas en el scroll
  for( int i=nVRows-1; i>=0; --i )                                        // Recorre todas las vistas de atras hacia adelante
    {
    VirtualRowView* view = self.subviews[i];                              // Toma la vista actual
    if(view.tag != -1 ) continue;                                         // La vista no es una fila, la salta
    
    [view CacheView];                                                     // Guarda la fila en el cache, para reuzarla
    [view removeFromSuperview];                                           // Borra la fila del scroll
    }
    
  YPosIni = -1;                                                           // Pone todos los datos de las filas a sus valores por defecto
  YPosFin = -1;
  
  ItemIni = -1;
  ItemFin = -1;
  
  _NoLayaut = false;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el indice a la subview de la fila con indice 'idx'
- (int) FindRowIndex:(int) idx
  {
  if( idx<0 || idx>=_Count ) return -1;                                   // Si idx no esta en el rango valido, retorna no encontrado
  
  for( int i=0; i<self.subviews.count; ++i )                              // Recorre todas las vistas en el scroll
    {
    UIView* view = self.subviews[i];                                      // Toma la vista actual
    if(view.tag != -1 ) continue;                                         // La vista no es una fila, la salta
    
    VirtualRowView* vRow = (VirtualRowView*)view;                         // Castea la vista a una fila
    if( vRow.Index == idx  ) return i;                                    // Si la fila es la buscada, retorna indice de la vista
    }
    
  return -1;                                                              // No la encontro
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Corre todas las filas visibles a partir de 'idx' una magnitud de 'dtH' en el eje y
-(void) ShiftRowsFrom:(int) idx Delta:(float)dtH
  {
  if( dtH == 0 ) return;                                            // No hay nada que correr
  
  int i = (++idx);                                                  // Inicia en la fila siguiente a la actual
  for(; i<self.subviews.count; ++i )                                // Recorre todas las filas visibles a partir de la actual
    {
    UIView* view = self.subviews[i];                                // Coge la vista actual
    if(view.tag != -1 ) continue;                                   // No es una fila de la lista, la salta

    CGRect rc = view.frame;                                         // Obtiene el marco que la encierra
    rc.origin.y += dtH;                                             // Corrige la posición y
    
    view.frame = rc;                                                // Pone rectangulo actualizado
    }
    
  YPosFin += dtH;                                                   // Actualiza la posición final de la zona visible
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone la fila 'iRow' como la seleccionada
- (void)setSelectedIndex:(int)iRow
  {
  if( _SelectedIndex == iRow ) return;                              // Si ya esta seleccionada, no hace nada
  
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
// Cambia la vista de la fila en 'Idx' por la nueva solicitada al delegado con indice 'iRow'
-(void) ChangeSubView:(int) Idx At:(int) iRow
  {
  _NoLayaut = true;                                                 // Posiciona las filas por si misma, no necesita LayoutSubview
  
  VirtualRowView* nowRow = self.subviews[Idx];                      // Obtiene la fila en idx
  
  float YPos = nowRow.frame.origin.y;                               // Obtiene la posicion en y
  float H    = nowRow.frame.size.height;                            // Obtiene la altura
  
  [nowRow CacheView];                                               // Pone la fila en el cache para reutilizarla
  [nowRow removeFromSuperview];                                     // La quita de la lista
  
  nowRow = [_VirtualListDelegate GetRowViewAt:iRow];                // Obtiene una fila nueva con indice iRow
  nowRow.Index = iRow;
  
  CGRect rc = nowRow.frame;                                         // Obtiene el rectangulo que la enmarca
  rc.origin.y = YPos;                                               // Le pone la posición en y
  nowRow.frame = rc;                                                // Actualiza el rectangulo con la posición correcta
  
  [self insertSubview:nowRow atIndex:Idx ];                         // La inserta en la misma posicion que estaba la otra
  
  float dtH = rc.size.height-H;                                     // Diferenccia de altura entre las filas
  
  if( dtH !=0 )                                                     // Si cambio la altura
    [self ShiftRowsFrom:Idx Delta:dtH ];                            // Desplaza las filas siguientes, hacia arriba, o hacia abajo
    
  if( dtH<0 )                                                       // Si disminuye la altura de la fila
    [self CreateRowsDownFromRow: ItemFin];                          // Rellena hacia abajo lo necesario
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Posiciona la fila con indice iRow en la parte superior de la lista
-(void) SetAtTopRow:(int) iRow
  {
  if( iRow<0 || iRow >= _Count ) return;                            // Si la fila no esta dentro del rango, no hace nada
  
  float yPos = iRow * (_MinHeight+SEP_ROW);                         // Calcula la posición de la fila
  if( yPos == self.contentOffset.y ) return;                        // Si ya el scroll esta en esa posición, no hace nada
  
  [self ClearRowsView];                                             // Fuerza a que se redibujen todas las filas
  self.contentOffset = CGPointMake(0, yPos );                       // Pone el scroll en la posición
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Asegura que la fila iRow sea completamente visible
-(void) SetVisibleRow:(int) iRow
  {
  if( iRow<ItemIni || iRow>ItemFin )                                // El item esta fuera de la zona visible
    {
    [self SetAtTopRow:iRow];                                        // Lo pone de primero en la lista
    return;                                                         // y termina
    }
    
  int Idx = [self FindRowIndex: iRow ];                             // Busca el indice de la vista de la fila iRow
  
  VirtualRowView* rowView = self.subviews[Idx];                     // Obtiene la vista con la fila
    
  float yi = rowView.frame.origin.y;                                // Obtiene la y de la parte inferior de la fila
  float yf = yi + rowView.frame.size.height;                        // Obtiene la y de la parte inferior de la fila
  
  if( yi>=YOffIni && yf<=YOffFin )                                  // Si la fila es enteramente visible
    return;                                                         // Termina sin hacer nada
   
  _NoLayaut = false;                                                // Garantiza que se posicionen las filas
  
  float dtH = (yi<YOffIni)? (yi-YOffIni):(yf-YOffFin);              // Determina la magnitud a desplazar el scroll
  self.contentOffset = CGPointMake(0, YOffIni+dtH );                // Pone el scroll en la posición adecuada
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end

//=========================================================================================================================================================
@implementation VirtualRowView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
  {
  self = [super initWithFrame:frame];
  if( !self ) return nil;
  
  self.tag = -1;
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone la fila actual en el cache para poder reusarla
- (void) CacheView
  {
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

