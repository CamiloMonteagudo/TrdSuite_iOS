//=========================================================================================================================================================
//  PanelMeansView.m
//  TrdSuite
//
//  Created by Camilo on 21/05/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "PanelMeansView.h"
#import "ProxyDict.h"
#import "ProxyConj.h"
#import "AppData.h"

//=========================================================================================================================================================
@interface PanelMeansView()
  {
  float wPanel;
  float hPanel;
  
  UILabel* word;
  
  int       nowIdx;                             // Indice de la ultima palabra buscada
  NSString* nowKey;                             // Ultima palabra buscada
  }

@end

//=========================================================================================================================================================
@implementation PanelMeansView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];
  if( !self ) return nil;
  
  hPanel = 30;
  
  word = [[UILabel alloc] initWithFrame: self.frame];
  
  word.numberOfLines    = 0;
  word.backgroundColor  = ColFillGray;
    
  [self addSubview: word];
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Implementa del propiedad 'Word'
- (void)setWord:(NSString *)Word
  {
  [self FindInDictWord:Word];
  }

- (NSString *)Word
  {
  return word.text;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca la palabra actual en el diccionario
- (void) FindInDictWord:( NSString *) sWord
  {
  if( ![ProxyDict OpenDict] ) return;                                     // Si no puede abrir el diccionario no hace nada
  if( !sWord || [sWord length] == 0 )                                     // Si la palabra a buscar es nula o esta vacia
    return;                                                               // No hace nada
  
  nowKey = sWord;                                                         // Pone palabra actual para la busqueda
  nowIdx = [ProxyDict getWordIdx:nowKey];                                 // Busca la palabra en el diccionario
  
  if( ![ProxyDict Found] ) [self FindLowerWord];                          // No la encontro, la busca en minusculas
  if( ![ProxyDict Found] ) [self FindRootWord ];                          // No la encontro, busca una se sus raices

  if( [ProxyDict Found] )                                                 // Si la palabra fue encontrada
    word.attributedText = [ProxyDict getWDataFromIndex:nowIdx];            // Obtiene los significado de la palabra
  else                                                                    // Si no encontro, la palabra
    {
    NSString* sMsg = NSLocalizedString( @"WrdNoFound", nil);
    word.attributedText = [ProxyDict FormatedMsg:sMsg Title:sWord];       // Pone mensaje de palabra no encontrada
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
  NSString* rWord = [ProxyConj FindRootWord: nowKey];                     // Busca una raiza de la palabra
  if( rWord==nil ) return;                                                // No encontro raiz, no hace nada
    
  nowKey = rWord;                                                         // Pone palabra actual para la busqueda
  nowIdx = [ProxyDict getWordIdx:nowKey];                                 // Busca la palabra en el diccionario
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Recalcula la altura del texto, según el ancho disponible y el tamaño del texto
- (void) ResizeWordHeight
  {
  float w = wPanel - 2*SEP_BRD - 2*SEP_TXT;

  CGSize sz = CGSizeMake( w, 1000 );
  CGRect rc1 = [word.attributedText boundingRectWithSize:sz options:NSStringDrawingUsesLineFragmentOrigin context:nil];
  
  hPanel = (int)(rc1.size.height + 12.5);
  if( hPanel<30 ) hPanel = 30;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Redimesiona el panel y todos las vistas que contenga
- (void) layoutSubviews
  {
  CGPoint pos = self.frame.origin;                                                // Posición actual de la vista
  CGSize   sz = self.frame.size;                                                  // Tamaño actual de la vista
  
  if( sz.width != wPanel || sz.height != hPanel)                                  // Si cambio de tamaño
    {
    if( sz.width != wPanel )
      {
      wPanel = sz.width;
      [self ResizeWordHeight];
      }
    
    self.frame = CGRectMake( pos.x, pos.y, wPanel, hPanel );                      // Redimesiona la vista
    
    float w = wPanel - 2*SEP_BRD - 2*SEP_TXT;
    float h = hPanel - 2*SEP_TXT;
  
    word.frame = CGRectMake( SEP_BRD + SEP_TXT, SEP_TXT, w, h);
  
    [self  setNeedsDisplay];                                                      // Redibuja el fondo del panel
    [self.superview setNeedsLayout];                                              // Reorganiza los controles de la vista que contiene al panel
    }
  }


//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
  {
  float w = self.frame.size.width - 2*SEP_BRD;
  float h = self.frame.size.height;

  CGRect rc = CGRectMake(SEP_BRD, 0, w, h );
  
  DrawRoundRect( rc, R_INF, ColBrdBlue, ColFillGray);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//=========================================================================================================================================================
