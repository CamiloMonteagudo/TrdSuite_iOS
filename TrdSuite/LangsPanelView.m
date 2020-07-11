//=========================================================================================================================================================
//  SrcPanel.m
//  PruTranslate
//
//  Created by Camilo on 26/12/14.
//  Copyright (c) 2014 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "LangsPanelView.h"
#import "AppData.h"
#import "LangsBar.h"
#import "ColAndFont.h"

//=========================================================================================================================================================
@interface LangsPanelView()
  {
  __weak UITextView* TextCtl;
  __weak UILabel*    PlaceHolder;
  
  NSRange MarkRange;                                    // Si hay un texto seleccionado y esta marcado
  BOOL    NoSelMsg;                                     // No envia mensaje cuando cambia la selección
  
  NSString* Txts[LGCount];
  
  LangsBar* LGBar;
  int oldLng;
  
  float lstWText;
  }

@end

//--------------------------------------------------------------------------------------------------------------------------------------------------------

//=========================================================================================================================================================
@implementation LangsPanelView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];                // Clase base hace la inicializacion del objeto
  if( !self ) return nil;
  
  _BoxInit = SEP_BRD;
  _BoxMaxWidth = 50000;
  
  LGBar = [[LangsBar alloc] initWithView:self Trd:FALSE];  // Crea la barra de idiomas en la parte superior

  [self addSubview:LGBar];                              // Adiciona la barra a la lista
  
  [LGBar OnSelLang:@selector(OnSelLang:) Target:self];  // Pone callback para cuando se seleccione un idioma
  [LGBar OnSelItem:@selector(OnSelItem:) Target:self];  // Pone callback para cuando se seleccione un boton adicional
  
  TextCtl = (UITextView*)[self viewWithTag:10];         // Obtiene el control que representa al editor de texto
  
  TextCtl.font = fontEdit;
  
  float mVert = (FontSize-1)/2;
  TextCtl.textContainerInset = UIEdgeInsetsMake(mVert, 0, mVert, 0);
  
  TextCtl.delegate               = self;                // Pone delegado para el control de texto
  TextCtl.layoutManager.delegate = self;                // Pone delegado para el layoutManager del control de texto
  
  PlaceHolder = (UILabel*   )[self viewWithTag:20];     // Obtiene el control que representa al placa holder
  PlaceHolder.font      = fontEdit;
  PlaceHolder.textColor = ColHolder;
  
  oldLng = LGBar.SelLng;                                // Guarda el idioma actual
  
  _Round = R_ALL;
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Refresca el contenido de  la vista cuando cambia el tamaño de las letras
-(void) RefreshView
  {
  TextCtl.font     = fontEdit;
  PlaceHolder.font = fontEdit;
  
  float mVert = (FontSize-1)/2;
  TextCtl.textContainerInset = UIEdgeInsetsMake(mVert, 0, mVert, 0);
  
  [LGBar RefreshView];
  
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (UITextView*) GetTextView {return TextCtl;}

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Función para establecer la propiedad 'Back' (Poner/Quitar boton de retroceso)
- (void)setBack:(BOOL)Back
  {
  _Back  = Back;                                        // Pone variable que respada la propiedad
  SEL fun = Back? @selector(OnBack:) : nil;             // Si es verdero, pone callback, sino nil
  
  [LGBar OnOnBack:fun Target:self];                     // Pone callback a la barra de botones, para boton de retroceso
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Maneja si se van a mostrar titulo del idioma del idioma actual o no
- (void)setHideTitle:(BOOL)HideTitle
  {
  LGBar.HideTitle = HideTitle;
  
  _HideTitle = HideTitle;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el tipo de retorno del teclado
- (void)setReturnType:(UIReturnKeyType)ReturnType
  {
  _ReturnType = ReturnType;
  if( TextCtl )
    TextCtl.returnKeyType = ReturnType;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona un item adicional a la barra (botones de la derecha), suministrando el icono y el titulo
- (void) AddItemID:(NSString *)strItem
  {
  [LGBar AddItemId:strItem];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Borra todos los items adicionales (botones de la derecha) en la barra de botones
- (void) ClearAllItems
  {
  [LGBar ClearAllItems];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama por la barra de botones, cuando se selecciona un idioma mediante los botones de las banderas
- (void)OnSelLang:(LangsBar*) view
  {
  HideKeyBoard();                                       // Oculta el teclado
  
  [self setSelLng:LGBar.SelLng];                        // Establece idioma para esta clase
  
  if( _Delegate ) [_Delegate OnSelLang:self];           // Si hay un delegado informa que cambio el idioma
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Funcion para establecer el valor de la propiedad 'SelLng'
- (void)setSelLng:(int)SelLng
  {
  if( LGBar.SelLng != SelLng )                          // Si es un idioma diferente al actual en la barra de botones
    LGBar.SelLng = SelLng;                              // Lo cambia
  
  [self OnSelSrcLang ];                                 // Hace lo correspondiente cuando se cambia el idioma fuente
  
  [self setNeedsLayout];                                // Reposicona las vistas internas
  [self setNeedsDisplay];                               // Redibuja rectangulo redondeado arrededor del texto
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se selecciona el idioma de origen
- (void)OnSelSrcLang
  {
  int Lng = LGBar.SelLng;
  if( Lng!=-1 && Lng!=oldLng )                          // Si los idiomas son diferentes
    {
    if( oldLng>=0 )                                     // Si se habia establecido un idioma anteriomente
      Txts[oldLng] = TextCtl.text;                      // Guarda el texto que habia
    
    TextCtl.text = _NoSaveText? @"" : Txts[Lng];        // Pone el texto nuevo
    
    oldLng = Lng;
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Espera que se prosecen los mensajes
    }

  [self CheckPlaceHolder];                              // Determina si hay que poner 'place holder' o no
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Función para obtener el valor de la propiedad 'SelLang'
- (int)SelLng
  {
  return LGBar.SelLng;                                  // Retotorna texto actual de la barra de botones
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca uno de los botones adicionales de la barra (salen a la derecha)
- (void)OnSelItem:(LangsBar*) bar
  {
  HideKeyBoard();                                             // Oculata el teclado, si es visible
  _SelItem = bar.SelItem;                                     // Actualiza item seleccionado
  
  if( [_Delegate respondsToSelector:@selector(OnSelItem:)])   // Si se atiende la seleccion de un Item
    [_Delegate OnSelItem:self];                               // Informa que cambio el item seleccionado
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se oprime el boton de retroceso (se pone a la izquierda)
- (void)OnBack:(LangsBar*) bar
  {
  HideKeyBoard();                                           // Oculata el teclado, si es visible
  
  if( [_Delegate respondsToSelector:@selector(OnBack:)])    // Si se atiende boton de retorna
      [_Delegate OnBack:self];                              // Informa que se oprimio el boton Atras
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se cambia el texto
- (void)textViewDidChange:(UITextView *)textView
  {
  if( _Delegate ) [_Delegate OnChanged:self Text:textView];   // Si hay delegado informa que cambio el texto
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
  {
  if( _ReturnType!= 0 && range.length==0 && [text isEqualToString:@"\n"] )
    {
    if( [_Delegate respondsToSelector:@selector(OnKeyBoardReturn)])   // Si se atiende el retorno del teclado
        [_Delegate OnKeyBoardReturn];                                 // Llama a la función
    return NO;
    }
  
  return YES;
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
  if( MarkRange.length > 0  && _TextMark )              // Si hay un texto marcado
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
  if( !TextCtl  || !_TextMark ) return;
  
  // Obtiene todo el texto con los atributos normales
  NSMutableAttributedString* Txt = [[NSMutableAttributedString alloc] initWithString:TextCtl.text attributes:attrEdit];
    
  // Le aplica un color de fondo al texto que esta marcado
  [Txt addAttribute:NSBackgroundColorAttributeName value:ColTxtSel range:range];
    
  NoSelMsg  = TRUE;                                     // Pone bandera para no enviar mensaje de cambio de selección
  TextCtl.attributedText = Txt;                         // Reasigna el texto con los atributos nuevos
  TextCtl.selectedRange  = range;                       // Cambia la selección
  NoSelMsg  = FALSE;                                    // Quita la bandera
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita la parte del texto marcada
- (void) ClearMarkText
  {
  if( !TextCtl || !_TextMark ) return;
  
  NoSelMsg  = TRUE;                                     // Pone bandera para no enviar mensaje de cambio de selección
  
  // Obtiene y pone, todo el texto con los atributos normales
  TextCtl.attributedText = [[NSMutableAttributedString alloc] initWithString:TextCtl.text attributes:attrEdit];
  
  TextCtl.selectedRange  = NSMakeRange(TextCtl.selectedRange.location, 0);    // Quita el rango seleccionado
  
  NoSelMsg  = FALSE;                                                          // Quita la bandera
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se cambia el texto seleccionado
- (void)textViewDidChangeSelection:(UITextView *)textView
  {
  MarkRange = TextCtl.selectedRange;                                      // Pone texto marcado según rango de selección
  
  if( MarkRange.length==0 || NoSelMsg || !_TextMark ) return;             // Si no hay texto marcado, o es un cambio interno, no notifica

  NSString* Txt = TextCtl.text;                                           // Obatiene el texto que se esta editando
  
  int ini = (int)MarkRange.location;                                      // Indice de la primera letra de la seleccion
  int fin = ini + (int)MarkRange.length - 1;                              // Indice de la ultima letra de la seleccion
  
  // Si no esta al principio de una palabra, no notifica al delegado
  if( (ini!=0 && IsLetter(ini-1, Txt) ) || !IsLetter(ini, Txt) )
    return;
  
  // Si no esta al final de una palabra, no notifica al delegado
  if( (fin!=Txt.length-1 && IsLetter(fin+1, Txt) ) || !IsLetter(fin, Txt) )
    return;
  
  if( [_Delegate respondsToSelector:@selector(OnChanged:SelectText:)])    // Si se atiende la seleccion del texto
    [_Delegate OnChanged:self SelectText:textView];                       // Notifica al delegado
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se termina de calcular el layout del texto dentro del control de edicción
- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag
  {
  [self CheckPlaceHolder];                              // Determina si hay que poner 'Place holder' o no
  [self setNeedsLayout];                                // Recalcula distribución de los controles
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Chequea si el texto es vacio y pone el placeholder si es necesario
- (void) CheckPlaceHolder
  {
  if( PlaceHolder==nil ) return;                        // Si no hay placeholder no hace nada
  
  // Oculta el placeholder si no hay texto o no hay idioma seleccionado
  PlaceHolder.hidden = (TextCtl.text.length!=0 || LGBar.SelLng==-1);
  if( !PlaceHolder.hidden )                             // Si el placehoder esta visible
    {
    CGRect rc = TextCtl.frame;
    PlaceHolder.frame = CGRectMake(rc.origin.x+5, rc.origin.y, rc.size.width-3, rc.size.height);
    
    NSString* sKey   = NSLocalizedString( _PlaceHolderKey, nil );
    NSString* sLang  = LGName( LGBar.SelLng );
    PlaceHolder.text = [sKey stringByAppendingString: [sLang uppercaseString]];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Manda a refrescar los botones de idioma, para reflejar combios en los idiomas actuales
- (void)RefreshLangs
  {
  [LGBar RefreshLangsButtons];
  self.hidden = false;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Organiza y redimesiona las vistas que estan dentro de esta vista
- (void) layoutSubviews
  {
  float hText = 0;                                                                // Altura del texto por defecto
  if( LGBar.SelLng==-1 )                                                          // Si no hay idioma selecionado
    {
    TextCtl.hidden = TRUE;
    PlaceHolder.hidden = TRUE;
    }
  else
    {
    CGRect rcTxt = [TextCtl.layoutManager usedRectForTextContainer:TextCtl.textContainer];          // Obtiene el tamaño del texto
  
    hText = rcTxt.size.height + FontSize;                                         // Obtiene altura del control, mas un de margen arriba y abajo
    if( hText>EditMaxHeigth )                                                     // Chequea si sobrepasa el tamaño maximo
      hText = EditMaxHeigth;                                                      // Lo pone al tamaño máximo
    
    TextCtl.hidden = FALSE;                                                       // Garantiza que el control del texto este visible
    }

  CGRect rc    = self.frame;
  float wPanel = rc.size.width;
  float hBtns  = LGBar.frame.size.height;
  
  float  wBox  = (wPanel>_BoxMaxWidth)? _BoxMaxWidth : wPanel;
  float  wText = wBox - _BoxInit - SEP_BRD - 2*SEP_TXT;                           // Calcula ancho del control del texto
  
  float hPanel = hBtns + hText + SEP_TXT;                                         // Calcula altura del panel
  
  CGSize sz = TextCtl.frame.size;                                                 // Obtiene tamaño actual del control de texto
  if( sz.height != hText || rc.size.height != hPanel || lstWText != wText)        // Si cambio altura del control del texto o del panel
    {
    rc.size.height = hPanel;
    self.frame = rc;                                                              // Redimesiona el panel
    
    CGRect frm    = CGRectMake(_BoxInit + SEP_TXT  ,hBtns, wText, hText );        // Dimensiones del control del texto
    TextCtl.frame = frm;                                                          // Redimesiona control del texto
    lstWText = wText;
    
    PlaceHolder.frame = CGRectMake(frm.origin.x+5, frm.origin.y, frm.size.width-3, frm.size.height);
    
    [self  setNeedsDisplay];                                                      // Redibuja el fondo del panel
    [self.superview setNeedsLayout];                                              // Reorganiza los controles de la vista que contiene al panel
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
//  Retorna retorna la altura de la vista sin el texto
- (float) StaticHeight
  {
  CGSize sz1 = self.frame.size;                               // Obtiene tamaño actual de la vista
  CGSize sz2 = TextCtl.frame.size;                            // Obtiene tamaño actual del control de texto
  
  return sz1.height - sz2.height;                             // Retorna el espacio estatico de la vista
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja el borde redondiado alrededor del la vista de edicción
- (void)drawRect:(CGRect)rect
  {
  if( LGBar.SelLng==-1 ) return;
  
  float w = self.frame.size.width;
  if( w > _BoxMaxWidth ) w = _BoxMaxWidth;
  
  w = w - _BoxInit - SEP_BRD;
  
  float h = TextCtl.frame.size.height + 2*SEP_TXT;
  float y = LGBar.frame.size.height - SEP_TXT;

  CGRect rc = CGRectMake(_BoxInit, y, w, h );
  
  DrawRoundRect( rc, _Round, ColBrdRound2, ColFillRound2);
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
  return TextCtl.text;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Coloca un texto en el control
- (void)setText:(NSString *)Text
  {
  TextCtl.text = Text;
  [self setNeedsLayout];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se modifica la propiedad del redondeo inferior
- (void)setRound:(int)Round
  {
  if( _Round == Round ) return;

  _Round = Round;
  [self setNeedsDisplay];
  }

@end
//=========================================================================================================================================================

