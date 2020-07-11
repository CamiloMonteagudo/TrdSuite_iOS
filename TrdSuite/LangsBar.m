//=========================================================================================================================================================
//  LangsBar.m
//  TrdSuite
//
//  Created by Camilo on 26/04/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "LangsBar.h"
#import "AppData.h"
#import "PanelRigthView.h"
#import "ColAndFont.h"
#import "PurchasesView.h"

#define INI_SEP    5
#define PANEL_MAX  300
#define BACK_W     50

//=========================================================================================================================================================
@interface LangsBar ()
  {
  UIButton* Btns[LGCount];                                // Botones de idioma
  int nLngs;                                              // Número de idiomas que se estan mostrando
  
  UIImageView* LGCur;                                     // Para indicar cual es el idioma actual
  UIView*      LGPanel;                                   // Vista en la que se ponen las banderas de idioma
  
  float szTitle;                                          // Tamaño del actual para el titulo del idioma seleccinado
  float szTitleLang;                                      // Tamaño fijo del titulo del idioma seleccionado
  float szTitleBegan;                                     // Tamaño al comenzar a desplazar el titulo del idioma seleccionado
  float sgnTitle;                                         // Signo del para crecer o disminuir el tamaño del titulo
  float xTitle;                                           // Posición en la x donde esta el titulo
  
  int   wPanel;                                           // Ancho del panel que muestra los idiomas
  
  UIButton* btnBck;                                       // Boton para para retroceder
  UIButton* btnMnu;                                       // Boton para mostrar un menú con las opciones adicionales
  PanelRigthView* PopUp;                                  // Vista que muestra el menú con las opciones adicionales
  
  NSMutableArray* ItemIDs;                                // Identificadores de lo items adicionales
  NSMutableArray* BtnItems;                               // Botones con las opciones adicionales
  
  SEL OnSelItem;                                          // Metodo que se llama cuando se selecciona un Item
  id  ItemTarget;                                         // Objeto al que pertence el metodo de notificación seleccion de un item
  
  SEL OnSelLang;                                          // Metodo que se llama cuando se selecciona un idioma
  id  LangTarget;                                         // Objeto al que pertenece el metodo
  
  SEL OnBack;                                             // Metodo que se llama cuando se toca el boton back
  id  BackTarget;                                         // Objeto al que pertenece el metodo
  }
@end

@implementation LangsBar

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];                // Clase base hace la inicializacion del objeto
  if( !self ) return nil;

  _Trd = (self.tag);                                    // Establece si es el texto traducido o el origen

  [self initData];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea una barra para la seleccon de los idiomas, a todo lo ancho de la vista 'view' a partir de 'yPos' en la vertical
- (id)initWithView:(UIView*) view Trd:(BOOL) trd
  {
  _Trd = trd;
  
  CGRect rc = view.frame;
  
  CGRect frame = CGRectMake(0, 0, rc.size.width, BTN_H );        // Determina el marco que ocupará la barra
  self = [super initWithFrame:frame];                            // Crea la vista para la barra
  if( !self ) return self;
  
  [self initData];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Mueve la barra de posición
- (void) MoveToX:(float) x Y:(float) y
  {
  CGRect rc = self.frame;
  
  rc.origin.x = x;
  rc.origin.y = y;
  
  self.frame = rc;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa los datos especifico de la barra de idiomas, una ves creada la vista
- (void) initData
  {
  ItemIDs  = [NSMutableArray new];                                  // Arreglo vacio para los iconos de los items adicionales
  BtnItems = [NSMutableArray new];                                  // Arreglo vacio para los botones adicionales
  
  self.autoresizingMask = UIViewAutoresizingFlexibleWidth;          // Hace que se redimensione en la horizontal con la vista que la contiene
  
  [self CreateLangsButtons];                                        // Crea los botones de los idiomas
  
  // Crea un gesto para ocultar o mostrar el nombre de idioma para ganar espacio
  UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(OnGeture:)];
  [self addGestureRecognizer:gesture];
  
  self.SelLng =  ( _Trd )? LGDes : LGSrc;                           // Establece el idioma inicial
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Refresca el contenido de la vista cuando cambia el tamaño de las letras o los idiomas instalados
-(void) RefreshView
  {
  for( int i=0; i<LGCount; ++i )
    {
    UIButton* btn = Btns[i];
    btn.titleLabel.font = fontTxtBtns;
    }

  szTitleLang = LGNameSz(_SelLng);
  [self RefreshLangsButtons];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona un item adicional a la barra, suministrando el icono y el titulo
- (void) AddItemId:(NSString*) strItem
  {
  [ItemIDs addObject:strItem ];
  
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Estable el metodo y el objeto que se notificará cuando se seleccione un item adicional
- (void) OnSelItem:(SEL)action Target:(id)target
  {
  OnSelItem  = action;
  ItemTarget = target;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Estable el metodo y el objeto que se notificará cuando se seleccione un Idioma
- (void) OnSelLang:(SEL)action Target:(id)target
  {
  OnSelLang  = action;
  LangTarget = target;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Estable el metodo y el objeto que se notificará cuando se seleccione el botón Back
- (void) OnOnBack:(SEL)action Target:(id)target
  {
  OnBack     = action;
  BackTarget = target;
  
  CGRect rc = CGRectMake( 0, 0, BTN_W, BTN_H);
  
  btnBck = [[UIButton alloc] initWithFrame:rc];
  [btnBck setImage: [UIImage imageNamed: @"BtnBack" ] forState: UIControlStateNormal ];
  
  [btnBck addTarget:self action:@selector(OnBack:) forControlEvents:UIControlEventTouchUpInside];
   
  [self addSubview:btnBck];
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca una de la bandera que no esta activa
- (void)OnPurchaseLang:(id)sender
  {
  HideKeyBoard();                                                                   // Se oculta el teclado si esta desplegado
  
  int src, des;
  int Lng = (int)((UIButton*)sender).tag-100;                                  // Determina el idioma que representa el botón oprimido
  
  if( _Trd ) { src=LGSrc;  des=Lng;   }
  else       { src=Lng;    des=LGDes; }
  
  PurchasesScreen* PutcView = [[PurchasesScreen alloc] initWithFromView:self ];
  [PutcView SelPurchasesSrc:src Des:des];
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca una de la bandera que definen los idiomas
- (void)OnSelLang:(id)sender
  {
  HideKeyBoard();                                                                   // Se oculta el teclado si esta desplegado
  
  int newLng   = (int)((UIButton*)sender).tag-100;                                  // Determina el idioma que representa el botón oprimido
  int oldLng   = _SelLng;                                                           // Guarda idioma seleccionado actualmente
//  int oldTitle = szTitle;                                                           // Guarda titulo del idioma seleccionado actualmente
  
  [UIView animateWithDuration: 0.6
          animations:^{
                      if( newLng != oldLng )                                        // Si es el idioma seleccionado cambio
                        [self setSelLng:newLng];                                    // Se selecciona el idioma de forma animada
//                      else
//                        {
//                        szTitle = (oldTitle==0)? szTitleLang : 0;                   // Se muestra/oculta el titulo contrario al estado anterior
//                        [self LayoutButtons];                                       // Manda a reorganizar las vistas
//                        }
                      }];
  
  if( OnSelLang && LangTarget )                                                     // Si se establecio a quien notificar
    {
    NSThread* nowThread = [NSThread currentThread];
    [LangTarget performSelector:OnSelLang onThread:nowThread withObject:self waitUntilDone:NO];       // Realiza la notificacion
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton que muestra el menú opciones adicionales (se usa cuando hay poco espacio)
- (void)OnBack:(id)sender
  {
  HideKeyBoard();                                                                   // Se oculta el teclado si esta desplegado
  
  if( OnBack && BackTarget )
    {
    NSThread* nowThread = [NSThread currentThread];
    [BackTarget performSelector:OnBack onThread:nowThread withObject:self waitUntilDone:NO];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton que muestra el menú opciones adicionales (se usa cuando hay poco espacio)
- (void)OnShowMenu:(id)sender
  {
  HideKeyBoard();                                                                   // Se oculta el teclado si esta desplegado

  PopUp = [[PanelRigthView alloc] initInView:btnMnu ItemIDs:ItemIDs];             // Crea un popup menú con items adicionales

  [PopUp OnHidePopUp:@selector(OnHidePopUp:) Target:self];                          // Pone metodo de notificación del mené
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cierra el menú con las opciones adicionales
- (void)OnHidePopUp:(PanelRigthView*) view
  {
  PopUp = nil;                                                                     // Indica que no hay menú a partir de este momento
  
  int Idx = view.SelectedItem;                                                     // Obtiene el item seleccionado en el menú
  if( Idx >= 0 )                                                                   // Hay uno seleccionado
    [self OnSelectItem:Idx];                                                       // Función que procesa la acción
  }
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca uno de los botones de items adicionales
- (void)OnButttonItem:(id)sender
  {
  int Idx = (int)((UIView*)sender).tag;                                                // Obtiene identificador del idioma
  [self OnSelectItem:Idx-200];                                                      // Función que procesa la acción
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Posesa la accion al seleccionar un boton de un item adicional
- (void)OnSelectItem:(int) idxItem
  {
  _SelItem = idxItem;                                                             // Guarda el item seleccionado
  if( OnSelItem && ItemTarget )                                                   // Si se establecio el metodo para la notificación
    {
    NSThread* nowThread = [NSThread currentThread];
    [ItemTarget performSelector:OnSelItem onThread:nowThread withObject:self waitUntilDone:NO];       // Realiza la notificacion
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Propiedad que controla si se muestra la titulo del idioma o no
- (void)setHideTitle:(BOOL)HideTitle
  {
  [self showLangTitle];
  
  _HideTitle = HideTitle;
  [self setNeedsLayout];                                                         // Manda a reorganizar las vistas
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Define si se muestra o no el titulo del idioma
- (void) showLangTitle
  {
  float w    = self.bounds.size.width;                                          // Ancho disponible para la barra
  float wBar = INI_SEP + nLngs*(BTN_H+BTN_SEP) - BTN_SEP + MAX_LGTITLE;         // Ancho que ocupan los botones de idioma
  
  if( OnBack ) wBar += BACK_W;                                                  // Si hay boton de retorceder, suma el ancho
  
  if( ItemIDs.count != 0 )                                                      // Hay iconos adicionales
    wBar += 60;                                                                 // Suma un minimo para el boton del menú
  
  szTitle = (_HideTitle && w<wBar )? 0 : szTitleLang;                           // Pone el tamaño como el actual
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Establece cual es el idioma seleccionado
- (void)setSelLng:(int)lng
  {
  _SelLng     = lng;                                                              // Pone la propiedad
  szTitleLang = LGNameSz(_SelLng);                                                // Determina el tamaño del titulo del idioma
  
  [self showLangTitle];                                                           // Actualiza al tamano del titulo del nuevo idioma
    
  if( _Trd ) LGDes = lng; else LGSrc = lng;                                       // Pone idioma global para traducción (según el tipo de vista)
  
  if( lng<0 ) LGCur.hidden = TRUE;                                                // Si no es uno valido, oculta el indicador del idioma seleccionado
  
  [self setNeedsLayout];                                                          // Manda a reorganizar las vistas
  [self layoutIfNeeded];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al cambiar le propiedad de mostrar el cursor o no
- (void)setNoCur:(BOOL)NoCur
  {
  if( _NoCur == NoCur ) return;
  
  _NoCur = NoCur;
  if( NoCur )
    LGCur.hidden = TRUE;
  else
    LGCur.hidden = (_SelLng<0);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea los botones adicionales hacia la derecha del ancho 'Width'
- (void) CreateButtonItems:(float) Width
  {
  float wItems = (ItemIDs.count * (BTN_W+BTN_SEP)) - BTN_SEP + INI_SEP;           // Ancho ocupado por todos los items adiconales
  float      x = Width - wItems;                                                  // Determina la posición del primer boton
  
  for( int i=0; i<ItemIDs.count; ++i)                                             // Recorre todos los iconos de las opciones adicionales
    {
    CGRect rc = CGRectMake( x, 0, BTN_W, BTN_H);                                  // Recuadro que opupará el botón
  
    UIButton* btn = [[UIButton alloc] initWithFrame:rc];                          // Crea la vista para el botón
    
    btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;                  // Hace que se mantenga pegado a la izquierda cuando se redimensiona
    btn.tag = 200 + i;                                                            // Marca el número del Item
    
    NSString* sImg = [@"Btn" stringByAppendingString:ItemIDs[i]];                 // Obtiene el nombre de la imagen
    UIImage* Img = [UIImage imageNamed: sImg ];                                   // Carga la imagen perteneciete al item actual
    
    if( Img != nil )                                                              // Si se pudo cargar la imagen
      [btn setImage: Img forState: UIControlStateNormal ];                        // Le pone la imagen al botón
    else                                                                          // No se pudo cargar la imagen
      {
      NSLog(@"No se pudo cargar la imagen '%@'", sImg);                           // Pone un aviso, para debuguer
      btn.backgroundColor = [UIColor blackColor];                                 // Pone boton en negro
      }
    
    [btn addTarget:self action:@selector(OnButttonItem:) forControlEvents:UIControlEventTouchUpInside];   // Pone metodo para la notificación
   
    [self addSubview:btn];                                                        // Adiciona el botón a la barra de idiomas
    
    [BtnItems addObject:btn];                                                     // Adiciona el botón a la lista de botones
    x += (BTN_W + BTN_SEP);                                                       // Calcula la posición del proximo botón
    }
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita todos los items adicionales asocidados a la barra de idiomas
- (void) ClearAllItems
  {
  [ItemIDs removeAllObjects];
  
  [self ClearButtonItems];
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita todos los botones de los items adiconales
- (void) ClearButtonItems
  {
  for( int i=0; i<BtnItems.count; ++i)
    {
    [((UIButton*)BtnItems[i]) removeFromSuperview];
    }
    
  [BtnItems removeAllObjects];
  [self setNeedsLayout];
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita el botón del menú de las opciones adicionales
- (void) ClearButtonMenu
  {
  if( PopUp  ) [PopUp removeFromSuperview];
  if( btnMnu ) [btnMnu removeFromSuperview];
    
  PopUp  = nil;
  btnMnu = nil;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el botón para el menú de items adicionales
- (void) CreateButtonMenu:(float) Width
  {
  CGRect rc = CGRectMake( Width-INI_SEP-BTN_W, 0, BTN_W, BTN_H);
  
  btnMnu = [[UIButton alloc] initWithFrame:rc];
  btnMnu.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  [btnMnu setImage: [UIImage imageNamed: @"Menu" ] forState: UIControlStateNormal ];
  
  [btnMnu addTarget:self action:@selector(OnShowMenu:) forControlEvents:UIControlEventTouchUpInside];
   
  [self addSubview:btnMnu];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea los botones de idiomas y las vistas relacionadas al iniciar la barra de idiomas
- (void) CreateLangsButtons
  {
  CGRect frame = self.bounds;                                           // Obtiene el espacio disponible
  frame.size.width -= 60;                                               // Deja espacio para el botón del menú de la derecha
  wPanel = frame.size.width;                                            // Pone el ancho del panel de idiomas
  
  LGPanel = [[UIView alloc] initWithFrame:frame  ];                     // Crea el panel para idiomas
  LGPanel.clipsToBounds = TRUE;                                         // Bandera para que oculte todo lo que quede por fuera
  
  [self addSubview:LGPanel];                                            // Adiciona panel de idioma a la vista
  
  frame = CGRectMake( INI_SEP+BTN_W, 33, 40, 28);                       // Posiciona el indicador de idioma seleccionado
  
  LGCur = [[UIImageView alloc] initWithFrame:frame ];                   // Crea vista para indicador de idioma seleccionado
  LGCur.image  = [UIImage imageNamed: @"Leading"];                      // Carga la imagen del indicador de idioma seleccionado
  LGCur.hidden = TRUE;                                                  // Oculta temporalmente el indicador
  [LGPanel addSubview:LGCur];                                           // Adiciona indicador de idioma a la vista

  nLngs = ((_Trd)? 3 : 4);                                              // # de botones de idimas (Traducción 3, Fuente 4 )
  
  for( int i=0; i<nLngs; ++i )                                          // Crea todos los botones de idioma
    {
    CGRect rc = CGRectMake( 0, 0, BTN_W, BTN_H);                        // Rectangulo para boton (la posición de define despúes)
    
    UIButton* btn = [[UIButton alloc] initWithFrame:rc];                // Crea vista del tipo botón
    
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;   // Que de alinee a la izquierda
    
    btn.titleLabel.font = fontTxtBtns;                                  // Fuente para las etiqueta de los botones
    btn.titleLabel.lineBreakMode = NSLineBreakByClipping;               // Si no cabe la etiqueta la corta
    
    [btn setTitleColor: ColTxtBtns forState: UIControlStateNormal ];    // Pone el color del titulo de los botones
    
    Btns[i] = btn;                                                      // Lo agrega a la lista de botones
    
    [LGPanel addSubview:btn];                                           // Lo adiciona a la vista del panel de botones
    }

  [self RefreshLangsButtons];                                           // Pone todas la banderas de acuerdo a los idiomas instalados
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Refresca los botones de idioma para reflejar los cambios en los idiomas instalados
- (void) RefreshLangsButtons
  {
  if( _Trd && LGSrc<0 ) return;
  
  LGCur.hidden = TRUE;                                                  // Oculta indicador del idioma actual
  
  int iBtn = 0;                                                         // Indice del boton que se esta actualizando
  for( int lng=0; lng<LGCount; ++lng )                                  // Recorre todos los idiomas (Para poner idiomas para traducir)
    {
    if( ![self IsValidLang:lng] ) continue;                             // La tradución con 'lng' no es posible, lo salta
    
    [self RefreshButton:iBtn Lang:lng ForTrd:TRUE];                     // Pone el boton para traducir en idioma 'lng'
    ++iBtn;                                                             // Corre al proximo boton
    }
    
  for( int lng=0; lng<LGCount; ++lng )                                  // Recorre todos los idiomas (Para poner idiomas para comprar)
    {
    if( _Trd && lng==LGSrc     ) continue;                              // Salta cuando idioma fuente es igual a idioma destino
    if( lng==3                 ) continue;                              // Salta cuando el idioma es alemán
    if( [self IsValidLang:lng] ) continue;                              // Salta los idiomas instalados
    
    [self RefreshButton:iBtn Lang:lng ForTrd:FALSE];                    // Pone el boton para comprar en idioma 'lng'
    ++iBtn;                                                             // Corre al proximo boton
    }
    
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Refresca los botones de idioma para reflejar los cambios en los idiomas instalados
- (void) RefreshButton:(int)idx Lang:(int)lng ForTrd:(BOOL)trd
  {
  UIButton* btn = Btns[idx];                                                          // Toma el boton actual
  [btn removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];   // Quita la acciones para el evento que tenia anteriormante
  
  btn.tag = lng + 100;                                                            // Le pone el idioma que representa
  btn.alpha = trd? 1.0 : 0.5;                                                     // Atenua el boton si no es para traducción
      
  SEL fun = trd? @selector(OnSelLang:) : @selector(OnPurchaseLang:);              // Pone evento generado por el boton de acuerdo
  
  [btn addTarget:self action:fun forControlEvents:UIControlEventTouchUpInside];   // si se va usar para traducir o no
    
  [btn setTitle : LGName(lng)                                  forState: UIControlStateNormal ];    // Pone nombre del idioma
  [btn setImage : [UIImage imageNamed: LGFlagFile(lng,@"50") ] forState: UIControlStateNormal ];    // Pone bandera del idioma
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si el idioma 'lng' es valido en el momento de llamar la función
- (BOOL) IsValidLang:(int)lng
  {
  if( _Trd && lng==LGSrc ) return FALSE;                                     // Se salta el idioma fuente
    
  return (_Trd? LGIsInstDes(lng) : LGIsInstSrc(lng));                        // Verifica si el idioma esta instalado
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Reorganiza los botones de idioma teniendo en cuenta el idioma seleccionado y el tamaño a mostrar
- (void)LayoutButtons
  {
  float x = [self GetXOffset];                                              // Obteine desplazamiento del primer boton
  
  for( int i=0; i<LGCount; ++i )                                            // Recorre todos los botones de idioma posibles
    {
    UIButton* btn = Btns[i];                                                // Toma el boton actual
    
    int lng = (int)btn.tag-100;                                             // Obtiene le idioma que representa (por el Tag)
    
    float w = BTN_W;                                                        // Toma ancho estadrad del boton
    if( lng == _SelLng )                                                    // Si es el idioma seleccionado
      {
      xTitle = x + w;
      w += szTitle;                                                         // Aumenta su acho en el tamaño actual definido para el titulo del idioma
      
      LGCur.hidden = _NoCur;                                                // Muestra la imagen que indica el idioma seleccionado
      LGCur.frame = CGRectMake( x+BTN_W-2, 33, 40, 28);                     // Posiciona el indicador de idioma seleccionado
      }
    
    btn.frame = CGRectMake( x, 0, w, BTN_H);                                // Posiciona el boton de idioma
    x += w + BTN_SEP;                                                       // Calcula posición para el proximo boton
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el desplazamiento del primer boton de la barra
-(float) GetXOffset
  {
  float w = INI_SEP + nLngs*(BTN_H+BTN_SEP) - BTN_SEP + szTitle;            // Ancho total requerido para todos los botones
  if( w <= wPanel )                                                         // Si alcanza el espacio para todos los botones
    return INI_SEP;                                                         // Separa el valor normal
  
  float x = INI_SEP;                                                        // Separación del borde del primer boton
  
  for( int i=0; i<LGCount; ++i )                                            // Recorre botones hasta encontrar el seleccionado
    {
    UIButton* btn = Btns[i];                                                // Toma el boton actual
    
    if( ((int)btn.tag-100) == _SelLng )                                     // Si es el idioma seleccionado
      {
      x += ((BTN_W+szTitle)/2.0);                                           // Calcula posicion del centro del boton
        
      if( x>(wPanel/2)) return wPanel-w;                                    // Si es mayor que el centro del panel, corre hacia la izquierda
      else              return INI_SEP;                                     // Menor corre hacia la dercha
      }
        
    x += (BTN_W+BTN_SEP);                                                   // Posición del proximo boton
    }
    
  return INI_SEP;                                                           // No hay ninguno seleccionado
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Llamado por el sistema cada ves que se requiere posicionar las vista (cambios de tamaño fundamentalmente)
- (void)layoutSubviews
  {
  [self showLangTitle];                                                       // Actualiza al tamano del titulo del nuevo idioma
  
  float Width  = self.bounds.size.width;                                      // Ancho disponible para la barra
  float wItem  = 0;                                                           // Ancho de los items adiconales
  float xPanel = 0;                                                           // Desplazamiento de los botones de idiomas
  
  if( OnBack ) xPanel = BACK_W;                                               // Si hay boton de Back, desplaza los botones de idioma
  wPanel = Width - xPanel;                                                    // Ancho disponible para los botones de idioma
  
  if( ItemIDs.count != 0 )                                                    // Hay iconos adicionales
    {
    wItem = (ItemIDs.count * (BTN_W+BTN_SEP)) - BTN_SEP + INI_SEP;            // Calcual ancho de los iconos adicionales
  
    wPanel -= 60;                                                             // Deja un espacio minimo para boton de menú
    if( wPanel>PANEL_MAX ) wPanel = PANEL_MAX;                                // Si el tamaño de para idiomas es suficiente, lo ajusta al maxino
    }

  LGPanel.frame = CGRectMake(xPanel, 0, wPanel, 50);                          // Ajusta el rectangulo de los botones de idioma
  [self LayoutButtons];                                                       // Refresca la distribución de los botones de idioma
  
  float resto = Width - wPanel - xPanel;                                      // Espacio disponible para botones adicionales
//  float resto = 0;                                                          // Fuerzo a que siempre ponga el boton de menú
  if( resto >= wItem && ItemIDs.count<=1 )                                    // Hay suficiente espacio
    {
    if( BtnItems.count != ItemIDs.count )                                     // Cambio el número de botones actuales
      {
      [self ClearButtonMenu ];                                                // Quita boton de menú, si estaba
      [self ClearButtonItems];                                                // Borra todos los botones adicionales
      [self CreateButtonItems:Width];                                         // Los vuelve a crear
      }
    }
  else                                                                        // No espacio para los items adicionales
    {
    if( PopUp ) [PopUp setNeedsLayout];                                       // Si estaba desplegado el menú, lo quita
    
    if( !btnMnu )                                                             // Si no esta el botón de menú
      {
      [self ClearButtonItems];                                                // Borra los botones adicionales, si existian
      [self CreateButtonMenu:Width];                                          // Crea el boton del menú
      }
    }
  
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Desplaza los botones interactivamente para mostrar o ocultar el nombre del idioma
- (void) OnGeture:(UIPanGestureRecognizer *)sender
  {
  if( _SelLng == -1 ) return;                                               // Si no hay idioma seleccionado, no hace nada
  
  CGPoint pnt;
  if( sender.state == UIGestureRecognizerStateBegan)                        // Si es cuando comienza el movimiento
    {
    pnt = [sender locationInView:self];
    
    sgnTitle = (pnt.x < xTitle)? -1.0 : 1.0;
    szTitleBegan = szTitle;                                                 // Almacena tamaño del titulo en ese momento
    }
  
  pnt = [sender translationInView:self];                                    // Obtiene valor del desplamiento (Hoz y Vert)
  
  if( sender.state == UIGestureRecognizerStateChanged )                     // Mientras se esta moviendo
    {
    szTitle = szTitleBegan + sgnTitle * pnt.x;                              // Cambia tamaño del nombre según el desplazamiento
    
    if( szTitle>szTitleLang ) szTitle = szTitleLang;                        // Si es demasiado grande lo ajuta al tamaño maximo
    if( szTitle<0           ) szTitle = 0;                                  // Si es demasiado pequeño, lo pone a 0
      
    [self LayoutButtons];                                                   // Reorganiza los botones
    }
  
  if( sender.state == UIGestureRecognizerStateEnded )                       // Termino el gesto de desplazamiento
    {
    szTitle = ( szTitle > szTitleLang/2)? szTitleLang : 0;                  // De acuerdo al tamaño actual, lo oculta o lo muestra
    [self LayoutButtons];                                                   // Reorganiza los botones
    }
  }
//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================================
