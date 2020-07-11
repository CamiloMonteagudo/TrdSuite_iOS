//=========================================================================================================================================================
//  PanelTrdView.m
//
//  Created by Camilo on 26/12/14.
//  Copyright (c) 2014 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "PanelTrdView.h"
#import "AppData.h"
#import "LangsBar.h"
#import "MainController.h"
#import "ColAndFont.h"

//=========================================================================================================================================================
@interface PanelTrdView()
  {
  UILabel*    lbTrd;                // Control con el titulo del panel
  LangsBar*   LGBar;                // Vista de la barra de idiomas
  UITextView* TrdText;              // Vista donde se muestran los resultados de la traducción
  UIButton*   btnRight;             // Boton de la derecha para filtrado y cerrar la traducción
  
  float lstWText;                   // Ancho del ultimo texto mostrado
  float lstWidth;                   // El último ancho que se redimesiono la vista
  
  NSRange MarkRange;                // Si hay un texto seleccionado y esta marcado
  BOOL    NoSelMsg;                 // No envia mensaje cuando cambia la selección
  }

@end

//--------------------------------------------------------------------------------------------------------------------------------------------------------

//=========================================================================================================================================================
@implementation PanelTrdView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];                // Clase base hace la inicializacion del objeto
  if( !self ) return nil;
  
  // Crea el label para la traducción
  NSString* slbTrd = NSLocalizedString(@"Traslate", nil);
  
  float hText = FontSize + ROUND;                         // Obtiene altura del texto
  
  lbTrd           = [[UILabel alloc] initWithFrame: CGRectMake(SEP_BRD+SEP_TXT, 0, 200, hText)];
  lbTrd.font      = fontPanelTitle;
  lbTrd.textColor = ColPanelTitle;
  lbTrd.text      = slbTrd;
  
  [self addSubview: lbTrd];
  
  // Crea la barra de idiomas
  LGBar = [[LangsBar alloc] initWithView:self Trd:TRUE];    // Crea la barra de idiomas en la parte superior
  
  [LGBar OnSelLang:@selector(OnSelLang:) Target:self];      // Pone callback para cuando se seleccione un idioma

  [self addSubview:LGBar];                                  // Adiciona la barra a la lista

  [self MakeBtnRight];                                      // Crea el boton de la derecha
  
  // Crea el texto de la traducción
  CGSize sz  = LGBar.frame.size;
  CGRect frm = CGRectMake(SEP_BRD, hText+sz.height, sz.width, LineHeight);
  
  TrdText = [[UITextView alloc] initWithFrame: frm];
  TrdText.font  = fontEdit;

  float mVert = (FontSize-1)/2;
  TrdText.textContainerInset = UIEdgeInsetsMake(mVert, 0, mVert, 0);
  
  TrdText.delegate = self;                              // Pone delegado para el control de texto
  TrdText.layoutManager.delegate = self;                // Pone delegado para el layoutManager del control de texto
  
  [self addSubview:TrdText];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se va a liberar la vista
-(void) RefreshView
  {
  TrdText.font = fontEdit;
  lbTrd.font   = fontPanelTitle;
                                          
  float mVert = (FontSize-1)/2;
  TrdText.textContainerInset = UIEdgeInsetsMake(mVert, 0, mVert, 0);
  
  [LGBar RefreshView];
  
  lstWidth = 0;
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el boton de la dercha
- (void) MakeBtnRight
  {
  float x = self.bounds.size.width-BTN_W-SEP_BRD;
  float y = LGBar.frame.origin.y;
  
  CGRect rc = CGRectMake( x, y, BTN_W, BTN_H);
  
  btnRight = [[UIButton alloc] initWithFrame:rc];
  
  [btnRight addTarget:self action:@selector(OnBtnRight:) forControlEvents:UIControlEventTouchUpInside];
   
  btnRight.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  
  [btnRight setImage: [UIImage imageNamed: @"BtnMoveUp" ] forState: UIControlStateNormal ];
  
  [self addSubview:btnRight];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca el boton de la derecha
- (void)OnBtnRight:(id)sender
  {
  HideKeyBoard();                                                              // Se oculta el teclado si esta desplegado
  
  [_Ctrller OnBtnHideTrd ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama por la barra de botones, cuando se selecciona un idioma mediante los botones de las banderas
- (void)OnSelLang:(LangsBar*) view
  {
  HideKeyBoard();                                       // Oculta el teclado
  
  [self setSelLng:LGBar.SelLng];                        // Establece idioma para esta clase
  
  [_Ctrller OnBtnTrd];                                  // Manda a traducir el texto fuente desde el controlador
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Funcion para establecer el valor de la propiedad 'SelLng'
- (void)setSelLng:(int)SelLng
  {
  if( LGBar.SelLng != SelLng )                          // Si es un idioma diferente al actual en la barra de botones
    LGBar.SelLng = SelLng;                              // Lo cambia

//  self.FunBntR = (LGBar.SelLng==-1)?  FUN_FILTER: FUN_CLOSE;
  
  [self setNeedsLayout];                                // Reposicona las vistas internas
  [self setNeedsDisplay];                               // Redibuja rectangulo redondeado arrededor del texto
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Función para obtener el valor de la propiedad 'SelLang'
- (int)SelLng
  {
  return LGBar.SelLng;                                  // Retotorna texto actual de la barra de botones
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que de cambia la propiedad para mostrar el panel o no
- (void)setNoShow:(BOOL)NoShow
  {
  _NoShow = NoShow;
  
  if( NoShow )
    {
    self.hidden = TRUE;
    _Ctrller.OnTextTrd  = FALSE;
    }
    
  [self.superview setNeedsLayout];                    // Reorganiza los controles de la vista que contiene al panel
  [_Ctrller UpdateButtons];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que de cambia la propiedad para mostrar el texto traducido o no
-(void)setNoText:(BOOL)NoText
  {
  if( _NoText == NoText ) return;
  
  _NoText = NoText;
  LGBar.NoCur = NoText;
  
  [_Ctrller UpdateButtons];
  
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Manda a refrescar los botones de idioma, para reflejar combios en los idiomas actuales
- (void)RefreshLangs
  {
  [LGBar RefreshLangsButtons];
  self.hidden = false;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se cambia el texto
- (void)textViewDidChange:(UITextView *)textView
  {
  [_Ctrller OnChangedTextTrd];                          // Notifica al controlador que cambio el texto traducido
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se comienza a editar el texto
- (void)textViewDidBeginEditing:(UITextView *)textView
  {
  if( KbHeight != 0 )                                   // Se comenzo la edicción del texto si ocultar el teclado
    [self.superview setNeedsLayout];                    // Notifica al padre, por si hay que scrolear la vista
  
  Responder = textView;                                 // Pone la vista en edición en una varible global, para ocultar el teclado
  [self ClearMarkText];                                 // Quita la marca de la palabra seleccionada
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando termina la edicción del texto
- (void)textViewDidEndEditing:(UITextView *)textView
  {
  if( MarkRange.length > 0  )              // Si hay un texto marcado
    [self SetMarkText:MarkRange];                       // Manda a resaltarlo
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el rango del texto que esta marcado
- (NSRange) GetMarkText
  {
  return MarkRange;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el texto en el rango dado como marcado
- (void) SetMarkText:(NSRange) range
  {
  // Obtiene todo el texto con los atributos normales
  NSMutableAttributedString* Txt = [[NSMutableAttributedString alloc] initWithString:TrdText.text attributes:attrEdit];
    
  // Le aplica un color de fondo al texto que esta marcado
  [Txt addAttribute:NSBackgroundColorAttributeName value:ColTxtSel range:range];
    
  NoSelMsg  = TRUE;                                     // Pone bandera para no enviar mensaje de cambio de selección
  TrdText.attributedText = Txt;                         // Reasigna el texto con los atributos nuevos
  TrdText.selectedRange  = range;                       // Cambia la selección
  NoSelMsg  = FALSE;                                    // Quita la bandera
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita la parte del texto marcada
- (void) ClearMarkText
  {
  NoSelMsg  = TRUE;                                     // Pone bandera para no enviar mensaje de cambio de selección
  
  // Obtiene y pone, todo el texto con los atributos normales
  TrdText.attributedText = [[NSMutableAttributedString alloc] initWithString:TrdText.text attributes:attrEdit];
  
  TrdText.selectedRange  = NSMakeRange(TrdText.selectedRange.location, 0);    // Quita el rango seleccionado
  
  NoSelMsg  = FALSE;                                                          // Quita la bandera
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se cambia el texto seleccionado
- (void)textViewDidChangeSelection:(UITextView *)textView
  {
  MarkRange = TrdText.selectedRange;                                      // Pone texto marcado según rango de selección
  
  if( MarkRange.length==0 || NoSelMsg ) return;                           // Si no hay texto marcado, o es un cambio interno, no notifica

  NSString* Txt = TrdText.text;                                           // Obatiene el texto que se esta editando
  
  int ini = (int)MarkRange.location;                                      // Indice de la primera letra de la seleccion
  int fin = ini + (int)MarkRange.length - 1;                              // Indice de la ultima letra de la seleccion
  
  // Si no esta al principio de una palabra, no notifica al delegado
  if( (ini!=0 && IsLetter(ini-1, Txt) ) || !IsLetter(ini, Txt) )
    return;
  
  // Si no esta al final de una palabra, no notifica al delegado
  if( (fin!=Txt.length-1 && IsLetter(fin+1, Txt) ) || !IsLetter(fin, Txt) )
    return;
  
  [_Ctrller OnChangedSelectTextTrd];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se termina de calcular el layout del texto dentro del control de edicción
- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag
  {
  [self setNeedsLayout];                                // Recalcula distribución de los controles
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Organiza y redimesiona las vistas que estan dentro de esta vista
- (void) layoutSubviews
  {
  [self layoutLGBar];
  
  float hText  = 0;                                                               // Altura del texto por defecto
  CGRect    rc = self.frame;                                                      // Marco que ocupa el panel
  float wPanel = rc.size.width;                                                   // Ancho del panel
  float  wText = wPanel - 2*SEP_BRD - 2*SEP_TXT;                                  // Ancho del texto

  CGRect rcB  = LGBar.frame;                                                      // Marco que ocupa la barra de idiomas
  float yBtns = rcB.origin.y + rcB.size.height;                                   // Borde inferior de la barra de botones
  float hPanel;
  
  if( LGBar.SelLng==-1 || _NoText)                                                // Si no hay idioma selecionado
    {
    TrdText.hidden = TRUE;                                                        // Oculta el texto
    hPanel = yBtns - SEP_TXT;                                                     // Calcula altura del panel
    }
  else                                                                            // Hay un idioma seleccionado
    {
    CGRect rcTxt = [TrdText.layoutManager usedRectForTextContainer:TrdText.textContainer];          // Obtiene el tamaño del texto
  
    hText = rcTxt.size.height + FontSize;                                         // Obtiene altura del control, con margen arriba y abajo
    if( hText>EditMaxHeigth )                                                     // Chequea si sobrepasa el tamaño maximo
      hText = EditMaxHeigth;                                                      // Lo pone al tamaño máximo
    
    TrdText.hidden = FALSE;                                                       // Garantiza que el texto este visible
    hPanel = yBtns + hText + SEP_TXT + 2*BRD_W;                                   // Calcula altura del panel
    }

  CGSize sz = TrdText.frame.size;                                                 // Obtiene tamaño actual del control de texto
  if( sz.height != hText || rc.size.height != hPanel || lstWText != wText)        // Si cambio altura del control del texto o del panel
    {
    rc.size.height = hPanel;
    self.frame = rc;                                                              // Redimesiona el panel
    
    CGRect frm    = CGRectMake(SEP_BRD + SEP_TXT  ,yBtns, wText, hText );         // Dimensiones del control del texto
    TrdText.frame = frm;                                                          // Redimesiona control del texto
    lstWText = wText;
    
    [self  setNeedsDisplay];                                                      // Redibuja el fondo del panel
    [self.superview setNeedsLayout];                                              // Reorganiza los controles de la vista que contiene al panel
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
//  Posiciona la barra de idiomas dentro de la vista de acuerdo al espacio disponible
- (void) layoutLGBar
  {
  float w = self.bounds.size.width;                           // Ancho disponible en la vista
  if( w == lstWidth ) return;                                 // Si ya se posiciono para ese ancho no hace nada
  
  lstWidth = w;
    
  float xLabel = SEP_BRD + SEP_TXT;                           // Magnitud en la x donde se va a posicionar el label de traducir
  
  float yBar, xBar;
  if( w>370 )                                                 // Si hay mucho espacio, pone el label al lado
    {
    yBar = 0;                                                 // Y, la barra en la parte superior de la vista
    
    CGSize sz = lbTrd.attributedText.size;
    xBar = sz.width + xLabel;                                 // X, de la barra a continuación del label de traducción
    
    float hText = LGBar.frame.size.height- SEP_TXT;
    lbTrd.frame = CGRectMake(xLabel, 0, sz.width+1, hText);   // Mueve el lavel de traducción
    }
  else                                                        // Si hay poco espacio, pone le label y la barra uno arriba del otro
    {
    float hText  = FontSize + ROUND;                          // Obtiene altura del label de traducir
  
    xBar   = SEP_TXT;                                         // X, de la barra pegada a la izquierda
    yBar   = hText - SEP_BRD;                                 // Y, de la barra debajo del label de traducción
    
    lbTrd.frame = CGRectMake(xLabel, 0, w, hText);            // Mueve el lavel de traducción
    }
  
  [LGBar MoveToX:xBar Y:yBar];                                // Mueve la barra
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
//  Retorna retorna la altura de la vista sin el texto
- (float) StaticHeight
  {
  float h = self.frame.size.height;                           // Obtiene altura actual de la vista
  
  if( !TrdText.hidden )                                       // Si el texto traducido esta visible
    h -= TrdText.frame.size.height;                           // Le resta el tamaño de la vista de texto
  
  return h;                                                   // Retorna el espacio estatico de la vista
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja el contenido de la vista
- (void)drawRect:(CGRect)rect
  {
  CGSize sz    = self.frame.size;
  float w      = sz.width - 2*SEP_BRD;

  if( LGBar.SelLng!=-1 && !_NoText )
    {
    [self drawBordesLateral:sz];
    }
  else
    {
    CGRect rcVw = CGRectMake(SEP_BRD, 0, w, sz.height-BRD_W );
    DrawRoundRect( rcVw, R_INF, ColBrdRound1, ColFillRound1 );
    }
  
  if( LGBar.SelLng!=-1 && !_NoText)
    {
    float h = TrdText.frame.size.height + 2*SEP_TXT;
    
    CGRect rcB = LGBar.frame;                                                      // Marco que ocupa la barra de idioma
    float    y = rcB.origin.y + rcB.size.height - SEP_TXT;                         // Determina la altura ocupada por la barra
    
    CGRect rcTx = CGRectMake(SEP_BRD+BRD_W, y, w-2*BRD_W, h );
    
    DrawRoundRect( rcTx, 0, ColBrdRound2, ColFillRound2 );
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja los bordes laterales de la vista
- (void)drawBordesLateral:(CGSize) sz
  {
  float xIzq = SEP_BRD;
  float xDer = sz.width - SEP_BRD;

  float ySup = 0;
  float yInf = sz.height;
  
  CGContextRef ct = UIGraphicsGetCurrentContext();
  
  CGContextSetStrokeColorWithColor(ct, ColBrdRound1.CGColor);
  CGContextSetFillColorWithColor(ct, ColFillRound1.CGColor);
    
  CGContextSetLineWidth(ct, BRD_W);
  
  CGContextFillRect(ct, CGRectMake(xIzq, ySup, xDer-SEP_BRD, yInf));
    
  CGContextBeginPath(ct);
    
  CGContextMoveToPoint   (ct, xDer  , ySup );
  CGContextAddLineToPoint(ct, xDer  , yInf );
    
  CGContextMoveToPoint   (ct, xIzq  , ySup );
  CGContextAddLineToPoint(ct, xIzq  , yInf );
    
  CGContextDrawPath( ct, kCGPathFillStroke);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
  HideKeyBoard();
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el texto del control
- (NSString *)Text
  {
  return TrdText.text;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Coloca un texto en el control
- (void)setText:(NSString *)Text
  {
  TrdText.text = Text;
  
  [self setNeedsLayout];
  }


@end
//=========================================================================================================================================================

