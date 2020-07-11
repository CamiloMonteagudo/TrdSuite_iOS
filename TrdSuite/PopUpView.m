//=========================================================================================================================================================
//  PopUpView.m
//  TrdSuite
//
//  Created by Camilo on 28/04/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "PopUpView.h"

#define BORDER_SEP    2
#define ROW_HEIGHT    50
#define ROW_SEP       1

#define ICON_WIDTH     50
#define ICON_HEIGHT    50

//=========================================================================================================================================================
@interface PopUpView ()
  {
  NSMutableArray * Rows;            // Filas o Item que conforman el menú
  UIView* RefView;                  // Vista usada como referencia para posicionar el popup
  UIView* UpView;                   // Ventana superior en la jerarquia de la ventana de referencia
  UIView* popUp;                    // Vista que contiene el contenido del menú
  float   popUpHeight;              // Altura de la vista del menú
  
  SEL OnSelAction;                  // Acción que se ejecuta cuando se selecciona un item en el menu
  id  OnTarget;                     // Objeto donde se va a ejecutar la accion
  
  float RowHeight;                  // Altura de las filas del meno
  float PopUpWidth;                 // Ancho del mené
  }

@end

//=========================================================================================================================================================
@implementation PopUpView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un PopUp Menu, debajo de la vista view, con las listas de Iconos de cada uno de los items del menú
- (id)initForView:(UIView*)view ItemIDs:(NSArray*) Items
  {
  RowHeight  = 50;                  // Altura de las filas del meno
  PopUpWidth = 200;                 // Ancho del mené
  
  RefView = view;                                                             // Guarda la ventana de referencia
  UpView  = view;                                                             // Vista de mayor jerarquia, de la ventana 'view'
  for(;;)                                                                     // Itera para encontrar la vista de mayor jerarquia
    {
    UIView* Parent = UpView.superview;                                        // Obtiene la vista superior en la jerarquia
    
    BOOL isWin = [Parent isKindOfClass: [UIWindow class]];                    // Si es la ventana principal
    if( !Parent || isWin )                                                    // Si no existe, o es la vantana principal
      break;                                                                  // Termina
    
    UpView = Parent;                                                          // Toma la vista, como de mayor jerarquia
    }
  
  self = [super initWithFrame: UpView.bounds ];                               // Crea una vista, con la dimensiones la de mayor jerarquia
  if( !self ) return self;                                                    // Si no la puede crear termina
  
  [UpView addSubview:self];                                                   // Adiciona esta vista a de mayor jerarquia (La cubre de forna trasparente)
  
  CGPoint pnt = [self GetPopUpPos];                                           // Calcula la posición donde se debe colocar el menú
  
  popUpHeight = Items.count * (RowHeight+ROW_SEP) - ROW_SEP + (2*BORDER_SEP);  // Calcula la altura del menú
  
  popUp = [self CreatePopUpAt:pnt Items:Items];                          // Crea el menú popup, con altura igual 0
  
  [self addSubview:popUp];                                                    // Adiciona el menú a la vista de fondo
  
  CGRect  frame = CGRectMake( pnt.x, pnt.y, PopUpWidth, popUpHeight);       // Rectangulo del menú, con la altura final
  [UIView animateWithDuration: 0.6 animations:^{ popUp.frame = frame;} ];     // Muestra menú animado, con la altura final

  _SelectedItem = -1;                                                         // Por defecto no se selecciono ningun item
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina la posición del menú popup, en función de la vista de referencia
- (CGPoint) GetPopUpPos
  {
  CGRect rc = [self convertRect:RefView.bounds fromView:RefView];             // Convierte las cordenadas de la view de referencia a la vista actual
  
  CGPoint pnt;
  pnt.x = (rc.origin.x + rc.size.width) - PopUpWidth;                       // Calcula la posición en x del Menú
  pnt.y = rc.origin.y + rc.size.height - 8;                                   // Calcula la posición en y del Menú
  
  return pnt;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se utiliza para establecer el metodo y el objeto al que se notificará cuando se seleccione un item en el menú
- (void) OnHidePopUp:(SEL)action Target:(id)target
  {
  OnSelAction = action;                                                       // Guarda el metodo a llamar
  OnTarget    = target;                                                       // Guarda el objeto a que pertenece el metodo
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca en cualquier lugar de la pantalla
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
  {
  CGPoint pnt = [[touches anyObject] locationInView: self];                   // Punto de la vista en la que se produjo el toque
  [self OnToucheMenuItem:pnt];                                                // Determina si el toque se produjo sobre un item del menú
  
  CGRect rc = popUp.frame;                                                    // Obtiene el marco del meno de popUp
  rc.size.height = 0;                                                         // Pone su altura iqual a cero

  [UIView animateWithDuration:0.6 animations:^{ popUp.frame = rc;  }          // Anina como disminulle la altura del menú hasta desaparecer
                                  completion:^(BOOL finished)
                                    {
                                    [self removeFromSuperview];               // Quita la ventada de fondo (el menú)
                                    [self NotifySelMenuItem];                 // Notifica si se toco algun item del menú
                                    }];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Notifica al objeto interesado que se esta cerrando el menú de popup
- (void) NotifySelMenuItem
  {
  if( !OnSelAction || !OnTarget )                                             // Si ningún objeto se ha registrado para recivir notificación
    return;                                                                   // Termina sin hacer nada
    
  NSThread* nowThread = [NSThread currentThread];
  [OnTarget performSelector:OnSelAction onThread:nowThread withObject:self waitUntilDone:NO];       // Realiza la notificacion
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si el toque se produjo sobre uno de los items del menú
- (void) OnToucheMenuItem:(CGPoint) pnt
  {
  CGPoint pnt2 = [self convertPoint:pnt toView:popUp];                        // Refiere el punto a la vista Pop Up
    
  for( int i=0; i<Rows.count; ++i )                                           // Recorre todas las filas (Items del menú)
    {
    UIView* vRow = Rows[i];                                                   // Toma la vista del fila actual
    
    if( CGRectContainsPoint( vRow.frame, pnt2 ) )                             // Si el punto esta dentro de la fila actual
      {
      _SelectedItem = i;
      return;                                                                 // Retorna el incice de la fila
      }
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el menú en el punto 'pnt', con los Items definidos en 'Names' e 'Icons'
// Nota: El menú se crea con altura cero y los item hacia arriba, para facilitar la animación al mostrarse
- (UIView*)CreatePopUpAt:(CGPoint) pnt Items:(NSArray*) ItemsId
  {
  CGRect  frame = CGRectMake( pnt.x, pnt.y, PopUpWidth, 0);                 // Crea recuadro para la vista del menú
  UIView* PopUp = [[UIView alloc] initWithFrame:frame  ];                     // Crea la vista del menú
  
  PopUp.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.4 alpha:0.75];  // Define el color de fondo del menú
  PopUp.clipsToBounds   = TRUE;                                               // Hace que se oculten las vistas fuera del recuadro del menú
  
  Rows = [NSMutableArray new];                                                // Crea arreglo vacio, para las vistas de las filas (Items del menú)
  
  float yPos = BORDER_SEP-popUpHeight;                                        // Posición inicial para el primer item del menú
  for( int i=0; i<ItemsId.count; ++i )                                        // Recorre todo los nombres de los items
    {
    UIView* vRow = [self CreateRowWidthItem:ItemsId[i] YPos: yPos];           // Crea la fila con el item de menu actual
    
    [PopUp addSubview:vRow];                                                  // Agrega la fila al menú
    
    yPos = yPos + RowHeight + ROW_SEP;                                        // Calcula posición para el proximo item
    }
  
  return PopUp;                                                               // Retorna el menú creado
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea una fila o Item del menú, con el identificador del item 'sItem' en la posición 'yPos´
- (UIView*)CreateRowWidthItem:(NSString*)sItem YPos:(float) yPos
  {
  NSString* strIcon  = [@"Btn" stringByAppendingString:sItem];
  NSString* strTitle = NSLocalizedString( [@"Mnu" stringByAppendingString:sItem], nil);
  
  float  width = PopUpWidth - (2*BORDER_SEP);                                 // Determina el ancho de la fila o Item
  CGRect frame = CGRectMake( BORDER_SEP, yPos, width, RowHeight);             // Determina el recuedro para la fila
  UIView* vRow = [[UIView alloc] initWithFrame:frame  ];                      // Crea la vista de la fila con el rectangulo calculado
  
  vRow.backgroundColor  = [UIColor colorWithRed:0.25 green:0.65 blue:0.85 alpha:0.75];  // Define el color de fondo del menú
  vRow.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;                // Se mantiene la distancia con el borde inferior del menú
  
  CGRect rcImg = CGRectMake( 10, 0, ICON_WIDTH, ICON_HEIGHT);                 // Determina el recuadro para el icono
  
  UIImageView* img = [[UIImageView alloc] initWithFrame: rcImg];              // Crea la vista para el icono
  img.image   = [UIImage imageNamed: strIcon ];                               // Carga el icono en la vista
  
  [vRow addSubview: img];                                                     // Agrega la vista del icono a la fila
  
  CGFloat xTitle = ICON_WIDTH + 10 + BORDER_SEP;                              // Determina la posicion donde empieza el titulo
  CGRect rcTitle = CGRectMake( xTitle, 0, width-xTitle, ICON_HEIGHT);         // Determina el recuadro para el titulo
  
  UILabel* Title  = [[UILabel alloc] initWithFrame: rcTitle];                 // Crea la vista para el titulo
  Title.text      = strTitle;                                                 // Pone el texto del titulo
  Title.textColor = [UIColor whiteColor];                                     // Pone el color de las letras del titulo
  
  [vRow addSubview: Title];                                                   // Agrega la vista del titulo a la fila
  
  [Rows addObject:vRow ];                                                     // Adiciona la vista de la fila al arreglo de filas
  return vRow;                                                                // Retorna la fila
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Recalcula la posición del menu cuando la vista de referencia cambia de posición
-(void)layoutSubviews
  {
  float h = popUp.frame.size.height;                                          // Determina la altura actual del menú
  if( h==0 ) return;                                                          // Si es cero no hace nada (se esta cerrando)
  
  CGPoint pnt = [self GetPopUpPos];                                           // Calcula la posición donde se debe colocar el menú
  CGRect  frame = CGRectMake( pnt.x, pnt.y, PopUpWidth, popUpHeight);       // Rectangulo del menú, con la altura final
  
  popUp.frame = frame;                                                        // Muestra menú animado, con la altura final
  self.frame  = UpView.bounds;                                                // Ventana de fondo a cubrir toda la pantalla
  }


@end
//=========================================================================================================================================================
