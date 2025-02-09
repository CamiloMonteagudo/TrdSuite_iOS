//
//  TrdInfoView.m
//  TrdSuite
//
//  Created by Camilo on 03/06/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//

#import "TrdInfoView.h"
#import "AppData.h"
#import "ProxyDict.h"
#import "ProxyConj.h"
#import "MainController.h"
#import "ColAndFont.h"

//=========================================================================================================================================================
@interface TrdInfoView()
  {
  float wPanel;
  float hPanel;
  
  UILabel* Info;
  UILabel* title;
  UIView*  Frame;
  
  int       nowIdx;                             // Indice de la ultima palabra buscada
  NSString* nowKey;                             // Ultima palabra buscada
  
  UIButton* btnShowMean;                        // Muestra los significados
  UIButton* btnShowRoots;                       // Muestra las raices de las palabras
  UIButton* btnSaveTrd;                         // Guarda la traducción
  UIButton* btnEdFilter;                        // Boton de editar traducción, Poner/Quitar fitrado de oraciones
  UIButton* btnPrevios;                         // Pasa a la palabra anterior
  UIButton* btnNext;                            // Pasa al proxima palabra
  UIButton* btnClose;                           // Cierra la información que esta mostrando
  UIButton* btnChgInfo;                         // Muestra traducción, cambian información entre el texto fuente y destino
  
  int WSrc;                                     // Idioma fuente de la palabra que se esta analizando
  int WDes;                                     // Idioma fuente de la palabra que se esta analizando
  }
@end

//=========================================================================================================================================================
@implementation TrdInfoView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];
  if( !self ) return nil;
  
  hPanel    = 50;                                // Altura por defecto del panel
  _InfoMode = -1;                                // Modo del boton de información (Fuente, destino, Mostrar traducion)
  _ModeBtnRight  = -1;                           // Modo actual del boton derecho (Sin especificar)
  
  Frame = [[UIView alloc] initWithFrame: self.frame];
  Frame.backgroundColor = ColBckTrdInfo1;
  
  float w = self.frame.size.width - 2*SEP_TXT;
  float h = self.frame.size.height;
    
  Info = [[UILabel alloc] initWithFrame: CGRectMake(SEP_TXT, 0, w, h)];
  
  Info.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  Info.numberOfLines    = 0;
    
  [Frame addSubview: Info];
  [self addSubview: Frame];
  
  btnShowMean  = [self CreateButtonWithImage:@"BtnMeans2"   ];
  btnShowRoots = [self CreateButtonWithImage:@"BtnRoots2"   ];
  btnSaveTrd   = [self CreateButtonWithImage:@"BtnSave"     ];
  btnEdFilter  = [self CreateButtonWithImage:@"BtnEdit"     ];
  btnPrevios   = [self CreateButtonWithImage:@"BtnPrev2"    ];
  btnNext      = [self CreateButtonWithImage:@"BtnNext2"    ];
  btnClose     = [self CreateButtonWithImage:@"BtnMoveUp"   ];
  btnChgInfo   = [self CreateButtonWithImage:@"BtnMoveDown" ];
  
  [self CreateTitle];
  
  self.Mode = MODE_CMDS;
  
  btnSaveTrd.hidden = TRUE;
  
  return self;
  }
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Refresca el contenido de  la vista cuando cambia el tamaño de las letras
-(void) RefreshView
  {
  title.font = fontPanelTitle;
  
  if( self.Mode == MODE_MEANS ) [self ShowMeans];
  else                          [self ShowRoots];
  
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el boton que representa al idioma 'lang'
- (UIButton*) CreateButtonWithImage:(NSString*) sImage
  {
  CGRect rc = CGRectMake( 0, 0, 50, 50);
    
  UIButton* btn = [[UIButton alloc] initWithFrame:rc];
    
  [btn addTarget:self action:@selector(OnTapButton:) forControlEvents:UIControlEventTouchUpInside];
    
  [btn setTitle: @""                          forState: UIControlStateNormal ];
  [btn setImage: [UIImage imageNamed: sImage] forState: UIControlStateNormal ];
    
  [self addSubview:btn];
  
  return btn;
  }


//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea la vista para mostrar el titulo
- (void) CreateTitle
  {
  float hText = FontSize + ROUND;                         // Obtiene altura del texto
  float x = 2*(SEP_BRD + 50);
  float w = self.frame.size.width - x - 50 - SEP_BRD;
  float y = (50 - hText) / 2;
  
  title = [[UILabel alloc] initWithFrame: CGRectMake( x, y, w, hText)];
  
  title.font      = fontPanelTitle;
  title.textColor = ColPanelTitle;
  
  //title.backgroundColor = [UIColor grayColor];
    
  [self addSubview: title];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Establece el modo de trabajo y el tipo de información a mostrar
// MODE_CMDS - muestra comandos, MODE_MEANS - Muestra los significados, MODE_ROOTS - Muestra las raices
- (void)setMode:(int)Mode
  {
  _Mode = Mode;

  [self UpdateButtons];
  [self ResizeWordHeight];
  [self setNeedsLayout  ];
  [self setNeedsDisplay ];
  
  [self.superview setNeedsLayout];                                              // Reorganiza los controles de la vista que contiene al panel
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Implementa la propiedad 'SaveHidden'
- (BOOL)SaveHidden                     { return btnSaveTrd.hidden;       }
- (void)setSaveHidden:(BOOL)SaveHidden { btnSaveTrd.hidden = SaveHidden; }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Implementa la modificación de la propiedad 'Hidden' de la vista
- (void)setHidden:(BOOL)hidded
  {
  if( super.hidden != hidded )
    {
    super.hidden = hidded;
    if( hidded )
      [_Ctrller ClearMarkText];
    self.Mode = MODE_CMDS;
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Redimesiona el panel y todos las vistas que contenga
- (void) layoutSubviews
  {
  CGPoint pos = self.frame.origin;                                                // Posición actual de la vista
  CGSize   sz = self.frame.size;                                                  // Tamaño actual de la vista
  
  if( sz.width != wPanel || sz.height != hPanel )                                 // Si cambio de tamaño
    {
    if( sz.width != wPanel )
      {
      wPanel = sz.width;
      [self ResizeWordHeight];
      }
    
    self.frame = CGRectMake( pos.x, pos.y, wPanel, hPanel );                      // Redimesiona la vista
    
    if( !Frame.hidden )
      {
      float w = wPanel - 2*(SEP_BRD+1);
      float h = hPanel - 80;
  
      Frame.frame = CGRectMake( SEP_BRD+1, 40, w, h);
      }
  
    [self  setNeedsDisplay];                                                      // Redibuja el fondo del panel
    [self.superview setNeedsLayout];                                              // Reorganiza los controles de la vista que contiene al panel
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Recalcula la altura del texto, según el ancho disponible y el tamaño del texto
- (void) ResizeWordHeight
  {
  if( _Mode == MODE_CMDS )
    {
    hPanel = 50;
    Frame.hidden = TRUE;
    }
  else
    {
    Frame.hidden = FALSE;
    float w = wPanel - 2*SEP_BRD - 2;

    CGSize sz = CGSizeMake( w, 1000 );
    CGRect rc1 = [Info.attributedText boundingRectWithSize:sz options:NSStringDrawingUsesLineFragmentOrigin context:nil];
  
    int h = (int)(rc1.size.height + FontSize);                                    // Obtiene la altura del texto
    if( h<LineHeight    ) h = LineHeight;                                         // Si la altura es pequeña
    if( h>EditMaxHeigth ) h = EditMaxHeigth;                                      // Si la altura es muy grabde
  
    hPanel = h + 80;                                                              // Pone la altura del panel
    }
  
  [self SetButtonPositions];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
  {
  float w = self.frame.size.width - 2*SEP_BRD;
  
  CGRect rc = CGRectMake(SEP_BRD, 0, w, hPanel - 10 );
  
  DrawRoundRect( rc, R_INF, ColBrdRound1, ColFillRound1);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Posiciona los botones en su correspondientes lugares según el modo de trabajo
- (void) SetButtonPositions
  {
  btnPrevios.frame = CGRectMake( SEP_BRD       , 0, BTN_W, BTN_H);                    // Botones arriba y a la izquierda
  btnNext.frame    = CGRectMake( 2*SEP_BRD + 50, 0, BTN_W, BTN_H);
  
  btnClose.frame   = CGRectMake( wPanel-50-SEP_BRD, 0, BTN_W, BTN_H);                 // Botones arriba y a derecha
  
  float y  = (_Mode==MODE_CMDS)? 0 : hPanel-47;
  float x1 = SEP_BRD;
  float x2 = x1 + SEP_BRD + BTN_W;
  float x3 = x2 + SEP_BRD + BTN_W;
  float x4 = x3 + SEP_BRD + BTN_W;
  
  btnShowMean.frame  = CGRectMake( x1, y, BTN_W, BTN_H);                              // Botones de abajo y a la izquierda
  btnShowRoots.frame = CGRectMake( x2, y, BTN_W, BTN_H);
  btnEdFilter.frame  = CGRectMake( x3, y, BTN_W, BTN_H);
  btnSaveTrd.frame   = CGRectMake( x4, y, BTN_W, BTN_H);
  
  btnChgInfo.frame   = CGRectMake( wPanel-BTN_W-SEP_BRD, y, BTN_W, BTN_H);            // Boton de abajo a la derecha

  BOOL hide = (_Mode == MODE_CMDS);
  
  btnPrevios.hidden   = hide;
  btnNext.hidden      = hide;
  title.hidden        = hide;
  btnClose.hidden     = hide;
  
  if(hide) btnShowRoots.hidden = FALSE;
    
  NSString *MeanImg  = (_Mode==MODE_MEANS)? @"BtnDict2" : @"BtnMeans2";
  NSString *RootsImg = (_Mode==MODE_ROOTS)? @"BtnConj2" : @"BtnRoots2";
    
  [btnShowMean  setImage: [UIImage imageNamed:MeanImg ] forState: UIControlStateNormal ];
  [btnShowRoots setImage: [UIImage imageNamed:RootsImg] forState: UIControlStateNormal ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza lo que muestran los botones en función del contexto actual
- (void) UpdateButtons
  {
  int btnCMode = [_Ctrller GetChgInfoMode];       // Chequea modo de mostrar la información (Fuente, destino, Mostrar traducción)
  if( btnCMode != _InfoMode )                     // Solo si cambia la modo de mostrar la información
    {
    _InfoMode = btnCMode;
    
    btnChgInfo.hidden = (btnCMode==InfoModeHide);
  
    NSString *sImg = nil;
    
    switch (btnCMode)
      {
      case InfoModeHide : break;
      case InfoModeDown : sImg = @"BtnMoveDown";          break;
      case InfoModeSrc  : sImg = LGFlagFile(LGDes,@"30"); break;
      case InfoModeTrd  : sImg = LGFlagFile(LGSrc,@"30"); break;
      }

    if( sImg != nil )
      {
      [btnChgInfo setImage: [UIImage imageNamed:sImg ] forState: UIControlStateNormal ];
  
      btnChgInfo.contentEdgeInsets = UIEdgeInsetsMake(-3,0,3,0);
      }
    }
    
  int btnRMode = [_Ctrller GetEdFilterMode];
  if( btnRMode != _ModeBtnRight )
    {
    _ModeBtnRight = btnRMode;
    
    btnEdFilter.hidden = (btnRMode==0);
  
    NSString *sImg;
  
         if( btnRMode==1 ) sImg = @"BtnEdit";
    else if( btnRMode==2 ) sImg = @"BtnFilterOn";
    else if( btnRMode==3 ) sImg = @"BtnFilterOff";
    
    [btnEdFilter setImage: [UIImage imageNamed:sImg ] forState: UIControlStateNormal ];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca uno de los botones de la vista
- (void)OnTapButton:(id)sender
  {
  HideKeyBoard();                                               // Oculta el teclado
  
  [self UpdateLangs];
  
  _Ctrller.ParamWord = nowKey;
  _Ctrller.ParamSrc  = WSrc;
  _Ctrller.ParamDes  = WDes;

  if( sender == btnShowMean )
    {
    if( self.Mode != MODE_MEANS ) [self ShowMeans];
    else                          [_Ctrller ShowScreenNum:0];
    }
  else if( sender == btnShowRoots )
    {
    if( self.Mode != MODE_ROOTS ) [self ShowRoots];
    else                          [_Ctrller ShowScreenNum:1];
    }
  else if( sender == btnClose )
    {
    [_Ctrller ClearMarkText];

    self.Mode = MODE_CMDS;
    }
  else if( sender == btnChgInfo   ) {[_Ctrller OnBtnChgInfo ];}
  else if( sender == btnSaveTrd   ) {[_Ctrller OnBtnSaveTrd ];}
  else if( sender == btnEdFilter  ) {[_Ctrller OnBtnEdFilter];}
  else if( sender == btnNext      ) {[_Ctrller OnBtnNextWord];}
  else if( sender == btnPrevios   ) {[_Ctrller OnBtnPrevWord];}
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra los significados por primera ves
- (void)ShowMeans
  {
  self.Mode = MODE_MEANS;
  title.text = NSLocalizedString( @"TitleMeans", nil);

  NSString* txt = [_Ctrller GetMarkedWord];
  [self FindInDictWord:txt];
    
  btnShowRoots.hidden = FALSE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra las raises de la palabar por primera ves
- (void)ShowRoots
  {
  self.Mode = MODE_ROOTS;
  
  title.text = NSLocalizedString( @"TitleRoots", nil);

  NSString* txt = [_Ctrller GetMarkedWord];
  [self FindRootsOfWord:txt];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza los idiomas de acuerdo al modo de trabajo
- (void) UpdateLangs
  {
  if( _Ctrller.OnTextTrd ) { WSrc = LGDes; WDes = LGSrc; }
  else                     { WSrc = LGSrc; WDes = LGDes; }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca los significados de 'txt' y los muestra
- (void)FindWord:(NSString*) txt
  {
  [self UpdateLangs];
  
  if( self.Mode == MODE_MEANS ) [self FindInDictWord:txt];
  else                          [self FindRootsOfWord:txt];
  }

/****************************************************************** BUSCA SIGNIFICADOS *******************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca la palabra actual en el diccionario
- (void) FindInDictWord:( NSString *) sWord
  {
  BOOL dOk = [ProxyDict OpenDictSrc:WSrc Dest:WDes];                     // Si puede abrir el diccionario
  BOOL wOk = (sWord && [sWord length] != 0 );                             // Si la palabra a buscar no es nula o esta vacia
  BOOL fOK = FALSE;                                                       // Si la palabra fue encontrada
  
  if( dOk && wOk )                                                        // Si todo esta OK
    {
    nowKey = sWord;                                                       // Pone palabra actual para la busqueda
    nowIdx = [ProxyDict getWordIdx:nowKey];                               // Busca la palabra en el diccionario
  
    if( ![ProxyDict Found] ) [self FindLowerWord];                        // No la encontro, la busca en minusculas
    if( ![ProxyDict Found] ) [self FindRootWord ];                        // No la encontro, busca una se sus raices

    fOK = [ProxyDict Found];
    }

  if( fOK )                                                               // Si la palabra fue encontrada
    Info.attributedText = [ProxyDict getWDataFromIndex:nowIdx NoKey:FALSE];           // Obtiene los significado de la palabra
  else                                                                    // Si no encontro, la palabra
    {
    NSString* sMsg = NSLocalizedString( @"WrdNoFound", nil);
    Info.attributedText = [ProxyDict FormatedMsg:sMsg Title:sWord];       // Pone mensaje de palabra no encontrada
    }
  
  [self ResizeWordHeight];                                                // Obtiene la altura del texto
  [self setNeedsLayout];                                                  // Reorganiza los controles
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Lleva la palabra actual a minusculas y después la busca en el diccionario
- (void) FindLowerWord
  {
  NSString* lWord = [nowKey lowercaseString];                             // La lleva a minusculas
  
  if( [lWord isEqualToString:nowKey] )                                    // Si son iguales (no tenia mayusculas)
    return;                                                               // No hace nada
    
  nowKey = lWord;                                                         // Pone palabra actual para la busqueda
  nowIdx = [ProxyDict getWordIdx:nowKey];                                 // Busca la palabra en el diccionario
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca la primera raíz de la palabra que se encuentre en el diccionario
- (void) FindRootWord
  {
  NSString* rWord = [ProxyConj FindRootWord: nowKey Lang:WSrc];           // Busca una raiza de la palabra
  if( rWord==nil ) return;                                                // No encontro raiz, no hace nada
    
  nowKey = rWord;                                                         // Pone palabra actual para la busqueda
  nowIdx = [ProxyDict getWordIdx:nowKey];                                 // Busca la palabra en el diccionario
  }

/****************************************************************** BUSCA RAICES *******************************************************************/
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Las raices de la palabra 'sWord' y las pone en la vista 'Info'
- (void) FindRootsOfWord:(NSString*) sWord
  {
  [ProxyConj LoadConjLang:WSrc];

  float w = Info.frame.size.width;
  nowKey  = [sWord lowercaseString];
  
  NSAttributedString* str =  [ProxyConj GetRootWord:nowKey With:w];
  
  Info.attributedText = str;
  
  btnShowRoots.hidden = ![ProxyConj IsVerb];

  [self ResizeWordHeight];                                              // Obtiene la altura del texto
  [self setNeedsLayout];                                                // Reorganiza los controles
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================================
